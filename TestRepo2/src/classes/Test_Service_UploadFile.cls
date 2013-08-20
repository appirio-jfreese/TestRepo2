@isTest
public class Test_Service_UploadFile {

	private static Organizational_Unit__c division {private get; private set;}
	private static Organizational_Unit__c region {private get; private set;}
	private static Organizational_Unit__c district {private get; private set;}
	private static Organizational_Unit__c market {private get; private set;}
	private static String distributorName {private get; private set;}
	private static String distributorId {private get; private set;}
		
    private static Id folderId {private get; private set;}
    private static Id organizationalHierarchyId {private get; private set;}
    private static String organizationalHierarchyName {private get; private set;}
		
	static private void setup(){
        division = new Organizational_Unit__c(Label__c = 'Division', Name = 'divisionName', Type__c='Spirits');
        insert division;
        region = new Organizational_Unit__c(Label__c = 'Region', Name = 'regionName', Parent__c=division.Id, Type__c='Spirits');
        insert region;
        district = new Organizational_Unit__c(Label__c = 'State District', Name = 'regionName', Parent__c=region.Id, Type__c='Spirits');
        insert district;
        market = new Organizational_Unit__c(Label__c = 'Market', Name = 'regionName', Parent__c=district.Id, Type__c='Spirits');
        insert market;
        organizationalHierarchyId = market.id;
        organizationalHierarchyName = market.name;
	}

	static testmethod void testAsDistributorPortalUser(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        
 		PageReference pageRef = Page.Collaboration;
        Test.setCurrentPage(pageRef);
		User u;
		setup();
        Account a = Test_Helper.testInsertAccount('Test Account', market.Id);
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];      
        System.runAs (thisUser) {
        	u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
		distributorName = a.Name;
		distributorId = a.ID;


		Folder__c folderParent = Test_Helper.testInsertFolder(true, false, market.Id, false, false, CONSTANT.COLLABORATION, null, a.Id);
		Folder__c folderParent1 = Test_Helper.testInsertFolder(true, true, market.Id, false, false, CONSTANT.COLLABORATION, null, a.Id);
		Folder__c folderChild = Test_Helper.testInsertFolder(true, false, market.Id, false, false, CONSTANT.COLLABORATION, folderParent.ID, a.Id);
		Folder__c folderChild1 = Test_Helper.testInsertFolder(false, false, market.Id, false, false, CONSTANT.COLLABORATION, folderParent.ID, a.Id);
		folderId = folderParent.id;
		
		Test.StartTest();

	    System.runAs(u){
        	Service_UploadFile suf = new Service_UploadFile();
        	suf.organizationalHierarchyId = organizationalHierarchyId;
        	suf.organizationalHierarchyName = organizationalHierarchyName;  
        	suf.distributorName = distributorName;  
        	suf.distributorId = distributorId;  
        	suf.folderId = folderId;  
        	suf.afterUploadRedirectTo = 'test';
        	suf.isInternal = false;
        	suf.comment = 'comment';
        	suf.availableUntilText = '01/01/2020';
        	
        	suf.file0 = new ContentVersion();
	        suf.file0.PathOnClient = 'c:\\video0.pdf'; 
        	suf.file0.Description = 'Test Description0';

        	suf.file1 = new ContentVersion();
	        suf.file1.PathOnClient = 'c:\\video1.pdf'; 
        	suf.file1.Description = 'Test Description1';

        	suf.file2 = new ContentVersion();
	        suf.file2.PathOnClient = 'c:\\video2.pdf'; 
        	suf.file2.Description = 'Test Description2';

        	suf.file3 = new ContentVersion();
	        suf.file3.PathOnClient = 'c:\\video3.pdf'; 
        	suf.file3.Description = 'Test Description3';

        	suf.file4 = new ContentVersion();
	        suf.file4.PathOnClient = 'c:\\video4.pdf'; 
        	suf.file4.Description = 'Test Description4';

        	suf.file5 = new ContentVersion();
	        suf.file5.PathOnClient = 'c:\\video5.pdf'; 
        	suf.file5.Description = 'Test Description5';

        	suf.file6 = new ContentVersion();
	        suf.file6.PathOnClient = 'c:\\video6.pdf'; 
        	suf.file7.Description = 'Test Description6';

        	suf.file7 = new ContentVersion();
	        suf.file7.PathOnClient = 'c:\\video7.pdf'; 
        	suf.file7.Description = 'Test Description7';

        	suf.file8 = new ContentVersion();
	        suf.file8.PathOnClient = 'c:\\video8.pdf'; 
        	suf.file8.Description = 'Test Description8';

        	suf.file9 = new ContentVersion();
	        suf.file9.PathOnClient = 'c:\\video9.pdf'; 
        	suf.file9.Description = 'Test Description9';

        	suf.fileIndexes = '0,1,2,3,4,5,6,7,8,9,';
			suf.upload();
	    }			
 		Test.StopTest();   	
	}
	
	static testmethod void testAsDistributorPortalUser1(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        
   		ContentWorkspace CW = [select Id, DefaultRecordTypeId from ContentWorkspace where name = 'Collaboration'];
        
        ContentVersion cvtmp = new ContentVersion();
        //set mandatory fields
        cvtmp.Title = 'test upload';        
        cvtmp.PathOnClient = 'c:\\video.pdf'; 
        cvtmp.VersionData = blob.valueof('1115660548001'); 
        cvtmp.Description = 'Test Description';
        cvtmp.RecordTypeId = CW.DefaultRecordTypeId;
		        
 		PageReference pageRef = Page.Collaboration;
        Test.setCurrentPage(pageRef);
		User u;
		setup();
        Account a = Test_Helper.testInsertAccount('Test Account', market.Id);
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];      
        System.runAs (thisUser) {
        	u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
		distributorName = a.Name;
		distributorId = a.ID;


		Folder__c folderParent = Test_Helper.testInsertFolder(true, false, market.Id, false, false, CONSTANT.COLLABORATION, null, a.Id);
		Folder__c folderParent1 = Test_Helper.testInsertFolder(true, true, market.Id, false, false, CONSTANT.COLLABORATION, null, a.Id);
		Folder__c folderChild = Test_Helper.testInsertFolder(true, false, market.Id, false, false, CONSTANT.COLLABORATION, folderParent.ID, a.Id);
		Folder__c folderChild1 = Test_Helper.testInsertFolder(false, false, market.Id, false, false, CONSTANT.COLLABORATION, folderParent.ID, a.Id);
		folderId = folderParent.id;
		
		Test.StartTest();

	    System.runAs(u){
        	Service_UploadFile suf = new Service_UploadFile();
        	suf.fileIndexes = '0,1,2,3,4,5,6,7,8,9,';
			suf.upload();
	    }			
 		Test.StopTest();   	
	}

	static testmethod void testAsDistributorPortalUser2(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        
   		ContentWorkspace CW = [select Id, DefaultRecordTypeId from ContentWorkspace where name = 'Collaboration'];
        
        ContentVersion cvtmp = new ContentVersion();
        //set mandatory fields
        cvtmp.Title = 'test upload';        
        cvtmp.PathOnClient = 'c:\\video.pdf'; 
        cvtmp.VersionData = blob.valueof('1115660548001'); 
        cvtmp.Description = 'Test Description';
        cvtmp.RecordTypeId = CW.DefaultRecordTypeId;
		        
 		PageReference pageRef = Page.Collaboration;
        Test.setCurrentPage(pageRef);
		User u;
		setup();
        Account a = Test_Helper.testInsertAccount('Test Account', market.Id);
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];      
        System.runAs (thisUser) {
        	u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
		distributorName = a.Name;
		distributorId = a.ID;

		Folder__c folderParent = Test_Helper.testInsertFolder(true, false, market.Id, false, false, CONSTANT.COLLABORATION, null, a.Id);
		Folder__c folderParent1 = Test_Helper.testInsertFolder(true, true, market.Id, false, false, CONSTANT.COLLABORATION, null, a.Id);
		Folder__c folderChild = Test_Helper.testInsertFolder(true, false, market.Id, false, false, CONSTANT.COLLABORATION, folderParent.ID, a.Id);
		Folder__c folderChild1 = Test_Helper.testInsertFolder(false, false, market.Id, false, false, CONSTANT.COLLABORATION, folderParent.ID, a.Id);
		folderId = folderParent.id;
		
		Test.StartTest();

	    System.runAs(u){
        	Service_UploadFile suf = new Service_UploadFile();
        	suf.getDistributorsForOrgUnit();
        	Service_UploadFile.getDistributorsForOrgUnit(organizationalHierarchyId);
        	suf.getFoldersOptions();
        	
        	Service_UploadFile.getFoldersOptions(organizationalHierarchyId, distributorId, false);
			Service_UploadFile.HierarchicalOption ho = new Service_UploadFile.HierarchicalOption('a','b');
			Service_UploadFile.HierarchicalOption ho1 = new Service_UploadFile.HierarchicalOption('a','b');
			ho.addKid(ho1);
	    }			
 		Test.StopTest();   	
	}


}