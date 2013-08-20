global class ScheduleGenerateSurveys implements Schedulable 
{

	global void execute(SchedulableContext SC) 
	{
		BatchGenerateSurveysAfterActivation batch = new BatchGenerateSurveysAfterActivation();
		database.executebatch(batch,1);
	}
	
	
	
	static testmethod void testSchedule() 
	{
		Test.startTest();
			
			String jobId = system.schedule('Generate_Surveys_AfterActivation', '0 0 0 * * ?', new ScheduleGenerateSurveys());
			CronTrigger ct = [SELECT id, CronExpression, TimesTriggered,NextFireTime from CronTrigger WHERE id = :jobId];
			
			system.assertEquals('0 0 0 * * ?', ct.CronExpression);
			system.assertEquals(0, ct.TimesTriggered);
			
		Test.stopTest();
	}
}