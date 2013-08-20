@isTest
private class Test_Controller_ShareReporting {

    static testMethod void testController_ShareReporting() {
    	Account acc = new Account();
    	acc.Name = 'test account';
    	insert acc;
    	
    	NABCA_Category__c nc = new NABCA_Category__c();
    	nc.NABCA_Major_Category_Description__c = 'nc';
    	nc.NABCA_Major_Category_Code__c = 'code';
    	insert nc;
    	
    	NABCA_Vendor__c nv = new NABCA_Vendor__c();
    	nv.NABCA_Vendor_Description__c = 'nv';
    	nv.NABCA_Vendor_Code__c = 'code';
    	insert nv;
    	
    	NABCA_Brand__c brand = new NABCA_Brand__c();
    	brand.NABCA_Category__c = nc.Id;
    	brand.NABCA_Vendor__c = nv.Id;
    	brand.Common_Description__c = 'desc';
    	brand.NABCA_Size_Description__c = 'big';
    	brand.Brand_Composite_Key__c = 'key';
    	insert brand;
    	
    	NABCA_Sales_Data__c sd = new NABCA_Sales_Data__c();
    	sd.Account__c = acc.Id;
    	sd.Brand__c = brand.Id;
    	sd.Month_End_Date__c = Date.today();
    	sd.Sale_Composite_Key__c = '12345';
    	sd.Month36_9L_Volume__c = 100;
    	sd.Month36_ShelfDollar_Volume__c = 100;
    	sd.Month24_9L_Volume__c = 100;
    	sd.Month24_ShelfDollar_Volume__c = 100;
    	insert sd;
    	
    	Test.startTest();
    	
        Controller_ShareReporting cont = new Controller_ShareReporting(new ApexPages.StandardController(acc));
    
    	cont.getGroupByOptions();
    	cont.getSelectedRecordsOptions();
    	cont.getStartDateOptions();
    	cont.getBeverageTypeOptions();
    	cont.getDateRangeOptions();
    	cont.getMeasurementOptions();
    	cont.getTableRowList();
    	cont.measurementType = cont.VOLUME;
    	cont.getData();
    	cont.measurementType = cont.SHELF_DOLLAR;
    	cont.getData();
    	cont.dateRange = cont.LAST12;
    	cont.beverageType = cont.SPIRIT;
    	cont.selectedGroup = cont.CATEGORY;
    	cont.measurementType = cont.VOLUME;
    	cont.getData();
    	cont.fetchInternalSalesData(cont.selectedGroup, cont.selectedMonth, cont.dateRange, cont.TOPTEN, cont.ALL, cont.VOLUME);
    	cont.measurementType = cont.SHELF_DOLLAR;
    	cont.getData();
    	cont.dateRange = cont.CURRENTFISCAL;
    	cont.beverageType = cont.WINE;
    	cont.measurementType = cont.VOLUME;
    	cont.getData();
    	cont.measurementType = cont.SHELF_DOLLAR;
    	cont.getData();
    	
    	cont.getCurrencyFromString('3.00');
    	cont.getCurrencyFromString('3.0');
    	cont.getCurrencyFromString('3');
    	cont.sortDown(cont.topTenTableRowList);
    	cont.sortUp(cont.topTenTableRowList);
    	cont.setBevTypeToSpirits();
    }
}