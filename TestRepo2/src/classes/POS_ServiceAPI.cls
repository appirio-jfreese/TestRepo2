/*
POS version of "Service API" to keep methods sepearate as to reduce the risk of collisions in modifications.
This class will only have those methods that need modifications of what's currently in the Service API class.
*/
public without sharing class POS_ServiceAPI {
	
    // different from the method in ServiceAPI as this ignores Digeo Direct Theme set on User object
    public static Set<Id> getAccBrandIdsForUser(Id userId){ 
        set<id> brandIDsFoUser = new Set<Id>();
        
        //If it's a Diageo member they have all brands so skip this 
        List<Account> diageoAccounts = [select Id from Account where name='DIAGEO' and RecordType.Name='Distributor'];
        if (diageoAccounts.size()==1) {
            //Should be one and only one.  If there's not don't try this (at home)
            Account DIAGEO = diageoAccounts.get(0);
            List<Account_Member__c> ams = [select Id from Account_Member__c where User__c = :userId and Account__c = :DIAGEO.Id];
            
            if (ams.size()>0) {
                List<Brand__c> brands = [select Id from Brand__c where diageo_direct_visible__c = true];
                for (Brand__c brand:brands) {
                    brandIDsFoUser.add(brand.Id);
                }
                return brandIDsFoUser;
            }
        }
        
        //Not a Diageo member so get the real list
        Set<Id> accountIds = Service_API.getAIDsForUser(userId);
        
        //We change this to ignore Digeo Direct Theme as while budgeting by Brand it's not relavent
        List<AccountBrand__c> userAccountBrands = [
            SELECT Brand__c
                FROM AccountBrand__c                    
                WHERE Account__c in :accountIds and Brand__r.diageo_direct_visible__c = true and Account__r.RecordTypeId in :Service_API.getAccountRecordTypeIds()
                //GROUP BY Brand__c 
        ];
        
        for (AccountBrand__c ab: userAccountBrands) {
            brandIDsFoUser.add(ab.Brand__c);
        }
       
        return brandIDsFoUser;
    }	
    
    // will return parent generic brand Ids as well, will handle cases where shopper as access to Individual but budgetted at Generic Brand.
    public static Set<Id> getAccBrandIdsWithParentForUser(Id userId){ 
        set<id> brandIDsFoUser = getAccBrandIdsForUser(userId);
        set<id> parentBrandIDs = new Set<id>();
        
        for(Brand__c brd : [Select Parent_Brand__c from Brand__c where Parent_Brand__c!=null and id in :brandIDsFoUser]) {
        	parentBrandIDs.add(brd.Parent_Brand__c);
        }    
        
        brandIDsFoUser.addAll(parentBrandIDs);
        
        return brandIDsFoUser;
    }
    
    // different from the method in ServiceAPI as this ignores Digeo Direct Theme, plus filters by brand classification
    public static Set<Id> getAccBrandIdsForUser(Id userId, String classification){ 
        set<id> brandIDsFoUser = new Set<Id>();
        
        //If it's a Diageo member they have all brands so skip this 
        List<Account> diageoAccounts = [select Id from Account where name='DIAGEO' and RecordType.Name='Distributor'];
        if (diageoAccounts.size()==1) {
            //Should be one and only one.  If there's not don't try this (at home)
            Account DIAGEO = diageoAccounts.get(0);
            List<Account_Member__c> ams = [select Id from Account_Member__c where User__c = :userId and Account__c = :DIAGEO.Id];
            
            if (ams.size()>0) {
                List<Brand__c> brands = [select Id from Brand__c where diageo_direct_visible__c = true and Classification__c = :classification];
                for (Brand__c brand:brands) {
                    brandIDsFoUser.add(brand.Id);
                }
                return brandIDsFoUser;
            }
        }
        
        //Not a Diageo member so get the real list
        Set<Id> accountIds = Service_API.getAIDsForUser(userId);
        
        //We change this to have the classification passed in.  Since this is called in the cart processing by the magento
        //user, we can't determine that based on logged in user.
        List<AccountBrand__c> userAccountBrands = [
            SELECT Brand__c
                FROM AccountBrand__c                    
                WHERE Account__c in :accountIds and Brand__r.diageo_direct_visible__c = true and Brand__r.Classification__c = :classification and Account__r.RecordTypeId in :Service_API.getAccountRecordTypeIds()
                //GROUP BY Brand__c 
        ];
        
        for (AccountBrand__c ab: userAccountBrands) {
            brandIDsFoUser.add(ab.Brand__c);
        }
       
        return brandIDsFoUser;
    }
    
    
}