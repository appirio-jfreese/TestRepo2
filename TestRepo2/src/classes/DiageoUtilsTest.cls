/*******************************************************************************
Name		 		: DiageoUtilsTest

Updated By 	: Basant Verma (Appirio OffShore)
Date				: 23/07/2013
Story/Task	: For Sprint 7-8  code coverage.
*******************************************************************************/
@isTest
private class DiageoUtilsTest {


    static testMethod void test()
    {
    	System.Test.startTest();
    	String testString = DiageoUtils.getMonthFullnameFromMonthNumber(1);
    	System.assertEquals(testString, 'January');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(2);
    	System.assertEquals(testString, 'Febuary');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(3);
    	System.assertEquals(testString, 'March');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(4);
    	System.assertEquals(testString, 'April');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(5);
    	System.assertEquals(testString, 'May');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(6);
    	System.assertEquals(testString, 'June');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(7);
    	System.assertEquals(testString, 'July');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(8);
    	System.assertEquals(testString, 'August');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(9);
    	System.assertEquals(testString, 'September');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(10);
    	System.assertEquals(testString, 'October');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(11);
    	System.assertEquals(testString, 'November');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(12);
    	System.assertEquals(testString, 'December');
    	testString = DiageoUtils.getMonthFullnameFromMonthNumber(13);
    	System.assertEquals(testString, 'NA');
    	
    	decimal testShare = DiageoUtils.calculateShare(75, 25);
    	System.assertEquals(testShare, 200);
    	testShare = DiageoUtils.calculateShare(11, 0);
    	System.assertEquals(testShare, 100);
    	testShare = DiageoUtils.calculateShare(0, 0);
    	System.assertEquals(testShare, 0);
    	
    	List<SelectOption> monthList = DiageoUtils.getMonthOptions();
    	System.assertEquals(monthList.size(), 12);
    	
    	List<SelectOption> yearList = DiageoUtils.getYearOptions(2001, 15);
    	System.assertEquals(yearList.size(), 15);
    	
    	System.Test.stopTest();
    }

}