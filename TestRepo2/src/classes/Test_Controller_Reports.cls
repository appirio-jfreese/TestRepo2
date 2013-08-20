@isTest
public class Test_Controller_Reports{
	/* This class is no longer used -- kept for archival purposes
    private static Account acc;
    static Final String CURRENTMONTH='Current Month';
    static Final String TOPTEN='Top 10';
    static Final String BOTTOMTEN='Bottom 10';
    static Final String LAST12='Last 12 Months';
    static Final String CURRENTFISCAL='Current Fiscal Year';
    static Final String ALL='All';
    static Final String SPIRITS='Spirit';
    static Final String WINES='Wine';
    static Final String FILTERDOLLAR = 'Shelf Dollar';
    static Final String FILTERVOLUME = 'Volume';
    static{
        CreateDataForTest();
    }
    public static void CreateDataForTest(){
        Territory__c terr1 = Test_RecordUtil.newTerritory('terr1');
        insert terr1;
        
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accRTIdsByName = d.getRecordTypeInfosByName();
        
        acc= Test_RecordUtil.newAccount('Test Account',terr1.id,accRTIdsByName.get('On Premise').getRecordTypeId());
        insert acc;
        
        List<NABCA_Vendor__c> vendorList = Test_RecordUtil.getVendors(10);
        
        List<NABCA_Category__c> catList = Test_RecordUtil.getCategories(10);
        
        List<NABCA_Brand__c> brandList = Test_RecordUtil.getBrands(10,vendorList,catList);        
        
        List<NABCA_Sales_Data__c> dataList = Test_RecordUtil.getSalesData(10,brandList,acc);
        
    }
    
    public static testMethod void testVendorShareReporting(){
        Test.StartTest();
            
            ApexPages.StandardController sc = new ApexPages.standardController(acc);
            
            Controller_VendorShareReporting ext = new Controller_VendorShareReporting(sc);
            system.assertEquals(ext.totalPercentChange, 48.00);
            system.assertEquals(ext.totalShare, 100.00);
            system.assertEquals(ext.groupedquerytotal, '3700.00');
            List<SelectOption> itemList = ext.getItems();
            List<SelectOption> WineList = ext.getSpiritsnWines();
            List<SelectOption> recordsList = ext.getRecordsItems();
            List<SelectOption> dollarList = ext.getDollarVolumeItems();
            
            for(Integer i = 0; i < itemList.size(); i++){
                for(Integer j = 0; j < WineList.size(); j++){
                    for(Integer k = 0; k < recordsList.size(); k++){
                        for(Integer l = 0; l < dollarList.size(); l++){
                            ext.prepareSalesDataQuery(recordsList[k].getValue(),itemList[i].getValue(),WineList[j].getValue(),dollarList[l].getValue());
                            ext.SelectedType = recordsList[k].getValue();
                            ext.selectedValue = itemList[i].getValue();
                            ext.selectedFilter = WineList[j].getValue();
                            ext.SelectedDollar = dollarList[l].getValue();
                            ext.getSelectedVolume();
                            ext.getBrandRowlist();
                        }
                    }
                }   
            }
            
        Test.stopTest();        
    }
    
    public static testMethod void testCategoryShareReporting(){
        Test.StartTest();
            
            ApexPages.StandardController sc = new ApexPages.standardController(acc);
            
            Controller_CategoryShareReporting ext = new Controller_CategoryShareReporting(sc);
            system.assertEquals(ext.totalPercentChange, 48.00);
            system.assertEquals(ext.totalShare, 100.00);
            system.assertEquals(ext.groupedquerytotal, '3700.00');
            List<SelectOption> itemList = ext.getItems();
            List<SelectOption> WineList = ext.getSpiritsnWines();
            List<SelectOption> recordsList = ext.getRecordsItems();
            List<SelectOption> dollarList = ext.getDollarVolumeItems();
            
            for(Integer i = 0; i < itemList.size(); i++){
                for(Integer j = 0; j < WineList.size(); j++){
                    for(Integer k = 0; k < recordsList.size(); k++){
                        for(Integer l = 0; l < dollarList.size(); l++){
                            ext.prepareSalesDataQuery(recordsList[k].getValue(),itemList[i].getValue(),WineList[j].getValue(),dollarList[l].getValue());
                            ext.SelectedType = recordsList[k].getValue();
                            ext.selectedValue = itemList[i].getValue();
                            ext.selectedFilter = WineList[j].getValue();
                            ext.SelectedDollar = dollarList[l].getValue();
                            ext.getSelectedVolume();
                            ext.getBrandRowlist();
                        }
                    }
                }   
            }
            
        Test.stopTest();        
    }
    
    public static testMethod void testTopBottomBrands(){
        Test.StartTest();
            
            ApexPages.StandardController sc = new ApexPages.standardController(acc);            
            Controller_TopBottomBrands ext = new Controller_TopBottomBrands(sc);
            List<SelectOption> itemList = ext.getItems();
            List<SelectOption> WineList = ext.getSpiritsnWines();
            List<SelectOption> recordsList = ext.getRecordsItems();
            List<SelectOption> dollarList = ext.getDollarVolumeItems();
            system.assertEquals(ext.totalPercentChange, 48.00);
            system.assertEquals(ext.totalShare, 100.00);
            system.assertEquals(ext.groupedquerytotal, '3700.00');
            system.assertEquals(ext.totalLastYearShare, 2500.000);
            
            for(Integer i = 0; i < itemList.size(); i++){
                for(Integer j = 0; j < WineList.size(); j++){
                    for(Integer k = 0; k < recordsList.size(); k++){
                        for(Integer l = 0; l < dollarList.size(); l++){
                            ext.prepareSalesDataQuery(recordsList[k].getValue(),itemList[i].getValue(),WineList[j].getValue(),dollarList[l].getValue());
                            ext.SelectedType = recordsList[k].getValue();
                            ext.selectedValue = itemList[i].getValue();
                            ext.selectedFilter = WineList[j].getValue();
                            ext.SelectedDollar = dollarList[l].getValue();
                            ext.getSelectedVolume();
                            ext.getBrandRowlist();
                        }
                    }
                }   
            }
            
        Test.stopTest();
    }       */
}