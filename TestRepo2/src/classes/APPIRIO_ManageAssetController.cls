/********************************************************************************************************************
Name        : APPIRIO_ManageAssetController
Updated By  : Appirio Offshore(Rishi Khirbat)   
Date        : 21st Nov, 2012
Purpose     : Controller of APPIRIO_ManageAsset.page
Ref         : T-96368
              Create a Visualforce page per the specs in the attached file.
              This page allows the user to search for Recipe__c objects, and then link them to an asset via 
              the Published_Recipe__c junction object. 
              It contains all the search functionality and we should be able to add onto it to perform the junction object save operations.
********************************************************************************************************************/
public with sharing class APPIRIO_ManageAssetController {
	
	//variable declaration
	public Digital_Published_Asset__c publishedAsset{get; set;}
	
	public Boolean hasPublishedRecipe{get; set;}
	public Boolean hasPublishedOccasion{get; set;}
	public integer currentRecipeLimit{get;set;}
	public integer currentOccasionLimit{get;set;}
	public integer recipeCount{get;set;}
	public integer occasionCount{get;set;}
	
	public integer recipeCounter{get;set;}
	public integer occasionCounter{get;set;}
	
	public integer limitValue{get;set;}
	
	//public integer currentLimitValue{get;set;}
	//public integer currentLimitValue{get;set;}
	
	//public integer recipePAGE_SIZE = 5;
	//public integer occasionPAGE_SIZE = 5;
	
	public ApexPages.StandardSetController conRecipe {get;set;}
	public ApexPages.StandardSetController conOccasion {get;set;}
	
	String queryString;
	//returns the current logged in Browser name to associate respective CSS.
    public String getUserAgent() { 
	 	return ApexPages.currentPage().getHeaders().get('User-Agent');
	}
	
	//Constructor of calss APPIRIO_ManageAssetController
	public APPIRIO_ManageAssetController(Apexpages.Standardcontroller controller) {
		hasPublishedRecipe = false;
		hasPublishedOccasion = false;
		
		limitValue = 5;
		currentRecipeLimit = 5;
		currentOccasionLimit = 5;
		recipeCounter = 1;
		occasionCounter = 1;
		
		if(controller.getId() != null) {
			publishedAsset = [Select Id, Name From Digital_Published_Asset__c Where Id =: controller.getId()];
		} else {
			publishedAsset = new Digital_Published_Asset__c();
		}
		
		//Grabbing/getting all the details of the Published_Recipe__c that is Published.
		queryString = ' Select Id From Published_Recipe__c Where Digital_Published_Asset__c =\''+ publishedAsset.Id +'\'And Status__c = \'Published\'';
		conRecipe = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
		recipeCount = conRecipe.getResultSize();
		
		//Grabbing/getting all the details of the Published_Occasion__c that is Published.
		queryString = ' Select Id From Published_Occasion__c Where Digital_Published_Asset__c =\''+ publishedAsset.Id +'\'And Status__c = \'Published\'';
		conOccasion = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
		occasionCount = conOccasion.getResultSize();
	}
	
	//Generating Published Recipes info.
	public List<Published_Recipe__c> getPublishedRecipes() {
		
		queryString = ' Select Status__c, Recipe__r.Recipe_Title__c, CreatedDate, Recipe__r.Locale__c, LastModifiedDate ';
		queryString += ' From Published_Recipe__c  Where Digital_Published_Asset__c =\''+ publishedAsset.Id +'\'And Status__c = \'Published\'  Order by LastModifiedDate DESC limit '+currentRecipeLimit;
		conRecipe = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
		
		List<Published_Recipe__c> publishedRecipe = (List<Published_Recipe__c>)conRecipe.getRecords();
		if(publishedRecipe.size() > 0)
			hasPublishedRecipe = true;
		
		return publishedRecipe;
	}
	
	public pageReference showMoreRecipe(){
    	recipeCounter = recipeCounter+1;
        currentRecipeLimit = limitValue * recipeCounter;
        return null;
	}
   
   	public pageReference showLessRecipe(){
      	recipeCounter = recipeCounter-1;
      	currentRecipeLimit = limitValue * recipeCounter;
      	return null;
   	}
	
	//Generating Published Occasions info.
	public List<Published_Occasion__c> getPublishedOccasions() {
		
		queryString = ' Select Status__c, Occasion__r.Occasion_Type__c, Occasion__r.Name_Of_The_Occasion__c, Occasion__r.Locale__c, LastModifiedDate ';
		queryString += ' From Published_Occasion__c Where Digital_Published_Asset__c =\''+ publishedAsset.Id +'\'And Status__c = \'Published\'  Order by LastModifiedDate DESC limit '+currentOccasionLimit;
		conOccasion = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
		
		List<Published_Occasion__c> publishedOccasion = (List<Published_Occasion__c>)conOccasion.getRecords();
		if(publishedOccasion.size() > 0)
			hasPublishedOccasion = true;
		
		return publishedOccasion;
	}
	
	public pageReference showMoreOccasion(){
    	occasionCounter = occasionCounter+1;
        currentOccasionLimit = limitValue * occasionCounter;
        return null;
	}
   
   	public pageReference showLessOccasion(){
      	occasionCounter = occasionCounter-1;
      	currentOccasionLimit = limitValue * occasionCounter;
      	return null;
   	}
	
	/*
	// indicates whether there are more records of Recipes after the current page set.
	public Boolean hasNextRecipes {
		get {
			return conRecipe.getHasNext();
		}
		set;
	}
	
	public Integer totalRecordRecipes {
		get {
			return conRecipe.getResultSize()+1;
		}
		set;
	}
	
	public Integer currentStartRecordRecipes {
		get {
			return (pageNumberRecipe*recipePAGE_SIZE)-4;
		}
		set;
	}
	
	public Integer currentEndRecordRecipes {
		get {
			if (hasNextRecipes)
				return currentStartRecordRecipes+(recipePAGE_SIZE-1);
			else{
				Integer tmp = Math.mod(totalRecordRecipes,recipePAGE_SIZE);
				if (tmp == 0)
					return (recipePAGE_SIZE-1)+currentStartRecordRecipes;
				else
					return (tmp-1)+currentStartRecordRecipes;
					
			}
		}
		set;
	}	
   
   	//Returns the Page Numbers to display on to the screen.
   	public list<pageNumberWrapperRecipe> pageNumbersRecipes {
		get {
	   		Integer lastRow = Integer.valueOf(Math.ceil(totalRecordRecipes/recipePAGE_SIZE));
	   		if( Math.mod(totalRecordRecipes,recipePAGE_SIZE)!= 0)
	   			lastRow+=1;
	   		
	   		List<pageNumberWrapperRecipe> pNo = new List<pageNumberWrapperRecipe>();
	   		Integer j=1;
	   		for(Integer i=pageNumberRecipe;i<=lastRow && j<6;i++) {
	   			pNo.add(new pageNumberWrapperRecipe(i,j,conRecipe,pageNumberRecipe));
	   			j++;
	   		}
	   		return pNo;
	   	}
   		set;
   }
   
	public class pageNumberWrapperRecipe {
   		public Integer num{get;set;}
   		public Integer cnt{get;set;}
   		public String col{get; set;}
   		ApexPages.StandardSetController conRecipe;
   		public pageNumberWrapperRecipe(Integer n,Integer c,ApexPages.StandardSetController conRecipe, Integer pno)
   		{
	   		this.num=n;
	   		this.cnt=c;
	   		this.conRecipe=conRecipe;
	   		if(this.num == pno)
	   		this.col='red';
	   		else
	   		this.col='black';
   		}
   	
   		public void pageItems() {
      		Integer n = Integer.valueOf(Apexpages.currentPage().getParameters().get('cnt')); 
      		for(Integer i=1;i<n;i++)
         	this.conRecipe.next();
      	}
 
	}
	// indicates whether there are more records before the current page set.
	public Boolean hasPreviousRecipes {
		get {
			return conRecipe.getHasPrevious();
		}
		set;
	}
 
	// returns the page number of the current page set
	public Integer pageNumberRecipe {
		get {
			return conRecipe.getPageNumber();
		}
		set;
	}
 
	// returns the first page of records
 	public void firstRecipes() {
 		conRecipe.first();
 	}
 
 	// returns the last page of records
 	public void lastRecipes() {
 		conRecipe.last();
 	}
 
 	// returns the previous page of records
 	public void previousRecipes() {
 		conRecipe.previous();
 	}
 
 	// returns the next page of records
 	public void nextRecipes() {
 		conRecipe.next();
 		
 	}
 	
 	// indicates whether there are more records of Occasions after the current page set.
	public Boolean hasNextOccasions {
		get {
			return conOccasion.getHasNext();
		}
		set;
	}
	
	public Integer totalRecordOccasions {
		get {
			return conOccasion.getResultSize()+1;
		}
		set;
	}
	
	public Integer currentStartRecordOccasions {
		get {
			return (pageNumberOccasion*OccasionPAGE_SIZE)-4;
		}
		set;
	}
	
	public Integer currentEndRecordOccasions {
		get {
			if (hasNextOccasions)
				return currentStartRecordOccasions+(OccasionPAGE_SIZE-1);
			else{
				Integer tmp = Math.mod(totalRecordOccasions,OccasionPAGE_SIZE);
				if (tmp == 0)
					return (OccasionPAGE_SIZE-1)+currentStartRecordOccasions;
				else
					return (tmp-1)+currentStartRecordOccasions;
					
			}
		}
		set;
	}	
   
   	//Returns the Page Numbers to display on to the screen.
   	public list<pageNumberWrapperOccasion> pageNumbersOccasions {
		get {
	   		Integer lastRow = Integer.valueOf(Math.ceil(totalRecordOccasions/OccasionPAGE_SIZE));
	   		if( Math.mod(totalRecordOccasions,OccasionPAGE_SIZE)!= 0)
	   			lastRow+=1;
	   		
	   		List<pageNumberWrapperOccasion> pNo = new List<pageNumberWrapperOccasion>();
	   		Integer j=1;
	   		for(Integer i=pageNumberOccasion;i<=lastRow && j<6;i++) {
	   			pNo.add(new pageNumberWrapperOccasion(i,j,conOccasion,pageNumberOccasion));
	   			j++;
	   		}
	   		return pNo;
	   	}
   		set;
   }
   
	public class pageNumberWrapperOccasion {
   		public Integer num{get;set;}
   		public Integer cnt{get;set;}
   		public String col{get; set;}
   		ApexPages.StandardSetController conOccasion;
   		public pageNumberWrapperOccasion(Integer n,Integer c,ApexPages.StandardSetController conOccasion, Integer pno)
   		{
	   		this.num=n;
	   		this.cnt=c;
	   		this.conOccasion=conOccasion;
	   		if(this.num == pno)
	   		this.col='red';
	   		else
	   		this.col='black';
   		}
   	
   		public void pageItems() {
      		Integer n = Integer.valueOf(Apexpages.currentPage().getParameters().get('cnt')); 
      		for(Integer i=1;i<n;i++)
         	this.conOccasion.next();
      	}
 
	}
	// indicates whether there are more records before the current page set.
	public Boolean hasPreviousOccasions {
		get {
			return conOccasion.getHasPrevious();
		}
		set;
	}
 
	// returns the page number of the current page set
	public Integer pageNumberOccasion {
		get {
			return conOccasion.getPageNumber();
		}
		set;
	}
 
	// returns the first page of records
 	public void firstOccasions() {
 		conOccasion.first();
 	}
 
 	// returns the last page of records
 	public void lastOccasions() {
 		conOccasion.last();
 	}
 
 	// returns the previous page of records
 	public void previousOccasions() {
 		conOccasion.previous();
 	}
 
 	// returns the next page of records
 	public void nextOccasions() {
 		conOccasion.next();
 		
 	}	
 	*/
}