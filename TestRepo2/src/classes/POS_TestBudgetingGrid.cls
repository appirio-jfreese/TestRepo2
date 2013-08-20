public with sharing class POS_TestBudgetingGrid {
@isTest
	public static void testOrderHistory () {
		//Profile p = [select id from profile where name='System Administrator'];
        /*
		User u = [select Id from User where Id='005Z0000000X1Xn'];
		
		
		
		
		System.runAs(u) {
			PageReference pageRef = Page.HomePage;
        	Test.setCurrentPage(pageRef);
        	String owId = 'a12Z000000060xCIAQ';
        	List<Budget__c> orderwindowBudgets	= [SELECT Id, Account__c, Account__r.Name, Amount__c, Brand__c, Brand__r.Name, Budgeter__c, Budgeter__r.Name, Channel__c, 
        	Item__c, Item_Allocation_Quantity__c, Sub_Allocated_Amount__c, Sub_Allocated_Item_Quantity__c,
        	LastModifiedById, LastModifiedDate, Organizational_Unit__c, Parent__c, Program__c, Program__r.Name,
        	Shopper__c, Shopper__r.Name, (SELECT Id, Account__c, Account__r.Name, Amount__c, Brand__c, Brand__r.Name, Budgeter__c, Budgeter__r.Name, 
        	Channel__c, Item__c, Item_Allocation_Quantity__c, Sub_Allocated_Amount__c, Sub_Allocated_Item_Quantity__c, LastModifiedById, LastModifiedDate, Organizational_Unit__c, Parent__c, Program__c, Program__r.Name,
        	Shopper__c, Shopper__r.Name FROM Budgets__r order by Shopper__r.Name) FROM Budget__c where Order_Window__c=:owId and 
        								Parent__r.Shopper__c != :UserInfo.getUserId() and
        									(Shopper__c=:UserInfo.getUserId() or 
        									 Budgeter__c=:UserInfo.getUserId() or Budget_Creator__c=:UserInfo.getUserId()) and
        									(Parent__r.Shopper__c != :UserInfo.getUserId() and Parent__r.Budgeter__c != :UserInfo.getUserId() and
        									 Parent__r.Budget_Creator__c != :UserInfo.getUserId())
        									order by Shopper__r.Name];
        	System.debug('BUDGETS: '+orderwindowBudgets);
        	
		}
		*/
	}
}