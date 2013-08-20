/*****************************************************************************************
Name        : Service_API.cls

Created By  : Denise Bacher
Date        : 8/29/2011
Description : Static API class, makes calls to data base to retrieve information

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 6/25/13
Story/Task  : US615/TA1067

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 6/14/13
Story/Task  : US503/TA1011

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 6/13/13
Story/Task  : US85/DE576-DE583 

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 5/27/13
Story/Task  : US79/DE565 

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 6/31/13
Story/Task  : US503/TA906/TA907/TA908
  
Updated By  : Basant Verma (Appirio Offshore)   
Date        : 5/27/13
Story/Task  : US85/TA910

Updated By  : Jonathan Freese (Appirio)   
Date        : 7/7/13
Story/Task  : US614/TA1068
*****************************************************************************************/

public without sharing class Service_API {
    public class Service_APIException  extends Exception{}
    
    private static set<id> accountRecordTypesIds; 
    
    private static String uid;
    private static String cid;
    private static String userAID;
    private static List<String> distributorNames;
    private static DateTime lastLoginDate;
    private static set<Id> aids;
    private static set<String> dnames;

    private static list<Sections__c> sectionTabs;
    private static list<Brand__c> rtsBrands;

    private static String siteTheme;
    private static String siteThemeDefault;
    private static String userNumberOfItemsPerPage;
    private static set<String> brandTypes;
    private static set<String> brandCategories;
    
    private static set<id> OUChildren;
    // Start : Changes for US615/TA1067 - Basant Verma (Appirio OffShore)
    public static boolean isResponsive(){
    		String userAgent =
					ApexPages.currentPage().getHeaders().get('USER-AGENT');
				System.debug('======================== userAgent : '+userAgent);
				if((userAgent != null && !userAgent.trim().equals('') && 
    			(userAgent.containsIgnoreCase('Android') || userAgent.containsIgnoreCase('iOS') || 
    			userAgent.containsIgnoreCase('webOS') || userAgent.containsIgnoreCase('iPhone') || 
    			// Start : Changes for US614/TA1068 - Jonathan Freese - disable iPad at client request
    			// userAgent.containsIgnoreCase('iPad') ||
    			// End   : Changes for US645/TA1068 - Jonathan Freese
    			userAgent.containsIgnoreCase('iPod') || 
    			userAgent.containsIgnoreCase('BlackBerry')))
    			|| (ApexPages.currentPage().getUrl().indexOf('R_MonthlyExecutionPlan') > -1)){
    				return true;
				}else{
					return false;
				}
    }
    // End : Changes for US615/TA1067 - Basant Verma (Appirio OffShore)
    
    /**
    * @author Denise Bacher
    * @date 27/07/2011
    * @description Get the user's id
    * @return String The id as a string for the current user
    */
    public static String getUID(){
        if (uid==null) {
            uid = UserInfo.getUserID();
        }
        return uid;
    }
    
    
    
    /**
    * @author Bartek Dudziak
    * @date 31/07/2012
    * @description Get the account record types
    * @return Set<id> record type ids
    */
    public static set<id> getAccountRecordTypeIds(){
        if(accountRecordTypesIds == null){  
            List<RecordType> accountRecordTypes =[Select r.Name, r.Id From RecordType r WHERE r.SobjectType = 'Account' AND r.Name = 'Distributor'];
            accountRecordTypesIds = new set<id>();
            for(RecordType r : accountRecordTypes ){
                accountRecordTypesIds.add(r.Id);
            }
        } 
        return accountRecordTypesIds;
    }
    
    /**
    * @author Wojciech Migas
    * @date 14/11/2011
    * @description Get the user's last login date
    * @return DateTime User last login date
    */
     public static DateTime getLastLoginDate(){
        if (lastLoginDate==null) {
            lastLoginDate = [SELECT loginDate__c FROM USER WHERE ID =: getUID()][0].loginDate__c;
        }
        return lastLoginDate;
    }
    
    public static void refreshUserPreferances(){
            User usr = [SELECT Use_current_theme_as_default__c, Diageo_Direct_Theme__c,Number_of_items_per_page__c FROM USER WHERE ID =: getUID()][0];
            siteThemeDefault = usr.Use_current_theme_as_default__c;
            siteTheme = usr.Diageo_Direct_Theme__c;
            userNumberOfItemsPerPage = usr.Number_of_items_per_page__c;
            if(userNumberOfItemsPerPage == null || userNumberOfItemsPerPage == ''){
                userNumberOfItemsPerPage = '12';
            }
    }
    
    /**
    * @author Bartek Dudziak
    * @date 22/06/2012
    * @description Get number of content per page
    * @return Integer Number of content per page
    */
     public static Integer getUserNumberOfItemsPerPage(){
            // Start : Changes for TA920 - Basant Verma 
            // Chnaged for US79/DE565 : to Checked ApexPages.currentPage() for NULL
                if(ApexPages.currentPage() != null && ApexPages.currentPage().getParameters().containsKey('toggled')){
                siteThemeDefault = ApexPages.currentPage().getParameters().get('toggledThemeDef');
            siteTheme = ApexPages.currentPage().getParameters().get('toggledTheme');
                userNumberOfItemsPerPage = ApexPages.currentPage().getParameters().get('toggledNum');
            if(userNumberOfItemsPerPage == null || userNumberOfItemsPerPage == ''){
                userNumberOfItemsPerPage = '12';
            }
            }else if (userNumberOfItemsPerPage==null) {
            User usr = [SELECT Use_current_theme_as_default__c, Diageo_Direct_Theme__c,Number_of_items_per_page__c FROM USER WHERE ID =: getUID()][0];
            siteThemeDefault = usr.Use_current_theme_as_default__c;
            siteTheme = usr.Diageo_Direct_Theme__c;
            userNumberOfItemsPerPage = usr.Number_of_items_per_page__c;
            if(userNumberOfItemsPerPage == null || userNumberOfItemsPerPage == ''){
                userNumberOfItemsPerPage = '12';
            }
        }
        // End : Changes for TA920 - Basant Verma 
        return Integer.valueof(userNumberOfItemsPerPage);
    }
    
    /**
    * @author Bartek Dudziak
    * @date 22/06/2012
    * @description Return section theme
    * @return Return section theme
    *@Modified by Luke Slevin
    *data 2/13/2013
    *@If statement added for theme on 
    *planning sections
    */
     public static String getSectionTheme(){
            // Start : Changes for TA920 - Basant Verma 
            // Chnaged for US79/DE565 : to Checked ApexPages.currentPage() for NULL
                if(ApexPages.currentPage() != null && ApexPages.currentPage().getParameters().containsKey('toggled')){
                siteThemeDefault = ApexPages.currentPage().getParameters().get('toggledThemeDef');
            siteTheme = ApexPages.currentPage().getParameters().get('toggledTheme');
                userNumberOfItemsPerPage = ApexPages.currentPage().getParameters().get('toggledNum');
            if(userNumberOfItemsPerPage == null || userNumberOfItemsPerPage == ''){
                userNumberOfItemsPerPage = '12';
            }
            }// End : Changes for TA920 - Basant Verma 
            else if (siteTheme==null) {
            User usr = [SELECT Use_current_theme_as_default__c, Diageo_Direct_Theme__c,Number_of_items_per_page__c FROM USER WHERE ID =: getUID()][0];
             // Modified by Jai Gupta [Appirio Jaipur] on Feb 21,2013 for case 00040450
             system.debug('----------------APexPages.CurrentPage().getUrl();-------------'+ApexPages.CurrentPage());
             String pageName = null ;
             if(APexPages.CurrentPage() != null) {
                 pageName = APexPages.CurrentPage().getUrl();
             }
             // End for case 00040450
           if(pageName != null){  
            if(pageName.contains('WinePlanning') || pageName.contains('wineplanning')){
                siteTheme = 'Wine';
            }
            else if(pagename.contains('SpiritsPlanning') || pageName.contains('spiritsplanning')){
                siteTheme = 'Spirits';
            }
            else{
            siteThemeDefault = usr.Use_current_theme_as_default__c;
            siteTheme = usr.Diageo_Direct_Theme__c;
            }
           }
           else{
             siteThemeDefault = usr.Use_current_theme_as_default__c;
             siteTheme = usr.Diageo_Direct_Theme__c;
           }
            userNumberOfItemsPerPage = usr.Number_of_items_per_page__c;
            if(userNumberOfItemsPerPage == null || userNumberOfItemsPerPage == ''){
                userNumberOfItemsPerPage = '12';
            }
       }
       return siteTheme;
    }    
    
    /**
    * @author Bartek Dudziak
    * @date 22/06/2012
    * @description Return section theme
    * @return Return section theme
    *@Modified by Luke Slevin
    *data 2/13/2013
    *@If statement added for theme on 
    *planning sections
    */
     public static String getSectionThemeDefault(){
            // Start : Changes for TA920 - Basant Verma 
                // Chnaged for US79/DE565 : to Checked ApexPages.currentPage() for NULL
                if(ApexPages.currentPage() != null && ApexPages.currentPage().getParameters().containsKey('toggled')){
                siteThemeDefault = ApexPages.currentPage().getParameters().get('toggledThemeDef');
            siteTheme = ApexPages.currentPage().getParameters().get('toggledTheme');
                userNumberOfItemsPerPage = ApexPages.currentPage().getParameters().get('toggledNum');
            if(userNumberOfItemsPerPage == null || userNumberOfItemsPerPage == ''){
                userNumberOfItemsPerPage = '12';
            }
            }// End : Changes for TA920 - Basant Verma
            else if (siteThemeDefault==null) {
            User usr = [SELECT Use_current_theme_as_default__c, Diageo_Direct_Theme__c,Number_of_items_per_page__c FROM USER WHERE ID =: getUID()][0];
            String pageName = APexPages.CurrentPage().getUrl();
            if(pageName.contains('WinePlanning') || pageName.contains('wineplanning')){
                siteTheme = 'Wine';
            }
            else if(pagename.contains('SpiritsPlanning') || pageName.contains('spiritsplanning')){
                siteTheme = 'Spirits';
            }
            else{
            siteThemeDefault = usr.Use_current_theme_as_default__c;
            siteTheme = usr.Diageo_Direct_Theme__c;
            }
            userNumberOfItemsPerPage = usr.Number_of_items_per_page__c;
            if(userNumberOfItemsPerPage == null || userNumberOfItemsPerPage == ''){
                userNumberOfItemsPerPage = '12';
            }
       }
        return siteThemeDefault;
    }  

    public static set<string> getUserBrandTypes(){
        if(brandTypes == null){
            brandTypes = new set<string>();
        
            String emptyStr = '';
            
            list<AggregateResult> bTypes = [select classification__c from brand__c where classification__c != null and classification__c  != 'NOT DEFINED' and classification__c != :emptyStr and id in (
                SELECT Brand__c
                    FROM AccountBrand__c                    
                    WHERE Account__c in :getAIDs() and Brand__r.diageo_direct_visible__c = true and Account__r.RecordTypeId in :Service_API.getAccountRecordTypeIds())
                    group by classification__c];
            for(AggregateResult bt: bTypes){
                String brandType = String.valueof(bt.get('classification__c'));
                if(brandType != null && brandType != ''){
                    if(!brandTypes.contains(brandType)){
                        brandTypes.add(brandType);
                    }
                }
            }
            
        }
        return brandTypes;
    }
    
    public static set<string> getUserBrandCategories(){
        if(brandCategories == null){
            brandCategories = new set<string>();
        
            String emptyStr = '';
            
            list<AggregateResult> bCategory = [select category__c from brand__c where category__c != null and category__c != :emptyStr and id in (
                SELECT Brand__c
                    FROM AccountBrand__c                    
                    WHERE Account__c in :getAIDs() and Brand__r.diageo_direct_visible__c = true and Account__r.RecordTypeId in :Service_API.getAccountRecordTypeIds())
                    group by category__c];
            for(AggregateResult bc: bCategory){
                String brandCategory = String.valueof(bc.get('category__c'));
                if(brandCategory != null && brandCategory != ''){
                    if(!brandCategories.contains(brandCategory)){
                        brandCategories.add(brandCategory);
                    }
                }
            }
            
        }
        return brandCategories;
    }

    /**
    * @author Bartek Dudziak
    * @date 28/06/2012
    * @description Prepare site theme after login
    * @return 
    */
    public static void prepareSiteThemeAfterLogin(Id userIdlog){
        uid = userIdlog; 
        String currentSectionThemeDefault = Service_API.getSectionThemeDefault();
        String currentSectionTheme = Service_API.getSectionTheme();

        // get brand types      
        brandTypes = Service_API.getUserBrandTypes();

        // prepare site theme       
        if(brandTypes.size() == 1){
            // only one brand type, setup this theme
            for(String stheme : brandTypes){
                Service_API.setUserSiteTheme(stheme, true);
                break;
            }
        } else {
            // more then one brand available
            if(currentSectionThemeDefault != null && currentSectionThemeDefault != ''){
                // user should be login with default theme 
                Service_API.setUserSiteTheme(currentSectionThemeDefault, true); 
            } else {
                // we should clear current login theme -> then user needs to choose theme after login
                Service_API.setUserSiteTheme(null, false);
            }
        }
    }
   
    /**
    * @author Bartek Dudziak
    * @date 22/06/2012
    * @description Get number of content per page
    * @return Integer Number of content per page
    */
     public static void setUserNumberOfItemsPerPage(String customNumber){
        User userToUpdate = [SELECT id FROM USER WHERE ID =: getUID()][0];
        if(customNumber == null || customNumber == ''){
            customNumber = '12';
        }
        userToUpdate.Number_of_items_per_page__c = customNumber;
        update userToUpdate;
        userNumberOfItemsPerPage = customNumber;
    }    

    /**
    * @author Bartek Dudziak
    * @date 22/06/2012
    * @description Get number of content per page
    * @return Integer Number of content per page
    */
     public static void setUserSiteTheme(String theme, Boolean defaultInd){
        User userToUpdate = [SELECT id FROM USER WHERE ID =: getUID()][0];
        userToUpdate.Diageo_Direct_Theme__c = theme;
        
        if(defaultInd){
            userToUpdate.Use_current_theme_as_default__c = theme;
        }
        
        update userToUpdate;
        
        siteTheme = theme;
        if(defaultInd){
            siteThemeDefault = theme;
        } else {
            siteThemeDefault = '';
        }
    } 
    
    /**
    * @author Wojciech Migas
    * @date 14/11/2011
    * @description Get the user's last login date
    * @return DateTime User last login date
    */
    public static String getSSOId() {
        settings__c s = settings__c.getValues('ssoId');
        return s == null ? '' : s.value__c;
    }
    
    /**
    * @author Anna Ptak
    * @date 22/11/2011
    * @description Get id of 'Goals' folder
    * @return String Id of 'Goals' folder
    */
    public static String getGoalsFolderId() {
        settings__c s = settings__c.getValues('goalsFolderId');
        return s == null ? '' : s.value__c;
    }
    
    /**
    * @author Bartek Dudziak
    * @date 25/11/2011
    * @description Get id of 'SpiritsPlaning' folder
    * @return String Id of 'SpiritsPlaning' folder
    */
    public static String getSpiritsPlaningId() {
        settings__c s = settings__c.getValues('spiritsPlanningFolderId');
        return s == null ? '' : s.value__c;
    }

    
    /**
    * @author Bartek Dudziak
    * @date 28/11/2011
    * @description Get name of 'Setting'
    * @return String Value of 'Setting
    */
    public static String getSetting(String settingName) {
        settings__c s = settings__c.getValues(settingName);
        return s == null ? '' : s.value__c;
    }
    
    /**
    * @author Wojciech Migas
    * @date 24/11/2011
    * @description Get id of 'POS Ad hoc' folder
    * @return String Id of 'POS Ad hoc' folder
    */
    public static String getPosAdHocFolderId() {
        settings__c s = settings__c.getValues('posAdHocFolderId');
        return s == null ? '' : s.value__c;
    }
    
    /**
    * @author Wojciech Migas
    * @date 24/11/2011
    * @description Get id of 'POS TOOL' folder
    * @return String Id of 'POS TOOL' folder
    */
    public static String getPosToolFolderId() {
        settings__c s = settings__c.getValues('posToolFolderId');
        return s == null ? '' : s.value__c;
    }
    
    /**
    * @author Anna Ptak
    * @date 22/11/2011
    * @description Get video player id
    * @return String Video player id
    */
    public static String getVideoPlayerId() {
        settings__c s = settings__c.getValues('videoPlayerId');
        return s == null ? '' : s.value__c;
    }
    
    /**
    * @author Anna Ptak
    * @date 22/11/2011
    * @description Get video player key
    * @return String Video player key
    */
    public static String getVideoPlayerKey() {
        settings__c s = settings__c.getValues('videoPlayerKey');
        return s == null ? '' : s.value__c;
    }
    
    /**
    * @author Denise Bacher
    * @date 27/07/2011
    * @description Get the user's contact id
    * @return String The contact id as a string for the current user
    */
    public static String getCID(){
        if (cid==null) {
            getUserAccountInfo();
        }
        return cid;
    }
    
    public static String getAID(){
        if(userAID==null){
            getUserAccountInfo();
        }
        return userAID;
    }

    /**
    * @author Bartosz Dudziak
    * @date 01/05/2012
    * @description Get the user's associated account name
    * @return String The account name as a string associated with the current user
    */
    public static List<String> getDistributorNames(){
        if (distributorNames==null) {
            getUserAccountInfo();
        }
        return distributorNames;
    }


    /**
    * @author Wojciech Migas
    * @date 28/11/2011
    * @description Get the user's associated account ids
    * @return String The account ids as a set of string associated with the current user
    */
    public static set<Id> getAIDs(){
        if (aids==null) {
            getUserAccountInfo();
        }
        return aids;
    }

    /**
    * @author Wojciech Migas
    * @date 28/11/2011
    * @description Get the user's associated division names
    * @return String The account division names as a set of string associated with the current user
    */
    public static set<String> getDivisions(){
        if (dnames==null) {
            getUserAccountInfo();
        }
        return dnames;
    }
    
    /**
    * @author Bartek Dudziak
    * @date 27/02/2012
    * @description Get tab sections
    * @return String The account division names as a set of string associated with the current user
    */
    public static List<Sections__c> getSectionTabs(String section){
        if (sectionTabs==null) {
            String thm = '%'+Service_API.getSectionTheme()+'%';
            // Changes done by Jai Gupta [Appirio Jaipur] for case #00033756 on Oct 03, 2012
            // Revert back the change which was done for case #00033756 by Mohit for Case #00034036 on Oct 9,2012.
            sectionTabs = [select Section__c, Parent_Tab__c, Tab__c, Sales_Driver__c, Order__c FROM Sections__c where Section__c = :section AND Classification__c like :thm ORDER BY Order__c];
            //sectionTabs = [select Section__c, Parent_Tab__c, Tab__c, Sales_Driver__c, Order__c FROM Sections__c where Section__c = :section AND Classification__c like :thm ORDER BY Tab__c];
            // End for case #00033756
        }
        return sectionTabs;
    }    
    
    /**
    * @author Denise Bacher
    * @date 29/08/2011
    * @description Get the user's account and contact ids
    */
    private static void getUserAccountInfo(){
        if (userAID==null || cid==null) {
            User currUser = [SELECT Id, AccountID, ContactID, Contact.Account.Division__c, Contact.Account.Name FROM User WHERE Id = :getUID()];
            List<Account_Member__c> members = [select Account__c, Account__r.Name, Account__r.Division__c, Default__c from Account_Member__c where User__c = :currUser.Id]; 
            for(Account_Member__c m : members){
                if(m.Default__c){
                    userAID = m.Account__c;
                    break;
                }
            }
            if(members == null || members.size()==0) {
                userAID = currUser.AccountID;
            }
            if (userAID==null) {
                throw new Service_APIException('Misconfigured account relation');
            }
            cid             = currUser.ContactID;
            aids            = new set<Id>();
            set<Id> tmpaids = new set<Id>();
            if (userAID != null) {
                tmpaids.add(userAID);
            }
            distributorNames = new List<String>();
            for(Account_Member__c member : members){
                tmpaids.add(member.Account__c);
                distributorNames.add(member.Account__r.Name);
            }
            //get child accounts from account hierarchy
            getAllChildAccounts(tmpaids);
            //get division names
            dnames = new set<String>();
            list<Organizational_Unit__c> ous = [SELECT Name FROM Organizational_Unit__c WHERE Id in: searchOrganizationalUnitIds(aids) AND Label__c = 'Division' ];
            for (Organizational_Unit__c ou : ous) {
                dnames.add(ou.Name);
            }
        }
    }
    
    /**
    * @author Wojciech Migas
    * @date 23/10/2011
    * @description Recurive function which get all child account ids
    */
    public static void getAllChildAccounts(set<Id> parentIds){
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
                  and Account.RecordTypeId in :Service_API.getAccountRecordTypeIds()
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
    }
    
/**
** Brand Requests
**/
    private static Set<Id> brandIDs;
    private static Set<Id> brandContentIDs;
    private static Set<Id> allContentIDs;
    private static List<Brand__c> userBrands;        // parent brands
    private static List<Brand__c> allUserBrands;    // parent and child brands
    
    /**
    * @author Denise Bacher
    * @date 26/07/2011
    * @description Get the AccountBrand IDs associate with the user's account to get the brands.
    * @return Set<Id> A set of AccoutBrand IDs
    */
    public static Set<Id> getAccBrandIds(){
        if (brandIDs == null) {

            List<AggregateResult> userAccountBrands = [
                SELECT id from Brand__c WHERE diageo_direct_visible__c = true and Classification__c = :getSectionTheme() and id in 
                    (
                        SELECT Brand__c
                        FROM AccountBrand__c                    
                        WHERE Account__c in :getAIDs() and Brand__r.diageo_direct_visible__c = true and Brand__r.Classification__c = :getSectionTheme() and Account__r.RecordTypeId in :Service_API.getAccountRecordTypeIds()
                    )
                GROUP BY id
            ];
            brandIDs = new Set<Id>();
            for (AggregateResult ar: userAccountBrands) {
                brandIDs.add((Id)ar.get('id'));
            }
        }
        return brandIDs;
    }
    
    public static Set<Id> getAccBrandIds(Set<String> themes){
            // Start : For US85/TA910
            // Edited by Jonathan Freese to per DE552 to change Other to US Spirits
                List<AggregateResult> userAccountBrands;
                if((themes.contains('Catalyst') && themes.contains('US Spirits')) 
                        || !(themes.contains('Catalyst') || themes.contains('US Spirits'))){
                    userAccountBrands = [
                SELECT id FROM Brand__c WHERE diageo_direct_visible__c = true AND Classification__c IN :themes AND Id IN 
                (
                    SELECT Brand__c
                    FROM AccountBrand__c                    
                        WHERE Account__c IN :getAIDs() AND Brand__r.diageo_direct_visible__c = true 
                        AND Brand__r.Classification__c IN :themes AND Account__r.RecordTypeId IN :Service_API.getAccountRecordTypeIds()
                )
                GROUP BY id];
                }else if(themes.contains('Catalyst') || themes.contains('US Spirits')){
                    themes.add(Label.CatalystParentTheme);
                    Set<Id> selectedBrandIds = new Set<Id>();
                    boolean catalyst = (themes.contains('Catalyst') ? true : false);
                    // Start : Changes for US85/DE583-DE576 : Basant Verma
                    userAccountBrands = [
		                SELECT id FROM Brand__c WHERE diageo_direct_visible__c = true AND Classification__c IN :themes AND Id IN 
		                (
		                    SELECT Brand__c
		                    FROM AccountBrand__c                    
		                        WHERE Account__c IN :getAIDs() AND Brand__r.diageo_direct_visible__c = true 
		                        AND Brand__r.Classification__c IN :themes AND Account__r.RecordTypeId IN :Service_API.getAccountRecordTypeIds()
		                        AND (Brand__r.Classification__c != :Label.CatalystParentTheme 
		                        			OR (Brand__r.Classification__c = :Label.CatalystParentTheme AND Brand__r.Catalyst__c = :catalyst))
		                )
		                GROUP BY id];
		                // End : Changes for US85/DE583-DE576 : Basant Verma
                }
        // End : For US85/TA910
                  
        Set<Id> brandIDs1 = new Set<Id>();
        for (AggregateResult ar: userAccountBrands) {
            brandIDs1.add((Id)ar.get('id'));
        }
        return brandIDs1;
    }
    
    public static Set<Id> getAccBrandIdsForUser(Id userId){ 
        set<id> brandIDsFoUser = new Set<Id>();
        
        //If it's a Diageo member they have all brands so skip this 
        List<Account> diageoAccounts = [select Id from Account where name='DIAGEO' and RecordType.Name='Distributor'];
        if (diageoAccounts.size()==1) {
            //Should be one and only one.  If there's not don't try this (at home)
            Account DIAGEO = diageoAccounts.get(0);
            List<Account_Member__c> ams = [select Id from Account_Member__c where User__c = :userId and Account__c = :DIAGEO.Id];
            
            if (ams.size()>0) {
                List<Brand__c> brands = [select Id from Brand__c where diageo_direct_visible__c = true and Classification__c = :getSectionTheme() ];
                for (Brand__c brand:brands) {
                    brandIDsFoUser.add(brand.Id);
                }
                return brandIDsFoUser;
            }
        }
        
        //Not a Diageo member so get the real list
        
        List<AccountBrand__c> userAccountBrands = [
            SELECT Brand__c
                FROM AccountBrand__c                    
                WHERE Account__c in :getAIDsForUser(userId) and Brand__r.diageo_direct_visible__c = true and Brand__r.Classification__c = :getSectionTheme() and Account__r.RecordTypeId in :Service_API.getAccountRecordTypeIds()
                //GROUP BY Brand__c 
        ];
        
        for (AccountBrand__c ab: userAccountBrands) {
            brandIDsFoUser.add(ab.Brand__c);
        }
       
        return brandIDsFoUser;
    }
    
    public static set<Id> getAIDsForUser(Id userId){
        User currUser = [SELECT Id, AccountID, ContactID, Contact.Account.Division__c, Contact.Account.Name FROM User WHERE Id = :userId];
        List<Account_Member__c> members = [select Account__c, Account__r.Name, Account__r.Division__c, Default__c from Account_Member__c where User__c = :currUser.Id]; 
        Id thisUserAID;
        for(Account_Member__c m : members){
            if(m.Default__c){
                thisUserAID = m.Account__c;
                break;
            }
        }
        if(members == null || members.size()==0) {
            thisUserAID = currUser.AccountID;
        }
        if (thisUserAID==null) {
            throw new Service_APIException('Misconfigured account relation');
        }
        set<id> thisUserAids = new set<Id>();
        set<Id> tmpaids = new set<Id>();
        if (userAID != null) {
            tmpaids.add(userAID);
        }
        for(Account_Member__c member : members){
            tmpaids.add(member.Account__c);
        }
        //get child accounts from account hierarchy
        getAllChildAccountsNoRewrite(thisUserAids, tmpaids);
        return thisUserAids;
    }        
    
    public static void getAllChildAccountsNoRewrite(set<id> resultHolder, set<Id> parentIds){
        System.debug('=========resultHolder= ' + resultHolder); //Testing Reports - Diana 2/5
        System.debug('=========parentIds1= ' + parentIds); //Testing Reports - Diana 2/5
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
                        OR parent.parent.parent.parentId in: parentIds
                       )
                  
        ];
        
        System.debug('=========ts= ' + ts); //Testing Reports - Diana 2/5

        oldParentIds = new set<id>(parentIds);
        parentIds.clear();
        for (Account t: ts) {
            resultHolder.add(t.Id);
            if (t.parent.parent.parent.parentId != null && oldParentIds.contains(t.parent.parent.parent.parentId) ) {
                parentIds.add(t.id);
            }
        }
        System.debug('=========resultHolder= ' + resultHolder); //Testing Reports - Diana 2/5
        System.debug('=========parentIds2= ' + parentIds); //Testing Reports - Diana 2/5
        getAllChildAccountsNoRewrite(resultHolder, parentIds);
    }    
    
    /**
    * @author Anna Ptak
    * @date 27/09/2011
    * @description Get the Brands associated with the Account the Customer Portal User is part of.
    * @return List<Brand__c> A list of parent brands
    */
    public static List<Brand__c> getBrandsByCategories(String[] categoryList){
            Brand__c[] childBrands = [
                SELECT Parent_Brand__c 
                    FROM Brand__c 
                    WHERE Id in :getAccBrandIds() 
                        AND Parent_Brand__c != NULL
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                        and (Parent_Brand__r.diageo_direct_visible__c = true and Parent_Brand__r.Classification__c = :getSectionTheme())
            ];
            set<Id> parentIds = new set<Id>();
            for (Brand__c brand : childBrands) {
                parentIds.add(brand.Parent_Brand__c);
            } 
        if (categoryList == null || categoryList.size() == 0) {
            return [
                SELECT Id, Name, brand_description__c, content_description__r.Content_Version_Id__c, brand_priority__c, brand_type__c, 
                    category__c, classification__c, generic_brand__c, parent_brand__c, reserve_brand__c
                    FROM Brand__c
                    WHERE 
                        ( Id in :getAccBrandIds() or Id in :parentIds )
                        AND Parent_Brand__c = null 
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())  
                    ORDER BY brand_priority__c DESC, Brand_Order__c ASC
                    LIMIT 1000
            ];
        } else {
            return [
                SELECT Id, Name, brand_description__c, content_description__r.Content_Version_Id__c, brand_priority__c, brand_type__c,
                    category__c, classification__c, generic_brand__c, parent_brand__c, reserve_brand__c
                    FROM Brand__c
                    WHERE
                       ( Id in :getAccBrandIds() or Id in :parentIds )
                       AND category__c in :categoryList
                       AND Parent_Brand__c = null
                       and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())              
                    ORDER BY brand_priority__c DESC, Brand_Order__c ASC
                    LIMIT 1000
            ];
        }
    }
    
    /* overloaded */
    public static List<Brand__c> getPILBrandsNew2(Boolean isInnovation){
        return  getPILBrandsNew2(isInnovation, false);
    }
    
   /**
    * @author Bartek Dudziak, modified by Maciek Krol
    * @date 09/12/2011, modified 08/21/2012
    * @description Get the Brands associated with the Account the Customer Portal User is part of.
    * @return List<Brand__c> A list of parent brands
    */
    public static List<Brand__c> getPILBrandsNew2(Boolean isInnovation, Boolean isWine){
        if(isWine){
            if(isInnovation){
                return [
                    SELECT Id, Name, brand_description__c, PIL_Logo__r.Content_Version_Id__c, brand_priority__c, brand_type__c, 
                        category__c, classification__c, generic_brand__c, parent_brand__c, reserve_brand__c, Core_Trademarks__c, Innovation__c,
                        Heritage__c, Heritage_Logo__r.Content_Version_Id__c, Lifestyle__c, Lifestyle_Logo__r.Content_Version_Id__c, Luxury__c, Luxury_Logo__r.Content_Version_Id__c,
                        Core_Trademarks_Logo__r.Content_Version_Id__c, Innovation_Logo__r.Content_Version_Id__c, Reserve_Brand_Logo__r.Content_Version_Id__c,  
                        Brand_Variant_Grouping__c
                        FROM Brand__c
                        WHERE (
                                Id in :getAccBrandIds() 
                            )
                            AND Innovation__c = true // AND Parent_Brand__c != NULL
                            and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                        //    and (Parent_Brand__r.diageo_direct_visible__c = true and Parent_Brand__r.Classification__c = :getSectionTheme())
                        ORDER BY Name ASC
                        LIMIT 1000
                ];
            } else {
                return [
                    SELECT Id, Name, brand_description__c, PIL_Logo__r.Content_Version_Id__c, brand_priority__c, brand_type__c, 
                        category__c, classification__c, generic_brand__c, parent_brand__c, reserve_brand__c, Core_Trademarks__c, Innovation__c,
                        Heritage__c, Heritage_Logo__r.Content_Version_Id__c, Lifestyle__c, Lifestyle_Logo__r.Content_Version_Id__c, Luxury__c, Luxury_Logo__r.Content_Version_Id__c,
                        Core_Trademarks_Logo__r.Content_Version_Id__c, Innovation_Logo__r.Content_Version_Id__c, Reserve_Brand_Logo__r.Content_Version_Id__c,  
                        Brand_Variant_Grouping__c
                        FROM Brand__c
                        WHERE (
                                Id in :getAccBrandIds() 
                            )
                           AND Parent_Brand__c = null                          
                           and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                        ORDER BY Name ASC
                        LIMIT 1000
                ];
            }   
        }else{
            if(isInnovation){
                return [
                    SELECT Id, Name, brand_description__c, PIL_Logo__r.Content_Version_Id__c, brand_priority__c, brand_type__c, 
                        category__c, classification__c, generic_brand__c, parent_brand__c, reserve_brand__c, Core_Trademarks__c, Innovation__c,
                        Heritage__c, Heritage_Logo__r.Content_Version_Id__c, Lifestyle__c, Lifestyle_Logo__r.Content_Version_Id__c, Luxury__c, Luxury_Logo__r.Content_Version_Id__c,
                        Core_Trademarks_Logo__r.Content_Version_Id__c, Innovation_Logo__r.Content_Version_Id__c, Reserve_Brand_Logo__r.Content_Version_Id__c,  
                        Brand_Variant_Grouping__c
                        FROM Brand__c
                        WHERE (
                                Id in :getAccBrandIds() 
                            )
                            AND Innovation__c = true AND Parent_Brand__c != NULL
                            and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                            and (Parent_Brand__r.diageo_direct_visible__c = true and Parent_Brand__r.Classification__c = :getSectionTheme())
                        ORDER BY Name ASC
                        LIMIT 1000
                ];
            } else {
                return [
                    SELECT Id, Name, brand_description__c, PIL_Logo__r.Content_Version_Id__c, brand_priority__c, brand_type__c, 
                        category__c, classification__c, generic_brand__c, parent_brand__c, reserve_brand__c, Core_Trademarks__c, Innovation__c,
                        Heritage__c, Heritage_Logo__r.Content_Version_Id__c, Lifestyle__c, Lifestyle_Logo__r.Content_Version_Id__c, Luxury__c, Luxury_Logo__r.Content_Version_Id__c,
                        Core_Trademarks_Logo__r.Content_Version_Id__c, Innovation_Logo__r.Content_Version_Id__c, Reserve_Brand_Logo__r.Content_Version_Id__c,  
                        Brand_Variant_Grouping__c
                        FROM Brand__c
                        WHERE (
                                Id in :getAccBrandIds() 
                            )
                            AND Parent_Brand__c = null
                            and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                        ORDER BY Name ASC
                        LIMIT 1000
                ];
            }   
        }         
    }
    
   /**
    * @author Bartek Dudziak
    * @date 09/12/2011
    * @description Get the Brands associated with the Account the Customer Portal User is part of.
    * @return List<Brand__c> A list of parent brands
    */
    public static List<Brand__c> getPILBrandsNewSearch(String searchName){
            searchName = '%'+searchName+'%';
            return [
                    SELECT Id, Name, brand_description__c, PIL_Logo__r.Content_Version_Id__c, brand_priority__c, brand_type__c, 
                        category__c, classification__c, generic_brand__c, parent_brand__c, 
                        reserve_brand__c, 
                        Core_Trademarks__c, 
                        Innovation__c,
                        Core_Trademarks_Logo__r.Content_Version_Id__c, 
                        Innovation_Logo__r.Content_Version_Id__c, 
                        Reserve_Brand_Logo__r.Content_Version_Id__c,  
                        Heritage__c, Heritage_Logo__r.Content_Version_Id__c, Lifestyle__c, Lifestyle_Logo__r.Content_Version_Id__c, Luxury__c, Luxury_Logo__r.Content_Version_Id__c,
                        Brand_Variant_Grouping__c
                        FROM Brand__c
                        WHERE (
                                Id in :getAccBrandIds() 
                            )
                            and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                            and (name like :searchName)
                        ORDER BY Name ASC
                        LIMIT 1000
                ];

    }


    /**
    * @author Denise Bacher
    * @date 27/07/2011
    * @param currentBrand Currently selected brand ID
    * @description Get the related child brands (brand varients)
    * @return List<Brand__c> A list of child brands
    */
    public static List<Brand__c> getPILChildBrands(ID currentBrand){
        if (!getAccBrandIds().contains(currentBrand)) {
            return new List<Brand__C>();
        }

        return [
            SELECT Id, name, brand_description__c, brand_priority__c, brand_type__c, category__c, classification__c, generic_brand__c,
                parent_brand__c, reserve_brand__c, Core_Trademarks__c, Innovation__c, Brand_Variant_Grouping__c
                FROM Brand__c
                WHERE Parent_Brand__c = :currentBrand
                    and Id in :getAccBrandIds()  
                    and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                    and (Parent_Brand__r.diageo_direct_visible__c = true and Parent_Brand__r.Classification__c = :getSectionTheme())
                ORDER BY name, Brand_Variant_Grouping__c
        ];
    }

    /**
    * @author Bartek Dudziak
    * @date 23/01/2012
    * @param brand id list
    * @description get brand list sorted by Brand_Variant_Grouping__c
    * @return List<Brand__c> A list of brands
    */
    public static List<Brand__c> getPILChildBrandsByIds(set<ID> brandIdSet){
        return [
            SELECT Id, name, brand_description__c, brand_priority__c, brand_type__c, category__c, classification__c, generic_brand__c,
                parent_brand__c, reserve_brand__c, Core_Trademarks__c, Innovation__c, Brand_Variant_Grouping__c
                FROM Brand__c
                WHERE id in :brandIdSet 
                    AND Id in :getAccBrandIds() 
                    and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                ORDER BY Brand_Variant_Grouping__c
        ];
    }
    
    /**
    * @author Bartek Dudziak
    * @date 09/12/2011
    * @description Get the Brands associated with the Account the Customer Portal User is part of.
    * @return List<Brand__c> A list of parent brands
    */
    public static List<Brand__c> getBrandsForFilters(String category){
        if (category == null || category=='') {
            return getBrandsForFilters(new list<String>());
        } else {
            return getBrandsForFilters(new String[]{category});
        }
    }
    
    /**
    * @author Bartek Dudziak
    * @date 09/12/2011
    * @description Get the Brands associated with the Account the Customer Portal User is part of.
    * @return List<Brand__c> A list of parent brands
    */
    public static List<Brand__c> getBrandsForFilters(list<String> category){
            Brand__c[] childBrands = [
                SELECT Parent_Brand__c 
                    FROM Brand__c 
                    WHERE Id in :getAccBrandIds() 
                        AND Parent_Brand__c != NULL
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                        and (Parent_Brand__r.diageo_direct_visible__c = true and Parent_Brand__r.Classification__c = :getSectionTheme())
            ];
            set<Id> parentIds = new set<Id>();
            for (Brand__c brand : childBrands) {
                parentIds.add(brand.Parent_Brand__c);
            } 
        if (category == null || category.size()==0) {
            return [
                SELECT Id, Name, brand_description__c, Filtering_logo__r.Content_Version_Id__c, brand_priority__c, brand_type__c, 
                    category__c, classification__c, generic_brand__c, parent_brand__c, reserve_brand__c
                    FROM Brand__c
                    WHERE (
                            Id in :getAccBrandIds() or Id in :parentIds
                        )
                        AND Parent_Brand__c = null     
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())           
                    ORDER BY filter_order__c, name ASC
                    LIMIT 1000
            ];
        } else {
            return [
                SELECT Id, Name, brand_description__c, Filtering_logo__r.Content_Version_Id__c, brand_priority__c, brand_type__c,
                    category__c, classification__c, generic_brand__c, parent_brand__c, reserve_brand__c
                    FROM Brand__c
                    WHERE (
                           Id in :getAccBrandIds() or Id in :parentIds
                        )
                        AND category__c in :category
                        AND Parent_Brand__c = null
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())              
                    ORDER BY filter_order__c, name ASC
                    LIMIT 1000
            ];
        }
    }
    
    
    public static List<Brand__c> getAdditionalBrandsForFilters(Set<Id> mainBrands, list<String> category){
            Brand__c[] childBrands = [
                SELECT Parent_Brand__c 
                    FROM Brand__c 
                    WHERE Id in :getAccBrandIds() 
                        AND Parent_Brand__c != NULL
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                        and (Parent_Brand__r.diageo_direct_visible__c = true and Parent_Brand__r.Classification__c = :getSectionTheme())
            ];
            set<Id> parentIds = new set<Id>();
            for (Brand__c brand : childBrands) {
                parentIds.add(brand.Parent_Brand__c);
            } 
        
          if (category == null || category.size()==0) {
            return [
                SELECT Id, Name, brand_description__c, Filtering_logo__r.Content_Version_Id__c, brand_priority__c, brand_type__c, 
                    category__c, classification__c, generic_brand__c, parent_brand__c, reserve_brand__c
                    FROM Brand__c
                    WHERE (
                            Id in :getAccBrandIds() or Id in :parentIds
                        )
                        AND Id not in:mainBrands
                        AND Parent_Brand__c = null   
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())             
                    ORDER BY  name ASC
                    LIMIT 1000
            ];
        } else {
            return [
                SELECT Id, Name, brand_description__c, Filtering_logo__r.Content_Version_Id__c, brand_priority__c, brand_type__c,
                    category__c, classification__c, generic_brand__c, parent_brand__c, reserve_brand__c
                    FROM Brand__c
                    WHERE (
                            Id in :getAccBrandIds() or Id in :parentIds
                        )
                        AND category__c in :category
                        AND Id not in:mainBrands
                        AND Parent_Brand__c = null   
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())      
                    ORDER BY name ASC
                    LIMIT 1000
            ];
        }
    }
    /**
    * @author Bartosz Dudziak
    * @date 01/10/2012
    * @description Get all 'Ready to Serve' brands, both parent and child
    * @return List<Brand__c> A list of both parent and child brands
    */
    public static List<Brand__c> getRTSBrands(){
        if(rtsBrands == null){
            rtsBrands = [
                SELECT Id, Name, brand_description__c, brand_priority__c, brand_type__c, category__c, classification__c, generic_brand__c,
                    parent_brand__c, reserve_brand__c
                FROM Brand__c
                WHERE (
                        Id in :getAccBrandIds()
                    ) 
                    AND category__c in ('Ready to Serve')
                    AND diageo_direct_visible__c = true and Classification__c = :getSectionTheme()
                ORDER By Generic_Brand__c, Parent_Brand__c, name
            ];
        }
        
        return rtsBrands;
    }
        
    /**
    * @author Denise Bacher
    * @date 27/07/2011
    * @description Get all brands, both parent and child
    * @return List<Brand__c> A list of both parent and child brands
    */
    public static List<Brand__c> getAllBrands(){
        if(allUserBrands == null){
            allUserBrands = [
                SELECT Id, Name, brand_description__c, brand_priority__c, brand_type__c, category__c, classification__c, generic_brand__c,
                    parent_brand__c, reserve_brand__c
                FROM Brand__c
                WHERE (
                        Id in :getAccBrandIds()
                    )
                    AND diageo_direct_visible__c = true and Classification__c = :getSectionTheme()
                ORDER By Generic_Brand__c, Parent_Brand__c, name
            ];
        }
            
        return allUserBrands;
    } 

    public static List<Brand__c> getAllBrands(Set<String> themes){
            Set<Id> tmpSetOfIds = Service_API.getAccBrandIds(themes);
        return [
            SELECT Id, Name, brand_description__c, brand_priority__c, brand_type__c, category__c, classification__c, generic_brand__c,
                parent_brand__c, reserve_brand__c
            FROM Brand__c
            WHERE (
                    Id in :tmpSetOfIds
                )
                AND diageo_direct_visible__c = true and Classification__c in :themes
            ORDER By Generic_Brand__c, Parent_Brand__c, name
        ];
    }
    
    /**
    * @author Denise Bacher
    * @date 29/08/2011
    * @param currentBrand Currently selected brand ID
    * @description Get all information for a single brand
    * @return Brand__c A single brand record
    */
    public static Brand__c getBrandInfo(ID currentBrand){
            Brand__c[] childBrands = [
                SELECT Parent_Brand__c 
                    FROM Brand__c 
                    WHERE Id in :getAccBrandIds() 
                        AND Parent_Brand__c != NULL
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                        and (Parent_Brand__r.diageo_direct_visible__c = true and Parent_Brand__r.Classification__c = :getSectionTheme())
            ];
            set<Id> parentIds = new set<Id>();
            for (Brand__c brand : childBrands) {
                parentIds.add(brand.Parent_Brand__c);
            } 
        return [
            SELECT ID, Name, brand_description__c, brand_priority__c, brand_type__c, category__c, classification__c, generic_brand__c,
                parent_brand__c, reserve_brand__c, gradient_bottom_color__c, gradient_top_color__c, font_color__c, PIL_Logo__r.Content_Version_Id__c
                FROM Brand__c
                WHERE (Id = :currentBrand) AND ( id in :parentIds OR Id in :getAccBrandIds() )
                    and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                limit 1
        ];       
    }
    
    /**
    * @author Bartek Dudziak
    * @date 08/09/2011
    * @description Get brand parents
    * @return List<Brand__c> A list of parent brands
    */
    public static List<Brand__c> getParentBrands(){
        return [
            SELECT Id, Name, brand_description__c, brand_priority__c, brand_type__c, category__c, classification__c, generic_brand__c,
                parent_brand__c, reserve_brand__c
                FROM Brand__c
                WHERE (
                        Id in :getAccBrandIds() 
                    )
                    AND Parent_Brand__c = null
                    and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                ORDER BY Generic_Brand__c, Parent_Brand__c, name 
                LIMIT 1000
        ];
    }
        
    /**
    * @author Denise Bacher
    * @date 27/07/2011
    * @param currentBrand Currently selected brand ID
    * @description Get the related child brands (brand varients)
    * @return List<Brand__c> A list of child brands
    */
    public static List<Brand__c> getChildBrands(ID currentBrand){
        return [
            SELECT Id, name, brand_description__c, brand_priority__c, brand_type__c, category__c, classification__c, generic_brand__c,
                parent_brand__c, reserve_brand__c
                FROM Brand__c
                WHERE Parent_Brand__c = :currentBrand
                AND Id in :getAccBrandIds()
                AND diageo_direct_visible__c = true and Classification__c = :getSectionTheme()
                ORDER BY name
        ];
    }
    
/**
** Calendar Requests
**/
    private static Set<Id> calendarBrandIDs;
    private static List<ContentVersion> brandContent;
    private static List<CalendarBrand__c> calendarBrands;    
    
    /**
    * @author Denise Bacher
    * @date 04/08/2011
    * @description Get a list of calendar ids by brands that this user can see
    * @return Set<ID> A set of calendar ids by brands that this user can see
    */
    public static Set<ID> getCalendarBrands(){
        if(calendarBrands == null){
            calendarBrands = [
                SELECT Id, Brand__c, Calendar__c
                    FROM CalendarBrand__c
                    WHERE Brand__c IN :getAllBrands()
            ];
                      
            calendarBrandIDs = new Set<Id>();
            for(CalendarBrand__c msp: calendarBrands)
            {
                calendarBrandIDs.add(msp.Calendar__c);
            }
        }
        return calendarBrandIDs;
    }
    
    public static Set<ID> getCalendarBrands(Set<String> themes){
            list<CalendarBrand__c> calendarBrands1 = [
                SELECT Id, Brand__c, Calendar__c
                    FROM CalendarBrand__c
                    WHERE Brand__c IN :getAllBrands(themes)
            ];
    
            Set<Id> calendarBrandIDs1 = new Set<Id>();
            for(CalendarBrand__c msp: calendarBrands1)
            {
                calendarBrandIDs1.add(msp.Calendar__c);
            }
        return calendarBrandIDs1;
    }
    
    /**
    * @author Denise Bacher
    * @date 05/08/2011
    * @param startSate Start date of the date range to be returned
    * @param endDate End date of the date range to be returned
    * @param salesDriver The user selected Sales Driver
    * @description Get a list of Monthly Execution Plan for the current user for a specific sales driver or all drivers
    * @return List<Calendar__c> A list of Monthly Execution Plan for the current user for a specific sales driver or all drivers
    */
    public static List<Calendar__c> getMEPs(Date startDate, Date endDate, String salesDriver, Set<String> themes){
        Set<ID> ids = getCalendarBrands(themes);
        if (salesDriver != 'All') {
            return [
                SELECT Id, name, sales_channel__c, description__c, start_date__c, end_date__c , background_color__c, background_color2__c,
                    Logo_Image_Small__r.content_id__c, Logo_Image_Large__r.content_id__c, text_color__c, classification__c   
                    FROM Calendar__c
                    WHERE recordtype.name =: Constant.MONTHLY_EXECUTION_PLAN 
                        AND ((start_date__c >= :startDate AND start_date__c < :endDate) OR (end_date__c <= :endDate AND end_date__c > :startDate) OR (end_date__c >= :endDate AND start_date__c <= :startDate) )
                        AND ID in :ids 
                        AND Archive__c = false
                        AND sales_channel__c = :salesDriver
                    ORDER BY sales_channel__c, classification__c, priority__c ASC, start_date__c
            ];
        } else {
            List<Calendar__c> tmp =  [
                SELECT Id, name, sales_channel__c, description__c, start_date__c, end_date__c , background_color__c, background_color2__c,
                    Logo_Image_Small__r.content_id__c, Logo_Image_Large__r.content_id__c, text_color__c, classification__c     
                    FROM Calendar__c
                    WHERE recordtype.name =: Constant.MONTHLY_EXECUTION_PLAN 
                        AND ((start_date__c >= :startDate AND start_date__c < :endDate) OR (end_date__c <= :endDate AND end_date__c > :startDate) OR (end_date__c >= :endDate AND start_date__c <= :startDate) )
                        AND ID in :ids
                        AND Archive__c = false
                    ORDER BY sales_channel__c, classification__c, priority__c ASC, start_date__c                        
            ];
            return tmp;
        }
    }
    
    /**
    * @author Bartek Dudziak
    * @date 23/11/2011
    * @param startSate Start date of the date range to be returned
    * @param endDate End date of the date range to be returned
    * @param salesDriver The user selected Sales Driver
    * @description Get a list of Planning for the current user for a specific sales driver or all drivers
    * @return List<Calendar__c> A list of Planning for the current user for a specific sales driver or all drivers
    */
    public static List<Calendar__c> getPlanningCalendarItems(Date startDate, Date endDate, String salesDriver, String folderId, Set<String> themes){
        if (salesDriver != 'All') {
            return [
                SELECT Id, name, sales_channel__c, description__c, start_date__c, end_date__c , background_color__c, background_color2__c,
                    Logo_Image_Small__r.content_id__c, Logo_Image_Large__r.content_id__c, text_color__c, classification__c
                    FROM Calendar__c
                    WHERE recordtype.name =: Constant.PLANNING 
                        AND ((start_date__c >= :startDate AND start_date__c < :endDate) OR (end_date__c <= :endDate AND end_date__c > :startDate) OR (end_date__c >= :endDate AND start_date__c <= :startDate) )
                        AND Archive__c = false
                        AND sales_channel__c = :salesDriver
                        AND Folder__c = :folderId
                    ORDER BY sales_channel__c, classification__c, priority__c ASC, start_date__c
            ];
        } else {
            return [
                SELECT Id, name, sales_channel__c, description__c, start_date__c, end_date__c , background_color__c, background_color2__c,
                    Logo_Image_Small__r.content_id__c, Logo_Image_Large__r.content_id__c, text_color__c, classification__c
                    FROM Calendar__c
                    WHERE recordtype.name =: Constant.PLANNING 
                        AND ((start_date__c >= :startDate AND start_date__c < :endDate) OR (end_date__c <= :endDate AND end_date__c > :startDate) OR (end_date__c >= :endDate AND start_date__c <= :startDate) )
                        AND Archive__c = false
                        AND Folder__c = :folderId
                    ORDER BY sales_channel__c, classification__c, priority__c ASC, start_date__c                       
            ];
        }
    }

    /**
    * @author Bartek Dudziak
    * @date 28/11/2011
    * @param startSate Start date of the date range to be returned
    * @param endDate End date of the date range to be returned
    * @param salesDriver The user selected Sales Driver
    * @description Get a list of Multicultural for the current user for a specific sales driver or all drivers
    * @return List<Calendar__c> A list of Multicultural for the current user for a specific sales driver or all drivers
    */
    public static List<Calendar__c> getMulticulturalCalendarItems(Date startDate, Date endDate, String salesDriver, Set<String> themes){
        Set<ID> ids = getCalendarBrands(themes);        
        if (salesDriver != 'All') {
            return [
                SELECT Id, name, sales_channel__c, description__c, start_date__c, end_date__c , background_color__c, background_color2__c,
                    Logo_Image_Small__r.content_id__c, Logo_Image_Large__r.content_id__c, text_color__c, classification__c
                    FROM Calendar__c
                    WHERE recordtype.name =: Constant.MULTICULTURAL 
                        AND ((start_date__c >= :startDate AND start_date__c < :endDate) OR (end_date__c <= :endDate AND end_date__c > :startDate) OR (end_date__c >= :endDate AND start_date__c <= :startDate) )
                        AND Archive__c = false
                        AND ID in :ids                        
                        AND sales_channel__c = :salesDriver
                    ORDER BY sales_channel__c, classification__c, priority__c ASC, start_date__c
            ];
        } else {
            return [
                SELECT Id, name, sales_channel__c, description__c, start_date__c, end_date__c , background_color__c, background_color2__c,
                    Logo_Image_Small__r.content_id__c, Logo_Image_Large__r.content_id__c, text_color__c, classification__c
                    FROM Calendar__c
                    WHERE recordtype.name =: Constant.MULTICULTURAL 
                        AND ((start_date__c >= :startDate AND start_date__c < :endDate) OR (end_date__c <= :endDate AND end_date__c > :startDate) OR (end_date__c >= :endDate AND start_date__c <= :startDate) )
                        AND Archive__c = false
                        AND ID in :ids                  
                    ORDER BY sales_channel__c, classification__c, priority__c ASC, start_date__c                       
            ];
        }
    }


    /**
    * @author Bartosz Dudziak
    * @date 29/09/2011
    * @param startSate Start date of the date range to be returned
    * @param endDate End date of the date range to be returned
    * @param salesDriver The user selected Sales Driver
    * @description Get a list of Innovation, Sustainovation & VAP for the current user for a specific sales driver or all drivers
    * @return List<Calendar__c> A list of Innovation, Sustainovation & VAP for the current user for a specific sales driver or all drivers
    */
    public static List<Calendar__c> getIVAPs(Date startDate, Date endDate, String salesDriver, Set<String> themes){
        Set<ID> ids = getCalendarBrands(themes);
        
        if (salesDriver != 'All') {
            return [
                SELECT Id, name, sales_channel__c, description__c, start_date__c, end_date__c , background_color__c, background_color2__c,
                    Show_tooltip_details__c, Logo_Image_Small__r.content_id__c, Logo_Image_Large__r.content_id__c, text_color__c, Launch_Date__c, Ship_Date__c, classification__c        
                    FROM Calendar__c
                    WHERE recordtype.name =: Constant.INNOVATION_AND_SUSTAINOVATION 
                        AND ((start_date__c >= :startDate AND start_date__c < :endDate) OR (end_date__c <= :endDate AND end_date__c > :startDate) OR (end_date__c >= :endDate AND start_date__c <= :startDate) )
                        AND ID in :ids
                        AND Archive__c = false
                        AND sales_channel__c = :salesDriver
                    ORDER BY sales_channel__c, classification__c, priority__c ASC, start_date__c
            ];
        } else {
            return [
                SELECT Id, name, sales_channel__c, description__c, start_date__c, end_date__c , background_color__c, background_color2__c,
                    Show_tooltip_details__c, Logo_Image_Small__r.content_id__c, Logo_Image_Large__r.content_id__c, text_color__c, Launch_Date__c, Ship_Date__c, classification__c        
                    FROM Calendar__c
                    WHERE recordtype.name =: Constant.INNOVATION_AND_SUSTAINOVATION 
                        AND ((start_date__c >= :startDate AND start_date__c < :endDate) OR (end_date__c <= :endDate AND end_date__c > :startDate) OR (end_date__c >= :endDate AND start_date__c <= :startDate) )
                        AND ID in :ids
                        AND Archive__c = false
                    ORDER BY sales_channel__c, classification__c, priority__c ASC, start_date__c
            ];
        }
      }

    /**
    * @author Bartek Dudziak
    * @date 09/09/2011
    * @param Id Requested mep Id
    * @description Get a Monthly Execution Plan for requested ID
    * @return Calendar__c Requested Monthly Execution Plan Item.
    */
    public static Calendar__c getMEP(Id mepId, Set<String> themes){
        Set<ID> ids = getCalendarBrands(themes);
        return [
            SELECT Id, name, sales_channel__c, description__c, description_content_description__r.Content_Version_Id__c,
                description_content_description__r.filetype__c, start_date__c, end_date__c , background_color__c, Logo_Image_Small__r.content_id__c,
                Logo_Image_Large__r.content_id__c, text_color__c, classification__c   
                FROM Calendar__c
                WHERE recordtype.name =: Constant.MONTHLY_EXECUTION_PLAN 
                    AND ID in : ids  
                    AND Archive__c = false
                    AND ID = :mepId
        ];
    }

    /**
    * @author Bartek Dudziak
    * @date 29/09/2011
    * @param Id Requested ivap Id
    * @description Get a Innovation, Sustainovation & VAP for requested ID
    * @return Calendar__c Requested Innovation, Sustainovation & VAP Item.
    */
    public static Calendar__c getIVAP(Id ivapId, Set<String> themes){
        Set<ID> ids = getCalendarBrands(themes);
        return [
            SELECT Id, name, sales_channel__c, description__c, start_date__c, end_date__c , background_color__c, 
                description_content_description__r.Content_Version_Id__c, description_content_description__r.filetype__c, 
                Logo_Image_Small__r.content_id__c, Logo_Image_Large__r.content_id__c, text_color__c, Specification_Text__c, 
                Specification_Content_Description__r.Content_Version_Id__c, Specification_Content_Description__r.filetype__c, 
                Situation_Text__c, Situation_Content_Description__r.Content_Version_Id__c, Situation_Content_Description__r.filetype__c,
                Idea_Text__c, Idea_Content_Description__r.Content_Version_Id__c, Idea_Content_Description__r.filetype__c, 
                How_it_Works_Text__c, How_it_Works_Content_Description__r.Content_Version_Id__c,
                How_it_Works_Content_Description__r.filetype__c, Consumer_Target_Text__c, 
                Consumer_Target_Content_Description__r.Content_Version_Id__c, Consumer_Target_Content_Description__r.filetype__c,
                Show_tooltip_details__c, Launch_Date__c, Ship_Date__c, classification__c    
                FROM Calendar__c
                WHERE recordtype.name =: Constant.INNOVATION_AND_SUSTAINOVATION 
                    AND ID in :ids 
                    AND Archive__c = false
                    AND ID =: ivapId
        ];
      }
      
    /**
    * @author Bartek Dudziak
    * @date 09/09/2011
    * @param Id Requested planning calendar Id
    * @description Get a Planning Item for requested ID
    * @return Calendar__c Requested Planning Plan Item.
    */
    public static Calendar__c getPlanningCalendarItem(Id calendarId, Set<String> themes){
        return [
            SELECT Id, name, sales_channel__c, description__c, description_content_description__r.Content_Version_Id__c,
                description_content_description__r.filetype__c, start_date__c, end_date__c , background_color__c, Logo_Image_Small__r.content_id__c,
                Logo_Image_Large__r.content_id__c, text_color__c, classification__c    
                FROM Calendar__c
                WHERE recordtype.name =: Constant.PLANNING 
                    AND Archive__c = false
                    AND ID = :calendarId
        ];
    }
    
    /**
    * @author Bartek Dudziak
    * @date 28/11/2011
    * @param Id Requested multicultural calendar Id
    * @description Get a multicultural for requested ID
    * @return Calendar__c Requested multicultural Item.
    */
    public static Calendar__c getMulticulturalCalendarItem(Id calendarId, Set<String> themes){
        Set<ID> ids = getCalendarBrands(themes);   
        return [
            SELECT Id, name, sales_channel__c, description__c, description_content_description__r.Content_Version_Id__c,
                description_content_description__r.filetype__c, start_date__c, end_date__c , background_color__c, Logo_Image_Small__r.content_id__c,
                Logo_Image_Large__r.content_id__c, text_color__c, classification__c        
                FROM Calendar__c
                WHERE recordtype.name =: Constant.MULTICULTURAL 
                    AND Archive__c = false
                    AND ID = :calendarId
                    AND ID in :ids
        ];
    }
 /**
 ** Content Requests
 **/
    /**
    * @author Denise Bacher
    * @date 27/07/2011
    * @description Get the ContentDocument IDs for content related to the all brands
    * @return Set<ID> A list of content ids related to all brands
    */
    public static Set<ID> getAllContentBrandIDs(){

            List<ContentBrand__c> contentBrandIDs = [
                SELECT Content_Description__r.Content_ID__c
                    FROM ContentBrand__c 
                    WHERE Brand__c in :getAllBrands()
            ];
            
            allContentIDs = new Set<ID>();
            for(ContentBrand__c c : contentBrandIDs){
                allContentIDs.add(c.Content_Description__r.Content_ID__c);
            }

        return allContentIDs;
    }
    
    public static Set<ID> getAllContentBrandIDs(String division){

            List<ContentBrand__c> contentBrandIDs = [
                SELECT Content_Description__r.Content_ID__c
                    FROM ContentBrand__c 
                    WHERE (Content_Description__c in (select Content_Description__c from Content_Property__c where category__c = :division))
                          and Brand__c in :getAllBrands()
            ];
            
            allContentIDs = new Set<ID>();
            for(ContentBrand__c c : contentBrandIDs){
                allContentIDs.add(c.Content_Description__r.Content_ID__c);
            }

        return allContentIDs;
    }
         
    /**
    * @author Denise Bacher
    * @date 27/07/2011
    * @param currentBrand Currently selected brand ID
    * @description Get the ContentDocument IDs for content related to the current brand
    * @return Set<ID> A list of content ids related to this brand
    */
    public static Set<ID> getContentBrandIDs(ID currentBrand){
        list<ID> currentBrandIdList = new list<ID>();
        currentBrandIdList.add(currentBrand);
        return getContentBrandIDs(currentBrandIdList);
    }
    
    public static Set<ID> getContentBrandIDs(ID currentBrand, string division){
        list<ID> currentBrandIdList = new list<ID>();
        currentBrandIdList.add(currentBrand);
        return getContentBrandIDs(currentBrandIdList,division, false);
    }
    
    /**
    * @author Bartosz Dudziak
    * @date 18/10/2011
    * @param currentBrand Currently selected brand IDs
    * @description Get the ContentDocument IDs for content related to the current brand
    * @return Set<ID> A list of content ids related to this brand
    */
    public static Set<ID> getContentBrandIDs(list<ID> currentBrand){
        
            List<ContentBrand__c> notinq = [select Content_Description__c from ContentBrand__c where Brand__c not IN :currentBrand  and (Brand__r.diageo_direct_visible__c = true and Brand__r.Classification__c = :getSectionTheme())];
            List<Id> notin = new List<Id>();

            for(ContentBrand__c cb : notinq) {
                notin.add(cb.content_description__c);
            }
        
            List<ContentBrand__c> contentBrandIDs = [
                SELECT Content_Description__r.Content_ID__c 
                    FROM ContentBrand__c
                    WHERE (
                            Brand__c IN :currentBrand and brand__c in :getAccBrandIds()
                        )
                        and Content_Description__c not IN :notin
                        and (Brand__r.diageo_direct_visible__c = true and Brand__r.Classification__c = :getSectionTheme())
            ];
            brandContentIDs = new Set<ID>();
            for(ContentBrand__c c : contentBrandIDs){
                brandContentIDs.add(c.Content_Description__r.Content_ID__c);
            }

        return brandContentIDs;
    }   
     
    public static Set<ID> getContentBrandIDs(list<ID> currentBrand, string division, Boolean isFiltering){
        system.debug('=============currentBrand============'+currentBrand);
        system.debug('=============division============'+division);
        system.debug('=============isFiltering============'+isFiltering);                
        if(!isFiltering){
            Brand__c[] childBrands = [
                SELECT id 
                    FROM Brand__c 
                    WHERE (parent_brand__c in :currentBrand)
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                        and id in :getAccBrandIds()
            ];
            system.debug('=============childBrands ============'+childBrands );                
            set<Id> childIds = new set<Id>();
            for (Brand__c brand : childBrands) {
                childIds.add(brand.id);
            }
            system.debug('=============childIds============'+childIds); 
            List<ContentBrand__c> notinq = [select Content_Description__c from ContentBrand__c where Brand__c not IN :getAccBrandIds() and Brand__c not IN :childBrands and (Brand__r.diageo_direct_visible__c = true and Brand__r.Classification__c = :getSectionTheme())];
            system.debug('=============notinq ============'+notinq ); 
            List<Id> notin = new List<Id>();
            for(ContentBrand__c cb : notinq) {
                notin.add(cb.content_description__c);
            }
            system.debug('=============notin============'+notin); 
            system.debug('=============getAccBrandIds()============'+getAccBrandIds()); 
            List<ContentBrand__c> contentBrandIDs = [
                SELECT Content_Description__r.Content_ID__c 
                FROM ContentBrand__c
                WHERE (Content_Description__c in (select Content_Description__c from Content_Property__c where category__c = :division))
                    and (
                        (Brand__c IN :currentBrand or brand__c in :childIds) and brand__c in :getAccBrandIds()
                    )
                    and Content_Description__c not IN :notin
                    and (Brand__r.diageo_direct_visible__c = true and Brand__r.Classification__c = :getSectionTheme())
            ];
            system.debug('=============contentBrandIDs ============'+contentBrandIDs ); 
            brandContentIDs = new Set<ID>();
            for(ContentBrand__c c : contentBrandIDs){
                brandContentIDs.add(c.Content_Description__r.Content_ID__c);
            }
            system.debug('=============brandContentIDs============'+brandContentIDs); 
            return brandContentIDs;
        } else {
            Brand__c[] childBrands = [
                SELECT id 
                    FROM Brand__c 
                    WHERE (parent_brand__c in :currentBrand)
                        and (diageo_direct_visible__c = true and Classification__c = :getSectionTheme())
                        and id in :getAccBrandIds()
            ];
            system.debug('=============childBrands ============'+childBrands );                
            set<Id> childIds = new set<Id>();
            for (Brand__c brand : childBrands) {
                childIds.add(brand.id);
            }
            system.debug('=============childIds============'+childIds);  
            List<ContentBrand__c> notinq = [select Content_Description__c from ContentBrand__c where Brand__c not IN :getAccBrandIds() and Brand__c not IN :childBrands and (Brand__r.diageo_direct_visible__c = true and Brand__r.Classification__c = :getSectionTheme())];
            system.debug('=============notinq ============'+notinq ); 
            List<Id> notin = new List<Id>();
            for(ContentBrand__c cb : notinq) {
                notin.add(cb.content_description__c);
            }
            system.debug('=============notin============'+notin); 
            system.debug('=============getAccBrandIds()============'+getAccBrandIds()); 
            List<ContentBrand__c> contentBrandIDs = [
                SELECT Content_Description__r.Content_ID__c 
                FROM ContentBrand__c
                WHERE (Content_Description__c in (select Content_Description__c from Content_Property__c where category__c = :division))
                    and (
                        (Brand__c IN :currentBrand or brand__c in :childIds) and brand__c in :getAccBrandIds()
                    )
                    and Content_Description__c not IN :notin
                    and (Brand__r.diageo_direct_visible__c = true and Brand__r.Classification__c = :getSectionTheme())
            ];
            system.debug('=============contentBrandIDs ============'+contentBrandIDs ); 
            brandContentIDs = new Set<ID>();
            for(ContentBrand__c c : contentBrandIDs){
                brandContentIDs.add(c.Content_Description__r.Content_ID__c);
            }
            system.debug('=============brandContentIDs============'+brandContentIDs); 
            return brandContentIDs;
        }
    }     
    
    /**
    * @author Denise Bacher
    * @date 27/07/2011
    * @param currentBrand Currently selected brand ID
    * @description Get the content related to this brand
    * @return List<ContentVersion> A list of all content related to this brand
    */
    public static List<ContentVersion> getBrandContent(ID currentBrand){
        if(!getAccBrandIds().contains(currentBrand))
            return new List<ContentVersion>();
            
        //if(brandContent==null){
            brandContent = [
                SELECT Id, title, description, filetype, Content_Description__r.Content_ID__c, OwnerId
                    FROM ContentVersion
                    WHERE ContentDocumentId = :getContentBrandIDs(currentBrand) 
                        AND IsLatest = true
            ];
        //}
        
        return brandContent;
    }
    
 /**
 ** FAQ Requests
 **/
      /**
    * @author Denise Bacher
    * @date 10/08/2011
    * @description Get all FAQ
    * @return List<FAQ__c> A list of all FAQ
    */
    public static List<FAQ__c> getFAQs(){
        return [
            SELECT Id, Question__c, Answer__c
                FROM FAQ__c
        ];
    }
    
/**
 ** Link Requests
 **/
 
     /**
    * @author Denise Bacher
    * @date 10/08/2011
    * @description Get Facebook Links
    * @return List<Hyperlink__c> A list of facebook related links
    */
    public static List<Hyperlink__c> getFacebookLinks(){
        return [
            SELECT URL__c, Name
                FROM Hyperlink__c 
                WHERE Category__c = 'Facebook'
        ];
    }
    
    /**
    * @author Denise Bacher
    * @date 10/08/2011
    * @description Get Brand Page Links
    * @return List<Hyperlink__c> A list of Brand Page related links
    */
    public static List<Hyperlink__c> getBrandLinks(){
        return [
            SELECT URL__c, Name 
                FROM Hyperlink__c 
                WHERE Category__c = 'Brand'
        ];
    }

    /**
    * @author Denise Bacher
    * @date 29/08/2011
    * @description Get Industry Related Links
    * @return List<Hyperlink__c> A list of Industry Related links
    */
    public static List<Hyperlink__c> getIndustryLinks(){
        return [
            SELECT URL__c, Name 
                FROM Hyperlink__c 
                WHERE Category__c = 'Industry'
        ];
    }

/**
 ** Case Requests
 **/
 
     /**
    * @author Denise Bacher
    * @date 30/08/2011
    * @param c The Case to insert
    * @description Insert a new case for a user
    * @return Boolean Returns true if insert was successful
    */
    public static Boolean insertUserCases(Case c){
        if(getAID() == null)
            return false;
        else {
            try {
                c.AccountId = Service_API.getAID();
                c.ContactId = Service_API.getCID();
                c.Origin = 'Web';
                        
                // Specify DML options to ensure the assignment rules are executed
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule = true;
                c.setOptions(dmlOpts);
    
                // Insert the case
                insert c;
                return true;
            }
            catch (Exception e) {
                return false;
            }
        }
    }
    
    /**
    * @author Denise Bacher
    * @update Bartek Dudziak
    * @date 29/08/2011
    * @param caseStatus The Case status
    * @description Get all open cases for user
    * @return List<Case> A list of Cases with requested status
    */
    public static List<Case> getUserCases(String caseStatus){
        if(caseStatus != '' && caseStatus != null){
            return [
                SELECT Id, CaseNumber, status, priority, type, subject, description, LastModifiedDate
                    FROM Case
                    WHERE status = :caseStatus
                        AND ContactID = :getCID()
                    ORDER BY LastModifiedDate DESC
            ];
        } else {
            return [
                SELECT Id, CaseNumber, status, priority, type, subject, description, LastModifiedDate
                    FROM Case
                    WHERE ContactID = :getCID()
                    ORDER BY LastModifiedDate DESC
            ];      
        }
    }
    
    /**
    * @Created Appirio Jaipur [Jai Gupta] 
    * @date 27/11/2012
    * @param caseStatus The Case status
    * @description Get all cases acc to status for user
    * @return List<Case> A list of Cases with requested status
    */
    public static List<Case> getCurrentUserCases(String caseStatus) {
        if(caseStatus != '' && caseStatus != null){
            return [
                SELECT Id, CaseNumber, status, priority, type, subject, description, LastModifiedDate
                    FROM Case
                    WHERE status = :caseStatus
                        AND CreatedById = :getUID()
                    ORDER BY LastModifiedDate DESC
            ];
        } else {
            return [
                SELECT Id, CaseNumber, status, priority, type, subject, description, LastModifiedDate
                    FROM Case
                    WHERE CreatedById = :getUID()
                    ORDER BY LastModifiedDate DESC
            ];      
        }
    }
    
    /**
    * @author Bartek Dudziak
    * @date 01/09/2011
    * @param caseId The case ID
    * @description Get case for requested ID
    * @return Case 
    */
    public static Case getCase(Id caseId){
        return [
            SELECT Id, CaseNumber, status, priority, type, subject, description, LastModifiedDate
                FROM Case
                WHERE Id = :caseId
                    AND ContactID = :getCID()
                LIMIT 1
        ];
    }    
    
     /**
    * @Created Appirio Jaipur [Jai Gupta] 
    * @date 27/11/2012
    * @param caseId The case ID
    * @description Get case for requested ID
    * @return Case 
    */
    public static Case getCaseModified(Id caseId){
        return [
            SELECT Id, CaseNumber, status, priority, type, subject, description, LastModifiedDate
                FROM Case
                WHERE Id = :caseId
                    AND CreatedById = :getUID()
                LIMIT 1
        ];
    }
    
    /**
    * @author Bartek Dudziak
    * @date 31/08/2011
    * @param c The Case to update    
    * @description Update case
    * @return Boolean Returns true if update was successful
    */
    public static Boolean updateUserCases(Case c){
        try {
            // Specify DML options to ensure the assignment rules are executed
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            c.setOptions(dmlOpts);
    
            // Update the case
            update c;
            return true;
        }
        catch (Exception e) {
            return false;
        }
    }
    
    /**
    * @author Bartek Dudziak
    * @date 31/08/2011
    * @description Get all comments connected with requested case.
    * @return List<CaseComment> A list of comment cases
    */
    public static List<CaseComment> getCaseComment(Case c){
        return [
            SELECT Id, CommentBody, ParentId, LastModifiedDate, LastModifiedBy.name
                FROM CaseComment
                WHERE ParentId = :c.Id
        ];
    }

    /**
    * @author Bartek Dudziak
    * @date 31/08/2011
    * @param cc The CaseComment to insert
    * @description Insert a new case comment
    * @return Boolean Returns true if insert was successful
    */
    public static Boolean insertCaseComment(CaseComment cc){
        try {
            // Specify DML options to ensure the assignment rules are executed
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            cc.setOptions(dmlOpts);

            insert cc;
            return true;
        }
        catch (Exception e) {
            return false;
        }
    }
     /**
    * @author Bartek Dudziak
    * @date 15/09/2011
    * @param c The Case to insert
    * @description Insert a new case
    * @return Id Returns Id if insert was successful, else return null
    */
    public static Id insertCase(Case c){
        try {
            // Specify DML options to ensure the assignment rules are executed
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            c.setOptions(dmlOpts);

            insert c;
            return c.id;
        }
        catch (Exception e) {
            return null;
        }
    }    
    // Changes done by Jai Gupta [Appirio Jaipur] for case #00003417 on Dec 07,2012
    public static void insertAttachment(Attachment a){
        insert a ;
    }
/**
 ** News & Articles Requests
 **/    

    /**
    * @author Bartek Dudziak
    * @date 01/09/2011
    * @description Get all articles & news
    * @return List<NewsAndArticles__c> A list of articles & news
    */
    public static List<NewsAndArticles__c> getNewsAndArticles(){
          return [
            SELECT Id, Title__c, BodyText__c, CreatedDate, LastModifiedDate 
                FROM NewsAndArticles__c WHERE Classification__c includes (:getSectionTheme())
                ORDER BY CreatedDate DESC
            ];
    }
    
    /**
    * @author Bartek Dudziak
    * @date 01/09/2011
    * @description Get article for requested id
    * @param articleId Requested article id
    * @return NewsAndArticles__c Articles or news
    */
    public static NewsAndArticles__c getArticle(Id articleId){
        return [
            SELECT Id, Title__c, BodyText__c, CreatedDate, LastModifiedDate
                FROM NewsAndArticles__c
                WHERE Id = :articleId
        ];
    }
    
/*************************
 * Performance Managment *
 *************************/
    
    /**
    * @author Bartek Dudziak
    * @date 24/10/2011
    * @description Get the value list for requested SelectName
    * @return List<SelectOption> List of options
    */
    public static List<SelectValues__c> getSelectValues(String SelectName, String ParentSelectValue){
        List<SelectValues__c> values = new List<SelectValues__c>();
        List<SelectValues__c> optAll = SelectValues__c.getall().values(); 
        
        for(SelectValues__c currentOption: optAll){
            if(currentOption.SelectName__c == SelectName){
                if(ParentSelectValue != null){
                    if(currentOption.ParentSelectValue__c == ParentSelectValue){
                        values.add(currentOption);
                    }              
                } else {
                    values.add(currentOption);
                }
            }
        }
        return values;
    }
   

    /**
    * @author Bartosz Dudziak
    * @date 25/10/2011
    * @description Get the folders tree.
    * @return List<Folder> A list of Folders
    */
    public static List<Folder__c> getDocumentFolders(String section, Id orgUnit, Boolean isInternal){
       list<Id> orgUnits = new list<id>();
       orgunits.addAll(searchDivisionAndRegionByOUId(orgUnit, new set<id>()));
       if(orgUnits.size()==2) {
            return [
                SELECT Id, Name, Parent_Folder__c, Parent_Folder__r.Name, Page_Section__c, Allow_Add_Comment__c, Allow_File_Upload__c, is_header__c
                    FROM Folder__c 
                    WHERE (OrgUnits__c includes (:orgUnits.get(0)) OR OrgUnits__c includes (:orgUnits.get(1))) 
                        AND Page_Section__c =: section
                        AND (Only_For_Internal_User__c = false OR Only_For_Internal_User__c =: isInternal)
                        and Classification__c includes (:getSectionTheme())
                    ORDER BY Parent_Folder__c, Order__c, Name
                ];
       } else if(orgUnits.size()==1) {
            return [
                SELECT Id, Name, Parent_Folder__c, Parent_Folder__r.Name, Page_Section__c, Allow_Add_Comment__c, Allow_File_Upload__c, is_header__c
                    FROM Folder__c 
                    WHERE OrgUnits__c includes (:orgUnits.get(0)) 
                        AND Page_Section__c =: section
                        AND (Only_For_Internal_User__c = false OR Only_For_Internal_User__c =: isInternal)
                        and Classification__c includes (:getSectionTheme())
                    ORDER BY Parent_Folder__c, Order__c, Name
                ];
       } else {
            throw new Service_APIException('Misconfigured organizational unit hierarchy');
       }
    }

    /**
    * @author Bartosz Dudziak
    * @date 25/10/2011
    * @description Get the folders tree.
    * @return List<Folder> A list of Folders
    */
    public static List<Folder__c> getDocumentFoldersForAdmin(String section, List<Id> organizationalUnits, Boolean isInternal){
        String query = 'SELECT Id, Name, Parent_Folder__c, Parent_Folder__r.Name, OrgUnits__c, Page_Section__c, Allow_Add_Comment__c, Allow_File_Upload__c, is_header__c FROM Folder__c WHERE ';
        String glue = '';
        string listOu = '';
        set<id> organizationalUnitsWithChildren = getAllChildOU(organizationalUnits);
        for(Id id : organizationalUnitsWithChildren){
            listOu += glue + '\''+id+'\'';
            glue = ',';
        }
        if(!organizationalUnits.isEmpty()){
            query += 'OrgUnits__c includes ('+listOu+') AND ';
        }
        query += ' Page_Section__c =: section ORDER BY Parent_Folder__c, Order__c, Name';
        return Database.query(query);
    }

    /**
    * @author Bartosz Dudziak
    * @date 25/10/2011
    * @description Get the folders tree.
    * @return List<Folder> A list of Folders
    */
    public static List<Folder__c> getDocumentFolders(String section, Id orgUnit, Boolean isInternal, String distributorId){
       list<Id> orgUnits = new list<id>();
       orgunits.addAll(searchDivisionAndRegionByOUId(orgUnit, new set<id>()));
       if(orgUnits.size()==2) {
            return [
                SELECT Id, Name, Parent_Folder__c, Parent_Folder__r.Name, Page_Section__c, Allow_Add_Comment__c, Allow_File_Upload__c, is_header__c
                    FROM Folder__c 
                    WHERE (OrgUnits__c includes (:orgUnits.get(0)) OR OrgUnits__c includes (:orgUnits.get(1))) 
                        AND Page_Section__c =: section
                        AND (Only_For_Internal_User__c = false OR Only_For_Internal_User__c =: isInternal)
                        AND (Distributors__c includes (:distributorId) or Distributors__c = null)
                        AND Classification__c includes (:getSectionTheme())
                    ORDER BY Parent_Folder__c, Order__c, Name
                ];
       } else if(orgUnits.size()==1) {
            return [
                SELECT Id, Name, Parent_Folder__c, Parent_Folder__r.Name, Page_Section__c, Allow_Add_Comment__c, Allow_File_Upload__c, is_header__c
                    FROM Folder__c 
                    WHERE OrgUnits__c includes (:orgUnits.get(0)) 
                        AND Page_Section__c =: section
                        AND (Only_For_Internal_User__c = false OR Only_For_Internal_User__c =: isInternal)
                        AND (Distributors__c includes (:distributorId) or Distributors__c = null)
                        AND Classification__c includes (:getSectionTheme())
                    ORDER BY Parent_Folder__c, Order__c, Name
                ];
       } else {
            throw new Service_APIException('Misconfigured organizational unit hierarchy');
       } 
    }


    /**
    * @author Wojciech Migas
    * @date 11/07/2011
    * @description Get the documents tree.
    * @return List<Folder> A list of Folders
    */
    public static List<Folder__c> getPlanningFolders(){
        return [
            SELECT Id, Name, Parent_Folder__c, Parent_Folder__r.Name, Layout_Type__c, Page_Section__c, Allow_Add_Comment__c, Allow_File_Upload__c, Filter_By_Brand__c, Filter_By_Time__c, is_header__c
                FROM Folder__c 
                WHERE Page_Section__c =: Constant.PLANNING and Classification__c includes (:getSectionTheme())
                ORDER BY Parent_Folder__c, Order__c, Name
        ];
    }

    /**
    * @author Wojciech Migas
    * @date 11/07/2011
    * @description Get the documents tree.
    * @return List<Folder> A list of Folders
    */
    public static List<Folder__c> getPlanningFoldersForAdmin(){
        return [
            SELECT Id, Name, Parent_Folder__c, Parent_Folder__r.Name, Layout_Type__c, Page_Section__c, Allow_Add_Comment__c, Allow_File_Upload__c, Filter_By_Brand__c, Filter_By_Time__c, is_header__c
                FROM Folder__c 
                WHERE Page_Section__c =: Constant.PLANNING 
                ORDER BY Parent_Folder__c, Order__c, Name
        ];
    }

    /**
    * @author Bartosz Dudziak
    * @date 27/10/2011
    * @description Get the documents.
    * @return List<Folder> A list of Files.
    */
    public static List<File__c> getFolderFiles(String section, String distributor, String division, Boolean isInternal){
        List<AccountBrand__c> ab = [select Brand__c from AccountBrand__c where Brand__r.diageo_direct_visible__c = true and Brand__r.Classification__c = :getSectionTheme() and id in :Service_API.getAIDs()];
        Set<Id> ids = new Set<Id>();
        for(AccountBrand__c a : ab){
            ids.add(a.Brand__c);
        }
        List<File__c> files = new List<File__c>();
        List<File__c> toReturn = new List<File__c>();
        if (isInternal) {
            files = [
              SELECT id, Name, Content_Version_Id__c, Description__c, filesize__c, filetype__c, Title__c, Folders__c, video_id__c, Brands__c
                  FROM File__c
                  WHERE
                      Page_Section__c =: section
                      AND (Distributors__c INCLUDES (:distributor) OR Division_Access__c =: division )
                      AND Classification__c includes (:Service_API.getSectionTheme())
                  ORDER BY Description__c
            ];
        } else {
            files = [
              SELECT id, Name, Content_Version_Id__c, Description__c, filesize__c, filetype__c, Title__c, Folders__c, video_id__c, Brands__c
                  FROM File__c
                  WHERE
                      Page_Section__c =: section
                      AND (
                           (Distributors__c INCLUDES (:distributor) OR Division_Access__c =: division ) 
                            AND Only_For_Internal_User__c = false
                          )
                      AND Classification__c includes (:Service_API.getSectionTheme())
                  ORDER BY Description__c
            ];
        }
        for(File__c f : files){
            if(f.Brands__c!=null){
                for(String id : f.Brands__c.split(';')){
                    if(ids.contains(id)){
                        toReturn.add(f);
                        break;
                    }
                }
            } else {
                toReturn.add(f);
            }
        }
        return toReturn;
    }

   /**
    * @author Maciej Krol
    * @date 07/10/2012
    * @description Get accounts 
    * @return String The list of accounts
    */
    public static List<Account> getUserAccounts(){
        List<Account> accounts = new List<Account>();
        accounts = [
                    SELECT id, name,
                        Spirits_Hierarchy__c, Spirits_Hierarchy__r.Id, Spirits_Hierarchy__r.Label__c, Spirits_Hierarchy__r.Name, Spirits_Hierarchy__r.Type__c,
                        Wine_Hierarchy__c, Wine_Hierarchy__r.Id, Wine_Hierarchy__r.Label__c, Wine_Hierarchy__r.Name, Wine_Hierarchy__r.Type__c                  
                    FROM Account
                    WHERE Id in:getAIDs() and Account.RecordTypeId in :Service_API.getAccountRecordTypeIds()];
        return accounts;
    }
    
    /**
    * @author Maciej Krol
    * @date 07/17/2012
    * @description Get OU by parent
    * @return List<Organizational_Unit__c> List of options
    */    
    public static List<Organizational_Unit__c> getOrgUnitByParent(Id parentId){
        List<Organizational_Unit__c> ouList = [ SELECT id, Name, Parent__r.Id, Type__c, Label__c FROM Organizational_Unit__c WHERE type__c = :Service_API.getSectionTheme() and Parent__r.Id =:parentId ORDER BY name];
        return ouList;      
    }

    /**
    * @author Maciej Krol
    * @date 07/17/2012
    * @description Get OU by parent
    * @return List<Organizational_Unit__c> List of options
    */    
    public static List<Organizational_Unit__c> getOrgUnitByParent(Id parentId, set<id> ouids){
        List<Organizational_Unit__c> ouList = [ SELECT id, Parent__r.Id, Name, Type__c, Label__c FROM Organizational_Unit__c WHERE type__c = :Service_API.getSectionTheme() and Parent__r.Id =:parentId and id in :ouids ORDER BY name];
        return ouList;      
    }
        
    /**
    * @author Maciej Krol
    * @date 07/17/2012
    * @description Get OU by parent
    * @return List<Organizational_Unit__c> List of options
    */    
    public static List<Organizational_Unit__c> getOrgUnitByParentForAdmin(Id parentId, String thm){
        List<Organizational_Unit__c> ouList = [ SELECT id, Name, Parent__r.Id, Type__c, Label__c FROM Organizational_Unit__c WHERE Parent__r.Id =:parentId and type__c = :thm ORDER BY name];
        return ouList;      
    }

    /**
    * @author Maciej Krol
    * @date 07/17/2012
    * @description Get OU by parent
    * @return List<Organizational_Unit__c> List of options
    */    
    public static List<Organizational_Unit__c> getOrgUnitByParentForAdmin(Id parentId){
        List<Organizational_Unit__c> ouList = [ SELECT id, Name, Parent__r.Id, Type__c, Label__c FROM Organizational_Unit__c WHERE Parent__r.Id =:parentId ORDER BY name];
        return ouList;      
    }

    /**
    * @author Maciej Krol
    * @date 07/17/2012
    * @description Get OU by parent
    * @return List<Organizational_Unit__c> List of options
    */    
    public static List<Organizational_Unit__c> getOrgUnitByParentForAdmin(Id parentId, set<id> ouids){
        List<Organizational_Unit__c> ouList = [ SELECT id, Parent__r.Id, Name, Type__c, Label__c FROM Organizational_Unit__c WHERE Parent__r.Id =:parentId and id in :ouids ORDER BY name];
        return ouList;      
    }
        
    /**
    * @author Bartosz Dudziak
    * @date 03/11/2011
    * @description Get list of folder comments.
    * @return List<Folder> A list of comments.
    */
    public static List<Folder_Comment__c> getFolderComments(String distributor, String folder){
          return [
              SELECT Id, Name, Comment_Body__c, Distributor_Access__c, Distributor_Name__r.Name, File__r.Description__c, File__r.Content_Version_Id__c, Folder__c, LastModifiedDate, LastModifiedBy.name 
                FROM Folder_Comment__c
                WHERE Distributor_Access__c =: distributor 
                    AND Folder__c =: folder and Classification__c = :getSectionTheme()
                ORDER BY LastModifiedDate DESC
                LIMIT 100
        ];
    }
    
    /**
    * @author Bartosz Dudziak
    * @date 10/05/2013
    * @description Get list of file comments.
    * @return List<Folder_Comment__c> A list of comments.
    */
    public static List<Folder_Comment__c> getFileComments(String distributor, String folder, String file){
          return [
              SELECT Id, Name, Comment_Body__c, Distributor_Access__c, Distributor_Name__r.Name, File__r.Description__c, File__r.Content_Version_Id__c, Folder__c, LastModifiedDate, LastModifiedBy.name, OwnerID 
                FROM Folder_Comment__c
                WHERE Distributor_Access__c =: distributor 
                    AND Folder__c =: folder AND Classification__c = :getSectionTheme()
                    AND File__c = :file
                ORDER BY LastModifiedDate DESC
        ];
    }
    /**
    * @author Bartosz Dudziak
    * @date 10/05/2013
    * @description Get file comment.
    * @return Folder_Comment__c file comment.
    */
    public static Folder_Comment__c getFileComment(String distributor, String folder, String file, String comment){
          return [
              SELECT Id, Name, Comment_Body__c, Distributor_Access__c, Distributor_Name__r.Name, File__r.Description__c, File__r.Content_Version_Id__c, Folder__c, LastModifiedDate, LastModifiedBy.name, OwnerID 
                FROM Folder_Comment__c
                WHERE Distributor_Access__c =: distributor 
                    AND Folder__c =: folder AND Classification__c = :getSectionTheme()
                    AND File__c = :file
                    AND id = :comment
                LIMIT 1
        ];
    }
    
    /**
    * @author Bartosz Dudziak
    * @date 24/11/2011
    * @description Get child folders.
    * @return List<Folder> A list of Folders
    */
    public static List<Folder__c> getChildFolders(Id parentFolderId){
        return [
            SELECT Id, Name, Parent_Folder__c, Parent_Folder__r.Name, Layout_Type__c, Page_Section__c, Allow_Add_Comment__c, Allow_File_Upload__c, Filter_By_Brand__c, Filter_By_Time__c, is_header__c
                FROM Folder__c
                where Parent_Folder__c = :parentFolderId and Classification__c  includes ( :getSectionTheme() )
                ORDER BY Order__c, Name
        ];
    }

    /**
    * @author Wojciech Migas
    * @date 18/07/2012
    * @description Get Division name by ditributor id
    * @return String Division name
    */
    public static string searchDivisionByDistributorId(Id distributorId) {
        try {
            String accountRecordTypeIdsString = '';
            String glue = '';
            for (String value : Service_API.getAccountRecordTypeIds()) {         
                accountRecordTypeIdsString += glue + '\''+value+'\' ';
                glue = ',';
            }
            if(accountRecordTypeIdsString == '' || Service_API.getSectionTheme() == '' || Service_API.getSectionTheme() == null){
                return '';
            }
            sObject a = database.query(
                      ' SELECT ' +  
                    + ' '+Service_API.getSectionTheme()+'_Hierarchy__r.Label__c,                               '+Service_API.getSectionTheme()+'_Hierarchy__r.Name, ' +
                    + ' '+Service_API.getSectionTheme()+'_Hierarchy__r.Parent__r.Label__c,                     '+Service_API.getSectionTheme()+'_Hierarchy__r.Parent__r.Name, ' +
                    + ' '+Service_API.getSectionTheme()+'_Hierarchy__r.Parent__r.Parent__r.Label__c,           '+Service_API.getSectionTheme()+'_Hierarchy__r.Parent__r.Parent__r.Name, ' +
                    + ' '+Service_API.getSectionTheme()+'_Hierarchy__r.Parent__r.Parent__r.Parent__r.Label__c, '+Service_API.getSectionTheme()+'_Hierarchy__r.Parent__r.Parent__r.Parent__r.Name ' +
                    + ' FROM Account ' +
                    + ' WHERE Id =: distributorId and Account.RecordTypeId in ('+accountRecordTypeIdsString+') ' +
                    + ' LIMIT 1 '
            );
            Organizational_Unit__c ouCurrentTheme = (Organizational_Unit__c)a.getSObject(Service_API.getSectionTheme()+'_Hierarchy__r');
            if(ouCurrentTheme != null){
                if (ouCurrentTheme.Parent__r.Parent__r.Parent__r != null) {
                    if(ouCurrentTheme.Parent__r.Parent__r.Parent__r.Label__c == 'Division') {
                        return ouCurrentTheme.Parent__r.Parent__r.Parent__r.Name;
                    } else {
                        return Service_API.searchDivisionByOUId(ouCurrentTheme.Parent__r.Parent__r.Parent__r.Id);
                    }
                } else if (ouCurrentTheme.Parent__r.Parent__r != null && ouCurrentTheme.Parent__r.Parent__r.Label__c == 'Division') {
                    return ouCurrentTheme.Parent__r.Parent__r.Name;
                } else if (ouCurrentTheme.Parent__r != null && ouCurrentTheme.Parent__r.Label__c == 'Division') {
                    return ouCurrentTheme.Parent__r.Name;
                } else if (ouCurrentTheme != null && ouCurrentTheme.Label__c == 'Division') {
                    return ouCurrentTheme.Name;
                }
            }
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find division.'));
        }

        throw new Service_APIException('Invalid organizational unit hierarchy. There is no division');
    }
    
    /**
    * @author Wojciech Migas
    * @date 18/07/2012
    * @description Get Organizational Unit Ids by ditributor ids
    * @return set<id> Origanizational unit ids
    */
    public static list<id> searchOrganizationalUnitIds(set<Id> distributorIds) {
        list<id> result = new list<id>();
        try {        
            String accountRecordTypeIdsString = '';
            String glue = '';
            for (String value : Service_API.getAccountRecordTypeIds()) {         
                accountRecordTypeIdsString += glue + '\''+value+'\' ';
                glue = ',';
            }       
        
            String distributorIdsString = '';
            glue = '';
            for (String value : distributorIds) {         
                distributorIdsString += glue + '\''+value+'\' ';
                glue = ',';
            }
            
            if(accountRecordTypeIdsString == '' || distributorIdsString == '' || Service_API.getSectionTheme() == '' || Service_API.getSectionTheme() == null){
                return result;
            }
            
            list<sObject> ac = database.query(
                 ' SELECT '+ 
                +' '+Service_API.getSectionTheme()+'_Hierarchy__c, '+
                +' '+Service_API.getSectionTheme()+'_Hierarchy__r.Parent__c, '+
                +' '+Service_API.getSectionTheme()+'_Hierarchy__r.Parent__r.Parent__c, '+
                +' '+Service_API.getSectionTheme()+'_Hierarchy__r.Parent__r.Parent__r.Parent__c '+
                +' FROM Account  '+
                +' WHERE id in ('+distributorIdsString+') and Account.RecordTypeId in ('+accountRecordTypeIdsString+') '
            );
            
            for(sObject a : ac){
                Organizational_Unit__c ouCurrentTheme = (Organizational_Unit__c)a.getSObject(Service_API.getSectionTheme()+'_Hierarchy__r');
                if(ouCurrentTheme == null){
                    continue;
                }
                
                if (ouCurrentTheme.Parent__r.Parent__r.Parent__c != null) {
                    set<id> tmp = new set<id>(result);
                    if (!tmp.contains(ouCurrentTheme.Parent__r.Parent__r.Parent__c)) {
                        result = Service_API.searchOrganizationalUnitIdsRecursion(ouCurrentTheme.Parent__r.Parent__r.Parent__c, result);
                    }
                }
                if (ouCurrentTheme.Parent__r.Parent__c != null) {
                    result.add(ouCurrentTheme.Parent__r.Parent__c);
                }
                if (ouCurrentTheme.Parent__c != null) {
                    result.add(ouCurrentTheme.Parent__c);
                }
                if (ouCurrentTheme != null) {
                    result.add(ouCurrentTheme.id);
                }
            } 
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find organizational unit.'));
        }

        return result;
    }

    /**
    * @author Wojciech Migas
    * @date 18/07/2012
    * @description Get Division name by organization id
    * @return String Division name
    */
    public static string searchDivisionByOUId(Id OrganizationalUnitId) {
        Organizational_Unit__c o = [
        SELECT 
            Name, Label__c,
            Parent__r.Label__c, Parent__r.Name,
            Parent__r.Parent__r.Label__c,                     Parent__r.Parent__r.Name,
            Parent__r.Parent__r.Parent__r.Label__c,           Parent__r.Parent__r.Parent__r.Name,
            Parent__r.Parent__r.Parent__r.Parent__r.Label__c, Parent__r.Parent__r.Parent__r.Parent__r.Name
            FROM  Organizational_Unit__c
            WHERE Id =:  OrganizationalUnitId
            LIMIT 1
        ];
    
        if (o.Parent__r.Parent__r.Parent__r.Parent__r != null) {
            if(o.Parent__r.Parent__r.Parent__r.Parent__r.Label__c == 'Division') {
                return o.Parent__r.Parent__r.Parent__r.Parent__r.Name;
            } else {
                return Service_API.searchDivisionByOUId(o.Parent__r.Parent__r.Parent__r.Parent__r.Id);
            }
        } else if (o.Parent__r.Parent__r.Parent__r != null && o.Parent__r.Parent__r.Parent__r.Label__c == 'Division') {
            return o.Parent__r.Parent__r.Parent__r.Name;
        } else if (o.Parent__r.Parent__r != null && o.Parent__r.Parent__r.Label__c == 'Division') {
            return o.Parent__r.Parent__r.Name;
        } else if (o.Parent__r != null && o.Parent__r.Label__c == 'Division') {
            return o.Parent__r.Name;
        } else if(o.Label__c == 'Division') {
            return o.Name;
        } 
        throw new Service_APIException('Invalid organizational unit hierarchy. There is no division');
    }

    /**
    * @author Wojciech Migas
    * @date 18/07/2012
    * @description Get Organizational Unit Ids by ditributor ids (recursion helper)
    * @return set<id> Origanizational unit ids
    */
    public static list<id> searchOrganizationalUnitIdsRecursion(Id OUId, list<id> result) {
        Organizational_Unit__c o = [
        SELECT 
            Id,
            Parent__c,
            Parent__r.Parent__c,
            Parent__r.Parent__r.Parent__c,
            Parent__r.Parent__r.Parent__r.Parent__c
            FROM Organizational_Unit__c
            WHERE Id =: OUId
            LIMIT 1
        ];
        
        if (o==null) {
            return result;
        }
        
        if (o.Parent__r.Parent__r.Parent__r.Parent__c != null) {
            set<id> tmp = new set<id>(result);
            if (!tmp.contains(o.Parent__r.Parent__r.Parent__r.Parent__c)) {
                result = Service_API.searchOrganizationalUnitIdsRecursion(o.Parent__r.Parent__r.Parent__r.Parent__c, result);
            }
        }
        if (o.Parent__r.Parent__r.Parent__c != null) {
            result.add(o.Parent__r.Parent__r.Parent__c);
        }
        if (o.Parent__r.Parent__c != null) {
            result.add(o.Parent__r.Parent__c);
        }
        if (o.Parent__c != null) {
            result.add(o.Parent__c);
        }

        result.add(o.Id);

        return result;
    }

    /**
    * @author Wojciech Migas
    * @date 18/07/2012
    * @description Get Division and Region Ids by organization id
    * @return String Division name
    */
    public static set<id> searchDivisionAndRegionByOUId(Id OrganizationalUnitId, set<id> res) {
        Organizational_Unit__c o = [
        SELECT 
            Label__c,
            Parent__r.Label__c, Parent__r.Name,
            Parent__r.Parent__r.Label__c,                     Parent__r.Parent__r.Name,
            Parent__r.Parent__r.Parent__r.Label__c,           Parent__r.Parent__r.Parent__r.Name,
            Parent__r.Parent__r.Parent__r.Parent__r.Label__c, Parent__r.Parent__r.Parent__r.Parent__r.Name
            FROM  Organizational_Unit__c
            WHERE Id =:  OrganizationalUnitId
            LIMIT 1
        ];
    
        if (o.Parent__r.Parent__r.Parent__r.Parent__r != null) {
            if(o.Parent__r.Parent__r.Parent__r.Parent__r.Label__c == 'Division' || o.Parent__r.Parent__r.Parent__r.Parent__r.Label__c == 'Region') {
                res = Service_API.searchDivisionAndRegionByOUId(o.Parent__r.Parent__r.Parent__r.Parent__r.Id, res);
                res.add(o.Parent__r.Parent__r.Parent__r.Parent__r.Id);
            }
        }
        if (o.Parent__r.Parent__r.Parent__r != null && (o.Parent__r.Parent__r.Parent__r.Label__c == 'Division' || o.Parent__r.Parent__r.Parent__r.Label__c == 'Region')) {
            res.add(o.Parent__r.Parent__r.Parent__r.Id);
        }
        if (o.Parent__r.Parent__r != null && (o.Parent__r.Parent__r.Label__c == 'Division' || o.Parent__r.Parent__r.Label__c == 'Region')) {
            res.add(o.Parent__r.Parent__r.Id);
        }
        if (o.Parent__r != null && (o.Parent__r.Label__c == 'Division' || o.Parent__r.Label__c == 'Region')) {
            res.add(o.Parent__r.Id);
        }
        if(o.Label__c == 'Division' || o.Label__c == 'Region') {
            res.add(o.Id);
        } 
        return res;
    }
    
    /**
    * @author Wojciech Migas
    * @date 20/07/2012
    * @description Return all child organizational unit ids
    * @return set<id> ids of childen organizational units
    */
    public static set<id> getAllChildOU(set<Id> parentIds){
        OUChildren = new set<id>();
        set<id> tmpParentIds = new set<id>();
        tmpParentIds.addAll(parentIds);
        getAllChildOUr(tmpParentIds);
        return OUChildren;
    }
    /**
    * @author Wojciech Migas
    * @date 20/07/2012
    * @description Return all child organizational unit ids
    * @return set<id> ids of childen organizational units
    */
    public static set<id> getAllChildOU(list<Id> parentIds){
        OUChildren = new set<id>();
        set<id> tmpParentIds = new set<id>();
        tmpParentIds.addAll(parentIds);
        getAllChildOUr(tmpParentIds);
        return OUChildren;
    }
    /**
    * @author Wojciech Migas
    * @date 20/07/2012
    * @description Recursion function which get all child organization unit ids
    */
    private static void getAllChildOUr(set<Id> parentIds){
        if (parentIds.size()==0) {
            return;
        }
        set<Id> oldParentIds;

        Organizational_Unit__c[] ts = [
        SELECT Id, 
            parent__c,
            parent__r.parent__c,
            parent__r.parent__r.parent__c,
            parent__r.parent__r.parent__r.parent__c
            FROM Organizational_Unit__c 
                WHERE id in: parentIds 
                    OR parent__c in: parentIds
                    OR parent__r.parent__c in: parentIds
                    OR parent__r.parent__r.parent__c in: parentIds
                    OR parent__r.parent__r.parent__r.parent__c in: parentIds
        ];

        oldParentIds = new set<id>(parentIds);
        parentIds.clear();
        for (Organizational_Unit__c t: ts) {
            OUChildren.add(t.Id);
            if (t.parent__r.parent__r.parent__r.parent__c != null && oldParentIds.contains(t.parent__r.parent__r.parent__r.parent__c) ) {
                parentIds.add(t.id);
            }
        }
        getAllChildOUr(parentIds);
    }
    
    // Start : Changes for US503/TA1011 : Comment All Blog Code - Basant
    // Start : Changes for US503/TA907 - Randy
    /**
    * @author Randy Wandell
    * @Story US503/TA907
    * @description It will return all Blogs and it's related lists filtered by current Theme and tags 
    */
       public static List<Blog__c> getBlogRecords(List<String> fromUrl, List<String> blogTags, String theme){
            String tempSiteTheme = siteTheme;
            siteTheme = theme;
            List<Blog__c> blogRecords = getBlogRecords(fromUrl, blogTags);
            siteTheme = tempSiteTheme;
            return blogRecords;
        }
       
    // Start : Changes for US503/TA907 - Basant
    /**
    * @author Basant Verma
    * @Story US503/TA907
    * @description It will return all Blogs and it's related lists filtered by current Theme and tags 
    */
    
    public static List<Blog__c> getBlogRecords(List<String> fromUrl, List<String> blogTags){
        String soql = 'Select Id, Name, AllowComments__c, Detail__c, EndDate__c, ' + 
            ' StartDate__c, Sub_Title__c, Summary__c, Theme__c, CreatedById, CreatedBy.Name, CreatedDate, ' + 
            ' (Select Id, Comment__c, CreatedById, CreatedBy.Name, CreatedDate From Comment__r Order By CreatedDate), ' + 
            ' (Select Id, Tag__c, Tag__r.Name From Blog2Tag__r), ' + 
            ' (Select Id, Brand__c, Brand__r.Name, Brand__r.Brand_Type__c From Blog2Brand__r) ' + 
            ' From Blog__c Where Theme__c = :siteTheme ';
        if(blogTags != null && blogTags.size() > 0){  
            soql += 'AND Id IN ( Select Blog__c From Blog2Tag__c Where ' +
                ' Tag__r.Tag__c IN :blogTags )'; 
        }
        soql += ' ORDER BY StartDate__c DESC, CreatedDate DESC';
        System.debug('================= SOQL : '+soql);
        System.debug('================= blogTags : '+blogTags);
        System.debug('================= siteTheme : '+siteTheme);
        List<Blog__c> blgList = (List<Blog__c>)Database.query(soql);
        
        return filterBlogsByBrandSecurity(blgList);
    }
   
    /*
		* @author Basant Verma
		* @Story US503/TA907
		* @description Filter Blogs By Brand Security 
		*/
    public static List<Blog__c> filterBlogsByBrandSecurity(List<Blog__c> blgList){
        // Below code check for Brand Security
        Map<String, Set<Id>> blogBrandSet = new Map<String, set<Id>>();
        for(Blog2Brand__c b : [Select Id, Brand__c, Blog__c 
                From Blog2Brand__c Where Blog__c IN :blgList]){
            if(!blogBrandSet.containsKey(b.Blog__c))
                blogBrandSet.put(b.Blog__c, new Set<Id>());
            blogBrandSet.get(b.Blog__c).add((ID)b.Brand__c);
        }
        
        Set<Id> accBrandIds = getAccBrandIds();
        List<Blog__c> blgWithB2bSecurity = new List<Blog__c>();
        for(Blog__c b : blgList){
            if(blogBrandSet.containsKey(b.Id)){
                // Logic to check it ATLEAST ONE Brand Exist
                if(accBrandIds != null){
                    Set<Id> tempSet = new Set<Id>();
                    tempSet.addAll(accBrandIds);
                    tempSet.addAll(blogBrandSet.get(b.Id));
                    if(tempSet.size() < (accBrandIds.size() + blogBrandSet.get(b.Id).size())){
                        blgWithB2bSecurity.add(b);
                    }
                }
            }else{
                blgWithB2bSecurity.add(b);
            }
        }
        return blgWithB2bSecurity;
    }
      
    /**
    * @author Basant Verma
    * @Story US503/TA907
    * @description Returns all available tags
    */
   	public static List<Tag__c> getAllTags(){
        return [Select Id, Name, Type__c, Tag__c From Tag__c];
    }
    
    // End : Changes for US503/TA907 - Basant
    // End : Changes for US503/TA1011 : Comment All Blog Code - Basant
    /**
    * @author Basant Verma
    * @Story US85/DE576
    * @description Return a list of sObject Records
    * It will be helpfull when we fec the error 'Too many query rows: 50001' 
    */
    public static List<sObject> queryRecords(String soql, Map<String, sObject> paramMap){
        List<sObject> allRecords = new List<sObject>();
        if(soql != null && !soql.trim().equals('')){
	        boolean flag = true;
	        Integer lastFromIndex = soql.lastIndexOfIgnoreCase(' FROM ')+6;
	        Integer grpByIndex = soql.indexOfIgnoreCase(' GROUP BY ', lastFromIndex);
	        Integer ordByIndex = soql.indexOfIgnoreCase(' ORDER BY ', lastFromIndex);
	        Integer whereIndex = soql.indexOfIgnoreCase(' WHERE ', lastFromIndex);
	        if( grpByIndex > 0 )
	        	soql = soql.substring(0, grpByIndex) + (whereIndex > 0 ? ' AND ' : ' WHERE ') + ' Id NOT IN :allRecords ' +  soql.substring(grpByIndex);
	        else if( ordByIndex > 0 )
	        	soql = soql.substring(0, ordByIndex) + (whereIndex > 0 ? ' AND ' : ' WHERE ') + ' Id NOT IN :allRecords ' +  soql.substring(ordByIndex);
	        else
	        	soql = soql.substring(0, ordByIndex) + (whereIndex > 0 ? ' AND ' : ' WHERE ') + ' Id NOT IN :allRecords ' +  soql.substring(ordByIndex);
	        
	        soql += ' LIMIT 5000';
	        
	        while(flag){
	        	List<sObject> records = Database.query(soql);
	        	if(records != null && records.size() > 0)
	        		 allRecords.addAll(records);
	        	else
	        		flag = false;
	        }
        }
        return allRecords;
    }
}