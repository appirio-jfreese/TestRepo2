/*****************************************************************************************************************
Name        : Controller_BlogPost.cls

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 6/14/13
Story/Task  : US503/TA1011

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 5/31/13
Story/Task  : US503/TA906/TA907/TA908
*****************************************************************************************************************/
public without sharing class Controller_BlogPost extends Controller_Base{
	public String detailPagePath {public get; protected set;}
	public String currentPageUrl {public get; protected set;}
	public String currentSectionConstant {get; private set;}
	
		// Blog Post Count
    public integer blogPostsCount { set;
        get{
            return blogPosts.size();
        }
    }
    
    // Start Side Tile : Basant
    public List<Tag__c> tagList {set; 
        get{
            return Service_API.getAllTags();
        }
    }
    public Map<String,List<Blog__c>> acrhiveMap {set;
        get{
            return buildArchiveMap();
        }
    }
    
    public Map<String,List<Blog__c>> buildArchiveMap(){
        Map<String,List<Blog__c>> archMap = new Map<String,List<Blog__c>>();

        for(Blog__c b : Service_API.getBlogRecords(null,null)){
            for(String str : monthSet(b.StartDate__c, b.EndDate__c)){
                if(!archMap.containsKey(str))
                    archMap.put(str, new List<Blog__c>());
                archMap.get(str).add(b);
            }
        }

        return archMap;
    }
       
    private Set<String> monthSet(DateTime startDate, DateTime endDate){
        Set<String> mSet = new Set<String>();
        if(startDate != null && endDate != null){
            mSet.add(getMonthName(startDate.year(), startDate.month()));
        }
        return mSet;
    }
    
    private String getMonthName(Integer year, Integer month) {
        String result;
        if (month==1) {
            result = 'January';
        } else if (month==2) {
            result = 'February';
        } else if (month==3) {
            result = 'March';
        } else if (month==4) {
            result = 'April';
        } else if (month==5) {
            result = 'May';
        } else if (month==6) {
            result = 'June';
        } else if (month==7) {
            result = 'July';
        } else if (month==8) {
            result = 'August';
        } else if (month==9) {
            result = 'September';
        } else if (month==10) {
            result = 'October';
        } else if (month==11) {
            result = 'November';
        } else if (month==12) {
            result = 'December';
        }
        return result + ' ' + year;
    }
    
    public List<String> getArchiveList(){
        List<String> archList = new List<String>();
        for(String str : acrhiveMap.keySet()){
            archList.add(str+' ('+acrhiveMap.get(str).size()+')');
        }
        return archList;
    }
    
    // End Side Tile : Basant
    // Start BlogPost Component : Basant
    public List<String> blogUrls {set; get;}    // Blog URLs from Componnet attribute - Yet Not Used
    public String blogTag {set; get;}   // Blog Tags to be filtered on, from Componnet attribute
    public String blogSTag {set; get;} // Smart Tag - Yet Not Used
    public Integer blogCount {public get; set;} // Total Number of Blogs 
    public Integer pageCount {get; private set;} // Total Number of Pages
    public Integer currPage {set; get;} // Current Page Number
    public String blogFormat {set; get;} // Blogs Display Format - Can be Titles, TitlesAndShortDesc or TitlesAndLongDesc
    public String clickedBlogId {set; get;} // Store Blog Id which is clicked for Detail View
    public List<Blog__c> allBlogPosts {public get; private set;}
    
    public String blogId { get; set; }
    public integer commentsSize { get; set; }
    public String newCommentBlogId = '';
    public String newCommentText = '';
    public String filterByTag { get; set; }
    public Map<Id, List<Comment__c>> blogComments { get; set; }
    public String theme { get; set; }
    public String archive { get; set; }
    public String startDate { get; set; }
    public String endDate { get; set; }
    
    // Start For TA906
    // Return a list of Select Option for Dislpay Option, Current Selected Value is stored in 'blogFormat'
    public List<SelectOption> getDisplayOptions() {
    List<SelectOption> options = new List<SelectOption>(); 
    options.add(new SelectOption('Titles','Titles')); 
    options.add(new SelectOption('TitlesAndShortDesc','Titles and Short Description'));
    options.add(new SelectOption('TitlesAndLongDesc','Titles and Long Description')); 
    return options; 
  }
  // End For TA906
  // List of Tags On which we have to filter all blogs
    public List<String> blogTags {set; 
        get{
            if(blogTag != null && !blogTag.trim().equals('')){
                if(blogTags == null || blogTags.size() == 0)
                    blogTags = new List<String>();
                blogTags.add(blogTag);
            }
            return blogTags;
        }
    }
    // List of Blogs to be show on current Page Only
    public List<Blog__c> blogPosts {set;
        get{
            if(blogPosts == null){
                blogPosts = getCurrentPageData(false);
            }
        return blogPosts;
        }
    }
    
    // Called when User Click on A single blog Title/ReadMore link to open Detail Page
    public Pagereference openBlogDetail(){
        Pagereference pr = Page.BPDetails;
        if(isResponsive) { pr = Page.R_BPDetails; }
        pr.getParameters().put('blogId',clickedBlogId);
        pr.setRedirect(true);
        return pr;
    }
    
    // Prepare Data for Current Page
    public List<Blog__c> getCurrentPageData(boolean loadAnyway){
    	setResponsiveState();
        Date beginningDate = Date.today();
        Date endingDate = Date.today();
        
        if(ApexPages.currentPage().getParameters().containsKey('blogTagsParam')){
            blogTags = blogTagsFromUrlPram(ApexPages.currentPage().getParameters().get('blogTagsParam'));
        }
        List<Blog__c> currData = new List<Blog__c>();
        if(blogCount == null || blogCount == 0)
            blogCount = 5;
        if(pageCount == null || pageCount == 0)
            pageCount = 0;
        if(currPage == null || currPage == 0)
            currPage = 1;
        if(startDate == null) {
            Date myDate = Date.today();
            beginningDate = beginningDate.toStartOfMonth();
            endingDate = beginningDate.addMonths(1);
        } else {
            beginningDate = date.parse(startDate);
            beginningDate = beginningDate.toStartOfMonth();
            endingDate = beginningDate.addMonths(1);
        }

        if((allBlogPosts == null || loadAnyway) && theme == null ){
            allBlogPosts = Service_API.getBlogRecords(blogUrls, blogTags);
            pageCount = (Integer)Math.ceil(Double.valueOf(String.valueOf(allBlogPosts.size()))/blogCount); 
        }
        
        if((allBlogPosts == null || loadAnyway) && theme != null ){
            allBlogPosts = Service_API.getBlogRecords(blogUrls, blogTags, theme);
            pageCount = (Integer)Math.ceil(Double.valueOf(String.valueOf(allBlogPosts.size()))/blogCount); 
        }

        
        List<Blog__c> dateSubset = new List<Blog__c>();
        for(Blog__c blog : allBlogPosts) {
            if((startDate == null && (blog.StartDate__c >= beginningDate || blog.EndDate__c<= endingDate)) || (startDate!= null && blog.StartDate__c >= beginningDate && blog.StartDate__c < endingDate)) {
                dateSubset.add(blog);
            }
        }
        
        allBlogPosts = dateSubset;
       
        pageCount = (Integer)Math.ceil(Double.valueOf(String.valueOf(allBlogPosts.size()))/blogCount);
        
        Integer currStart = (currPage-1)*blogCount;
        Integer currEnd = ((currStart + blogCount)>allBlogPosts.size()) 
                                                        ? allBlogPosts.size() : (currStart + blogCount);
        
        System.Debug('<----- currStart: ' + currStart + ' ----->');
        System.Debug('<----- currEnd: ' + currEnd + ' ----->');
        
        
        for(Integer iCount=currStart; iCount<currEnd; iCount++){
            currData.add(allBlogPosts.get(iCount));
        }
        
        blogPosts = currData;
        
        return currData;
    }
    
    public PageReference showForTag() {
        theme = null;
        
        blogTags = new List<String>();
        blogTags.add(filterByTag);
        
        blogUrls = new List<String>();
        
        blogCount = null;
        pageCount = null;
        currPage = null;

        System.Debug('<----- filterByTag: ' + filterByTag + ' ----->');
        System.Debug('<----- blogTags: ' + blogTags + ' ----->');
        System.Debug('<----- blogUrls: ' + blogUrls + ' ----->');
        blogPosts = getCurrentPageData(true);                

        return null;    
    }
    
    public PageReference switchToTag() {
        theme = null;
        Pagereference pr = Page.BlogHome;
        if(isResponsive) { pr = Page.R_BlogHome; }
        pr.getParameters().put('filterByTag',filterbyTag);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference switchToTheme() {
        blogTags = new List<String>();
        blogUrls = new List<String>();
        
        blogCount = null;
        pageCount = null;
        currPage = null;

        System.Debug('<----- filterByTag: ' + filterByTag + ' ----->');
        System.Debug('<----- blogTags: ' + blogTags + ' ----->');
        System.Debug('<----- blogUrls: ' + blogUrls + ' ----->');
        blogPosts = getCurrentPageData(true);                  

        return null;     
    }
    
    public PageReference switchToArchive() {
        String arcMonth = archive.substring(0,archive.indexOf(' '));
        archive = archive.substring(archive.indexOf(' ') + 1);
        String arcYear = archive.substring(0,archive.indexOf(' '));
        
        if(arcMonth == 'January') { arcMonth = '01'; }
        else if(arcMonth == 'February') { arcMonth = '02'; }
        else if(arcMonth == 'March') { arcMonth = '03'; }
        else if(arcMonth == 'April') { arcMonth = '04'; }
        else if(arcMonth == 'May') { arcMonth = '05'; }
        else if(arcMonth == 'June') { arcMonth = '06'; }
        else if(arcMonth == 'July') { arcMonth = '07'; }
        else if(arcMonth == 'August') { arcMonth = '08'; }
        else if(arcMonth == 'September') { arcMonth = '09'; }
        else if(arcMonth == 'October') { arcMonth = '10'; }
        else if(arcMonth == 'November') { arcMonth = '11'; }
        else if(arcMonth == 'December') { arcMonth = '12'; }
        
        startDate = arcMonth + '/01/' + arcYear;
        
        blogTags = new List<String>();
        blogUrls = new List<String>();
        
        blogCount = null;
        pageCount = null;
        currPage = null;

        System.Debug('<----- filterByTag: ' + filterByTag + ' ----->');
        System.Debug('<----- blogTags: ' + blogTags + ' ----->');
        System.Debug('<----- blogUrls: ' + blogUrls + ' ----->');
        blogPosts = getCurrentPageData(true); 
                
        return null;
    }
    
    // Called when Page Number Changed on UI or Next/Previous Button clicked
    public Pagereference pageChanged(){
        blogPosts = getCurrentPageData(true);
        return null;
    }
    
    // Navigate to Previous Page
    public Pagereference previousPage(){
        currPage--;
        blogPosts = getCurrentPageData(false);
        return null;
    }
    
    // Navigate to Next Page
    public Pagereference nextPage(){
        currPage++;
        blogPosts = getCurrentPageData(false);
        return null;
    }
    
    // Create A single URL Parameter String from Current Tag List (filter Criteria)
    private String blogTagsUrlPram(){
        String parmStr = '';
        if(blogTags != null){
            for(String str : blogTags){
                parmStr += str + '~~~';
            }
            if(!parmStr.trim().equals(''))
                parmStr = parmStr.substring(0, parmStr.length()-3);
        }
        return parmStr;
    }
    
    // Regain Tag List from URL Parameter
    private List<String> blogTagsFromUrlPram(String parmStr){
        List<String> bTags = new List<String>();
        if(!parmStr.trim().equals('')){
            for(String str : parmStr.split('~~~')){
                bTags.add(str);
            }
        }
        return bTags;
    }
    // END BlogPost Component : Basant
    
    // Start Detail Page : By Parul
    public String backToBlogPostsUrl {get; private set;} // URL of Last Page viewed
    public Integer bpIndex {
    	public get{
    		if(bpIndex == null)
    			bpIndex = 1;
    		return bpIndex;
    	} 
    protected set;} // Index of Currntly showing Blog in All Blog's List
    public Blog__c blogItem {public get; protected set;} // Current Blog Record
    public Comment__c newComment {public get; protected set;} // New Comment can be made by user through UI
    
    // Process any filters passed from another page before displaying the list
    public PageReference processFilters() {
    	setResponsiveState();
        if(ApexPages.currentPage().getParameters().get('filterByTag') != null){
            filterByTag = ApexPages.currentPage().getParameters().get('filterByTag');
            System.Debug('<----- processFilters:filterByTag: ' + filterByTag + ' ----->');
            showForTag();
        }
        return null;
    }
    
    // Called whne Detail Page Loaded first Time just After Clicking on a Blog from List
    public PageReference initBPDetails() {
    	setResponsiveState();
        backToBlogPostsUrl = Page.BlogPosts.getUrl();
        if(isResponsive) { backToBlogPostsUrl = Page.R_BlogPosts.getUrl(); }
        pageUrl = ApexPages.currentPage().getUrl();
        
        System.Debug('<----- pageUrl: ' + pageUrl + ' ----->');
      
        if(ApexPages.currentPage().getParameters().get('blogId') != null){
            String blogId = ApexPages.currentPage().getParameters().get('blogId');
            
            String myQuery = 'Select Id, Name, AllowComments__c, Detail__c, EndDate__c, ' + 
                ' StartDate__c, Sub_Title__c, Summary__c, Theme__c, CreatedById, CreatedBy.Name, CreatedDate, ' + 
                ' (Select Id, Comment__c, CreatedById, CreatedBy.Name, CreatedDate From Comment__r Order By CreatedDate), ' + 
                ' (Select Id, Tag__c, Tag__r.Name From Blog2Tag__r), ' + 
                ' (Select Id, Brand__c, Brand__r.Name, Brand__r.Brand_Type__c From Blog2Brand__r) ' + 
                ' From Blog__c Where ID =: blogId';
            
            blogItem = Database.query(myQuery);                    
        }

        newComment = new Comment__c();
        return null;
    }
  
  // Allow user to post a new Comment
    public PageReference postComment(){
        Pagereference p = Page.BPDetails;
        if(isResponsive) { p = Page.R_BPDetails; }
        newComment.Blog__c = blogItem.id;
        insert newComment;
        blogItem.Comment__r.add(newComment);
        p.getParameters().put('BlogPostIndex', String.valueOf(bpIndex));
//        p.setRedirect(true);
        return p;
    }
    
    // Naviagate to Previous Post
    public PageReference previousPost(){
        if(bpIndex > 0){
            bpIndex--;
            blogItem = allBlogPosts.get(bpIndex);
        }       
        return null;
    }
    
    // Naviagate to Next Post
    public PageReference nextPost(){
        if(bpIndex < allBlogPosts.size()-1)
            bpIndex++;
            blogItem = allBlogPosts.get(bpIndex); 
        return null;
    }
    // End Detail Page : By Parul  
		 
		// End : Changes for US503/TA1011 : Comment All Blog Code - Basant

	private void prepareBreadcrumbs(){
		cleanBreadcrumbs();
		
		// Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13
//       	currentPageUrl = Page.InnovationAndVAP.getUrl();
		currentPageUrl = ApexPages.currentPage().getUrl();
		if(isResponsive) {
			detailPagePath = Page.R_IVAPDetails.getUrl();
		} else {
        	detailPagePath = Page.IVAPDetails.getUrl();
		}
		//End:

        detailPagePath += '&'+parseSelectedThemesToUrl();
        
        addBreadcrumbItem(currentPageUrl, currentSectionConstant);
	}    
    
	// Start: Changes for Responsive Site - Randy Wandell (Appirio) 7/10/13    
    public void setResponsiveState() {
		pageUrl = ApexPages.currentPage().getUrl();
		if(pageUrl.toLowerCase().indexOf('r_bpdetails') > -1 || pageUrl.toLowerCase().indexOf('r_bloghome') > -1) {
			isResponsive = true;
			preapareSiteNavigationMenu();
		} else {
			isResponsive = false;
			preapareSiteNavigationMenu();
		}    	
    }
    // End:		
}