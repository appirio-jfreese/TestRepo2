global without sharing class POS_ReportsController extends Controller_Base {

    public List<POS_BreadCrumb> breadcrumbs {get;set;} 

    /********************FILTERS*************************/
    public String []            orderWindows        { get; set; }
    public string               classification      { get; set; }
    public List<String>         brands              { get; set; }
    public List<String>         organizationalUnits { get; set; }
    public String               orgUnitsString      { get; set{organizationalUnits=stringToList(value);} }
    public List<String>         distributors        { get; set; }
    public List<String>         shoppers            { get; set; }
    public String               programs            { get; set; }
    
    public String owP { get; set; }
    public String clP { get; set; }
    public String brP { get; set; }
    public String ouP { get; set; }
    public String dsP { get; set; }
    public String ssP { get; set; }
    
    public String objId { get; set; }
    
    public void saveToTmpObject(){
        List<ReportTmpObj__c> tmps = [select Id, ow__c, cl__c, br__c, ou__c, ds__c, ss__c from ReportTmpObj__c where id = :objId limit 1];
        ReportTmpObj__c tmp = (tmps.isEmpty()) ? new ReportTmpObj__c() : tmps.get(0);
        tmp.ow__c = owP;
        tmp.cl__c = clP;
        tmp.br__c = brP;
        tmp.ou__c = ouP;
        tmp.ds__c = dsP;
        tmp.ss__c = ssP;
        upsert tmp;
        objId = tmp.id;
    }
    
    public void resetClassification(){
        classification = null;
    }
    
    public void resetOrganizationalUnits(){
        organizationalUnits = new List<String>();
    }
        
    public List<SelectOption> orderWindowOptions            { get; private set; }
    public List<SelectOption> classificationOptions         { get; private set; }
    public List<SelectOption> brandOptions                  { get; private set; }
    public List<SelectOption> organizationalUnitOptions     { get; private set; }
    public List<SelectOption> distributorOptions            { get; private set; }
    
    // via js remote
    // public static List<SelectOption> shopperOptions       { get; private set; }
    
    private List<String> stringToList(String s){
        List<String> toReturn = new List<String>();
        if(s!=null){
            for(String str : s.split(',')){
                toReturn.add(str);
            }
        }
        return toReturn;
    }
    
    public List<Organizational_Unit__c> orgUnits {get;set;}
    
    public void initFilters(){
        orderWindows = new string[]{};
        fillOrderWindowOptions();
        fillClassificationOptions();
        brandOptions = new List<SelectOption>();
        organizationalUnitOptions = new List<SelectOption>();
        distributorOptions = new List<SelectOption>();
    }
        
    private void fillOrderWindowOptions(){
        //(Reena Acharya)Changed Order by in query Instead of order by Name we are doing sorting on the basis of created Date for case # 00045914
        List<Order_Window_Customer__c> windowsCustomers = [select Order_Window__c, Order_Window__r.Name from Order_Window_Customer__c where Customer__c = :Service_API.getUId() order by Order_Window__r.CreatedDate desc];//order by Order_Window__r.Name];
        orderWindowOptions = new List<SelectOption>();
        for(Order_Window_Customer__c windowCustomer : windowsCustomers){
            orderWindowOptions.add(new SelectOption(windowCustomer.Order_Window__c, windowCustomer.Order_Window__r.Name));
        }
    }
        
    private void fillClassificationOptions(){
        classificationOptions = new List<SelectOption>();
        classificationOptions.add(new SelectOption('All','All'));
        classificationOptions.addAll(getSiteThemes());
    }
        
    public static Set<Id> getAccBrandIds(){

       System.debug('=========aids1= ' + aids); //Testing Reports - Diana 2/5
        if(aids == null) {
            getUserAccountInfo();
        }
        
        
        List<Brand__c> brands = [
            SELECT Id from Brand__c
                where ID in (select Brand__c from AccountBrand__c                    
                WHERE Account__c in :aids)
               // WHERE Account__c in :aids && Brand__c.Brand_Type__c == 'Individual' )
        ];
        
        Set<Id> brandIds = new Set<Id>();
        for (Brand__c brand:brands) {
            brandIds.add(brand.Id);
        }
        
        return brandIds; 
        
        /*
        //This is the original code here but it was hitting a query limit because it 
        //retrieves too many rows.  Leaving here for now in case there's some side effect
        //of the above fix.  SS 11/28/12 
        if(aids == null)
            getUserAccountInfo();
        List<AggregateResult> userAccountBrands = [
            SELECT Brand__c
                FROM AccountBrand__c                    
                WHERE Account__c in :aids
                GROUP BY Brand__c
        ];
        set<id> brandIDs = new Set<Id>();
        for (AggregateResult ar: userAccountBrands) {
            brandIDs.add((Id)ar.get('Brand__c'));
        }
        return brandIds; */
        
        
    }

    public void fillBrandOptions(){
        Set<Id> brandsIds = getAccBrandIds();
     // List<Brand__c> brands = [select Id, Name from Brand__c where id in :brandsIds and Classification__c = :classification and order by Name]; Commented out per case 5259
        List<Brand__c> brands = [select Id, Name from Brand__c where id in :brandsIds and Classification__c = :classification and (Brand_Type__c = 'Individual' OR Brand_Type__c = '')  order by Name]; //Line modified per case 5259
        brandOptions = new List<SelectOption>();
        for(Brand__c brand : brands){
            brandOptions.add(new SelectOption(brand.id, brand.Name));
        }
    }
    
    public void resetBrandsOptions(){
        brandOptions = new List<SelectOption>();
    }
        
    public void reset(){
        orderWindows = null;
        classification = null;
        brands = null;
        organizationalUnits = null;
        distributors = null;
    }
        
    //POS service-api change
    public static set<Id> aids;
    public static set<Id> sub_aids;
    private static String userAID;
    public static Set<Id> visible_user_ids;
/*
    // #soe - revised the code 10/01/2013
    private static void getUserAccountInfo(){
        /*
        
        User currUser = [SELECT Id, AccountID, ContactID, Contact.Account.Division__c, Contact.Account.Name FROM User WHERE Id = :UserInfo.getUserID()];
        List<Account_Member__c> members = [select Account__c, Account__r.Name, Account__r.Division__c, Default__c from Account_Member__c where User__c = :currUser.Id]; 
        for(Account_Member__c m : members){
            if(m.Default__c){
                userAID = m.Account__c;
                break;
            }
        }
        aids            = new set<Id>();
        set<Id> tmpaids = new set<Id>();
        if (userAID != null) {
            tmpaids.add(userAID);
        }
        for(Account_Member__c member : members){
            tmpaids.add(member.Account__c);
        }
        //get child accounts from account hierarchy
        getAllChildAccounts(tmpaids);
    }
*/

    private static void getUserAccountInfo(){ 
        // get Cart for all users who i have visibility to
        // first get accounts the current user is a member of
        List<Account_Member__c> user_accounts = [select Account__c, Default__c, Id from Account_Member__c where User__c = :UserInfo.getUserId()]; 
        
        // userAID - get the default account of the user
        for(Account_Member__c a : user_accounts){
            if(a.Default__c){
                userAID = a.Account__c;
                break;
            }
        }
                
        // then use those accounts as parent accounts 
        Set<id> parent_account_ids = new Set<Id>();
        for(Account_Member__c user_account : user_accounts) {
            parent_account_ids.add(user_account.Account__c);
        }
        
        // copy - so that we can remove the accounts of users just to get the sub-accounts
        Set<id> parent_account_ids_copy = new Set<Id>(parent_account_ids);

        // now use a method in Service_API to get all child accounts of the parent accounts
        aids = new Set<Id>();
        System.debug('=========parent_account_ids1= ' + parent_account_ids); //Testing Reports - Diana 2/5
        System.debug('=========aids2= ' + aids); //Testing Reports - Diana 2/5
        Service_API.getAllChildAccountsNoRewrite(aids, parent_account_ids);
        
        System.debug('=========aids3= ' + aids); //Testing Reports - Diana 2/5   
        System.debug('=========parent_account_ids2= ' + parent_account_ids); //Testing Reports - Diana 2/5     
        // aids - contain all accounts + sub-accounts of the user 
        
        sub_aids = new Set<Id>(aids);
        
        // remove the accounts the user is member of
        // to get sub-accounts
        /*for(Id parent_account_id : parent_account_ids_copy) {
            sub_aids.remove(parent_account_id);
        }*/
        
        visible_user_ids = new Set<Id>();        
        // first of all, add the user him/herself
        visible_user_ids.add(UserInfo.getUserId()); 
        
        // then add all users who are members of the sub-accounts (aids)
        for(Account_Member__c u : [select Id, User__c from Account_Member__c where Account__c in :sub_aids]) {
            visible_user_ids.add(u.User__c);
        }                     
    }
    /*
    // #soe - commented out, new getUserAccountInfo uses the Service_API directly
    private static void getAllChildAccounts(set<Id> parentIds){
        if (parentIds.size()==0) {
            return;
        }
        set<Id> oldParentIds;

        Account[] ts = [
        SELECT Id, 
            parentId,
            parent.parentId,
            parent.parent.parentId,
            parent.parent.parent.parentId
            FROM Account 
                WHERE (
                        id in: parentIds 
                        OR parentId in: parentIds
                        OR parent.parentId in: parentIds
                        OR parent.parent.parentId in: parentIds
                        OR parent.parent.parent.parentId in: parentIds
                       )
        ];

        oldParentIds = new set<id>(parentIds);
        parentIds.clear();
        for (Account t: ts) {
            aids.add(t.Id);
            if (t.parent.parent.parent.parentId != null && oldParentIds.contains(t.parent.parent.parent.parentId) ) {
                parentIds.add(t.id);
            }
        }
        getAllChildAccounts(parentIds);
    }*/
        
    private list<id> searchOrganizationalUnitIds(set<Id> distributorIds) {
        list<id> result = new list<id>();
        String query = 'SELECT '
            +classification+'_Hierarchy__c par1, '
            +classification+'_Hierarchy__r.Parent__c par2, '
            +classification+'_Hierarchy__r.Parent__r.Parent__c par3, '
            +classification+'_Hierarchy__r.Parent__r.Parent__r.Parent__c par4 '
            +'FROM Account WHERE Id in ('+makeQuerySet(distributorIds)+') group by id, '
            +classification+'_Hierarchy__c, '
            +classification+'_Hierarchy__r.Parent__c, '
            +classification+'_Hierarchy__r.Parent__r.Parent__c, '
            +classification+'_Hierarchy__r.Parent__r.Parent__r.Parent__c ';
        
        list<AggregateResult> ac = Database.query(query);
        
        for(AggregateResult a : ac){
            if (a.get('par4') != null) {
                set<id> tmp = new set<id>(result);
                if (!tmp.contains((id)a.get('par4'))) {
                    result = Service_API.searchOrganizationalUnitIdsRecursion((String)a.get('par4'), result);
                }
            }
            if (a.get('par3') != null) {
                result.add((id)a.get('par3'));
            }
            if (a.get('par2') != null) {
                result.add((id)a.get('par2'));
            }
            if (a.get('par1') != null) {
                result.add((id)a.get('par1'));
            }
        }     
        return result;
    }
    
    public void resetOrganizationalUnitOptions(){
        organizationalUnitOptions = new List<SelectOption>();
        resetDistributorOptions();
        resetOrganizationalUnits();
    }
    
    public void resetDistributorOptions(){
        distributorOptions = new List<SelectOption>();
    }
        
    public void fillOrganizationalUnitOptions(){
        distributorOptions = new List<SelectOption>();
        if(aids == null)
            getUserAccountInfo();
        List<id> ouIds = searchOrganizationalUnitIds(aids);
        organizationalUnitOptions = new List<SelectOption>();
        if(orgUnits == null){
            orgUnits = [select Id, Name, Parent__c from Organizational_Unit__c where id in :ouIds and type__c = :classification];
        }
        //construct upper-most ous
        Set<Id> ids = new Set<Id>();
        Set<id> uppermost = new Set<Id>();
        for(Organizational_Unit__c ou : orgUnits){
            ids.add(ou.id);
            uppermost.add(ou.id);
        }
        Map<Id, List<Organizational_Unit__c>> orgUnitHierarchy = new Map<Id, List<Organizational_Unit__c>>();
        for(Organizational_Unit__c ou : orgUnits){
            if(ou.Parent__c != null && ids.contains(ou.Parent__c)){
                uppermost.remove(ou.id);
                List<Organizational_Unit__c> children = orgUnitHierarchy.get(ou.Parent__c);
                children = (children == null) ? (new List<Organizational_Unit__c>()) : (children);
                children.add(ou);
                orgUnitHierarchy.put(ou.Parent__c, children);
            }
        }
        //reccursion towards leaves
        for(Organizational_Unit__c ou : orgUnits){
            system.debug('a');
            if(uppermost.contains(ou.id)){
                system.debug('b');
                organizationalUnitOptions.add(new SelectOption(ou.id, ou.Name));
                organizationalUnitOptions.addAll(findOUsChildren(ou, orgUnitHierarchy, ou.Name));
            }
        }
        
        sortSelectOptions(organizationalUnitOptions);
    }

    private List<SelectOption> findOUsChildren(Organizational_Unit__c parent, Map<Id, List<Organizational_Unit__c>> orgUnitHierarchy, String currName){
        List<SelectOption> options = new List<SelectOption>();
        if(orgUnitHierarchy.get(parent.id)!=null){
            for(Organizational_Unit__c ou : orgUnitHierarchy.get(parent.id)){
                String name = currName+' - '+ou.Name;
                options.add(new SelectOption(ou.id, name));
                options.addAll(findOUsChildren(ou, orgUnitHierarchy, name));
            }
        }
        return options;
    }

    public void fillDistributorOptions(){
        distributorOptions = new List<SelectOption>();
        List<Account> accounts = getDistributorsForOrgUnit(organizationalUnits);
        for(Account account : accounts){
            distributorOptions.add(new SelectOption(account.id, account.name));
        }
    }
    
    @RemoteAction
    global static List<User> getShopperWindowOptions(String windowId) {
        if(aids == null) getUserAccountInfo();

        Set<ID> ids = new Set<ID>();
        
        for (Cart__c id : [select Shopper__r.Id from Cart__c where Order_Window__c = :windowId])
            ids.add(id.Shopper__r.Id);

        for (Budget__c id : [select Shopper__r.Id from Budget__c where Order_Window__c = :windowId])
            ids.add(id.Shopper__r.Id);

        return [select Id, Name from User where Id in :ids and Id in :visible_user_ids order by Name];
    }

    global List<Account> getDistributorsForOrgUnit(List<String> orgIdsList){
        List<Account> distributors = new List<Account>();
        
        if(orgIdsList.isEmpty())
            return distributors;
        
        try{
            String ids = makeQuerySet(Service_API.getAIDs());
            Set<Id> orgIdsSet1 = new Set<Id>();
            for(String str : orgIdsList){
                orgIdsSet1.add((Id)str);
            }
            Set<Id> orgIdsSet = Service_API.getAllChildOU(orgIdsSet1);
            String orgIds = makeQuerySet(orgIdsSet);
            for(string id:ids.split(',')){ //Start testing POS_Reports - Diana 2/5
                System.debug('==========ids=' + id);
            }
            for(string od:orgIds.split(',')){
                System.debug('==========orgIds=' + od);
            }//End testing POS_Reports - Diana 2/5
            String query = 'select id, Name from Account where Id in ('+ids+') and '+classification+'_Hierarchy__c in ('+orgIds+') order by Name';
            List<Account> accounts = database.query(query);
            for(Account account : accounts){
                distributors.add(account);
            }
        } catch(Exception ex){
            return distributors;
        }
        return distributors;
    }
    
    private static String makeQuerySet(Set<Id> toProcess){
        String toReturn = '';
        String glue = '';
        for(String s : toProcess){
            toReturn += glue + '\''+s+'\'';
            glue = ',';
        }
        return toReturn;
    }
    
    private static String makeQueryList(List<String> toProcess){
        String toReturn = '';
        String glue = '';
        for(String s : toProcess){
            toReturn += glue + '\''+s+'\'';
            glue = ',';
        }
        return toReturn;
    }
    
     private static List<SelectOption> sortSelectOptions(List<SelectOption> sortingList) {
        for (Integer i =0; i < sortingList.size(); i++) {
            for (Integer j = i; j > 0; j--) {
                if (sortingList[j-1].getLabel() > sortingList[j].getLabel()){
                    SelectOption temp = sortingList[j];
                    sortingList[j] = sortingList[j-1];
                    sortingList[j-1] = temp;
                }
            }
        }
        return sortingList;
    }

    /**********************CONSTRUCTOR****************/
    public Map<String, String> reportsMap { get; set; }
    public Set<String> reportsNames {
        get{
            return reportsMap.keySet();
        }
    }
    
    public POS_ReportsController(){
        breadCrumbs = new List<POS_BreadCrumb>();
         breadCrumbs.add(new POS_BreadCrumb('POS','POS_OrderWindowView'));
         breadCrumbs.add(new POS_BreadCrumb('Reports','#'));        
        initFilters();
        
        reportsMap = new Map<String, String>();
        for(POS_GeneratedReports__c report : POS_GeneratedReports__c.getAll().values()){
            reportsMap.put(report.Name, report.CodeName__c);
        }
    }    
}