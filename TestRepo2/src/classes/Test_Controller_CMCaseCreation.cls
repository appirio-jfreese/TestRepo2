/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * Created by Akanksha(offshore) for case  00003540
 */
@isTest
private class Test_Controller_CMCaseCreation {

    static testMethod void myUnitTest() {
    	Case newcase = Test_Helper.testInsertCase('New');
        ApexPages.currentPage().getParameters().put('id', newcase.id);
        ApexPages.currentPage().getParameters().put('caseType', newcase.Type);
        Controller_CMCaseCreation classcontroller = new Controller_CMCaseCreation();
        classcontroller.addNewComment();
        classcontroller.newCommentText = 'Hello its new comment';
        classcontroller.addNewComment();
        classcontroller.addNewCase();
        classcontroller.newCaseText = 'DescriptionCase';
        classcontroller.newCaseTitleText = 'Case Title';
        classcontroller.newCasePhone = '991299999991';
        classcontroller.newCaseEmail = 'a@test.com';
        classcontroller.newCaseFirstName = 'TestFName';
        classcontroller.newCaseLastName = 'TestLName';
        classcontroller.newApplication = 'newApplication';
        classcontroller.attachment.Body = EncodingUtil.base64Decode('body of my attachement');
        classcontroller.addNewCase();
        classcontroller.getCaseStatusList();
        classcontroller.getCaseTypeList();
        classcontroller.getCMApplicationList();
        classcontroller.changeViewStatus();
 
    }
}