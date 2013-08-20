@isTest
private class Test_Controller_AccountSurvey {
	 
	 
	 
	 static testMethod void testControllerUpdates()
	 {
	 	Account account = Test_Helper.testInsertAccount('testAcct');
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
        
        system.test.startTest();
			
			
			layout.Activate_Survey__c = true;
			update layout;
			
			
			
			
			
			Survey__c survey = new Survey__c();
			//[select id, Extra_Credit_Value_1__c, Beating_Comp_Diageo_Val_1__c, Beating_Comp_Diageo_Val_5__c,
				//				Beating_Comp_Diageo_Val_6__c, Beating_Comp_Diageo_Val_4__c, Beating_Comp_Diageo_Val_3__c, Beating_Comp_Diageo_Val_2__c, 
					//			Beating_Comp_Diageo_Val_7__c, Beating_Comp_Diageo_Val_8__c, Beating_Comp_Diageo_Val_9__c, Beating_Comp_Diageo_Val_10__c
						//		from Survey__c where Survey_Layout__c = :layout.Id limit 1] ;
						
			survey.Extra_Credit_Value_1__c = true;
			survey.Beating_Comp_Diageo_Val_1__c = 11;
			survey.Beating_Comp_Diageo_Val_2__c = 1;
			survey.Beating_Comp_Diageo_Val_3__c = 1;
			survey.Beating_Comp_Diageo_Val_4__c = 1;
			survey.Beating_Comp_Diageo_Val_5__c = 1;
			survey.Beating_Comp_Diageo_Val_6__c = 1;
			survey.Beating_Comp_Diageo_Val_7__c = 1;
			survey.Beating_Comp_Diageo_Val_8__c = 1;
			survey.Beating_Comp_Diageo_Val_9__c = 1;
			survey.Beating_Comp_Diageo_Val_10__c = 1;
			survey.Survey_Layout__c = layout.Id;
			survey.Account__c = account.Id;
			//update survey;
			insert survey;
			
			
			Gold_Standard_Met__c newGsmRecord = new Gold_Standard_Met__c();
			newGsmRecord.Brand__c = brand.Id ;
			newGsmRecord.Survey__c = survey.Id ;
			newGsmRecord.Account__c = account.Id ;
			insert newGsmRecord;
			
			Gold_Standard_Met__c newGsmRecord2 = new Gold_Standard_Met__c();
			newGsmRecord2.Brand__c = brand.Id ;
			newGsmRecord2.BrandBottle_Size__c = bbi.BrandBottle_Size__c;
			newGsmRecord2.Survey__c = survey.Id ;
			newGsmRecord2.Account__c = account.Id ;
			insert newGsmRecord2;
			
			
			Controller_AccountSurvey controllerExt = new Controller_AccountSurvey( survey.Id );
			controllerExt.submitSurvey();
			//Updated by Akanksha(offshore) for case  00003540
			ApexPages.StandardController sc = new ApexPages.StandardController(survey);
			Controller_AccountSurvey controller = new Controller_AccountSurvey(sc);
			
		
		system.test.stopTest();
	 }
	 
	 
	 
	 
	 static testMethod void testDeletes()
	 {
	 	Account account = Test_Helper.testInsertAccount('testAcct');
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
        
		layout.Activate_Survey__c = true;
		update layout;
		
		Survey__c survey = new Survey__c();
			//[select id, Extra_Credit_Value_1__c, Beating_Comp_Diageo_Val_1__c, Beating_Comp_Diageo_Val_5__c,
				//				Beating_Comp_Diageo_Val_6__c, Beating_Comp_Diageo_Val_4__c, Beating_Comp_Diageo_Val_3__c, Beating_Comp_Diageo_Val_2__c, 
					//			Beating_Comp_Diageo_Val_7__c, Beating_Comp_Diageo_Val_8__c, Beating_Comp_Diageo_Val_9__c, Beating_Comp_Diageo_Val_10__c
						//		from Survey__c where Survey_Layout__c = :layout.Id limit 1] ;
						
		survey.Extra_Credit_Value_1__c = true;
		survey.Beating_Comp_Diageo_Val_1__c = 11;
		survey.Beating_Comp_Diageo_Val_2__c = 1;
		survey.Beating_Comp_Diageo_Val_3__c = 1;
		survey.Beating_Comp_Diageo_Val_4__c = 1;
		survey.Beating_Comp_Diageo_Val_5__c = 1;
		survey.Beating_Comp_Diageo_Val_6__c = 1;
		survey.Beating_Comp_Diageo_Val_7__c = 1;
		survey.Beating_Comp_Diageo_Val_8__c = 1;
		survey.Beating_Comp_Diageo_Val_9__c = 1;
		survey.Beating_Comp_Diageo_Val_10__c = 1;
		survey.Survey_Layout__c = layout.Id;
		survey.Account__c = account.Id;
		//update survey;
		insert survey;
		
		Controller_AccountSurvey controllerExt = new Controller_AccountSurvey( survey.Id );
		controllerExt.submitSurvey();
		
		
        system.test.startTest();
			
			try {
				survey.Survey_Status__c = 'Closed - Complete';
				update survey;
				survey.Beating_Comp_Diageo_Val_1__c = 1;
				update survey;
			} catch (Exception e) {}
			
			layout.Clone_Survey_Layout__c = true;
			try {
				update layout ;
			}
			catch (Exception e) {
			}
			
			delete layout ;
		
		system.test.stopTest();
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
        layout.Beating_Comp_Success_Percent_2__c = 0;
        layout.Beating_Comp_Success_Percent_3__c = 0;
        layout.Beating_Comp_Success_Percent_4__c = 0;
        layout.Beating_Comp_Success_Percent_5__c = 0;
        layout.Beating_Comp_Success_Percent_6__c = 0;
        layout.Beating_Comp_Success_Percent_7__c = 0;
        layout.Beating_Comp_Success_Percent_8__c = 0;
        layout.Beating_Comp_Success_Percent_9__c = 0;
        layout.Beating_Comp_Success_Percent_10__c = 0;
        layout.Clone_Survey_Layout__c = false;
        return layout;
	 }
	 
	 
	 static testMethod void testController() 
	 {	 	

        Account account = Test_Helper.testInsertAccount('testAcct');
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
        
        
        
        
        system.test.startTest();
			
			//going to put this here as another project missed this simple line:
			AggregateResultHolder testHolder = new AggregateResultHolder(); 
			
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
			
		
		system.test.stopTest();
	
	 }

}