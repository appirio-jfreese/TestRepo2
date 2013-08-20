public without sharing class POS_ReportBudgetInfo extends POS_ReportRenderer{

    protected override String getOrderWindowWhereName() {return 'Order_Window__c';}
    protected override String getClassificationWhereName() {return 'Brand__r.Classification__c';}
    protected override String getBrandsWhereName() {return 'Brand__c';}
    protected override String getOrgUnits1WhereName()      {return (classification == 'Spirits') ? 'Account__r.Spirits_Hierarchy__c' : 'Account__r.Wine_Hierarchy__c';}
    protected override String getOrgUnits2WhereName()      {return (classification == 'Spirits') ? 'Account__r.Spirits_Hierarchy__r.Parent__c' : 'Account__r.Wine_Hierarchy__r.Parent__c';}
    protected override String getOrgUnits3WhereName()      {return (classification == 'Spirits') ? 'Account__r.Spirits_Hierarchy__r.Parent__r.Parent__c' : 'Account__r.Wine_Hierarchy__r.Parent__r.Parent__c';}
    protected override String getOrgUnits4WhereName()      {return (classification == 'Spirits') ? 'Account__r.Spirits_Hierarchy__r.Parent__r.Parent__r.Parent__c' : 'Account__r.Wine_Hierarchy__r.Parent__r.Parent__r.Parent__c';}
    protected override String getDistributorsWhereName() {return 'Account__c';}
    protected override String getShoppersWhereName() {return 'Shopper__c';}
    
    protected override String getBaseTableName() {return 'Budget__c';}
        
    public List<Budget__c> budgets {get;set;}
    
    protected override String getQuerySelect() {
        return 'Select b.My_Spent_Amount__c, b.Shopper__c, b.Budgeter__c, '+
      'b.Budget_Creator__c, b.Brand__c, b.Brand__r.Brand_Type__c, b.Amount__c, Shopper__r.Name, Brand__r.Name, Order_Window__r.Name, '+
      'Account__r.Name From ' + getBaseTableName() + ' b ';
    }
    
/** 
    protected override String getQueryWhereAdd(){
        System.debug('INITIALIZED BUDGET REPORT WHERE');
        Set<Id> accountIds = Service_API.getAIDsForUser(UserInfo.getUserId());
        List<Account_Member__c> shoppers=[select Id,User__c from Account_Member__c where Account__c in :accountIds];
        
        String whereClause = 'Shopper__c in (Select User__c from Account_Member__c where Account__c in (';
        Integer x=0;
        for (Id accountId:accountIds) {
            whereClause=whereClause+'\''+accountId+'\'';
            x++;
            if (x<accountIds.size()) {
                whereClause=whereClause+','; 
            }
            
        }
        whereClause=whereClause+'))';
        
        
        System.debug('WHERE CLAUSE: '+whereClause);
        
        return whereClause;
    }
**/

    private String whereCache;

    // #soe - US805
    // get all users who are members of my accounts' sub accounts    
    protected override String getQueryWhereAdd(){
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
 
            //Commented out per Diageo case 4114
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
            
            whereCache = 'Shopper__c in ('+stringSetToString(items)+')';
            System.debug(whereCache);
        }

        return whereCache;        
    }   
    
    protected override String getQueryOrder(){
        return 'order by Order_Window__r.Order_Start_Date__c DESC, Account__r.Name ASC, Shopper__r.Name ASC, Brand__r.Name ASC';
    }
    
    public POS_ReportBudgetInfo(){
        System.debug('INITIALIZED BUDGET REPORT');
    }
    
    protected override void initData() { 

        try{
            System.debug('Budget Info Query: '+query);
            budgets = Database.query(query);
            List<Budget__c> summaryBudgets = new List<Budget__c>();
            
            Map<Id,Account> shopperToAccountMap = new Map<Id,Account>();
            
            Set<Id> shopperIds = new Set<Id>();
            for (Budget__C budget:budgets) {
                shopperIds.add(budget.Shopper__c);
            }
            
            List<Account_Member__c> shopperAccounts = [select Account__r.Name, User__c from Account_Member__c where User__c in :shopperIds];
            for (Account_Member__c shopperAccount:shopperAccounts) {
                shopperToAccountMap.put(shopperAccount.User__c,shopperAccount.Account__r);
            }
            
            //iterate through budgets and add them up to provide totals where a user has had more than one
            //budget allocated to a combination of window/brand/distributor
            Budget__c currentBudget = null;
            for (Budget__c budget:budgets) {
                
                //Change the specified account in the budget to the user's primary account for display purposes
                budget.Account__r = shopperToAccountMap.get(budget.Shopper__c);
                
                // escapCsv #soe
                if(isCsv) {
                    if(budget.Order_Window__r.Name != null) budget.Order_Window__r.Name = budget.Order_Window__r.Name.escapeCsv();
                    if(budget.Account__r.Name != null) budget.Account__r.Name = budget.Account__r.Name.escapeCsv();
                    if(budget.Brand__r.Name != null) budget.Brand__r.Name = budget.Brand__r.Name.escapeCsv();
                    if(budget.Brand__r.Brand_Type__c != null) budget.Brand__r.Brand_Type__c = budget.Brand__r.Brand_Type__c.escapeCsv();
                }
                
                if (budget.My_Spent_Amount__c==null) {
                    budget.My_Spent_Amount__c=0;
                }
                if (currentBudget==null || 
                  currentBudget.Order_Window__c!=budget.Order_Window__c ||
                  currentBudget.Account__c!=budget.Account__c ||
                  currentBudget.Brand__c!=budget.Brand__c || 
                  currentBudget.Shopper__c!=budget.Shopper__c) {
                    currentBudget = budget;
                    summaryBudgets.add(currentBudget);
                }
                else {
                    currentBudget.My_Spent_Amount__c=currentBudget.My_Spent_Amount__c+budget.My_Spent_Amount__c;
                    currentBudget.Amount__c = currentBudget.Amount__c+budget.Amount__c;
                }
            }
            
            budgets=summaryBudgets;
        } 
        catch(Exception ex) {
            Apexpages.addmessage(new apexpages.message(apexpages.severity.ERROR, 'Could not load data.' + ex.getMessage()));
        }
    }
    
    protected override void calculate() {
    }
}