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
private class Test_Service_FolderComments {

	private static Organizational_Unit__c division;
	private static Account a;
	private static Contact c;
	private static User u;
	private static User thisUser;
	private static Folder__c folder;
	private static File__c file;

    private static void beforeTest(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        division = new Organizational_Unit__c(Label__c = 'Division', Name = 'Control', Type__c ='Spirits');
        insert division;
        a = Test_Helper.testInsertAccount('Test Account');
        c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];   
        folder = Test_Helper.testInsertFolder(true, true, division.Id, false, false, 'Collaboration', null, null);
        file = Test_Helper.testInsertFile();
    }
    
	static testMethod void mainTestAsDistributorFileComment() {
    	beforeTest();
    	
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
        
        // test file comments
		mainTest();
    }

    static testMethod void mainTestAsDiageoFileComment() {
    	beforeTest();

        System.runAs (thisUser) {
            u = Test_Helper.testInsertDiageoPortalUser(c.ID);
        }

        // test file comments
		mainTest();
    }
    
	static testMethod void mainTestAsDistributorFolderComment() {
    	beforeTest();
    	
        System.runAs (thisUser) {
            u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
        
		file = null;
		mainTest();		
    }

    static testMethod void mainTestAsDiageoFolderComment() {
    	beforeTest();

        System.runAs (thisUser) {
            u = Test_Helper.testInsertDiageoPortalUser(c.ID);
        }

		file = null;
		mainTest();		
    }
    
    static testMethod void deleteCommentSecurityTest() {
    	beforeTest();

        Account a1 = Test_Helper.testInsertAccount('Test Account1');
        Contact c1 = Test_Helper.testInsertContact('TestFirst1', 'TestLast1', a1.ID);
        Account a2 = Test_Helper.testInsertAccount('Test Account2');
        Contact c2 = Test_Helper.testInsertContact('TestFirst2', 'TestLast2', a2.ID);
		User diageoUser, distributorUser;
        String diageoCommentId, distributorCommentId;
        
        System.runAs (thisUser) {
            diageoUser = Test_Helper.testInsertDiageoPortalUser(c1.ID);
            distributorUser = Test_Helper.testInsertDistributorPortalUser(c2.ID);
        }

		Test.StartTest();
        
        System.runAs (diageoUser) {
			diageoCommentId = addCommentAsUser(diageoUser, 'Diageo comment 1', true);
        }

        System.runAs (distributorUser) {
			distributorCommentId = addCommentAsUser(distributorUser, 'Distributor comment 1', false);
        }

        System.runAs (diageoUser) {
			removeCommentAsUser(diageoUser, distributorCommentId, true, true);
        }

        System.runAs (distributorUser) {
			removeCommentAsUser(distributorUser, diageoCommentId, false, false);
        }
       
        Test.StopTest();
    }
    
    private static String addCommentAsUser(User usr, String txt, Boolean isInternal){
		String addedCommentId;                    
    	System.runAs(usr){
	        Service_FolderComments fcService = new Service_FolderComments();
	        fcService.commentBody = txt;
	        fcService.distributorId = a.ID;
	        fcService.folderId = folder.Id;
	        fcService.fileId = file.Id;
	        fcService.isInternalUser = isInternal;
	        list<Folder_Comment__c> folderCommentListBeforeAdd = fcService.getFileComments();
	        list<Folder_Comment__c> folderCommentListBeforeAddToShow = fcService.getCommentsToShow();
	        fcService.addCommentMsg();
	        list<Folder_Comment__c> folderCommentListAfterAdd = fcService.getFileComments();
	        list<Folder_Comment__c> folderCommentListAfterAddToShow = fcService.getCommentsToShow();
	        System.assertEquals(folderCommentListBeforeAdd.size()+1, folderCommentListAfterAdd.size());
	        System.assertEquals(folderCommentListBeforeAddToShow.size()+1, folderCommentListAfterAddToShow.size());
	        System.assertEquals(fcService.isAdded, true);
	        
			// find comment and check that all values are correct
            for(Folder_Comment__c comment : folderCommentListAfterAdd){
                if(comment.Comment_Body__c == txt){
                    System.assertEquals(comment.Distributor_Name__c, Service_API.getAID());
                    System.assertEquals(comment.Distributor_Access__c, a.ID);
                    System.assertEquals(comment.File__c, file.ID);
                    System.assertEquals(comment.Folder__c, folder.ID);
                    addedCommentId = comment.id;
                }
            }
    	}
    	System.assert(addedCommentId != null && !addedCommentId.equals(''));
    	return addedCommentId;
    }
    
    private static void removeCommentAsUser(User usr, String commentId, Boolean isInternal, Boolean showBeRemoved){
    	System.runAs(usr){
	        Service_FolderComments fcService = new Service_FolderComments();
	        fcService.distributorId = a.ID;
	        fcService.folderId = folder.Id;
	        fcService.fileId = file.Id;
	        fcService.isInternalUser = isInternal;
	        fcService.removeCommentId = commentId;
	        list<Folder_Comment__c> folderCommentListBeforeRemove = fcService.getFileComments();
	        fcService.removeCommentMsg();
	        list<Folder_Comment__c> folderCommentListAfterRemove = fcService.getFileComments();
	        if(showBeRemoved){
	        	System.assertEquals(folderCommentListBeforeRemove.size()-1, folderCommentListAfterRemove.size());
	        } else {
	        	System.assertEquals(folderCommentListBeforeRemove.size(), folderCommentListAfterRemove.size());
	        }
    	}
    }
    
	private static void mainTest(){
        Test.StartTest();
        System.runAs(u){
	        Service_FolderComments fcService = new Service_FolderComments();
	        fcService.commentBody = 'Test body';
	        fcService.distributorId = a.ID;
	        fcService.folderId = folder.Id;
	        fcService.folderName = folder.Name;
	        if(file != null){
	        	fcService.fileId = file.Id;
	        	System.assert(fcService.fileName != null);
	        }
	        fcService.isInternalUser = false;
        	System.assertEquals(0, ApexPages.getMessages().size());

			// add comment
            fcService.addCommentMsg();
            list<Folder_Comment__c> allFolderCommentListAfterAdd = Service_API.getFolderComments(a.id, folder.Id);
            list<Folder_Comment__c> folderCommentListAfterAdd = fcService.getFileComments();
            list<Folder_Comment__c> folderCommentListAfterAddToShow = fcService.getCommentsToShow();
            // check that comment was properly added
            System.assertEquals(1, ApexPages.getMessages().size());
            System.assertEquals('Comment added.', ApexPages.getMessages().get(0).getSummary());
            System.assertEquals(1, folderCommentListAfterAdd.size());
            System.assertEquals(1, folderCommentListAfterAddToShow.size());
            System.assertEquals(fcService.isAdded, true);
			// find comment and check that all values are correct
			String addedCommentId;                    
            for(Folder_Comment__c comment : folderCommentListAfterAdd){
                if(comment.Comment_Body__c == 'Test body'){
                    System.assertEquals(comment.Distributor_Name__c, Service_API.getAID());
                    System.assertEquals(comment.Distributor_Access__c, a.ID);
                    if(file != null){
                    	System.assertEquals(comment.File__c, file.ID);
                    }
                    System.assertEquals(comment.Folder__c, folder.ID);
                    addedCommentId = comment.id;
                }
            }
                
            // remove added comemnt
	        fcService.distributorId = a.ID;
	        fcService.folderId = folder.Id;
			if(file != null){
	        	fcService.fileId = file.Id;
			}
	        fcService.removeCommentId = addedCommentId;
            fcService.removeCommentMsg();
            System.assertEquals(2, ApexPages.getMessages().size());    
			System.assertEquals('Comment removed.', ApexPages.getMessages().get(1).getSummary());
           	list<Folder_Comment__c> folderCommentListAfterRemove = fcService.getFileComments();
           	System.assertEquals(0, folderCommentListAfterRemove.size());

			// test more comments
			String setting_numberOfCommentsToShow = Service_API.getSetting('numberOfCommentsToShow.default');
			String setting_incrementNumberOfComments = Service_API.getSetting('numberOfCommentsToShow.increment');
			if(setting_numberOfCommentsToShow == null || setting_numberOfCommentsToShow.equals(''))  setting_numberOfCommentsToShow = '20';
			Integer numberOfCommentsToAdd = Integer.valueOf(setting_numberOfCommentsToShow)+1;
            for(Integer i = 0; i < numberOfCommentsToAdd; i++){
				fcService.commentBody = 'Test body '+String.valueOf(i);
				fcService.addCommentMsg();
            }
            System.assertEquals(2, ApexPages.getMessages().size());    
            list<Folder_Comment__c> folderCommentListAll = fcService.getFileComments();
            list<Folder_Comment__c> folderCommentListToShow = fcService.getCommentsToShow();
            System.assert(folderCommentListAll.size() > folderCommentListToShow.size());
            System.assertEquals(true, fcService.hasMoreComments);
            fcService.showMoreComments();
            folderCommentListAll = fcService.getFileComments();
            folderCommentListToShow = fcService.getCommentsToShow();
            System.assert(folderCommentListAll.size() == folderCommentListToShow.size());
            System.assertEquals(false, fcService.hasMoreComments);

            // test validations
            System.assertEquals(2, ApexPages.getMessages().size());    
			fcService.commentBody = '';
            fcService.addCommentMsg();
            System.assertEquals(3, ApexPages.getMessages().size());    
			System.assertEquals('Unable to add comment. Comment text is required.', ApexPages.getMessages().get(2).getSummary());
			fcService.commentBody = 'a';
            fcService.removeCommentMsg();
    		System.assertEquals(4, ApexPages.getMessages().size());    
			System.assertEquals('Unable to remove comment.', ApexPages.getMessages().get(3).getSummary());
        }
        Test.StopTest();
    }
}