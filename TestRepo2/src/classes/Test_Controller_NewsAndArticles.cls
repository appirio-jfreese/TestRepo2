@isTest
private class Test_Controller_NewsAndArticles {

	class TestSettings {
	 	List <NewsAndArticles__c> newsAndArticles;
	  	Contact contact;
        Account account;
        User user;
		
		public TestSettings(){
			
         	account = Test_Helper.testInsertAccount('test_account1');
         	contact = Test_Helper.testInsertContact('firstName', 'lastName', account.id);
         	
         	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];   
	        System.runAs (thisUser) {
         		user = Test_Helper.testInsertDistributorPortalUser(contact.id);
	        }
         	
			List <NewsAndArticles__c> news = [select id from NewsAndArticles__c];
			delete news;
			newsAndArticles = new NewsAndArticles__c[]{ 
				Test_Helper.testInsertNewsAndArticles('title1', 'body1'),
				Test_Helper.testInsertNewsAndArticles('title2', 'body2'),
				Test_Helper.testInsertNewsAndArticles('title3', 'body3'),
				Test_Helper.testInsertNewsAndArticles('title4', 'body4'),
				Test_Helper.testInsertNewsAndArticles('title5', 'body5'),
				Test_Helper.testInsertNewsAndArticles('title6', 'body6')
			};
		}
	}
	
	static testmethod void testNewsAndArticles(){
		PageReference pageRef = Page.NewsAndArticles;
        Test.setCurrentPage(pageRef);

		TestSettings ts = new  TestSettings();
		Test.StartTest();
		System.RunAs(ts.user){
	        
		 	ApexPages.currentPage().getParameters().put('id', ts.newsAndArticles[0].id);
		 	Controller_NewsAndArticles c = new Controller_NewsAndArticles();
		 	System.assertEquals(6, c.articles.size());
		 	System.assertEquals(ts.newsAndArticles[0].id, c.currentArticle.id);
		 	System.assertEquals('title1', c.currentArticle.title__c);
		 	System.assertEquals('body1', c.currentArticle.BodyText__c);
		}
		Test.StopTest();
	}
}