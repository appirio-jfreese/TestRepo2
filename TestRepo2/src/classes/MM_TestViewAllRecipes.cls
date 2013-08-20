/*Test to check the Contorller Associated with MM_ViewAllRecipes Visualforce page.
* @Author  : Raj Avirneni
* @Date    : Mar 20 2012
* @Version : 1.0
* The @isTest class annotation indicates this class only contains test methods. 
* Classes defined with the @isTest annotation do not count against the organization size limit for all Apex scripts.

 */
@isTest
private class MM_TestViewAllRecipes{

		static	Master_Recipe__c mastRec;
		static Recipe__c rec1; 
		static Recipe__c rec2;
		static Recipe__c rec3;
		static Recipe__c rec4;
		static Attribute__c attr;
		static Attribute__c attr1;
		static Attribute__c attr2;
		static Attribute__c attr3;
		static Attribute__c attr4;
		static Attribute__c attr5;
		static Recipe_Attribute__c recattr;
		static Recipe_Attribute__c recattr1;
		static Recipe_Attribute__c recattr2;
		static Recipe_Attribute__c recattr3;
		static Occasion__c occ;
		static Occasion__c occ1;
		static Recipe_Occasion__c recOcc;
		static Recipe_Occasion__c recOcc1;
		static Diageo_Brand__c diagBrnd;
		static Diageo_Product__c diagPrdct;
		static Recipe_Non_Diageo_Product__c nonDiagPrdct;
		static Diageo_Ingredient__c diagIng;
		static Diageo_Ingredient__c nonDiagIng;
		static Preparation_Step__c prepStep;
		
		
	static
	{
		//creating a Master Recipe
		 mastRec = TestUtil.createMasterRecipe('MasterRecipe');
		
		 //Creates a list of Recipes
		 rec1 = TestUtil.createRecipe('TestRecipe1',mastRec.Id,'Draft',true);
		 rec2 = TestUtil.createRecipe('TestRecipe2',mastRec.Id,'Draft',true);
		 rec3 = TestUtil.createRecipe('TestRecipe3',mastRec.Id,'Draft',true);
		 rec4 = TestUtil.createRecipe('TestRecipe4',mastRec.Id,'Draft',true);
		 
		 //Creating a bunch of Attribute Records
		 attr = TestUtil.createAttribute('Color','TestBlue',null);
		 attr1= TestUtil.createAttribute('Language','TestEnglish',null);
		 attr2 = TestUtil.createAttribute('Flavor','TestStrawberry',null);
		 attr3 = TestUtil.createAttribute('Flavor','TestBanana',null);
		 attr4 = TestUtil.createAttribute('Drink Type','TestCocktails',null);
		 attr5 = TestUtil.createAttribute('Drink Type','TestBloody-Marys',null);
		 
		 //Mapping Recipes to the Attributes(Creating Junction Object Records)
		 recattr = TestUtil.createRecipeAttribute(rec1.Id,attr.Id);
		 recattr1 = TestUtil.createRecipeAttribute(rec1.Id,attr1.Id);
		 recattr2 = TestUtil.createRecipeAttribute(rec1.Id,attr3.Id);
		 recattr3 = TestUtil.createRecipeAttribute(rec1.Id,attr4.Id);
		 
		 //Creating a bunch of Occasions
		occ = TestUtil.createOccasion('TestHolidays','TestLaborDay',null);
		occ1 = TestUtil.createOccasion('TestCelebrations','TestThanksgivingDay',null);
		
		//Linking Occasions to Recipes Via Junction Object
		recOcc = TestUtil.createRecipeOccasion(rec1.Id,occ.Id);
		recOcc1 = TestUtil.createRecipeOccasion(rec1.Id,occ1.Id);
		
		//Creating a Diageo Brand(Parent Product)		
		diagBrnd  = TestUtil.createDiageoBrand('ModelBrand',null);
		
		//Creating a Recipe Diageo Product(Categeory/Sub Brand of Daigeo Brand)
		diagPrdct = TestUtil.createDiageoProduct('ModelBrandCaramel',diagBrnd.Id,null);
		
		//Creating a Recipe Non Diageo Product	
		nonDiagPrdct = TestUtil.createNonDiageoProduct('Big Banana',null);
		
		//Creating Recipe Ingredients
		diagIng = TestUtil.createRecipeIngredient(true,'1.23','Oz',rec1.Id,diagBrnd.Id,diagPrdct.id,null,1);
		nonDiagIng = TestUtil.createRecipeIngredient(true,'1.23','Oz',rec1.Id,null,null,nonDiagPrdct.id,2);
		
		//Creating Preparation Step 
		prepStep = TestUtil.createPreparationStep('Test this Recipe',rec1.Id);		 
		 
	}
	
	static testMethod void filtersTest(){
	
		
    	
    	
   	/* 	* @#UseCase 1 :Checking the Dynamic Filter.All the Values that are being Set are added to the Filter Criteria and  a search is performed against Recipes. 
		* @Description:1.Create a Recipe With atleast One Color,Flavor,Occasion,Diageo Ingredient,Non-Diageo Ingredient and Preparation step.
		*			   2.Search for all of the Attributes,Occasions,Ingredients by enetering in the Manual Search bar
		* @Expected   :List of Recipes that Matches/Finds the Search Critera are Returned. */
    	pageReference pRef = page.MM_ViewAllRecipes;
    	Test.setCurrentPage(pRef);
    	MM_ViewAllRecipesController varec = new MM_ViewAllRecipesController();
    
    	varec.getIsSuperAdmin();
		varec.searchTerm = '';
    	varec.PAGE_SIZE = 9;
    	varec.currentColor = 'TestBlue';
    	varec.currentFlavor = 'TestBanana';
    	varec.currentBrand = 'ModelBrand';
    	varec.currentType = 'TestCocktails';
    	varec.currentStatus = 'Draft';  
    	varec.currentIngredientNumber = '2';	
    	List<RecipeWrapper> rw = varec.getWrapperRecipes();
    	//The Wrapper Should Return One Recipe
    	Recipe__c r = [select id,Recipe_Title__c from Recipe__c where id=:rw[0].rec.Id];
		system.assertEquals(r.Recipe_Title__c,'TestRecipe1');
    	system.assertEquals(rw.size(),1);
    	rw[0].checked = true;
    	pageReference pageRef = varec.selectAll();
       	pageRef = varec.process();
    	pageRef = varec.clearFilters(); 	
	}
	
	static testMethod void searchTest() {
		
    	/* 	* @#UseCase 3: Checking the Manual Search.
			* @Description:1.Create a Recipe With atleast One Color,Flavor,Occasion,Diageo Ingredients,Non Diageo Ingredients,preparation steps
			*			   2.set a string Value to the SearchTerm that either matches or atleast contains in any of the Attributes or Ingredients or Preparationsteps or on the Recipe 
						   3.A search is performed against all the Objects Related to Recipes	
			* @Expected   :Recipe Records are returned that contanins the SerachTerm either on the Recipe or Objects Related to Recipe. */
    	
    	
    	pageReference pref = Page.MM_ViewAllRecipes;
		Test.setCurrentPage(pref);
		MM_ViewAllRecipesController vac = new MM_ViewAllRecipesController();
		vac.searchTerm = 'TestBlue';
		PageReference pageRef = vac.filterResults();
		list<RecipeWrapper> reW = vac.getWrapperRecipes();	
		Recipe__c r = [select id,Recipe_Title__c from Recipe__c where id=:reW[0].rec.Id];
		
		system.assertEquals(r.Recipe_Title__c,'TestRecipe1');
		system.assertEquals(reW.Size(),1);
		pageRef = vac.clearFilters();
		
		
		/* 	* @#UseCase 4: Checking the Manual Search(Failing Criteria).
			* @Description:1.Create a Recipe With atleast One Color,Flavor,Occasion,Diageo Ingredients,Non Diageo Ingredients,preparation steps
			*			   2.set a string Value to the SearchTerm that Doesnot match in any of the Attributes or Ingredients or Preparationsteps or on the Recipe 
						   3.A search is performed against all the Objects Related to Recipes	
			* @Expected   :None of the Recipe Records are returned that contanins the SerachTerm either on the Recipe or Objects Related to Recipe. */
		
		vac.searchTerm = 'TestBlack';
		pageRef = vac.filterResults();
		list<RecipeWrapper> rw = vac.getWrapperRecipes();
		system.assertEquals(rw.Size(),0);		
		
    }
	
    static testMethod void backToFilterResultsTest(){
		
		/* 	* @#UseCase 5: Checking the Restorement of Filtered Results when coming from View Mode of a Recipe.
			* @Description:1.Create a Recipe With atleast One Color,Flavor,Occasion,Diageo Ingredients,Non Diageo Ingredients,preparation steps
			*			   2.Set the Respective Filter Criteria and Perform a search on Recipes
						   3.CLick on one of the Recipes Returned in the Results List to view the Recipe
						   4.GO back the Search Page to View other Recipes or modify the existing criteria
			* @Expected   :Recipe Records are returned that contanins the Previous Filter criteria */
			
		pageReference pref = Page.MM_ViewAllRecipes;
		Test.setCurrentPage(pref);
		ApexPages.currentPage().getParameters().put('searchTerm','Draft');
		ApexPages.currentPage().getParameters().put('isNavigatingFromDetail','true');
		ApexPages.currentPage().getParameters().put('currentColor', 'TestBlue');
		ApexPages.currentPage().getParameters().put('currentBrand', 'ModelBrand');
		ApexPages.currentPage().getParameters().put('currentFlavor', 'TestBanana');
		ApexPages.currentPage().getParameters().put('currentType', 'TestCocktails');
		ApexPages.currentPage().getParameters().put('currentIngredientNumber','2');
		MM_ViewAllRecipesController bac = new MM_ViewAllRecipesController();
		list<recipeWrapper> rw = bac.getWrapperRecipes();
		//One Recipe is Returned matching the Above Filter criteria.
		Recipe__c r = [select id,Recipe_Title__c from Recipe__c where id=:rw[0].rec.Id];
		system.assertEquals(r.Recipe_Title__c,'TestRecipe1');
		system.assertEquals(rw.size(),1);
    	
    }
    
    static testMethod void gettersTest() {
    	
    	Test.setCurrentPage(Page.MM_ViewAllRecipes);
    	MM_ViewAllRecipesController con = new MM_ViewAllRecipesController();
    	con.searchTerm = '';
		string flavor = con.flavorLast;
    	string color = con.colorLast;
    	string types = con.typeLast;
    	string brand = con.brandLast;
    	string status = con.statusLast;
    	string ingNumber = con.numberLast;
    	integer colorCount = con.colorCounter;
    	integer flavorCount = con.flavorCounter;
    	integer typeCount = con.typeCounter;
    	integer brandCount = con.brandCounter;
    	integer statusCount = con.statusCounter;
    	integer numberCount = con.numberCounter;
    	
    	list<String> ingList = con.getIngredientNumbers();
    	list<Diageo_Brand__c> brandList = con.getRecipeBrands();
    	list<String> colorList = con.getRecipeColors();
    	//LIst<String> occasionList = con.getOccasions();
    	list<String> flavorList = con.getRecipeFlavors();
    	list<String> typeList = con.getTypes();
    	list<String> brandList2 = con.getBrands();
    	list<String> statusList = con.getStatus();
    	list<selectOption> opList = con.getSortOrderTypes();
    	list<Recipe__c> recipeList = con.getRecipes();
    	Boolean hasRecords = con.hasNext;
    	Boolean hasPrev = con.hasPrevious;
    	con.first();
    	con.last();
    	con.previous();
    	con.next();
    	
    	List<RecipeWrapper> rw = con.getWrapperRecipes();
    	
    }
    
}