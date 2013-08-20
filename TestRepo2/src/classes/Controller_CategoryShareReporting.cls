public with sharing class Controller_CategoryShareReporting {
	
	/* This class is no longer used -- kept for archival purposes
	
    Final String CURRENTMONTH='Current Month';
    Final String TOPTEN='Top 10';
    Final String BOTTOMTEN='Bottom 10';
    Final String LAST12='Last 12 Months';
    Final String CURRENTFISCAL='Current Fiscal Year';
    Final String ALL='All';
    Final String SPIRITS='Spirit';
    Final String WINES='Wine';
    Integer maxCategories = 10;
    Final String FILTERDOLLAR = 'Shelf Dollar';
    Final String FILTERVOLUME = 'Volume';
    Final Map<integer,String> monthMap = new Map<integer,String>{1 => 'Jan',2 => 'Feb',3 => 'Mar',4 => 'Apr',5 => 'May',6 => 'Jun',7 => 'July',8 => 'Aug',9 => 'Sept',10 => 'Oct',11 => 'Nov',12 => 'Dec'};
    
    Public Boolean ShowList{get;set;}
    transient Map<id,BrandRow> BrandRowMap;
    
    Public string SelectedValue{get;set;}
    Public string SelectedType {get;set;}
    Public Decimal totalVolume {get;set;}
    Public String volumeHeader{get;set;}
    Public String brandExpansionHeader{get;set;}
  //  Public String pointsHeader{get;set;}
    Public Decimal totalPercentChange{get;set;}
    Public Decimal totalShare{get;set;}
    Public Decimal totalPercentChangeShare{get;set;}
    Public String SelectedFilter{get;set;}
    Public String SelectedDollar{get;set;}
    Public Decimal totalLastYearShare{get;set;}
    public List<BrandRow> Top10BrandRowList;
    Public string monthYear{get;set;}
    Public date EndDate{get;set;}
    private decimal sum1=0;
    private decimal sum2=0;
    AggregateResult[] groupedResults;
    public string groupedquerytotal{get;private set;}
    
    transient List<NABCA_Sales_Data__c> listInternalSalesData;
    Account accountRecord;
     //  Final String top10=' DESC Limit 10';
     //  Final String Bottom10=' ASC Limit 10';
       Final String ORDERBY=' Order By ';
    
    public Controller_CategoryShareReporting(ApexPages.StandardController controller) {
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
    
    public string prepareSalesDataQuery(string optionSelected, string typeofData, string filter,String SelectedDollar){
         System.debug(optionSelected+'&&&&&&&'+typeofData);
         string query;
         string part1Query='SELECT Id,name,Month_End_Date__c,Brand__c, Brand__r.Name, brand__r.Common_Description__c,Brand__r.NABCA_Category__r.NABCA_Major_Category_Description__c, Brand__r.Nabca_Category__r.name, Brand__r.NABCA_Beverage_Type_Description__c,Brand__r.Id,Brand__r.NABCA_Category__c,Brand__r.NABCA_size_description__c,';
         string part2Query=' FROM NABCA_Sales_Data__c where Account__c=\''+accountRecord.id+'\'';
         String filterBySpirits='And Brand__r.NABCA_Beverage_Type_Description__c=\''+filter+'\'';

         String filterByShelfDollarvolume='And month36_9L_Volume__c > 0';
         String filterByLast12Monthsvolume='And Last_12_Months_Volume__c > 0';
         String FilterByFiscalVolume='And Volume_For_last_Fiscal_Year__c > 0';

         String ShelfDollarvolume='month36_9L_Volume__c,month24_9L_Volume__c';
         String Last12Months='Last_12_Months_Volume__c, Percent_Change_in_Volume__c,Last_year_volume_data__c';
         String Fiscal='Volume_For_last_Fiscal_Year__c, Volume_for_Fiscal_Year__c';

         String OrderByShelfDollarvolume='month36_9L_Volume__c';
         String OrderByLast12Months='Last_12_Months_Volume__c';
         String OrderByFiscal='Volume_For_last_Fiscal_Year__c';

         // this was added to create a new filter ShelfDollar/Volume
         String FilterShelfDollar=' And Month36_ShelfDollar_Volume__c > 0';
         String filterByLast12MonthsDollar=' And Last12_Months_Dollar_value__c > 0';
         String filterByFiscalDollar=' And ShelfDollar_for_Fiscal_Year__c > 0';

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

             }else if(optionSelected==CURRENTMONTH && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
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
            
             }else if(optionSelected==CURRENTMONTH && typeofData== TOPTEN && SelectedDollar==FILTERDOLLAR){
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
       // Public Boolean expand{get;set;}
       // Public List<BrandRow> expandedBrandRow{get;set;}
        transient Public List<BrandRow> expandedBrandRow{get;set;}
        Public Decimal LastYearVolume{get;set;}
        Public Decimal LastYearShare {get;set;}
        Public string shelfdollardata{get;set;}
        Public string shelfdollar{get;set;}
        public string expandedshelfdollar{get;set;}
        public string expandedshelfdollardata{get;set;}
        public string perCentChangeString {get;set;}

        
      }
    
    void fetchInternalSalesdata(string optionSelected, string typeofData, string selectedFilter,string SelectedDollar){
        totalVolume=0;
        totalShare=0;
        totalPercentChange=0;
        totalPercentChangeShare=0;
        totalLastYearShare = 0;
       
        integer count=0;
        
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
       // TotalVolume=sum1;
        //totalPercentChange=((sum1-sum2)/sum2)*100;
       // totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);
        for(NABCA_Sales_Data__c ISD: listInternalSalesData){
         count++;        
                IBCSetid.add(ISD.Brand__r.NABCA_Category__c);
                BrandRow BRRecord;
                List<BrandRow> BrandRowList;
                BrandRow BRExpansionRow;
                BRExpansionRow= new BrandRow();
                EndDate = ISD.Month_End_Date__c;
                monthYear =  monthmap.get(EndDate.month()) + ' ' + EndDate.year().format().replace(',','');                 
                
                if(BrandRowMap.get(ISD.Brand__r.NABCA_Category__c)==null){
                   BRRecord= new BrandRow();
                   BRRecord.volume=0;
                   BRRecord.PerCentChange=0;
                   BRRecord.LastYearVolume=0;
                   BrandRowList= new List<BrandRow>();

                 }
               else{
                   BRRecord=BrandRowMap.get(ISD.Brand__r.NABCA_Category__c);
                   BrandRowList=BrandRowMap.get(ISD.Brand__r.NABCA_Category__c).expandedBrandRow;
               }
                            
                BRRecord.brandid= ISD.Brand__r.NABCA_Category__c;
                BRRecord.BrandName=ISD.Brand__r.Nabca_Category__r.NABCA_Major_Category_Description__c;
                BRExpansionRow.brandid=ISD.Brand__r.NABCA_Category__c;
                BRExpansionRow.BrandName=ISD.Brand__r.Common_Description__c +' '+ ISD.Brand__r.NABCA_size_description__c;
                
                if(BRRecord.Volume==null)
                    BRRecord.Volume=0;
                if(BRRecord.PerCentChange==null)
                    BRRecord.PerCentChange=0;
                
                if(SelectedDollar== FILTERVOLUME){
                    if(optionSelected==LAST12){
                        if(ISD.Last_12_Months_Volume__c!=null)
                            BRRecord.Volume+=ISD.Last_12_Months_Volume__c;
                        
                        if(ISD.Percent_Change_in_Volume__c!=null)
                           BRRecord.PerCentChange+=ISD.Percent_Change_in_Volume__c;
                 
                        if(ISD.Last_year_volume_data__c != null){
                        BRRecord.LastYearVolume+=ISD.Last_year_volume_data__c;
                        }   
                        if(ISD.Last_12_Months_Volume__c!= null){
                            BRExpansionRow.Volume=ISD.Last_12_Months_Volume__c;
                        }
                        BRExpansionRow.PerCentChange=ISD.Percent_Change_in_Volume__c;
                        if(ISD.Last_year_volume_data__c != null){
                        BRExpansionRow.LastYearVolume=ISD.Last_year_volume_data__c;
                       
                        }   

                        VolumeHeader='Volume Last 12 Months';
                     
                     }

                    else if(optionSelected==CURRENTFISCAL){
                        if(ISD.Volume_for_Fiscal_Year__c!=null){
                          BRRecord.Volume+=ISD.Volume_for_Fiscal_Year__c;
                         }
                       if(ISD.Volume_For_last_Fiscal_Year__c != null){
                            BRRecord.LastYearVolume+=ISD.Volume_For_last_Fiscal_Year__c;
                       }
                       if(ISD.Volume_for_Fiscal_Year__c != null){    
                         BRExpansionRow.Volume=ISD.Volume_for_Fiscal_Year__c;
                       }
                      if(ISD.Volume_For_last_Fiscal_Year__c != null){
                            BRExpansionRow.LastYearVolume=ISD.Volume_For_last_Fiscal_Year__c;
                           }
                        VolumeHeader='Volume Current fiscal';
                      }
                    else{
                        if(ISD.month36_9L_Volume__c!=null){
                           BRRecord.Volume+=ISD.month36_9L_Volume__c;
                        }
                         if(ISD.month24_9L_Volume__c != null){
                            BRRecord.LastYearVolume+=ISD.month24_9L_Volume__c;
                        }
                        if(ISD.month36_9L_Volume__c != null){
                         BRExpansionRow.Volume=ISD.month36_9L_Volume__c;
                        }
                        if(ISD.month24_9L_Volume__c != null){
                            BRExpansionRow.LastYearVolume=ISD.month24_9L_Volume__c;
                        }
                        VolumeHeader='Volume';
                        brandExpansionHeader = 'Volume';
                    }
                   BRRecord.shelfdollardata = String.valueOf(BRRecord.Volume.setScale(2).format());
                   BRRecord.perCentChangeString=String.valueof(BRRecord.PerCentChange.setScale(2));
                   system.debug('$$$$$ before '+ BRExpansionRow.Volume.setScale(2));
                   BRExpansionRow.expandedShelfDollardata = String.valueOf(BRExpansionRow.Volume.setScale(2));
                   system.debug('$$$$$ after '+ BRRecord.expandedshelfdollardata);
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
                    VolumeHeader='Shelf Dollar Last 12 Months';
                    brandExpansionHeader = 'Shelf Dollar';
                    if(ISD.Last12_Months_Dollar_value__c!=null){
                        BRExpansionRow.Volume=ISD.Last12_Months_Dollar_value__c;
                    }
                    if(ISD.Percent_Change_in_Dollar__c!=null)
                        BRExpansionRow.PerCentChange=ISD.Percent_Change_in_Dollar__c;
                        if(ISD.Last_year_Shelfdollar_data__c != null){
                        BRExpansionRow.LastYearVolume=ISD.Last_year_Shelfdollar_data__c;
                       
                      }
                 }

                else if(optionSelected==CURRENTFISCAL){
                    BRRecord.Volume+=ISD.ShelfDollar_for_Fiscal_Year__c;
                    if(ISD.Shelfdollar_For_last_Fiscal_Year__c != null){
                        BRRecord.LastYearVolume+=ISD.Shelfdollar_For_last_Fiscal_Year__c;
                    }
                    if(ISD.ShelfDollar_for_Fiscal_Year__c!=null){
                       BRExpansionRow.Volume=ISD.ShelfDollar_for_Fiscal_Year__c;
                    }
                       if(ISD.Shelfdollar_For_last_Fiscal_Year__c != null){
                        BRExpansionRow.LastYearVolume=ISD.Shelfdollar_For_last_Fiscal_Year__c;
                    }
                    VolumeHeader='Shelf Dollar Current fiscal';
                  }
                else{
                    BRRecord.Volume+=ISD.Month36_ShelfDollar_Volume__c;
                     if(ISD.month24_ShelfDollar_Volume__c != null){
                        BRRecord.LastYearVolume+=ISD.month24_ShelfDollar_Volume__c;
                    }
                    if(ISD.Month36_ShelfDollar_Volume__c!=null){
                        BRExpansionRow.Volume=ISD.Month36_ShelfDollar_Volume__c;
                    }
                        if(ISD.month24_ShelfDollar_Volume__c != null){
                        BRExpansionRow.LastYearVolume=ISD.month24_ShelfDollar_Volume__c;
                    }
                    VolumeHeader='Shelf Dollar';
                    brandExpansionHeader = 'Shelf Dollar';
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
                    else{
                        BRRecord.shelfdollardata = '$ '+BRRecord.shelfdollar;  
                    } 
                    BRRecord.expandedshelfdollar = BRExpansionRow.Volume.setScale(2).format();
                    string s3 = BRRecord.expandedshelfdollar.substringAfterLast('.'); 
                    integer n1 = s3.length();
                    if(n1 == 0){
                        BRRecord.expandedshelfdollardata = '$ '+BRRecord.expandedshelfdollar+'.00';
                    }  
                    else if(n1 == 2){
                        BRRecord.expandedshelfdollardata = '$ '+BRRecord.expandedshelfdollar+'0';
                    }
                    else{
                        BRRecord.expandedshelfdollardata = '$ '+BRRecord.expandedshelfdollar;
                    }
            }
            BrandRowList.add(BRExpansionRow);
           
            //BrandRowList = getSortedExpandedList(BrandRowList);

            BRRecord.expandedBrandRow=BrandRowList;

          


            BrandRowMap.put(ISD.Brand__r.NABCA_Category__c,BRRecord);
            
           
               
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
            
            //    TotalVolume+=ISDV.volume;    
             
                totalLastYearShare+=ISDV.LastYearVolume;
                
                

           }
                     
          for(BrandRow ISDV: Top10BrandRowList){
             if(TotalVolume!=0){
                ISDV.Share=(ISDV.volume/TotalVolume)*100;
              }else
                 ISDV.Share=0;
                 

               if(totalLastYearShare != 0){
                  ISDV.LastYearShare=((ISDV.LastYearVolume/totalLastYearShare)*100);
                 }
                 else{
                  ISDV.LastYearShare=0;
                }
                 ISDV.PercentChangeShare=ISDV.Share-ISDV.LastYearShare;
                 ISDV.perCentChange=DiageoUtils.calculateShare(ISDV.Volume,ISDV.LastYearVolume);
             //    ISDV.perCentChange=ISDV.Volume-ISDV.LastYearVolume;


            TotalShare+=ISDV.share;    
            totalPercentChangeShare+=ISDV.PercentChangeShare;

                  for(BrandRow ISDVE:ISDV.expandedBrandRow){
                  
                  if(TotalVolume!=0 && ISDVE.volume!=null){
                    ISDVE.Share=(ISDVE.volume/TotalVolume)*100;
                  }else{
                     ISDVE.Share=0;
                  }
                 if(totalLastYearShare != 0){
                  ISDVE.LastYearShare=((ISDVE.LastYearVolume/totalLastYearShare)*100);
                 }
                 else{
                  ISDVE.LastYearShare=0;
                }
                 ISDVE.PercentChangeShare=ISDVE.Share-ISDVE.LastYearShare;
                 // AT [09/27/12] corrected percent change calculation statement
                 // ISDVE.perCentChange=DiageoUtils.calculateShare(ISDVE.Share,ISDVE.LastYearShare);  
                 ISDVE.perCentChange=DiageoUtils.calculateShare(ISDVE.Volume,ISDVE.LastYearVolume);  
                }
                
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
        system.debug('*******'+BrandRowList);
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
             sortup(Top10BrandRowList);
           }
        else{
             sortdown(Top10BrandRowList);
         }
          
    return BrandRowList;
    }

    // public List<BrandRow> getSortedExpandedList(List<BrandRow> brandRows){
    //     Map<Decimal, List<BrandRow>> brandRowMapByVolume = new Map<Decimal, List<BrandRow>>();
    //     Set<Decimal> volumes = new Set<Decimal>();
        
    //     List<BrandRow> sortedBrandRows = new List<BrandRow>();
        
    //     for(BrandRow row : brandRows){
        
    //         Decimal vol = row.volume;
    //         if(!brandRowMapByVolume.containsKey(vol)){
    //             brandRowMapByVolume.put(vol, new List<BrandRow>()); 
    //         }    
    //         brandRowMapByVolume.get(vol).add(row);
    //         volumes.add(vol);
    //     }
        
    //     List<Decimal> volsToSort = new List<Decimal>();
    //     volsToSort.addAll(volumes);
        
    //     volsToSort.sort();
        
        
    //         for(Decimal vol : volsToSort){
    //             sortedBrandRows.addAll(brandRowMapByVolume.get(vol));
    //         }
    
        
    
    //     return sortedBrandRows;
    // }

 
   public pageReference getSelectedVolume(){
        
        maxCategories = 10;
        fetchInternalSalesdata(SelectedType,selectedValue,selectedFilter,SelectedDollar);       
        return null;
    }
 */
}