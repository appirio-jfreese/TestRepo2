public with sharing class ObjectiveTriggerActions 
{
    
    
    public static void generateActionRecordsFromObjectiveInsert(List<Objective__c> objectiveInsertList)
    {
    	
		
        Map<Id,User> activeUserMap = new Map<Id,User>( [select id, userRoleId from user where isActive = true] );
        Map<Id,UserRole> userRoleMap = new Map<Id,UserRole>( [select id, name, parentRoleId from userRole] );
        Map<Id,List<UserRole>> userRoleMapByParentId = new Map<Id,List<UserRole>>();

        for(UserRole usrRole1 : userRoleMap.values()) {
            if(usrRole1.parentRoleId != null) {
                List<UserRole> childList1 = userRoleMapByParentId.get(usrRole1.parentRoleId);
                if(childList1 == null) {
                    childList1 = new List<UserRole>();
                }
                childList1.add(usrRole1);
                /*
	            Changes done by Jai Gupta [Appirio Jaipur] for case 00002808 on Diageo NA
	            Date : Oct 15,2012
	            */
         		userRoleMapByParentId.put(usrRole1.parentRoleId,childList1);
         		/*End for case 00002808*/
            }
        }
        Map<Id,User> subordinateUsersMap = buildListOfSubordinateUsers( UserInfo.getUserId(), activeUserMap, userRoleMap, userRoleMapByParentId );
        Map<Id,List<Account>> accountMapByOwnerId = buildAccountMapByOwnerId(subordinateUsersMap.values()) ; 
        Map<String, RecordType> recordTypeByName = new Map<String, RecordType>();
        Map<Id, RecordType> recordTypeById = new Map<Id, RecordType>();
        for(RecordType rt : [select Id, Name, DeveloperName, SobjectType, IsActive from RecordType where isactive = true and ( sobjecttype = 'Objective__c' or sobjecttype = 'Action__c' )]) {
            recordTypeByName.put( rt.Name, rt );
            recordTypeById.put( rt.Id, rt );
        }
        List<Action__c> actionsToInsert = new List<Action__c>();
        
        for(Objective__c objective : objectiveInsertList)
        {
            if(shouldGenerateActionRecords(activeUserMap, userRoleMap)) {
                buildActionRecordsFromObjectiveIfRuleTrue(objective, activeUserMap, userRoleMap, 
                                                            accountMapByOwnerId, 
                                                            recordTypeByName, 
                                                            recordTypeById, 
                                                            actionsToInsert,
                                                            subordinateUsersMap.values());
            }
            
        }
        
        system.debug('========actionsToInsert 2========='+actionsToInsert );
        insert actionsToInsert ;
        
        
    }
    
    private static Boolean shouldGenerateActionRecords(Map<Id,User> activeUserMap, Map<Id,UserRole> userRoleMap)
    {
        User activeUser = activeUserMap.get( UserInfo.getUserId() );
        
        if(activeUser != null && activeUser.UserRoleId != null) {
            UserRole userRole = userRoleMap.get( activeUser.UserRoleId );
            if(userRole != null && userRole.Name == 'Sales Manager - East') {
                return true;
            }
        }
        
        return false;
    }
    
    private static void buildActionRecordsFromObjectiveIfRuleTrue(Objective__c objective, 
                                                                    Map<Id,User> activeUserMap, 
                                                                    Map<Id,UserRole> userRoleMap, 
                                                                    Map<Id,List<Account>> accountMapByOwnerId, 
                                                                    Map<String, RecordType> recordTypeByName, 
                                                                    Map<Id, RecordType> recordTypeById, 
                                                                    List<Action__c> actionsToInsert,
                                                                    List<User> subordinateUsers)
    {
        
        for(User user : subordinateUsers) {
            
            List<Account> usersAccountList = accountMapByOwnerId.get(user.Id);
            
            if(usersAccountList != null && !usersAccountList.isEmpty()) {
                
                for(Account account : usersAccountList) 
                {
                    Action__c actionToInsert = new Action__c();
                    actionToInsert.Account__c = account.Id;
                    actionToInsert.RecordTypeId = getActionRecordTypeFromObjective(objective, recordTypeByName, recordTypeById); 
                    actionToInsert.Status__c = 'Open - Not Started' ;
                    actionToInsert.Objective__c = objective.Id ;
                    actionToInsert.OwnerId = account.OwnerId ;
                    actionToInsert.BrandBottle_Size__c = objective.BrandBottle_Size__c ;
                    //actionToInsert.Cases_Displayed__c = objective.Cases_Displayed__c ;
                    //actionToInsert.Display__c 
                    //actionToInsert.Gold_Standard_Met__c
                    //actionToInsert.Location_Grade__c = objective.Location_Grade__c ;
                    
                    
                    actionsToInsert.add(actionToInsert);
                }
            }
        }
        
        
    }
    
    private static Id getActionRecordTypeFromObjective(Objective__c objective, Map<String, RecordType> recordTypeByName, Map<Id, RecordType> recordTypeById)
    {
        if(objective.RecordtypeId == null)
            return null;
        
        RecordType recordType = recordTypeById.get(objective.RecordTypeId);
        
        if(recordType == null)
            return null;
            
        String str = recordType.Name ;
        str = str.replace(' Objective', '') ;
        
        recordType = recordTypeByName.get( str ) ; //Ease of Shop Objective;  Ease of Shop;
        
        if(recordType != null) {
            return recordType.Id ;
        }
        
        return null; 
    }
    
    
    private static Map<Id,User> buildListOfSubordinateUsers( Id currentUserId, Map<Id,User> activeUserMap, Map<Id,UserRole> userRoleMap, Map<Id,List<UserRole>> userRoleMapByParentId )
    {
        Map<Id,User> userMapToReturn = new Map<Id,User>();
        User manager = activeUserMap.get( UserInfo.getUserId() );
        List<Id> roleIds = recursivelyGetListOfSubordinateRoleIds( manager.UserRoleId, userRoleMap, userRoleMapByParentId );
        
        if(!roleIds.isEmpty()) {
            Map<Id,Id> roleIdMap = new Map<Id,Id>(); 
            for(Id roleid : roleIds) {
                roleIdMap.put(roleid, roleid); //to eliminate a sub-loop
            }
            for(User usr : activeUserMap.values()) {
                if(usr.userRoleId != null && roleIdMap.get(usr.userRoleId) != null) {
                    userMapToReturn.put(usr.Id, usr);
                }
            }
        }
        
        return userMapToReturn;
    }
    
    private static List<Id> recursivelyGetListOfSubordinateRoleIds(Id currentLevelRoleId, Map<Id,UserRole> userRoleMap, Map<Id,List<UserRole>> userRoleMapByParentId)
    {
        UserRole currentLevelRole = userRoleMap.get(currentLevelRoleId);
        List<Id> listToReturn = new List<Id>();
        
        if(currentLevelRole == null)
            return listToReturn ;
        
        List<UserRole> childRoles = userRoleMapByParentId.get(currentLevelRoleId);
        if(childRoles != null) {
            for(UserRole usrRole : childRoles) {
                
                listToReturn.add(usrRole.Id);
                
                List<UserRole> subChildRoles = userRoleMapByParentId.get(usrRole.Id);
                if(subChildRoles != null) {
                    List<Id> subChildList = recursivelyGetListOfSubordinateRoleIds(usrRole.id, userRoleMap, userRoleMapByParentId);
                    if(!subChildList.isEmpty()){
                        listToReturn.addAll(subChildList);
                    }
                }
            }
            
        }
        system.debug('========listToReturn========='+listToReturn);
        return listToReturn ;
    }
    
    
    private static Map<Id,List<Account>> buildAccountMapByOwnerId(List<User> subordinateUsers) {
        
        Set<String> userIds = new Set<String>();
        Map<Id,List<Account>> mapToReturn = new Map<Id,List<Account>>();
        
        if(subordinateUsers != null)
        {
            
            for(User userObj : subordinateUsers) {
                userIds.add(userObj.Id);
            }
            /*
            Changes done by Jai Gupta [Appirio Jaipur] for case 00002808 on Diageo NA
            Date : Oct 15,2012
            */
            Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
			set<id> accRecordTypeIds = new set<id>();
			Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
			//REMOVE COMBINED accRecordTypeIds.add(rtMapByName.get('Combined Premise - Control').getRecordTypeId());
			accRecordTypeIds.add(rtMapByName.get('On Premise').getRecordTypeId());
			accRecordTypeIds.add(rtMapByName.get('Off Premise').getRecordTypeId());
			/* End for case 00002808*/
            if(userIds.size() > 0) {
            	/*
	            Changes done by Jai Gupta [Appirio Jaipur] for case 00002808 on Diageo NA
	            Date : Oct 15,2012
	            */
                /*for(Account acct : [select id, ownerId from Account where ownerId in :userIds 
                                    and (recordType.Name = 'Combined Premise - Control' or
                                            recordType.Name = 'On Premise' or
                                            recordType.Name = 'Off Premise')
                                    ]) {*/
                  for(Account acct : [select id, ownerId from Account where ownerId in :userIds 
                                    and recordTypeId IN :accRecordTypeIds LIMIT 1000
                                    ]) {
                  /* End for case 00002808*/  
                    List<Account> childList = mapToReturn.get(acct.ownerId) ;
                    
                    if(childList == null || childList.isEmpty()) {
                        childList = new List<Account>() ;
                    }
                    
                    childList.add(acct);
                    
                    mapToReturn.put(acct.ownerId, childList) ;
                    
                }
            }
            
        }
        
        
        return mapToReturn ;
    }
    
    
    
}