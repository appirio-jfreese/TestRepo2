/********************************************************************************************************************
Name        : APPIRIO_FutureClass
Updated By  : Appirio Offshore(Rishi Khirbat)
Date        : 25th Feb, 2013
Purpose     : This is helper class of other classes that contains generic function.
********************************************************************************************************************/
public class APPIRIO_FutureClass {

    /*
    @Method Name : RecipeEditNotificationToPublisher
    @description : Method to send email notification to the Publishers when Approved Recipe gets updated by Recipe-Admin (Ref: T-120059).  
    @parameters  : List<Order__c>, Map<Id,Id>
    @returns     : Nothing
    */
    @future
    public static void RecipeEditNotificationToPublisher(set<Id> recipeIds) {
        
        //creating a account
        Account account = new Account(Name='Temp Account');
        insert account;
        
        Contact tempContact = new Contact();
        tempContact.LastName = 'tempContact';
        tempContact.AccountId = account.Id;
        tempContact.Email = 'contact@support.com';
        insert tempContact;
        
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'Approved_Recipe_Edit_Notification'];
        map<Id,List<String>> mapRecipePublisherEmails = new map<Id,List<String>>();
        
        //Query Published_Recipe__c for all records matching the Recipe ID.
        for(Digital_Published_Asset__c dpa :[Select Publisher__r.Email, 
                                            (Select Recipe__c From Published_Recipes__r Where Recipe__c IN :recipeIds) 
                                            From Digital_Published_Asset__c]) {
                                                
            if(dpa.Publisher__r.Email != null && dpa.Published_Recipes__r != null && dpa.Published_Recipes__r.size() > 0) {
                for(Published_Recipe__c pr :dpa.Published_Recipes__r) {
                    if(!mapRecipePublisherEmails.containsKey(pr.Recipe__c)) {
                        mapRecipePublisherEmails.put(pr.Recipe__c, new List<String>());
                    }   
                    mapRecipePublisherEmails.get(pr.Recipe__c).add(dpa.Publisher__r.Email);
                }
            }
        }
        
        //Send an email to the Published_Recipe__c.Digital_Published_Asset__c.Publisher__c using the following template: Approved_Recipe_Edit_Notification (contains Recipe merge fields)
        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
        for(Id recipeId :mapRecipePublisherEmails.keySet()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setWhatId(recipeId);    
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSenderDisplayName('Diageo Support');
            mail.setTargetObjectId(tempContact.id);
            mail.setToAddresses(mapRecipePublisherEmails.get(recipeId));
            //mail.setToAddresses(new String[]{'rishi.khirbat@metacube.com'}); //for testing
            mail.setTemplateId(et.id);
            lstEmails.add(mail);
        }
        if(lstEmails.size() > 0) {
            Messaging.sendEmail(lstEmails); 
        }
        
        delete tempContact;
        
    }
}