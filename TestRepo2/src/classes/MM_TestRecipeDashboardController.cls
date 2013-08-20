@isTest
private class MM_TestRecipeDashboardController {

    static testMethod void myUnitTest() {
  	
		UserRole editorRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_EDITOR ];
	    //UserRole reviewerRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_REVIEWER];
	    UserRole publisherRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_PUBLISHER];
	    UserRole approverRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_APPORVER];
	    UserRole adminRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_ADMIN];
		
		User editor = new User(alias = 'unittest', email='unittest@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = editorRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unittest@diageorecipes.com');
        /*  
        User reviewer = new User(alias = 'unitrev', email='unitrev@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = reviewerRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unitrev@diageorecipes.com');
		*/
       	User publisher = new User(alias = 'unitrev', email='unitrev@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = publisherRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unitrev@diageorecipes.com');
            
        User approver = new User(alias = 'unitapp', email='unitapp@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = approverRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unitapp@diageorecipes.com');
            
        User admin = new User(alias = 'unitadm', email='unitadm@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = adminRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unitadm@diageorecipes.com');
            
        insert editor;
        //insert reviewer;
        insert publisher;
        insert approver;
        insert admin;
       
       
        MM_RecipeDashboardController controller = null;
        
       
        Master_Recipe__c master = new Master_Recipe__c();
        System.runAs(editor) {
			insert master;
			controller = new MM_RecipeDashboardController();
        }
		Recipe__c recipe = new Recipe__c();
		recipe.Master_Recipe__c=master.Id;
		recipe.Preparation_Steps__c='TEST PREP STEPS';
		recipe.Recipe_Title__c = 'TEST RECIPE PREP STEPS';
		recipe.Locale__c = 'EN-US';
		recipe.Status__c='Draft';
		recipe.recordSaved__c = true;
		System.runAs(editor) {
			insert recipe;
		}
		String recipeId = recipe.Id;
        
        controller.setRecipeId(recipeId);
        controller.getRecipeId();
        
        System.runAs(editor) {
          controller.getDraftRecipes();
        }
        
      recipe.Status__c='Approved';
        System.runAs(editor) {
        	update recipe;
        }
        
        System.runAs(admin) {
        	controller.getApprovedRecipes();
        }
        
        System.runAs(editor) {
        	recipe.Current_Editor__c=editor.Id;
        	update recipe;
        	controller.getApprovedRecipes();
        }
        
        
        
        recipe.Status__c='Rejected';
       
       	System.runAs(editor) {
        	update recipe;
       	}
        controller.isSuperAdmin=true;
        
        System.runAs(admin) {
       		controller.getRejectedRecipes();
        }
        
        recipe.Current_Editor__c = UserInfo.getUserId();
        System.runAs(editor) {
       		update recipe;
        }
        
        controller.isSuperAdmin=false;
        controller.getRejectedRecipes();
        
        recipe.Status__c='Pending';
        recipe.recordSaved__c = true;
        System.runAs(editor) {
        	update recipe;
        }
        
        
        recipe.reviewedBy__c = UserInfo.getUserId();
        
        System.runAs(editor) {
			update recipe;
        }
		
		String userId = UserInfo.getUserId();
		
		
		
		System.runAs(editor) {
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
			
			req1.setNextApproverIds(new Id[]{editor.Id});
			req1.setObjectId(recipe.Id);   
			Approval.ProcessResult result = Approval.process(req1);
		}
		
		recipe.Status__c = 'Pending Review';
		System.runAs(editor) {
			recipe.Current_Editor__c = editor.Id;
			update recipe;
        	controller.getPendingRecipes();
		}
        
        recipe.Status__c='Archive';
        System.runAs(editor) {
        	update recipe;
        }
        
        System.runAs(editor) {
        	controller.getRecipesSentFromCurrentUser();
        }
        
        System.runAs(admin) {
        	controller.getArchivedRecipes();
        }
        
        list<Id> RecIdList = controller.recipeRejIds;
        
        controller.getUserAgent();
        controller.parseListForQuery(RecIdList);
        controller.editRecipe();
        controller.getHasArchivedRecipes();
        controller.getHasPendingRecipes();
        controller.getHasRejectedRecipes();
        controller.getHasApprovedRecipes();
        controller.getHasDraftRecipes();
        controller.getAuthorName(UserInfo.getUserId());
        
        controller.showLessApprovedRecipes();
        controller.showlessArchivedRecipes();
        controller.showLessPendingApprovalRecipes();
        controller.showLessRejectedRecipes();
        controller.showLessEditor();
        controller.showMoreApprovedRecipes();
        controller.showMoreArchivedRecipes();
        controller.showMoreEditor();
        controller.showMorePendingApprovalRecipes();
        controller.showMoreRejectedRecipes();
    }
}