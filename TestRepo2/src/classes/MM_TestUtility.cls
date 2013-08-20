@isTest
private class MM_TestUtility { 
	
    static testMethod void myUnitTest() {
		
		UserRole editorRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_EDITOR ];
	    //UserRole reviewerRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_REVIEWER];
	    UserRole publisherRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_PUBLISHER];
	    UserRole approverRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_APPORVER];
		
	    List<User> lstUser = new List<User>();	
			User editor = new User(alias = 'unittest', email='unittest@diageorecipes.com', 
	            emailencodingkey='UTF-8', lastname='Testing', 
	            languagelocalekey='en_US', 
	            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = editorRole.Id,
	            timezonesidkey='America/Los_Angeles', 
	            username='unittest@diageorecipes.com');
	    lstUser.Add(editor);        
	    /*
	    User reviewer = new User(alias = 'unitrev', email='unitrev@diageorecipes.com', 
	            emailencodingkey='UTF-8', lastname='Testing', 
	            languagelocalekey='en_US', 
	            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = reviewerRole.Id,
	            timezonesidkey='America/Los_Angeles', 
	            username='unitrev@diageorecipes.com');*/
	    User publisher = new User(alias = 'unitrev', email='unitrev@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = publisherRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unitrev@diageorecipes.com');
            
	    lstUser.Add(publisher);        
	    User approver = new User(alias = 'unitapp', email='unitapp@diageorecipes.com', 
	            emailencodingkey='UTF-8', lastname='Testing', 
	            languagelocalekey='en_US', 
	            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = approverRole.Id,
	            timezonesidkey='America/Los_Angeles', 
	            username='unitapp@diageorecipes.com');
	    lstUser.Add(approver);        
	    insert lstUser;
        
    	
    	
		Master_Recipe__c master = new Master_Recipe__c();
		
		System.runAs(editor) {
			insert master;
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
		
		//MM_Utility util = new MM_Utility();
		String userId = UserInfo.getUserId();
		
		System.runAs(editor) {
		  MM_Utility.cloneRecipeInformation(recipe.Id);		
		  MM_Utility.deleteRecordNotSaved();
		  MM_Utility.getProcessWorkItemsByRecipe(recipe.Id);
		}
		
		//recipe.ReviewedBy__c = reviewer.Id;
		recipe.ReviewedBy__c = publisher.Id;
		
		System.runAs(editor) {
			update recipe;
		}
		
    	System.runAs(editor) {
		
		
		
			Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
			req1.setComments('TEST');
			//req1.setNextApproverIds(new Id[]{reviewer.Id});
			req1.setNextApproverIds(new Id[]{publisher.Id});
			req1.setObjectId(recipe.Id);   
			Approval.ProcessResult result = Approval.process(req1);
    	}
		
		List<ProcessInstanceWorkitem> processWorkItems = MM_Utility.getProcessWorkItemsByRecipe(recipe.Id);
			
		//System.runAs(reviewer) {
		System.runAs(publisher) {
			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
			req.setNextApproverIds(new Id[] {approver.Id});
			req.setAction('Approve');
			req.setWorkitemId(processWorkItems[0].Id); 
			Approval.ProcessResult result =  Approval.process(req);
		}
		
		
		MM_Utility.getRecipesByApprover(approver.Id);
		
		MM_Utility.processApproval('Rejected',recipe.Id,approver.Id);
		
		MM_Utility.getCurrentRejectedRecipesByUser(editor.Id, 'Rejected');
		
		MM_Utility.getCurrentRecipesApprovedByUser(approver.Id, 'Rejected');
		
		MM_Utility.archiveRecipe(recipe);
		MM_Utility.deleteRecipe(recipe);
		
		MM_Utility.isEmptyPickListValue('Blah blah blah');
		
		MM_Utility.listToString(new List<String>{'abc','xyx','test'},';');
		
		MM_Utility.IngredientsWrapper_New ingW = new MM_Utility.IngredientsWrapper_New(recipe.Id);
    } 
}