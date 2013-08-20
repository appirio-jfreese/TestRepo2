@isTest(SeeAllData=true)
private class MM_TestMediaController {

    static testMethod void myUnitTest() {
	   	Master_Recipe__c master = new Master_Recipe__c();
	    insert master;
	    
		Recipe__c recipe = new Recipe__c();
		recipe.Master_Recipe__c=master.Id;
		recipe.Recipe_Title__c = 'TEST Recipe PREP STEPS';
		recipe.Locale__c = 'EN-US';
		recipe.Preparation_Steps__c='TEST PREP STEPS';
		insert recipe;
		  
		  
      	MM_MediaController controller = new MM_MediaController (recipe.Id);     
        controller.editMode = 'false';
	 	ContentVersion myImage = new ContentVersion();
	 	myImage.title='TITLE';
	 	//myImage.contentUrl='http://www.salesforce.com'; 		
 		myImage.VersionData = Blob.valueOf('sdfasfsafsf');
 		myImage.PathOnClient = 'test.png';
	    insert myImage;
	    controller.myImage=myImage;
	    controller.upload();
        
  		Recipe_Media__c media = new Recipe_Media__c();
 	    media.Content_id__c=myImage.Id;
      	insert media;
        
		controller.loadAllImages();
      
	    List<String> mediaName = new List<String>();
	    mediaName.add('mainRecipe');
	    mediaName.add('mobileDrink');
	    mediaName.add('mainIngredient');
	    mediaName.add('additional1');
	    mediaName.add('additional2');
	    mediaName.add('background');
	    mediaName.add('brandRecipe');
	    mediaName.add('searchRecipe');
	    mediaName.add('searchRecipe');
	    mediaName.add('mobileSelected');
	    mediaName.add('mobileUnselected');
              
	   	for (String name:mediaName) {
	   		controller.mediaName=name;
	   		controller.mediaId=media.Id;
	    	controller.associateMedia();
	    	controller.setMediaType2();
	   	}
	   	
	   	
	   	controller.saveImages();
        
	    controller.close();
	    controller.loadRecentImages();
	    
	    controller.showUpload();
	    controller.showSelectImages();
	    controller.imageNameFilter='test';
	    controller.filterImages();
	    controller.getUserAgent();
	    controller.getAlphabets();
	    MM_MediaController.setMediaType('image');
       
	   
	    
	    controller.setMediaType2();
	    mediaName.add('mainRecipe');
	    mediaName.add('mobileDrink');
	    mediaName.add('mainIngredient');
	    mediaName.add('additional1');
	    mediaName.add('additional2');
	    mediaName.add('background');
	    mediaName.add('brandRecipe');
	    mediaName.add('searchRecipe');
	    mediaName.add('searchRecipe');
	    mediaName.add('mobileSelected');
	    mediaName.add('mobileUnselected');
	    
	    for (String name:mediaName) {
        controller.mediaName=name;
        controller.mediaId=media.Id;
        controller.disassociateMedia();
      }
      
      
      PageReference pg = page.MM_Media;
      Test.setCurrentPageReference(pg);
      ApexPages.currentPage().getParameters().put('recipeId',recipe.Id);
      controller = new MM_MediaController();    
    
    }
}