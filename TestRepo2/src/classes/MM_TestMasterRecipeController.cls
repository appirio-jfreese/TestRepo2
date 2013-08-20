/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MM_TestMasterRecipeController {

    static testMethod void myUnitTest() {
        Master_Recipe__c master = new Master_Recipe__c();
        master.Name='TEST PREP STEPS';
		insert master;
		Recipe__c recipe = new Recipe__c();
		recipe.Master_Recipe__c=master.Id;
		recipe.Recipe_Title__c = 'Test Recipe PREP STEPS';
		recipe.Preparation_Steps__c='TEST PREP STEPS';
		recipe.recordSaved__c=true;
		recipe.Locale__c = 'EN-US';
		insert recipe;
		String recipeId = recipe.Id;
		
		
		
		MM_MasterRecipeController controller = new MM_MasterRecipeController(master.Id,'');
    	List<RecipeWrapper> recipes = controller.getChildRecipes();
    	recipes = controller.getAllApproved();
    	controller.searchTerm='TEST';
    	controller.getAlphabets();
    	controller.filterResults();
        recipes = controller.getChildRecipes();
        recipes = controller.getAllApproved();
        
        controller.cloneFromId=recipe.Id;
        controller.cloneRecipe();
        controller.searchRecipe();
        controller.clearResults();
        controller.getUserAgent();
        
        ApexPages.currentPage().getParameters().put('recipeId',recipeId);
        MM_MasterRecipeController cont = new MM_MasterRecipeController();
        List<RecipeWrapper> rw = controller.getChildRecipes();
        cont.searchTerm='';
        cont.filterResults();
        cont.cancel();
        cont.first();
        cont.next();
        integer  x = cont.pageNumber;
        cont.previous();
        cont.last();
        boolean n = cont.hasNext;
        boolean p = cont.hasPrevious;
        integer ce = cont.currentEndRecord;
        integer cs =cont.currentStartRecord;
    }
}