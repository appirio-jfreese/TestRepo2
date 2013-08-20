/******************************************************************************
    Name        :   Test_Controller_BlogPost 
    Author      :   Basant Kumar Verma(Appirio Offshore)
    Created Date:   10 June, 2013
    Purpose     :   Test Class for Controller_BlogPost 
*******************************************************************************/
@isTest
private class Test_Controller_BlogPost {
		private static List<Blog__c> blogs;
		private static List<Tag__c> tags;
		private static String theme;
		private static User testUser;
		private static List<Brand__c> brands;
		private static List<Blog2Tag__c> blogTags;
		private static Account acc;
		private static Controller_BlogPost controller;
		
    static testMethod void myUnitTest() {
        Test.startTest();
        createTestData();
        System.runAs(testUser){
        	PageReference pageRef = Page.BlogPosts;
				  Test.setCurrentPageReference(pageRef);
				  controller = new Controller_BlogPost();
				  controller.getDisplayOptions();
				  controller.blogFormat = 'TitlesAndShortDesc';
				  ApexPages.currentPage().getParameters().put('blogTagsParam', 'Location:Test');
				   
				  List<String> currTags = controller.blogTags;
				  List<Blog__c> currBlogs = controller.blogPosts;
				  blogs = controller.allBlogPosts;
				  System.assertEquals(controller.allBlogPosts.size(),12);
				  System.assertEquals(controller.blogCount,5);
				  System.assertEquals(controller.blogPostsCount, 5);
				  
				  controller.nextPage();
				  System.assertEquals(controller.blogPostsCount, 5);
				  
				  controller.nextPage();
				  System.assertEquals(controller.blogPostsCount, 2);
				  
				  controller.previousPage();
				  controller.previousPage();
				  controller.currPage = 2;
				  controller.pageChanged();
				  controller.currPage = 1;
				  controller.pageChanged();
				  controller.clickedBlogId = blogs.get(1).Id;
				  pageRef = controller.openBlogDetail();
				  Test.setCurrentPageReference(pageRef);
				  controller.initBPDetails();
				  
				  System.assertNotEquals(controller.blogItem, null);
				  System.assertEquals(controller.blogItem.id,blogs.get(1).Id);
				  
				  controller.newComment.Comment__c = 'Test Comment';
				  controller.postComment();
				  controller.nextPost();
				  System.assertEquals(controller.blogItem.id,blogs.get(2).Id);
				  controller.nextPost();
				  System.assertEquals(controller.blogItem.id,blogs.get(3).Id);
				  controller.previousPost();
				  System.assertEquals(controller.blogItem.id,blogs.get(2).Id);
				  
				  System.assertNotEquals(controller.tagList.size(), null);
				  System.assertNotEquals(controller.acrhiveMap.keySet().size(), null);
				  System.assertNotEquals(controller.getArchiveList().size(), null);
				  
				  controller.switchToTag();
				  controller.switchToTheme();
				  for(String key : controller.acrhiveMap.keySet()){
				  	controller.archive = key+' ';
				  	controller.switchToArchive();
				  }
				  
				  ApexPages.currentPage().getParameters().put('filterByTag', 'Location:Test');
				  controller.processFilters();
				  
        }
        Test.stopTest();
    }
    
    static void createTestData(){
    	testUser = Test_Helper.generateTestUser('TUser', true, 'System Administrator');
    	theme = testUser.Diageo_Direct_Theme__c;
    	
    	Brand__c brand1 = Test_Helper.testCreateBrand('TestBrand1', null, null);
    	insert brand1;
    	acc = Test_helper.testInsertAccount('Test Account');
    	//AccountBrand__c acb = Test_Helper.testInsertAccountBrand(acc.Id, brand1.Id);
    	Account_Member__c am = new Account_Member__c();
    	am.Account__c = acc.Id;
    	am.User__c = testUser.id;
    	am.Default__c = true;
			insert am;
    	
    	tags = new List<Tag__c>();
    	Tag__c t = new Tag__c();
			t.Name = 'Test';
			t.Type__c = 'Location';
			tags.add(t);
    	insert tags;
    	
    	blogs = new List<Blog__c>();
    	for(Integer i=0; i<12; i++){
    		Blog__c b = new Blog__c();
    		b.AllowComments__c = true;
    		b.Detail__c = 'TestClass Blog'+1;
    		b.StartDate__c = DateTime.newInstance(2008, i+1, 1);
    		b.EndDate__c = DateTime.newInstance(2008, i+1, 1).addYears(1);
    		b.Name = 'Test Clss Blog'+1;
    		b.Sub_Title__c = 'Test Blog'+1;
    		b.Summary__c = 'Test Blog Summary'+1;
    		b.Theme__c = theme;
    		blogs.add(b);
    	}
    	insert blogs;
    	
    	blogTags = new List<Blog2Tag__c>();
    	for(Integer i=0; i<12; i++){
    		Blog2Tag__c bt = new Blog2Tag__c();
    		bt.Blog__c = blogs.get(i).Id;
    		bt.Tag__c = t.Id;
    		blogTags.add(bt);
    	}
    	insert blogTags;
    	
    }
}