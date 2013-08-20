public with sharing class Controller_AccountSurvey {
	
	public Boolean userHasEditPerms{get;set;}
	
	public Account account{get;set;}
	
	public Survey__c survey{get;set;}
	public Boolean surveyStatusIsComplete{get;set;}
	
	public Survey_Layout__c surveyLayout{get;set;}
	public List<SurveyLayout_Brand_Items__c> surveyLayoutBrandItems{get;set;}
	public List<Survey_Layout_Brand_Bottle_Item__c> surveyLayoutBrandBottleItems{get;set;}
	
	public List<Gold_Standard_Met__c> goldStandardList{get;set;}
	public List<Gold_Standard_Met__c> goldStandardBottleList{get;set;}
	
	public List<String> brandContentStringHtmlItems{get;set;}
	public List<String> brandBottleContentStringHtmlItems{get;set;}
	
	private Boolean config_RunningFromUrlVarId = false ;
	
	public Integer topCheckboxRowCount{get;set;}
	public Integer brandBottleCheckboxRowCount{get;set;}
	
	public Integer topCheckboxInitializedCount{get;set;}
	public Integer topCheckboxInitializedCountCol1{get;set;}
	public Integer topCheckboxInitializedCountCol2{get;set;}
	public Integer topCheckboxInitializedCountCol3{get;set;}
	public Integer totalCheckboxTopSectionAvailable{get;set;}
	public Integer topGrade{get;set;}
	
	public Integer totalBeatingCompetitionRows{get;set;}
	public Integer totalBeatingCompetitionSuccesses{get;set;}
	public Integer beatingRow1Success{get;set;}
	public Integer beatingRow2Success{get;set;}
	public Integer beatingRow3Success{get;set;}
	public Integer beatingRow4Success{get;set;}
	public Integer beatingRow5Success{get;set;}
	public Integer beatingRow6Success{get;set;}
	public Integer beatingRow7Success{get;set;}
	public Integer beatingRow8Success{get;set;}
	public Integer beatingRow9Success{get;set;}
	public Integer beatingRow10Success{get;set;}
	public Integer beatingCompGrade{get;set;}
	
	public Integer totalExtraCreditRows{get;set;}
	public Integer totalExtraCreditSuccesses{get;set;}
	public Double extraCreditGrade{get;set;}
	
	public Integer innovationGrade{get;set;}
	public Integer innovationSelectedCheckboxCount{get;set;}
	public Integer totalInnovationCheckboxes{get;set;}
	
	public Integer totalSurveyScore{get;set;}
	
	public Controller_AccountSurvey(ApexPages.StandardController controller) 
	{
		//this.controller = controller ;
		String surveyId = initializeConfigAndGetSurveyId();
		init(surveyId);
	}
	
	public Controller_AccountSurvey(String surveyId) 
	{
		//this.controller = controller ;
		init(surveyId);
	}
	
	private void init(String surveyId)
	{
		brandContentStringHtmlItems = new List<String>();
		brandBottleContentStringHtmlItems = new List<String>();
		topCheckboxRowCount = 0;
		brandBottleCheckboxRowCount = 0;
		
		populateSurveyFromSurveyId(surveyId); //doing some things in these methods in prep for an 'example layout' page
		
		if(survey != null) {
			getCurrentSurveyLayoutAndBrandItemListsFromSurveyId(survey.Survey_Layout__c);
			
			populateAccountFromPopulatedSurvey();
			
			generateGoldStandardMetRecordsFromLayoutList() ;
			
			initializeScore();
		}
		
		this.userHasEditPerms = setPerms();
		
	}
	
	private void initializeScore()
	{
		if(survey != null) {
			
			topCheckboxInitializedCount = getTopCheckboxTotalFromBrandItemList();
			
			innovationGrade = getInnovationNumbersAndReturnFinalScore() ;
			
			generateBeatingTheCompetitionNumbers();
			
			generateExtraCreditNumbers();
			
			generateTotalScore();
			
		}
	}
	
	
	private Boolean setPerms()
	{
		Boolean boolToReturn = false;
		if(survey != null && survey.Account__r.OwnerId == UserInfo.getUserId()) {
			boolToReturn = true;
		}
		
		String profileName = [select profile.name from user where id = :UserInfo.getUserId()].Profile.Name ;
		if(profileName == 'System Administrator')
			boolToReturn = true;
		
		if(system.Test.isRunningTest()) {
			boolToReturn = true;
		}
		
		return boolToReturn;
	}
	
	
	private void generateTotalScore()
	{
		totalSurveyScore = Math.round(extraCreditGrade + topGrade + beatingCompGrade) ;
	}
	
	
	private void calculateTotalExtraCreditLinesVisible() {
		String[] stringList = new String[]{surveyLayout.Extra_Credit_Label_1__c, surveyLayout.Extra_Credit_Label_2__c};
		stringList.add(surveyLayout.Extra_Credit_Label_3__c);
		stringList.add(surveyLayout.Extra_Credit_Label_4__c);
		stringList.add(surveyLayout.Extra_Credit_Label_5__c);
		stringList.add(surveyLayout.Extra_Credit_Label_6__c);
		stringList.add(surveyLayout.Extra_Credit_Label_7__c);
		stringList.add(surveyLayout.Extra_Credit_Label_8__c);
		stringList.add(surveyLayout.Extra_Credit_Label_9__c);
		stringList.add(surveyLayout.Extra_Credit_Label_10__c);
		
		totalExtraCreditRows = 0;
		for(String str : stringList) {
			if(!isNullOrEmpty(str)) {
				totalExtraCreditRows++;
			}
		}
	}
	
	private void generateExtraCreditNumbers() {
		
		calculateTotalExtraCreditLinesVisible();
		
		Boolean[] boolList = new Boolean[]{survey.Extra_Credit_Value_1__c, survey.Extra_Credit_Value_2__c};
		boolList.add(survey.Extra_Credit_Value_3__c);
		boolList.add(survey.Extra_Credit_Value_4__c);
		boolList.add(survey.Extra_Credit_Value_5__c);
		boolList.add(survey.Extra_Credit_Value_6__c);
		boolList.add(survey.Extra_Credit_Value_7__c);
		boolList.add(survey.Extra_Credit_Value_8__c);
		boolList.add(survey.Extra_Credit_Value_9__c);
		boolList.add(survey.Extra_Credit_Value_10__c);
		
		totalExtraCreditSuccesses = 0;
		for(Boolean bool : boolList) {
			if(bool == true) {
				totalExtraCreditSuccesses++;
			}
		}
		
		if(totalExtraCreditSuccesses == 0 || totalExtraCreditRows == 0) {
			extraCreditGrade = 0;
		}else{
			Decimal extraCreditGradeDec = (Double)totalExtraCreditSuccesses / (Double)totalExtraCreditRows ;
			extraCreditGradeDec = extraCreditGradeDec * surveyLayout.Percent_of_Grade_Extra_Credit__c ;
			extraCreditGrade = Math.round(extraCreditGradeDec); 
		}
	}
	
	
	private void calculateTotalCompetitionLinesVisible()
	{
		String[] stringList = new String[]{};
		stringList.add(surveyLayout.Beating_Comp_Label_1__c);
		stringList.add(surveyLayout.Beating_Comp_Label_2__c);
		stringList.add(surveyLayout.Beating_Comp_Label_3__c);
		stringList.add(surveyLayout.Beating_Comp_Label_4__c);
		stringList.add(surveyLayout.Beating_Comp_Label_5__c);
		stringList.add(surveyLayout.Beating_Comp_Label_6__c);
		stringList.add(surveyLayout.Beating_Comp_Label_7__c);
		stringList.add(surveyLayout.Beating_Comp_Label_8__c);
		stringList.add(surveyLayout.Beating_Comp_Label_9__c);
		stringList.add(surveyLayout.Beating_Comp_Label_10__c);
		
		totalBeatingCompetitionRows = 0;
		for(String str : stringList) {
			if(!isNullOrEmpty(str)) {
				totalBeatingCompetitionRows++;
			}
		}
	}
	
	private void generateBeatingTheCompetitionNumbers()
	{
		calculateTotalCompetitionLinesVisible();
		
		totalBeatingCompetitionSuccesses = 0;
		beatingRow1Success = beatingRow2Success = beatingRow3Success = beatingRow4Success = 0;
		beatingRow5Success = beatingRow6Success = beatingRow7Success = beatingRow8Success = 0;
		beatingRow9Success = beatingRow10Success = 0;
		
		if(survey.Beating_Comp_Calc1__c >= surveyLayout.Beating_Comp_Success_Percent_1__c ) {
			totalBeatingCompetitionSuccesses++;
			beatingRow1Success = 1;
		}
		if(survey.Beating_Comp_Calc2__c >= surveyLayout.Beating_Comp_Success_Percent_2__c ) {
			totalBeatingCompetitionSuccesses++;
			beatingRow2Success = 1;
		}
		if(survey.Beating_Comp_Calc3__c >= surveyLayout.Beating_Comp_Success_Percent_3__c ) {
			totalBeatingCompetitionSuccesses++;
			beatingRow3Success = 1;
		}
		if(survey.Beating_Comp_Calc4__c >= surveyLayout.Beating_Comp_Success_Percent_4__c ) {
			totalBeatingCompetitionSuccesses++;
			beatingRow4Success = 1;
		}
		if(survey.Beating_Comp_Calc5__c >= surveyLayout.Beating_Comp_Success_Percent_5__c ) {
			totalBeatingCompetitionSuccesses++;
			beatingRow5Success = 1;
		}
		if(survey.Beating_Comp_Calc6__c >= surveyLayout.Beating_Comp_Success_Percent_6__c ) {
			totalBeatingCompetitionSuccesses++;
			beatingRow6Success = 1;
		}
		if(survey.Beating_Comp_Calc7__c >= surveyLayout.Beating_Comp_Success_Percent_7__c ) {
			totalBeatingCompetitionSuccesses++;
			beatingRow7Success = 1;
		}
		if(survey.Beating_Comp_Calc8__c >= surveyLayout.Beating_Comp_Success_Percent_8__c ) {
			totalBeatingCompetitionSuccesses++;
			beatingRow8Success = 1;
		}
		if(survey.Beating_Comp_Calc9__c >= surveyLayout.Beating_Comp_Success_Percent_9__c ) {
			totalBeatingCompetitionSuccesses++;
			beatingRow9Success = 1;
		}
		if(survey.Beating_Comp_Calc10__c >= surveyLayout.Beating_Comp_Success_Percent_10__c ) {
			totalBeatingCompetitionSuccesses++;
			beatingRow10Success = 1;
		}
		
		
		if(totalBeatingCompetitionRows == 0 || totalBeatingCompetitionSuccesses == 0) {
			beatingCompGrade = 0;
		}else{
			Double beatingCompDec = ((Double)totalBeatingCompetitionSuccesses / (Double)totalBeatingCompetitionRows) ;
			beatingCompDec = beatingCompDec * surveyLayout.Percent_of_Grade_BeatComp__c ;
			beatingCompGrade = Math.round(beatingCompDec) ;
		}
		
		
		
	}
	
	private Integer getInnovationNumbersAndReturnFinalScore()
	{
		Integer numToReturn = 0;
		innovationSelectedCheckboxCount = 0;
		totalInnovationCheckboxes = 0;
		
		for(Gold_Standard_Met__c item : goldStandardBottleList) {
			totalInnovationCheckboxes++;
			
			if(item.Gold_Standard_for_Distribution_Met__c == true) {
				innovationSelectedCheckboxCount++;
			}
		}
		
		if(innovationSelectedCheckboxCount != 0 && totalInnovationCheckboxes != 0) {
			Double numToReturnDouble = ((Double)innovationSelectedCheckboxCount / (Double)totalInnovationCheckboxes) ;
			numToReturn = Math.round( numToReturnDouble ) ;
		}
		
		return numToReturn ;
	}
	
	private Integer getTopCheckboxTotalFromBrandItemList()
	{
		Integer numToReturn = 0;
		topCheckboxInitializedCountCol1 = 0;
		topCheckboxInitializedCountCol2 = 0;
		topCheckboxInitializedCountCol3 = 0;
		totalCheckboxTopSectionAvailable = 0;
		
		for(Gold_Standard_Met__c item : goldStandardList)
		{
			if(item.Gold_Standard_Display_Not_Applicable__c == true) {
				totalCheckboxTopSectionAvailable = totalCheckboxTopSectionAvailable + 2 ;
			}else{
				totalCheckboxTopSectionAvailable = totalCheckboxTopSectionAvailable + 3 ;
			}
			
			if(item.Gold_Standard_for_Distribution_Met__c == true) {
				numToReturn++;
				topCheckboxInitializedCountCol1++;
			}
			if(item.Gold_Standard_for_Shelf_Met__c == true) {
				numToReturn++;
				topCheckboxInitializedCountCol2++;
			}
			if(item.Gold_Standard_for_Display_Met__c == true && item.Gold_Standard_Display_Not_Applicable__c == false) {
				numToReturn++;
				topCheckboxInitializedCountCol3++;
			}
		}
		
		if(numToReturn == 0 || totalCheckboxTopSectionAvailable == 0) {
			topGrade = 0;
		}else{
			Double topGradeDec = ((Double)numToReturn / (Double)totalCheckboxTopSectionAvailable) * surveyLayout.Percent_of_Grade_Dist__c ;
			topGrade = Math.round( topGradeDec ) ;
		}
		
		return numToReturn ;
	}
	
	
	
	private String initializeConfigAndGetSurveyId()
	{
		String surveyLayoutId = ApexPages.currentPage().getParameters().get('surveyLayoutId');
		
		if(isNullOrEmpty(surveyLayoutId)) {
			surveyLayoutId = ApexPages.currentPage().getParameters().get('Id');
		}
		
		return surveyLayoutId;
	}
	
	private void populateSurveyFromSurveyId(String surveyId)
	{
		if(!isNullOrEmpty(surveyId))
		{
			Survey__c[] surveyList = [select Id, account__r.OwnerId, Name, Account__c, Survey_Date__c, Survey_Layout__c, Extra_Credit_Value_1__c, 
							Extra_Credit_Value_2__c, Extra_Credit_Value_3__c, Extra_Credit_Value_4__c, 
							Extra_Credit_Value_5__c, Extra_Credit_Value_6__c, Extra_Credit_Value_7__c, 
							Extra_Credit_Value_8__c, Extra_Credit_Value_9__c, Extra_Credit_Value_10__c, 
							Beating_Comp_Diageo_Val_1__c, Beating_Comp_Diageo_Val_2__c, Beating_Comp_Diageo_Val_3__c,
							Beating_Comp_Diageo_Val_4__c, Beating_Comp_Diageo_Val_5__c, Beating_Comp_Diageo_Val_6__c, 
							Beating_Comp_Diageo_Val_7__c, Beating_Comp_Diageo_Val_8__c, Beating_Comp_Diageo_Val_9__c, 
							Beating_Comp_Diageo_Val_10__c, Beating_Comp_Tot_Val_1__c, Beating_Comp_Tot_Val_2__c, 
							Beating_Comp_Tot_Val_3__c, Beating_Comp_Tot_Val_4__c, Beating_Comp_Tot_Val_5__c, 
							Beating_Comp_Tot_Val_6__c, Beating_Comp_Tot_Val_7__c, Beating_Comp_Tot_Val_8__c, 
							Beating_Comp_Tot_Val_9__c, Beating_Comp_Tot_Val_10__c, Survey_Status__c,
							Beating_Comp_Calc1__c, Beating_Comp_Calc2__c, Beating_Comp_Calc3__c, Beating_Comp_Calc4__c,
							Beating_Comp_Calc5__c, Beating_Comp_Calc6__c, Beating_Comp_Calc7__c, Beating_Comp_Calc8__c,
							Beating_Comp_Calc9__c, Beating_Comp_Calc10__c
							from Survey__c
							where id = :surveyId];
			
			if(!surveyList.isEmpty()) {
				survey = surveyList[0] ;
				surveyStatusIsComplete = survey.Survey_Status__c == 'Closed - Complete' ;
			} 
		}
	
	}
	
	
	
	private void getCurrentSurvey()
	{
		//only used if a survey is passed in.
		//populate the currentPage paramaters with acct = survey__c.account__c;
	}
	
	private void getCurrentSurveyLayoutAndBrandItemListsFromSurveyId(String surveyId)
	{
		String surveyLayoutId = survey.Survey_Layout__c ;
		
		if(!isNullOrEmpty(surveyLayoutId)) {
			Survey_Layout__c[] surveyLayoutList = [select Id, Name, Beating_Comp_Label_1__c, Beating_Comp_Label_2__c, Beating_Comp_Label_3__c, 
														Beating_Comp_Label_4__c, Beating_Comp_Label_5__c, Beating_Comp_Label_6__c, 
														Beating_Comp_Label_7__c, Beating_Comp_Label_8__c, Beating_Comp_Label_9__c, 
														Beating_Comp_Label_10__c, Percent_of_Grade_Dist__c, 
														Percent_of_Grade_Innovation__c, Percent_of_Grade_BeatComp__c, 
														Percent_of_Grade_Extra_Credit__c, Extra_Credit_Label_1__c, 
														Extra_Credit_Label_2__c, Extra_Credit_Label_3__c, Extra_Credit_Label_4__c, 
														Extra_Credit_Label_5__c, Extra_Credit_Label_6__c, Extra_Credit_Label_7__c, 
														Extra_Credit_Label_8__c, Extra_Credit_Label_9__c, Extra_Credit_Label_10__c, 
														Beating_Comp_Success_Percent_1__c, Beating_Comp_Success_Percent_2__c, Beating_Comp_Success_Percent_3__c, 
														Beating_Comp_Success_Percent_4__c, Beating_Comp_Success_Percent_5__c, Beating_Comp_Success_Percent_6__c, 
														Beating_Comp_Success_Percent_7__c, Beating_Comp_Success_Percent_8__c, Beating_Comp_Success_Percent_9__c, 
														Beating_Comp_Success_Percent_10__c
														from Survey_Layout__c where id = :surveyLayoutId] ;
			if(!surveyLayoutList.isEmpty()) {
				surveyLayout = surveyLayoutList[0];
				surveyLayoutBrandItems = [select Id, Name, Brand__c, Survey_Layout__c from SurveyLayout_Brand_Items__c where Survey_Layout__c = :surveyLayout.Id order by createddate] ;
				surveyLayoutBrandBottleItems = [select Id, Name, BrandBottle_Size__c, BrandBottle_Size__r.Brand__c, Survey_Layout__c from Survey_Layout_Brand_Bottle_Item__c where Survey_Layout__c = :surveyLayout.Id order by createddate] ;
			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid Survey Layout selected.'));
			}
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid Survey Layout selected.'));
		}
	}
	
	private void generateGoldStandardMetRecordsFromLayoutList()
	{
		goldStandardList = new List<Gold_Standard_Met__c>();
		goldStandardBottleList = new List<Gold_Standard_Met__c>();
		
		if(config_RunningFromUrlVarId) {
			for(SurveyLayout_Brand_Items__c layoutBrandItem : surveyLayoutBrandItems) {
				
				Gold_Standard_Met__c met = new Gold_Standard_Met__c();
				met.Brand__c = layoutBrandItem.Brand__c ;
				if(account != null)
					met.Account__c = account.Id;
				goldStandardList.add(met);
			}
			
			for(Survey_Layout_Brand_Bottle_Item__c layoutBrandBottleItem : surveyLayoutBrandBottleItems) {
				Gold_Standard_Met__c met2 = new Gold_Standard_Met__c();
				met2.Brand__c = layoutBrandBottleItem.BrandBottle_Size__r.Brand__c ;
				met2.BrandBottle_Size__c = layoutBrandBottleItem.BrandBottle_Size__c ;
				if(account != null)
					met2.Account__c = account.Id;
				goldStandardBottleList.add(met2);
			}
			
		}else{
			if(survey != null && survey.Id != null)
			{
				for(Gold_Standard_Met__c actualLayoutBrandItem : [select Id, Brand__r.Name, Comments__c, BrandBottle_Size__c, Gold_Standard_for_Display_Met__c, 
																	Gold_Standard_for_Shelf_Met__c, Gold_Standard_for_Distribution_Met__c, Brand__c,
																	Gold_Standard_Display_Not_Applicable__c,
																	Brand__r.Gold_Standard_Shelf__c, Brand__r.Gold_Standard_Image__c,
																	Brand__r.Gold_Standard_Distribution__c, Brand__r.Gold_Standard_Display__c
																	from Gold_Standard_Met__c
																	where Survey__c = :survey.Id
																	and (BrandBottle_Size__c = '' or BrandBottle_Size__c = null)
																	order by createddate]) 
				{
					goldStandardList.add(actualLayoutBrandItem);
					brandContentStringHtmlItems.add( getHtmlContentFromGoldStandardMet(actualLayoutBrandItem) );
				}
				
				for(Gold_Standard_Met__c actualLayoutBrandBottleItem : [select Id, Comments__c, BrandBottle_Size__r.Name, BrandBottle_Size__c, Gold_Standard_for_Display_Met__c, 
																	Gold_Standard_for_Shelf_Met__c, Gold_Standard_for_Distribution_Met__c, Brand__c,
																	Gold_Standard_Display_Not_Applicable__c,
																	Brand__r.Gold_Standard_Shelf__c, Brand__r.Gold_Standard_Image__c,
																	Brand__r.Gold_Standard_Distribution__c, Brand__r.Gold_Standard_Display__c
																	from Gold_Standard_Met__c
																	where Survey__c = :survey.Id
																	and BrandBottle_Size__c <> ''
																	and BrandBottle_Size__c <> null 
																	order by createddate]) 
				{
					goldStandardBottleList.add(actualLayoutBrandBottleItem);
					brandBottleContentStringHtmlItems.add( getHtmlContentFromGoldStandardMet(actualLayoutBrandBottleItem) );
				}
			}
		}
		
		if(goldStandardList != null && !goldStandardList.isEmpty()) {
			topCheckboxRowCount = goldStandardList.size() ;
		}
		
		if(goldStandardBottleList != null && !goldStandardBottleList.isEmpty()) {
			brandBottleCheckboxRowCount = goldStandardBottleList.size() ;
		}
			
		
	}
	
	
	private String getHtmlContentFromGoldStandardMet(Gold_Standard_Met__c goldMetRecord)
	{
		String stringToReturn = '<table width="500" border="0"><tr><td width="100%">';
		
		if(goldMetRecord.Brand__r.Gold_Standard_Image__c != null) {
			//stringToReturn += goldMetRecord.Brand__r.Gold_Standard_Image__c + '<br />' ;
		}
		
		//stringToReturn += '</td><td width="100%" style="vertical-align:top">';
		
		if(goldMetRecord.Brand__r.Gold_Standard_Shelf__c != null) {
			stringToReturn += '<b>Gold Standard - Shelf</b><br />' ;
			stringToReturn += goldMetRecord.Brand__r.Gold_Standard_Shelf__c + '<br /><br />' ;
		}
		
		if(goldMetRecord.Brand__r.Gold_Standard_Distribution__c != null) {
			stringToReturn += '<b>Gold Standard - Distribution</b><br />' ;
			stringToReturn += goldMetRecord.Brand__r.Gold_Standard_Distribution__c + '<br /><br />' ;
		}
		
		if(goldMetRecord.Brand__r.Gold_Standard_Display__c != null) {
			stringToReturn += '<b>Gold Standard - Display</b><br />' ;
			stringToReturn += goldMetRecord.Brand__r.Gold_Standard_Display__c + '<br /><br />' ;
		}
		
		//stringToReturn = stringToReturn.replace('\n', '<br />') ;
		//stringToReturn = stringToReturn.replace('<', '&#60;') ;
		//stringToReturn = stringToReturn.replace('>', '&#62;') ;
		//stringToReturn = stringToReturn.replace('\'', '"') ;
		
		//stringToReturn = EncodingUtil.urlEncode(stringToReturn, 'UTF-8') ;
		
		stringToReturn += '</td></tr></table>';
		
		return stringToReturn;
	}
	
	
	
	private void populateAccountFromPopulatedSurvey()
	{
		if(survey != null && survey.Account__c != null) {
			Account[] acctList = [select id, name from account where id = :survey.Account__c] ;
			if(!acctList.isEmpty()) {
				account = acctList[0];
			}else{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No account was selected for this survey.  Use the button on an account record to start a survey'));
			}
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No account was selected for this survey.  Use the button on an account record to start a survey'));
		}
		
	}
	
	
	
	
	private Boolean pageIsValidForSubmit() {
		
		if(userHasEditPerms == false)
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You do not own the Account associated with this survey and cannot edit it.'));
		
		if(account == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No account was selected for this survey.  Use the button on an account record to start a survey'));
		}
		
		if(ApexPages.hasMessages()){
			return false;
		}
		
		return true;
	}
	
	public PageReference submitSurvey()
	{
		if(pageIsValidForSubmit()) {
			return saveSurvey();
		}
		 
		return null;
	}
	
	private void calculateScore()
	{
		
		
	}
	
	public PageReference saveSurvey()
	{
		if(surveyStatusIsComplete == true) {
			survey.Survey_Status__c = 'Closed - Complete';
		}else{
			survey.Survey_Status__c = 'Open - In Progress';
		}
		
		initializeScore();
		survey.Score_Beating_the_Competition__c = beatingCompGrade;
		survey.Score_Distribution_Shelf_Display__c = topGrade;
		survey.Score_Extra_Credit__c = extraCreditGrade;
		survey.Score_Sustainovation__c = innovationGrade;
		survey.Score_Total__c = totalSurveyScore;
		
		
		if(survey.Id == null) {
			insert survey ;
		}else{
			update survey ;
		}
		
		Gold_Standard_Met__c[] metUpdateList = new Gold_Standard_Met__c[]{};
		Gold_Standard_Met__c[] metInsertList = new Gold_Standard_Met__c[]{};
		
		for(Gold_Standard_Met__c met : goldStandardList) {
			met.Survey__c = survey.Id ;
			if(met.Id != null) {
				metUpdateList.add(met);
			}else{
				metInsertList.add(met);
			}
		}
		for(Gold_Standard_Met__c met2 : goldStandardBottleList) {
			met2.Survey__c = survey.Id ;
			if(met2.Id != null) {
				metUpdateList.add(met2);
			}else{
				metInsertList.add(met2);
			}
		}
		Boolean errorsExist = false;
		
		Database.SaveResult[] srList = database.insert(metInsertList) ;
		
		for(Database.SaveResult sr : srList) {
			for(Database.Error err: sr.getErrors())
			{
			   errorsExist = true;
			   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage());
			   ApexPages.addMessage(myMsg);
			}
		}
		
		
		Database.SaveResult[] srList2 = database.update(metUpdateList);
		
		for(Database.SaveResult sr2 : srList2) {
			for(Database.Error err: sr2.getErrors())
			{
			   errorsExist = true;
			   ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage());
			   ApexPages.addMessage(myMsg2);
			}
		}
			
		
		if(errorsExist) {
			return null;
		}
		return new PageReference('/apex/AccountSurvey?id=' + survey.Id);
	}
	
	
	private Boolean isNullOrEmpty(String str)
	{
		if(str == null)
			return true;
		
		if(str == '')
			return true;
		
		return false;
	}
	
	
	
	public PageReference addBrandToSurvey()
	{
		
		
		return null;
	}
	
	
	
	
}