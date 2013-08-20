/***************************************************************************************************************************************
Name – VendorShareReporting

Purpose – Vendor Share Reporting - Top 10: The system must display volume and share information by sku on the Account Detail page for the current month(default) 
and then have the ability to filter specific criteria.

Rally User Story and Task – (US658)


Version US     Author              Date            Details 
------------------------------------------------------------------------------------------------------------------------------
1.0     US658   Siddhesh Kabe          06/07/2012      Created class and page for US658.
2.0     US658   Siddhesh Kabe          26/07/2012      Rewrote the class with new fields.
3.0     US658   Siddhesh Kabe          16/08/2012      Debugging and change in object model.
4.0             Ritika Dhandia         29/11/2012      calculateShare calls from DiageoUtils
****************************************************************************************************************************************/

public with sharing class Controller_VendorShareReporting {
/* This class is no longer used -- kept for archival purposes
    Final String CURRENTMONTH='Current Month';
    Final String TOPTEN='Top 10';
    Final String BOTTOMTEN='Bottom 10';
    Final String LAST12='Last 12 Months';
    Final String CURRENTFISCAL='Current Fiscal Year';
    Final String ALL='All';
    Final String SPIRITS='Spirit';
    Final String WINES='Wine';
    Final String FILTERDOLLAR = 'Shelf Dollar';
    Final String FILTERVOLUME = 'Volume';
    Integer maxVendors = 10;
    Final Map<integer,String> monthMap = new Map<integer,String>{1 => 'Jan',2 => 'Feb',3 => 'Mar',4 => 'Apr',5 => 'May',6 => 'Jun',7 => 'July',8 => 'Aug',9 => 'Sept',10 => 'Oct',11 => 'Nov',12 => 'Dec'};
    Public Boolean ShowList{get;set;}
    Map<id,BrandRow> BrandRowMap;
    
    Public Set<id> internalBrandSetId;
    Public string SelectedValue{get;set;}
    Public string SelectedType {get;set;}
    Public Decimal totalVolume {get;set;}
    Public String volumeHeader{get;set;}
    Public String pointsHeader{get;set;}
    Public Decimal totalPercentChange{get;set;}
    Public Decimal totalShare{get;set;}
    Public Decimal totalPercentChangeShare{get;set;}
    Public String SelectedFilter{get;set;}
    Public String SelectedDollar{get;set;}
    Public Decimal totalLastYearShare{get;set;}
    Public List<BrandRow> Top10BrandRowList;
    Public date EndDate{get;set;}
    Public string monthYear{get;set;}
    private decimal sum1=0;
    private decimal sum2=0;
    AggregateResult[] groupedResults;
    public string groupedquerytotal{get;private set;}

    List<NABCA_Sales_Data__c> listInternalSalesData;
    Account accountRecord;
    Final String top10=' DESC Limit 10';
    Final String Bottom10=' ASC Limit 10';
    Final String ORDERBY=' Order By ';
   
    public Controller_VendorShareReporting(ApexPages.StandardController controller) {
        accountRecord=(Account)Controller.getRecord();
        selectedValue=TOPTEN;
        fetchInternalSalesdata(CURRENTMONTH, TOPTEN,ALL,FILTERVOLUME);
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(TOPTEN,TOPTEN));
            options.add(new SelectOption(BOTTOMTEN,BOTTOMTEN));
        return options;
    }
    
    public List<SelectOption> getSpiritsnWines(){
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(ALL,ALL));
            options.add(new SelectOption(SPIRITS,SPIRITS));
            options.add(new SelectOption(WINES,WINES));
        return options;
    }
    
    public List<SelectOption> getRecordsItems() {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(CURRENTMONTH,CURRENTMONTH));
            options.add(new SelectOption(CURRENTFISCAL,CURRENTFISCAL)); 
            options.add(new SelectOption(LAST12,LAST12));
        return options;
    }

     public List<SelectOption> getDollarVolumeItems() {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(FILTERVOLUME,FILTERVOLUME));
            options.add(new SelectOption(FILTERDOLLAR,FILTERDOLLAR)); 
        return options;
    }
    
    public string prepareSalesDataQuery(string optionSelected, string typeofData, string filter, string SelectedDollar){
         System.debug(optionSelected+'&&&&&&&'+typeofData);
         string query;
         string part1Query='SELECT Id,name,Brand__c,Month_End_Date__c, Brand__r.NABCA_Vendor__r.NABCA_Vendor_Description__c, Brand__r.NABCA_Beverage_Type_Description__c, Brand__r.Id,Brand__r.Common_Code__c, Brand__r.Common_Description__c,';
         string part2Query=' FROM NABCA_Sales_Data__c where Account__c =\''+accountRecord.id+'\'';
         String filterBySpirits=' And Brand__r.NABCA_Beverage_Type_Description__c = \''+filter+'\'';
    
         String ShelfDollarvolume='month36_9l_volume__c,month24_9l_volume__c';
         String Last12Months='Last_12_Months_Volume__c, Percent_Change_in_Volume__c,Last_year_volume_data__c';
         String Fiscal='Volume_For_last_Fiscal_Year__c, Volume_for_Fiscal_Year__c';

         String OrderByShelfDollarvolume='brand__r.Nabca_Vendor__r.Nabca_Vendor_Description__c';
         String OrderByLast12Months='brand__r.Nabca_Vendor__r.Nabca_Vendor_Description__c';
         String OrderByFiscal='brand__r.Nabca_Vendor__r.Nabca_Vendor_Description__c';

         // this was added for dollar/volume picklist
      
         String OrderShelfDollarVolume='Month36_ShelfDollar_Volume__c';
         String OrderByLast12MonthsVolume='Last12_Months_Dollar_value__c';
         String OrderByFiscalVolume='ShelfDollar_for_Fiscal_Year__c';

         String ShelfDollarVolumedv='Month36_ShelfDollar_Volume__c,month24_ShelfDollar_Volume__c';
         String Last12MonthsDollarVolume='Last12_Months_Dollar_value__c,Percent_Change_in_Dollar__c,Last_year_Shelfdollar_data__c';
         String FiscalDollarVolume='ShelfDollar_for_Fiscal_Year__c,Shelfdollar_For_last_Fiscal_Year__c';

         
         query=part1query;
         if(filter=='ALL'){
             if(optionSelected==CURRENTMONTH && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                 query=query+ShelfDollarvolume+part2Query;
             }else if (optionSelected==LAST12 && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                 query=query+Last12Months+part2Query;
             }else if(optionSelected== CURRENTFISCAL && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                  query=query+Fiscal+part2Query;
             }else if(optionSelected==CURRENTMONTH && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                 query=query+ShelfDollarvolume+part2Query;
             }else if (optionSelected==LAST12 && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                 query=query+Last12Months+part2Query;
             }else if(optionSelected== CURRENTFISCAL && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                  query=query+Fiscal+part2Query;
             }

             else if(optionSelected==CURRENTMONTH && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+ShelfDollarVolumedv+part2Query;
             }else if (optionSelected==LAST12 && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+Last12MonthsDollarVolume+part2Query;
             }else if(optionSelected== CURRENTFISCAL && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                  query=query+FiscalDollarVolume+part2Query;
             }else if(optionSelected==CURRENTMONTH && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+ShelfDollarVolumedv+part2Query;
             }else if (optionSelected==LAST12 && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+Last12MonthsDollarVolume+part2Query;
             }else if(optionSelected== CURRENTFISCAL && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                  query=query+FiscalDollarVolume+part2Query;
             }

         }else{
             if(optionSelected==CURRENTMONTH && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                 query=query+ShelfDollarvolume+part2Query+filterBySpirits;
             }else if (optionSelected==LAST12 && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                 query=query+Last12Months+part2Query+filterBySpirits;
             }else if(optionSelected== CURRENTFISCAL && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                  query=query+Fiscal+part2Query+filterBySpirits;
             }else if(optionSelected==CURRENTMONTH && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                 query=query+ShelfDollarvolume+part2Query+filterBySpirits;
             }else if (optionSelected==LAST12 && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                 query=query+Last12Months+part2Query+filterBySpirits;
             }else if(optionSelected== CURRENTFISCAL && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                  query=query+Fiscal+part2Query+filterBySpirits;
             }

             else if(optionSelected==CURRENTMONTH && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+ShelfDollarVolumedv+part2Query+filterBySpirits;
             }else if (optionSelected==LAST12 && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+Last12MonthsDollarVolume+part2Query+filterBySpirits;
             }else if(optionSelected== CURRENTFISCAL && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                  query=query+FiscalDollarVolume+part2Query+filterBySpirits;
             }else if(optionSelected==CURRENTMONTH && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+ShelfDollarVolumedv+part2Query+filterBySpirits;
             }else if (optionSelected==LAST12 && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+Last12MonthsDollarVolume+part2Query+filterBySpirits;
             }else if(optionSelected== CURRENTFISCAL && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                  query=query+FiscalDollarVolume+part2Query+filterBySpirits;
             }

         }
         System.debug(query+'*******************');
         return query;
    }
    
    public class BrandRow{
        Public ID brandid;
        Public String brandName{get;set;}
        Public Decimal volume{get;set;}
        Public Decimal share{get;set;}   
        Public Decimal perCentChange {get;set;}
        Public Decimal PercentChangeShare{get;set;}
        Public Decimal LastYearShare {get;set;}
        Public Decimal LastYearVolume{get;set;}
        Public string shelfdollardata{get;set;}
        Public string shelfdollar{get;set;}
        
        
        
      }
    
    void fetchInternalSalesdata(string optionSelected, string typeofData, string selectedFilter,string SelectedDollar){
        totalVolume=0;
        totalShare=0;
        totalPercentChange=0;
        totalPercentChangeShare=0;
        totalLastYearShare = 0;
        internalBrandSetId=new Set<id>();
        
        Set<id> IBCSetid= new Set<id>();
        listInternalSalesData= new List<NABCA_Sales_Data__c>();
        BrandRowMap= new Map<id,BrandRow>();
        try{
        listInternalSalesData=database.query(prepareSalesDataQuery(optionSelected,typeofData,selectedFilter,SelectedDollar));
        
        if(optionSelected==CURRENTMONTH && SelectedDollar==FILTERVOLUME && selectedFilter==ALL){
        AggregateResult[] groupedResults =[select sum(month36_9L_Volume__c) currenttotal ,sum(month24_9L_Volume__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal');
        totalvolume = sum1; 
        groupedquerytotal = string.valueof(sum1.setScale(2));
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
         
        else if(optionSelected==LAST12 && SelectedDollar==FILTERVOLUME && selectedFilter==ALL){
        AggregateResult[] groupedResults =[select sum(Last_12_Months_Volume__c) currenttotal ,sum(Last_year_volume_data__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        
        else if(optionSelected==CURRENTFISCAL && SelectedDollar==FILTERVOLUME && selectedFilter==ALL){
        AggregateResult[] groupedResults =[select sum(Volume_for_Fiscal_Year__c) currenttotal ,sum(Volume_For_last_Fiscal_Year__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        
        else if(optionSelected==CURRENTMONTH && SelectedDollar==FILTERDOLLAR && selectedFilter==ALL){
        AggregateResult[] groupedResults =[select sum(Month36_ShelfDollar_Volume__c) currenttotal ,sum(month24_ShelfDollar_Volume__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = '$' + sum1.format();
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
         
        else if(optionSelected==LAST12 && SelectedDollar==FILTERDOLLAR && selectedFilter==ALL){
        AggregateResult[] groupedResults =[select sum(Last12_Months_Dollar_value__c) currenttotal ,sum(Last_year_Shelfdollar_data__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = '$' + sum1.format();
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        
        else if(optionSelected==CURRENTFISCAL && SelectedDollar==FILTERDOLLAR && selectedFilter==ALL){
        AggregateResult[] groupedResults =[select sum(ShelfDollar_for_Fiscal_Year__c) currenttotal ,sum(Shelfdollar_For_last_Fiscal_Year__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal');
        totalvolume = sum1;
        groupedquerytotal = '$' + sum1.format(); 
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        
        else if(optionSelected==CURRENTMONTH && SelectedDollar==FILTERVOLUME && selectedFilter==SPIRITS){
        AggregateResult[] groupedResults =[select sum(month36_9L_Volume__c) currenttotal ,sum(month24_9L_Volume__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:SPIRITS group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        
        else if(optionSelected==LAST12 && SelectedDollar==FILTERVOLUME && selectedFilter==SPIRITS){
        AggregateResult[] groupedResults =[select sum(Last_12_Months_Volume__c) currenttotal ,sum(Last_year_volume_data__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:SPIRITS group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1; 
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);      
        }
        
        else if(optionSelected==CURRENTFISCAL && SelectedDollar==FILTERVOLUME && selectedFilter==SPIRITS){
        AggregateResult[] groupedResults =[select sum(Volume_for_Fiscal_Year__c) currenttotal ,sum(Volume_For_last_Fiscal_Year__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:SPIRITS group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        
        else if(optionSelected==CURRENTMONTH && SelectedDollar==FILTERVOLUME && selectedFilter==WINES){
        AggregateResult[] groupedResults =[select sum(month36_9L_Volume__c) currenttotal ,sum(month24_9L_Volume__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:WINES group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        
        else if(optionSelected==LAST12 && SelectedDollar==FILTERVOLUME && selectedFilter==WINES){
        AggregateResult[] groupedResults =[select sum(Last_12_Months_Volume__c) currenttotal ,sum(Last_year_volume_data__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:WINES group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal');
        totalvolume = sum1; 
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);        
        }
        
        else if(optionSelected==CURRENTFISCAL && SelectedDollar==FILTERVOLUME && selectedFilter==WINES){
        AggregateResult[] groupedResults =[select sum(Volume_for_Fiscal_Year__c) currenttotal ,sum(Volume_For_last_Fiscal_Year__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:WINES group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal');
        totalvolume = sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);    
        }
        else if(optionSelected==CURRENTMONTH && SelectedDollar==FILTERDOLLAR && selectedFilter==SPIRITS){
        AggregateResult[] groupedResults =[select sum(Month36_ShelfDollar_Volume__c) currenttotal ,sum(month24_ShelfDollar_Volume__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:WINES group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = '$' + sum1.format();
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
         
        else if(optionSelected==LAST12 && SelectedDollar==FILTERDOLLAR && selectedFilter==SPIRITS){
        AggregateResult[] groupedResults =[select sum(Last12_Months_Dollar_value__c) currenttotal ,sum(Last_year_Shelfdollar_data__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:SPIRITS group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = '$' + sum1.format();
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        
        else if(optionSelected==CURRENTFISCAL && SelectedDollar==FILTERDOLLAR && selectedFilter==SPIRITS){
        AggregateResult[] groupedResults =[select sum(ShelfDollar_for_Fiscal_Year__c) currenttotal ,sum(Shelfdollar_For_last_Fiscal_Year__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:SPIRITS group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal');
        totalvolume = sum1;
        groupedquerytotal = '$' + sum1.format(); 
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        else if(optionSelected==CURRENTMONTH && SelectedDollar==FILTERDOLLAR && selectedFilter==WINES){
        AggregateResult[] groupedResults =[select sum(Month36_ShelfDollar_Volume__c) currenttotal ,sum(month24_ShelfDollar_Volume__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:WINES group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = '$' + sum1.format();
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
         
        else if(optionSelected==LAST12 && SelectedDollar==FILTERDOLLAR && selectedFilter==WINES){
        AggregateResult[] groupedResults =[select sum(Last12_Months_Dollar_value__c) currenttotal ,sum(Last_year_Shelfdollar_data__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:WINES group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        totalvolume = sum1;
        groupedquerytotal = '$' + sum1.format();
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        
        else if(optionSelected==CURRENTFISCAL && SelectedDollar==FILTERDOLLAR && selectedFilter==WINES){
        AggregateResult[] groupedResults =[select sum(ShelfDollar_for_Fiscal_Year__c) currenttotal ,sum(Shelfdollar_For_last_Fiscal_Year__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:WINES group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal');
        totalvolume = sum1; 
        groupedquerytotal = '$' + sum1.format();
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        }
        
        }// End of try block
        catch(Exception e){
                e.getmessage();
        }
        //totalPercentChange=((sum1-sum2)/sum2)*100;
        
        //totalvolume = sum1;
        
        //totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
        for(NABCA_Sales_Data__c ISD: listInternalSalesData){
               EndDate = ISD.Month_End_Date__c;
               //monthYear =  EndDate.month().format() + ' ' + EndDate.year().format().replace(',','');
               monthYear =  monthmap.get(EndDate.month()) + ' ' + EndDate.year().format().replace(',','');
               BrandRow BRRecord;
               IBCSetid.add(ISD.Brand__r.NABCA_Vendor__c);
               if(BrandRowMap.get(ISD.Brand__r.NABCA_Vendor__c)==null){
                   
                   BRRecord= new BrandRow();
                   BRRecord.volume=0;
                   BRRecord.PerCentChange=0;
                   BRRecord.LastYearVolume=0;
                   
                   
                   
                 }
               else{
                   BRRecord=BrandRowMap.get(ISD.Brand__r.NABCA_Vendor__c);
               }
                 
                
                BRRecord.brandid= ISD.Brand__r.NABCA_Vendor__c;
                BRRecord.BrandName=ISD.Brand__r.NABCA_Vendor__r.NABCA_Vendor_Description__c;

         if(SelectedDollar== FILTERVOLUME){                 
            
            if(optionSelected==LAST12){
                if(ISD.Last_12_Months_Volume__c != null)
                BRRecord.Volume+=ISD.Last_12_Months_Volume__c;
                
                if(ISD.Percent_Change_in_Volume__c != null)
                BRRecord.PerCentChange+=ISD.Percent_Change_in_Volume__c;
                
                 if(ISD.Last_year_volume_data__c != null){
                    BRRecord.LastYearVolume+=ISD.Last_year_volume_data__c;
                   
                }
                VolumeHeader='Volume Last 12 Months';
             }

            else if(optionSelected==CURRENTFISCAL){
                if(ISD.Volume_For_last_Fiscal_Year__c != null){
                    BRRecord.LastYearVolume+=ISD.Volume_For_last_Fiscal_Year__c;
                   
                }
                BRRecord.Volume+=ISD.Volume_for_Fiscal_Year__c;
                
               
                VolumeHeader='Volume Current fiscal';
              }
            else{
                if(ISD.month24_9L_Volume__c != null){
                    BRRecord.LastYearVolume+=ISD.month24_9L_Volume__c;
                    
                }
                if(ISD.month36_9l_volume__c!= null){
                    BRRecord.Volume+=ISD.month36_9l_volume__c;
                   
                }
                
                
                VolumeHeader='Volume';
            }
            BRRecord.shelfdollardata = String.valueOf(BRRecord.Volume.setScale(2));
         }
         
         if(SelectedDollar == FILTERDOLLAR){
            if(optionSelected==LAST12){
                if(ISD.Last12_Months_Dollar_value__c != null)
                BRRecord.Volume+=ISD.Last12_Months_Dollar_value__c;
                if(ISD.Last_year_Shelfdollar_data__c != null){
                    BRRecord.LastYearVolume+=ISD.Last_year_Shelfdollar_data__c;
                
                 }
                VolumeHeader='Shelf Dollar Last 12 Months';
             }

            else if(optionSelected==CURRENTFISCAL){
                BRRecord.Volume+=ISD.ShelfDollar_for_Fiscal_Year__c;
                
                if(ISD.Shelfdollar_For_last_Fiscal_Year__c != null){
                    BRRecord.LastYearVolume+=ISD.Shelfdollar_For_last_Fiscal_Year__c;
                    
                }
               
                VolumeHeader='Shelf Dollar Current fiscal';
              }
            else{
                if(ISD.Month36_ShelfDollar_Volume__c != null){
                BRRecord.Volume+=ISD.Month36_ShelfDollar_Volume__c;
               
                }
                if(ISD.month24_ShelfDollar_Volume__c != null){
                    BRRecord.LastYearVolume+=ISD.month24_ShelfDollar_Volume__c;
                    
                }
                VolumeHeader='Shelf Dollar';
            }
            
            BRRecord.shelfdollar = BRRecord.Volume.setscale(2).format();
            String s2 = BRRecord.shelfdollar.substringAfterLast('.');
            integer n = s2.length();
            if(n == 0){
                BRRecord.shelfdollardata = '$ '+BRRecord.shelfdollar+'.00';
            }
            else if(n == 1){
            BRRecord.shelfdollardata = '$ '+BRRecord.shelfdollar+'0';
            }
            else if(n==2){
            BRRecord.shelfdollardata = '$ '+BRRecord.shelfdollar;
            }
           
         }  
                 
            BrandRowMap.put(BRRecord.brandid,BRRecord);

            internalBrandSetId.add(BRRecord.brandid);
        
          if(brandRowMap.Values().size()>0)
                ShowList=true;
                    
}

List<BrandRow> BrandRowList=brandRowMap.values();
         
         Top10BrandRowList=new List<BrandRow>();
         
           if(SelectedValue==TOPTEN){
                 sortup(BrandRowList);
               }
            else{
                 sortdown(BrandRowList);
             }   
             
         for(BrandRow br: BrandRowList){
             if(Top10BrandRowList.size()>=10)
                 break;
             else
                 if(br.volume!=0)
                  Top10BrandRowList.add(br);
         }    
              
          for(BrandRow ISDV:BrandRowList){
                
           if(ISDV.LastYearVolume!=null){
           totalLastYearShare+=ISDV.LastYearVolume;
           }
          
           
          
               
          }
          
          
                                      
          for(BrandRow ISDV: Top10BrandRowList){
            
            
              if(TotalVolume!=0){
                ISDV.Share=(ISDV.volume/TotalVolume)*100;
                  
              }else
                 ISDV.Share=0;
                 

               if(totalLastYearShare != 0){
                     ISDV.LastYearShare=(ISDV.LastYearVolume/totalLastYearShare)*100;
                   
                }
                else{
                  ISDV.LastYearShare=0;
                }
                
                
                
                 ISDV.PercentChangeShare=ISDV.Share-ISDV.LastYearShare;
                 
                
                ISDV.perCentChange=DiageoUtils.calculateShare(ISDV.volume,ISDV.LastYearVolume);
               // ISDV.perCentChange=ISDV.volume-ISDV.LastYearVolume; 
             

                    
                if(ISDV.share != null)
                    TotalShare+=ISDV.share;    
                
                if(ISDV.PercentChangeShare != null)
                    totalPercentChangeShare+=ISDV.PercentChangeShare;
                 
          }
       }
    
    
 public void sortDown(List<BrandRow> BrandRowList){
    for(integer i=0;i<BrandRowList.size();i++){
                for(integer j=0;j<BrandRowList.size()-1;j++){
                    if(BrandRowList[j].volume > BrandRowList[j+1].volume){
                         BrandRow BrTemp=BrandRowList[j+1];
                         BrandRowList[j+1]=BrandRowList[j];
                         BrandRowList[j]=BrTemp;
                }
           }     
        }
     
     }   
 
     public void sortUp(List<BrandRow> BrandRowList){
        for(integer i=0;i<BrandRowList.size();i++){
                for(integer j=0;j<BrandRowList.size()-1;j++){
                    if(BrandRowList[j].volume < BrandRowList[j+1].volume){
                         BrandRow BrTemp=BrandRowList[j+1];
                         BrandRowList[j+1]=BrandRowList[j];
                         BrandRowList[j]=BrTemp;
                }
           }     
        }
     
     }   
 
 
    public List<BrandRow> getBrandRowlist(){
     List<BrandRow> BrandRowList=Top10BrandRowList;
         if(SelectedValue==TOPTEN){
             sortup(BrandRowList);
           }
        else{
             sortdown(BrandRowList);
         }   
    return BrandRowList;
    }

   public pageReference getSelectedVolume(){
        
        maxVendors=10;
        fetchInternalSalesdata(SelectedType,selectedValue,selectedFilter,SelectedDollar);       
        return null;
    }
 */
}