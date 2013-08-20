/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        07/03/2012
 * @description Controller to add/remove Customers to a OrderWindow
 **/
public with sharing class POS_POSAddEmailController {
    
    public List<CustomerWrapper> availableCustomers{get; set;}
    public List<Order_Window_Customer__c> existingCustomers{get; set;}
    public Order_Window__c orderWindow {get; set;}
    
    public String selectedProfile {get; set;}
    public List<Profile> profileItems{get; set;}
    public String name {get; set;}
    public String accountName {get; set;}
    public string type {get; set;}
    public Boolean openAndBeyond {get; set;}

    /**** Variables for custom Email author ****/
    public Boolean ShowCustomEmailAuthor  {get; set;}
    public String fromAddress             {get; set;}
    public String toAddress               {get; set;} 
    
    public Boolean ShowJavascript  {get; set;}   
    
    public POS_POSAddEmailController(ApexPages.StandardController controller) {
        ShowJavascript=false;
        String owId = ApexPages.currentPage().getParameters().get('owId');
        type = ApexPages.currentPage().getParameters().get('type');
        ShowCustomEmailAuthor  = false;
        
        orderWindow = [Select o.Id, o.Type__c, o.Status__c, o.Name, o.Magento_Id__c, o.Fiscal_Year__c 
                        From Order_Window__c o where o.Id = :owId][0];
        if(orderWindow.Status__c == 'Open' || orderWindow.Status__c == 'Closed' || orderWindow.Status__c == 'Completed' || orderWindow.Status__c == 'Archived') {
            openAndBeyond = true;
        } else {
            openAndBeyond = false;
        }                       
                        
        profileItems = [Select p.UserType, p.Name, p.Id From Profile p];
                                
        existingCustomers = [Select o.Id, o.Magento_Id__c, o.Customer__c, o.Open_For_Shopping__c From Order_Window_Customer__c o where o.Order_Window__c=:orderWindow.Id];
    
    }
    
    public PageReference searchUsers() {
        
        String queryStr = 'Select u.Username, u.UserType, u.UserRole.Name, u.Profile.Name, ' +
             'u.Contact.Account.Name, u.Contact.Account.ShippingState, ' +
             'u.POS_Access__c, u.Name, u.Magento_Id__c, u.LastName, u.LastLoginDate, u.IsPortalSelfRegistered, ' +
             'u.IsPortalEnabled, u.IsActive, u.Id, u.FirstName, u.Email, u.AccountId From User u ' +
             'where u.IsActive=true and u.POS_Access__c=true ';
             // and u.Id not in :existingUserIds
             
        String nameLike = '%';
        if(name != null && name.trim() != '') {
            nameLike = nameLike + name + '%';
            queryStr = queryStr + ' and u.Name LIKE :nameLike';
        }

        String accountNameLike = '%';
        if(accountName != null && accountName.trim() != '') {
            accountNameLike = accountNameLike + accountName + '%';
            queryStr = queryStr + ' and u.Contact.Account.Name LIKE :accountNameLike';
        }
        
        if(selectedProfile != null && selectedProfile != 'ALL') {
            queryStr = queryStr + ' and u.Profile.Id = :selectedProfile';
        }   
        System.debug('selectedProfile = ' + selectedProfile);   
        
        // order by User Name
        queryStr = queryStr + ' order by u.Name';           
        List<User> availableUsers = Database.query(queryStr); 
            
        availableCustomers = new List<CustomerWrapper>();   
        for(User u : availableUsers) {
              // create a new wrapper by passing User for construction
              CustomerWrapper cw = new CustomerWrapper(u);
              for(Order_Window_Customer__c owc : existingCustomers) {
                if(owc.Customer__c==u.Id) {
                    //cw.checked = true;
                    cw.canShop = owc.Open_For_Shopping__c;
                    break;
                }
              }
              
              // add the wrapper to the results
              availableCustomers.add(cw);
        }           
            
        return null;
    }    
    
    public PageReference renderEmailAuthor() {
    fromAddress = [Select Id,Email from User where Id = :UserInfo.getUserId()].Email;
    toAddress   = '';
         for (CustomerWrapper cw : availableCustomers) {
                if (cw.checked) 
                 toAddress +=  cw.usr.Email + ';';    
        }    
     ShowJavascript=true;
     ShowCustomEmailAuthor = true;
     return null;
    }
    
    public PageReference saveOWCAssignments() {
        
        List<Order_Window_Customer__c> owcAddList = new List<Order_Window_Customer__c>();
        List<Order_Window_Customer__c> owcRemoveList = new List<Order_Window_Customer__c>();
 
        // add the selected Customer to a new List
        Boolean openForShopping;
        for (CustomerWrapper cw : availableCustomers) {
            if (cw.checked) {
                Boolean recordAdded = true;
                for(Order_Window_Customer__c owc : existingCustomers) {
                    if(owc.Customer__c==cw.usr.Id) {
                        recordAdded = false;
                        break;
                    }
                }
                
                if(recordAdded) {
                    if(orderWindow.Status__c=='Open') { openForShopping = true; } else { openForShopping = false; }
                    owcAddList.add(new Order_Window_Customer__c(Customer__c=cw.usr.id, Order_Window__c=orderWindow.Id, Open_For_Shopping__c=openForShopping));
                }

            } else {
                Order_Window_Customer__c removedOWC = null;
                for(Order_Window_Customer__c owc : existingCustomers) {
                    if(owc.Customer__c==cw.usr.Id) {
                        removedOWC = owc;
                        break;
                    }
                }  
                
                if(removedOWC != null) {
                    owcRemoveList.add(removedOWC);
                }                           
            }
        }
        
        try {
            if (owcAddList.size() > 0) {
                insert owcAddList;
            } 
            
            if (owcRemoveList.size() > 0) {
                delete owcRemoveList;
            }   
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));
            return null;
        }      
        
        return new PageReference('/'+ orderWindow.Id);    
 
    }        

    
    public PageReference back() {
        return new PageReference('/'+ orderWindow.Id);
    }           
    
    public class CustomerWrapper {
     
        public Boolean checked { get; set; }
        public Boolean canShop { get; set; }
        public User usr { get; set;}
     
        public CustomerWrapper(){
            usr = new User();
        }
     
        public CustomerWrapper(User u){
            usr = u;
        }
     
    }    

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('ALL', '-- All Profiles --'));
        for(Profile p:profileItems) {
            options.add(new SelectOption(p.Id,p.Name));
        }

        return options;
    }   
     public static User createCMAdminUser() {
        Profile p = [select id from profile where name='POS - CM Administrator' limit 1]; 
        User testUser = new User(alias = 'cmadmin', email='cmadminuser@modelmetrics.pos.com', 
            emailencodingkey='UTF-8', lastname='Admin', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, firstname='CM',
            timezonesidkey='America/Los_Angeles', username='cmadminuser41231@modelmetrics.pos.com');
        insert testUser; 
        return testUser;     
     }  
       public static Order_Window__c createOrderWindow(){
        Order_Window__c o = new Order_Window__c(Name = 'Test OW', Type__c='Monthly', Status__c='Open');
        o.Fiscal_Year__c = '2012';
        DateTime now = System.now();
        Date nowDate = date.newinstance(now.year(), now.month(), now.day());
        Date later = nowDate.addDays(90);
        Date muchLater = later.addDays(90);
        o.Order_Close_Date__c=later;
        o.Order_Delivery_Date__c=muchLater;
        o.Order_Start_Date__c=nowDate;
        insert o; 
        return o;                        
    } 
      public static User createStdUser() {
        Profile p = [select id from profile where name='Standard User' limit 1]; 
        User testUser = new User(alias = 'standt', email='standarduser@modelmetrics.pos.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, firstname='phil',
            timezonesidkey='America/Los_Angeles', username='standarduser231242@modelmetrics.pos.com');
        insert testUser; 
        return testUser;     
     } 
    public static testMethod void testManageOrderWindowCustomer () {
        User u = createCMAdminUser();
        List<Order_Window_Customer__c> owcList;
        List<CustomerWrapper> cwList = new List<CustomerWrapper>();
        
        System.runAs(u) {
            Order_Window__c ow =createOrderWindow();
            User usr0 = createStdUser();
            
            Order_Window_Customer__c owc11 = new Order_Window_Customer__c(Order_Window__c = ow.Id, Customer__c=usr0.id);
            insert owc11;
            
            owcList = [select id from Order_Window_Customer__c where Order_Window__c=:ow.Id];
            System.debug(' owcList - ' + owcList);
            system.assertEquals(1, owcList.size());
            
            ApexPages.currentPage().getParameters().put('owId', ow.Id+'');
            POS_POSAddEmailController ctr = new POS_POSAddEmailController(new ApexPages.StandardController(ow));
            
            Profile p = [select id from profile where name='Standard User' limit 1]; 
            User usr1 = new User(alias = 'posmmtst1', email='posmmunittest1@diageo.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p.Id,
                                timezonesidkey='America/Chicago', username='posmmunittest12@diageo.com');
            User usr2 = new User(alias = 'posmmtst2', email='posmmunittest2@diageo.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p.Id,
                                timezonesidkey='America/Chicago', username='posmmunittest24@diageo.com');
            
            /* add a new cw */
            CustomerWrapper cw0 = new CustomerWrapper(usr0); // retain the existing user as checked
            cw0.checked = true;
                                
            CustomerWrapper cw1 = new CustomerWrapper(usr1);
            cw1.checked = true;
            
            CustomerWrapper cw2 = new CustomerWrapper(usr2); // not checked
            cw2.checked = false;
            
            cwList.add(cw0);    cwList.add(cw1);    cwList.add(cw2);
            ctr.availableCustomers = cwList;
            ctr.saveOWCAssignments();
            
            owcList = [select id from Order_Window_Customer__c where Order_Window__c=:ow.Id];
            system.assertEquals(2, owcList.size());     // Original cw0 + new cw1 but not cw2   
            
            /* search user by name */
            ctr.name = 'pos';
            ctr.searchUsers();
            system.assert(ctr.availableCustomers.size() > 0);
            
            ctr.accountName = 'MM';
            ctr.selectedProfile = 'Diageo';
            ctr.searchUsers();
            ctr.getItems();
            ctr.back();
            
            /* delete a existing cw and adding new one */
            ApexPages.currentPage().getParameters().put('owId', ow.Id+'');
            POS_POSAddEmailController ctr1 = new POS_POSAddEmailController(new ApexPages.StandardController(ow));           
            cw0.checked = false;
            cw2.checked = true;
            cwList = new List<CustomerWrapper>();
            cwList.add(cw0);    cwList.add(cw1);    cwList.add(cw2);
            ctr1.availableCustomers = cwList;
            ctr1.saveOWCAssignments();
            
            owcList = [select id from Order_Window_Customer__c where Order_Window__c=:ow.Id];
            System.debug(' owcList - ' + owcList);
            system.assertEquals(1, owcList.size());  
            
            /* test on a OW in New status */
            Order_Window__c owNew =createOrderWindow();
            owNew.status__c = 'New';
            update owNew;
            
            ApexPages.currentPage().getParameters().put('owId', owNew.Id+'');
            POS_POSAddEmailController ctrNew = new POS_POSAddEmailController(new ApexPages.StandardController(owNew));
            
            cwList = new List<CustomerWrapper>();           
            cwList.add(cw0);    cwList.add(cw1);    cwList.add(cw2);
            ctrNew.availableCustomers = cwList;
            ctrNew.saveOWCAssignments();
            
            system.assert(Apexpages.hasMessages());
            system.assertEquals(1, Apexpages.getMessages().size());
            system.assert(Apexpages.getMessages()[0].getDetail().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            
           
                
        }
                
        
    }   

}