/***************************************************************************************************************************************
Name – ShareReporting

Purpose – Vendor Share Reporting - Top 10: The system must display volume and share information by sku on the Account Detail page for the current month(default) 
and then have the ability to filter specific criteria.

Rally User Story and Task – (US658)


Version US     Author              Date            Details 
------------------------------------------------------------------------------------------------------------------------------
1.0             Tom Ansley             11/12/2012      Refactored vendor/category classes and pages to display both pages on one page.
 ****************************************************************************************************************************************/


public with sharing class Controller_ShareReporting {
	
	/* STATIC DATA */
	public String VENDOR = 'Vendor';
	public String CATEGORY = 'Category';
	public String CURRENTMONTH = 'Current Month';
	public String TOPTEN = 'Top 10';
	public String BOTTOMTEN = 'Bottom 10';
	public String LAST12 = 'Last 12 Months';
	public String CURRENTFISCAL = 'Current Fiscal Year';
	public String ALL = 'All';
	public String SPIRITS = 'Spirits';
	public String SPIRIT  =  'SPIRIT';
	public String WINES = 'Wines';
	public String WINE  =  'WINE';
	public String SHELF_DOLLAR  =  'Shelf Dollar';
	public String VOLUME  =  'Volume';
	private final Map<integer,String> monthMap = new Map<integer,String>{1 => 'Jan',2 => 'Feb',3 => 'Mar',4 => 'Apr',5 => 'May',6 => 'Jun',7 => 'July',8 => 'Aug',9 => 'Sept',10 => 'Oct',11 => 'Nov',12 => 'Dec'};

	/* PRIVATE */
	transient Map<id,BrandRow> brandRowMap;
	private decimal sum1 = 0;
	private decimal sum2 = 0;
	transient sObject groupedResults;
	transient List<NABCA_Sales_Data__c> salesData;
	private Account accountRecord;
	private Set<id> internalBrandSetId;
	public List<BrandRow> topTenTableRowList;
	
	//holds the selected month and that data should be displayed for.  NOTE - the latest month is 1, latest month - 1 = 2 etc.

	//These two variables hold the last month and year that data exists for.
	private Integer latestMonth = 0;
	private Integer latestYear = 0;

	/* PUBLIC */
	public Boolean showList{get;set;} 				//indicates to the visual page whether there is data in the list to display
	public Boolean showCategory{get;set;}			//the drop down which indicates whether VENDOR or CATEGORY data is being displayed
	public String selectedRecords{get;set;}			//the drop down which indicates whether the TOP or BOTTOM 10 records are being displayed.
	public String selectedGroup{get;set;}
	public String selectedMonth {get;set;}
	public Integer monthOffset {get;set;}
	public String dateRange {get;set;}
	public Decimal totalVolume {get;set;}
	public String volumeHeader{get;set;}
	public Decimal totalPercentChange{get;set;}
	public Decimal totalShare{get;set;}
	public Decimal totalPercentChangeShare{get;set;}
	public String beverageType{get;set;}
	public String measurementType{get;set;}
	public Decimal totalLastYearShare{get;set;}
	public date endDate{get;set;}
	public String monthYear{get;set;}
	public String groupedQueryTotal{get;private set;}
    public String brandExpansionHeader{get;set;}

	/* INTERNAL CLASS */
	public class BrandRow{
		public ID brandid;
		public String brandName{get;set;}
		public Decimal volume{get;set;}
		public Decimal share{get;set;}   
		public Decimal percentChange {get;set;}
		public Decimal percentChangeShare{get;set;}
		public Decimal lastYearShare {get;set;}
		public Decimal lastYearVolume{get;set;}
		public String shelfDollarData{get;set;}
		public String shelfDollar{get;set;}
		
    	transient public List<BrandRow> expandedBrandRow{get;set;}
        public String expandedShelfDollar{get;set;}
        public String expandedShelfDollarData{get;set;}
        public String percentChangeString {get;set;}
	}

	/* CONSTRUCTOR */
	public Controller_ShareReporting(ApexPages.StandardController controller) {
		accountRecord = (Account)Controller.getRecord();
		showCategory = false;
		selectedRecords = TOPTEN;
		selectedGroup = CATEGORY;
		selectedMonth = '1';
		dateRange = CURRENTMONTH;
		beverageType = ALL;
		measurementType = VOLUME;
		fetchInternalSalesData(selectedGroup, selectedMonth, dateRange, TOPTEN, ALL, VOLUME);
	}

	/* GET/SET METHODS FOR THE DROP-DOWN FILTER ON THE VISUAL FORCE PAGE */
	public List<SelectOption> getGroupByOptions() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(VENDOR,VENDOR));
		options.add(new SelectOption(CATEGORY,CATEGORY));
		return options;
	}

	public List<SelectOption> getSelectedRecordsOptions() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(TOPTEN,TOPTEN));
		options.add(new SelectOption(BOTTOMTEN,BOTTOMTEN));
		return options;
	}

	public List<SelectOption> getStartDateOptions() {
		List<SelectOption> options = new List<SelectOption>();
		Integer monthCounter = latestMonth;
		Integer yearCounter = latestYear;
		for(Integer i = 0; i < 13; i++) {
			options.add(new SelectOption((i+1)+'',monthmap.get(monthCounter) + ' ' + yearCounter));// + ' (' + (i+1) + ')'));
			monthCounter--;
			if (monthCounter == 0) {
				monthCounter = 12;
				yearCounter--;
			}
		}
		return options;
	}

	public List<SelectOption> getBeverageTypeOptions(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(ALL,ALL));
		options.add(new SelectOption(SPIRIT,SPIRITS));
		options.add(new SelectOption(WINE,WINES));
		return options;
	}

	public List<SelectOption> getDateRangeOptions() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(CURRENTMONTH,CURRENTMONTH));
		options.add(new SelectOption(CURRENTFISCAL,CURRENTFISCAL)); 
		options.add(new SelectOption(LAST12,LAST12));
		return options;
	}

	public List<SelectOption> getMeasurementOptions() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(VOLUME,VOLUME));
		options.add(new SelectOption(SHELF_DOLLAR,SHELF_DOLLAR)); 
		return options;
	}

	public List<BrandRow> getTableRowList(){
		List<BrandRow> tableRowList = topTenTableRowList;
		if(selectedRecords==TOPTEN){
			sortUp(tableRowList);
		} else {
			sortDown(tableRowList);
		}   
		return tableRowList;
	}

	/*
	 * Method which is called when the "Go" button is pressed on the ShareReporting page.
	 */
	public pageReference getData(){
		monthOffset = 1 - Integer.valueOf(selectedMonth);
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE1: ' + selectedMonth +', ' + monthOffset));
		fetchInternalSalesData(selectedGroup, selectedMonth, dateRange, selectedRecords, beverageType, measurementType);       
		return null;
	}

	/*
	 * Method to create the query that will be used to return the sales data.
	 */
	private String prepareSalesDataQuery(String beverageType, String selectedMonth, String dateRange){
		monthOffset = 1 - Integer.valueOf(selectedMonth);
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE2: ' + selectedMonth +', ' + monthOffset));

		//--------------------------------------------------
		//This section builds the SELECT part of the query
		String query = 'SELECT Id, name,Brand__c, Month_End_Date__c, Brand__r.NABCA_Vendor__c, Brand__r.NABCA_Vendor__r.NABCA_Vendor_Description__c';
		query += ', Brand__r.NABCA_Beverage_Type_Description__c, Brand__r.Id, Brand__r.Common_Code__c, Brand__r.Common_Description__c, Brand__r.Name';
		query += ', Brand__r.NABCA_Category__r.NABCA_Major_Category_Description__c, Brand__r.Nabca_Category__r.name, Brand__r.NABCA_Category__c';
		query += ', Brand__r.NABCA_size_description__c';
		String limiter = '';
		
		//if the dateRange is CURRENTMONTH then get the data associated with that particular month
		if (dateRange.equals(CURRENTMONTH)) {
			//query = query + ', Month' + selectedMonth + '_9L_Volume__c, Month' + selectedMonth + '_ShelfDollar_Volume__c ';
			query += ', Month' + (36+monthOffset) + '_9L_Volume__c, Month' + (36+monthOffset) + '_ShelfDollar_Volume__c';
			query += ', Month' + (24+monthOffset) + '_9L_Volume__c, Month' + (24+monthOffset) + '_ShelfDollar_Volume__c';
			limiter = ' AND Month' + (36+monthOffset) + '_9L_Volume__c > 0 ORDER BY Month' + (36+monthOffset) + '_9L_Volume__c DESC';
		//if the dateRange is LAST12 then get the last 12 months of data from the selectedMonth.
		} else if (dateRange.equals(LAST12)) {
			integer i = Integer.valueOf(selectedMonth);
			for(integer num = i; num < i + 13; num++) {
				query = query + ', Month' + num + '_9L_Volume__c, Month' + num + '_ShelfDollar_Volume__c ';
			}
			query+= ', Last_12_Months_Volume_' + selectedMonth + '__c, Last12_Months_Dollar_value_' + selectedMonth + '__c';
			query+= ', Percent_Change_in_Volume_' + selectedMonth + '__c, Percent_Change_in_Dollar_' + selectedMonth + '__c';
			query+= ', Last_year_volume_data_' + selectedMonth + '__c, Last_year_Shelfdollar_data_' + selectedMonth + '__c';
			limiter = ' AND Last_12_Months_Volume_' + selectedMonth + '__c > 0 ORDER BY Last_12_Months_Volume_' + selectedMonth + '__c DESC LIMIT 4450';
		} else {
			query+= ', Volume_for_Fiscal_Year_' + selectedMonth + '__c, ShelfDollar_for_Fiscal_Year_' + selectedMonth + '__c';
			query+= ', Volume_For_last_Fiscal_Year_' + selectedMonth + '__c, Shelfdollar_For_last_Fiscal_Year_' + selectedMonth + '__c';
			limiter = ' AND Volume_For_Fiscal_Year_' + selectedMonth + '__c > 0 ORDER BY Volume_For_Fiscal_Year_' + selectedMonth + '__c DESC';
		}
		
		//--------------------------------------------------
		
		query = query + ' FROM NABCA_Sales_Data__c WHERE Account__c =\'' + accountRecord.id + '\'';
		
		if (beverageType.equals(SPIRIT)) {
			query = query + ' And Brand__r.NABCA_Beverage_Type_Description__c = \'' + SPIRIT + '\'';
		} else if (beverageType.equals(WINE)) {
			query = query + ' And Brand__r.NABCA_Beverage_Type_Description__c = \'' + WINE + '\'';			
		}
		query += limiter;
		
		//if(UserInfo.getLastName() == 'Mansell'){
		//	query += ' LIMIT 2000';
		//}
		
		return query;
	}

	/*
	 * Method which, given the input filters, performs the data query and arranges all data into its necessary buckets.
	 */
	public void fetchInternalSalesData(String selectedGroup, String selectedMonth, String dateRange, String selectedRecords, String beverageType, String measurementType){
		totalVolume = 0;
		totalShare = 0;
		totalPercentChange = 0;
		
		totalPercentChangeShare = 0;
		totalLastYearShare = 0;
		internalBrandSetId = new Set<id>();

		salesData = new List<NABCA_Sales_Data__c>();
		brandRowMap = new Map<id,BrandRow>();

		//if the grouping is set to CATEGORY then tell page to show the categories rather than the vendors.
		if (selectedGroup.equals(CATEGORY)) {
			showCategory = true;
		} else {
			showCategory = false;
		}

		//This is where we put together the SQL statement for the aggregated data
		try{
			//String q = prepareSalesDataQuery(beverageType, selectedMonth, dateRange);
			//salesData = Database.query(q);
			
			String aggregateQuery = '';
			monthOffset = 1 - Integer.valueOf(selectedMonth);
			
			if(dateRange==CURRENTMONTH && measurementType.equals(VOLUME)){
				aggregateQuery = 'select sum(month' + (36+monthOffset) + '_9L_Volume__c) currenttotal ,sum(month' + (24+monthOffset) + '_9L_Volume__c) lastyeartotal from nabca_sales_data__c where Account__c =\'' + accountRecord.id + '\'';
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE 1: ' + aggregateQuery));
			}
			
			else if(dateRange==CURRENTMONTH && measurementType.equals(SHELF_DOLLAR)){
				aggregateQuery = 'select sum(Month' + (36+monthOffset) + '_ShelfDollar_Volume__c) currenttotal ,sum(month' + (24+monthOffset) + '_ShelfDollar_Volume__c) lastyeartotal from nabca_sales_data__c where Account__c =\'' + accountRecord.id + '\'';
			}

			else if(dateRange==LAST12 && measurementType.equals(VOLUME)){
				aggregateQuery = 'select sum(Last_12_Months_Volume_' + selectedMonth + '__c) currenttotal ,sum(Last_year_volume_data_' + selectedMonth + '__c) lastyeartotal from nabca_sales_data__c where Account__c =\'' + accountRecord.id + '\'';
			}

			else if(dateRange==LAST12 && measurementType.equals(SHELF_DOLLAR)){
				aggregateQuery = 'select sum(Last12_Months_Dollar_value_' + selectedMonth + '__c) currenttotal ,sum(Last_year_Shelfdollar_data_' + selectedMonth + '__c) lastyeartotal from nabca_sales_data__c where Account__c =\'' + accountRecord.id + '\'';
			}

			else if(dateRange==CURRENTFISCAL && measurementType.equals(VOLUME)){
				aggregateQuery = 'select sum(Volume_for_Fiscal_Year_' + selectedMonth + '__c) currenttotal ,sum(Volume_For_last_Fiscal_Year_' + selectedMonth + '__c) lastyeartotal from nabca_sales_data__c where Account__c =\'' + accountRecord.id + '\'';
			}

			else if(dateRange==CURRENTFISCAL && measurementType.equals(SHELF_DOLLAR)){
				aggregateQuery = 'select sum(ShelfDollar_for_Fiscal_Year_' + selectedMonth + '__c) currenttotal ,sum(Shelfdollar_For_last_Fiscal_Year_' + selectedMonth + '__c) lastyeartotal from nabca_sales_data__c where Account__c =\'' + accountRecord.id + '\'';
			}

			//if the filter has been set for SPIRIT/WINE
			if(!beverageType.equals(ALL)) {
				aggregateQuery = aggregateQuery + ' and brand__r.nabca_beverage_type_description__c=\'' + beverageType + '\'group by account__c';
			}
			
			sObject groupedResults = Database.query(aggregateQuery);
			
			sum1 = (Decimal)groupedResults.get('currenttotal');
			sum2 = (Decimal)groupedResults.get('lastyeartotal');
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE 2: ' + sum1));
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE 3: ' + sum2));
			totalVolume = sum1; 
			if (measurementType.equals(SHELF_DOLLAR)) {
				groupedQueryTotal = '$' + sum1.format();
			} else {
				groupedQueryTotal = String.valueof(sum1.setscale(2));				
			}
			totalPercentChange = DiageoUtils.calculateShare(sum1,sum2);   
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE 4: ' + totalPercentChange));

		}
		catch(Exception e){
			e.getmessage();
		}

		//loop through the returned data and organize it.
		String q = prepareSalesDataQuery(beverageType, selectedMonth, dateRange);
		for(NABCA_Sales_Data__c ISD: Database.query(q)){
            List<BrandRow> tableRowList;
			BrandRow tableRow;
            BrandRow tableRowChild = new BrandRow();
			
			//get the latest month and year for this data set for filter display
			if(monthYear == null){
				endDate = ISD.Month_End_Date__c;
				latestMonth = endDate.month();
				latestYear = endDate.year();
							
				//this sets the human readable latest date value that can be searched on at top of visual force page.
				monthYear =  monthmap.get(endDate.month()) + ' ' + endDate.year().format().replace(',','');
			}
			
			if(selectedGroup.equals(CATEGORY) && brandRowMap.get(ISD.Brand__r.NABCA_Category__c) != null) {
				tableRow = brandRowMap.get(ISD.Brand__r.NABCA_Category__c);
                tableRowList = brandRowMap.get(ISD.Brand__r.NABCA_Category__c).expandedBrandRow;
			} else if(selectedGroup.equals(VENDOR) && brandRowMap.get(ISD.Brand__r.NABCA_Vendor__c) != null) {
				tableRow = brandRowMap.get(ISD.Brand__r.NABCA_Vendor__c);
                tableRowList = brandRowMap.get(ISD.Brand__r.NABCA_Vendor__c).expandedBrandRow;
			} else {
				tableRow = new BrandRow();
				tableRow.volume = 0;
				tableRow.percentChange = 0;
				tableRow.LastYearVolume = 0;
				tableRowList = new List<BrandRow>();
			}

			if (selectedGroup.equals(CATEGORY)) {
                tableRow.brandid = ISD.Brand__r.NABCA_Category__c;
                tableRow.BrandName = ISD.Brand__r.Nabca_Category__r.NABCA_Major_Category_Description__c;
				tableRowChild.brandid = ISD.Brand__r.NABCA_Category__c;
			} else if (selectedGroup.equals(VENDOR)) {
				tableRow.brandid = ISD.Brand__r.NABCA_Vendor__c;
				tableRow.BrandName = ISD.Brand__r.NABCA_Vendor__r.NABCA_Vendor_Description__c;
				tableRowChild.brandid = ISD.Brand__r.NABCA_Vendor__c;
			}
			tableRowChild.BrandName = ISD.Brand__r.Common_Description__c +' '+ ISD.Brand__r.NABCA_size_description__c;

            if(tableRow.volume == null) {
                tableRow.volume = 0;
            }
            if(tableRow.percentChange == null) {
                tableRow.percentChange = 0;
            }

			if(measurementType == VOLUME){       
				
				if(dateRange == LAST12){
					String string12Vol = 'Last_12_Months_Volume_' + selectedMonth + '__c';
					if(ISD.get(string12Vol)!= null) {
						Double value12Vol = Double.valueOf(ISD.get(string12Vol));
						tableRow.Volume += value12Vol;
						tableRowChild.Volume = value12Vol;
					}
					String string12Perc = 'Percent_Change_in_Volume_' + selectedMonth + '__c';
					if(ISD.get(string12Perc)!= null) {
						Double value12Perc = Double.valueOf(ISD.get(string12Perc));
						tableRow.percentChange += value12Perc;
						tableRowChild.percentChange = value12Perc;
					}
					String string12LastVol = 'Last_year_volume_data_' + selectedMonth + '__c';
					if(ISD.get(string12LastVol)!= null) {
						Double value12LastVol = Double.valueOf(ISD.get(string12LastVol));
						tableRow.LastYearVolume += value12LastVol;
						tableRowChild.LastYearVolume = value12LastVol;
					}
					VolumeHeader='Volume Last 12 Months';
					
				} else if(dateRange == CURRENTFISCAL){
					
					String stringVol = 'Volume_for_Fiscal_Year_' + selectedMonth + '__c';
					if(ISD.get(stringVol)!= null) {
						Double valueVol = Double.valueOf(ISD.get(stringVol));
						tableRow.Volume += valueVol;
						tableRowChild.Volume = valueVol;
					}
					String stringVolLast = 'Volume_For_Last_Fiscal_Year_' + selectedMonth + '__c';
					if(ISD.get(stringVolLast)!= null){
						Double valueVolLast = Double.valueOf(ISD.get(stringVolLast));
						tableRow.LastYearVolume += valueVolLast;
						tableRowChild.LastYearVolume = valueVolLast;
					}
					VolumeHeader='Volume Current Fiscal';
					
				} else if(dateRange == CURRENTMONTH){
					Boolean debugGroup = ISD.Brand__r.NABCA_Vendor__r.NABCA_Vendor_Description__c == 'WINE GROUP';
					String string36 = 'Month' + (36+monthOffset) + '_9L_Volume__c';
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE1: ' + string36));
					if(ISD.get(string36)!= null){
						Double value36 = Double.valueOf(ISD.get(string36));
						//if(debugGroup) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE2: ' + value36));
						tableRow.Volume += value36;
						tableRowChild.Volume = value36;
					}
					String string24 = 'Month' + (24+monthOffset) + '_9L_Volume__c';
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE3: ' + string24));
					if(ISD.get(string24) != null){
						Double value24 = Double.valueOf(ISD.get(string24));
						//if(debugGroup) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE4: ' + value24));
						tableRow.LastYearVolume += value24;
						tableRowChild.LastYearVolume = value24;
					}
					
					VolumeHeader = 'Volume';
					brandExpansionHeader = 'Volume';
					
				}
				tableRow.shelfDollarData = String.valueOf(tableRow.Volume.setScale(2).format());
				tableRow.percentChangeString = String.valueof(tableRow.percentChange.setScale(2));
				tableRowChild.expandedShelfDollarData = String.valueOf(tableRowChild.Volume.setScale(2));
			
			} else if(measurementType.equals(SHELF_DOLLAR)){
				
				if(dateRange.equals(LAST12)){
					String string12Vol = 'Last12_Months_Dollar_value_' + selectedMonth + '__c';
					if(ISD.get(string12Vol)!= null) {
						Double value12Vol = Double.valueOf(ISD.get(string12Vol));
						tableRow.Volume += value12Vol;
						tableRowChild.Volume = value12Vol;
					}
					String string12Perc = 'Percent_Change_in_Dollar_' + selectedMonth + '__c';
					if(ISD.get(string12Perc)!= null) {
						Double value12Perc = Double.valueOf(ISD.get(string12Perc));
						tableRow.percentChange += value12Perc;
						tableRowChild.percentChange = value12Perc;
					}
					String string12LastVol = 'Last_year_Shelfdollar_data_' + selectedMonth + '__c';
					if(ISD.get(string12LastVol)!= null) {
						Double value12LastVol = Double.valueOf(ISD.get(string12LastVol));
						tableRow.LastYearVolume += value12LastVol;
						tableRowChild.LastYearVolume = value12LastVol;
					}
					VolumeHeader = 'Shelf Dollar Last 12 Months';
					brandExpansionHeader = 'Shelf Dollar';

				} else if(dateRange==CURRENTFISCAL){
					String stringVol = 'ShelfDollar_for_Fiscal_Year_' + selectedMonth + '__c';
					if(ISD.get(stringVol)!= null) {
						Double valueVol = Double.valueOf(ISD.get(stringVol));
						tableRow.Volume += valueVol;
						tableRowChild.Volume = valueVol;
					}
					String stringVolLast = 'ShelfDollar_For_Last_Fiscal_Year_' + selectedMonth + '__c';
					if(ISD.get(stringVolLast)!= null){
						Double valueVolLast = Double.valueOf(ISD.get(stringVolLast));
						tableRow.LastYearVolume += valueVolLast;
						tableRowChild.LastYearVolume = valueVolLast;
					}
					VolumeHeader='Shelf Dollar Current Fiscal';
					
				} else if(dateRange==CURRENTMONTH){
					
					String string36 = 'Month' + (36+monthOffset) + '_ShelfDollar_Volume__c';
					if(ISD.get(string36)!= null){
						Double value36 = Double.valueOf(ISD.get(string36));
						tableRow.Volume += value36;
						tableRowChild.Volume = value36;
					}
					String string24 = 'Month' + (24+monthOffset) + '_ShelfDollar_Volume__c';
					if(ISD.get(string24) != null){
						Double value24 = Double.valueOf(ISD.get(string24));
						tableRow.LastYearVolume += value24;
						tableRowChild.LastYearVolume = value24;
					}
					VolumeHeader = 'Shelf Dollar';
					brandExpansionHeader = 'Shelf Dollar';
				}

				tableRow.shelfDollar = tableRow.Volume.setscale(2).format();
				tableRow.shelfDollarData = getCurrencyFromString(tableRow.shelfDollar);
				tableRow.expandedShelfDollar = tableRowChild.Volume.setScale(2).format();
				
				tableRow.expandedShelfDollarData = getCurrencyFromString(tableRow.expandedShelfDollar);				
				tableRowChild.expandedShelfDollarData = String.valueOf(tableRowChild.Volume.setScale(2));
				
			}
			
			if(tableRowList.size() < 1000){
            	tableRowList.add(tableRowChild);
			}
            tableRow.expandedBrandRow = tableRowList;
			if (selectedGroup.equals(VENDOR)) {
				brandRowMap.put(tableRow.brandid,tableRow);
			} else {
        		brandRowMap.put(ISD.Brand__r.NABCA_Category__c,tableRow);
			}

			internalBrandSetId.add(tableRow.brandid);

		}
		
		if(brandRowMap.Values().size()>0){
			showList = true;

			List<BrandRow> tableRowList = brandRowMap.values();
	
			topTenTableRowList = new List<BrandRow>();
			
			for(BrandRow br: tableRowList){
				if(br.volume > 0){ //) && br.brandName != 'NOT DEFINED'){
					if(topTenTableRowList.size() < 10){
						topTenTableRowList.add(br);
					} else if(selectedRecords==TOPTEN){
						Integer lowestIndex = -1;
						for(Integer i = 0; i < 10; i++){
							if(topTenTableRowList[i].volume < br.volume){
								if(lowestIndex == -1 || topTenTableRowList[i].volume < topTenTableRowList[lowestIndex].volume){
									lowestIndex = i;
								}
							}
						}
						if(lowestIndex != -1){
							topTenTableRowList[lowestIndex] = br;
						}
					} else {
						Integer highestIndex = -1;
						for(Integer i = 0; i < 10; i++){
							if(topTenTableRowList[i].volume > br.volume){
								if(highestIndex == -1 || topTenTableRowList[i].volume > topTenTableRowList[highestIndex].volume){
									highestIndex = i;
								}
							}
						}
						if(highestIndex != -1){
							topTenTableRowList[highestIndex] = br;
						}
					}
					if(br.LastYearVolume != null){
						totalLastYearShare += br.LastYearVolume;
					}
			
				}
			}
			
			
			for(BrandRow ISDV: topTenTableRowList){
	
				if(totalVolume != 0){
					ISDV.Share = (ISDV.volume/totalVolume)*100;
				} else {
					ISDV.Share = 0;
				}
	
				if(totalLastYearShare != 0){
					ISDV.LastYearShare = (ISDV.LastYearVolume/totalLastYearShare)*100;
				} else {
					ISDV.LastYearShare = 0;
				}
	
				ISDV.percentChangeShare = ISDV.Share-ISDV.LastYearShare;
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DAVE TEST, PLEASE IGNORE1: ' + ISDV.brandName +', ' + ISDV.volume + ', ' + ISDV.lastYearVolume));
				ISDV.percentChange = DiageoUtils.calculateShare(ISDV.volume,ISDV.LastYearVolume);
				
	
				if(ISDV.share != null) {
					TotalShare += ISDV.share;
				}
	
				if(ISDV.percentChangeShare != null) {
					totalPercentChangeShare += ISDV.percentChangeShare;
				}
				
				//sortUp(ISDV.expandedBrandRow);
				
				for(BrandRow ISDVE:ISDV.expandedBrandRow){
				  
					if(TotalVolume != 0 && ISDVE.volume != null){
						ISDVE.Share = (ISDVE.volume/TotalVolume)*100;
					} else {
						ISDVE.Share = 0;
					}
					
					if(ISDVE.lastYearVolume != null && totalLastYearShare != 0){
						ISDVE.LastYearShare = ((ISDVE.lastYearVolume/totalLastYearShare)*100);
					} else{
						ISDVE.LastYearShare = 0;
					}
					ISDVE.percentChangeShare = ISDVE.Share-ISDVE.LastYearShare;
					ISDVE.percentChange = DiageoUtils.calculateShare(ISDVE.Volume,ISDVE.LastYearVolume); 
					 
				}
				
			}
		}

	}
	
	/*
	 * Utility method which takes a number and turns it into a currency formatted string
	 */
	public String getCurrencyFromString(String strValue) {
		String s2 = strValue.substringAfterLast('.');
		integer n = s2.length();
		if (n == 0) {
			return '$ ' + strValue + '.00';
		} else if (n == 1) {
			return '$ ' + strValue + '0';
		} else {
			return '$ ' + strValue;
		}
		return null;
	} 

	public void sortDown(List<BrandRow> tableRowList){
		for(integer i = 0;i<tableRowList.size();i++){
			for(integer j = 0;j<tableRowList.size()-1;j++){
				if(tableRowList[j].volume > tableRowList[j+1].volume){
					BrandRow BrTemp = tableRowList[j+1];
					tableRowList[j+1] = tableRowList[j];
					tableRowList[j] = BrTemp;
				}
			}     
		}

	}   

	public void sortUp(List<BrandRow> tableRowList){
		for(integer i = 0;i<tableRowList.size();i++){
			for(integer j = 0;j<tableRowList.size()-1;j++){
				if(tableRowList[j].volume < tableRowList[j+1].volume){
					BrandRow BrTemp = tableRowList[j+1];
					tableRowList[j+1] = tableRowList[j];
					tableRowList[j] = BrTemp;
				}
			}     
		}

	}   
	
	public void setBevTypeToSpirits(){
		beverageType = SPIRIT;
	}

}