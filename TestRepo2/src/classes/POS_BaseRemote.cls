global without sharing virtual class POS_BaseRemote {

	// is defined as extension to Controller_Base in POS_Header.component
    public POS_BaseRemote(Controller_Base controller ) {
            
    }    
    
    @RemoteAction 
    global static list<Brand__c> searchForBrand(String shopperId, String orderWindowId) { 
    	list<Brand__c> finalResponse = new list<Brand__c>();
		    	
        if(shopperId != null && shopperId != '' && orderWindowId != null && orderWindowId != ''){
			Set<Id> userBrands = POS_ServiceAPI.getAccBrandIdsForUser(shopperId);
			set<ID> alreadyAdded = new set<id>();
			
			list<Item_Brand__c> resultDirect = [
				SELECT Brand__r.Id, Brand__r.Name 
				FROM Item_Brand__c 
				where 
					Item__r.Program__r.Order_Window__r.Id = :orderWindowId 
					and
					Item__r.Status__c not in ('Cancelled', 'Removed')
					and
					Primary__c=true
					and 
					Brand__r.Id in:userBrands
			];
			
			for(Item_Brand__c itemBrand : resultDirect){
				alreadyAdded.add(itemBrand.Brand__r.Id);
			}
			
			list<Item_Brand__c> resultParent = [
				SELECT brand__r.Parent_Brand__c, Brand__r.Parent_Brand__r.Name 
				FROM Item_Brand__c 
				where 
					Item__r.Program__r.Order_Window__r.Id = :orderWindowId 
					and
					Item__r.Status__c not in ('Cancelled', 'Removed')
					and
					Primary__c=true
					and 
					brand__r.Parent_Brand__c in:userBrands
					and 
					brand__r.Parent_Brand__c != null					
			];
			
			for(Item_Brand__c itemBrand : resultParent){
				alreadyAdded.add(itemBrand.Brand__r.Parent_Brand__c);
			}			
			
			finalResponse = [Select Id, Name from Brand__c where id in :alreadyAdded order by Name] ;
        }
        
        return finalResponse;      
    }   
    
    @RemoteAction
    global static list<Program__c> searchForProgram(Id brandId, String orderWindowId){
    	// get all the childBrand Ids if the brandId passed to this is parent brand Id
    	Map<Id, Brand__c> childBrands = new Map<Id, Brand__c>([SELECT Id, Name from Brand__c where Parent_Brand__c=:brandId]);
    	System.debug('searchForProgram:childBrands -' + childBrands);
    	
    	List<Item_Brand__c> brands = [
    		select Item__r.Program__c 
    		from Item_Brand__c 
    		where 
    			Item__r.Program__r.Order_Window__r.Id = :orderWindowId
    			and Item__r.Status__c not in ('Cancelled', 'Removed')
    			and Primary__c = true
    			and (Brand__c = :brandId or Brand__c in :childBrands.keySet())
    		];
    	
    	Set<Id> programsIDs = new Set<Id>();
    	for(Item_Brand__c brand : brands)
    		programsIDs.add(brand.Item__r.Program__c);
    		
    	return [select Id, Name from Program__c where id in :programsIDs order by Name];
    }
    
    @RemoteAction
    global static list<Program__c> searchForProgramItemAllocation(Id itemId, String orderWindowId){
    	List<Item__c> items = [
    		select Program__c 
    		from Item__c 
    		where 
    			Program__r.Order_Window__r.Id = :orderWindowId
    			and Status__c not in ('Cancelled', 'Removed')
    			and Id = :itemId
    		];
    	
    	Set<Id> programsIDs = new Set<Id>();
    	for(Item__c itm : items)
    		programsIDs.add(itm.Program__c);
    		
    	return [select Id, Name from Program__c where id in :programsIDs order by Name];
    }    
    
    @RemoteAction
    global static list<Item__c> searchForItemsOnAllocation(Id shopperId, String orderWindowId){  
    	Set<Id> userAcctBrandIds = POS_ServiceAPI.getAccBrandIdsForUser(shopperId); 
    	List<Item_Brand__c> brands = [
    		SELECT Id, Item__c FROM Item_Brand__c 
    		where Item__r.Program__r.Order_Window__c = :orderWindowId
    		 and Item__r.Status__c not in ('Cancelled', 'Removed') and Item__r.On_Allocation__c=true //and Primary__c=true
    		 and (Brand__c in :userAcctBrandIds or Brand__r.Parent_Brand__c in :userAcctBrandIds)
    	];
    	System.debug('brands -' + brands);
    	
    	Set<Id> itemIDs = new Set<Id>();
    	for(Item_Brand__c brand : brands)
    		itemIDs.add(brand.Item__c);
    		
    	return [select Id, Name from Item__c where id in :itemIDs order by Name];    	
    }
    
    @RemoteAction
    global static list<Account> searchForDistributorsItemAllocation(String itemId, Id userId){
    	Item_Brand__c itmbrand = [select Brand__c from Item_Brand__c where Item__c = :itemId];
    	return searchForDistributors(itmbrand.Brand__c, userId);
    }    
    
    
    @RemoteAction
    global static list<Account> searchForDistributors(String brandId, Id userId){
    	Brand__c brand = [select Classification__c from Brand__c where id = :brandId];
    	String hierarchy = brand.Classification__c;
    	
    	if(hierarchy != 'Spirits' && hierarchy != 'Wine')
    		return new List<Account>();
    	
    	List<Id> userOrgIds = new List<Id>();
    	Boolean isDiageoAcctMbr = false;
    	String queryForMembers = 'SELECT Account__r.Name name, Account__r.'+hierarchy+'_Hierarchy__c hierarchy from Account_Member__c where User__c= \''+userId+'\'and Active__c=true group by id, Account__r.Name, Account__r.'+hierarchy+'_Hierarchy__c';
	    for(AggregateResult am : Database.query(queryForMembers)) {
	       	if(am.get('hierarchy') != null) {
	       		userOrgIds.add((Id)am.get('hierarchy'));
	       	} else if (am.get('name') == 'diageo') { // Diageo Acct. will not have Org coding, if Business changes this and code ORG on it that will be used via the first if
	       		isDiageoAcctMbr = true;
	       		break;
	       	}
	    }
    	
    	if(isDiageoAcctMbr) {
    		return [SELECT Id, Name FROM Account where RecordTypeId in (SELECT Id FROM RecordType where DeveloperName='Distributor')  order by Name];
    	}
    	
    	Set<Id> userOrgIdTree = Service_API.getAllChildOU(userOrgIds);
    	List<Id> acctIdsFromOrgAccts = new List<Id>();
    	if(userOrgIdTree != null && userOrgIdTree.size() > 0) { // User Org Hierarchy is not coded
	    	String queryForAccounts = 'SELECT Id, Name FROM Account where Active__c!=\'No\' and '+hierarchy+'_Hierarchy__c in '+idSetToString(userOrgIdTree);
	    	List<Account> acctsFromOrgAccts = Database.query(queryForAccounts);
																																			
		    
		    for(Account acct : acctsFromOrgAccts) {
		       	acctIdsFromOrgAccts.add(acct.Id);
		    }
    	}
    	
    	return [SELECT Id, Name FROM Account where Id in :acctIdsFromOrgAccts and
	        									RecordTypeId in (SELECT Id FROM RecordType where DeveloperName='Distributor')  order by Name];
    }
    
    
    @RemoteAction
    global static list<Organizational_Unit__c> searchForGeographyItemAllocation(String itemId, Id userId){
    	Item_Brand__c itmbrand = [select Brand__c from Item_Brand__c where Item__c = :itemId];
    	return searchForGeography(itmbrand.Brand__c, userId);
    }    
    
    @RemoteAction
    global static list<Organizational_Unit__c> searchForGeography(String brandId, Id userId){
    	Brand__c brand = [select Classification__c from Brand__c where id = :brandId];
    	String hierarchy = brand.Classification__c;
    	Boolean isDiageoAcctMbr = false;
    	
    	if(hierarchy != 'Spirits' && hierarchy != 'Wine')
    		return new List<Organizational_Unit__c>();
    	
    	List<Id> userOrgIds = new List<Id>();
    	String queryForMembers = 'SELECT Account__r.Name name, Account__r.'+hierarchy+'_Hierarchy__c hierarchy from Account_Member__c where User__c= \''+userId+'\'and Active__c=true group by id, Account__r.Name, Account__r.'+hierarchy+'_Hierarchy__c';
	    for(AggregateResult am : Database.query(queryForMembers)) {
	       	if(am.get('hierarchy') != null) {
	       		userOrgIds.add((Id)am.get('hierarchy'));
	       	} else if (am.get('name') == 'diageo') { // Diageo Acct. will not have Org coding, if Business changes this and code ORG on it that will be used via the first if
	       		isDiageoAcctMbr = true;
	       		break;
	       	}
	    }
    	
    	if(isDiageoAcctMbr) {
    		return [SELECT Id, Hierarchy_Location__c from Organizational_Unit__c where Type__c=:hierarchy order by Hierarchy_Location__c];
    	}
    	    	
    	Set<Id> userOrgIdTree = Service_API.getAllChildOU(userOrgIds);
    	return [SELECT Id, Hierarchy_Location__c from Organizational_Unit__c where id in :userOrgIdTree order by Hierarchy_Location__c];
    }
    
    private static string idSetToString(set<Id> ids){
    	String ret = '(';
    	String glue = '';
    	for(Id id : ids){
    		ret += glue + '\''+id+'\'';
    		glue = ',';
    	}
    	ret += ')';
    	return ret;
    }
}