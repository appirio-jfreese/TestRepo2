@isTest
private class Test_Controller_Home {
    
    class TestSettings {
        List <NewsAndArticles__c> newsAndArticles;
        HomeVideo__c currentVideo;
        public TestSettings(){
            List <NewsAndArticles__c> news = [select id from NewsAndArticles__c];
            delete news;
            List <HomeVideo__c> videos = [select id from HomeVideo__c];
            delete videos;
            newsAndArticles = new NewsAndArticles__c[]{ 
                Test_Helper.testInsertNewsAndArticles('title1', 'body1'),
                Test_Helper.testInsertNewsAndArticles('title2', 'body2'),
                Test_Helper.testInsertNewsAndArticles('title3', 'body3'),
                Test_Helper.testInsertNewsAndArticles('title4', 'body4'),
                Test_Helper.testInsertNewsAndArticles('title5', 'body5'),
                Test_Helper.testInsertNewsAndArticles('title6', 'body6')
            };
        }
        
        public void addVideos(){
            Test_Helper.testInsertHomeVideo('1115632928001', 'name1', 'description1', false);
            currentVideo = Test_Helper.testInsertHomeVideo('1115632928002', 'name2', 'description2', true);
        }
    }
    
    static testmethod void testHome(){
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);
        
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'divisionName', Type__c = 'Spirits');
        insert division;
        Account account = Test_Helper.testInsertAccount('test_account', division.Id);
        Contact contact = Test_Helper.testInsertContact('firstName', 'lastName', account.id);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];   
        User usr;
        System.runAs (thisUser) {
            usr = Test_Helper.testInsertDistributorPortalUser(contact.id);
        } 

        TestSettings ts = new  TestSettings();
        
        System.runAs(usr){  
            Controller_Home c = new Controller_Home();
            System.assertEquals(6, c.articles.size());
            System.assertEquals('none', c.showPlayer);
        }
    }
    
    static testmethod void testHomeWithVideo(){
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);
        
        TestSettings ts = new  TestSettings();
        
        Organizational_Unit__c division = new Organizational_Unit__c(Label__c = 'Division', Name = 'divisionName', Type__c = 'Spirits');
        insert division;
        Account account = Test_Helper.testInsertAccount('test_account', division.Id);
        Contact contact = Test_Helper.testInsertContact('firstName', 'lastName', account.id);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];   
        User usr;
        System.runAs (thisUser) {
            usr = Test_Helper.testInsertDistributorPortalUser(contact.id);
        }

        ts.addVideos();

        System.runAs(usr){  
            Controller_Home c = new Controller_Home();
            System.assertEquals(6, c.articles.size());
            System.assertEquals('block', c.showPlayer);
            System.assertEquals('1115632928002', c.videoId);
            System.assertEquals('description2', c.videoDesc);
        }
    }
}