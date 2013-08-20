@isTest
private class Test_Controller_InnovationAndVAP{

      class TestSettings {
         Contact contact;
         Account account;
         User user;
         Brand__c brand1;
         Brand__c brand2;
         Calendar__c calendar1;
         Calendar__c calendar2;
         
         Calendar__c[] calendars;
         
         String baseDate;
         String nextMonthBase;
         String prevMonthBase;
         
         public TestSettings(){

                account = Test_Helper.testInsertAccount('test_account1');
                contact = Test_Helper.testInsertContact('firstName', 'lastName', account.id);
                User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];   
                System.runAs (thisUser) { 
                    user = Test_Helper.testInsertDistributorPortalUser(contact.id);
                }
                
                baseDate = date.today().year()+'-'+date.today().month();
                
                
         }
         
         public void insertTwoBrands(){
            brand1 = Test_Helper.testInsertBrand('brand1');
            brand2 = Test_Helper.testInsertBrand('brand2');
         }
         
         public void insertTwoCalendars(){
            calendar1 = Test_Helper.testInsertCalendar('calendar1', 'Innovation', 'GLBT', '1', 'description1', date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'), false, false);                
            calendar2 = Test_Helper.testInsertCalendar('calendar2', 'Innovation', 'GLBT', '1', 'description2', date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'), false, false);                
         }
         
         public void prepareCalendarList(){
            
                Date tmpDate = date.today();
                tmpDate = tmpDate.addMonths(1);
                nextMonthBase = tmpDate.year()+'-'+tmpDate.month();
                tmpDate = tmpDate.addMonths(-2);
                prevMonthBase = tmpDate.year()+'-'+tmpDate.month();
                
                calendars = new Calendar__c[]{
                    Test_Helper.testInsertCalendar('calendar1', 'Innovation', 'GLBT', '1', 'description1', date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar1', 'Innovation', 'GLBT', '1', 'description2', date.valueOf(nextMonthBase+'-1'), date.valueOf(nextMonthBase+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar3', 'Innovation', 'GLBT', '1', 'description3', date.valueOf(nextMonthBase+'-1'), date.valueOf(nextMonthBase+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar4', 'Innovation', 'GLBT', '1', 'description3', date.valueOf(prevMonthBase+'-1'), date.valueOf(prevMonthBase+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar5', 'Innovation', 'GLBT', '1', 'description5', date.valueOf(prevMonthBase+'-1'), date.valueOf(prevMonthBase+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar6', 'Innovation', 'GLBT', '1', 'description6', date.valueOf(prevMonthBase+'-1'), date.valueOf(prevMonthBase+'-10'), false, false)
                };
                
                brand1 = Test_Helper.testInsertBrand('brand1');
                Test_Helper.testInsertAccountBrand(account.id, brand1.id);
                
                for(Calendar__c cal : calendars){
                    Test_Helper.testInsertCalendarBrand(cal.id, brand1.id);
                }
         }
         
         public void prepareCalendarListQ(){
            
                Service_Calendar sc = new Service_Calendar(3);
                Date tmpDate = sc.startDate;
                prevMonthBase = tmpDate.year()+'-'+tmpDate.month();
                tmpDate = tmpDate.addMonths(1);
                baseDate = tmpDate.year()+'-'+tmpDate.month();
                tmpDate = tmpDate.addMonths(1);
                nextMonthBase = tmpDate.year()+'-'+tmpDate.month();
                
                calendars = new Calendar__c[]{
                    Test_Helper.testInsertCalendar('calendar1', 'Innovation', 'GLBT', '1', 'description1', date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar1', 'Innovation', 'GLBT', '1', 'description2', date.valueOf(nextMonthBase+'-1'), date.valueOf(nextMonthBase+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar3', 'Innovation', 'GLBT', '1', 'description3', date.valueOf(nextMonthBase+'-1'), date.valueOf(nextMonthBase+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar4', 'Innovation', 'GLBT', '1', 'description3', date.valueOf(prevMonthBase+'-1'), date.valueOf(prevMonthBase+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar5', 'Innovation', 'GLBT', '1', 'description5', date.valueOf(prevMonthBase+'-1'), date.valueOf(prevMonthBase+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar6', 'Innovation', 'GLBT', '1', 'description6', date.valueOf(prevMonthBase+'-1'), date.valueOf(prevMonthBase+'-10'), false, false)
                };
                
                brand1 = Test_Helper.testInsertBrand('brand1');
                Test_Helper.testInsertAccountBrand(account.id, brand1.id);
                
                for(Calendar__c cal : calendars){
                    Test_Helper.testInsertCalendarBrand(cal.id, brand1.id);
                }
         }
         
         public void prepareCalendarList2(){
            
                calendars = new Calendar__c[]{
                    Test_Helper.testInsertCalendar('calendar1', 'Sustainovation', 'GLBT', '1', 'description1', date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar1', 'Innovation', 'GLBT', '1', 'description2', date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar3', 'Innovation', 'GLBT', '1', 'description3', date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar4', 'VAP', 'GLBT', '1', 'description3', date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar5', 'VAP', 'GLBT', '1', 'description5', date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'), false, false),
                    Test_Helper.testInsertCalendar('calendar6', 'VAP', 'GLBT', '1', 'description6', date.valueOf(baseDate+'-1'), date.valueOf(baseDate+'-10'), false, false)
                };
                
                brand1 = Test_Helper.testInsertBrand('brand1');
                Test_Helper.testInsertAccountBrand(account.id, brand1.id);
                
                for(Calendar__c cal : calendars){
                    Test_Helper.testInsertCalendarBrand(cal.id, brand1.id);
                }
         }
        
      }
    
    
    static testmethod void testConstructor(){
        PageReference pageRef = Page.InnovationAndVAP;
        Test.setCurrentPage(pageRef);
        
        TestSettings ts = new  TestSettings();
        ts.insertTwoBrands();
        ts.insertTwoCalendars();
        Test_Helper.testInsertAccountBrand(ts.account.id, ts.brand1.id);
        Test_Helper.testInsertCalendarBrand(ts.calendar1.id, ts.brand1.id);
        Test_Helper.testInsertCalendarBrand(ts.calendar2.id, ts.brand2.id);
        
        Test.StartTest();
        System.RunAs(ts.user){
            Controller_InnovationAndVAP c = new Controller_InnovationAndVAP();
            Date d = Date.today();
            System.assertEquals(d.year()+'-'+d.month()+'-01', c.startFromDate);
            System.assertEquals(1, c.timePeriod);
            System.assertEquals('All', c.salesDriver);
            System.assertEquals(false, c.isExport);
        }
        
        Test.StopTest();
    } 

    static testmethod void testConstructorGetParameters(){
        PageReference pageRef = Page.InnovationAndVAP;
        Test.setCurrentPage(pageRef);
        
        TestSettings ts = new  TestSettings();
        ts.insertTwoBrands();
        ts.insertTwoCalendars();
        Test_Helper.testInsertAccountBrand(ts.account.id, ts.brand1.id);
        Test_Helper.testInsertCalendarBrand(ts.calendar1.id, ts.brand1.id);
        Test_Helper.testInsertCalendarBrand(ts.calendar2.id, ts.brand2.id);
        Test.StartTest();
        System.RunAs(ts.user){
            ApexPages.currentPage().getParameters().put('date', '2011-10-1');
            ApexPages.currentPage().getParameters().put('time', '3');
            ApexPages.currentPage().getParameters().put('driver', 'Innovation');
            ApexPages.currentPage().getParameters().put('export', 'true');
            ApexPages.currentPage().getParameters().put('date', '2011-10-1');
            
            Controller_InnovationAndVAP c = new Controller_InnovationAndVAP();
            System.assertEquals('2011-10-01', c.startFromDate);
            System.assertEquals(3, c.timePeriod);
            System.assertEquals('Innovation', c.salesDriver);
            System.assertEquals(true, c.isExport);
        }
        Test.StopTest();
    } 
    
    static testmethod void testGetDataForProperAccount(){
        PageReference pageRef = Page.InnovationAndVAP;
        Test.setCurrentPage(pageRef);
        
        TestSettings ts = new  TestSettings();
        ts.insertTwoBrands();
        ts.insertTwoCalendars();
        Test_Helper.testInsertAccountBrand(ts.account.id, ts.brand1.id);
        Test_Helper.testInsertCalendarBrand(ts.calendar1.id, ts.brand1.id);
        Test_Helper.testInsertCalendarBrand(ts.calendar2.id, ts.brand1.id);
        
        Controller_InnovationAndVAP c;
        Test.StartTest();
        System.RunAs(ts.user){
            c = new Controller_InnovationAndVAP();
            system.debug(c.calendarData);
            System.assertEquals(2, c.calendarData.get(ts.baseDate).get('Innovation').size());
            
        }
        Test.StopTest();
            
    }
    
    static testmethod void testGetDataForProperAccount2(){
        PageReference pageRef = Page.InnovationAndVAP;
        Test.setCurrentPage(pageRef);
        
        TestSettings ts = new  TestSettings();
        ts.insertTwoBrands();
        ts.insertTwoCalendars();
        Test_Helper.testInsertAccountBrand(ts.account.id, ts.brand1.id);
        Test_Helper.testInsertCalendarBrand(ts.calendar1.id, ts.brand1.id);
        Test_Helper.testInsertCalendarBrand(ts.calendar2.id, ts.brand2.id);
        
        Controller_InnovationAndVAP c;
        Test.StartTest();
        System.RunAs(ts.user){
            c = new Controller_InnovationAndVAP();
            system.debug(c.calendarData);
            System.assertEquals(1, c.calendarData.get(ts.baseDate).get('Innovation').size());
            
        }
        Test.StopTest();
    }
    
    static testmethod void testGetDataForProperDates(){
        PageReference pageRef = Page.InnovationAndVAP;
        Test.setCurrentPage(pageRef);
        
        TestSettings ts = new  TestSettings();
        ts.prepareCalendarList();
        
        Controller_InnovationAndVAP c;
        Test.StartTest();
        System.RunAs(ts.user){
            c = new Controller_InnovationAndVAP();
            System.assertEquals(1, c.calendarData.get(ts.baseDate).get('Innovation').size());
            System.assertEquals(null, c.calendarData.get(ts.nextMonthBase));
            System.assertEquals(null, c.calendarData.get(ts.prevMonthBase));
            c.nextMonth();
            System.assertEquals(2, c.calendarData.get(ts.nextMonthBase).get('Innovation').size());
            System.assertEquals(null, c.calendarData.get(ts.baseDate));
            System.assertEquals(null, c.calendarData.get(ts.prevMonthBase));
            c.previousMonth();
            System.assertEquals(1, c.calendarData.get(ts.baseDate).get('Innovation').size());
            c.previousMonth();
            System.assertEquals(3, c.calendarData.get(ts.prevMonthBase).get('Innovation').size());
            System.assertEquals(null, c.calendarData.get(ts.baseDate));
            System.assertEquals(null, c.calendarData.get(ts.nextMonthBase));

            
        }
        Test.StopTest();
    }
    static testmethod void testGetDataForProperDatesQ(){
        PageReference pageRef = Page.InnovationAndVAP;
        Test.setCurrentPage(pageRef);
        
        TestSettings ts = new  TestSettings();
        ts.prepareCalendarListQ();
        
        Controller_InnovationAndVAP c;
        Test.StartTest();
        System.RunAs(ts.user){
            c = new Controller_InnovationAndVAP();
            c.timePeriod = 3;
            c.refreshContent();

            System.assertEquals(3, c.calendarData.get(ts.prevMonthBase).get('Innovation').size());
            System.assertEquals(1, c.calendarData.get(ts.baseDate).get('Innovation').size());
            System.assertEquals(2, c.calendarData.get(ts.nextMonthBase).get('Innovation').size());
            
        }
        Test.StopTest();
    }
    
    static testmethod void testGetDataForProperSalesChannel(){
        PageReference pageRef = Page.InnovationAndVAP;
        Test.setCurrentPage(pageRef);
        
        TestSettings ts = new  TestSettings();
        ts.prepareCalendarList2();
        
        Controller_InnovationAndVAP c;
        Test.StartTest();
        System.RunAs(ts.user){
            c = new Controller_InnovationAndVAP();
            System.assertEquals(1, c.calendarData.get(ts.baseDate).get('Sustainovation').size());
            System.assertEquals(2, c.calendarData.get(ts.baseDate).get('Innovation').size());
            System.assertEquals(3, c.calendarData.get(ts.baseDate).get('VAP').size());
            c.salesDriver = 'Innovation';
            c.selectSalesDriver();
            System.assertEquals(null, c.calendarData.get(ts.baseDate).get('Sustainovation'));
            System.assertEquals(2, c.calendarData.get(ts.baseDate).get('Innovation').size());
            System.assertEquals(null, c.calendarData.get(ts.baseDate).get('VAP'));
            c.salesDriver = 'VAP';
            c.selectSalesDriver();
            System.assertEquals(null, c.calendarData.get(ts.baseDate).get('Sustainovation'));
            System.assertEquals(null, c.calendarData.get(ts.baseDate).get('Innovation'));
            System.assertEquals(3, c.calendarData.get(ts.baseDate).get('VAP').size());
        }
        Test.StopTest();
    }
    
    static testmethod void testGetTimePerioda(){
        PageReference pageRef = Page.InnovationAndVAP;
        Test.setCurrentPage(pageRef);
        
        TestSettings ts = new  TestSettings();
        ts.insertTwoBrands();
        ts.insertTwoCalendars();
        Test_Helper.testInsertAccountBrand(ts.account.id, ts.brand1.id);
        Test_Helper.testInsertCalendarBrand(ts.calendar1.id, ts.brand1.id);
        Test_Helper.testInsertCalendarBrand(ts.calendar2.id, ts.brand2.id);
        
        Controller_InnovationAndVAP c;
        Test.StartTest();
        System.RunAs(ts.user){
            c = new Controller_InnovationAndVAP();
            List<SelectOption> options = c.getTimePeriods();
            System.assertEquals(4, options.size());
        }
        Test.StopTest();
    }
}