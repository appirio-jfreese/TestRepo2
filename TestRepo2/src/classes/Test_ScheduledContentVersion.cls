@istest

class Test_ScheduledContentVersion {
	 static testmethod void test() {
   		Test.startTest();
   		String CRON_EXP = '0 0 0 3 9 ? 2022';
   		String jobId = System.schedule('ScheduledContentVersion',
      	CRON_EXP, new ScheduledContentVersion());
         
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
        NextFireTime
        FROM CronTrigger WHERE id = :jobId];

   		// Verify the expressions are the same 
      	System.assertEquals(CRON_EXP, ct.CronExpression);
        // Verify the next time the job will run 
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
   		Test.stopTest();
	 }
	 
	 static testmethod void test2() {
   		Test.startTest();
   		String CRON_EXP = '0 0 0 3 9 ? 2022';
   		String jobId = System.schedule('ScheduledContentVersion2',
      	CRON_EXP, new ScheduledContentVersion2());
         
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
        NextFireTime
        FROM CronTrigger WHERE id = :jobId];

   		// Verify the expressions are the same 
      	System.assertEquals(CRON_EXP, ct.CronExpression);
        // Verify the next time the job will run 
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
   		Test.stopTest();
	 }	 
}