/*****************************************************************************************************************
Name        : Controller_Base.cls

Updated By  : Basant Verma (Appirio Offshore)   
Date                : 6/25/13
Story/Task  : US615/TA1067

Updated By  : Basant Verma (AppirioOffShore)   
Date        : 6/17/13
Story/Task  : US495/DE600

Updated By  : Basant Kumar Verma (Appirio OffShore)
Date                : 15/6/2013
Story/Task  : US79/DE594

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 5/22/13
Story/Task  : US491/TA920

Updated By  : Jonathan Freese (Appirio)   
Date        : 5/23/13
Story/Task  : US493/TA922

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 5/27/13
Story/Task  : US85/TA910 - DE550

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 6/6/13
Story/Task  : US79/TA997

Updated By  : Jonathan Freese (Appirio)   
Date        : 6/6/13
Story/Task  : US491/TA973 - header updates

Updated By  : Jonathan Freese (Appirio)   
Date        : 6/25/13
Story/Task  : US607/TA1014

Updated By  : Basant Verma (Appirio OffShore)   
Date        : 7/1/13
Story/Task  : US607/TA1014

Updated By  : Basant Verma (Appirio OffShore)   
Date        : 7/19/13
Story/Task  : US609/DE654
*******************************************************************************************************************/

global public without sharing virtual class Controller_Base {
        // Start : Changes for US615/TA1067 - Basant Verma (Appirio OffShore)
        // Revised by Randy Wandell 7/10/13
        public boolean isResponsive { get; set; }
        // End : Changes for US615/TA1067 - Basant Verma (Appirio OffShore)
        // Start : Changes for TA920 - Basant Verma
        public String clickedTheme {public get; public set;}
        private String defSiteThemeTemp;
        /*Note by Jonathan Freese 6/9/13:
             With the changes under US507/TA918, the theme selector will be discarded from all pages in favor of
             of theme toggle buttons.  The Boolean showThemeSelector defined for each page will henceforth be used
             to indicate which pages should include theme toggles in the header.  (Under the previous configuration,
             15 pages in addition to the homePage had showThemeSelector="false".)  The Boolean isNeedToggle will not
             be needed at all, but is retained (for now) to demonstrate the workings of the previous header.*/
        public boolean isNeedToggle {
            get{
        if(currentUserPage().equalsIgnoreCase('/apex/HomePage'))
            return true;
        else
            return false;
        }
      }
      public String planningTheme {get; set;}
        // End : Changes for TA920
    // Begin Appirio Case 4632 - Mark Ellis
    public boolean firstload {public get; public set;}
    // Begin Appirio Case 4632
 
    public String pageUrl {public get; public set;}
    public String siteTheme {public get; public set;}
    public String siteThemeDef {public get; public set;}
    public Boolean isSiteThemeDef {public get; public set;}
     
    public string hexDiageowines {get; private set;}
    public string hexDwsacademies {get;private set;}
    public string ssoId {get;private set;}
     
    protected Boolean shareFromContentDescription {protected get; protected set;}
     
    public Set<Id> currentBasketIds {public get; protected set;}
    public Set<Id> currentFollowIds {public get; protected set;}
        
    public Boolean isLoggedIn{get; protected set;}
    public Boolean isExport{get; protected set;}
    
    public list<pageLink> breadCrumbLinks{get; protected set;}
    public list<pageLink> menuLinks{get; protected set;}

    public String videoPlayerId{get; protected set;}
    public String videoPlayerKey{get; protected set;}
		public Boolean R_MultInFollowWithselAll {get; set;}  
    public String searchPhrase {public get; public set;}
    
    public String googleAnalyticsUID {public get; protected set;}
    
    // TA914, TA979 : Varialbes used for setting Google Analytics 
    // Custom Variable values
    public String userType {public get; protected set;}
    public String userProfile {public get; protected set;}
    public String userTitle {public get; protected set;}
    
    public Boolean expandFilter {get;set;}   
        
    public String myuserAgent{get;set;}
    public Boolean isIpad{get;set;}
    public String selectedMonth {get; set;}
    public String selectedYear {get; set;}
    public Boolean isInternalUser {
        get{
            if (isInternalUser == null) {
                isInternalUSer = false;
                try{
                    Account diageo = [select Id from Account where Name = 'DIAGEO'];
                    List<Account_Member__c> members = [select Account__c from Account_Member__c where User__c = :Service_API.getUID()];
                    for(Account_Member__c member : members){
                        if(member.Account__c == diageo.id){
                            isInternalUser = true;
                            break;
                        }
                    }
                } catch(Exception ex){
                    //nothing
                }
            }
            return isInternalUser;
        } private set;
    }
    
    public List<String> distributorNames {
        get{
            List<String> distributorNames = Service_API.getDistributorNames();
            return distributorNames;
        } private set;
    }
    
    // Start : Changes for TA1014 - Jonathan Freese
    public Integer followItemsNo {
        get{
            Integer noFollowItems = Service_Follow.getNumberOfItems();
            return noFollowItems;
        } private set;
    } 
    // End : Changes for TA1014 - Jonathan Freese

    public Integer basketItemsNo {
        get{
            Integer noBasketItems = Service_Basket.getNumberOfItems();
            return noBasketItems;
        } private set;
    } 

    // Start : Changes for TA973 - Jonathan Freese
    public String avatarUrl {
        get{
            String result='';
            try{
                User u = [select Id, FirstName, LastName, SmallPhotoUrl, FULLPhotoUrl from User where Id = : UserInfo.getUserId()];
                    result = u.SmallPhotoUrl;
            }catch(Exception ex){
                //nothing
            }
            return result;
        } private set;
    } 

    public Boolean showAvatar {
        get{
            Boolean result=true;
            try{
                User u = [select Id, FirstName, LastName, profile.userlicense.name from User where Id = : UserInfo.getUserId()];
                if(u.profile.userlicense.name == 'Customer Portal Manager Custom'){
                    result=false;
                }
            }catch(Exception ex){
                //nothing
            }
            return result;
        } private set;
    } 
    // End : Changes for TA973 - Jonathan Freese
    
    // pages
    public Integer numberOfPages {public get; public set;}
    public Integer numberOfItems {public get; public set {
            pageNumbers = new list<Integer>();          
            if(value > 0 && numberOfItemsOnPage > 0){
                numberOfItems = value;
                showFromIndex = (numberOfCurrentPage-1)*numberOfItemsOnPage;
                if(showFromIndex + numberOfItemsOnPage <= numberOfItems){
                    showToIndex = showFromIndex + numberOfItemsOnPage;
                } else {
                    showToIndex = numberOfItems;
                }
                if(numberOfItems > numberOfItemsOnPage){
                    numberOfPages = Integer.valueOf(math.ceil(decimal.valueOf(numberOfItems)/numberOfItemsOnPage));     
                } else {
                    numberOfPages = 1;
                }
                
                if(numberOfCurrentPage == 1){
                    pageNumbers.add(1);
                    if(numberOfCurrentPage+1 <= numberOfPages && numberOfCurrentPage+1 != 0){
                        pageNumbers.add(numberOfCurrentPage+1);
                    }
                    if(numberOfCurrentPage+2 <= numberOfPages && numberOfCurrentPage+2 != 0){
                        pageNumbers.add(numberOfCurrentPage+2);
                    }                       
                } else if(numberOfCurrentPage == numberOfPages){
                    if(numberOfCurrentPage-2 <= numberOfPages && numberOfCurrentPage-2 != 0){
                        pageNumbers.add(numberOfCurrentPage-2);
                    }
                    if(numberOfCurrentPage-1 <= numberOfPages && numberOfCurrentPage-1 != 0){
                        pageNumbers.add(numberOfCurrentPage-1);
                    }
                    if(numberOfCurrentPage <= numberOfPages && numberOfCurrentPage != 0){
                        pageNumbers.add(numberOfCurrentPage);
                    }
                } else {
                    if(numberOfCurrentPage-1 <= numberOfPages && numberOfCurrentPage-1 != 0){
                        pageNumbers.add(numberOfCurrentPage-1);
                    }
                    if(numberOfCurrentPage <= numberOfPages && numberOfCurrentPage != 0){           
                        pageNumbers.add(numberOfCurrentPage);
                    }
                    if(numberOfCurrentPage+1 <= numberOfPages && numberOfCurrentPage+1 != 0){
                        pageNumbers.add(numberOfCurrentPage+1);
                    }
                }
            } else {
                numberOfItems = 0;
                showFromIndex = 0;
                showToIndex = 0;
                numberOfPages = 1;
                //numberOfCurrentPage = 1;
            }
            
        }}
    public Integer numberOfItemsOnPage {public get; public set;}   
    public Integer numberOfCurrentPage {public get; public set;}    
    public Integer showFromIndex {public get; public set; }
    public Integer showToIndex {public get; public set; }        
    public List<Integer> pageNumbers {public get; public set; }
    public String cShareLink {public get; public set; }
    public String cShareLinkLow {public get; public set; }
    public Boolean isNewContent {public get; protected set; }

    //Site navigation menu links list
    public list<pageLink> menuLinksBase {public get {
        menuLinks.clear();
        PageLink dws = (siteTheme == 'Spirits') ? (new PageLink('/idp/login?app='+ssoId+'&RelayState='+hexDwsacademies,Constant.DWS, 'menu-plan')) : (new PageLink('/idp/login?app='+ssoId+'&RelayState='+hexDiageowines,Constant.DIAGEOWINESCOM, 'menu-plan'));

        if(isResponsive) {
            return new list<pageLink>
                {
                   new PageLink(Page.R_MonthlyExecutionPlan.getUrl(),Constant.MONTHLY_EXECUTION_PLAN, 'menu-mep'),
                   new PageLink(Page.R_InnovationAndVAP.getUrl(),((Service_API.getSectionTheme() == 'Spirits') ? Constant.INNOVATION_AND_SUSTAINOVATION : Constant.INNOVATION_SUSTAINOVATION_AND_VINTAGE) , 'menu-isv'),
                   new PageLink(Page.R_SMIntro.getUrl(),Constant.SELLING_MATERILAS, 'menu-sm'),
                   new PageLink(Page.R_BlogHome.getUrl(),'News Blog', 'menu-mep')
                };          
        } else {
            return new list<pageLink>
                {
                   new PageLink(Page.MonthlyExecutionPlan.getUrl(),Constant.MONTHLY_EXECUTION_PLAN, 'menu-mep'),
                   new PageLink(Page.InnovationAndVAP.getUrl(),((Service_API.getSectionTheme() == 'Spirits') ? Constant.INNOVATION_AND_SUSTAINOVATION : Constant.INNOVATION_SUSTAINOVATION_AND_VINTAGE) , 'menu-isv'),
                   new PageLink(Page.SMIntro.getUrl(),Constant.SELLING_MATERILAS, 'menu-sm'),
                   new PageLink(Page.CDIntro.getUrl(),Constant.CATEGOTY_DEVELOPMENT, 'menu-pm'),
                   new PageLink(Page.BMIIntro.getUrl(),Constant.BRAND_MARKETING_INFORMATION, 'menu-bmi'),
                   new PageLink(Page.PIL.getUrl(),Constant.PRODUCT_IMAGES_AND_LOGOS, 'menu-pil'),
                   new PageLink(Page.POS_LegalDisclaimer.getUrl(),Constant.POS, 'menu-pos'),
                   new PageLink(Page.Collaboration.getUrl(),Constant.COLLABORATION, 'menu-col'),
                   dws,
                   new PageLink(Page.Multicultural.getUrl(),Constant.MULTICULTURAL, 'menu-dws')
                }; 
        }
        }
        protected set;}
        
    // content overview/share
    public String cVersionId {public get; public set; }
    public String cDescr {public get; public set; }
    public String cVideoId {public get; public set; }   
    public Boolean cIsVideo {public get; public set; }
    public Boolean cIsPreview {public get; public set; }                
    public String cPreviewId {public get; public set; }
    
    
    // multiple share
    public String cVersionIds {public get; public set; }
    
    public DateTime lastLoginDate {
        public get{
            if (lastLoginDate==null) {
                 lastLoginDate = Service_API.getLastLoginDate();
            }
            return lastLoginDate;
        } 
        private set;
    }
    
    private void setGAUID(){
        if(googleAnalyticsUID==null)
            googleAnalyticsUID = Service_API.getSetting('googleanaliticsuid');
    }
        
    public Controller_Base() {
        // Start: Changes to support responsive site - Randy Wandell (Appirio) 7/10/13
        if(isResponsive == null) { isResponsive = Service_API.isResponsive(); }
        // End:
        myuserAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if(myuserAgent != null && myuserAgent != '' && myuserAgent.contains('iPad')){
            isIpad = true;  
        }else{
            isIpad = false;
        }
        
            String siteThemeDefault = Service_API.getSectionThemeDefault();
        if(siteThemeDefault != null && siteThemeDefault != ''){
            isSiteThemeDef = true;
        } else {
            isSiteThemeDef = false;
        }
        
        siteTheme = Service_API.getSectionTheme();
        
        // Start : Changes for TA920 - Basant Verma     
        defSiteThemeTemp = siteThemeDefault;   
        clickedTheme = siteTheme;
        // End : Changes for TA920
        
        currentBasketIds = new set<id>();
        currentFollowIds = new set<id>();
        
        ssoId = Service_API.getSSOId();
        User u = [select Id, FirstName, LastName, Title, Profile.Name from User where Id = : UserInfo.getUserId()];
        
        String usrInfo = 'first_name=' + u.FirstName + ',last_name=' + u.LastName+', title=' + u.Title;
        
        Blob spBlob    = Blob.ValueOf('dest=diageowines.com,'+usrInfo );
        hexDiageowines = EncodingUtil.base64Encode(spBlob);
        
        spBlob          = Blob.ValueOf('dest=www.dwsacademies.com,'+usrInfo );
        hexDwsacademies = EncodingUtil.base64Encode(spBlob);   
        
        shareFromContentDescription = true;
        isLoggedIn      = Userinfo.getUserName() != null;
        breadCrumbLinks = new list<pageLink>();
        menuLinks       = new list<pageLink>();
        
        videoPlayerId  = Service_API.getVideoPlayerId();
        videoPlayerKey = Service_API.getVideoPlayerKey();
        
        setGAUID();
        
        // TA914, TA979 : Set Google Analytics custom variable values
        setGACustomVariables(u);
    
        // pages
        initPager();       
        
        preapareSiteNavigationMenu();
        
        // content share/overview
        cDescr     = null;
        cVideoId   = null;
        cVersionId = null;
        cVersionIds = null;
        cIsVideo   = false;
        cShareLink = null;
        cShareLinkLow = null;
        
        // START : Changes For US585/TA1081 : Parul Gupta
        selectedMonth = String.valueOf(System.today().month());
        selectedYear = String.valueOf(System.today().year());
        // END : Changes For US585/TA1081   : Parul Gupta
        
        
    }
    
    public List<SelectOption> getNumberOfItemsPerPageList() {
        return Service_UserInput.getNumberOfItemsPerPageList();
    }
    
    //Case 4632 
    public void changeNumberOfItemPerPage(){
        Service_API.setUserNumberOfItemsPerPage(String.valueOf(numberOfItemsOnPage));
        initPager();
        refreshPageContent();
        expandFilter = false;
    }

    public void changeListOrder(){
        refreshPageContent();
    }

    public List<SelectOption> getSiteThemes() {
        List<SelectOption> options = new List<SelectOption>();
        List<SelectOption> tmp = Service_UserInput.getSiteThemes();
        SelectOption lastOpt;
        for(SelectOption so : tmp){
            if(so.getLabel() != siteTheme)
                options.add(so);
            else {
                lastOpt = so;
            }
        }
        options.add(lastOpt);
        return options;
    }
    
    public String themeOptionsString { get {
        String resultStr = '';
        map<String,String> urlPrm = ApexPages.currentPage().getParameters();
        String glueThmOpt = '';
        for(String prm : urlPrm.keySet()){
            String prmAfter = prm.replaceAll('themetype', '');
            if(prm.length() != prmAfter.length()){ // this param contains information theme
                resultStr += glueThmOpt + EncodingUtil.urlDecode(urlPrm.get(prm), 'UTF-8');
                glueThmOpt = ', ';
            }
        }
        return resultStr;
    } set;}
    
    public List<CheckboxOption> themeOptions {
        get {
            set<String> themesFromUrl = new set<string>();
            if(themeOptions == null){
                themeOptions = new List<CheckboxOption>();
                map<String,String> urlPrm = ApexPages.currentPage().getParameters();
                for(String prm : urlPrm.keySet()){
                    String prmAfter = prm.replaceAll('themetype', '');
                    if(prm.length() != prmAfter.length()){ // this param contains information theme
                        themesFromUrl.add(EncodingUtil.urlDecode(urlPrm.get(prm), 'UTF-8'));
                    }
                }
                for(SelectOption opt : getSiteThemes()){
                    if(opt.getLabel() != siteTheme)
                        themeOptions.add(new CheckboxOption(opt.getLabel(), themesFromUrl.contains(opt.getLabel()), false));
                }
                themeOptions.add(new CheckboxOption(siteTheme, true, true));
            }
            
            // Start : For US85/TA910
            // @description To Show Sub Options ( Catalyst,  Other) on 'Monthly execution plan'
            // Edited by Jonathan Freese per DE552 to change Other to US Spirits and place it above Catalyst
            // Edited By Basant Verma per DE558 to show slected calendar on PDF also
            // Start : Changes for US585/TA1082 - Basant (Added R_xxx page) 
            if(currentUserPage().equalsIgnoreCase('/apex/MonthlyExecutionPlan')
                    || currentUserPage().equalsIgnoreCase('/apex/MonthlyExecutionPlanPDF')
                    || currentUserPage().equalsIgnoreCase('/apex/R_MonthlyExecutionPlan')
                    || currentUserPage().equalsIgnoreCase('/apex/R_MonthlyExecutionPlanPDF')
                    || currentUserPage().equalsIgnoreCase('/apex/R_InnovationAndVAP')
                    || currentUserPage().equalsIgnoreCase('/apex/R_InnovationAndVAPPDF')){
            // End : Changes for US585/TA1082 - Basant (Added R_xxx page)
                for(CheckboxOption cbo : themeOptions){
                    if(cbo.name.equalsIgnoreCase(Label.CatalystParentTheme) && cbo.subOptions.size() == 0){
                        cbo.subOptions = new List<CheckboxOption>();
                        cbo.subOptions.add(new CheckboxOption('US Spirits', (cbo.chosen || themesFromUrl.contains('US Spirits')), false));
                        cbo.subOptions.add(new CheckboxOption('Catalyst', (cbo.chosen || themesFromUrl.contains('Catalyst')), false));
                    }
                }
            } // End : For US85/TA910
            
            return themeOptions;
        }
        set;
    }
    
    public Integer noOfThemesAvailable {
        get {
            return themeOptions.size();
        }
    }
    
    protected Set<String> selectedThemes(){
        Set<String> str = new Set<String>();
        for(CheckboxOption o : themeOptions){
            if(o.chosen)
                str.add(o.name);
                for(CheckboxOption subOp : o.subOptions){
                    if(subOp.chosen)
                        str.add(subOp.name);
                }
        }
        return str;
    }
    
    public Boolean isCalendarThemeMixed{
        get {
            return selectedThemes().size()>1;
        }
    }
    
    protected String parseSelectedThemesToUrl(){
        String urlThemeParam = '';
        String glue = '';
        Integer i = 1;
        for(CheckboxOption o : themeOptions){
            if(o.chosen){
                urlThemeParam += glue+'themetype'+i+'='+EncodingUtil.urlEncode(o.name, 'UTF-8');
                glue = '&';
                i++;
            }
            // Start : Changes for DE558 : Basant Verma
            for(CheckboxOption subOp : o.subOptions){
                    if(subOp.chosen){
                        urlThemeParam += glue+'themetype'+i+'='+EncodingUtil.urlEncode(subOp.name, 'UTF-8');
                    glue = '&';
                    i++;
                    }
                }
                // End : Changes for DE558 : Basant Verma
        }
        return urlThemeParam;
    }
    
    public PageReference changeSiteTheme(){
    	System.Debug('<----- ' + siteTheme + ' ----->');
        if(siteTheme == null || siteTheme == ''){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Site theme is required.' ));
            return null;
        }
        try {
        
            // update user profile
            Service_API.setUserSiteTheme(siteTheme, isSiteThemeDef);
            
        } catch (Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to set site theme.' ));
            return null;
        }
        PageReference p;

        String currentUserPageUrl = ApexPages.currentPage().getUrl();
        Integer ask = currentUserPageUrl.indexOf('?');
        String currentUserPage = (ask==-1) ? currentUserPageUrl : currentUserPageUrl.substring(0, ask);
        
		System.Debug('<----- ' + currentUserPageUrl + ' ----->');
		System.Debug('<----- ' + currentUserPage + ' ----->');        

        if(currentUserPage != null && currentUserPage != ''){
            p = new PageReference(currentUserPage);
        } else {
            p = Page.HomePage;
        }

        p.setRedirect(true);    
        return p;
    }

    public PageReference changeCurrentSiteTheme(){
        if(siteTheme == null || siteTheme == ''){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Site theme is required.' ));
            return null;
        }
        try {
        
            // update user profile
            Service_API.setUserSiteTheme(siteTheme, false);
            
        } catch (Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to set site theme.' ));
            return null;
        }
        PageReference p;

        String currentUserPageUrl = ApexPages.currentPage().getUrl();
        Integer ask = currentUserPageUrl.indexOf('?');
        String currentUserPage = (ask==-1) ? currentUserPageUrl : currentUserPageUrl.substring(0, ask);
        //System.debug('^^^currentUserPageUrl='+currentUserPageUrl);

        if(currentUserPage != null && currentUserPage != ''){
            /* Start: changes for TA922 Jonathan Freese */
            Boolean PlanningPage=false;
            for (PlanningPage_Theme__c ppt : PlanningPage_Theme__c.getAll().values()){
                if (ppt.Planning_Page__c == currentUserPage){
                    PlanningPage=true;
                }
            }
            if(PlanningPage){
                String test_pp='';
                for (PlanningPage_Theme__c ppt : PlanningPage_Theme__c.getAll().values()){
                    if (ppt.Name == siteTheme){
                        test_pp=ppt.Planning_Page__c;
                    }
                }
                if(test_pp != null && test_pp != ''){
                   currentUserPage = test_pp;
                }
                else{
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'PlanningPage_Theme not defined for selected theme: ' + siteTheme));
                    return null;
                }
            }            
            p = new PageReference(currentUserPage);
            /* end: changes for TA922 Jonathan Freese */
        } else {
            p = Page.HomePage;
        }

        p.setRedirect(true);    
        return p;
    } 
   
    protected void initPager(){
            //Begin Appirio Case 4632 - Mark Ellis
            if(firstload == true) {
            numberOfItemsOnPage = 12;
        } else {
            numberOfItemsOnPage = Service_API.getUserNumberOfItemsPerPage();
        }
        // End Appirio Case 4632 
        numberOfCurrentPage = 1; // we display always one or more pages 
        numberOfPages = 1; // we display always one or more pages
        numberOfItems = 0;
        showFromIndex = 0;
        showToIndex   = 0;
        pageNumbers   = new list<Integer>();   
        isNewContent = false;
    }
    
    protected void preapareSiteNavigationMenu() {
        menuLinksBase.clear();

        String currentPageUrl = ApexPages.currentPage().getUrl();
        Integer ask = currentPageUrl.indexOf('?');
        String currentPage = (ask==-1) ? currentPageUrl : currentPageUrl.substring(0, ask);
        for(pageLink pl: menuLinksBase) { 
            if (pl.link != currentPage) {
                if((currentPage == Page.SellingMaterials.getUrl())&&(pl.linkName == Constant.SELLING_MATERILAS))
                    continue;
                menuLinks.add(pl);
            }
        }
        if(isInternalUser && !isResponsive){
            pageLink planningPageLink = new PageLink('#',Constant.PLANNING, 'menu-plan');
            pageLink[] planningSubPageLinks = new pageLink[] {
                new PageLink(Page.SpiritsPlanning.getUrl(), 'Spirits Planning', 'menu-plan'),
                new PageLink(Page.NationalAccounts.getUrl(), 'National Accounts', 'menu-plan'),
                new PageLink(Page.WinePlanning.getUrl(), 'Wine Planning', 'menu-plan')
            };
            planningPageLink.addSubLinks(planningSubPageLinks);
            menuLinks.add(planningPageLink);
        }
    }
    
    protected void addBreadcrumbItem(String link, String linkName) {
        if (linkName == '' || linkName == null) {
            return;
        }
        if (link == '' || link == null) {
            link = '#';
        }
        pageLink bl = new pageLink();
        bl.link     = link;
        bl.linkName = linkName;
        breadCrumbLinks.add(bl);
    }

    protected void cleanBreadcrumbs() {
        breadCrumbLinks.clear();
    }

    protected list<SelectOption> convertListToSelect ( sObject[] records, String idFieldName, String valueFieldName, String allText) {
        list<SelectOption> result = new list<SelectOption>();
        if(allText != null){
            result.add(new SelectOption('All', allText));
        }         
        for (sObject o : records) {
            result.add(
                new SelectOption(
                    (string)o.get(idFieldName),
                    (string)o.get(valueFieldName)
                    )
                );
        }
        return result;
    }
    
    // pages functions
    public void showPageRequested() {
        if(numberOfCurrentPage < 0 || numberOfCurrentPage > numberOfPages) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to show page.' ));
            return;
        }
        refreshPageContent();
        expandFilter = false;       
    }
    
    public void showNextPage() {
        if (this.numberOfCurrentPage + 1 <= this.numberOfPages && this.numberOfCurrentPage + 1 > 0) {
            this.numberOfCurrentPage += 1;
        } else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to show next page.' ));
            return;
        }
        refreshPageContent();  
        expandFilter = false;         
    }
    
    public void showPrevPage() {
        if (this.numberOfCurrentPage - 1 <= this.numberOfPages && this.numberOfCurrentPage - 1 > 0) {
            this.numberOfCurrentPage -= 1;
        } else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to show prev page.' ));
            return;
        }
        refreshPageContent();  
        expandFilter = false;         
    }
    
    public void showFirstPage() {
        if(this.numberOfPages > 0){
            this.numberOfCurrentPage = 1;
        } else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to show first page.' ));
            return;
        }
        refreshPageContent();
        expandFilter = false;   
    }
    
    public void showLastPage() {
        if(this.numberOfPages >= 1){
            this.numberOfCurrentPage = this.numberOfPages;
        } else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to show last page.' ));
            return;
        }
        refreshPageContent();
        expandFilter = false;   
    }
    
    public list<sobject> getRequestedPage(list<sobject> all){
        list<sobject> tempList = new List<sobject>();
        isNewContent = false;
        if(all.size() < showToIndex){
            return new List<sobject>();
        }
    
        for (Integer i = showFromIndex; i < showToIndex; i++) {
            tempList.add(all.get(i));
            sObject currentItem = all.get(i);
            DateTime itemTime = datetime.valueOf((currentItem.get('createdDate') != null && currentItem.get('createdDate') != '') ? currentItem.get('createdDate') : system.now());
            if(!isNewContent && lastLoginDate < itemTime){
                isNewContent = true;
            }   
        }
        all.clear();
        all.addall(tempList);
        return all;
    }
    
    public Map<String, list<sobject>> getRequestedPageForMap(Map<String, list<sobject>> all, List<String> headers){
    // Start : Changes For US495/DE600 : Basant Kumar Verma
    contentCanEditIdSet = null;
    // End : Changes For US495/DE600 : Basant Kumar Verma
        Map<String, list<sobject>> tmp = new Map<String, list<sobject>>();
        isNewContent = false;
        Integer size = 0;
        for(list<sobject> lobj : all.values()){
            size += lobj.size();
        }
        if(size < showToIndex){
            return new Map<String, list<sobject>>();
        }
        
        Integer counter = -1;
        for(String key : headers){
            for(sobject obj : all.get(key)){
                counter++;
                if((counter >= showFromIndex)&&(counter < showToIndex)){
                    list<sobject> tmplist = tmp.get(key);
                    tmplist = (tmplist == null) ? new list<sobject>() : tmplist;
                    tmplist.add(obj);
                    tmp.put(key, tmplist);
                    DateTime itemTime = datetime.valueOf((obj.get('createdDate') != null && obj.get('createdDate') != '') ? obj.get('createdDate') : system.now());
                    if(!isNewContent && lastLoginDate < itemTime){
                        isNewContent = true;
                    }
                }
            }
        }
        return tmp;
    }
    
    public virtual void refreshPageContent(){
        
    }
    
    public String getRandomId(){
        return String.valueOf(Math.abs(Crypto.getRandomLong()));
    }
    
    public virtual PageReference userSearch(){
        PageReference pr = ApexPages.currentPage();
        if(searchPhrase.length() != 0){
            if(currentUserPage().toLowerCase().startsWith('/apex/r_')){
                pr = new PageReference( Page.R_SearchResult.getUrl() + '?query='+EncodingUtil.urlEncode(searchPhrase,'UTF-8') );
            }else{
                pr = new PageReference( Page.SearchResult.getUrl() + '?query='+EncodingUtil.urlEncode(searchPhrase,'UTF-8') );
            }
            pr.setRedirect(true);
        }
        return pr;
    }
    
    // Start : Changes for TA920 - Basant Verma 
    public virtual PageReference toggleTheme(){
        PageReference pr = ApexPages.currentPage();
        
        // Start : Changes for TA973 Jonathan Freese
        /* If we are currently on a planning page, need to switch the page reference to a different planning page (the one indicated by the clickedTheme) */
        String currentUserPageUrl = ApexPages.currentPage().getUrl();
        Integer ask = currentUserPageUrl.indexOf('?');
        String currentUserPage = (ask==-1) ? currentUserPageUrl : currentUserPageUrl.substring(0, ask);

        if(currentUserPage != null && currentUserPage != ''){
            Boolean onPlanningPage=false;
            for (PlanningPage_Theme__c ppt : PlanningPage_Theme__c.getAll().values()){
                if (ppt.Planning_Page__c == currentUserPage){
                    onPlanningPage=true;
                }
            }
            if(onPlanningPage){
                String goToPlanningPage='';
                for (PlanningPage_Theme__c ppt : PlanningPage_Theme__c.getAll().values()){
                    if (ppt.Name == clickedTheme){
                        goToPlanningPage=ppt.Planning_Page__c;
                    }
                }
                if(goToPlanningPage != null && goToPlanningPage != ''){
                   pr = new PageReference(goToPlanningPage);
                }
                else{
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'PlanningPage_Theme not defined for selected theme: ' + clickedTheme));
                    return null;
                }
            }
        }
        // End : Changes for TA973 Jonathan Freese

        try{
                pr.getParameters().put('toggled','TRUE');
                pr.getParameters().put('toggledTheme',clickedTheme);
                pr.getParameters().put('toggledThemeDef',defSiteThemeTemp);
                pr.getParameters().put('toggledNum',String.valueOf(numberOfItemsOnPage));
                // Start : Changes for TA920/DE550 Jonathan Freese
                Service_API.setUserSiteTheme(clickedTheme, true);
                //   End : Changes for TA920/DE550 Jonathan Freese
                pr.setRedirect(true);
            }catch (Exception e){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to toggle theme.' ));
                return null;
            }
            return pr;
    }
    
    public virtual PageReference toggleToSpirits(){
        clickedTheme = 'Spirits';
            return toggleTheme();
    }
    
    public virtual PageReference toggleToWine(){
        clickedTheme = 'Wine';
        return toggleTheme();
    }
    // End : Changes for TA920

    // Start : Changes for DE550 : Basant
    public virtual PageReference openPlanningPage(){
        PageReference pr = ApexPages.currentPage();
        String newTheme=''; 
        if(planningTheme != null && !planningTheme.trim().equals('')){
            if(planningTheme.equalsIgnoreCase('Wine')){
                pr = Page.WinePlanning;
                newTheme = 'Wine';
            }else if(planningTheme.equalsIgnoreCase('Spirits')){
                pr = Page.SpiritsPlanning;
                newTheme = 'Spirits';
            }
        }
        
        if(newTheme != '' && newTheme != siteTheme){
            Service_API.setUserSiteTheme(newTheme, false);
        }
        return pr;
    }
    
    public virtual PageReference openSpiritsPlanningPage(){
        if(siteTheme != 'Spirits')
            Service_API.setUserSiteTheme('Spirits', false);
        return Page.SpiritsPlanning;
    }
    
    public virtual PageReference openWinePlanningPage(){
        if(siteTheme != 'Wine')
            Service_API.setUserSiteTheme('Wine', false);
        return Page.WinePlanning;
    }
    // End : Changes for DE550
    // set current overview/share
    public void userShareOverview(){
        cVersionIds = null;
        if(cVersionId == null || cVersionId == ''){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load content.' ));
            return;
        }
        try{
            try{
                Content_Description__c contentDescription = [select Content_ID__c, Content_Version_Id__c, Description__c, filetype__c, Innovation__c, Is_Video__c, Title__c, Video_Id__c, Preview_Id__c, Preview_Available__c, share_link__c, share_link_low__c
                                                                from Content_Description__c
                                                                where Content_Version_Id__c = :cVersionId
                                                                limit 1 ];
                cDescr     = contentDescription.Description__c;
                cVideoId   = contentDescription.Video_Id__c;
                cIsVideo   = contentDescription.Is_Video__c;
                cIsPreview = contentDescription.Preview_Available__c;
                cPreviewId = contentDescription.Preview_Id__c;
                cShareLink = contentDescription.share_link__c;
                cShareLinkLow = contentDescription.share_link_low__c;
            } catch (Exception e) {
                File__c fileObject = [select Content_ID__c, Content_Version_Id__c, Description__c, filetype__c, Is_Video__c, Title__c, Video_Id__c, Preview_Id__c, Preview_Available__c, share_link__c
                                                                from File__c
                                                                where Content_Version_Id__c = :cVersionId
                                                                limit 1 ];
                cDescr     = fileObject.Description__c;
                cVideoId   = fileObject.Video_Id__c;
                cIsVideo   = fileObject.Is_Video__c;
                cIsPreview = fileObject.Preview_Available__c;
                cPreviewId = fileObject.Preview_Id__c;
                cShareLink = fileObject.share_link__c;
            }
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load content.' ));
            cDescr = null;
            cVideoId = null;
            cIsVideo = false;
            cIsPreview = false;
            cPreviewId = null;
            cShareLinkLow = null;
            cShareLink =null;
        }
    } 

    // set current overview/share
    public void userMultipleShare(){
        //cVersionIds set by actionFunction 
        cVideoId = null;
        cDescr = null;
        cVideoId = null;
        cIsVideo = false;
        cIsPreview = false;
        cPreviewId = null;  
    }
    
    public Id fileToEdit {get;set;}
    public void setFileToEdit(){}

    public void addToBasket(){
        try {
            list<Id> cIds = new list<Id>();
            if(cVersionId != null){
                cIds.add(cVersionId);
                Service_Basket.addToBasket(cIds);
            }
            currentBasketIds = Service_Basket.getBasketIds();
            refreshPageContent();
            expandFilter = false; 
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to add item to basket.' ));
        }
    }
    
    public void addToBasketMultiple(){
        try {
            list<Id> cIds = new list<Id>();
            
            list<String> cvidList = cVersionIds.split(',');
            for(String cvid : cvidList){
                if(cvid != null && cvid != ''){
                    Id itemId = Id.valueOf(cvid);
                    if(itemId != null){
                        cIds.add(itemId);
                    }
                }
            }
            
            if(cIds.size() != 0){
                Service_Basket.addToBasket(cIds);
            }
            currentBasketIds = Service_Basket.getBasketIds();
            refreshPageContent();
            expandFilter = false;
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to add items to basket.' ));
        }
    }
    
    public void removeFromBasket(){
        try {
            list<Id> cIds = new list<Id>();
            if(cVersionId != null){
                cIds.add(cVersionId);
                Service_Basket.removeFromBasket(cIds);
            }
            currentBasketIds = Service_Basket.getBasketIds();
            initPager();
            refreshPageContent();
            expandFilter = false;
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to remove item from basket.' ));
        }
    }

    public void removeFromBasketMultiple(){
        try {
            list<Id> cIds = new list<Id>();
            
            list<String> cvidList = cVersionIds.split(',');
            for(String cvid : cvidList){
                if(cvid != null && cvid != ''){
                    Id itemId = Id.valueOf(cvid);
                    if(itemId != null){
                        cIds.add(itemId);
                    }
                }
            }
            
            if(cIds.size() != 0){
                Service_Basket.removeFromBasket(cIds);
            }
            currentBasketIds = Service_Basket.getBasketIds();
            initPager();
            refreshPageContent();
            expandFilter = false;
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to remove items from basket.' ));
        }
    }
        
    public String distributorBreadcrumbString {
        public get{
            String res = '';
            String glue = '';
            for(String s : distributorNames){
                res += glue;
                res += s;
                glue = ', ';
            }
            return res;
        }
    }
    
    public void addToFollow(){
        try {
            list<Id> cIds = new list<Id>();
            if(cVersionId != null){
                cIds.add(cVersionId);
                // Start : Changes for TA997 - Basant Verma
                Service_Follow.addFollow(cIds);
            }
            currentFollowIds = Service_Follow.getFollowIds();
            // End: Changes for TA997 - Basant Verma
            refreshPageContent();
            expandFilter = false; 
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to follow content.' ));
        }
    }
    
    public void addToFollowMultiple(){
        try {
            list<Id> cIds = new list<Id>();
            System.debug('================== cVersionIds : '+cVersionIds);
            list<String> cvidList = cVersionIds.split(',');
            for(String cvid : cvidList){
                if(cvid != null && cvid != ''){
                    Id itemId = Id.valueOf(cvid);
                    if(itemId != null){
                        cIds.add(itemId);
                    }
                }
            }
      System.debug('================== cIds : '+cIds);      
            if(cIds.size() != 0){
                // Start: Changes for TA997 - Basant Verma
                Service_Follow.addFollow(cIds);
            }
            currentFollowIds = Service_Follow.getFollowIds();
            // End: Changes for TA997 - Basant Verma
            refreshPageContent();
            expandFilter = false;
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to follow content.' ));
        }
    }   
    
    public void removeFromFollow(){
        try {
            list<Id> cIds = new list<Id>();
            if(cVersionId != null){
                cIds.add(cVersionId);
                // Start: Changes for TA997 - Basant Verma
                Service_Follow.removeFollow(cIds);
            }
            currentFollowIds = Service_Follow.getFollowIds();
            // End: Changes for TA997 - Basant Verma
            initPager();
            refreshPageContent();
            expandFilter = false;
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to unfollow content.' ));
        }
    }

    public void removeFromFollowMultiple(){
        try {
            list<Id> cIds = new list<Id>();
            
            list<String> cvidList = cVersionIds.split(',');
            for(String cvid : cvidList){
                if(cvid != null && cvid != ''){
                    Id itemId = Id.valueOf(cvid);
                    if(itemId != null){
                        cIds.add(itemId);
                    }
                }
            }
            
            if(cIds.size() != 0){
                // Start: Changes for TA997 - Basant Verma
                Service_Follow.removeFollow(cIds);
            }
            currentFollowIds = Service_Follow.getFollowIds();
            // End: Changes for TA997 - Basant Verma
            initPager();
            refreshPageContent();
            expandFilter = false;
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to unfollow content.' ));
        }
    }
    
    /** For For TA910/US85
    * @author Basant Kumar Verma (Appirio OffShore)
    * @date 27/05/2013
    * @description To fetch current page's name from URL
    * @return String Current Page Name
    */
    protected String currentUserPage(){
        String currentUserPageUrl = ApexPages.currentPage().getUrl();
    Integer ask = currentUserPageUrl.indexOf('?');
    String currentUserPage = (ask==-1) ? currentUserPageUrl : currentUserPageUrl.substring(0, ask);
    return currentUserPage;
    }
    
    /** Task Ref TA914/US532, TA979/US576
    * @author Parul Gupta (Appirio OffShore)
    * @date 27/05/2013
    * @description method sets google analytics
    * custom variable values for tracking
    * userType, userProfile and userTitle
    */
    private void setGACustomVariables(User user){
        
        // TA914: Set user type - Internal/External
        if (userType == null){
            
            // Fetch custom setting that maps the Salesforce UserType values 
            // to the values of "Internal" or "External".
            Map<String, Google_Analytics_User_Type__c> userTypeMap = 
            Google_Analytics_User_Type__c.getAll();
            
            // Assign user type value                   
            if (userTypeMap != null && userTypeMap.containsKey(UserInfo.getUserType())){
                userType = userTypeMap.get(UserInfo.getUserType()).Google_Analytics_Value__c;
            }           
        }
        
        // TA979 : Set user profile friendly name
        if (userProfile == null){
            userProfile = user.Profile.Name;
        }
        
        // TA979 : Set user title
        if(userTitle == null && user.title != null){
            userTitle = user.title;
        }
    }
    
    // Start : Changes for US79/DE594 - Basant Verma
    public List<SelectOption> getNotificationFrequency() {
        List<SelectOption> options = new List<SelectOption>();
        List<SelectOption> tmp = Service_UserInput.getNotificationFrequency();
        SelectOption lastOpt;
        for(SelectOption so : tmp){
            if(so.getLabel() != siteTheme)
                options.add(so);
            else {
                lastOpt = so;
            }
        }
        options.add(lastOpt);
      return options;
    }
    // End : Changes for US79/DE594 - Basant Verma
    
    // Start : Changes For US495/DE600 : Basant Kumar Verma
        public Set<Id> checkCanEdit(List<AggregateResultHolder> agrList){
            Set<Id> canEditIdSet = new Set<Id>();
            Map<Id, Set<Id>> ownerAccIds = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> ownerCvIds = new Map<Id, Set<Id>>();
            for(AggregateResultHolder agr : agrList){
                if(agr != null && agr.result != null){
                    try{ 
                        if(agr.result.get('OwnerID') != null){
                            ownerAccIds.put((Id)agr.result.get('OwnerID'), new Set<Id>());
                            if(!ownerCvIds.containsKey((Id)agr.result.get('OwnerID')))
                                ownerCvIds.put((Id)agr.result.get('OwnerID'), new Set<Id>());
                            if(agr.result.get('cvid') != null)
                                ownerCvIds.get((Id)agr.result.get('OwnerID')).add((Id)agr.result.get('cvid'));
                            else
                                ownerCvIds.get((Id)agr.result.get('OwnerID')).add((Id)agr.result.get('cvidlow'));
                        }
                    }catch(Exception e){
                        System.debug(e.getMessage());
                    }
                }
            }
            
            for(AggregateResult memberAgr : [SELECT Account__c, User__c FROM Account_Member__c 
                    WHERE User__c IN :ownerAccIds.keySet() GROUP BY Account__c, User__c]){
                ownerAccIds.get((Id)memberAgr.get('User__c')).add((Id)memberAgr.get('Account__c'));
            }
            
            Set<Id> currentUserAccIds = Service_API.getAIDs();
            Set<Id> tempIds = new Set<Id>();
            tempIds.addAll(currentUserAccIds);
            for(Id ownerId : ownerAccIds.keySet()){
                tempIds.addAll(ownerAccIds.get(ownerId));
                if(tempIds.size() < (ownerAccIds.get(ownerId).size() + currentUserAccIds.size())){
                    canEditIdSet.addAll(ownerCvIds.get(ownerId));
                }
                tempIds.removeAll(ownerAccIds.get(ownerId));
            }
            
            return canEditIdSet;
        }
        
        public String getStringFromSet(Set<Id> idSet){
            String str = '';
            for(String e : idSet)
                str += e + ', ';
            if(str != '')
                str = str.substring(0, str.length()-2);
            return str;
        }
        
        protected Set<id> contentCanEditIdSet;
        
        public String contentCanEditIds {
            get{
                String currantPageName = currentUserPage();
                
                if(contentCanEditIdSet == null && currantPageName != null 
                                && !currantPageName.trim().equals('')){
                    MAP<string, List<AggregateResultHolder>> contentMap = new MAP<string, List<AggregateResultHolder>>();
                    if(currantPageName.trim().equalsIgnoreCase('/apex/Collaboration')){
                        contentMap = ((Controller_Collaboration) this).contentHolderMap;
                    }/*else if(currantPageName.trim().equalsIgnoreCase('/apex/Basket')){
                        contentMap.put('contentDetailsMap',((Controller_Basket) this).contentDetailsMap.values());
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/BrandMarketingInformation')){
                        contentMap.put('contentHolder',((Controller_BrandMarketingInformation) this).contentHolder);
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/CategoryDevelopment')){
                        contentMap.put('contentHolder',((Controller_CategoryDevelopment) this).contentHolder);
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/Compliance')){
                        contentMap.put('contentHolder',((Controller_Compliance) this).contentHolder);
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/DownloadHistory')){
                        contentMap.put('contentDetailsMap',((Controller_DownloadHistory) this).contentDetailsMap.values());
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/FollowedItems')){
                        contentMap.put('contentDetailsMap',((Controller_Follow) this).contentDetailsMap.values());
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/IVAPDetails')){
                        contentMap = ((Controller_IVAPDetails) this).detailsHolderMap;
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/MEPDetails')){
                        contentMap = ((Controller_MEPDetails) this).contentHolderMap;
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/Multicultural')){
                        contentMap = ((Controller_Multicultural) this).contentHolderMap;
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/NationalAccounts')){
                        contentMap = ((Controller_NationalAccounts) this).contentHolderMap;
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/PIL')){
                        contentMap.put('contentHolder',((Controller_PIL) this).contentHolder);
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/SearchResult')){
                        contentMap = ((Controller_SearchResult) this).contentHolderMap;
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/SellingMaterials')){
                        contentMap.put('contentHolder',((Controller_SellingMaterials) this).contentHolder);
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/ShareHistory')){
                        contentMap.put('contentDetailsMap',((Controller_ShareHistory) this).contentDetailsMap.values());
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/SpiritsPlanning')){
                        contentMap = ((Controller_SpiritsPlanning) this).contentHolderMap;
                    }else if(currantPageName.trim().equalsIgnoreCase('/apex/WinePlanning')){
                        contentMap = ((Controller_WinePlanning) this).contentHolderMap;
                    }*/
                                        
                    List<AggregateResultHolder> allAggrList = new List<AggregateResultHolder>();
                    for(String key : contentMap.keySet()){
                        allAggrList.addAll(contentMap.get(key));
                    }
                    
                    contentCanEditIdSet = checkCanEdit(allAggrList);
                }
                
                return getStringFromSet(contentCanEditIdSet);
            }
            protected set;
        }
        // END : Changes For US495/DE600 : Basant Kumar Verma
     
    // START : Changes For US585/TA1081 : Parul Gupta
    // Utility methods for Responsive month/year popover section
    public List<SelectOption> getMonthOptions() {       
        return DiageoUtils.getMonthOptions();
    }
    
    public List<SelectOption> getYearOptions() {       
        return DiageoUtils.getYearOptions(2003, 20);
    }
   
    public PageReference popOverPrevious(){     
        if(selectedYear != null){
            if(selectedMonth == '1'){
                selectedMonth = '12';
                if(selectedYear != null){
                    selectedYear = String.valueOf(Integer.valueOf(selectedYear) - 1);
                }
            }else{
                selectedMonth = String.valueOf(Integer.valueOf(selectedMonth) - 1);
            }
        }
        return null;
    }
    
    public PageReference popOverNext(){
        if(selectedMonth != null){  
            if(selectedMonth == '12'){
                selectedMonth = '1';
                if(selectedYear != null){
                    selectedYear = String.valueOf(Integer.valueOf(selectedYear) + 1);
                }
            }else{
                selectedMonth = String.valueOf(Integer.valueOf(selectedMonth) + 1);
            }
        }
        return null;
    }
    
    public PageReference setTodayDate(){
        selectedMonth = String.valueOf(System.today().month());
        selectedYear = String.valueOf(System.today().year());
        return null;
    }
    // END : Changes For US585/TA1081   
    
    // Start : Changes for US609/DE654 - Basant
    public String bdLink {get; set;}
		public String bdLinkName {get; set;}
		public void addInBreadcrumb(){
			if(bdLink != null && !bdLink.trim().equals('') && bdLinkName != null && !bdLinkName.trim().equals(''))
				addBreadcrumbItem(bdLink, bdLinkName);
		}
		// END : Changes for US609/DE654 - Basant
}