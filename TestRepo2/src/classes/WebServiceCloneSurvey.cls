/**
*	@Webservice call used for clone button on survey.
*	@Sets value of clone field to true (and the trigger takes the true, sets to false, and clones all child (via lookup) objects)
*
*	@Author		: Jeremy Mooer
*	@Date		: 21 May 2012
*/
global class WebServiceCloneSurvey 
{
	
	
	WebService static String cloneSurveyLayoutRecordAndReturnMessageString(Id surveyLayoutId)
	{
		Survey_Layout__c surveyLayout = [select id, Clone_Survey_Layout__c from Survey_Layout__c where id = :surveyLayoutId limit 1] ;
		
		if(surveyLayout == null)
			return 'Unable to locate survey layout record for clone procedure.'; 
		
		surveyLayout.Clone_Survey_Layout__c = true;
		Database.SaveResult updateResult = database.update(surveyLayout, false) ;  //trigger then clones survey_layout and child records.
		
		if(updateResult.isSuccess()) {
			String successString = 'SUCCESS-'; //do not change this without changing the js in the button (on survey_layout__c layout)
			Survey_Layout__c[] clonedSurveyLayoutList = [select id, name from survey_layout__c order by createddate desc];
			Survey_Layout__c clonedSurveyLayout = clonedSurveyLayoutList[0];  //for some reason, createddate desc limit 1 was returning a random record
			successString += clonedSurveyLayout.Id ;
			return successString ;
		}else{
			String errorString = 'Errors occured while attempting to clone. ' ;
			for(Database.Error errorObj : updateResult.getErrors()) {
				errorString += errorObj.getMessage();
			}
			return errorString;
		}
		
		return 'Record Cloned.' ;
	}
	
	
	
	
}