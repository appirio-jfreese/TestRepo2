/**
*   @Someone added a query inside of a loop here.   
*
*/
global class BatchGenerateSurveysAfterActivation implements Database.Batchable<sObject>
{
    string query = 'select id, Due_Date__c, Activate_Survey__c, OwnerId from survey_layout__c where activate_survey__c = true';
    
    global BatchGenerateSurveysAfterActivation() 
    {
    }
    
    global BatchGenerateSurveysAfterActivation(String constructorQuery) 
    {
        query = constructorQuery;
    }
    
    global database.queryLocator start(Database.BatchableContext BC) 
    {
        if(test.isRunningTest()) {
            query += ' LIMIT 1' ;
        }
        return database.getQueryLocator(query);
    }
    
    
    
    global void execute(Database.BatchableContext BC, List<Survey_Layout__c> surveyLayoutList) 
    {
        Map<Id,Survey_Layout__c> newMap = new Map<Id,Survey_Layout__c>(surveyLayoutList);
        
        generateAndSaveChildRecordsForApplicableSurveyRecords(surveyLayoutList, newMap);
    }
    
    global Map<Id,List<SurveyLayout_Brand_Items__c>> buildBrandItemMapBySurveyLayoutId(Map<Id, Survey_Layout__c> surveyLayout) 
    {
        
        Map<Id,List<SurveyLayout_Brand_Items__c>> mapToReturn = new Map<Id,List<SurveyLayout_Brand_Items__c>>();
        
        for(SurveyLayout_Brand_Items__c brandItem : [select Id, Name, Brand__c, Survey_Layout__c, Display_Checkbox_Not_Applicable__c from SurveyLayout_Brand_Items__c where Survey_Layout__c in :surveyLayout.keySet() order by createddate] ) {
            
            List<SurveyLayout_Brand_Items__c> childList = mapToReturn.get(brandItem.Survey_Layout__c) ;
            
            if(childList == null || childList.isEmpty()) {
                childList = new List<SurveyLayout_Brand_Items__c>() ;
            }
            
            childList.add(brandItem);
            
            mapToReturn.put(brandItem.Survey_Layout__c, childList) ;
            
        }
        
        return mapToReturn ;
    }
    
    global Map<Id,List<Survey_Layout_Brand_Bottle_Item__c>> buildBrandBottleItemMapBySurveyLayoutId(Map<Id, Survey_Layout__c> surveyLayoutMap) {
        
        Map<Id,List<Survey_Layout_Brand_Bottle_Item__c>> mapToReturn = new Map<Id,List<Survey_Layout_Brand_Bottle_Item__c>>();
        
        for(Survey_Layout_Brand_Bottle_Item__c brandBottleItem : [select Id, Name, BrandBottle_Size__c, BrandBottle_Size__r.Brand__c, Survey_Layout__c from Survey_Layout_Brand_Bottle_Item__c where Survey_Layout__c in :surveyLayoutMap.keySet() order by createddate]) {
            
            List<Survey_Layout_Brand_Bottle_Item__c> childList = mapToReturn.get(brandBottleItem.Survey_Layout__c) ;
            
            if(childList == null || childList.isEmpty()) {
                childList = new List<Survey_Layout_Brand_Bottle_Item__c>() ;
            }
            
            childList.add(brandBottleItem);
            
            mapToReturn.put(brandBottleItem.Survey_Layout__c, childList) ;
            
        }
        
        return mapToReturn ;
    }
    
    global List<User> buildListOfSubordinateUsers( Id currentUserId, Map<Id,User> activeUserMap, Map<Id,UserRole> userRoleMap )
    {
        List<User> userListToReturn = new List<User>();
        User manager = activeUserMap.get( currentUserId );
        userListToReturn.add(manager);
        
        List<Id> roleIds = recursivelyGetListOfSubordinateRoleIds( manager.UserRoleId, userRoleMap );
        
        if(!roleIds.isEmpty()) {
            Map<Id,Id> roleIdMap = new Map<Id,Id>(); 
            for(Id roleid : roleIds) {
                roleIdMap.put(roleid, roleid); //to eliminate a sub-loop
            }
            
            for(User usr : activeUserMap.values()) {
                if(usr.userRoleId != null && roleIdMap.get(usr.userRoleId) != null) {
                    userListToReturn.add(usr);
                }
            }
        }
        
        return userListToReturn;
    }
    
    global List<Id> recursivelyGetListOfSubordinateRoleIds(Id currentLevelRoleId, Map<Id,UserRole> userRoleMap)
    {
        UserRole currentLevelRole = userRoleMap.get(currentLevelRoleId);
        List<Id> listToReturn = new List<Id>();
        
        if(currentLevelRole == null)
            return listToReturn ;
        
        for(UserRole usrRole : userRoleMap.values()) {
            if(usrRole.ParentRoleId == currentLevelRole.Id) {
                listToReturn.add(usrRole.Id);
                List<Id> childList = recursivelyGetListOfSubordinateRoleIds(usrRole.Id, userRoleMap) ;
                if(!childList.isEmpty()) {
                    listToReturn.addAll(childList);
                }
            }
        }
        
        return listToReturn ;
    }
    
    
    global void generateAndSaveChildRecordsForApplicableSurveyRecords(List<Survey_Layout__c> surveyLayoutList, Map<Id,Survey_Layout__c> newMap)
    {
        Map<Id,User> activeUserMap = new Map<Id,User>( [select id, userRoleId from user where isActive = true] );
        Map<Id,List<SurveyLayout_Brand_Items__c>> brandItemsMapBySurveyLayoutId = buildBrandItemMapBySurveyLayoutId(newMap);
        Map<Id,List<Survey_Layout_Brand_Bottle_Item__c>> brandBottleItemsMapBySurveyLayoutId = buildBrandBottleItemMapBySurveyLayoutId(newMap);
        
        List<Gold_Standard_Met__c> goldMetRecordsToInsert = new List<Gold_Standard_Met__c>();
        
        Map<Id,UserRole> userRoleMap = new Map<Id,UserRole>( [select id, name, parentRoleId from userRole] );
        
        //!!!!!!!!!!!!
        //if the batch was created such that the context is one record per batch, all should be o.k. with regard to optimization:
        //!!!!!!!!!!!!
        for(Survey_Layout__c surveyLayout : surveyLayoutList) 
        {
            if(surveyLayout.Activate_Survey__c == true)
            {
                //temporarily adding some duplication-avoidance logic now that the business rule has changed, and partial survey-sets may have been created.
                Set<String> existingSurveyAccountIds = new Set<String>();
                
                for(Survey__c tempSurveyRecord : [select id, Account__c from survey__c where survey_layout__c = :surveyLayout.Id]) {
                    if(tempSurveyRecord.Account__c != null)
                        existingSurveyAccountIds.add(tempSurveyRecord.Account__c);
                }
                
                
                Survey__c[] surveysInserted = new Survey__c[]{};
                List<SurveyLayout_Brand_Items__c> relatedBrandItems = brandItemsMapBySurveyLayoutId.get(surveyLayout.Id) ;
                List<Survey_Layout_Brand_Bottle_Item__c> relatedBrandBottleItems = brandBottleItemsMapBySurveyLayoutId.get(surveyLayout.Id);
                for(Account acct1 :  [select id, ownerId from account where billingstate = 'CT' and Id not in :existingSurveyAccountIds])
                {
                    Survey__c survey = new Survey__c();
                    survey.Account__c = acct1.Id ;
                    survey.Survey_Layout__c = surveyLayout.Id ;
                    survey.Due_Date__c = surveyLayout.Due_Date__c;
                    
                    surveysInserted.add(survey);
                }
                system.debug('==============surveysInserted=============='+surveysInserted);
                insert surveysInserted ;
                    
                for(Survey__c survey : surveysInserted) 
                {
                    generateSurveyChildRecords(surveyLayout, survey, relatedBrandItems, relatedBrandBottleItems, goldMetRecordsToInsert) ;
                }
                system.debug('==============goldMetRecordsToInsert=============='+goldMetRecordsToInsert);
                insert goldMetRecordsToInsert ;
                    
                    
                
            }
        
        }   
        
        
        
            
    }
    
    
    global void generateSurveyChildRecords(Survey_Layout__c surveyLayout, Survey__c survey, List<SurveyLayout_Brand_Items__c> relatedBrandItems, List<Survey_Layout_Brand_Bottle_Item__c> relatedBrandBottleItems, List<Gold_Standard_Met__c> goldMetRecordsToInsert)
    {
        if(relatedBrandItems != null && !relatedBrandItems.isEmpty())
        {
            for(SurveyLayout_Brand_Items__c brandItem : relatedBrandItems) {
                Gold_Standard_Met__c insertRecord = new Gold_Standard_Met__c();
                insertRecord.Brand__c = brandItem.Brand__c ;
                insertRecord.Survey__c = survey.Id ;
                insertRecord.Account__c = survey.Account__c ;
                insertRecord.Gold_Standard_Display_Not_Applicable__c = brandItem.Display_Checkbox_Not_Applicable__c ;
                
                goldMetRecordsToInsert.add(insertRecord);
            }
        }
        
        if(relatedBrandBottleItems != null && !relatedBrandBottleItems.isEmpty())
        {
            for(Survey_Layout_Brand_Bottle_Item__c brandBottleItem : relatedBrandBottleItems) {
                Gold_Standard_Met__c insertRecord2 = new Gold_Standard_Met__c();
                insertRecord2.Brand__c = brandBottleItem.BrandBottle_Size__r.Brand__c ;
                insertRecord2.BrandBottle_Size__c = brandBottleItem.BrandBottle_Size__c ;
                insertRecord2.Survey__c = survey.Id ;
                insertRecord2.Account__c = survey.Account__c ;
                
                goldMetRecordsToInsert.add(insertRecord2);
            }
        }
        
        
        
        
        
    }
    
        
    global void finish(Database.BatchableContext BC) 
    {
    
    }
}