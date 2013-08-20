public with sharing class Controller_PIL extends Controller_Base {

    public String brandFlag{get;set;}
    // content page sections
    public String siteTheme {get;set;}
    public MAP<String, String> sections {get; set;}
    public List<string> sectionsOrder {get; set;}
    public string currentSection {get; set;}
    public Id detailId {get; set;}
    public Id currentBrandId {get; set;} 
    public string detailPageLogoId {get; set;}
    public List<AggregateResult> content {get; set;}
    public List<AggregateResultHolder> contentHolder {
        get {
            List<AggregateResultHolder> contentHolder1 = new List<AggregateResultHolder>();
            if(content!=null){
                for(AggregateResult ar : content){
                    AggregateResultHolder tmp = new AggregateResultHolder();
                    tmp.result = ar;
                    contentHolder1.add(tmp);
                }
            }
            return contentHolder1;
        }
        set;
    }
    
    public Brand__c brandDetails {public get; public set;}
    public String brandHeaderStyle {public get; public set;}
    public Boolean displayAsList {get; set;}    
    public Boolean showLeftMenu {public get; public set;}
    public Boolean showTopMenu {public get; public set;}
    public Boolean flExist {public get; public set;}
    public List <SelectOption> bottleSizes {get;set;}
    public List<String> selectedbottleSizes {get;set;}
    public List<Brand__c> allVariantBrands {get;set;}
    
    public List<Brand__c> variantBrands {public get; public set;}
    public map<string, List<Brand__c>> flavorsBrands {public get; public set;}
    public map<string, string> brandTranlations {public get; public set;}
    public map<string, Boolean> brandSubMenuExist {public get; public set;}
    public String currentSubBrandGroup {public get; public set;}
    public String currentSubBrandGroupName  {
        get{
            if(currentSubBrandGroup != '' && currentSubBrandGroup != ''){
                for(brand__c brand : variantBrands){
                    if(brand.Brand_Variant_Grouping__c.replaceAll('[^a-zA-Z0-9]', '') == currentSubBrandGroup){
                        return brand.Brand_Variant_Grouping__c;
                    }
                }
                return '';
            } else {
                return '';
            }
        } set;
    }
    
    public List<Brand__c> allBrands {public get; public set;}
    public String selectedBrandIds {get; set;}
    public List<Brand__c> searchBrands {public get; public set;}
    public List<Brand__c> coreBrands {public get; public set;}
    public List<Brand__c> reserveBrands {public get; public set;}
    public List<Brand__c> innovationBrands {public get; public set;}
    public List<Brand__c> heritageBrands {public get; public set;}
    public List<Brand__c> lifestyleBrands {public get; public set;}
    public List<Brand__c> luxuryBrands {public get; public set;}    
    public List<Integer> additionalBrandsPage {public get; public set;}
    public Map<Integer, list<Brand__c>> additionalBrandsMap {public get; public set;}
    public Map<Id, String> bottleImgMap {public get; public set;}
    public String searchBrand  {public get; public set;}
    public String defaultSearchBrand  {public get; protected set;}
    public String categoryView  {get; set;}
    public Map<Id, String> brandValidNames {public get; public set;}

    public Controller_PIL() {
        pageUrl = Page.PIL.getUrl();
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), Constant.PRODUCT_IMAGES_AND_LOGOS);
        
        defaultSearchBrand = Constant.SEARCH_BRAND_DEFAULT_TEXT;
        searchBrand = Constant.SEARCH_BRAND_DEFAULT_TEXT;
        content = new List<AggregateResult>();
        sections = new MAP<String, String>();
        sectionsOrder = new List<String>();
        list<Sections__c> sectionTabs = Service_API.getSectionTabs(CONSTANT.PRODUCT_IMAGES_AND_LOGOS);
        for(Sections__c s : sectionTabs ){
            sectionsOrder.add( s.Tab__c.replaceAll('[^a-zA-Z0-9]','') );
            sections.put( s.Tab__c.replaceAll('[^a-zA-Z0-9]',''),  s.Tab__c);
        }        
        currentSection = null;
        showLeftMenu = false;
        showTopMenu = false;
        flExist = false;
        displayAsList = false;
        
        allVariantBrands = new list<brand__c>();
        variantBrands = new List<Brand__c>();
        flavorsBrands = new map<string, List<Brand__c>>();
        brandTranlations = new map<string, string>();
        brandSubMenuExist = new map<string, Boolean>();
        searchBrands = new List<Brand__c>();
        coreBrands = new List<Brand__c>();
        lifestyleBrands = new List<Brand__c>();
        luxuryBrands = new List<Brand__c>();
        heritageBrands = new List<Brand__c>();
        reserveBrands = new List<Brand__c>();
        innovationBrands = new List<Brand__c>();
        additionalBrandsPage = new List<Integer>();
        additionalBrandsPage.add(1);  
        additionalBrandsMap = new Map<Integer, list<Brand__c>>();
        additionalBrandsMap.put(1, new List<Brand__c>());
        bottleImgMap = new Map<Id, String>();
        siteTheme = Service_API.getSectionTheme();
        
        if(siteTheme == 'Wine'){
            allBrands = Service_API.getPILBrandsNew2(false, true);
            for(Brand__c brand : allBrands){        
                                
                    if(brand.Heritage__c == true){              
                        heritageBrands.add(brand);
                        if(!bottleImgMap.containsKey(brand.id) && brand.Heritage_Logo__r.Content_Version_Id__c != '' && brand.Heritage_Logo__r.Content_Version_Id__c != null){
                            bottleImgMap.put(brand.id, brand.Heritage_Logo__r.Content_Version_Id__c);
                        }
                    }
                
                    if(brand.Lifestyle__c == true){
                        lifestyleBrands.add(brand);
                        if(!bottleImgMap.containsKey(brand.id) && brand.Lifestyle_Logo__r.Content_Version_Id__c != '' && brand.Lifestyle_Logo__r.Content_Version_Id__c != null){
                            bottleImgMap.put(brand.id, brand.Lifestyle_Logo__r.Content_Version_Id__c);
                        }
                    }
                
                    if(brand.Luxury__c == true){
                        luxuryBrands.add(brand);
                        if(!bottleImgMap.containsKey(brand.id) && brand.Luxury_Logo__r.Content_Version_Id__c != '' && brand.Luxury_Logo__r.Content_Version_Id__c != null){
                            bottleImgMap.put(brand.id, brand.Luxury_Logo__r.Content_Version_Id__c);
                        }
                    }  
                    
                    if(brand.Heritage__c != true && brand.Lifestyle__c != true && brand.Luxury__c != true && brand.Innovation__c != true){
                        addAdditionalBrands(brand);
                        if(!bottleImgMap.containsKey(brand.id) && brand.Heritage_Logo__r.Content_Version_Id__c != '' && brand.Heritage_Logo__r.Content_Version_Id__c != null){
                            bottleImgMap.put(brand.id, brand.Heritage_Logo__r.Content_Version_Id__c);
                        }
                        if(!bottleImgMap.containsKey(brand.id) && brand.Lifestyle_Logo__r.Content_Version_Id__c != '' && brand.Lifestyle_Logo__r.Content_Version_Id__c != null){
                            bottleImgMap.put(brand.id, brand.Lifestyle_Logo__r.Content_Version_Id__c);
                        }
                        if(!bottleImgMap.containsKey(brand.id) && brand.Luxury_Logo__r.Content_Version_Id__c != '' && brand.Luxury_Logo__r.Content_Version_Id__c != null){
                            bottleImgMap.put(brand.id, brand.Luxury_Logo__r.Content_Version_Id__c);
                        }
                    }
                    searchBrands.add(brand);
                    if(!bottleImgMap.containsKey(brand.id)){
                        bottleImgMap.put(brand.id, '');
                    }   
            }
        }else{
            allBrands = Service_API.getPILBrandsNew2(false);
            for(Brand__c brand : allBrands){
                 if(brand.Core_Trademarks__c == true){
                    if(coreBrands.size() < 10){
                        coreBrands.add(brand);
                    } else {
                        addAdditionalBrands(brand);
                    }
                    if(!bottleImgMap.containsKey(brand.id) && brand.Core_Trademarks_Logo__r.Content_Version_Id__c != '' && brand.Core_Trademarks_Logo__r.Content_Version_Id__c != null){
                        bottleImgMap.put(brand.id, brand.Core_Trademarks_Logo__r.Content_Version_Id__c);
                    }
                }           

                if(brand.reserve_brand__c == true){
                    if(reserveBrands.size() < 20){
                        reserveBrands.add(brand);
                    } else {
                        addAdditionalBrands(brand);
                    }
                    if(!bottleImgMap.containsKey(brand.id) && brand.Reserve_Brand_Logo__r.Content_Version_Id__c != '' && brand.Reserve_Brand_Logo__r.Content_Version_Id__c != null){
                        bottleImgMap.put(brand.id, brand.Reserve_Brand_Logo__r.Content_Version_Id__c);
                    }
                }
                
                if(brand.reserve_brand__c != true && brand.Core_Trademarks__c != true){
                    addAdditionalBrands(brand);
                    if(!bottleImgMap.containsKey(brand.id) && brand.Core_Trademarks_Logo__r.Content_Version_Id__c != '' && brand.Core_Trademarks_Logo__r.Content_Version_Id__c != null){
                        bottleImgMap.put(brand.id, brand.Core_Trademarks_Logo__r.Content_Version_Id__c);
                    }
                    if(!bottleImgMap.containsKey(brand.id) && brand.Reserve_Brand_Logo__r.Content_Version_Id__c != '' && brand.Reserve_Brand_Logo__r.Content_Version_Id__c != null){
                        bottleImgMap.put(brand.id, brand.Reserve_Brand_Logo__r.Content_Version_Id__c);
                    }
                }
                
                searchBrands.add(brand);
                if(!bottleImgMap.containsKey(brand.id)){
                    bottleImgMap.put(brand.id, '');
                }   
            }   
        }   
        if(siteTheme == 'Wine'){
            innovationBrands = Service_API.getPILBrandsNew2(true, true);
        }else{
            innovationBrands = Service_API.getPILBrandsNew2(true);
        }
        for(Brand__c brand : innovationBrands){
            if(brand.Innovation_Logo__r.Content_Version_Id__c != '' && brand.Innovation_Logo__r.Content_Version_Id__c != null){
                bottleImgMap.put(brand.id, brand.Innovation_Logo__r.Content_Version_Id__c);
            } else {
                bottleImgMap.put(brand.id, '');
            }
            searchBrands.add(brand);
        }
        brandValidNames = new Map<Id, String>();
        for(Brand__c brand : searchBrands){
            brandValidNames.put(brand.Id, brand.Name.replaceAll('[^a-zA-Z0-9]','_'));
        }
    }
    
//END OF PIL CONTROLLER
    
    public void addAdditionalBrands(Brand__c brand){
        Integer lastBrandPageNumber = additionalBrandsPage.size();
        if(additionalBrandsMap.containsKey(lastBrandPageNumber)){
            List<Brand__c> tmpList = additionalBrandsMap.get(lastBrandPageNumber);
            if(tmpList.size() < 40){
                tmpList.add(brand);
                additionalBrandsMap.put(lastBrandPageNumber, tmpList);
            } else {
                tmpList = new list<Brand__c>();
                tmpList.add(brand);
                additionalBrandsPage.add(lastBrandPageNumber+1);
                additionalBrandsMap.put(lastBrandPageNumber+1, tmpList);
            }
        }
    }
    // search categories
    public List<SelectOption> getCategories() {
        return Service_UserInput.getBrandCategories(true);
    }
    
    // switch section
    public void switchSection() {
        Set<string> sectionSet = new Set<string>(sections.values());
        if( !sectionSet.contains(currentSection) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable switch section.' ));
            return;
        }

        if(currentSection == CONSTANT.PRODUCT_SHOTS ){
            showLeftMenu = true;
            showTopMenu = true;
        } else if(currentSection == CONSTANT.LOGOS ){
            showLeftMenu = true;
            showTopMenu = false;
        } else if(currentSection == CONSTANT.FAMILY_SHOTS ){
            showLeftMenu = false;
            showTopMenu = false;
        }
        
        bottleSizes = new List<SelectOption>();         
        selectedbottleSizes = new List<String>();
                
        initPager();
        refreshPageContent();
    }
    public void renderAsList() {
        displayAsList = true; // other action if needed
    }   
    public void renderAsBox() {
        displayAsList = false; // other action if needed
    }
    public void showContent(){
        try {
            allVariantBrands = new list<brand__c>();
            detailPageLogoId = '';
            brandDetails = Service_API.getBrandInfo(detailId);   
            flExist = false;
            bottleSizes = new List<SelectOption>();         
            selectedbottleSizes = new List<String>();
            currentSection = null;
            currentSubBrandGroup = '';
            currentSubBrandGroupName = '';
            selectedBrandIds = '';
            flavorsBrands = new map<string, List<Brand__c>>();
            variantBrands = new List<Brand__c>();
            brandTranlations = new map<string, string>();
            brandSubMenuExist = new map<string, Boolean>();
            Set<string> variantGroups = new set<string>();
            Boolean isVariant = false;
            
            if(brandDetails.parent_brand__c == null){
                brandDetails = Service_API.getBrandInfo(detailId);
            } else {
                Brand__c parentBrandInfo = [select parent_brand__c from brand__c where id = :detailId];
                set<id> accesibleBrand = Service_API.getAccBrandIds();
                if(accesibleBrand.contains(parentBrandInfo.parent_brand__c)){
                    isVariant = true;
                    brandDetails = Service_API.getBrandInfo(parentBrandInfo.parent_brand__c);
                    selectedBrandIds = detailId;
                }
            }

            if(brandDetails.gradient_top_color__c != ''){
                brandHeaderStyle = 'background: #' + brandDetails.gradient_top_color__c + ';';
            } else if(brandDetails.gradient_bottom_color__c != ''){
                brandHeaderStyle = 'background: #' + brandDetails.gradient_bottom_color__c + ';';
            }
                
            if(brandDetails.gradient_top_color__c != '' && brandDetails.gradient_bottom_color__c != ''){
                brandHeaderStyle += 'background: -moz-linear-gradient(top, #' + brandDetails.gradient_top_color__c + ' 0%, #' + brandDetails.gradient_bottom_color__c + ' 100%);';
                brandHeaderStyle += 'background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#' + brandDetails.gradient_top_color__c + '), color-stop(100%,#' + brandDetails.gradient_bottom_color__c + '));';
                brandHeaderStyle += 'background: -webkit-linear-gradient(top, #' + brandDetails.gradient_top_color__c + ' 0%,#' + brandDetails.gradient_bottom_color__c + ' 100%);';
                brandHeaderStyle += 'background: -o-linear-gradient(top, #' + brandDetails.gradient_top_color__c + ' 0%,#' + brandDetails.gradient_bottom_color__c + ' 100%);';
                brandHeaderStyle += 'background: -ms-linear-gradient(top, #' + brandDetails.gradient_top_color__c + ' 0%,#' + brandDetails.gradient_bottom_color__c + ' 100%);';
                brandHeaderStyle += 'filter: progid:DXImageTransform.Microsoft.gradient(startColorStr=\'#' + brandDetails.gradient_top_color__c + '\', EndColorStr=\'#' + brandDetails.gradient_bottom_color__c + '\');';
            }
        
            if(brandDetails.font_color__c != ''){
                brandHeaderStyle += 'color: #'+brandDetails.font_color__c;
            }
            
            detailPageLogoId = brandDetails.PIL_Logo__r.Content_Version_Id__c;
            currentBrandId = brandDetails.id;
            allVariantBrands = Service_API.getPILChildBrands(brandDetails.id);
            
            // check types of variant brands (reserve)
            Boolean preSelectReserve = false;
            if(siteTheme == 'Spirits' && brandFlag == 'reserve'){
                for(brand__c vb : allVariantBrands){  
                    if(vb.Core_Trademarks__c == true){
                        preSelectReserve = true;
                        break;
                    }
                }
            }
            //
            
            for(brand__c variantBrand : allVariantBrands){              
                if(variantBrand.Brand_Variant_Grouping__c != null && variantBrand.Brand_Variant_Grouping__c != ''){
                    String groupName = variantBrand.Brand_Variant_Grouping__c.replaceAll('[^a-zA-Z0-9]', '');
                    if(groupName != null && groupName != ''){
                        brandTranlations.put(variantBrand.Brand_Variant_Grouping__c,groupName);
                        if(flavorsBrands.containsKey(groupName)){
                            list<Brand__c> tmpVariantList = flavorsBrands.get(groupName);
                            tmpVariantList.add(variantBrand);
                            
                            if(brandFlag == 'reserve'){
                                if(variantBrand.Reserve_Brand__c == true && preSelectReserve){
                                    selectedBrandIds = selectedBrandIds + ',' +variantBrand.id;
                                }                           
                            }
                            
                            flavorsBrands.put(groupName, tmpVariantList);
                        } else {
                            list<Brand__c> tmpVariantList = new list<Brand__c>();
                            tmpVariantList.add(variantBrand);
                            flavorsBrands.put(groupName, tmpVariantList);
                        }
                        
                        if(!variantGroups.contains(groupName)){
                            variantGroups.add(groupName);
                            variantBrands.add(variantBrand);
                            
                            if(brandFlag == 'reserve'){
                                if(variantBrand.Reserve_Brand__c == true && preSelectReserve){
                                    selectedBrandIds = selectedBrandIds + ',' +variantBrand.id;
                                }                           
                            }   
                                                    
                        }
                    }
                }
            }
            Set<Id> firstColumnIds = new set<Id>();
            for(Brand__c brand : variantBrands){
                if(brand.Brand_Variant_Grouping__c != null && brand.Brand_Variant_Grouping__c != ''){
                    String groupName = brand.Brand_Variant_Grouping__c.replaceAll('[^a-zA-Z0-9]', '');
                    if(groupName != null && groupName != ''){
                        if(flavorsBrands.containsKey(groupName)){
                            list<Brand__c> tmpVariantList = flavorsBrands.get(groupName);
                            if(tmpVariantList.size() == 1){
                                flavorsBrands.remove(groupName);
                                brandSubMenuExist.put(groupName, false);
                            } else {
                                brandSubMenuExist.put(groupName, true);
                                flExist = true;
                            }
                        }
                    }
                }
                firstColumnIds.add(brand.id);   
                
            }
            if(variantBrands.size() != 0){ // sort 
                variantBrands = Service_API.getPILChildBrandsByIds(firstColumnIds);
            }
            if(isVariant){
                currentSection = CONSTANT.PRODUCT_SHOTS;
                switchSection();
            }          
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load details.'));
            return;
        }
        
    }
    public override void refreshPageContent(){
        Set<ID> brandIdsSet = new set<ID>();
        try {           
            list<Id> selectedBrandIdsList = new list<Id>();
            
            if(selectedBrandIds != null && selectedBrandIds != ''){
                List<String> brandIdsListTemp = new List<String>();
                brandIdsListTemp = selectedBrandIds.split(',');
                
                for(String selectedId : brandIdsListTemp){                  
                    if(selectedId != null && selectedId != ''){
                        selectedBrandIdsList.add(Id.valueOf(selectedId));
                    }
                }
            }

			Boolean isFiltering = false;
			// get content document ids		
			if(!selectedBrandIdsList.isEmpty()) {
				isFiltering = true;
				brandIdsSet = Service_API.getContentBrandIDs(selectedBrandIdsList,CONSTANT.PRODUCT_IMAGES_AND_LOGOS, isFiltering);
			} else {
				isFiltering = false;
				List<Id> currentBrandIds = new List<ID>();
				for(Brand__c brand : allVariantBrands){
					currentBrandIds.add(brand.id);
				}
				currentBrandIds.add(currentBrandId);
				brandIdsSet = Service_API.getContentBrandIDs(currentBrandIds,CONSTANT.PRODUCT_IMAGES_AND_LOGOS, isFiltering);
			}
		
            content = new List<AggregateResult>();
            if(!brandIdsSet.isEmpty()){
                String sizeQuery = '';

                if(selectedbottleSizes != null && selectedbottleSizes.size() > 0 ){
                    String glueSize = '';
                    String sizeString = '';
                    for(String s : selectedbottleSizes){
                        sizeString += glueSize+'\''+s+'\'';
                        glueSize =', ';
                    }
                    sizeQuery = ' AND Sub_Sub_Category__c in ('+sizeString+') ';
                }

                String queryString = 'SELECT Sub_Category__c,Sub_Sub_Category__c, content_description__r.is_video__c is_video, content_description__r.video_id__c video_id, content_description__r.Title__c title, content_description__r.Description__c description, content_description__r.Content_Version_Id__c cvid, content_description__r.filetype__c filetype, content_description__r.filesize__c filesize, content_description__r.filesize_low__c filesize_low, content_description__r.Preview_Available__c previewAvailable, content_description__r.Preview_Id__c previewId, content_description__r.Content_Version_Id_Low__c cvidlow,  max(content_description__r.Uploaded_date__c) createdDate, content_description__r.image_resolution__c imageRes FROM content_property__c' + 
                        +' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') ' +
                        +' AND category__c=\''+Constant.PRODUCT_IMAGES_AND_LOGOS+'\' ' +
                        +' AND Sub_Category__c=\''+currentSection+'\' ' +
                        +' AND content_description__r.Content_ID__c in ('+IdSetToString(brandIdsSet)+') ' +
                        + sizeQuery
                        +' GROUP BY Sub_Category__c,Sub_Sub_Category__c, content_description__r.is_video__c, content_description__r.video_id__c, content_description__r.Title__c, content_description__r.Description__c, content_description__r.Content_Version_Id__c, content_description__r.filetype__c, content_description__r.Preview_Available__c, content_description__r.Preview_Id__c, content_description__r.filesize__c, content_description__r.filesize_low__c, content_description__r.Content_Version_Id_Low__c, content_description__r.image_resolution__c '+  
                        +' ORDER BY content_description__r.Description__c ASC';
                
                system.debug('==========queryString======='+queryString);
                
                content = database.query(queryString);
                numberOfItems = Integer.valueOf(content.size());
                content = getRequestedPage(content);
                // check disabled sizes
                String queryString2 = 'SELECT Sub_Sub_Category__c FROM content_property__c' + 
                            +' WHERE content_description__r.Classification__c includes (\''+Service_API.getSectionTheme()+'\') '+
                            +' AND category__c=\''+Constant.PRODUCT_IMAGES_AND_LOGOS+'\' ' +
                            +' AND Sub_Category__c=\''+currentSection+'\' ' +
                            +' AND content_description__r.Content_Id__c in ('+IdSetToString(brandIdsSet)+') ' + 
                            +' GROUP BY Sub_Sub_Category__c';
                            
                list<AggregateResult> tmpContent = database.query(queryString2);
                bottleSizes = new List<SelectOption>();     
                if(tmpContent.size() != 0 ){
                    Set<String> possibleBottleSizesSet = new Set<String>(); 
                    for(AggregateResult contentItem : tmpContent){
                        string sizeBot = (string)contentItem.get('Sub_Sub_Category__c');
                        if(sizeBot != null && sizeBot != ''){
                            possibleBottleSizesSet.add(sizeBot);
                        }
                    }               
                    Schema.DescribeFieldResult fieldResult = content_property__c.Sub_Sub_Category__c.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    for( Schema.PicklistEntry f : ple)
                    {
                        if(possibleBottleSizesSet.contains(f.getLabel())){
                            bottleSizes.add(new SelectOption(f.getLabel(), f.getValue()));
                        }
                    }   
                } else{
                    bottleSizes = new List<SelectOption>();         
                    selectedbottleSizes = new List<String>();               
                }
            } else {
                numberOfItems = 0;
                bottleSizes = new List<SelectOption>();         
                selectedbottleSizes = new List<String>();               
            }

            currentBasketIds = Service_Basket.getBasketIds();
            currentFollowIds = Service_Notification.getFollowIds();
            
        } catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load details.'));
        }
    }  
    private String IdSetToString(Set<ID> valueList){
        String result = '';
        String glue = '';
        for (String value : valueList) {
            result += glue + '\''+value+'\' ';
            glue = ',';
        }
        return result;
    }
    private String StringSetToString(Set<String> valueList){
        String result = '';
        String glue = '';
        for (String value : valueList) {
            result += glue + '\''+value+'\' ';
            glue = ',';
        }
        return result;
    }
    private String IdListToString(List<ID> valueList){
        String result = '';
        String glue = '';
        for (String value : valueList) {
            result += glue + '\''+value+'\' ';
            glue = ',';
        }
        return result;
    }
    private String StringListToString(List<String> valueList){
        String result = '';
        String glue = '';
        for (String value : valueList) {
            result += glue + '\''+value+'\' ';
            glue = ',';
        }
        return result;
    }
    
}