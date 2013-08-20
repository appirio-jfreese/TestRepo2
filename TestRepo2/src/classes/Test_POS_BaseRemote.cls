@isTest
private class Test_POS_BaseRemote {

     static testMethod void testController1() {
     	User us = Test_Helper.generateTestUser('12121', true, 'System Administrator') ;
     	Account acc = Test_Helper.testInsertAccount('Test Account');
     	Account_Member__c acm = new Account_Member__c(User__c = us.id, Account__c=acc.id, Default__c = true,Active__c = true);
     	insert acm ;
     	Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
     	Brand__c br = Test_Helper.testInsertBrand('Portfolio');
     	
     	Program__c prg = POS_TestDataUtil.createProgram(br.Id, ow.Id);
     	Item__c itm = POS_TestDataUtil.createItem(prg);
     	
     	POS_BaseRemote.searchForBrand(us.id,ow.id);
     	POS_BaseRemote.searchForProgram(br.id,ow.id);
     	POS_BaseRemote.searchForProgramItemAllocation(itm.id,ow.id);
     	POS_BaseRemote.searchForItemsOnAllocation(us.Id,ow.Id);
     	POS_BaseRemote.searchForDistributorsItemAllocation(itm.id,us.id);
     	POS_BaseRemote.searchForDistributors(br.id, us.id);
     	POS_BaseRemote.searchForGeographyItemAllocation(itm.id,us.id);
     	POS_BaseRemote.searchForGeography(br.id,us.id);
     }
 }