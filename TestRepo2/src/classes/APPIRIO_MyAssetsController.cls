/********************************************************************************************************************
Name        : APPIRIO_MyAssetsController
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 16th Nov, 2012
Purpose     : Controller of APPIRIO_MyAssets.page
Ref         : T-96368
			  Create Visualforce Page for "My Assets".
			  Page will display a user only Asset records in which the user is listed in the Publisher__c field on the asset. 
			  System admins will have all assets listed.
********************************************************************************************************************/
public with sharing class APPIRIO_MyAssetsController {
	
	public Boolean hasMyAssets{get;set;}
	
    public String getUserAgent() { 
        return ApexPages.currentPage().getHeaders().get('User-Agent');
    }
    
    //Method to fetch "Digital Published Assets" that will display a user only Asset records in which the user is listed 
    //in the Publisher__c field on the asset. System admins will have all assets listed.
    public List<Digital_Published_Asset__c> getMyAssets() {
    	hasMyAssets = false;
    	List<Digital_Published_Asset__c> lstDPAsset = new List<Digital_Published_Asset__c>();
    	User currUser = [Select Profile.Name, UserRole.Name From User Where Id =: UserInfo.getUserId() limit 1]; 
        if(currUser.Profile.Name.equals('System Administrator') || currUser.UserRole.Name.equals('Recipe - Admin')) {
        	for(Digital_Published_Asset__c dpAsset :[Select Name, Publisher__r.Name From Digital_Published_Asset__c order by Name]) {
        		lstDPAsset.add(dpAsset);
        		hasMyAssets=true;	
        	}
        } else {
        	for(Digital_Published_Asset__c dpAsset :[Select Name, Publisher__r.Name From Digital_Published_Asset__c Where Publisher__c =: UserInfo.getUserId() order by Name]) {
        		lstDPAsset.add(dpAsset);
        		hasMyAssets=true;	
        	}
        }
        return lstDPAsset;
    }
    
    public PageReference manageAsset() {
    	//PageReference pageRef = new PageReference('/apex/MM_RecipeView?recipeId='+recipeId+'&editMode=true');
      	//pageRef.setRedirect(true);
      	//return pageRef;
      	return null;
   }
}