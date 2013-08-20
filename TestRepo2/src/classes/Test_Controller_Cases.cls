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
private class Test_Controller_Cases {


	class TestSettings {
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
      	}
	}

	static testmethod void testConstructor(){
		TestSettings ts = new  TestSettings();
		Test.StartTest();
		System.RunAs(ts.user){
 		
	 		PageReference pageRef = Page.Cases;
	        Test.setCurrentPage(pageRef);
	
			Case newCase = Test_Helper.testInsertCase('New'); 
			ApexPages.currentPage().getParameters().put('id', newCase.ID);
	
			Controller_Cases controller = new Controller_Cases();
			System.assertEquals(controller.currentCase.status, newCase.status);
			System.assertEquals(controller.currentCase.ID, newCase.ID);
			System.assertEquals(controller.currentCase.subject, newCase.subject);
			System.assertEquals(controller.currentCase.Description, newCase.Description);
			System.assertEquals(controller.displayWithStatus, newCase.status);
			for(Case c : controller.cases){
				System.assertEquals(c.status, controller.displayWithStatus);			
			}
			for(CaseComment cc : controller.currentCaseComments){
				System.assertEquals(cc.ParentId, newCase.ID);			
			}
		}	
 		Test.StopTest();   	
	}

	static testmethod void refreshPageContentTest(){
		TestSettings ts = new  TestSettings();
		Test.StartTest();
		System.RunAs(ts.user){

			PageReference pageRef = Page.Cases;
	        Test.setCurrentPage(pageRef);
	
			Case newCase = Test_Helper.testInsertCase('New'); 
			ApexPages.currentPage().getParameters().put('id', newCase.ID);
	
			Controller_Cases controller = new Controller_Cases();
			controller.refreshPageContent();
			System.assertEquals(controller.currentCase.status, newCase.status);
			System.assertEquals(controller.currentCase.ID, newCase.ID);
			System.assertEquals(controller.currentCase.subject, newCase.subject);
			System.assertEquals(controller.currentCase.Description, newCase.Description);
			System.assertEquals(controller.displayWithStatus, newCase.status);
			for(Case c : controller.cases){
				System.assertEquals(c.status, controller.displayWithStatus);			
			}
			for(CaseComment cc : controller.currentCaseComments){
				System.assertEquals(cc.ParentId, newCase.ID);			
			}
		}			
 		Test.StopTest();   	
	}
	

	static testmethod void changeViewStatusTest(){
		TestSettings ts = new  TestSettings();
		Test.StartTest();
		System.RunAs(ts.user){
			PageReference pageRef = Page.Cases;
	        Test.setCurrentPage(pageRef);
	
			Controller_Cases controller = new Controller_Cases();
			controller.changeViewStatus();
			System.assertEquals(controller.currentCase, null);
			System.assertEquals(controller.currentCaseComments, null);
		}	
 		Test.StopTest();
 		   	
	}	

	static testmethod void addNewCommentTest(){
		TestSettings ts = new  TestSettings();
		Test.StartTest();
		System.RunAs(ts.user){
	 		PageReference pageRef = Page.Cases;
	        Test.setCurrentPage(pageRef);
	
			Case newCase = Test_Helper.testInsertCase('New'); 
			ApexPages.currentPage().getParameters().put('id', newCase.ID);
	
			String testCommentBodyString = 'New comment test text';
			Controller_Cases controller = new Controller_Cases();
			controller.newCommentText = testCommentBodyString;
			controller.addNewComment();
			System.assertEquals(controller.newCommentText, null);
			list<CaseComment> currentCaseComments = Service_API.getCaseComment(newCase);
	
			System.assertEquals(1, currentCaseComments.size());
					
			for(CaseComment comment : currentCaseComments){
				if(comment.CommentBody == testCommentBodyString){
					System.assertEquals(comment.ParentId, newCase.ID);
				}
			}
		}			
 		Test.StopTest();
 		   	
	}	

	static testmethod void addNewCaseTest(){
		TestSettings ts = new  TestSettings();
		Test.StartTest();
		System.RunAs(ts.user){
	 		PageReference pageRef = Page.Cases;
	        Test.setCurrentPage(pageRef);
	
			Controller_Cases controller = new Controller_Cases();
			String caseText = 'Test new case text';
			String caseTitle = 'Test new case title';
			String phone = '000000';
			String email = 'text@test.com';
			String fname = 'first name';
			String lname = 'last name';
			String ctype = 'Other';
			String origin = 'Web';   
	
	
			list<Case> currentCasesBeforeAdd = Service_API.getUserCases('New');
					
			controller.newCaseText = caseText;
			controller.newCaseTitleText  = caseTitle;
			controller.newCasePhone = phone;
			controller.newCaseEmail = email;
			controller.newCaseFirstName = fname;
			controller.newCaseLastName = lname;
			controller.newCaseType = ctype;
			
			controller.addNewCase();
			
			System.assertEquals(controller.newCaseText, caseText);
			System.assertEquals(controller.newCaseTitleText, caseTitle);
	
			list<Case> currentCasesAfterAdd = Service_API.getUserCases('New');
	
			//System.assertEquals(currentCasesBeforeAdd.size()+1, currentCasesAfterAdd.size());
	
			for(Case newCase : currentCasesAfterAdd){
				if(newCase.Subject == caseTitle){
					System.assertEquals(newCase.Description, caseText);
					System.assertEquals(newCase.Status, 'New');
					System.assertEquals(newCase.Subject, caseTitle);
				}
			}
		}		
 		Test.StopTest();
	}	
	
}