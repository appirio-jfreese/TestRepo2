public class Test_Helper {

    public static User MDUser;
    /**
    * @author Denise Bacher
    * @date 09/08/2011
    * @description Insert a test Account
    * @return A test Account
    */
    public static Account testInsertAccount(String accountName){
        Organizational_Unit__c ou = new Organizational_Unit__c(Label__c = 'Division', Type__c = 'Spirits');
        insert ou;
        Account testAccount = new Account(name=accountName, Spirits_Hierarchy__c = ou.id);
        testAccount.BillingState = 'CT';
        insert testAccount;
        
        return testAccount;
    }
 
    /**
    * @author Bartosz Dudziak / modified by Maciej Krol
    * @date 15/11/2011 / 07/10/2012
    * @description Insert a test Account
    * @return A test Account
    */
    public static Account testInsertAccount(String accountName, Id OUId) {
        Account testAccount = new Account(name=accountName, Spirits_Hierarchy__c = OUId);
        testAccount.BillingState = 'CT';
        insert testAccount;
        
        return testAccount;
    }
    /**
    * @author Denise Bacher
    * @date 04/08/2011
    * @description Insert a test Contact
    * @return A test Contact
    */
    public static Contact testInsertContact(String firstName, String lastName, ID accountID){
        Contact testContact = new Contact(firstname=firstName, lastname=lastName, accountID = accountID);
        insert testContact;
        
        return testContact;
    }
    
    /**
    * @author Denise Bacher
    * @date 09/08/2011
    * @description Insert a test Brand
    * @return A test Brand
    */
    public static Brand__c testInsertBrand(String brandName){
        Brand__c testBrand = new Brand__c();
        testBrand.Name = brandName;
        testBrand.diageo_direct_visible__c = true;
        testBrand.Classification__c = 'Spirits';
        insert testBrand;
        
        return testBrand;
    }
    
    
    public static Brand__c testCreateBrand(String brandName, Id parentBrandId, String categoryName){
        Brand__c testBrand = new Brand__c();
        testBrand.Name = brandName;
        testBrand.Parent_Brand__c = parentBrandId;
        testBrand.Category__c = categoryName;
        testBrand.diageo_direct_visible__c = true;
        testBrand.Classification__c = 'Spirits';
        
        return testBrand;
    }
    
    /**
    * @author Denise Bacher
    * @date 09/08/2011
    * @description Insert a test child Brand (aka brand varient)
    * @return A test child Brand
    */
    public static Brand__c testInsertChildBrand(String brandName, ID brandID){
        Brand__c testBrand = new Brand__c();
        testBrand.Name = brandName;
        testBrand.Parent_Brand__c = brandID;
        testBrand.diageo_direct_visible__c = true;
        testBrand.Classification__c = 'Spirits';
        insert testBrand;
        
        return testBrand;
    }
    
    /**
    * @author Denise Bacher
    * @date 09/08/2011
    * @description Insert a test AccountBrand (links a brand to an account)
    * @return A test AccountBrand
    */
    public static AccountBrand__c testInsertAccountBrand(ID accountID, ID brandID){
        AccountBrand__c testActBrand = new AccountBrand__c();
        testActBrand.Name = 'Test AccountBrand';
        testActBrand.Account__c = accountID;
        testActBrand.Brand__c = brandID;
        insert testActBrand;
        
        return testActBrand;
    }
    
     public static void testInsertAccountBrand(ID accountID, List<Brand__c> brands){
        
        List<AccountBrand__c> ab = new AccountBrand__c[]{};
        for(Brand__c brand : brands){
            AccountBrand__c testActBrand = new AccountBrand__c();
            testActBrand.Name = 'Test AccountBrand';
            testActBrand.Account__c = accountID;
            testActBrand.Brand__c = brand.ID;
            
            ab.add(testActBrand);
        }
        insert ab;
    }
    
    
    
	/**
	*	@used to get a basic test user.
	*	@Author		: Jeremy Mooer
	*	@Date		: 24 Jun 2012
	*/
	public static User generateTestUser(String randomFiveDigitString, Boolean insertUser, String profileName)
	{
		User userToReturn = new User();
		userToReturn.Alias = randomFiveDigitString;
		userToReturn.Email = randomFiveDigitString + '@testorg.com';
		userToReturn.EmailEncodingKey = 'UTF-8';
		userToReturn.LastName = 'Test' + randomFiveDigitString;
		userToReturn.LanguageLocaleKey = 'en_US';
		userToReturn.LocaleSidKey = 'en_US';
		userToReturn.ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
		userToReturn.TimeZoneSidKey = 'America/Chicago';
		userToReturn.Username = randomFiveDigitString + '@test' + Math.round(Math.random() * 10000) + '.com';
		userToReturn.UserRoleId = null;
		userToReturn.Country = 'United States';
		userToReturn.Use_current_theme_as_default__c = 'Spirits';
		userToReturn.Diageo_Direct_Theme__c = 'Spirits'; 
		if(insertUser)
			insert userToReturn;
		
		return userToReturn;
	}
    
    
    /**
    * @author Denise Bacher
    * @date 09/08/2011
    * @description Insert a test distributor portal User
    * @return A test User
    */
    public static User testInsertDistributorPortalUser(ID contactID){
        double uniqueNum = Math.round(Math.random() * 10000);
        string uniqueKey = 'user' + uniqueNum;
        
        User testUser = new User();
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Distributor Portal User'].Id;
        testUser.Alias = 'u'+uniqueNum;
        testUser.FirstName = 'Test' + uniqueKey;
        testUser.LastName = 'Test' + uniqueKey;
        testUser.Username = uniqueKey + '@test' + uniqueNum + '.com';
        testUser.Email = uniqueKey + '@testorg.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.LocaleSidKey = 'en_US';
        testUser.Country = 'United States';
        testUser.IsActive = true;
        testUser.ContactId = contactID;
        testUser.UserPermissionsSFContentUser = true;
		testUser.Use_current_theme_as_default__c = 'Spirits';
		testUser.Diageo_Direct_Theme__c = 'Spirits'; 
        insert testUser;
        
        // Retrieve the roles for the user's account and assign one to the user
        
        Set<ID> aIDs = new Set<ID>();
        for(contact c: [select AccountID from Contact where id = :contactID]){
            aIDs.add(c.AccountID);
        }
        List<UserRole> roles = [select name, id, PortalRole from UserRole where PortalAccountId in :aIDs and name like '%Customer User%'];

		list<Account_Member__c> members = new list<Account_Member__c>();
		for(id amcid : aIDs){
        	Account_Member__c am = new Account_Member__c();
        	am.Account__c = amcid;
        	am.User__c = testUser.id;
        	am.Default__c = true;
        	members.add(am);
		}
		 
		if(members.size() != 0){
			insert members;
		}
		
        //Update the test user with the portal user role
        testUser.UserRoleId = roles[0].Id;
		testUser.loginDate__c = datetime.now();  
        update testUser;      
        
        return testUser;
    }

    /**
    * @author Denise Bacher
    * @date 09/08/2011
    * @description Insert a test distributor portal User
    * @return A test User
    */
    
    public static User testInsertDiageoPortalUser(ID contactID){
        double uniqueNum = Math.round(Math.random() * 10000);
        string uniqueKey = 'user' + uniqueNum;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        User testUser = new User();
        
        System.runAs ( thisUser ) {
	        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Diageo Portal User'].Id;
	        testUser.Alias = 'u'+uniqueNum;
	        testUser.FirstName = 'Test' + uniqueKey;
	        testUser.LastName = 'Test' + uniqueKey;
	        testUser.Username = uniqueKey + '@test' + uniqueNum + '.com';
	        testUser.Email = uniqueKey + '@testorg.com';
	        testUser.EmailEncodingKey = 'UTF-8';
	        testUser.LanguageLocaleKey = 'en_US';
	        testUser.TimeZoneSidKey = 'America/Chicago';
	        testUser.LocaleSidKey = 'en_US';
	        testUser.Country = 'United States';
	        testUser.IsActive = true;
	        testUser.ContactId = contactID;
	        testUser.UserPermissionsSFContentUser = true;
			testUser.Use_current_theme_as_default__c = 'Spirits';
			testUser.Diageo_Direct_Theme__c = 'Spirits'; 
	        insert testUser;
	        
	        // Retrieve the roles for the user's account and assign one to the user
	        Set<ID> aIDs = new Set<ID>();
	        for(contact c: [select AccountID from Contact where id = :contactID]){
	            aIDs.add(c.AccountID);
	        }
	        List<UserRole> roles = [select name, id, PortalRole from UserRole where PortalAccountId in :aIDs and name like '%Customer User%'];
	
			list<Account_Member__c> members = new list<Account_Member__c>();
			for(id amcid : aIDs){
	        	Account_Member__c am = new Account_Member__c();
	        	am.Account__c = amcid;
	        	am.User__c = testUser.id;
	        	am.Default__c = true;
	        	members.add(am);
			}
			 
			if(members.size() != 0){
				insert members;
			}
	        
	        // Update the test user with the portal user role
	        testUser.UserRoleId = roles[0].Id;
			testUser.loginDate__c = datetime.now();        
	        update testUser;
        }
        
        return testUser;
    }

    /**
    * @author Jonathan Freese
    * @date 06/13/2013
    * @description Insert a test Diageo Employee
    * @return A test User
    */
    
    public static User testInsertDiageoEmployee(){
        double uniqueNum = Math.round(Math.random() * 10000);
        string uniqueKey = 'user' + uniqueNum;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        User testUser = new User();
        
        System.runAs ( thisUser ) {
            testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Diageo Employee'].Id;
            testUser.Alias = 'u'+uniqueNum;
            testUser.FirstName = 'Test' + uniqueKey;
            testUser.LastName = 'Test' + uniqueKey;
            testUser.Username = uniqueKey + '@test' + uniqueNum + '.com';
            testUser.Email = uniqueKey + '@testorg.com';
            testUser.EmailEncodingKey = 'UTF-8';
            testUser.LanguageLocaleKey = 'en_US';
            testUser.TimeZoneSidKey = 'America/Chicago';
            testUser.LocaleSidKey = 'en_US';
            testUser.Country = 'United States';
            testUser.IsActive = true;
            //testUser.ContactId = contactID; - Not Applicable (Diageo Employee profile has no association tothe Contact object)
            testUser.UserPermissionsSFContentUser = true;
            testUser.Use_current_theme_as_default__c = 'Spirits';
            testUser.Diageo_Direct_Theme__c = 'Spirits'; 
            insert testUser;
            
            // Retrieve the roles for the user's account and assign one to the user
            Set<ID> aIDs = new Set<ID>();
            //for(contact c: [select AccountID from Contact where id = :contactID]){
            //    aIDs.add(c.AccountID);
            //}
            //List<UserRole> roles = [select name, id, PortalRole from UserRole where PortalAccountId in :aIDs and name like '%Customer User%'];
    
            list<Account_Member__c> members = new list<Account_Member__c>();
            for(id amcid : aIDs){
                Account_Member__c am = new Account_Member__c();
                am.Account__c = amcid;
                am.User__c = testUser.id;
                am.Default__c = true;
                members.add(am);
            }
             
            if(members.size() != 0){
                insert members;
            }
            
            // Update the test user with the portal user role
            //testUser.UserRoleId = roles[0].Id;
            testUser.loginDate__c = datetime.now();        
            update testUser;
        }
        
        return testUser;
    }

    public static Account testGetDiageoAccount(){
        return [select id, name from Account where name = 'Diageo' limit 1];
        
    }

    /**
    * @author Denise Bacher
    * @date 09/08/2011
    * @description Insert a test ContentVersion, it is added to the distributor library
    * @return A test ContentVersion
    */
    public static ContentVersion testInsertDistributorContent(String title, String fileURL, ID calendarID){        
        ContentWorkspace CW = [select id, defaultrecordTypeId from ContentWorkspace where name = 'Distributor Portal']; 
        ID contentWorkID = CW.Id;
        ContentVersion testContent = new ContentVersion();
        testContent.Title = title;
        testContent.ContentUrl = fileURL;
        testContent.Description = 'Test';
        testContent.RecordTypeId = CW.DefaultRecordTypeId;
        insert testContent;
        
        ID contentDocID = [select ContentDocumentId from ContentVersion where id = :testContent.id].ContentDocumentId;
        
       // System.debug('contentWorkID ' + contentWorkID);
       // System.debug('contentDocID ' + contentDocID);

       // System.debug('Record Types ' + [select id, name, SobjectType from RecordType]);
        
        ContentWorkspaceDoc contentWorkDoc = new ContentWorkspaceDoc();
        contentWorkDoc.ContentDocumentId = contentDocID;
        contentWorkDoc.ContentWorkspaceId = contentWorkID;
        insert contentWorkDoc;
        
        testContent.Content_Description__c = [select Content_Description__c from ContentVersion where ID = :testContent.ID][0].Content_Description__c;
        
        return testContent;
    }
    /**
    * @author Denise Bacher
    */    
    public static ContentBrand__c testInsertContentBrand(ID contentProxyID, ID brandID){
        ContentBrand__c testCB = new ContentBrand__c(name='test', Content_Description__c = contentProxyID, Brand__c = brandID);
        insert testCB;
        return testCB;
    }
    
    public static ContentBrand__c testCreateContentBrand(ID contentProxyID, ID brandID){
        ContentBrand__c testCB = new ContentBrand__c(name='test', Content_Description__c = contentProxyID, Brand__c = brandID);
        return testCB;
    }
    
    /**
    * @author Denise Bacher
    * @date 18/08/2011
    * @description Insert a test Calendar
    * @return A test Calendar
    */
    public static Calendar__c testInsertCalendar(String name, String salesChannel, String segment, 
        String priority, String description, Date startDate, Date endDate, Boolean archive, Boolean isMonthlyExecutionPlan){
            
        String recordName = isMonthlyExecutionPlan ? Constant.MONTHLY_EXECUTION_PLAN : Constant.INNOVATION_AND_SUSTAINOVATION;
        Id recordId = [select Id from RecordType where Name =: recordName and sObjectType = 'Calendar__c'].Id;
        Calendar__c testCalendar = new Calendar__c();
        testCalendar.Name = name;
        testCalendar.Sales_Channel__c = salesChannel;
        testCalendar.Segment__c = segment;
        testCalendar.Priority__c = priority;
        testCalendar.Description__c = description;
        testCalendar.Start_Date__c = startDate;
        testCalendar.End_Date__c = endDate;
        testCalendar.Archive__c = archive;
        testCalendar.recordTypeId = recordId;
        testCalendar.classification__c = 'Spirits';
        insert testCalendar;
        
        return testCalendar;
    }
    
    public static Calendar__c testInsertMCalendar(String name, String description, Date startDate, Date endDate){
            
        String recordName = Constant.MULTICULTURAL;
        Id recordId = [select Id from RecordType where Name =: recordName and sObjectType = 'Calendar__c'].Id;
        Calendar__c testCalendar = new Calendar__c();
        testCalendar.Name = name;
        testCalendar.Description__c = description;
        testCalendar.Start_Date__c = startDate;
        testCalendar.End_Date__c = endDate;
        testCalendar.recordTypeId = recordId;
        testCalendar.classification__c = 'Spirits';
        
        insert testCalendar;
        
        return testCalendar;
    }

    public static Calendar__c testInsertPCalendar(String name, String description, Date startDate, Date endDate){
            
        String recordName = Constant.PLANNING;
        Id recordId = [select Id from RecordType where Name =: recordName and sObjectType = 'Calendar__c'].Id;
        Calendar__c testCalendar = new Calendar__c();
        testCalendar.Name = name;
        testCalendar.Description__c = description;
        testCalendar.Start_Date__c = startDate;
        testCalendar.End_Date__c = endDate;
        testCalendar.recordTypeId = recordId;
        testCalendar.classification__c = 'Spirits';
        
        insert testCalendar;
        
        return testCalendar;
    }
    
    public static Calendar__c testCreateCalendar(String name, String salesChannel, String segment, 
        String priority, String description, Date startDate, Date endDate, Boolean archive, Boolean isMonthlyExecutionPlan){
            
        String recordName = isMonthlyExecutionPlan ? Constant.MONTHLY_EXECUTION_PLAN : Constant.INNOVATION_AND_SUSTAINOVATION;
        Id recordId = [select Id from RecordType where Name =: recordName and sObjectType = 'Calendar__c'].Id;
        Calendar__c testCalendar = new Calendar__c();
        testCalendar.Name = name;
        testCalendar.Sales_Channel__c = salesChannel;
        testCalendar.Segment__c = segment;
        testCalendar.Priority__c = priority;
        testCalendar.Description__c = description;
        testCalendar.Start_Date__c = startDate;
        testCalendar.End_Date__c = endDate;
        testCalendar.Archive__c = archive;
        testCalendar.recordTypeId = recordId;
        testCalendar.classification__c = 'Spirits';
        
        return testCalendar;
    }
    
   /**
    * @author Denise Bacher
    * @date 18/08/2011
    * @description Insert a test Calendar Brand
    * @return A test Calendar Brand
    */
       
    public static CalendarBrand__c testInsertCalendarBrand(ID calendarID, ID brandID){
        CalendarBrand__c testCB = new CalendarBrand__c(name='test', Calendar__c = calendarID, Brand__c = brandID);
        insert testCB;
        
        return testCB;
    }

   /**
    * @author Bartosz Dudziak
    * @date 14/11/2011
    * @description Insert a folder
    * @return A test Folder
    */
	public static User generateTestMDUser(String randomFiveDigitString, Boolean insertUser, String profileName){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        User userToReturn = new User();
        System.runAs ( thisUser ) {
			userToReturn.Alias = randomFiveDigitString;
			userToReturn.Email = randomFiveDigitString + '@testorg.com';
			userToReturn.EmailEncodingKey = 'UTF-8';
			userToReturn.LastName = 'Test' + randomFiveDigitString;
			userToReturn.LanguageLocaleKey = 'en_US';
			userToReturn.LocaleSidKey = 'en_US';
			userToReturn.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
			userToReturn.TimeZoneSidKey = 'America/Chicago';
			userToReturn.Username = randomFiveDigitString + '@test' + Math.round(Math.random() * 10000) + '.com';
			userToReturn.UserRoleId = [select Id from UserRole where name ='Marketing Directors' limit 1].Id;
			userToReturn.Country = 'United States';
			
			/*User userToReturn = new User();
			userToReturn.Alias = '12345';
			userToReturn.Email = '12345' + '@testorg.com';
			userToReturn.EmailEncodingKey = 'UTF-8';
			userToReturn.LastName = 'Test' + '12345';
			userToReturn.LanguageLocaleKey = 'en_US';
			userToReturn.LocaleSidKey = 'en_US';
			userToReturn.ProfileId = [SELECT Id FROM Profile limit 1].Id;
			userToReturn.TimeZoneSidKey = 'America/Chicago';
			userToReturn.Username = '12345' + '@test' + Math.round(Math.random() * 10000) + '.com';
			userToReturn.UserRoleId = '00EA0000000rueYMAQ';
			userToReturn.Country = 'United States';*/
			
//			if(insertUser)
				insert userToReturn;
            MDUser = userToReturn;
        }		
		return userToReturn;
	}
    public static Folder__c testInsertFolder(Boolean allowComment, Boolean allowUpload, Id OUId, Boolean brandFilter, Boolean timeFilter, String section, String parentFolder, Id DId){
		Folder__c testfolder;
		System.RunAs(MDUser){
		testFolder = new Folder__c(   
                                                name='test folder',
                                                Allow_Add_Comment__c = allowComment,
                                                Allow_File_Upload__c = allowUpload,
                                                OrgUnits__c = OUId,
                                                Filter_By_Brand__c = brandFilter,
                                                Filter_By_Time__c = timeFilter,
                                                Page_Section__c = section,
                                                Parent_Folder__c = parentFolder,
                                                Classification__c = 'Spirits',
                                                Distributors__c = DId
                                            );
        insert testFolder;
      }  
        return testFolder;
    }
    
    public static Folder__c testInsertFolder(String name, Boolean allowComment, Boolean allowUpload, Id OUId, Boolean brandFilter, Boolean timeFilter, String section, String parentFolder, Id DId){
		Folder__c testfolder;
		System.RunAs(MDUser){
		testFolder = new Folder__c(   
                                                name=name,
                                                Allow_Add_Comment__c = allowComment,
                                                Allow_File_Upload__c = allowUpload,
                                                OrgUnits__c = OUId,
                                                Filter_By_Brand__c = brandFilter,
                                                Filter_By_Time__c = timeFilter,
                                                Page_Section__c = section,
                                                Parent_Folder__c = parentFolder,
                                                Classification__c = 'Spirits',
                                                Distributors__c = DId
                                            );
        insert testFolder;
        }
        return testFolder;
    }

   /**
    * @author Bartosz Dudziak
    * @date 14/11/2011
    * @description Insert a File
    * @return A test File
    */
    public static File__c testInsertFile(){
      /*  File__c testFile = new File__c();
        testFile.Content_ID__c = '986598654578569854';
        testFile.Content_Version_Id__c = '235469878965412356';
        insert testFile;
        
        return testFile;
   		*/
   		ContentWorkspace CW = [select Id, DefaultRecordTypeId from ContentWorkspace where name = 'Planning'];
        
        ContentVersion c = new ContentVersion();
        //set mandatory fields
        
        c.Title = 'test upload';        // some title
        c.PathOnClient = 'c:\\video.pdf'; //dummy filepath, file doesn't exist on my computer. filetype is set based on a value of this field
        c.VersionData = blob.valueof('1115660548001'); //We store video Id from the BrightCove webstire
        c.Description = 'Test Description';
        c.RecordTypeId = CW.DefaultRecordTypeId;

        insert c;
        c = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: c.Id];
        
        
        
        ContentWorkspaceDoc cwd = new ContentWorkspaceDoc(
            ContentDocumentId = [select ContentDocumentId from ContentVersion where id = :c.id].ContentDocumentId,
            ContentWorkspaceId = CW.Id
        );
            
        insert cwd;
        
        Id testFileId = [SELECT Id, ContentDocumentId, File__c FROM ContentVersion WHERE Id =: c.Id Limit 1].File__c;
        File__c testFile = [SELECT Content_ID__c, Content_Version_Id__c, Folders__c, Page_Section__c, Distributors__c, Division_Access__c, OrgUnits__c From File__c Where Id =:testFileId Limit 1 ];

		testFile.Classification__c = 'Spirits';
		update testFile;
	
        return testFile;
    }

   /**
    * @author Bartosz Dudziak
    * @date 14/11/2011
    * @description Insert a File
    * @return A test File
    */
    public static File__c testInsertFile(String parentFolder, String section, String division, Id OUId, String distributorId){
        ContentWorkspace CW = [select Id, DefaultRecordTypeId from ContentWorkspace where name = :section];
        
        ContentVersion c = new ContentVersion();
        //set mandatory fields
        
        c.Title = 'test upload';        // some title
        c.PathOnClient = 'c:\\video.pdf'; //dummy filepath, file doesn't exist on my computer. filetype is set based on a value of this field
        c.VersionData = blob.valueof('1115660548001'); //We store video Id from the BrightCove webstire
        c.Description = 'Test Description';
        c.RecordTypeId = CW.DefaultRecordTypeId;

        insert c;
        c = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: c.Id];
        
        
        
        ContentWorkspaceDoc cwd = new ContentWorkspaceDoc(
            ContentDocumentId = [select ContentDocumentId from ContentVersion where id = :c.id].ContentDocumentId,
            ContentWorkspaceId = CW.Id
        );
            
        insert cwd;
        
        Id testFileId = [SELECT Id, ContentDocumentId, File__c FROM ContentVersion WHERE Id =: c.Id Limit 1].File__c;
        File__c testFile = [SELECT Content_ID__c, Content_Version_Id__c, Folders__c, Page_Section__c, Distributors__c, Division_Access__c, OrgUnits__c From File__c Where Id =:testFileId Limit 1 ];
        
        testFile.Content_ID__c = c.ContentDocumentId;
        testFile.Content_Version_Id__c = c.Id;
        testFile.Folders__c = parentFolder;
        testFile.Page_Section__c = section;
        testFile.Distributors__c = distributorId;
        testFile.Division_Access__c = division;
        testFile.OrgUnits__c = OUId;
		testFile.Classification__c = 'Spirits';
		update testFile;
        
        return testFile;
    }

   /**
    * @author Bartosz Dudziak
    * @date 14/11/2011
    * @description Insert a File
    * @return A test File
    */
    public static File__c testInsertFile(String parentFolder, String section, Calendar__c cal, Organizational_Unit__c OU){
        File__c testFile = new File__c();
        testFile.Content_ID__c = '986598654578569854';
        testFile.Content_Version_Id__c = '235469878965412356';
        testFile.Folders__c = parentFolder;
        testFile.Page_Section__c = section;
        testFile.Division_Access__c = OU.Name;
        testFile.OrgUnits__c = OU.Id;
        testFile.Calendar__c = cal.Id;
        testFile.Classification__c = 'Spirits';
        insert testFile;
        
        return testFile;
    }

   /**
    * @author Bartosz Dudziak
    * @date 14/11/2011
    * @description Insert a File
    * @return A test File
    */
    public static Content_Description__c testInsertContentDescription(){

        ContentWorkspace CW = [select Id, DefaultRecordTypeId from ContentWorkspace where name = 'Distributor Portal'];
        
        ContentVersion c = new ContentVersion();
        //set mandatory fields
        
        c.Title = 'test upload';        // some title
        c.PathOnClient = 'c:\\video.pdf'; //dummy filepath, file doesn't exist on my computer. filetype is set based on a value of this field
        c.VersionData = blob.valueof('1115660548001'); //We store video Id from the BrightCove webstire
        c.Description = 'Test Description';
        c.RecordTypeId = CW.DefaultRecordTypeId;

        insert c;
        
        
        
        ContentWorkspaceDoc cwd = new ContentWorkspaceDoc(
            ContentDocumentId = [select ContentDocumentId from ContentVersion where id = :c.id].ContentDocumentId,
            ContentWorkspaceId = CW.Id
        );
            
        insert cwd;
            
        Content_Description__c descr = [ select Content_ID__c, Content_Version_Id__c, Description__c, filetype__c, Innovation__c, Is_Video__c, Title__c, Video_Id__c, Preview_Id__c, Preview_Available__c, share_link__c
                                                                from Content_Description__c
                                                                where Content_Version_Id__c = :c.id
                                                                limit 1 ];
        descr.share_link__c = 'http://test.com';
        descr.Preview_Available__c = false;
        descr.Preview_Id__c = null;
        descr.Classification__c = 'Spirits';
        
        update descr;
        return descr;
    }
    
    public static Content_Description__c testInsertContentDescriptionExtended(String title){
        ContentWorkspace CW = [select Id, DefaultRecordTypeId from ContentWorkspace where name = 'Distributor Portal'];

        ContentVersion c = new ContentVersion();
        //set mandatory fields
        c.Title = title;        // some title
        c.PathOnClient = 'c:\\video.pdf'; //dummy filepath, file doesn't exist on my computer. filetype is set based on a value of this field
        c.VersionData = blob.valueof('1115660548001'); //We store video Id from the BrightCove webstire
        c.Description = 'Test Description';
        c.RecordTypeId = CW.DefaultRecordTypeId;
        insert c;
        
        
        
        ContentWorkspaceDoc cwd = new ContentWorkspaceDoc(
            ContentDocumentId = [select ContentDocumentId from ContentVersion where id = :c.id].ContentDocumentId,
            ContentWorkspaceId = CW.id
        );
            
        insert cwd;
            
        Content_Description__c descr = [ select Content_ID__c, Content_Version_Id__c, Description__c, filetype__c, Innovation__c, Is_Video__c, Title__c, Video_Id__c, Preview_Id__c, Preview_Available__c, share_link__c
                                                                from Content_Description__c
                                                                where Content_Version_Id__c = :c.id
                                                                limit 1 ];
        descr.share_link__c = 'http://test.com';
        descr.Preview_Available__c = false;
        descr.Preview_Id__c = null;
        descr.Classification__c = 'Spirits';
        
        update descr;
        return descr;
    }
    
    public static Case testInsertCase(String status){
        Case newCase = new Case();
        newCase.Description = 'Case test description';
        newCase.ContactId = Service_API.getCID();
        newCase.AccountId = Service_API.getAID();
        newCase.Status = status;
        newCase.Subject = 'Case test title';
		newCase.Phone__c = '000000';
		newCase.Email__c = 'text@test.com';
		newCase.First_Name__c = 'first name';
		newCase.Last_Name__c = 'last name';
		newCase.Type = 'Other';
		newCase.Origin = 'Web';        
        
        insert newCase;
        return newCase;
    }
    
     public static Content_Property__c testInsertContentProperty(String name, Id calendarId, Id contentDescriptionId, String category, String subCategory, String subSubCategory, String subSubSubCategory){
        Content_Property__c testContentProperty = new Content_Property__c(  
                                                name = name,
                                                Calendar__c = calendarId,
                                                Category__c = category,
                                                Content_Description__c = contentDescriptionId,
                                                Sub_Category__c = subCategory,
                                                Sub_Sub_Category__c = subSubCategory,
                                                Sub_Sub_Sub_Category__c = subSubSubCategory,
                                                end_date__c = date.today(),
                                                start_date__c = date.today().addDays(-1)
                                            );
        insert testContentProperty;
        
        return testContentProperty;
    }
    
    public static Content_Property__c testCreateContentProperty(String name, Id calendarId, Id contentDescriptionId, String category, String subCategory, String subSubCategory, String subSubSubCategory){
        Content_Property__c testContentProperty = new Content_Property__c(  
                                                name = name,
                                                Calendar__c = calendarId,
                                                Category__c = category,
                                                Content_Description__c = contentDescriptionId,
                                                Sub_Category__c = subCategory,
                                                Sub_Sub_Category__c = subSubCategory,
                                                Sub_Sub_Sub_Category__c = subSubSubCategory
                                            );
        
        return testContentProperty;
    }
    
     public static Content_Property__c testCreateContentProperty(String name, Id calendarId, Id contentDescriptionId, String category, String subCategory, String subSubCategory, String subSubSubCategory, date StartDate, date EndDate){
        Content_Property__c testContentProperty = new Content_Property__c(  
                                                name = name,
                                                Calendar__c = calendarId,
                                                Category__c = category,
                                                Content_Description__c = contentDescriptionId,
                                                Sub_Category__c = subCategory,
                                                Sub_Sub_Category__c = subSubCategory,
                                                Sub_Sub_Sub_Category__c = subSubSubCategory,
                                                Start_Date__c = StartDate,
                                                End_date__c = EndDate
                                            );
        
        return testContentProperty;
    }
    
     public static FAQ__c testInsertFAQ(String question, String answer){
        FAQ__c f = new FAQ__c(
            Question__c = question,
            Answer__c = answer
        );
        
        insert f;
        return f;
    } 
    
    public static Hyperlink__c testInsertLink(String url, String name, String category){
        Hyperlink__c h = new Hyperlink__c(
            URL__c = url,
            Name = name,
            Category__c = category
        );
        
        insert h;
        return h;
    } 
    
     public static NewsAndArticles__c testInsertNewsAndArticles(String title, String body){
        NewsAndArticles__c nea = new NewsAndArticles__c(
            Title__c = title,
            BodyText__c = body,
			Classification__c = 'Spirits'
        );
        
        insert nea;
        return nea;
    } 
    
     public static HomeVideo__c testInsertHomeVideo(String videoId, String name, String description, Boolean isCurrent){
        
        HomeVideo__c v = new HomeVideo__c(
            videoId__c = videoId,
            name = name,
            description__c  = description,
            current__c = isCurrent,
            Classification__c = 'Spirits'
        );
        
        insert v;
        return v;
    } 
}