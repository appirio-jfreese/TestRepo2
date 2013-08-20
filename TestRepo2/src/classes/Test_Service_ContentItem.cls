@isTest(seeAllData=true)
private class Test_Service_ContentItem {
	
    private static AggregateResultHolder resultHolder;    
    private static Organizational_Unit__c division;
    private static Organizational_Unit__c region;
    private static Organizational_Unit__c district;
    private static Organizational_Unit__c market;
   	private static File__c fileContent;
   	private static ContentWorkspace CW;
    static testmethod void testServiceUpload(){
        
        Service_ContentItem sci = new Service_ContentItem();
        AggregateResultHolder ag = new AggregateResultHolder();
        sci.aggregated = ag;
        Boolean isIpad = sci.isIpadComponent;
        Boolean editable = sci.editable;     
        Datetime createdDate1 = sci.createdDate1;     
        Datetime lastLoginDateItem1 = sci.lastLoginDateItem1;     
        String cvid1 = sci.cvid1;     
        String cvidlow1 = sci.cvidlow1;     
        String imageRes1 = sci.imageRes1;     
        String fileType1 = sci.fileType1;     
        String fileSize1 = sci.fileSize1;     
        Boolean displayUploadDate1 = sci.displayUploadDate1;     
        Boolean showDownloadShare1 = sci.showDownloadShare1;     
        Boolean showListButtons1 = sci.showListButtons1;     
        Boolean isVideo1 = sci.isVideo1;     
        String videoId1 = sci.videoId1;     
        Boolean previewAvailable1 = sci.previewAvailable1;     
        String previewId1 = sci.previewId1;
        String width1 = sci.width1;
        String height1 = sci.height1;
        String margin1 = sci.margin1;
        Boolean renderAsList1 = sci.renderAsList1;
        String description2 = sci.description2;
        set<id> basketIds = sci.basketIds;     
        set<id> followIds = sci.followIds;     
        Boolean inBasket = sci.inBasket;
        Boolean inFollow = sci.inFollow;
        Date getcreatedDate2 = sci.getcreatedDate2();
        Boolean getisNew = sci.getisNew();
        String id = sci.cid;
        sci.setlastLoginDateItem(getcreatedDate2);
    }
    
    // Test method tests controller functionality with content
    static testmethod void testServiceContentWithAggregatedContent(){
        
        Service_ContentItem sci = new Service_ContentItem();
        AggregateResultHolder ag = new AggregateResultHolder();
        
        // Creates test data
        createTestData();
        //sci.editableIdsString = ''+
        sci.setaggregated(resultHolder);       
        system.assert(sci.canEdit() == true);
        system.assert(sci.cvid1 != null);
        system.assert(sci.title1 != null);
        system.assert(sci.cutoffDescription2  != null);
        system.assert(sci.previewId1  == null);
        system.assert(sci.videoId1  == null);
        system.assert(sci.fileTypePath != null);
        Boolean inBasket = sci.inBasket;
        Boolean inFollow = sci.inFollow;
        Date getcreatedDate2 = sci.getcreatedDate2();
        Boolean getisNew = sci.getisNew();
        String id = sci.cid;
        sci.setlastLoginDateItem(getcreatedDate2);
    }
    // Test method tests controller functionality with content
    static testmethod void testServiceContentForFileType(){
    	Service_ContentItem sci = new Service_ContentItem();
        // Creates test data
        createTestData();
        updateFilepath('c:\\video.AI');
        sci.setaggregated(fetchFileContent(fileContent.Id));       
        system.assertEquals(sci.fileTypePath , '/i/filetype/ai_120.png');
        updateFilepath('c:\\video.M4V');
        sci.setaggregated(fetchFileContent(fileContent.Id));       
        system.assertEquals(sci.fileTypePath , '/i/filetype/m4v_120.png');
        updateFilepath('c:\\video.MP3');
        sci.setaggregated(fetchFileContent(fileContent.Id));       
        system.assertEquals(sci.fileTypePath , '/i/filetype/mp3_120.png');
        updateFilepath('c:\\video.PNG');
        sci.setaggregated(fetchFileContent(fileContent.Id));       
        system.assertEquals(sci.fileTypePath , '/i/filetype/png_120.png');
        
        updateFilepath('c:\\video.TXT');
        sci.setaggregated(fetchFileContent(fileContent.Id));       
        system.assertEquals(sci.fileTypePath , '/i/filetype/txt_120.png');
        updateFilepath('c:\\video.PSD');
        sci.setaggregated(fetchFileContent(fileContent.Id));       
        system.assertEquals(sci.fileTypePath , '/i/filetype/psd_120.png');
        updateFilepath('c:\\video.WMV');
        sci.setaggregated(fetchFileContent(fileContent.Id));       
        system.assertEquals(sci.fileTypePath , '/i/filetype/wmv_120.png');
        updateFilepath('c:\\video.TEXT');
        sci.setaggregated(fetchFileContent(fileContent.Id));       
        system.assertEquals(sci.fileTypePath , '/i/filetype/general_120_2.png');
        updateFilepath('c:\\video.ZIP');
        sci.setaggregated(fetchFileContent(fileContent.Id));       
        system.assertEquals(sci.fileTypePath , '/i/filetype/zip_120.png');
        
    }
    
      
    // Method Creates test data
    private static void createTestData(){
        Test_Helper.generateTestMDUser('12345', false, [SELECT Name FROM Profile Limit 1].Name);
        setup();         
        Account a = Test_Helper.testGetDiageoAccount();
		
        Folder__c folderParent = Test_Helper.testInsertFolder(false, true, market.Id, false, false, CONSTANT.COLLABORATION, null, a.Id);
        Folder__c folderChild = Test_Helper.testInsertFolder(true, false, market.Id, false, false, CONSTANT.COLLABORATION, folderParent.ID, a.Id);
        fileContent = Test_Helper.testInsertFile(folderChild.ID, Constant.COLLABORATION, division.Name, market.Id, a.ID);
         
        resultHolder = fetchFileContent(fileContent.Id);
        
    }
    
    private static AggregateResultHolder fetchFileContent(Id fileId){
    	String query = 'select OwnerID, Description__c folderName, id, Content_Version_Id__c cvid, Description__c description, '
        			  + 'filesize__c filesize, filetype__c filetype, Title__c  title, is_video__c is_video, video_id__c video_id, '
        			  + 'Preview_Available__c previewAvailable, Preview_Id__c previewId, max(Uploaded_date__c) createdDate, '
        			  + 'Image_Resolution__c imageRes '
                      + 'from File__c where id = \'' + fileId + '\' '             
        			  + 'GROUP BY id, Content_Version_Id__c, Description__c, filesize__c, filetype__c, '
        			  + 'Title__c, is_video__c, video_id__c, Preview_Available__c, Preview_Id__c, Image_Resolution__c, '
        			  + 'OwnerID ORDER BY Description__c';
        List<AggregateResult> content = database.query(query);
        AggregateResultHolder aggResultHolder = new AggregateResultHolder();
        system.assert(content.size() > 0);
        aggResultHolder.result = content[0];
        return aggResultHolder;
    }
    private static void updateFilepath(String fieldPath){
    	if(CW==null){
    		CW = [select Id, DefaultRecordTypeId from ContentWorkspace where name = :Constant.COLLABORATION];
    	}
        
        ContentVersion c = new ContentVersion();
        c.Title = 'test upload';        // some title
        c.PathOnClient = fieldPath; //dummy filepath, file doesn't exist on my computer. filetype is set based on a value of this field
        c.VersionData = blob.valueof('1115660548001'); //We store video Id from the BrightCove webstire
        c.Description = 'Test Description';
        c.RecordTypeId = CW.DefaultRecordTypeId;

        insert c;
        c = [SELECT Id, ContentDocumentId,File__c FROM ContentVersion WHERE Id =: c.Id];
        ContentWorkspaceDoc cwd = new ContentWorkspaceDoc(
            ContentDocumentId = c.ContentDocumentId,
            ContentWorkspaceId = CW.Id
        );
            
        insert cwd;
        Id testFileId = [SELECT Id, ContentDocumentId, File__c FROM ContentVersion WHERE Id =: c.Id Limit 1].File__c;
        File__c testFile = [SELECT Content_ID__c, Content_Version_Id__c, Folders__c, Page_Section__c, Distributors__c, Division_Access__c, OrgUnits__c From File__c Where Id =:testFileId Limit 1 ];
        testFile.Content_ID__c = c.ContentDocumentId;
        testFile.Content_Version_Id__c = c.Id;
        testFile.Folders__c = fileContent.Folders__c;
        testFile.Page_Section__c = fileContent.Page_Section__c;
        testFile.Distributors__c = fileContent.Distributors__c;
        testFile.Division_Access__c = fileContent.Division_Access__c;
        testFile.OrgUnits__c = fileContent.OrgUnits__c;
		testFile.Classification__c = fileContent.Classification__c;
		update testFile;
		fileContent = testFile;
        
    }
    
    
    // Method set up organization units
	private static void setup(){
        division = new Organizational_Unit__c(Label__c = 'Division', Name = 'divisionName', Type__c='Spirits');
        insert division;
        region = new Organizational_Unit__c(Label__c = 'Region', Name = 'regionName', Parent__c=division.Id, Type__c='Spirits');
        insert region;
        district = new Organizational_Unit__c(Label__c = 'State District', Name = 'regionName', Parent__c=region.Id, Type__c='Spirits');
        insert district;
        market = new Organizational_Unit__c(Label__c = 'Market', Name = 'regionName', Parent__c=district.Id, Type__c='Spirits');
        insert market;
    }
}