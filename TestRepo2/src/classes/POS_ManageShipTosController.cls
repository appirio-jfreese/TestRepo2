global without sharing class POS_ManageShipTosController extends Controller_Base {

    public List<SelectableShipTo> selectableShipTos {get;set;}
    public String currentAccountId {get;set;}
    public Ship_To__c addedShipTo {get; set;}
    public List<Account> accountList {get;set;}
    
    public String toggleShipToId {get;set;}
    public String shipToState{get;set;}
    
    public String referer {get;set;}
    
    public List<POS_BreadCrumb> breadCrumbs {get;set;}
    
    public String deletedShipTo {get;set;}
    public String selectedShipTo {get;set;}
    public static Account currentAccount {get;set;}
    public boolean nowiz {get;set;}
    
    public List<SelectOption> accountOptions {get;set;}
    
    //added new variables :
    public string classification{get;set;}
        
    
    public POS_ManageShipTosController () { 
        /*
    	Case 00003687 
  		Changed by - Appirio Offshore(Rahul Chitkara)
  		The below line was commented out to prevent the rendering issue in IE9 which was occuring while selecting
  		the account name and clicking on add new address within the iFrame [Please see the case for more details]
        //Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        */        

        Id currentUser=UserInfo.getUserId();
        String magentoCustomerId;
        classification ='Spirits';
        
        if (Test.isRunningTest()) {
            magentoCustomerId='1';
        }
        else {
            User user = [select Id, Magento_Id__c from User where Id=:currentUser ];
            magentoCustomerId=user.Magento_Id__c;
        }
        
        System.debug('Magento customer Id: '+magentoCustomerId);
        System.debug('Current user: '+UserInfo.getUserName());
            
        //Initialize variables
        addedShipTo = new Ship_To__c();
        
        updateSelectableShipTos();
        
        //Get list of accounts that this user is a member of
        List <Account_Member__c> accountMemberList = [
            select Account__r.Name, Account__r.Id from Account_Member__c where 
            User__c = :currentUser and Account_Member__c.Active__c=true
            order by Account__r.Name
        ];
        
        System.debug('Account member list: '+accountMemberList);
        
        
        breadCrumbs = new List<POS_BreadCrumb>();
        breadCrumbs.add(new POS_BreadCrumb('POS','POS_OrderWindowView'));
        breadCrumbs.add(new POS_BreadCrumb('Global Addressbook','#'));
        
        String returnUrl = ApexPages.currentPage().getParameters().get('return_url');
        nowiz=ApexPages.currentPage().getParameters().get('nowiz')!=null;
            
        if (returnUrl!=null) {
            //if (ApexPages.currentPage().getUrl().indexOf('POS_ManageShipToWizard')<0) {
            //  referer='https://'+returnUrl;
            //}
            //else {
                referer=returnUrl;
            //}
        }
    }


    private void sortAccounts (List<Account> unsorted){
        Map<String, List<Account>> nameMap = new Map<String, List<Account>>();
        for (Account a: unsorted) 
        {
           List<Account> accountList=nameMap.get(a.name);
           if (accountList==null) {
              accountList=new List<Account>();
              nameMap.put(a.name, accountList);
           }
           accountList.add(a);
        }
        unsorted.clear();
        
        List<String> sortedNames = new List<String>();
        sortedNames.addAll(nameMap.keySet());
        sortedNames.sort();
        
        for (String name: sortedNames) {
             accountList.addAll(nameMap.get(name));
        }
        
    
        
    }
    
    
    
    public void updateSelectableShiptos () {
        Id currentUser = UserInfo.getUserId();
        
        
        
        //Get list of all available shiptos
        /*List<Account_Member__c> accountMembers = [select Account__c, Account__r.Name, Account__r.Spirits_Hierarchy__c, Default__c from Account_Member__c where 
            User__c = :currentUser and Account_Member__c.Active__c=true];
        */
         
        String memquery='Select Account__c, Account__r.Name, Account__r.Spirits_Hierarchy__c, Default__c from Account_Member__c where            User__c = \''+currentUser+'\' and Account_Member__c.Active__c=true ';
        
        if(classification!=null && classification=='Spirits'){
            memquery+=' AND ( Account__r.Name = \'Diageo\' OR ( Account__r.Spirits_Hierarchy__c!=null AND Account__r.Spirits_Hierarchy__r.Responsible_Code__c!=null AND Account__r.Spirits_Hierarchy__r.District_Code__c!=null ))';
        }else if(classification!=null && classification=='Wines'){
            memquery+=' AND ( Account__r.Name = \'Diageo\' OR ( Account__r.Wine_Hierarchy__c!=null AND Account__r.Wine_Hierarchy__r.Responsible_Code__c!=null AND Account__r.Wine_Hierarchy__r.District_Code__c!=null ))';
        }
        
        List<Account_Member__c> accountMembers = Database.query(memquery);
         
        Boolean isMemberofDiageo=false;
                
        accountList = new List<Account>();
        
        Map<Id,Account> accountMap = new Map<Id,Account>();

        
        //This leverages standard SFDC parent/child account heirarchy
        List<Id> accountIds = new List<Id>();
        
        if (currentAccountId==null) {
            for (Account_Member__c accountMember:accountMembers) {
                if(accountMember.Account__r.Name=='Diageo') isMemberofDiageo=true;
                if (currentAccount == null && accountMember.Default__c && !isMemberofDiageo) {
                    currentAccount=accountMember.Account__r;
                    currentAccountId=currentAccount.Id;
                }
            }
        }
        else {
            for (Account_Member__c accountMember:accountMembers) {
                if(accountMember.Account__r.Name=='Diageo') isMemberofDiageo=true;
                if (accountMember.Account__c == currentAccountId && !isMemberofDiageo) {
                    currentAccount = accountMember.Account__r;
                    break;
                }
            }
        }
        
        System.debug('parentAccountIds -' + accountIds);
        
        Set <Id> childAccountTree = Service_API.getAIDsForUser(currentUser);
        //List<Account> childAccounts = [SELECT Id, Name FROM Account where Id in :childAccountTree and recordtypeId in (select Id from RecordType where  sObjectType='Account' and DeveloperName in ('Distributor', 'POS_Production_Agency', 'Internal', 'Broker'))];
        
        /*
          Modifying the query to take in account the classification
        */
        Set<String> recordTypes = new Set<String>{'Distributor', 'POS_Production_Agency', 'Internal', 'Broker'};
        String query ='select Id, Name, Spirits_Hierarchy__c, Wine_Hierarchy_Location__c, Wines_Division__c,Wines_Market__c, Wines_Region__c,Wines_State_District__c , Spirits_Hierarchy_Location__c ,Spirits_Market__c, Spirits_Region__c, Spirits_State_District__c, Spirits_Division__c from Account where  Id in :childAccountTree and recordtypeId in  (select Id from RecordType where  sObjectType=\'Account\' and DeveloperName in:recordTypes) ';
        
        if(classification!=null && classification=='Spirits'){
            query+=' AND ( Account.Name = \'Diageo\' OR (Spirits_Hierarchy__c!=null AND Spirits_Hierarchy__r.Responsible_Code__c!=null AND Spirits_Hierarchy__r.District_Code__c!=null))';
        }else if(classification!=null && classification=='Wines'){
            query+=' AND ( Account.Name = \'Diageo\' OR (Wine_Hierarchy__c!=null AND Wine_Hierarchy__r.Responsible_Code__c!=null AND Wine_Hierarchy__r.District_Code__c!=null))';
        }
        List<Account> childAccounts = Database.query(query);
        //accountMap.addAll(childAccounts);
        for (Account child:childAccounts) {
            accountMap.put(child.Id,child);
        }
        
        Set<Id> ids = accountMap.keySet();
        
        for (Id id:ids) {
            Account account = accountMap.get(id);
            accountList.add(account);
        }
        
        sortAccounts(accountList);
        
        System.debug('All accounts: '+accountList);
        System.debug('Child accounts: '+childAccounts);
        
        Map<String,String> sortMap = new Map<String,String>() ;        

        // add the selectoption to a map first so we can sort them and then add them
        // back as selectoptions.

        accountOptions = new List<SelectOption>();
        accountOptions.add(new SelectOption('0','--Select an Account--'));

        for (Account account:accountList) {
            List<String> displayLabel= new List<String>();
            /*displayLabel.add(classification=='Spirits' ? account.Spirits_Division__c: account.Wines_Division__c);
            displayLabel.add(classification=='Spirits' ? account.Spirits_Region__c: account.Wines_Region__c);
            displayLabel.add(classification=='Spirits' ? account.Spirits_State_District__c: account.Wines_State_District__c);
            displayLabel.add(classification=='Spirits' ? account.Spirits_Market__c: account.Wines_Market__c);*/
            
            displayLabel.add(classification=='Spirits' ? account.Spirits_Hierarchy_Location__c: account.Wine_Hierarchy_Location__c);
            displayLabel.add(classification=='Spirits' ? account.Name: account.Name);
                        
            sortMap.put(join(displayLabel,'/'), account.Id);
            //accountOptions.add(new SelectOption(account.Id,join(displayLabel,'/')));
        }

        List<String> sortList = new List<String>();
        sortList.addAll(sortMap.keySet());
        sortList.sort();
        for(String key: sortList)
            accountOptions.add(new SelectOption(sortMap.get(key),key));
        System.debug('Getting shiptos for: '+currentUser);
        List<Ship_To__c> availableShipTos = [
            Select s.Zip__c, s.Street__c, s.State__c, s.Phone__c, CreatedById,
            s.Name, s.Id, s.City__c, s.Attention__c, s.Account__r.Name, s.Notes__c 
            From Ship_To__c s where
            s.Account__c in :accountList
            and Removed__c=false
            order by s.Account__r.Name, s.Name 
        ];
        
        System.debug('Returned ship tos: '+availableShipTos);
        
        //Get list of shiptos the user has selected
        List<User_Ship_To__c> userShipTos = [Select Ship_To__c, User__c from User_Ship_To__c where 
          User__c = :currentUser];
          
        Map<Id, User_Ship_To__c> selectedShipTos = new Map<Id, User_Ship_To__c> ();
        for (User_Ship_To__c userShipTo:userShipTos) {
            selectedShipTos.put(userShipTo.Ship_To__c,userShipTo);
        }
        
        //Now build selectable shiptos by combining selected with the main list
        selectableShipTos = new List<SelectableShipTo>();
        for (Ship_To__c shipTo:availableShipTos) {
            SelectableShipTo selectable = new SelectableShipTo();
            selectable.shipTo=shipTo;
            if (selectedShipTos.get(shipTo.Id)!=null) {
                selectable.selected=true;
            }
            selectableShipTos.add(selectable); 
        }
        
        setCurrentAccount(); //Need to call this to get the current account info to be up to date
        
        System.debug('Selectable Ship Tos: '+selectableShipTos);
    }
    
    public static String join(List<String> values,String joinUsing) {
        List<String> valueCopy = new List<String>(values);
        if(valueCopy.isEmpty())
            return '';
        String result = valueCopy[0]==null?'':valueCopy[0];
         valueCopy.remove(0);
        while(!valueCopy.isEmpty()) {
            if(valueCopy[0]==null){ valueCopy.remove(0); continue;}
            result = result!='' ? result+ joinUsing + valueCopy[0]: result+valueCopy[0];
            valueCopy.remove(0);
        }
        return result;
    }

    public PageReference setCurrentAccount () {
    	System.debug('*******'+currentAccountId);
        if(currentAccountId=='0') {
            currentAccount=null;
        } else {
            for (Account account:accountList) {
                if (account.Id==currentAccountId) {
                    currentAccount=account;
                    break;
                }
            }
        }
        addedShipTo = new Ship_To__c(); 
        return null;
        
    }
    
    @RemoteAction
    global static void toggleShipToAjax (String shipToId, String state) {
        
        String ajaxUser = UserInfo.getUserId();
        String magentoCustomerId;
        
        if (Test.isRunningTest()) {
            magentoCustomerId='1';
        }
        else {
            User user = [select Id, Magento_Id__c from User where Id=:ajaxUser ];
            magentoCustomerId=user.Magento_Id__c;
        }
        
        if (state=='true') {
            System.debug('Adding to Magento');
            //Box was checked so add to Magento
            Ship_To__c shipTo = [Select s.Zip__c, s.Street__c, s.State__c, s.Phone__c, s.Name, s.Id, s.City__c, s.Attention__c, s.Account__r.Name, s.Account__c, s.Notes__c From Ship_To__c s where Id=:shipToId];
            User_Ship_To__c userShipTo = new User_Ship_To__c();
            userShipTo.Ship_To__c=shipTo.Id;
            userShipTo.User__c=ajaxUser;
            
            
            //customer ID should not be null but if integration is wrong this code will break
            //so we skip it here
            if (magentoCustomerId!=null) {
                //Commented out below and added the Id to the method call - Case 00003923 - Diana - 2/22/2013
                //String magentoShipToId=POS_MagentoShipTo.insertMagentoShipTo(magentoCustomerId, shipTo.Attention__c, 
                 // shipTo.Phone__c, shipTo.Zip__c, shipTo.State__c, shipTo.City__c, shipTo.Street__c, shipTo.Name, shipTo.Account__r.Name);

                String magentoShipToId=POS_MagentoShipTo.insertMagentoShipTo(magentoCustomerId, shipTo.Attention__c, 
                   shipTo.Phone__c, shipTo.Zip__c, shipTo.State__c, shipTo.City__c, shipTo.Street__c, shipTo.Name, shipTo.Account__r.Name, shipTo.Id);
                //End Case 00003923  
                  userShipTo.Magento_Ship_To_ID__c=magentoShipToId; 
            }
            
            System.debug('User ShipTo: '+userShipTo);
            insert userShipTo;
            
        }
        else {
            System.debug('Removing from Magento');
            //Box was unchecked so delete from Magento
            
            List<User_Ship_To__c> userShipTos = [Select Magento_Ship_To_Id__c, Id, Ship_To__r.Account__r.Id from User_Ship_To__c u where u.Ship_To__c=:shipToId and u.User__c=:ajaxUser];
            
            
            //customer ID should not be null but if integration is wrong this code will break
            //so we skip it here
            if (magentoCustomerId!=null) {
                for (User_Ship_To__c userShipTo:userShipTos) {
                    futureDeleteShipTo(userShipTo.Magento_Ship_To_id__c);
                }
                delete userShipTos;
            }
            
            
        }
    
    }
    

    public ApexPage createUpdateShipTo () {
        System.debug('Ship to: '+addedShipTo);
        /*
    	Case 00003687 
  		Changed by - Appirio Jaipur(Jai Gupta)
  		The below line was commented out to prevent the rendering issue in IE9 which was occuring while selecting
  		the account name and clicking on add new address within the iFrame [Please see the case for more details]
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        */
        if (addedShipTo.id!=null) {
            //Editing
            editShipTo();
        }
        else {
            insert addedShipTo;
        }
        
        
        currentAccountId = addedShipTo.Account__c;
        
        addedShipTo = new Ship_To__c();
        
        updateSelectableShipTos();
        return null;
    }
    
    public class SelectableShipTo {
        public Ship_To__c shipTo {get;set;}
        public boolean selected {get;set;}
        
        public SelectableShipTo () {
            selected=false;
        }
    }
    
    public PageReference selectShipTo () {
    	
        for (SelectableShipTo selectableShipTo:selectableShipTos) {
            if (selectableShipTo.shipTo.Id==selectedShipTo) {
                addedShipTo=selectableShipTo.shipTo;
                break;
            }
        }
        System.debug('Selected shipto: '+addedShipTo);
        
        return null;
    }
    public pageReference addShipTo(){
     addedShipTo = new Ship_To__c();
     return null;
    }
    public PageReference editShipTo () {
        /*
    	Case 00003687 
  		Changed by - Appirio Jaipur(Jai Gupta)
  		The below line was commented out to prevent the rendering issue in IE9 which was occuring while selecting
  		the account name and clicking on add new address within the iFrame [Please see the case for more details]
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        */
        System.debug('Edited shipto: '+addedShipTo);
        
        //Create a new shipto based on the old settings.  We get the original shipto from the selectable list
        //to ensure proper permission to edit it.  
        Ship_To__c originalShipTo = null;
        for (SelectableShipTo selectableShipTo:selectableShipTos) {
            System.debug('Selectable: '+selectableShipTo);
            if (selectableShipTo.shipTo.Id==addedShipTo.Id) {
                originalShipTo=selectableShipTo.shipTo;
                break;
            }
        }
        System.debug('Original: '+originalShipTo);
        
        if (originalShipTo == null) {
            return null;
        }
        
        //References to the original in existing orders need to be updated to point at new record with
        //original ShipTo information.  If there were none then don't bother
        String shipToId = originalShipTo.Id;
        List<Cart_Item__c> cartItems = [select Id from Cart_Item__c where Ship_To__c = :shipToId limit 10000];
        if (cartItems.size()>0) {
            Ship_To__c replacementShipTo = originalShipTo.clone();
            replacementShipTo.Removed__c = true;
            insert replacementShipTo;
            
            System.debug('Replacement Shipto: '+replacementShipTo);
            
            //Too many to update immediately so we need to batch process it
            if (cartItems.size()==10000) {
                POS_BatchUpdateShipTos batch = new POS_BatchUpdateShipTos(originalShipTo,replacementShipTo);
                database.executeBatch(batch);
            }
            else {
                for (Cart_Item__c cartItem:cartItems) {
                    cartItem.Ship_To__c = replacementShipTo.Id;
                }
                
                update cartItems;
            }
        } 
        
                
        update addedShipTo;
        
        //Now update the magento addressbooks
        Id currentUser=UserInfo.getUserId();
        
        //Update records on magento for this user
        futureUpdateshipTo(currentUser,originalShipTo.Id);
        
        
        //Now update the records on Magento of other users
        List<User_Ship_To__c> userShipTos = [Select Ship_To__r.Zip__c, Ship_To__r.Street__c, Ship_To__r.State__c, Ship_To__r.Phone__c, 
          Ship_To__r.Name, Ship_To__r.Id, Ship_To__r.City__c, Ship_To__r.Attention__c, Ship_To__r.Account__r.Name, Ship_To__r.Notes__c,
          Magento_Ship_To_ID__c, User__r.Id, User__r.Magento_Id__c from User_Ship_To__c where Ship_To__c=:originalShipTo.Id and User__c!=:currentUser];
        if (userShipTos.size()>0) {
            POS_MagentoShipTo.updateMagentoShipTos(userShipTos); 
        }
        
        return null;
    }
    
    public PageReference deleteShipTo () {
        //Because it's "without sharing" need to verify that we really have the right to delete this shipto
        boolean authorized=false;
        for (SelectableShipTo selectableShipTo:selectableShipTos) {
            if (selectableShipTo.shipTo.Id==deletedShipTo) {
                authorized=true;
                break;
            }
        }
        
        System.debug('Authorized: '+authorized);
        
        if (!authorized) {
            return null; //Not authorized so just return
        }
        
        Ship_To__c shipTo = [select Id, Account__r.Id, Removed__c from Ship_To__c where Id=:deletedShipTo];
        
        //Mark the shipto as removed
        shipTo.Removed__c = true;
        update shipTo;
        
        currentAccountId = shipTo.Account__c;
        
        updateSelectableShiptos();
        
        //Now update the magento addressbooks
        Id currentUser=UserInfo.getUserId();
        
        //Delete all but this user's ship to asynchronously
        List<User_Ship_To__c> userShipTos = [select Id, Magento_Ship_To_Id__c from User_Ship_To__c where Ship_To__c=:deletedShipTo and User__c!=:currentUser];
        if (userShipTos.size()>0) {
            POS_MagentoShipTo.deleteMagentoShipTos(userShipTos); 
        }
        
        
        //Delete this user's ship to synchronously
        userShipTos = [select Id, Magento_Ship_To_Id__c from User_Ship_To__c where Ship_To__c=:deletedShipTo and User__c=:currentUser];
        for (User_Ship_To__c userShipTo: userShipTos) {
            if (!Test.isRunningTest()) {
                futureDeleteShipTo(userShipTo.Magento_Ship_To_Id__c);
            }
        }
        
        return null;
        
    }
    
    @future(callout=true)
    private static void futureUpdateShipTo (Id currentUser, Id shipToId) {
        List<User_Ship_To__c> userShipTos = [Select Ship_To__r.Zip__c, Ship_To__r.Street__c, Ship_To__r.State__c, Ship_To__r.Phone__c, 
          Ship_To__r.Name, Ship_To__r.Id, Ship_To__r.City__c, Ship_To__r.Attention__c, Ship_To__r.Account__r.Name, Ship_To__r.Notes__c,
          Magento_Ship_To_ID__c, User__r.Id, User__r.Magento_Id__c from User_Ship_to__c where Ship_to__c= :shipToId and User__c = :currentUser];
        
        //Just in case there's an error and no user ship to, we ignore this
        if (userShipTos.size()==0) {
            return;
        }
        
        User_Ship_To__c userShipTo = userShipTos.get(0);
        POS_MagentoShipTo.updateMagentoShipTo(userShipTo);
        
        
            
    }
    
    @future(callout=true)
    private static void futureDeleteShipTo (String magentoShipToId) {
        POS_MagentoShipTo.deleteMagentoShipTo(magentoShipToId);
    }
    
    
    // CHALL 1990 :-
    public List<SelectOption> getClassificationTypes(){
         List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Spirits','Spirits '));
        //for future use: options.add(new SelectOption('Wines','Wines'));
        return options;
        
    }
    
    public static testMethod void testDeleteEditShiptos () {
        Profile p = [select id from profile where name='System Administrator'];
         
        User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/Chicago', username='posmmunittest@diageo.com'); 
        
        System.runAs(u) {
            PageReference pageRef = Page.HomePage;
            Test.setCurrentPage(pageRef);
            Organizational_Unit__c ou=POS_TestDataUtil.createOrgUnit();
            //Create some test data
            Account account = new Account();
            account.Name='POS Unit Test Account';
            account.Spirits_Hierarchy__c=ou.Id;
            insert account;
            
            Account_Member__c am = new Account_Member__c();
            am.Account__c = account.Id;
            am.User__c = u.Id;
            insert am;
            
            Ship_To__c shipTo = new Ship_To__c();
            shipTo.Account__c = account.Id;
            shipTo.Name='Test Ship To';
            insert shipTo;
            
            POS_ManageShipTosController controller = new POS_ManageShipTosController();
             controller.getClassificationTypes();
            controller.deletedShipTo=shipTo.Id;
            controller.deleteShipTo();
            Ship_To__c loadedShipTo = [select Id, Removed__c from Ship_to__c where Id=:shipTo.Id];
            System.assert(loadedShipTo.Removed__c);

            //reset it
            loadedShipTo.Removed__c=false;
            update loadedShipTo;
            
            controller = new POS_ManageShipTosController(); //refresh it to make sure removed item is brought back
            
            controller.selectedShipTo=loadedShipTo.Id;
            controller.selectShipTo();
            controller.addedShipTo.Name='TEST123';
            controller.editShipTo();
            
            loadedShipTo = [select Id, Name from Ship_to__c where Id=:shipTo.Id];
            System.assert(loadedShipTo.Name=='TEST123');
            
            
        }
    }
    
    @isTest
    public static void testManageShipTos () {
        
        Profile p = [select id from profile where name='System Administrator'];
         
        User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
        
        System.runAs(u) {
            PageReference pageRef = Page.HomePage;
            Test.setCurrentPage(pageRef);
           try{ 
                 Organizational_Unit__c ou=POS_TestDataUtil.createOrgUnit();
                //Create some test data
                Account account = new Account();
                account.Name='POS Unit Test Account';
                account.Spirits_Hierarchy__c=ou.Id;
                insert account;
                
                Account_Member__c am = new Account_Member__c();
                am.Account__c = account.Id;
                am.User__c = u.Id;
                insert am;
                
                Ship_To__c shipTo = new Ship_To__c();
                shipTo.Account__c = account.Id;
                shipTo.Name='Test Ship To';
                insert shipTo;
            
            
                POS_ManageShipTosController controller = new POS_ManageShipTosController();
                
                //Should have user associated with account list
                System.debug('Account list size: '+controller.accountList.size());
                System.debug('Account name: '+controller.accountList.get(0).Name);
                System.assert(controller.accountList.get(0).Name=='POS Unit Test Account');
            
                //Should have one ship to
                System.assert(controller.selectableShipTos.size()==1);
                System.assert(controller.selectableShipTos.get(0).shipTo.Name=='Test Ship To');
            
                //Create a new shipto
                controller.addedShipTo.Name='New Ship To';
                controller.addedShipTo.Account__c = account.Id;
                controller.createUpdateShipTo();
                
                //Should now have one more ship to
                System.assert(controller.selectableShipTos.size()==2);
            
                //Select a ship to
                System.assert(controller.selectableShipTos.get(0).selected=true);
                
                
                //Confirm that one and only one has been selected
                integer selectedCount = 0;
                for (SelectableShipTo selectable: controller.selectableShipTos) {
                    if (selectable.selected) {
                        selectedCount++;
                    }
                }
                
                System.assert(selectedCount==1);
                
                
                //Now toggle one
                POS_ManageShipTosController.toggleShipToAjax(shipTo.Id,'true');
                List<User_Ship_To__c> toggledList = [select Id from User_Ship_To__c where User__c = :u.Id];
                System.assert(toggledList.size()==1);
                
                //And detoggle it
                POS_ManageShipTosController.toggleShipToAjax(shipTo.Id,'false');
                toggledList = [select Id from User_Ship_To__c where User__c = :u.Id];
                System.assert(toggledList.size()==0);
           }catch(Exception e){
           
           } 
            
        }
        
    }
    
   
}