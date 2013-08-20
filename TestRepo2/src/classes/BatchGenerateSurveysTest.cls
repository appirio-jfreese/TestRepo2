@isTest
private class BatchGenerateSurveysTest {
	
	
	
	static testMethod void testSurveyBatch()
	{
		Survey_Layout__c layoutRecord = setupLayoutData();
		
		Account account = Test_Helper.testInsertAccount('testAcct');
		
		
		Test.StartTest();
			
			User testUser = Test_Helper.generateTestUser('A4L09', true, 'System Administrator');
			account.OwnerId = testUser.Id;
			update account;
			
			layoutRecord.OwnerId = testUser.Id;
			layoutRecord.Activate_Survey__c = true;
			update layoutRecord;
			
			
    		String query = 'select id, Due_Date__c, Activate_Survey__c, OwnerId from survey_layout__c where activate_survey__c = true ';
    		query += ' and id =  \'' + layoutRecord.Id + '\' ';
    		BatchGenerateSurveysAfterActivation batch = new BatchGenerateSurveysAfterActivation(query);
    		
    		ID batchprocessid = database.executebatch(batch,1);
    	//Updated by Akanksha(offshore) for case  00003540
	
    				
        Map<Id,User> activeUserMap = new Map<Id,User>( [select id, userRoleId from user where isActive = true] );
        Map<Id,UserRole> userRoleMap = new Map<Id,UserRole>( [select id, name, parentRoleId from userRole] );
        Map<Id,List<UserRole>> userRoleMapByParentId = new Map<Id,List<UserRole>>();

        for(UserRole usrRole1 : userRoleMap.values()) {
            if(usrRole1.parentRoleId != null) {
                List<UserRole> childList1 = userRoleMapByParentId.get(usrRole1.parentRoleId);
                if(childList1 == null) {
                    childList1 = new List<UserRole>();
                }
                childList1.add(usrRole1);
               
            }
        }
       List<User> subordinateUsersMap = batch.buildListOfSubordinateUsers(UserInfo.getUserId(), activeUserMap, userRoleMap);
	
    	Test.StopTest();
		
	}
	
	private static Survey_Layout__c setupLayoutData()
	{
		Survey_Layout__c layout = createSurveyLayout('test layout');
		
		Brand__c brand = new Brand__c();
        brand.Name = 'testBrand';
        brand.Innovation__c = true;
        brand.Brand_Type__c = 'Individual';
        insert brand;
        
        Bottle_Size__c bottleSize = new Bottle_Size__c();
        bottleSize.Name = '1000' ;
        insert bottleSize;
        
        BrandBottle_Size__c bbs = new BrandBottle_Size__c();
        bbs.Bottle_Size__c = bottleSize.Id;
        bbs.Brand__c = brand.Id;
        insert bbs;
        
        insert layout ;
       
        Survey_Layout_Brand_Bottle_Item__c bbi = new Survey_Layout_Brand_Bottle_Item__c();
        bbi.BrandBottle_Size__c = bbs.Id;
        bbi.Survey_Layout__c = layout.Id;
        
        SurveyLayout_Brand_Items__c bi = new SurveyLayout_Brand_Items__c();
        bi.Brand__c = brand.Id;
        bi.Survey_Layout__c = layout.Id;
        bi.Display_Checkbox_Not_Applicable__c = true;
		
		
		insert bbi;
		insert bi;
		
		return layout;
	}
	
	
	private static Survey_Layout__c createSurveyLayout(String layoutName)
	 {
	 	Survey_Layout__c layout = new Survey_Layout__c();
        layout.Name = layoutName;
        layout.Beating_Comp_Label_1__c = 'test 1';
        layout.Beating_Comp_Success_Percent_1__c = 10;
        layout.Extra_Credit_Label_1__c = 'test 1';
        layout.Percent_of_Grade_Innovation__c = 25;
        layout.Percent_of_Grade_Extra_Credit__c = 25;
        layout.Percent_of_Grade_Dist__c = 25;
        layout.Percent_of_Grade_BeatComp__c = 25;
        layout.Beating_Comp_Success_Percent_1__c = 0;
        layout.Clone_Survey_Layout__c = false;
        return layout;
	 }
	
	
}