/*******************************************************************************
Name 				: Controller_UserProfile.cls

Updated By 	: Basant Kumar Verma (Appirio OffShore)
Date				: 15/6/2013
Story/Task	: US79/DE594

*******************************************************************************/
public with sharing class Controller_UserProfile extends Controller_Base{
    public User UserRecord {get;set;}
    
    
    public Controller_UserProfile() {
        pageUrl = Page.UserProfile.getUrl();
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), 'User Profile');
        setupData();
    }
    
    public List<SelectOption> getTimezones() {
        return Service_UserInput.getTimezones();
    }
        
    public PageReference updateUserRecord() {
        try {
            UserRecord.Use_current_theme_as_default__c = UserRecord.Diageo_Direct_Theme__c;
            update UserRecord;
            PageReference p = Page.UserProfile;
            p.setRedirect(true);
            return p;  
        } catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Cannot save user data.'));
            return null;
        }
    }
    
    public void cancelEdit() {
        setupData();
    }
    
    private void setupData(){
    		// Start : Changes for US79/DE594 - Basant Verma
    		// Also Fetched Content_Notification_Frequency__c
        UserRecord = [SELECT Id, Name, Username, Contact.Account.Name, 
        	TimeZoneSidKey, Phone, Alternate_Email__c, Number_of_items_per_page__c, 
        	Diageo_Direct_Theme__c, Content_Notification_Frequency__c 
        	FROM User WHERE Id=:UserInfo.getUserId()];
        // End : Changes for US79/DE594 - Basant Verma
    }
}