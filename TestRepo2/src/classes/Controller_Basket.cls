public with sharing class Controller_Basket extends Controller_Base {

    // warning popup
    public Boolean accessChanged  {get; protected set;}
    
    // content 
    public List<Basket__c> content {public get; protected set;}
    public Map<Id, DateTime> contentDate {public get; protected set;}
    public List<AggregateResult> contentDownloadShare {get; protected set;}
    public MAP<String,AggregateResultHolder> contentDetailsMap {get; protected set;}
    public Set<String> needsToBeRemoved {get; protected set;}

    // access string
    public String basketIdsString {get; protected set;}
    protected String brandIdsString {get; protected set;}

    
    public Controller_Basket() {
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), 'Basket');
		pageUrl = Page.Basket.getUrl();
		
        accessChanged = false;

        contentDownloadShare = new List<AggregateResult>();
        contentDetailsMap = new MAP<String, AggregateResultHolder>();
        content = new List<Basket__c>();
        
        initPager();
        refreshPageContent();
        
    }
    
    public void clearBasket(){
        try{
            Service_Basket.clearBasket();
            contentDownloadShare = new List<AggregateResult>();
            contentDetailsMap = new MAP<String, AggregateResultHolder>();
            content = new List<Basket__c>();
            basketIdsString = '';
        } catch(Exception e){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to clear basket.'));
            return;         
        }
    }
    
    public override void refreshPageContent() {
        accessChanged = false;
        contentDownloadShare = new List<AggregateResult>();
        contentDetailsMap = new MAP<String, AggregateResultHolder>();
        content = new List<Basket__c>();
        basketIdsString = '';
        brandIdsString = '';
        try{
            
            Set<String> cvidIds = new set<String>();
            String cvidIdsString = '';
            
            // get history
            String queryString = 'SELECT Content_Version_Id__c, CreatedDate FROM Basket__c where OwnerId = \'' + Service_API.getUID() + '\' ORDER By CreatedDate DESC limit 50000';
                    
            if(queryString != null && queryString != ''){
                content = database.query(queryString);
                numberOfItems = Integer.valueOf(content.size());
                content = getRequestedPage(content);    
            } else {
                numberOfItems = 0;          
            }
            // prepare set of Content_Version_Id__c
            for(Basket__c c :content){
                cvidIds.add(c.Content_Version_Id__c);
            }
            
            
            // get details: content description objects
            Set<ID> brandIdsSet = new Set<Id>();
            List<ID> userBrands = new List<ID>(Service_API.getAccBrandIds());
            brandIdsSet = Service_API.getContentBrandIDs(userBrands);
                
            list<AggregateResult> contentDetails = new list<AggregateResult>();
            if(!brandIdsSet.isEmpty() && !cvidIds.isEmpty()){
                String brandIdsString = IdSetToString(brandIdsSet);
                cvidIdsString = IdSetToString(cvidIds);
                String queryCD  = ' SELECT Tags__c tag, is_video__c is_video, video_id__c video_id, Title__c title, Description__c description, Content_Version_Id__c cvid, filetype__c filetype, Preview_Available__c previewAvailable, Preview_Id__c previewId, filesize__c filesize, filesize_low__c filesize_low, Content_Version_Id_Low__c cvidlow, max(Uploaded_date__c) createdDate, image_resolution__c imageRes FROM content_description__c' 
                                + ' WHERE (Content_Id__c in ('+brandIdsString+') OR (Portfolio__c=true) ) '
                                + ' AND (content_version_id__c in ('+cvidIdsString+') OR content_version_id_low__c in ('+cvidIdsString+') )' +
                                + ' GROUP BY Tags__c, is_video__c, video_id__c, Title__c, Description__c, Content_Version_Id__c, filetype__c, Preview_Available__c, Preview_Id__c, filesize__c, filesize_low__c, Content_Version_Id_Low__c, image_resolution__c ';
                list<AggregateResult> cDescr = database.query(queryCD);
                contentDetails.addAll(cDescr);                          
            }       
            
            // get details: file objects
            if(!cvidIds.isEmpty()){
                
                cvidIdsString = IdSetToString(cvidIds);
            
                Set<Id> currentDistributors = Service_API.getAIDs();
                Set<String> currentDivisions  = Service_API.getDivisions();
                if(currentDivisions.size() == 0){
                    string s ='';
                    currentDivisions.add(s);
                }
                String currentDistributorsString = IdSetToString(currentDistributors);
                String currentDivisionsString = IdSetToString(currentDivisions);
            
                // COLLABORATION / PERFORMANCE MANAGMENT
                String queryCOL     = ' SELECT Content_Version_Id__c cvid,  Tags__c, Description__c description, filesize__c filesize, filetype__c filetype, Title__c  title, is_video__c is_video, video_id__c video_id, max(Uploaded_date__c) createdDate, image_resolution__c imageRes ' 
                                    + ' FROM File__c '
                                    + ' WHERE ( ( Distributors__c includes ('+currentDistributorsString+') or Division_Access__c in ('+currentDivisionsString+') ) ';
                                    if(isInternalUser){
                                        queryCOL += ' or ( Distributors__c = null or Division_Access__c = null ) ';
                                    }   
                       queryCOL    += ' ) ' 
                                    + ' AND (content_version_id__c in ('+cvidIdsString+') )  '+         
                                    + ' GROUP BY Content_Version_Id__c, Tags__c, video_id__c,  Description__c, image_resolution__c, filesize__c, filetype__c, Title__c, is_video__c';   
                list<AggregateResult> cFileCP = database.query(queryCOL);
                contentDetails.addAll(cFileCP);
                            
                // PLANNING 
                String queryPLN     = ' SELECT  Content_Version_Id__c cvid, Description__c description, Tags__c, filesize__c filesize, filetype__c filetype, Title__c  title, is_video__c is_video, video_id__c video_id, Preview_Available__c previewAvailable, Preview_Id__c previewId, max(Uploaded_date__c) createdDate, image_resolution__c imageRes ' + 
                                    + ' FROM File__c ' +
                                    + ' WHERE (Page_Section__c = \'' + CONSTANT.PLANNING + '\' ) ' +
                                    + ' AND (content_version_id__c in ('+cvidIdsString+') )  '+ 
                                    + ' GROUP BY Tags__c, video_id__c, Content_Version_Id__c, Description__c, filesize__c, filetype__c, Title__c, is_video__c, Preview_Available__c, Preview_Id__c, image_resolution__c ';
                list<AggregateResult> cFilePL = database.query(queryPLN);
                contentDetails.addAll(cFilePL); 
            }       
            
            for(AggregateResult cDetail : contentDetails){
                String cvid = '';
                String cvidlow = '';
                try{
                    cvid = String.valueOf(cDetail.get('cvid'));
                } catch (Exception e){
                    cvid = '';
                }
                try{
                    cvidlow = String.valueOf(cDetail.get('cvidlow'));
                } catch (Exception e){
                    cvidlow = '';
                }
                if(cvidIds.contains(cvid) || cvidIds.contains(cvidlow)){
                    if(cvid != null && cvid != '' && !contentDetailsMap.containsKey(cvid)){
                        AggregateResultHolder tmp = new AggregateResultHolder();
                        tmp.result = cDetail;
                        contentDetailsMap.put(cvid, tmp);
                        contentDownloadShare.add(cDetail);
                    }
                    if(cvidlow != null && cvidlow != '' && !contentDetailsMap.containsKey(cvidlow)){
                        AggregateResultHolder tmp = new AggregateResultHolder();
                        tmp.result = cDetail;
                        contentDetailsMap.put(cvidlow, tmp);                    
                        contentDownloadShare.add(cDetail);
                    }
                }
            }
            
            // add missing map keys (content deleted or edited)
            // and remove this items from basket
            needsToBeRemoved = new Set<String>();
            for(String civid : cvidIds){
                if(!contentDetailsMap.containsKey(civid)){
                    AggregateResultHolder tmp = new AggregateResultHolder();
                    contentDetailsMap.put(civid, tmp);
                    if(!needsToBeRemoved.contains(civid)){
                        needsToBeRemoved.add(civid);
                    }
                } else {
                    AggregateResultHolder tmp = contentDetailsMap.get(civid);
                    if(tmp == null){
                        tmp = new AggregateResultHolder();
                        contentDetailsMap.put(civid, tmp);
                        if(!needsToBeRemoved.contains(civid)){
                            needsToBeRemoved.add(civid);
                        }
                    }
                }
            }

            if(needsToBeRemoved.size() != 0){
                accessChanged = true;
            }
            
            currentBasketIds = Service_Basket.getBasketIds();
            currentFollowIds = Service_Notification.getFollowIds();
                  
            contentDate = new Map<Id, DateTime>();
            for(Basket__c basket : content){
                contentDate.put(basket.id, DateTime.newInstanceGmt(basket.CreatedDate.date(), basket.CreatedDate.time()));
            }
            
        } catch( Exception err ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load content.'));
            contentDownloadShare = new List<AggregateResult>();
            contentDetailsMap = new MAP<String, AggregateResultHolder>();
            content = new List<Basket__c>();
            return;
        }
    }

    public void removeTrashFromBasket(){
        if(accessChanged){
            list<ID> trashIds = new list<ID>();
            for(String stIdToRm : needsToBeRemoved){
                trashIds.add(Id.valueof(stIdToRm));
            }
            Service_Basket.removeFromBasket(trashIds);
            refreshPageContent();
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

    private String IdSetToString(Set<String> valueList){
        String result = '';
        String glue = '';
        for (String value : valueList) {         
            result += glue + '\''+value+'\' ';
            glue = ',';
        }       
        return result;
    }

}