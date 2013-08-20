public without sharing class POS_ReportPurchasedItems extends POS_ReportRenderer {

    protected override String getOrderWindowWhereName()    {return 'Item__r.Order_Window_ID__c';}
    protected override String getClassificationWhereName() {return 'Item__r.Brand_Classification__c';}
    protected override String getBrandsWhereName()         {return 'Item__r.Program__r.Brand__c';}
    protected override String getOrgUnits1WhereName()      {return (classification == 'Spirits') ? 'Ship_To__r.Account__r.Spirits_Hierarchy__c' : 'Ship_To__r.Account__r.Wine_Hierarchy__c';}
    protected override String getOrgUnits2WhereName()      {return (classification == 'Spirits') ? 'Ship_To__r.Account__r.Spirits_Hierarchy__r.Parent__c' : 'Ship_To__r.Account__r.Wine_Hierarchy__r.Parent__c';}
    protected override String getOrgUnits3WhereName()      {return (classification == 'Spirits') ? 'Ship_To__r.Account__r.Spirits_Hierarchy__r.Parent__r.Parent__c' : 'Ship_To__r.Account__r.Wine_Hierarchy__r.Parent__r.Parent__c';}
    protected override String getOrgUnits4WhereName()      {return (classification == 'Spirits') ? 'Ship_To__r.Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__c' : 'Ship_To__r.Account__r.Wine_Hierarchy__r.Parent__r.Parent__r.Parent__c';}
    protected override String getDistributorsWhereName()   {return 'Ship_To__r.Account__c';}
    protected override String getShoppersWhereName()       {return 'Cart__r.Shopper__c';}

    protected override String getBaseTableName() {return 'Cart_Item__c';}
    
    //sfdc bug prevents this from being deleted
    public class ItemWrapper {public ItemWrapper() {}}
            
    public String             header      {get; private set;}
    public List<List<String>> outputLines {get; private set;}
    
    protected override String getQuerySelect() {
        return 
            'SELECT '
                +'ID, '
                +'Item__r.Order_Window_Name__c, '
                +'Cart__r.Shopper__r.Name, '
                +'Status__c, '
                +'Item__r.Program__r.Brand__r.Name, '
                +'Item__r.Program__r.Name, '
                +'Item__r.Name, '
                +'Item__r.RecordType_Name__c, '
                +'Item__r.Category__c, '
                +'Item__r.Customer_Marketing_Category__c, '
                +'Item__r.Channel__c, '
                +'Item__r.Sales_Channel_Group__c, '
                +'Item__r.Status__c, '
                +'Item__r.Packout_Quantity__c, '
                +'Item__r.Current_Price__c, '
                +'Quantity__c, '
                +'Carrier__c, '
                +'Tracking_Code__c, '
                +'Account_Name__c, '
                +'Division__c, '
                +'Region__c, '
                +'State_District__c, '
                +'Market__c, '
                +'Ship_To__r.Name, '
                +'Ship_To__r.Street__c, '
                +'Ship_To__r.Street_2__c, '
                +'Ship_To__r.City__c, '
                +'Ship_To__r.State__c, '
                +'Ship_To__r.Zip__c, '
                +'Contact_Name__c, '
                +'Contact_Phone__c, '
                +'Contact_Email__c, '
                +'Item__r.Estimated_Shipping_Tax__c '
            +'FROM '
                +getBaseTableName()+' ';
        }
    
    protected override String getQueryOrder(){
        return 'order by Item__r.Order_Window_ID__c, Ship_To__r.Account__c, Item__r.Program__r.Brand__c, Item__r.Program__c, Item__c';
    }
    
    private String whereCache;

    // #soe - US805
    // get all users who are members of my accounts' sub accounts
    protected override String getQueryWhereAdd() {
        if(shoppers != null) { // shoppers defined by user
            return '';
        }
        
        if(whereCache == null){
            // get Cart for all users who i have visibility to
            // first get accounts the current user is a member of
            List<Account_Member__c> user_accounts = [select Account__c, Id from Account_Member__c where User__c = :UserInfo.getUserId()]; 
            
            // then use those accounts as parent accounts 
            Set<id> parent_account_ids = new Set<Id>();
            for(Account_Member__c user_account : user_accounts) {
                parent_account_ids.add(user_account.Account__c);
            }
            
            // copy - so that we can remove the ids from account_ids later
            Set<id> parent_account_ids_copy = new Set<Id>(parent_account_ids);

            // now use a method in Service_API to get all child accounts of the parent accounts
            Set<Id> account_ids = new Set<Id>();
            Service_API.getAllChildAccountsNoRewrite(account_ids, parent_account_ids);
            
            // Commented out per Diageo case 4114
            // remove the account_ids the user is member of
            // so that other members are not included
            /*for(Id parent_account_id : parent_account_ids_copy) {
                account_ids.remove(parent_account_id);
            } */
  
            // then get account_members (users) of all child accounts
            List<Account_Member__c> visible_users = [select Id, User__c from Account_Member__c where Account__c in :account_ids];
            
            Set<Id> items = new Set<Id>();
            
            // first of all, add the user him/herself
            items.add(UserInfo.getUserId()); 
            
            for(Account_Member__c u : visible_users) {
                items.add(u.User__c);
            } 
            
            whereCache = 'Cart__r.Shopper__c in ('+stringSetToString(items)+')';
            //System.debug(whereCache);
        }

        return whereCache;
    }
       
    public POS_ReportPurchasedItems(){}
    
    protected override void initData() {
        try {
            header = 'Order Window,Shopper,Status,Item: Brand,Item: Program,Item: Item Name,Item: Record Type,Item: Category,Item: Customer Marketing Category,Item: Channel,Item: Sales Channel Group,Item: Status,Item: Packout Quantity,Item: Current Price,Quantity,Carrier,Tracking Code,Account Name,Division,Region,State District,Market,Ship To Name,Street,Street 2,City,State,Zip,Contact Name,Contact Phone,Contact Email,Total Spend';

            List<AggregateResult> c = Database.query('select count(ID) from cart_item__c ' + queryWhere);
            Integer queryCount = (Integer)c[0].get('expr0');
            
            //too many records in one report will exceed the heap space limit
            if(isCsv && queryCount > 15000) {
                header = '"Your report exceeds 15,000 rows.  Please narrow your search criteria and try again."';
                Apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR, header));
                return;
            }
            if(!isCsv && queryCount > 10000) {
                String err = 'Your report exceeds 10,000 rows.  Please narrow your search criteria and try again.';
                Apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR, err));
                header = '';
                return;
            }
                                                            
            outputLines =  new List<List<String>>();
            
            Integer counter = 0;
            List<String> temp = new List<String>();
            //SOQL for loop, to preserve heap space
            for(Cart_Item__c item: Database.query(query)) {
                if(isCsv) {
                    temp.add(
                         (item.Item__r.Order_Window_Name__c==null?'':item.Item__r.Order_Window_Name__c.escapeCsv())+','
                        +(item.Cart__r.Shopper__r.Name==null?'':item.Cart__r.Shopper__r.Name.escapeCsv())+','
                        +(item.Status__c==null?'':item.Status__c.escapeCsv())+','
                        +(item.Item__r.Program__r.Brand__r.Name==null?'':item.Item__r.Program__r.Brand__r.Name.escapeCsv())+','
                        +(item.Item__r.Program__r.Name==null?'':item.Item__r.Program__r.Name.escapeCsv())+','
                        +(item.Item__r.Name==null?'':item.Item__r.Name.escapeCsv())+','
                        +(item.Item__r.RecordType_Name__c==null?'':item.Item__r.RecordType_Name__c.escapeCsv())+','
                        +(item.Item__r.Category__c==null?'':item.Item__r.Category__c.escapeCsv())+','
                        +(item.Item__r.Customer_Marketing_Category__c==null?'':item.Item__r.Customer_Marketing_Category__c.escapeCsv())+','
                        +(item.Item__r.Channel__c==null?'':item.Item__r.Channel__c.escapeCsv())+','
                        +(item.Item__r.Sales_Channel_Group__c==null?'':item.Item__r.Sales_Channel_Group__c.escapeCsv())+','
                        +(item.Item__r.Status__c==null?'':item.Item__r.Status__c.escapeCsv())+','
                        +item.Item__r.Packout_Quantity__c+','
                        +item.Item__r.Current_Price__c+','
                        +item.Quantity__c+','
                        +(item.Carrier__c==null?'':item.Carrier__c.escapeCsv())+','
                        +(item.Tracking_Code__c==null?'':item.Tracking_Code__c.escapeCsv())+','
                        +(item.Account_Name__c==null?'':item.Account_Name__c.escapeCsv())+','
                        +(item.Division__c==null?'':item.Division__c.escapeCsv())+','
                        +(item.Region__c==null?'':item.Region__c.escapeCsv())+','
                        +(item.State_District__c==null?'':item.State_District__c.escapeCsv())+','
                        +(item.Market__c==null?'':item.Market__c.escapeCsv())+','
                        +(item.Ship_To__r.Name==null?'':item.Ship_To__r.Name.escapeCsv())+','
                        +(item.Ship_To__r.Street__c==null?'':item.Ship_To__r.Street__c.escapeCsv())+','
                        +(item.Ship_To__r.Street_2__c==null?'':item.Ship_To__r.Street_2__c.escapeCsv())+','
                        +(item.Ship_To__r.City__c==null?'':item.Ship_To__r.City__c.escapeCsv())+','
                        +(item.Ship_To__r.State__c==null?'':item.Ship_To__r.State__c.escapeCsv())+','
                        +(item.Ship_To__r.Zip__c==null?'':item.Ship_To__r.Zip__c.escapeCsv())+','
                        +(item.Contact_Name__c==null?'':item.Contact_Name__c.escapeCsv())+','
                        +(item.Contact_Phone__c==null?'':item.Contact_Phone__c.escapeCsv())+','
                        +(item.Contact_Email__c==null?'':item.Contact_Email__c.escapeCsv())+','
                        +(item.Item__r.Current_Price__c*(1+(item.Item__r.Estimated_Shipping_Tax__c/100)))*item.Quantity__c
                    );
                }
                else {
                    temp.add(
                         '<td>'+(item.Item__r.Order_Window_Name__c==null?'':item.Item__r.Order_Window_Name__c)+'</td>'
                        +'<td>'+(item.Cart__r.Shopper__r.Name==null?'':item.Cart__r.Shopper__r.Name)+'</td>'
                        +'<td>'+(item.Status__c==null?'':item.Status__c)+'</td>'
                        +'<td>'+(item.Item__r.Program__r.Brand__r.Name==null?'':item.Item__r.Program__r.Brand__r.Name)+'</td>'
                        +'<td>'+(item.Item__r.Program__r.Name==null?'':item.Item__r.Program__r.Name)+'</td>'
                        +'<td>'+(item.Item__r.Name==null?'':item.Item__r.Name)+'</td>'
                        +'<td>'+(item.Item__r.RecordType_Name__c==null?'':item.Item__r.RecordType_Name__c)+'</td>'
                        +'<td>'+(item.Item__r.Category__c==null?'':item.Item__r.Category__c)+'</td>'
                        +'<td>'+(item.Item__r.Customer_Marketing_Category__c==null?'':item.Item__r.Customer_Marketing_Category__c)+'</td>'
                        +'<td>'+(item.Item__r.Channel__c==null?'':item.Item__r.Channel__c)+'</td>'
                        +'<td>'+(item.Item__r.Sales_Channel_Group__c==null?'':item.Item__r.Sales_Channel_Group__c)+'</td>'
                        +'<td>'+(item.Item__r.Status__c==null?'':item.Item__r.Status__c)+'</td>'
                        +'<td>'+item.Item__r.Packout_Quantity__c+'</td>'
                        +'<td>'+item.Item__r.Current_Price__c+'</td>'
                        +'<td>'+item.Quantity__c+'</td>'
                        +'<td>'+(item.Carrier__c==null?'':item.Carrier__c)+'</td>'
                        +'<td>'+(item.Tracking_Code__c==null?'':item.Tracking_Code__c)+'</td>'
                        +'<td>'+(item.Account_Name__c==null?'':item.Account_Name__c)+'</td>'
                        +'<td>'+(item.Division__c==null?'':item.Division__c)+'</td>'
                        +'<td>'+(item.Region__c==null?'':item.Region__c)+'</td>'
                        +'<td>'+(item.State_District__c==null?'':item.State_District__c)+'</td>'
                        +'<td>'+(item.Market__c==null?'':item.Market__c)+'</td>'
                        +'<td>'+(item.Ship_To__r.Name==null?'':item.Ship_To__r.Name)+'</td>'
                        +'<td>'+(item.Ship_To__r.Street__c==null?'':item.Ship_To__r.Street__c)+'</td>'
                        +'<td>'+(item.Ship_To__r.Street_2__c==null?'':item.Ship_To__r.Street_2__c)+'</td>'
                        +'<td>'+(item.Ship_To__r.City__c==null?'':item.Ship_To__r.City__c)+'</td>'
                        +'<td>'+(item.Ship_To__r.State__c==null?'':item.Ship_To__r.State__c)+'</td>'
                        +'<td>'+(item.Ship_To__r.Zip__c==null?'':item.Ship_To__r.Zip__c)+'</td>'
                        +'<td>'+(item.Contact_Name__c==null?'':item.Contact_Name__c)+'</td>'
                        +'<td>'+(item.Contact_Phone__c==null?'':item.Contact_Phone__c)+'</td>'
                        +'<td>'+(item.Contact_Email__c==null?'':item.Contact_Email__c)+'</td>'
                        +'<td>'+((item.Item__r.Current_Price__c*(1+(item.Item__r.Estimated_Shipping_Tax__c/100)))*item.Quantity__c)+'</td>'
                    );
                }
                //every thousand rows create a new List
                counter++;
                if(math.mod(counter,1000)==0) {
                    outputLines.add(temp);
                    temp = new List<String>();
                }
            }
            //add the leftover rows
            outputLines.add(temp);

        } catch(Exception ex) {
            header = 'Could not load data.';
            Apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR, header));
        }
    }
}