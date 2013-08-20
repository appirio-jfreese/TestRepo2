@isTest
public class Test_Delete {
	public static testmethod void testFile(){
		Test.starttest();
		File__c fileFirst 	 = Test_Helper.testInsertFile();
		
		ApexPages.StandardController fd = new ApexPages.standardController(fileFirst);
		Controller_FileDelete d = new Controller_FileDelete(fd);
		d.deleteAndRedirect();
		Test.stoptest();
	}
	
	public static testmethod void testContent(){
		Test.starttest();
		Content_Description__c cd 	 = Test_Helper.testInsertContentDescription();
		
		ApexPages.StandardController fd = new ApexPages.standardController(cd);
		Controller_ContentDescDelete d = new Controller_ContentDescDelete(fd);
		d.deleteAndRedirect();
		Test.stoptest();
	}
}