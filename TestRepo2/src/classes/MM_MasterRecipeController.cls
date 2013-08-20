public with sharing class MM_MasterRecipeController extends MM_RecipeBase {
    
    public Id recipeId {get; set;}
    public Id cloneFromId {get; set;}
    public String newRecipe {get; set;}
    public List<Recipe__c> childRecipes;
    public List<Recipe__c> allApproved;
    public String whereClause {get; set;}
    public String queryString {get; set;}
    public String rQuery{get; set;}
    public String searchTerm {get; set;}
    public string selectedAlphabet{get;set;}
    public Map<Id,User> authorMap {get;set;}
    public string currentAlpha{get;set;}
    public integer PAGE_SIZE = 15;
    public MM_MasterRecipeController (String recipeId, String newRecipe) {
        this.recipeId = recipeId;
        this.newRecipe = newRecipe;
        
        constructorProcessing();
    }

    public MM_MasterRecipeController() {
        
        recipeId = ApexPages.currentPage().getParameters().get('recipeId');
        newRecipe = ApexPages.currentPage().getParameters().get('newRecipe');
        authorMap = new Map<Id,User>([SELECT Id, Name From User]);
        
        constructorProcessing();
    }
    
    public void constructorProcessing () {
    	
    		   rQuery = 'SELECT Comments__c, CreatedById, CreatedDate, IsDeleted, Language__c, LastActivityDate, LastModifiedById,'; 
               rQuery+='LastModifiedDate, Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, Master_Recipe__r.Name, Master_Recipe__r.Id, Menu_Description__c,';
               rQuery+='Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c,Mobile_Selected_Image__c, Mobile_Selected_Image__r.Content_Id__c, Mobile_Unselected_Image__c,Mobile_Unselected_Image__r.Content_Id__c,Recipe_Title__c,Occasion__c, Occasion_Type__c,'; 
               rQuery+='Preparation_Steps__c,Recipe_Color_del__c, Recipe_Flavor_del__c, Recipe_Tag__c, Name, Recipe_Type_del__c,Recipe_Version__c, Id, Short_Description__c, Status__c, SystemModstamp, Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c,Main_Drink_Image__r.Content_id__c,';
               rQuery+='Main_Ingredient_Image__r.Content_id__c,Mobile_Drink_Image__r.Content_id__c,Additional_Image_1__r.Content_id__c,Additional_Image_2__r.Content_id__c,Additional_Image_3__r.Content_id__c,Additional_Image_4__r.Content_id__c,Background_Image__c,Background_Image__r.Content_id__c,Brand_Recipe_Image__c,';
               rQuery+='Brand_Recipe_Image__r.Content_id__c,Search_Recipe_Image__c,Search_Recipe_Image__r.Content_id__c FROM Recipe__c';
              searchTerm='' ; 
              selectedAlphabet = 'A';                 
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@13NewRecipe@@@@@@@@@@@@@@@@@@@@@@'+newRecipe);
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@13NewRecipe@@@@@@@@@@@@@@@@@@@@@@'+recipeId);
        if (recipeId != null)
            getChildRecipes();
        else
            getAllApproved();
        
    }
    
    
     
    public List<recipeWrapper> getChildRecipes() {
        List<recipeWrapper> rw= new List<recipeWrapper>();
            if (getIsSuperAdmin())
                childRecipes = [SELECT Comments__c, CreatedById, CreatedDate, IsDeleted, Language__c, LastActivityDate, LastModifiedById, 
                                        LastModifiedDate, Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, 
                                        Master_Recipe__r.Name, Master_Recipe__r.Id, Menu_Description__c, Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c, 
                                        Mobile_Selected_Image__c, Mobile_Selected_Image__r.Content_Id__c, Mobile_Unselected_Image__c, 
                                        Mobile_Unselected_Image__r.Content_Id__c,Recipe_Title__c,Occasion__c, Occasion_Type__c, Preparation_Steps__c, 
                                        Recipe_Color_del__c, Recipe_Flavor_del__c, Recipe_Tag__c, Name, Recipe_Type_del__c, 
                                        Recipe_Version__c, Id, Short_Description__c, Status__c, SystemModstamp, 
                                        Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c,Main_Drink_Image__r.Content_id__c,
                                        Main_Ingredient_Image__r.Content_id__c,Mobile_Drink_Image__r.Content_id__c,Additional_Image_1__r.Content_id__c,
                                        Additional_Image_2__r.Content_id__c,Additional_Image_3__r.Content_id__c,Additional_Image_4__r.Content_id__c,
                                        Additional_Image_5__r.Content_id__c,Background_Image__c,Background_Image__r.Content_id__c,Brand_Recipe_Image__c,
                                        Brand_Recipe_Image__r.Content_id__c,Search_Recipe_Image__c,Search_Recipe_Image__r.Content_id__c
                                   FROM Recipe__c
                                  WHERE Master_Recipe__c = :recipeId
                                  AND recordSaved__c = true
                                  order by Recipe_Title__c limit 999];
            else
                childRecipes = [SELECT Comments__c, CreatedById, CreatedDate, IsDeleted, Language__c, LastActivityDate, LastModifiedById, 
                                        LastModifiedDate, Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, 
                                        Master_Recipe__r.Name, Master_Recipe__r.Id, Menu_Description__c, Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c, 
                                        Mobile_Selected_Image__c, Mobile_Selected_Image__r.Content_Id__c, Mobile_Unselected_Image__c, 
                                        Mobile_Unselected_Image__r.Content_Id__c,Recipe_Title__c,Occasion__c, Occasion_Type__c, Preparation_Steps__c, 
                                        Recipe_Color_del__c, Recipe_Flavor_del__c, Recipe_Tag__c, Name, Recipe_Type_del__c, 
                                        Recipe_Version__c, Id, Short_Description__c, Status__c, SystemModstamp, 
                                        Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c,Main_Drink_Image__r.Content_id__c,
                                        Main_Ingredient_Image__r.Content_id__c,Mobile_Drink_Image__r.Content_id__c,Additional_Image_1__r.Content_id__c,
                                        Additional_Image_2__r.Content_id__c,Additional_Image_3__r.Content_id__c,Additional_Image_4__r.Content_id__c,
                                        Additional_Image_5__r.Content_id__c,Background_Image__c,Background_Image__r.Content_id__c,Brand_Recipe_Image__c,
                                        Brand_Recipe_Image__r.Content_id__c,Search_Recipe_Image__c,Search_Recipe_Image__r.Content_id__c
                                   FROM Recipe__c
                                  WHERE Master_Recipe__c = :recipeId
                                    AND Status__c <> 'Archived'
                                     AND recordSaved__c = true
                                  order by Recipe_Title__c limit 999];                           
    

       for(Recipe__c r:childRecipes)
       rw.add(new recipeWrapper(r));

        return rw;
        
    }
    
    public pageReference filterResults(){
    	system.debug('@@@@@@@@@@@@@@@@@@@@@@@@89 Current Alphabet@@@@@@@@@@@'+searchTerm);	
    	system.debug('@@@@@@@@@@@@@@@@@@@@@@@@89 Current Alphabet@@@@@@@@@@@'+searchTerm.length());
    	if (searchTerm != null && searchTerm.trim() != ''){
    		string cleanSearch;
    		cleanSearch = '%' +searchTerm + '%';
    		
    		whereClause = ' WHERE Recipe_Title__c like \'';
    		whereClause += cleanSearch+'\' AND Status__c = \'Approved\' AND recordSaved__c = true order By Recipe_Title__c';
				
		}
		else { 
			string currentAlphabet;
			if(selectedAlphabet != null && selectedAlphabet.trim()!=''){
				currentAlphabet = selectedAlphabet;
				currentAlpha = selectedAlphabet;
			}
			else{
				currentAlphabet = 'A';
				currentAlpha = 'A';
			}
			
			//currentAlphabet  = 	currentAlphabet + '%';
			system.debug('@@@@@@@@@@@@@@@@@@@@@@@@104 Current Alphabet@@@@@@@@@@@'+currentAlphabet);		
			whereClause = ' WHERE Recipe_Title__c like\'';
    		whereClause += currentAlphabet+'%\' AND Status__c = \'Approved\' AND recordSaved__c = true order By Recipe_Title__c';
		}
		system.debug('@@@@@@@@@@@@@@@@@@@@@@108Where Clause@@@@@@@@@@@@@@@@@@@@@@@@@@@'+whereClause);
		system.debug('@@@@@@@@@@@@@@@@@@@@@@109 rQuery @@@@@@@@@@@@@@@@@@@@@@@@@@@'+rQuery);
		
		queryString = rquery+whereClause;
		system.debug('@@@@@@@@@@@@@@@@@@@@@@109 rQuery @@@@@@@@@@@@@@@@@@@@@@@@@@@'+queryString);
		con = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
		con.setPageSize(PAGE_SIZE);		
		whereClause = null;
		return null;	
    }
    
    public pageReference clearResults(){
    	system.debug('@@@@@@@@@@@@@@@@@@@@searchTerm@@@@@@@@@@@@@'+searchTerm);
    	if(searchTerm != null)
    		searchTerm = '';
    	if(selectedAlphabet != null)	
    		selectedAlphabet = 'A';
    		filterResults();
    		system.debug('@@@@@@@@@@@@@@@@@@@@searchTerm@@@@@@@@@@@@@'+searchTerm);
   return null;	
    	
    }
    
    // instantiate the StandardSetController from a query locator
	public ApexPages.StandardSetController con {
		get {
			if(con == null) {
				whereClause = ' WHERE Recipe_Title__c like\'A%\' AND Status__c = \'Approved\' AND recordSaved__c = true order By Recipe_Title__c';
				queryString = rQuery + whereClause ;
				system.debug('@@@@@@@@@@@@@@@@@@@@@@126Where Clause@@@@@@@@@@@@@@@@@@@@@@@@@@@'+whereClause);
				system.debug('@@@@@@@@@@@@@@@@@@@@@@127 rQuery @@@@@@@@@@@@@@@@@@@@@@@@@@@'+queryString);
				con = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
				// sets the number of records in each page set
				con.setPageSize(PAGE_SIZE);
			}
			return con;
		}
		set;
	}
	
	
    
    public PageReference searchRecipe(){                         
        return null;    
    }
    
    public List<recipeWrapper> getAllApproved() {
    	List<recipeWrapper> rw= new List<recipeWrapper>();
    	List<Recipe__c> tempList = (List<Recipe__c>)con.getRecords();
      
      	for (Recipe__c recipe : tempList )
         rw.add(new recipeWrapper(recipe));
      	 
      	 return rw;
    	
    }
    
    public PageReference cloneRecipe(){
        
        Id newId = MM_Utility.cloneRecipeInformation(cloneFromId);
        PageReference pageRef = new PageReference('/apex/MM_RecipeView?isClone=true&editMode=true&recipeId=' + newId);
        pageRef.getParameters().put('prevPage', 'clone'); 
        pageRef.setRedirect(true);

        return pageRef;
        
    }   
    
    
    public String getUserAgent() { 
	 	return ApexPages.currentPage().getHeaders().get('User-Agent');
	}
	
	private list<string> alphaSet = new list<string>();
	public list<string> getAlphabets(){
		alphaSet.clear();
			alphaSet.add('A');
			alphaSet.add('B');
			alphaSet.add('C');
			alphaSet.add('D');
			alphaSet.add('E');
			alphaSet.add('F');
			alphaSet.add('G');
			alphaSet.add('H');
			alphaSet.add('I');
			alphaSet.add('J');
			alphaSet.add('K');
			alphaSet.add('L');
			alphaSet.add('M');
			alphaSet.add('N');
			alphaSet.add('O');
			alphaSet.add('P');
			alphaSet.add('Q');
			alphaSet.add('R');
			alphaSet.add('S');
			alphaSet.add('T');
			alphaSet.add('U');
			alphaSet.add('V');
			alphaSet.add('W');
			alphaSet.add('X');
			alphaSet.add('Y');
			alphaSet.add('Z');
			
			return alphaSet;
		
	}
	
	public pageReference refreshPanel(){
		return null;
	}
	
	
	// indicates whether there are more records after the current page set.
	public Boolean hasNext {
		get {
			return con.getHasNext();
		}
		set;
	}
 
	// indicates whether there are more records before the current page set.
	public Boolean hasPrevious {
		get {
			return con.getHasPrevious();
		}
		set;
	}
 
	// returns the page number of the current page set
	public Integer pageNumber {
		get {
			return con.getPageNumber();
		}
		set;
	}
 
	// returns the first page of records
 	public void first() {
 		con.first();
 	}
 
 	// returns the last page of records
 	public void last() {
 		con.last();
 	}
 
 	// returns the previous page of records
 	public void previous() {
 		con.previous();
 	}
 
 	// returns the next page of records
 	public void next() {
 		con.next();
 	}
 
 	// returns the PageReference of the original page, if known, or the home page.
 	public void cancel() {
 		con.cancel();
 	}
 	
 	public Integer totalRecords {
		get {
			return con.getResultSize();
		}
		set;
	}
	
	public Integer currentStartRecord {
		get {
			return (pageNumber*PAGE_SIZE)-14;
		}
		set;
	}
	
	public Integer currentEndRecord {
		get {
			if (hasNext)
				return currentStartRecord+(PAGE_SIZE-1);
			else{
				Integer tmp = Math.mod(totalRecords,PAGE_SIZE);
				if (tmp == 0)
					return (PAGE_SIZE-1)+currentStartRecord;
				else
					return (tmp-1)+currentStartRecord;
					
			}
		}
		set;
	}	

    
}