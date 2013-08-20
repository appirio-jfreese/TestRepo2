@isTest(SeeAllData=true)
public class Test_Service_EditFile {

    public static testmethod void testEdit(){
        ContentVersion cv = [select Id, File__c from ContentVersion limit 1];
        Account account = new Account(Name = 'A B');
        insert account;
        Folder__c folder = new Folder__c();
        insert folder;
        Test.startTest();
        
        Service_EditFile sv = new Service_EditFile();
        sv.file = cv;
        sv.DistributorId = account.id;
        sv.folderId = folder.id;
        sv.commentBody = 'ABC';
        sv.saveFile();
        sv.fileId = cv.id;
        sv.file = cv;
        sv.description = 'abc';
        sv.saveFile();
        
        Test.stopTest();
    }
    
    public static testmethod void testReplace(){
        ContentVersion cv1 = [select Id, File__c, PathOnClient, ContentDocumentId, VersionData from ContentVersion where PathOnClient != null limit 1];
        Account account = new Account(Name = 'A B');
        insert account;
        Folder__c folder = new Folder__c();
        insert folder;
        User user = new User(Id = UserInfo.getUserId());
        Test.startTest();
        
        system.runas(user){
	        Service_EditFile sv = new Service_EditFile();
	        sv.file = cv1;
	        sv.organizationalHierarchyName = 'Control';
	        sv.DistributorId = account.id;
	        sv.folderId = folder.id;
	        sv.commentBody = 'ABC';
	        sv.replaceFile();
	        sv.description = 'abc';
	        sv.PathOnClient = 'dummy file';
	        sv.replaceFile();
        }
        Test.stopTest();
    }
    
    public static testmethod void testDelete(){
        ContentVersion cv = [select Id, File__c from ContentVersion limit 1];
        Account account = new Account(Name = 'A B');
        insert account;
        Folder__c folder = new Folder__c();
        insert folder;
        Test.startTest();
        
        Service_EditFile sv = new Service_EditFile();
        sv.file = cv;
        sv.DistributorId = account.id;
        sv.folderId = folder.id;
        sv.commentBody = 'ABC';
        sv.deleteFile();
        sv.description = 'abc';
        sv.deleteFile();
        
        Test.stopTest();
    }

}