/* Modified By  : Rishi Khirbat(Appirio Offshore on 17th-Dec-2012)
   Details      : Modified against T-104880: Add Recently Approved Recipes to MM_RecipeDashboard. 
*/
public with sharing class MM_RecipeDashboardController extends MM_RecipeBase {

	private List<RecipeContainer> draftRecipes = new List<RecipeContainer>();
   	private List<RecipeContainer> approvedRecipes = new List<RecipeContainer>();
   	private List<RecipeContainer> rejectedRecipes = new List<RecipeContainer>();
   	private List<RecipeContainer> pendingRecipes = new List<RecipeContainer>();
   	private List<RecipeContainer> archivedRecipes = new List<RecipeContainer>();
   	private List<RecipeContainer> sentRecipes = new List<RecipeContainer>();   
   	
   	private Boolean hasApprovedRecipes;
   	private Boolean hasPendingRecipes;
   	private Boolean hasDraftRecipes;
   	private Boolean hasRejectedRecipes;
   	private Boolean hasArchivedRecipes; 
   	private Boolean hasSentRecipes;
   	
   	private Boolean superAdminCheck = false;
   	public String orderBy {get;set;}
   	public String reviewerCriteria {get;set;}
   	public String editorCriteria {get;set;}
   	public String approverCriteria {get; set;}
   	public Map<Id,User> authorMap {get;set;}
   	private String recipeId;
   
   	public list<Id> recipeIds = new list<Id>();
   	public list<Id> recipeRejIds = new list<Id>();
   
   	transient list<Recipe__c> totalApprovedRecipes = new list<Recipe__c>();
   	public list<Recipe__c> totalRejectedRecipes = new list<Recipe__c>();
   	public list<Recipe__c> totalDraftRecipes = new list<Recipe__c>();
   	public list<Recipe__c> totalPendingRecipes = new list<Recipe__c>();
   	public list<Recipe__c> totalArchivedRecipes = new list<Recipe__c>();
   	transient list<Recipe__c> totalRecipeCount = new list<Recipe__c>();
   
   	public integer draftRecipeCount{get;set;}
   	public integer approvedRecipeCount{get;set;}
   	public integer rejectedRecipeCount{get;set;}
   	public integer pendingRecipeCount{get;set;}
   	public integer archivedRecipeCount{get;set;}
  	 
   	public string queryString{get;set;}
   	public string approvedQueryString{get;set;}
   	public string pendingApprovalQueryString{get;set;}
   	public string rejectedQueryString{get;set;}
   	public string archivedQueryString{get;set;}
   	
   	public integer limitValue{get;set;}
   	public integer currentEditorLimitValue{get;set;}
   	public Integer currentApprovedLimitValue{get;set;}
   	public Integer currentPendingApprovalLimitValue{get;set;}
   	public Integer currentRejectedLimitValue{get;set;}
   	public Integer currentArchivedLimitValue{get;set;}
   	
   	public integer EditCounter{get;set;}
   	public integer approvedCounter{get;set;}
   	public integer pendingApprovalCounter{get;set;}
   	public integer rejectedCounter{get;set;}
   	public integer archivedCounter{get;set;}
   
  	public integer currentLimitValue{get;set;}
  	public integer currentALimitValue{get;set;}
  	
  	/*
   	Rishi Khirbat(Appirio Offshore on 17th-Dec-2012)
   	Details: Modified against T-104880: Add Recently Approved Recipes to MM_RecipeDashboard. 
   	*/
  	private List<RecipeContainer> recentlyApproveRecipes = new List<RecipeContainer>();
  	public Integer currentRecentlyApprovedLimitValue{get;set;}
  	public integer recentlyApprovedRecipeCount{get;set;}
  	public string recentlyApprovedQueryString{get;set;}
  	public integer recentlyApprovedCounter{get;set;}
  	//private Boolean hasRecentlyApprovedRecipes;
  	List<Id> recentlyApprovedRecipeIds = new List<Id>();
  	/************/
  	    
   	public MM_RecipeDashboardController() {
		
      	authorMap = new Map<Id,User>([SELECT Id, Name From User]);      
      	recipeRejIds = MM_Utility.getCurrentRejectedRecipesByUser(UserInfo.getUserId(),'Rejected');      
		recipeIds = MM_Utility.getRecipesByApprover(UserInfo.getUserId());
      	superAdminCheck = getIsSuperAdmin();
            
      	integer appCount = 0;
      	integer apadCount = 0;
      	limitValue = 5;
      	currentEditorLimitValue = 5;
      	currentRecentlyApprovedLimitValue = 5;
      	currentApprovedLimitValue = 5;
      	currentPendingApprovalLimitValue = 5;
      	currentRejectedLimitValue = 5;
      	currentArchivedLimitValue = 5;
          
      	EditCounter = 1;
      	recentlyApprovedCounter = 1;
      	approvedCounter = 1;
      	pendingApprovalCounter = 1;
      	rejectedCounter = 1;
      	archivedCounter = 1;
 
        totalRecipeCount = [SELECT CreatedById, CreatedDate, IsDeleted, LastActivityDate, LastModifiedById, 
          					LastModifiedDate, Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, 
          					Menu_Description__c, Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c, Mobile_Selected_Image__c, 
          					Mobile_Selected_Image_URL__c, Mobile_Unselected_Image__c, Mobile_Unselected_Image_URL__c,Recipe_Title__c,Occasion__c, 
          					Occasion_Type__c, Preparation_Steps__c, Recipe_Color_del__c, Recipe_Flavor_del__c, Recipe_Tag__c, 
         	 				Name, Recipe_Type_del__c, Id, Short_Description__c, Status__c,Current_Editor__c,SystemModstamp, Thumbnail_Drink_Image__c, 
          					Thumbnail_Drink_Image_URL__c, recordSaved__c 
                        	FROM Recipe__c
                         	WHERE recordSaved__c = true  
                         	ORDER BY LastModifiedDate];
          
		for(Recipe__c totRec : totalRecipeCount) {
			if(totRec.Status__c == 'Approved') {
            	if(superAdminCheck == true) {
					totalAPprovedRecipes.add(totRec);   
                    apadCount++;
				} else if(totRec.Current_Editor__c == UserInfo.getUserId()) {
					totalAPprovedRecipes.add(totRec);       
                    appCount++;
				}
			}
            if(totRec.Status__c == 'Rejected') {
				if(totRec.Current_Editor__c ==UserInfo.getUserId()){         
                	totalRejectedRecipes.add(totRec); 
				} else if(superAdminCheck == true) {
					totalRejectedRecipes.add(totRec);  
				}  
                if(recipeRejIds.size()>0) {
					for(Id reId : recipeRejIds) {
                    	if(totRec.Id != null && reId !=null) {
                        	if(totRec.Id == reId) {
								totalRejectedRecipes.add(totRec);
							}               
						}
					}     
				}
			}
			if(totRec.Status__c == 'Draft'){
				if(totRec.Current_Editor__c ==UserInfo.getUserId()){         
					totalDraftRecipes.add(totRec);            
				}
			}
			if(totRec.Status__c == 'Pending Review' || totRec.Status__c == 'Pending Approval') {
				if(totRec.Current_Editor__c ==UserInfo.getUserId()) {
					totalPendingRecipes.add(totRec);    
				}  
				if(recipeIds.size()>0) {
					for(Id recipId : recipeIds){
						if(totRec.Id != null && recipId !=null){
							if(totRec.Id == recipId){
								totalPendingRecipes.add(totRec);
							}
						}               
					}
				}
			}
			if(totRec.Status__c == 'Archive'){
				if(superAdminCheck == true){
					totalArchivedRecipes.add(totRec);    
				}  
			}
		} 
		
		/*
	   	Rishi Khirbat(Appirio Offshore on 17th-Dec-2012)
	   	Details: Modified against T-104880: Add Recently Approved Recipes to MM_RecipeDashboard. 
	   	*/
		for(Recipe__History recipeHistory :[Select ParentId, NewValue  From Recipe__History Where Field='Status__c' order by CreatedDate desc]) {
			if(recipeHistory.NewValue == 'Approved' && recentlyApprovedRecipeIds.size() <= 20) {
				recentlyApprovedRecipeIds.add(recipeHistory.ParentId);
			}
		}
		recentlyApprovedRecipeCount = recentlyApprovedRecipeIds.size();
		/******************/
		
		draftRecipeCount = totalDraftRecipes.size();
		approvedRecipeCount = totalApprovedRecipes.size();
		rejectedRecipeCount = totalRejectedRecipes.size();
		pendingRecipeCount = totalPendingRecipes.size();
		archivedRecipeCount = totalArchivedRecipes.size();
	}
   
   
   public void setRecipeId(String s){
      recipeId = s;
   }
   
   public String getRecipeId(){
      return recipeId;
   }
   
   public String getAuthorName(Id aId){
      return authorMap.get(aId).Name;
   }

   public List<RecipeContainer> getDraftRecipes() {
        //query heree
     string currentUseId = UserInfo.getUserId();
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@into DraftRecipes@@@@@@@@@@@@@@@@@@' + currentEditorLimitValue);
      //if (draftRecipes == null){
         draftRecipes = new List<RecipeContainer>();
      //   system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@60IntoContainer@@@@@@@@@@@@@@@@');
         
      //}
       queryString = 'SELECT CreatedById, CreatedDate, IsDeleted, LastActivityDate, LastModifiedById,';
       queryString += 'LastModifiedDate, Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, Menu_Description__c,'; 
       queryString += 'Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c, Mobile_Selected_Image__c, Mobile_Selected_Image_URL__c,';
       queryString += 'Mobile_Unselected_Image__c, Mobile_Unselected_Image_URL__c, Occasion__c, Occasion_Type__c, Preparation_Steps__c,';
       queryString += 'Recipe_Color_del__c, Recipe_Flavor_del__c, Recipe_Tag__c, Name,Recipe_Title__c, Recipe_Type_del__c, Id,Current_Editor__c,Short_Description__c,'; 
       queryString += 'Status__c, SystemModstamp, Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c, recordSaved__c';
       queryString += ' FROM Recipe__c WHERE Status__c = \'Draft\' AND Current_Editor__c = \''+currentUseId+'\' AND recordSaved__c = true ORDER BY LastModifiedDate desc limit '+currentEditorLimitValue;
      
   
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Query String for @@@@@@@@@@@@@@@@@'+queryString);
      //DataBase.query(queryString+' '+'limit'+' '+'5')
       for (Recipe__c r : DataBase.query(queryString)){
         RecipeContainer rc = new RecipeContainer();
         rc.authorName = getAuthorName(r.CreatedById);
         rc.recipe = r;
         
         draftRecipes.add(rc);   
               
       }
       
       return draftRecipes;

   }
   
   public Boolean getHasDraftRecipes(){
      return !draftRecipes.isEmpty();
   }  
   
   	/*
   	Rishi Khirbat(Appirio Offshore on 17th-Dec-2012)
   	Details: Modified against T-104880: Add Recently Approved Recipes to MM_RecipeDashboard. 
   	*/
   	public List<RecipeContainer> getRecentlyApprovedRecipes() {
   		string currentUseId = UserInfo.getUserId();
      	superAdminCheck = getIsSuperAdmin();
        recentlyApproveRecipes = new List<RecipeContainer>();
        
        recentlyApprovedQueryString = 'SELECT CreatedById, CreatedDate, IsDeleted, LastActivityDate, LastModifiedById,';
       	recentlyApprovedQueryString += ' LastModifiedDate, Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, Menu_Description__c,'; 
       	recentlyApprovedQueryString += ' Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c, Mobile_Selected_Image__c, Mobile_Selected_Image_URL__c,';
       	recentlyApprovedQueryString += ' Mobile_Unselected_Image__c, Mobile_Unselected_Image_URL__c, Occasion__c,Recipe_Title__c, Occasion_Type__c, Preparation_Steps__c,';
       	recentlyApprovedQueryString += ' Recipe_Color_del__c, Recipe_Flavor_del__c, Recipe_Tag__c, Name, Recipe_Type_del__c, Id,Current_Editor__c,Short_Description__c,'; 
       	recentlyApprovedQueryString += ' Status__c, SystemModstamp, Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c, recordSaved__c';
       	recentlyApprovedQueryString += ' FROM Recipe__c WHERE Status__c = \'Approved\'' ;
       	
       	if(recentlyApprovedRecipeIds.isEmpty()) {
			recentlyApprovedQueryString += ' And Id IN (\'\')';
		} else {
			recentlyApprovedQueryString += ' And Id IN ';
			recentlyApprovedQueryString += parseListForQuery(recentlyApprovedRecipeIds);
		}
       	
      	if(superAdminCheck == true)  
       		recentlyApprovedQueryString += ' ORDER BY LastModifiedDate desc limit '+currentRecentlyApprovedLimitValue;
      	else
        	recentlyApprovedQueryString += ' AND Current_Editor__c = \''+currentUseId+'\' ORDER BY LastModifiedDate desc limit '+currentRecentlyApprovedLimitValue;
     
     	system.debug('==========================QueryString: '+ recentlyApprovedQueryString);
     	
     	//Create a map from the Recipe Ids to Recipe objects. 
     	map<Id, Recipe__c> mapRetrievedRecipe = new map<Id, Recipe__c>();
     	//For loop to iterate through all the queried PricebookEntry records
     	for (Recipe__c r :DataBase.query(recentlyApprovedQueryString)) {
			mapRetrievedRecipe.put(r.id,r);
		}
		
		superAdminCheck = getIsSuperAdmin();
		for (Id rId :recentlyApprovedRecipeIds) {
			Recipe__c recipe = mapRetrievedRecipe.get(rId);
        	if(recipe != null) {
        		if(superAdminCheck == true) {
	         		RecipeContainer rc = new RecipeContainer();
	         		rc.authorName = getAuthorName(recipe.CreatedById);
	         		rc.recipe = recipe; 
	         		recentlyApproveRecipes.add(rc);   
	         	} else if(recipe.Current_Editor__c == UserInfo.getUserId()){
	         		RecipeContainer rc = new RecipeContainer();
	                rc.authorName = getAuthorName(recipe.CreatedById);
	                rc.recipe = recipe; 
	                recentlyApproveRecipes.add(rc); 
	         	}	
        	}
		}
		system.debug('==========================recentlyApproveRecipes: '+ recentlyApproveRecipes.size());
       	return recentlyApproveRecipes;
	}
	
	public pageReference showMoreRecentlyApprovedRecipes(){
    	recentlyApprovedCounter = recentlyApprovedCounter + 1;
        currentRecentlyApprovedLimitValue = limitValue * recentlyApprovedCounter;
        return null;
	}
   
   	public pageReference showLessRecentlyApprovedRecipes(){
      	recentlyApprovedCounter = recentlyApprovedCounter - 1;
      	currentRecentlyApprovedLimitValue = limitValue * recentlyApprovedCounter;
      	return null;
   	}
   	
   	public Boolean getHasRecentlyApprovedRecipes(){
   		system.debug('==========================getHasRecentlyApprovedRecipes: '+ !recentlyApproveRecipes.isEmpty());
    	return !recentlyApproveRecipes.isEmpty();
   	} 
	
	//Takes the set of selected Values for each attribute and formats them to comply with SOQL standards
	public String parseListForQuery(Set<String> s) {
		String returnString;	
		Integer listSize = s.size();
		Integer counter = 0;	
		returnString = '(';

		for (String element : s) {
			if (element == null) {
				counter++;
				continue;	
			}	
			if ((counter + 1) < listSize)
				returnString += '\'' + element + '\',';
			else
				returnString += '\'' + element + '\'';
				
			counter++;
		}			
		returnString += ')';			
		return returnString;	
	}
	/****************************************/
	
   	
	public List<RecipeContainer> getApprovedRecipes() {
		integer aCount = 0;
      	string currentUseId = UserInfo.getUserId();
      	superAdminCheck = getIsSuperAdmin();
        approvedRecipes = new List<RecipeContainer>();
        
		ApprovedQueryString = 'SELECT CreatedById, CreatedDate, IsDeleted, LastActivityDate, LastModifiedById,';
       	ApprovedQueryString += 'LastModifiedDate, Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, Menu_Description__c,'; 
       	ApprovedQueryString += 'Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c, Mobile_Selected_Image__c, Mobile_Selected_Image_URL__c,';
       	ApprovedQueryString += 'Mobile_Unselected_Image__c, Mobile_Unselected_Image_URL__c, Occasion__c,Recipe_Title__c, Occasion_Type__c, Preparation_Steps__c,';
       	ApprovedQueryString += 'Recipe_Color_del__c, Recipe_Flavor_del__c, Recipe_Tag__c, Name, Recipe_Type_del__c, Id,Current_Editor__c,Short_Description__c,'; 
       	ApprovedQueryString += 'Status__c, SystemModstamp, Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c, recordSaved__c';
      	if(superAdminCheck == true)  
       		ApprovedQueryString += ' FROM Recipe__c WHERE Status__c = \'Approved\' AND recordSaved__c = true ORDER BY LastModifiedDate desc limit '+currentApprovedLimitValue;
      	else
        	ApprovedQueryString += ' FROM Recipe__c WHERE Status__c = \'Approved\'  AND Current_Editor__c = \''+currentUseId+'\'   AND recordSaved__c = true ORDER BY LastModifiedDate desc limit '+currentApprovedLimitValue;
     
     	for (Recipe__c r :DataBase.query(ApprovedQueryString)) {
        	superAdminCheck = getIsSuperAdmin();
         
         	if(superAdminCheck == true) {
         		RecipeContainer rc = new RecipeContainer();
         		rc.authorName = getAuthorName(r.CreatedById);
         		rc.recipe = r; 
         		approvedRecipes.add(rc);   
         	} else if(r.Current_Editor__c == UserInfo.getUserId()){
				RecipeContainer rc = new RecipeContainer();
                rc.authorName = getAuthorName(r.CreatedById);
                rc.recipe = r; 
                approvedRecipes.add(rc); 
                aCount++;       
         	}
		}
       	return approvedRecipes;
	}
   
   public Boolean getHasApprovedRecipes(){
      return !approvedRecipes.isEmpty();
   }  

   public List<RecipeContainer> getRejectedRecipes() {
    //recipeRejIds = MM_Utility.getCurrentRejectedRecipesByUser(UserInfo.getUserId(),'Rejected');
    
    string currentUseId = UserInfo.getUserId();
     superAdminCheck = getIsSuperAdmin();
    system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@279RejectedRecipes@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+recipeRejIds.size());
     // if (rejectedRecipes == null)
         rejectedRecipes = new List<RecipeContainer>();
       rejectedQueryString = 'SELECT CreatedById, CreatedDate, IsDeleted, LastActivityDate, LastModifiedById,';
       rejectedQueryString += 'LastModifiedDate, Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, Menu_Description__c,'; 
       rejectedQueryString += 'Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c, Mobile_Selected_Image__c, Mobile_Selected_Image_URL__c,';
       rejectedQueryString += 'Mobile_Unselected_Image__c, Mobile_Unselected_Image_URL__c, Occasion__c, Occasion_Type__c, Preparation_Steps__c,';
       rejectedQueryString += 'Recipe_Color_del__c, Recipe_Flavor_del__c, Recipe_Tag__c, Recipe_Title__c,Name, Recipe_Type_del__c, Id,Current_Editor__c,Short_Description__c,'; 
       rejectedQueryString += 'Status__c, SystemModstamp, Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c, recordSaved__c, ReviewedBy__c';
       
       if(superAdminCheck == true) {
          rejectedQueryString += ' FROM Recipe__c WHERE Status__c = \'Rejected\'  AND recordSaved__c = true ORDER BY LastModifiedDate desc limit '+currentRejectedLimitValue;
          system.debug('======1.rejectedQueryString========' + rejectedQueryString);
       }
       else if(recipeRejIds.size()>0 && superAdminCheck == false) {
          //T-83194: Rejected recipes can be re-assigned by Reviewers
          rejectedQueryString += ' FROM Recipe__c WHERE Status__c = \'Rejected\'  AND  (Current_Editor__c = \''+currentUseId+'\' OR ReviewedBy__c = \''+currentUseId+'\' or Id In '+parseListForQuery(recipeRejIds)+') AND recordSaved__c = true ORDER BY LastModifiedDate desc limit '+currentRejectedLimitValue;
          system.debug('======2.rejectedQueryString========' + rejectedQueryString);
       }   
       else if(recipeRejIds.isEmpty()) {
          //T-83194: Rejected recipes can be re-assigned by Reviewers
          rejectedQueryString += ' FROM Recipe__c WHERE Status__c = \'Rejected\'  AND  (Current_Editor__c = \''+currentUseId+'\' OR ReviewedBy__c = \''+currentUseId+'\') AND recordSaved__c = true ORDER BY LastModifiedDate desc limit '+currentRejectedLimitValue;
          system.debug('======3.rejectedQueryString========' + rejectedQueryString);
       }   
      for (Recipe__c r : DataBase.query(rejectedQueryString)){
        superAdminCheck = getIsSuperAdmin(); 
        
        Set<Id> setRejectedRecipes = new set<Id>(); //set is used to collect/show distinct rejected recipes
        
        //if(r.Current_Editor__c ==UserInfo.getUserId())  
        if(r.Current_Editor__c == UserInfo.getUserId() || r.ReviewedBy__c == UserInfo.getUserId()){ //T-83194:       
                 RecipeContainer rc = new RecipeContainer();
                 rc.authorName = getAuthorName(r.CreatedById);
                 rc.recipe = r;
                 //rejectedRecipes.add(rc);
                 if(!setRejectedRecipes.contains(r.Id)){
						        setRejectedRecipes.add(r.id);
						        rejectedRecipes.add(rc);
						     }
        }
        else if(superAdminCheck == true){
                 system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@superAdminCheck@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+superAdminCheck);
                 RecipeContainer rc = new RecipeContainer();
                 rc.authorName = getAuthorName(r.CreatedById);
                 rc.recipe = r; 
                 //rejectedRecipes.add(rc);
                 if(!setRejectedRecipes.contains(r.Id)){
                    setRejectedRecipes.add(r.id);
                    rejectedRecipes.add(rc);
                 }   
         }
          
         if(recipeRejIds.size()>0){
	         for(Id recId : recipeRejIds){
	            if(r.Id != null && recId !=null){
                if(r.Id == recId){
	                 RecipeContainer rc = new RecipeContainer();
	                 rc.authorName = getAuthorName(r.CreatedById);
	                 rc.recipe = r;
	                 if(!setRejectedRecipes.contains(r.Id)){
	                    setRejectedRecipes.add(r.id);
	                    rejectedRecipes.add(rc);
	                 }
                }
	            }               
	         }
        }
         
      } 
       return rejectedRecipes;

   }
   
   public Boolean getHasRejectedRecipes(){
      return !rejectedRecipes.isEmpty();
   }     
   
   public List<RecipeContainer> getPendingRecipes() {
      string currentUseId = UserInfo.getUserId();
      //recipeIds = MM_Utility.getRecipesByApprover(UserInfo.getUserId());
      
      //if (pendingRecipes == null)
         pendingRecipes = new List<RecipeContainer>();


           pendingApprovalQueryString = 'SELECT CreatedById, CreatedDate, IsDeleted, LastActivityDate, LastModifiedById,';
       pendingApprovalQueryString += 'LastModifiedDate, Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, Menu_Description__c,'; 
       pendingApprovalQueryString += 'Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c, Mobile_Selected_Image__c, Mobile_Selected_Image_URL__c,';
       pendingApprovalQueryString += 'Mobile_Unselected_Image__c, Mobile_Unselected_Image_URL__c, Occasion__c, Occasion_Type__c, Preparation_Steps__c,';
       pendingApprovalQueryString += 'Recipe_Color_del__c, Recipe_Flavor_del__c, Recipe_Tag__c, Recipe_Title__c,Name, Recipe_Type_del__c, Id,Current_Editor__c,Short_Description__c,'; 
       pendingApprovalQueryString += 'Status__c, SystemModstamp, Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c, recordSaved__c';
       if(recipeIds.size()>0)
       pendingApprovalQueryString += ' FROM Recipe__c WHERE Status__c like \'%Pending%\'  AND (Current_Editor__c = \''+currentUseId+'\' or Id In '+parseListForQuery(recipeIds)+') AND recordSaved__c = true ORDER BY LastModifiedDate desc limit '+currentPendingApprovalLimitValue;
                else
                 pendingApprovalQueryString += ' FROM Recipe__c WHERE Status__c like \'%Pending%\'  AND (Current_Editor__c = \''+currentUseId+'\') AND recordSaved__c = true ORDER BY LastModifiedDate desc limit '+currentPendingApprovalLimitValue;
                 
system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@pendingApprovalQueryString@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+pendingApprovalQueryString);


      for (Recipe__c r : DataBase.query(pendingApprovalQueryString)){
          // ((Id in :recipeIds) or ) AND 
                         
         if(r.Current_Editor__c ==UserInfo.getUserId()){
                 RecipeContainer rc = new RecipeContainer();
                 rc.authorName = getAuthorName(r.CreatedById);
                 rc.recipe = r;
                 
                 pendingRecipes.add(rc);    
         }  
           
       if(recipeIds.size()>0){
                 for(Id recId : recipeIds){
                        if(r.Id != null && recId !=null){
                                if(r.Id == recId){
                                         RecipeContainer rc = new RecipeContainer();
                                         rc.authorName = getAuthorName(r.CreatedById);
                                         rc.recipe = r;
                                         pendingRecipes.add(rc);
                                }
                        }               
                 }
       }
     }  
     return pendingRecipes;

   }
   
   public List<RecipeContainer> getRecipesSentFromCurrentUser() {
                
                if (sentRecipes == null)
                        sentRecipes = new List<RecipeContainer>();

                for (Recipe__c r : [SELECT CreatedById, CreatedDate, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate,
                     Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, Menu_Description__c, Mobile_Drink_Image__c,
                     Mobile_Drink_Image_URL__c, Mobile_Selected_Image__c, Mobile_Selected_Image_URL__c, Mobile_Unselected_Image__c,
                     Mobile_Unselected_Image_URL__c, Occasion__c, Occasion_Type__c, Preparation_Steps__c, Recipe_Color_del__c, 
                     Recipe_Flavor_del__c, Recipe_Tag__c, Name,Recipe_Title__c, Recipe_Type_del__c, Id, Short_Description__c,Current_Editor__c, Status__c, 
                     SystemModstamp, Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c 
                                                  FROM Recipe__c
                                                  WHERE Status__c = 'pending Approval'
                                                  AND recordSaved__c = true
                                                  AND (CreatedById = :UserInfo.getUserId() OR Id in :MM_Utility.getCurrentRecipesApprovedByUser(UserInfo.getUserId(),'Approved'))   
                                             order BY LastModifiedDate desc]){
                   
                        RecipeContainer rc = new RecipeContainer();
                        rc.authorName = getAuthorName(r.CreatedById);
                        rc.recipe = r;
                        
                        sentRecipes.add(rc);    
                        
                 }
                 
                 return sentRecipes;

        }
        
        public Boolean getHasSentRecipes(){
                return !sentRecipes.isEmpty();
        }               
   public Boolean getHasPendingRecipes(){
      return !pendingRecipes.isEmpty();
   }     
   
   public List<RecipeContainer> getArchivedRecipes() {
      string currentUseId = UserInfo.getUserId();
     // recipeIds = MM_Utility.getRecipesByApprover(UserInfo.getUserId());
      
     // if (archivedRecipes == null)
         archivedRecipes = new List<RecipeContainer>();
        archivedQueryString = 'SELECT CreatedById, CreatedDate, IsDeleted, LastActivityDate, LastModifiedById,';
       archivedQueryString += 'LastModifiedDate, Main_Drink_Image__c, Main_Drink_Image_URL__c, Main_Ingredient_Image__c, Menu_Description__c,'; 
       archivedQueryString += 'Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c, Mobile_Selected_Image__c, Mobile_Selected_Image_URL__c,';
       archivedQueryString += 'Mobile_Unselected_Image__c, Mobile_Unselected_Image_URL__c, Occasion__c, Occasion_Type__c, Preparation_Steps__c,';
       archivedQueryString += 'Recipe_Color_del__c, Recipe_Flavor_del__c, Recipe_Tag__c, Name,Recipe_Title__c, Recipe_Type_del__c, Id,Current_Editor__c,Short_Description__c,'; 
       archivedQueryString += 'Status__c, SystemModstamp, Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c, recordSaved__c';
       archivedQueryString += ' FROM Recipe__c WHERE Status__c = \'Archive\' AND recordSaved__c = true ORDER BY LastModifiedDate desc limit '+currentArchivedLimitValue;
      
      for (Recipe__c r : DataBase.query(archivedQueryString)){
          
         RecipeContainer rc = new RecipeContainer();
         rc.authorName = getAuthorName(r.CreatedById);
         rc.recipe = r;
         
         archivedRecipes.add(rc);   
               
       }
       
       return archivedRecipes;

   }
   
   public Boolean getHasArchivedRecipes(){
      return !archivedRecipes.isEmpty();
   }  
   
   
   
   public PageReference editRecipe() {
      system.debug('Came into this');

      PageReference pageRef = new PageReference('/apex/MM_RecipeView?recipeId='+recipeId+'&editMode=true');
      pageRef.setRedirect(true);
      return pageRef;
      
   }
   
   public PageReference viewRecipe() {
      system.debug('Came Into this Page');

      PageReference pageRef = new PageReference('/apex/MM_RecipeView?recipeId='+recipeId);
      pageRef.setRedirect(true);
      return pageRef;
      
   }
   
  /*  public pageReference showMoreEditor(){
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@317@@@@@@@@@@@@@@@@@@@@@@@Into the Edtor@@@@@@@@@@@@');
                pagereference pref = new pagereference('/apex/MM_RecipeView');
                //Counter = Counter + 1;
                //limitValue = limitValue * Counter;
                //system.debug('@@@@@@@@@@@@@@@@@@@ Limit Value @@@@@@@@@@@@@@@@@@@@@@@'+limitValue);
                return pref;
        } */
   
   public pageReference showMoreEditor(){
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@IntoShowMoreEditor@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        EditCounter = EditCounter+1;
        currentEditorLimitValue = limitValue * EditCounter;
        currentLimitValue = currentEditorLimitValue;
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@332Counter@@@@@@@@@@@@@@@@@@@@'+EditCounter);
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@330currentEditorLimitValue@@@@@@@@@@@@@@@@@@@@@@@@@@@'+currentEditorLimitValue);
        return null;
        
   }
   
   public pageReference showLessEditor(){
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@IntoShowMoreEditor@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
      EditCounter = EditCounter-1;
      currentEditorLimitValue = limitValue * EditCounter;
      currentLimitValue = currentEditorLimitValue;
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@332Counter@@@@@@@@@@@@@@@@@@@@'+EditCounter);
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@330currentEditorLimitValue@@@@@@@@@@@@@@@@@@@@@@@@@@@'+currentEditorLimitValue);
      return null;
      
   }
   
   public pageReference showMoreApprovedRecipes(){
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@IntoShowMoreApprover@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        //integer currentALimitValue ;
        ApprovedCounter = ApprovedCounter+1;
        currentApprovedLimitValue = limitValue * ApprovedCounter;
        currentALimitValue = currentApprovedLimitValue;
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@332Counter@@@@@@@@@@@@@@@@@@@@'+ApprovedCounter);
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@330currentEditorLimitValue@@@@@@@@@@@@@@@@@@@@@@@@@@@'+currentApprovedLimitValue);
        return null;
        
   }
   
   public pageReference showLessApprovedRecipes(){
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@IntoShowMoreApprover@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
      //integer currentALimitValue ;
      ApprovedCounter = ApprovedCounter-1;
      currentApprovedLimitValue = limitValue * ApprovedCounter;
      currentALimitValue = currentApprovedLimitValue;
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@332Counter@@@@@@@@@@@@@@@@@@@@'+ApprovedCounter);
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@330currentEditorLimitValue@@@@@@@@@@@@@@@@@@@@@@@@@@@'+currentApprovedLimitValue);
      return null;
      
   }
   
   public pageReference showMorePendingApprovalRecipes(){
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@IntoShowMoreApprover@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        integer currentLimitValue ;
        PendingApprovalCounter = PendingApprovalCounter+1;
        currentPendingApprovalLimitValue = limitValue * PendingApprovalCounter;
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@332Counter@@@@@@@@@@@@@@@@@@@@'+PendingApprovalCounter);
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@330currentEditorLimitValue@@@@@@@@@@@@@@@@@@@@@@@@@@@'+currentPendingApprovalLimitValue);
        return null;
        
   }
   
   public pageReference showLessPendingApprovalRecipes(){
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@IntoShowMoreApprover@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
      integer currentLimitValue ;
      PendingApprovalCounter = PendingApprovalCounter-1;
      currentPendingApprovalLimitValue = limitValue * PendingApprovalCounter;
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@332Counter@@@@@@@@@@@@@@@@@@@@'+PendingApprovalCounter);
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@330currentEditorLimitValue@@@@@@@@@@@@@@@@@@@@@@@@@@@'+currentPendingApprovalLimitValue);
      return null;
      
   }
   
   public pageReference showMoreRejectedRecipes(){
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@IntoShowMoreApprover@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        integer currentLimitValue ;
        rejectedCounter = rejectedCounter+1;
        currentRejectedLimitValue = limitValue * rejectedCounter;
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@332Counter@@@@@@@@@@@@@@@@@@@@'+rejectedCounter);
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@330currentEditorLimitValue@@@@@@@@@@@@@@@@@@@@@@@@@@@'+currentRejectedLimitValue);
        return null;
        
   }
   public pageReference showLessRejectedRecipes(){
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@IntoShowMoreApprover@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
      integer currentLimitValue ;
      rejectedCounter = rejectedCounter-1;
      currentRejectedLimitValue = limitValue * rejectedCounter;
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@332Counter@@@@@@@@@@@@@@@@@@@@'+rejectedCounter);
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@330currentEditorLimitValue@@@@@@@@@@@@@@@@@@@@@@@@@@@'+currentRejectedLimitValue);
      return null;
      
   }
   
   public pageReference showMoreArchivedRecipes(){
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@IntoShowMoreApprover@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        integer currentLimitValue ;
        archivedCounter = archivedCounter+1;
        currentArchivedLimitValue = limitValue * archivedCounter;
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@332Counter@@@@@@@@@@@@@@@@@@@@'+archivedCounter);
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@330currentEditorLimitValue@@@@@@@@@@@@@@@@@@@@@@@@@@@'+currentArchivedLimitValue);
        return null;
        
   }
   
   public pageReference showlessArchivedRecipes(){
      system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@IntoShowMoreApprover@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
      integer currentLimitValue ;
      archivedCounter = archivedCounter-1;
      currentArchivedLimitValue = limitValue * archivedCounter;
      return null;
      
   }
   
   	//Container class for recipe and author
	public class RecipeContainer {
    	public String authorName{get;set;}
      	public Recipe__c recipe {get;set;}
   	}
   
   
   public String parseListForQuery(list<Id> s){
                
                
                system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@287ParseList@@@@@@@@@@@@@@@@@@@@@@@@@@'+s);
                String returnString;
                        
                Integer listSize = s.size();
                Integer counter = 0;
                        
                returnString = '(';

                for (Id element : s){
                        if (element == null) {
                                counter++;
                                continue;
                                
                        }       
                        if ((counter + 1) < listSize)
                                returnString += '\'' + element + '\',';
                        else
                                returnString += '\'' + element + '\'';
                                
                        counter++;
                }
                        
                returnString += ')';
                
                return returnString;
                
        }
        
       public String getUserAgent() { 
	 	return ApexPages.currentPage().getHeaders().get('User-Agent');
	  }
   
}