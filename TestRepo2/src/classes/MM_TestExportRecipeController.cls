/**
 Test to check the Contorller Associated with MM_ExportRecipes Visualforce page.
* @Author  : Raj Avirneni
* @Date    : Mar 29 2012
* @Version : 1.0
* The @isTest class annotation indicates this class only contains test methods. 
* Classes defined with the @isTest annotation do not count against the organization size limit for all Apex scripts.

 */
@isTest
private class MM_TestExportRecipeController {

    static testMethod void myUnitTest() {
    	//creating a Master Recipe
		Master_Recipe__c mastRec = TestUtil.createMasterRecipe('MasterRecipe');
		
		//Creates a list of Recipes 	
		Recipe__c rec1 = TestUtil.createRecipe('TestRecipe1',mastRec.Id,'Draft',true);
		
		pageReference pRef = page.MM_ExportRecipe;
    	Test.setCurrentPage(pRef);
    	String recipeId = rec1.Id;
        MM_ExportRecipe exp = new MM_ExportRecipe();
        
        //Exporting a Recipe that doesnot have a Master Reicpe
        exp = new MM_ExportRecipe(recipeId,null,null);
        //Exporting a Recipe which is Master Recipe
        exp = new MM_ExportRecipe(null,recipeId,null);
        
        //Exporting a list of Reicpes from View All Reicpes Page
        exp = new MM_ExportRecipe(null,null,recipeId);
        list<Recipe__c> rec = exp.recipes;
        Recipe__c r = [select id,Status__c,Recipe_Title__c from Recipe__c where id=:rec[0].Id];
        system.assertEquals(r.Status__c,'Draft');
        system.assertEquals(r.Recipe_Title__c,'TestRecipe1');
        system.assertEquals(rec.size(),1);
        exp.redirectBack='TEST';
        exp.sendBack();
    }
}