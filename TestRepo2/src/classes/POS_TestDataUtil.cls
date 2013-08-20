/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/08/2012
 * @description Reusable helper methods for preparing data for Unit Tests
 */
 
@isTest
public class POS_TestDataUtil {
    
    private static RecordType productionAgency = [select Id, Name from RecordType where Name='POS Production Agency'];
    private static RecordType distributorAccount = [select Id, Name from RecordType where Name='Distributor'];
    
    public static void initializeTestData () {
        //Added to acommodate brand update trigger from Diageo Direct
        List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'Diageo'];
        if (accounts.size()==0) {
            Account diageo = new Account();
            diageo.Name='Diageo';
            diageo.RecordTypeId=distributorAccount.Id;
            insert diageo;
        }
        
        //Added to acommodate brand update trigger from Diageo Direct
        List<Brand__c> brands = [SELECT Id FROM Brand__c WHERE Name LIKE 'Portfolio'];
        if (brands.size()==0) {
            Brand__c portfolio = new Brand__c();
            portfolio.Name='Portfolio';
            insert portfolio;
        }
    }
    
    public static Item__c createItem(Program__c pg){

        Account agency = new Account(Name='POS TEST AGENCY', RecordTypeId = productionAgency.Id);
        insert agency;      
        
        Item__c o = populateItem(pg, agency);
        insert o;
        return o; 
    }
    
    public static Account createProductionAgency () {
        Account agency = new Account(Name='POS TEST AGENCY', RecordTypeId = productionAgency.Id);
        insert agency;      
        return agency;
    }
    
    public static Account createDistributorAccount () {
        Account dist = new Account(Name='POS Distributor', RecordTypeId = distributorAccount.Id);
        insert dist;        
        return dist;
    }
    
    public static Item__c createKit(Program__c pg){

        Id kitRecTypeId = [select id from RecordType where DeveloperName = 'Kit'].id;
        Account agency = new Account(Name='POS TEST AGENCY', RecordTypeId = productionAgency.Id);
        insert agency;      
        
        return createKit(pg,agency);
    }    
    
    public static Item__c createKit(Program__c pg, Account agency){

        Id kitRecTypeId = [select id from RecordType where DeveloperName = 'Kit'].id;
        
        Item__c o = populateItem(pg, agency);
        o.recordTypeId=kitRecTypeId;
        
        insert o;
        return o; 
    }    
      
    
    public static Item__c populateItem(Program__c pg, Account ag){
        // create ItemCategory records which is required while creating Item
        Item_Category__c ic = createItemCategory();
        
        Item__c o = new Item__c(name='itemName',Description__c='Uit Test Item Description', Current_Price__c=19.99, Estimated_Price__c=17.99, 
                    Estimated_Shipping_Tax__c=7.65, Category__c='Regular', Minimum_Quantity__c=10, Packout_Quantity__c=10, 
                    Program__c=pg.id, Item_Category__c=ic.id, agency__c=ag.id);
        return o;                        
    }
    
   public static Cart_Item__c populateCartItem(Item__c it, Cart__c crt){
        
        Ship_To__c st = createShipTo();
        Cart_Item__c o = new Cart_Item__c(Cart__c=crt.id, Item__c=it.id, Ship_To__c=st.id, Quantity__c=40);
        return o;                        
    } 

    
    public static Cart__c createCart(User shpr, Order_Window__c ow){
        Cart__c crt = new Cart__c(Shopper__c = shpr.id,
                                  Order_Window__c = ow.id);
        insert crt;
        return crt;                        
    } 
    
    public static Ship_To__c createShipTo(Account act){
        Ship_To__c sh = new Ship_To__c(Account__c = act.id,
                                  Name = 'Test ShipTo');
        insert sh;
        return sh;                        
    }                       
    
    public static Account createAccount(){
        Account act = new Account(Name = 'Test Account',
                                  Type = 'Customer');
        insert act;
        return act;                        
    }
    
    public static Ship_To__c createShipTo(){
        Account act = createAccount();
        Ship_To__c shipTo = new Ship_To__c();
        shipTo.Account__c = act.Id;
        shipTo.Name='Test Ship To';
        
        insert shipTo;        
        return shipTo;                        
    }    
    
   /* public static Account createCustomerPortalAccountRole(){
        UserRole r = new UserRole(Name = 'Test Account',
                                  Type = 'Customer', IsCustomerPortal = true);
        insert act;
        return act;                        
    } */   

    public static Contact createContact(Account acct){
        Contact c = new Contact(Account = acct, FirstName = 'cfName', LastName ='clName', Email='fclName@test.pos.com');
        insert c;
        return c;                        
    }    
    
    
    public static Brand__c createBrand(){
        
        Brand__c brd = new Brand__c(Name = 'Test Brand', Classification__c='Spirits', Diageo_Direct_Visible__c=true, Brand_Type__c='Individual');
        insert brd;
        return brd;                        
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
         
    
    public static Program__c createProgram(){
        Order_Window__c ow = createOrderWindow();
        Brand__c  bd = createBrand();
        
        Program__c o = new Program__c(Name = 'Test Program1', Order_Window__c=ow.id, Brand__c=bd.id);
        insert o;
        return o;                        
    } 
    
    public static Program__c createProgram(Id owId){
        Brand__c  bd = createBrand();
        Program__c o = new Program__c(Name = 'Test Program2', Order_Window__c=owId, Brand__c=bd.id);
        insert o;
        return o;                        
    }    
    
    public static Program__c createProgram(Id brandId, Id owId){
        
        Program__c o = new Program__c(Name = 'Test Program2', Order_Window__c=owId, Brand__c=brandId);
        insert o;
        return o;                        
    }          
        
    public static Account_Member__c createAccountMember(Account a, User u){
        Account_Member__c am = new Account_Member__c(Account__c=a.id, User__c=u.id);
        insert am;
        return am;                        
    }    
    
    public static AccountBrand__c createAccountBrand(Account a, Brand__c b){
        AccountBrand__c ab = new AccountBrand__c(Account__c=a.id, Brand__c=b.id);
        insert ab;
        return ab;                        
    }
    
    public static Organizational_Unit__c createOrgUnit(){
        Organizational_Unit__c orgunit = new Organizational_Unit__c();
        orgunit.Name='Charmer';
        orgunit.Type__c='Spirit';
        orgunit.Responsible_Code__c='BN';
        orgunit.District_Code__c='4450';
        orgunit.Label__c='Division';
        insert orgunit;
        return orgunit; 
    }
    
    public static Item_Category__c createItemCategory(){
        Item_Category__c o = new Item_Category__c(Name='Test Item Category', Customer_Marketing_Category__c='Bar', Material_Code__c='55B.91', 
                                Primary_Group__c='Display', Primary_Type__c='PRINT');
        insert o;
        return o;                        
    }    
    
    public static User createStdUser() {
        Profile p = [select id from profile where name='Standard User' limit 1]; 
        User testUser = new User(alias = 'standt', email='standarduser@modelmetrics.pos.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, firstname='phil',
            timezonesidkey='America/Los_Angeles', username='standarduser@modelmetrics.pos.com');
        insert testUser; 
        return testUser;     
     } 
     
    public static User createCMAdminUser() {
        Profile p = [select id from profile where name='POS - CM Administrator' limit 1]; 
        User testUser = new User(alias = 'cmadmin', email='cmadminuser@modelmetrics.pos.com', 
            emailencodingkey='UTF-8', lastname='Admin', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, firstname='CM',
            timezonesidkey='America/Los_Angeles', username='cmadminuser@modelmetrics.pos.com');
        insert testUser; 
        return testUser;     
     }  
     
    public static User createDiageoEmployeeUser() {
        Profile p = [select id from profile where name='Diageo Employee' limit 1]; 
        User testUser = new User(alias = 'demp', email='demp@modelmetrics.pos.com', 
            emailencodingkey='UTF-8', lastname='Employee', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, firstname='D',
            timezonesidkey='America/Los_Angeles', username='demp@modelmetrics.pos.com');
        insert testUser; 
        return testUser;     
     }         
     
    public static User createPortalUser(Contact c) {
        Profile p = [select id from profile where name='Distributor Portal User' limit 1];
        //UserRole r = [select id from UserRole where name='Manager' and PortalAccountId=:a.id limit 1]; 
        User testUser = new User(alias = 'standt', email='portaluser@modelmetrics.pos.com', 
            emailencodingkey='UTF-8', lastname='PTesting', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, firstname='Dist', contactId=c.id,
            PortalRole = 'Manager',
            timezonesidkey='America/Los_Angeles', username='portaluser@modelmetrics.pos.com');
            
        System.debug('c.account.owner.UserRoleId -' + c.account.owner.UserRoleId);    
        insert testUser; 
        return testUser;     
     }        
 
}