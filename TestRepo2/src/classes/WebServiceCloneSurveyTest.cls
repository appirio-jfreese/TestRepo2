@isTest
private class WebServiceCloneSurveyTest {

    static testMethod void runWebserviceTest() 
    {
    	Survey_Layout__c layoutRecord = setupLayoutData();
		
		Account account = Test_Helper.testInsertAccount('testAcct');
		
		User testUser = Test_Helper.generateTestUser('A4L09', true, 'System Administrator');
		account.OwnerId = testUser.Id;
		update account;
		
		layoutRecord.OwnerId = testUser.Id;
		layoutRecord.Activate_Survey__c = true;
		update layoutRecord;
    	
    	
    	//Survey_Layout__c sl1 = [select id from Survey_Layout__c where Activate_Survey__c = false limit 1] ;
    	Survey_Layout__c sl2 = [select id from Survey_Layout__c where Activate_Survey__c = true limit 1] ;
    	Survey_Layout__c surveyLayout = new Survey_Layout__c();
    	insert surveyLayout;
		
		
		System.Test.startTest();
        	//WebServiceCloneSurvey.cloneSurveyLayoutRecordAndReturnMessageString(sl1.Id);
        	WebServiceCloneSurvey.cloneSurveyLayoutRecordAndReturnMessageString(sl2.Id);
        	WebServiceCloneSurvey.cloneSurveyLayoutRecordAndReturnMessageString(surveyLayout.Id);
		System.Test.stopTest();
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