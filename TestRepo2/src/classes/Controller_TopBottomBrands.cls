public with sharing class Controller_TopBottomBrands {
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
    Public Decimal totalLastYearShare{get;set;}
    Public Decimal totalPercentChangeShare{get;set;}
    Public String SelectedFilter{get;set;}
    Public String SelectedDollar{get;set;}
    Public string monthYear{get;set;}
    Public date EndDate{get;set;}
    private decimal sum1=0;
    private decimal sum2=0;
    AggregateResult[] groupedResults;
    public string groupedquerytotal{get;private set;}

    List<NABCA_Sales_Data__c> listInternalSalesData;
    Account accountRecord;
       Final String top10=' DESC Limit 10';
       Final String Bottom10=' ASC Limit 10';
       Final String ORDERBY=' Order By ';
    
    public Controller_TopBottomBrands(ApexPages.StandardController controller) {
        accountRecord=(Account)Controller.getRecord();
        fetchInternalSalesdata(CURRENTMONTH, TOPTEN,ALL,FILTERVOLUME);
        selectedValue=TOPTEN;
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
    
    public string prepareSalesDataQuery(string optionSelected, string typeofData, string filter,String SelectedDollar){
         System.debug(optionSelected+'&&&&&&&'+typeofData);
         string query;
         string part1Query='SELECT Id,name,Month_End_Date__c,account__c,Brand__c,Brand__r.Name,Brand__r.NABCA_Size_Description__c,Brand__r.common_description__c,Brand__r.NABCA_Category__r.NABCA_Major_Category_Description__c,Brand__r.NABCA_Beverage_Type_Description__c,Brand__r.Id,';
         string part2Query=' FROM NABCA_Sales_Data__c where Account__c=\''+accountRecord.id+'\'';
         String filterBySpirits='And Brand__r.NABCA_Beverage_Type_Description__c=\''+filter+'\'';

         String filterByShelfDollarvolume=' And month36_9l_volume__c > 0';
         String filterByLast12Monthsvolume=' And Last_12_Months_Volume__c > 0';
         String FilterByFiscalVolume=' And Volume_for_Fiscal_Year__c > 0';

         String orderByShelfDollarvolume='month36_9l_volume__c';
         String orderByLast12Months='Last_12_Months_Volume__c';
         String orderByFiscal='Volume_for_Fiscal_Year__c';

         String ShelfDollarvolume='month36_9l_volume__c,month24_9L_Volume__c';
         String Last12Months='Last_12_Months_Volume__c, Last_year_volume_data__c,Percent_Change_in_Volume__c';
         String Fiscal='Volume_For_last_Fiscal_Year__c, Volume_for_Fiscal_Year__c';

         // this was added for dollar/volume picklist
         String FilterShelfDollar='And Month36_ShelfDollar_Volume__c > 0';
         String filterByLast12MonthsDollar='And Last12_Months_Dollar_value__c > 0';
         String filterByFiscalDollar='And ShelfDollar_for_Fiscal_Year__c > 0';

         String OrderByShelfDollar='Month36_ShelfDollar_Volume__c';
         String OrderByLast12MonthsShelfDollar='Last12_Months_Dollar_value__c';
         String OrderByFiscalShelfDollar='ShelfDollar_for_Fiscal_Year__c';

         String ShelfDollarVolumedv='Month36_ShelfDollar_Volume__c,month24_ShelfDollar_Volume__c';
         String Last12MonthsDollarVolume='Last12_Months_Dollar_value__c,Percent_Change_in_Dollar__c,Last_year_Shelfdollar_data__c';
         String FiscalDollarVolume='ShelfDollar_for_Fiscal_Year__c,Shelfdollar_For_last_Fiscal_Year__c';
         
         query=part1query;
         System.debug(part1query+'*******************');
         if(filter=='ALL'){
             if(optionSelected==CURRENTMONTH && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                 query=query+ShelfDollarvolume+part2Query+filterByShelfDollarvolume+ORDERBY+orderByShelfDollarvolume+top10;
             }else if (optionSelected==LAST12 && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                 query=query+Last12Months+part2Query+filterByLast12Monthsvolume+ORDERBY+orderByLast12Months+top10;
             }else if(optionSelected== CURRENTFISCAL && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                  query=query+Fiscal+part2Query+FilterByFiscalVolume+ORDERBY+orderByFiscal+top10;
             }else if(optionSelected==CURRENTMONTH && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                 query=query+ShelfDollarvolume+part2Query+filterByShelfDollarvolume+ORDERBY+orderByShelfDollarvolume+Bottom10;
             }else if (optionSelected==LAST12 && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                 query=query+Last12Months+part2Query+filterByLast12Monthsvolume+ORDERBY+orderByLast12Months+Bottom10;
             }else if(optionSelected== CURRENTFISCAL && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                  query=query+Fiscal+part2Query+FilterByFiscalVolume+ORDERBY+orderByFiscal+Bottom10;
             }

             else if(optionSelected==CURRENTMONTH && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+ShelfDollarVolumedv+part2Query+FilterShelfDollar+ORDERBY+OrderByShelfDollar+top10;
             }else if (optionSelected==LAST12 && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+Last12MonthsDollarVolume+part2Query+filterByLast12MonthsDollar+ORDERBY+OrderByLast12MonthsShelfDollar+top10;
             }else if(optionSelected== CURRENTFISCAL && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                  query=query+FiscalDollarVolume+part2Query+filterByFiscalDollar+ORDERBY+OrderByFiscalShelfDollar+top10;
             }else if(optionSelected==CURRENTMONTH && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+ShelfDollarVolumedv+part2Query+FilterShelfDollar+ORDERBY+OrderByShelfDollar+Bottom10;
             }else if (optionSelected==LAST12 && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+Last12MonthsDollarVolume+part2Query+filterByLast12MonthsDollar+ORDERBY+OrderByLast12MonthsShelfDollar+Bottom10;
             }else if(optionSelected== CURRENTFISCAL && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                  query=query+FiscalDollarVolume+part2Query+filterByFiscalDollar+ORDERBY+OrderByFiscalShelfDollar+Bottom10;
             }
         }else{
             if(optionSelected==CURRENTMONTH && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                 query=query+ShelfDollarvolume+part2Query+filterBySpirits+filterByShelfDollarvolume+ORDERBY+orderByShelfDollarvolume+top10;
             }else if (optionSelected==LAST12 && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                 query=query+Last12Months+part2Query+filterBySpirits+filterByLast12Monthsvolume+ORDERBY+orderByLast12Months+top10;
             }else if(optionSelected== CURRENTFISCAL && typeofData== TOPTEN && SelectedDollar==FILTERVOLUME){
                  query=query+Fiscal+part2Query+filterBySpirits+FilterByFiscalVolume+ORDERBY+orderByFiscal+top10;
             }else if(optionSelected==CURRENTMONTH && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                 query=query+ShelfDollarvolume+part2Query+filterBySpirits+filterByShelfDollarvolume+ORDERBY+orderByShelfDollarvolume+Bottom10;
             }else if (optionSelected==LAST12 && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                 query=query+Last12Months+part2Query+filterBySpirits+filterByLast12Monthsvolume+ORDERBY+orderByLast12Months+Bottom10;
             }else if(optionSelected== CURRENTFISCAL && typeofData== BOTTOMTEN && SelectedDollar==FILTERVOLUME){
                  query=query+Fiscal+part2Query+filterBySpirits+FilterByFiscalVolume+ORDERBY+orderByFiscal+Bottom10;
             }

             else if(optionSelected==CURRENTMONTH && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+ShelfDollarVolumedv+part2Query+filterBySpirits+FilterShelfDollar+ORDERBY+OrderByShelfDollar+top10;
             }else if (optionSelected==LAST12 && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+Last12MonthsDollarVolume+part2Query+filterBySpirits+filterByLast12MonthsDollar+ORDERBY+OrderByLast12MonthsShelfDollar+top10;
             }else if(optionSelected== CURRENTFISCAL && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
                  query=query+FiscalDollarVolume+part2Query+filterBySpirits+filterByFiscalDollar+ORDERBY+OrderByFiscalShelfDollar+top10;
             }else if(optionSelected==CURRENTMONTH && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+ShelfDollarVolumedv+part2Query+filterBySpirits+FilterShelfDollar+ORDERBY+OrderByShelfDollar+Bottom10;
             }else if (optionSelected==LAST12 && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                 query=query+Last12MonthsDollarVolume+part2Query+filterBySpirits+filterByLast12MonthsDollar+ORDERBY+OrderByLast12MonthsShelfDollar+Bottom10;
             }else if(optionSelected== CURRENTFISCAL && typeofData== BOTTOMTEN && SelectedDollar==FILTERDOLLAR){
                  query=query+FiscalDollarVolume+part2Query+filterBySpirits+filterByFiscalDollar+ORDERBY+OrderByFiscalShelfDollar+Bottom10;
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
        Public Decimal LastYearVolume{get;set;}
        Public Decimal LastYearShare {get;set;}
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
        TotalVolume=sum1;
        groupedquerytotal = string.valueof(sum1.setScale(2));
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
         
        else if(optionSelected==LAST12 && SelectedDollar==FILTERVOLUME && selectedFilter==ALL){
        AggregateResult[] groupedResults =[select sum(Last_12_Months_Volume__c) currenttotal ,sum(Last_year_volume_data__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        TotalVolume=sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
        
        else if(optionSelected==CURRENTFISCAL && SelectedDollar==FILTERVOLUME && selectedFilter==ALL){
        AggregateResult[] groupedResults =[select sum(Volume_for_Fiscal_Year__c) currenttotal ,sum(Volume_For_last_Fiscal_Year__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        TotalVolume=sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
        
        else if(optionSelected==CURRENTMONTH && SelectedDollar==FILTERDOLLAR && selectedFilter==ALL){
     
        AggregateResult[] groupedResults =[select sum(Month36_ShelfDollar_Volume__c) currenttotal ,sum(month24_ShelfDollar_Volume__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        TotalVolume=sum1;
        groupedquerytotal = '$' + sum1.format();
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
         
        else if(optionSelected==LAST12 && SelectedDollar==FILTERDOLLAR && selectedFilter==ALL){
        AggregateResult[] groupedResults =[select sum(Last12_Months_Dollar_value__c) currenttotal ,sum(Last_year_Shelfdollar_data__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        TotalVolume=sum1;
        groupedquerytotal = '$' + sum1.format();
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
        
        else if(optionSelected==CURRENTFISCAL && SelectedDollar==FILTERDOLLAR && selectedFilter==ALL){
        AggregateResult[] groupedResults =[select sum(ShelfDollar_for_Fiscal_Year__c) currenttotal ,sum(Shelfdollar_For_last_Fiscal_Year__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        TotalVolume=sum1;
        groupedquerytotal = '$' + sum1.format();
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
        else if(optionSelected==CURRENTMONTH && SelectedDollar==FILTERVOLUME && selectedFilter==SPIRITS){
        AggregateResult[] groupedResults =[select sum(month36_9L_Volume__c) currenttotal ,sum(month24_9L_Volume__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:SPIRITS group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        TotalVolume=sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
        
        else if(optionSelected==LAST12 && SelectedDollar==FILTERVOLUME && selectedFilter==SPIRITS){
        AggregateResult[] groupedResults =[select sum(Last_12_Months_Volume__c) currenttotal ,sum(Last_year_volume_data__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:SPIRITS group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal');      
        TotalVolume=sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
        
        else if(optionSelected==CURRENTFISCAL && SelectedDollar==FILTERVOLUME && selectedFilter==SPIRITS){
        AggregateResult[] groupedResults =[select sum(Volume_for_Fiscal_Year__c) currenttotal ,sum(Volume_For_last_Fiscal_Year__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:SPIRITS group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        TotalVolume=sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
        
        else if(optionSelected==CURRENTMONTH && SelectedDollar==FILTERVOLUME && selectedFilter==WINES){
        AggregateResult[] groupedResults =[select sum(month36_9L_Volume__c) currenttotal ,sum(month24_9L_Volume__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:WINES group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        TotalVolume=sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
        
        else if(optionSelected==LAST12 && SelectedDollar==FILTERVOLUME && selectedFilter==WINES){
        AggregateResult[] groupedResults =[select sum(Last_12_Months_Volume__c) currenttotal ,sum(Last_year_volume_data__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:WINES group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal');      
        TotalVolume=sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
        
        else if(optionSelected==CURRENTFISCAL && SelectedDollar==FILTERVOLUME && selectedFilter==WINES){
        AggregateResult[] groupedResults =[select sum(Volume_for_Fiscal_Year__c) currenttotal ,sum(Volume_For_last_Fiscal_Year__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:WINES group by account__c];
        sum1 = (Decimal)groupedResults[0].get('currenttotal');
        sum2 = (Decimal)groupedResults[0].get('lastyeartotal'); 
        TotalVolume=sum1;
        groupedquerytotal = string.valueof(sum1);
        totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        }
        else if(optionSelected==CURRENTMONTH && SelectedDollar==FILTERDOLLAR && selectedFilter==SPIRITS){
        AggregateResult[] groupedResults =[select sum(Month36_ShelfDollar_Volume__c) currenttotal ,sum(month24_ShelfDollar_Volume__c) lastyeartotal from nabca_sales_data__c where account__c =: accountRecord.Id and brand__r.nabca_beverage_type_description__c=:SPIRITS group by account__c];
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
        }//End of try block
        catch(Exception e){
                        e.getmessage();
        }
        //TotalVolume=sum1;
        //totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
       
        
        
        
  
        

           for(NABCA_Sales_Data__c ISD: listInternalSalesData){
               EndDate = ISD.Month_End_Date__c;
               monthYear =  monthmap.get(EndDate.month()) + ' ' + EndDate.year().format().replace(',','');  
               IBCSetid.add(ISD.Brand__c);

                   brandRow BRRecord= new BrandRow();
                   BRRecord.volume=0;
                   BRRecord.PerCentChange=0;
                   BRRecord.LastYearVolume=0;
                
                BRRecord.brandid= ISD.Brand__c;
                BRRecord.BrandName=ISD.Brand__r.common_description__c+' '+ISD.Brand__r.nabca_size_description__c;  
                
                if(BRRecord.Volume==null)
                    BRRecord.Volume=0;
                if(BRRecord.PerCentChange==null)
                    BRRecord.PerCentChange=0;
                        
         if(SelectedDollar== FILTERVOLUME){
            if(optionSelected==LAST12){
                if(ISD.Last_12_Months_Volume__c != null){
                    BRRecord.Volume+=ISD.Last_12_Months_Volume__c;
                }
                if(ISD.Last_year_volume_data__c != null){
                    BRRecord.LastYearVolume+=ISD.Last_year_volume_data__c;
                }
              
                    BRRecord.PerCentChange+=DiageoUtils.calculateShare(ISD.Last_12_Months_Volume__c,ISD.Last_year_volume_data__c);

                VolumeHeader='Volume Last 12 Months';
             }

            else if(optionSelected==CURRENTFISCAL){
                if(ISD.Volume_For_last_Fiscal_Year__c != null){
                BRRecord.Volume+=ISD.Volume_for_Fiscal_Year__c;
                }
                if(ISD.Volume_For_last_Fiscal_Year__c != null){
                    BRRecord.LastYearVolume+=ISD.Volume_For_last_Fiscal_Year__c;
                }
                if(ISD.Volume_For_last_Fiscal_Year__c != 0)
              //  BRRecord.PerCentChange+=(((ISD.Volume_for_Fiscal_Year__c-ISD.Volume_For_last_Fiscal_Year__c)/ISD.Volume_For_last_Fiscal_Year__c)*100);
                 BRRecord.PerCentChange+=DiageoUtils.calculateShare(ISD.Volume_for_Fiscal_Year__c,ISD.Volume_For_last_Fiscal_Year__c);

                VolumeHeader='Volume Current fiscal';
              }
            else{
                if(ISD.Month36_9L_Volume__c != null){
                BRRecord.Volume+=ISD.month36_9l_volume__c;
                }
                if(ISD.month24_9L_Volume__c != null){
                    BRRecord.LastYearVolume+=ISD.month24_9L_Volume__c;
                }
                  
                   BRRecord.PerCentChange+=DiageoUtils.calculateShare(ISD.month36_9l_volume__c,ISD.month24_9L_Volume__c);
                 //  BRRecord.PerCentChange+=(ISD.month36_9l_volume__c-ISD.month24_9L_Volume__c);
                 
                 
                VolumeHeader='Volume';
            }
            BRRecord.shelfdollardata = String.valueOf(BRRecord.Volume.setScale(2));
         }


         if(SelectedDollar == FILTERDOLLAR){
            if(optionSelected==LAST12){
                if(ISD.Last12_Months_Dollar_value__c != null){
                    BRRecord.Volume+=ISD.Last12_Months_Dollar_value__c;
                }
                if(ISD.Percent_Change_in_Dollar__c != null){
                    BRRecord.PerCentChange+=ISD.Percent_Change_in_Dollar__c;
                }
                if(ISD.Last_year_Shelfdollar_data__c != null){
                    BRRecord.LastYearVolume+=ISD.Last_year_Shelfdollar_data__c;
                }
                BRRecord.PerCentChange+=DiageoUtils.calculateShare(ISD.Last12_Months_Dollar_value__c,ISD.Last_year_Shelfdollar_data__c);
                VolumeHeader='Shelf Dollar Last 12 Months';
             }

            else if(optionSelected==CURRENTFISCAL){
                if(ISD.ShelfDollar_for_Fiscal_Year__c != null){
                BRRecord.Volume+=ISD.ShelfDollar_for_Fiscal_Year__c;
                }
                if(ISD.Shelfdollar_For_last_Fiscal_Year__c != null){
                    BRRecord.LastYearVolume+=ISD.Shelfdollar_For_last_Fiscal_Year__c;
                }
                
                 BRRecord.PerCentChange+=DiageoUtils.calculateShare(ISD.ShelfDollar_for_Fiscal_Year__c,ISD.Shelfdollar_For_last_Fiscal_Year__c);

                VolumeHeader='Shelf Dollar Current fiscal';
              }
            else{
                // 
                if(ISD.Month36_ShelfDollar_Volume__c != null){
                   BRRecord.Volume+=ISD.Month36_ShelfDollar_Volume__c;
                }
                if(ISD.month24_ShelfDollar_Volume__c != null){
                    BRRecord.LastYearVolume+=ISD.month24_ShelfDollar_Volume__c;
                }
                
              BRRecord.PerCentChange+=DiageoUtils.calculateShare(ISD.Month36_ShelfDollar_Volume__c,ISD.month24_ShelfDollar_Volume__c);
                   
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




            
            BrandRowMap.put(ISD.id,BRRecord);
            internalBrandSetId.add(ISD.Brand__c);

          //  TotalVolume+=BRRecord.volume;    
         //   totalPercentChange+=BRRecord.PerCentChange;
            totalLastYearShare+=BRrecord.LastYearVolume;
            
  
          if(brandRowMap.Values().size()>0)
                ShowList=true;
}          

          for(BrandRow ISDV: BrandRowMap.values()){
           
              if(TotalVolume!=0){
                ISDV.Share=(ISDV.volume/sum1)*100;
              }else{
                 ISDV.Share=0;
              }
/**              if(totalPercentChange!=0){
                    ISDV.PercentChangeShare=(ISDV.perCentChange/totalPercentChange)*100;
              }else{
                    ISDV.PercentChangeShare=0;
              }    **/
              if(totalLastYearShare != 0){
                  ISDV.LastYearShare=(ISDV.LastYearVolume/sum2)*100;
                 }else{
                  ISDV.LastYearShare=0;
              }
              
              ISDV.PercentChangeShare=ISDV.Share-ISDV.LastYearShare;
               
            if(ISDV.share != null)
            TotalShare+=ISDV.share;
            if(ISDV.PercentChangeShare != null)    
            totalPercentChangeShare+=ISDV.PercentChangeShare;

          }
    }
  
    
    public static void sortDown(List<BrandRow> BrandRowList){
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
 
     public static void sortUp(List<BrandRow> BrandRowList){
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
     List<BrandRow> BrandRowList=brandRowMap.values();
         if(SelectedValue==TOPTEN){
             sortup(BrandRowList);
           }
        else{
             sortdown(BrandRowList);
         }   
    return BrandRowList;
    }

 
   public pageReference getSelectedVolume(){
       
        fetchInternalSalesdata(SelectedType,selectedValue,selectedFilter,SelectedDollar);       
        return null;
    }
 
}