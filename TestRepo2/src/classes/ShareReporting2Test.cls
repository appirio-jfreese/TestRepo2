@isTest
private class ShareReporting2Test {

    static testMethod void testShareReporting2() {
    	Account acc = new Account();
    	acc.Name = 'Test Account';
    	insert acc;
    	
    	NABCA_Category__c cat = new NABCA_Category__c();
    	cat.NABCA_Major_Category_Description__c = 'test description';
    	cat.NABCA_Major_Category_Code__c = 'test code';
    	insert cat;
    	
    	NABCA_Brand__c brand = new NABCA_Brand__c();
    	brand.NABCA_Category__c = cat.Id;
    	brand.Brand_Composite_Key__c = 'key';
    	brand.NABCA_Beverage_Type_Description__c = 'SPIRIT';
    	insert brand;
    	
    	NABCA_Brand__c brand2 = new NABCA_Brand__c();
    	brand2.NABCA_Category__c = cat.Id;
    	brand2.Brand_Composite_Key__c = 'key2';
    	brand2.NABCA_Beverage_Type_Description__c = 'WINE';
    	insert brand2;
    	
    	NABCA_Sales_Data__c nsd = new NABCA_Sales_Data__c();
    	nsd.Account__c = acc.Id;
    	nsd.Brand__c = brand.Id;
    	nsd.Sale_Composite_Key__c = 'key';
    	nsd.Month_End_Date__c = Date.today();
    	nsd.Month36_9L_Volume__c = 2;
    	nsd.Month35_9L_Volume__c = 2;
    	nsd.Month24_9L_Volume__c = 1;
    	nsd.Month23_9L_Volume__c = 0;
    	nsd.Month36_ShelfDollar_Volume__c = 2;
    	nsd.Month35_ShelfDollar_Volume__c = 2;
    	nsd.Month24_ShelfDollar_Volume__c = 1;
    	nsd.Month23_ShelfDollar_Volume__c = 0;
    	insert nsd;
    	
    	NABCA_Sales_Data__c nsd2 = new NABCA_Sales_Data__c();
    	nsd2.Account__c = acc.Id;
    	nsd2.Brand__c = brand2.Id;
    	nsd2.Sale_Composite_Key__c = 'key2';
    	nsd2.Month_End_Date__c = Date.today();
    	nsd2.Month36_9L_Volume__c = 2;
    	nsd2.Month35_9L_Volume__c = 2;
    	nsd2.Month24_9L_Volume__c = 1;
    	nsd2.Month23_9L_Volume__c = 0;
    	nsd2.Month36_ShelfDollar_Volume__c = 2;
    	nsd2.Month35_ShelfDollar_Volume__c = 2;
    	nsd2.Month24_ShelfDollar_Volume__c = 1;
    	nsd2.Month23_ShelfDollar_Volume__c = 0;
    	insert nsd2;
    	
    	Test.startTest();
    	
    	ShareReporting2Controller cont = new ShareReporting2Controller(new ApexPages.StandardController(acc));
    	cont.selectedRowLabel = 'test description';
    	cont.expandRow();
    	cont.collapseRow();
    	cont.sortData();
    	/*cont.sortField = 'label';
    	cont.sortData();
    	cont.sortField = 'valueChange';
    	cont.sortData();
    	cont.sortField = 'share';
    	cont.sortData();
    	cont.sortField = 'shareChange';
    	cont.sortData();
    	cont.sortData();
    	cont.sortData();*/
    	cont.filterBySel = 'Vendor';
    	cont.prepareQueryFields();
    	cont.filterBySel = 'Category';
    	cont.monthSel = '1';
    	cont.prepareQueryFields();
    	cont.dateRangeSel = 'Current Fiscal Year';
    	cont.prepareQueryFields();
    	cont.dateRangeSel = 'Last 12 Months';
    	cont.prepareQueryFields();
    	cont.valueSel = 'Shelf Dollar';
    	cont.dateRangeSel = 'Current Month';
    	cont.prepareQueryFields();
    	cont.dateRangeSel = 'Current Fiscal Year';
    	cont.typeSel = 'Spirits';
    	cont.prepareQueryFields();
    	cont.dateRangeSel = 'Last 12 Months';
    	cont.typeSel = 'Wines';
    	cont.prepareQueryFields();
    	
    	Test.stopTest();
    	
    }
}