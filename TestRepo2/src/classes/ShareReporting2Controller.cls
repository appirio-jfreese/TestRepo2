public without sharing class ShareReporting2Controller {
	
	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'wha ' + q));
	
	private final String VENDOR			= 'Vendor';
	private final String CATEGORY		= 'Category';
	private final String CURRENT		= 'Current Month';
	private final String FISCAL			= 'Current Fiscal Year';
	private final String LAST12			= 'Last 12 Months';
	private final String All			= 'All';
	private final String SPIRITS		= 'Spirits';
	private final String WINE			= 'Wines';
	private final String VOLUME			= 'Volume';
	private final String SHELF			= 'Shelf Dollar';
	private final Map<Integer, String> monthMap = new Map<Integer, String>
		{1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun',
		 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'};
	
	private Account accRecord						{get;set;}
	
	public List<SelectOption> filterBySOs			{get;set;}
	public List<SelectOption> monthSOs				{get;set;}
	public List<SelectOption> dateRangeSOs			{get;set;}
	public List<SelectOption> typeSOs				{get;set;}
	public List<SelectOption> valueSOs				{get;set;}
	
	public String filterBySel						{get;set;}
	public String monthSel							{get;set;}
	public String dateRangeSel						{get;set;}
	public String typeSel							{get;set;}
	public String valueSel							{get;set;}
	
	public Integer latestDataMonth					{get;set;}
	public Integer latestDataYear					{get;set;}
	public String latestDataMonthYear				{get;set;}
	
	private String valueField						{get;set;}
	private String lastValueField					{get;set;}
	private String currentShareField				{get;set;}
	private String previousShareField				{get;set;}
	private String groupingField					{get;set;}
	
	public Map<String, DataRow> allDataByGrouping	{get;set;}
	public List<DataRow> allData					{get;set;}
	public String selectedRowLabel					{get;set;}
	public DataRow currentExpandedRow				{get;set;}
	
	public String oldSortField						{get;set;}
	public String sortField							{get;set;}
	public String sortDirection						{get;set;}
	
	public Decimal totalValue						{get;set;}
	public Decimal totalLastValue					{get;set;}
	public Decimal totalValueChange					{get;set;}
	
	public class DataRow {
		public String label							{get;set;}
		public Decimal value						{get;set;}
		public Decimal lastValue					{get;set;}
		public String valueChange					{get;set;}
		public String share							{get;set;}
		public String lastShare						{get;set;}
		public String shareChange					{get;set;}
		public Boolean valueChangeIsNeg				{get;set;}
		public Boolean shareChangeIsNeg				{get;set;}
		
		public List<DataRow> children				{get;set;}
		public Boolean isExpanded					{get;set;}
		public Boolean isChild						{get;set;}
		
		public DataRow(String label){
			this.label = label;
		}
		
		public void finalize(Decimal totalValue, Decimal totalLastValue){
			valueChange = calculateChangeString(value, lastValue, 0);
			share = calculateShareString(value, totalValue, 2);
			lastShare = calculateShareString(lastValue, totalLastValue, 2);
			if(share != 'N/A' && lastShare != 'N/A'){
				Decimal sChange = Decimal.valueOf(share) - Decimal.valueOf(lastShare);
				sChange.setScale(2);
				shareChange = String.valueOf(sChange);
			} else {
				shareChange = 'N/A';
			}
			value = value.setScale(2);
			valueChangeIsNeg = valueChange.contains('-');
			shareChangeIsNeg = shareChange.contains('-');
			
			if(children != null){
				for(DataRow childRow : children){
					childRow.finalize(totalValue, totalLastValue);
				}
			}
		}
		
		private String calculateChangeString(Decimal numerator, Decimal denominator, Integer scale){
			if(denominator > 0){
				Decimal retValue = (numerator - denominator) / denominator * 100;
				return String.valueOf(retValue.setScale(scale));
			}
			return 'N/A';
		}
		
		private String calculateShareString(Decimal numerator, Decimal denominator, Integer scale){
			if(denominator > 0){
				Decimal retValue = numerator / denominator * 100;
				return String.valueOf(retValue.setScale(scale));
			}
			return 'N/A';
		}
	}
	
	public ShareReporting2Controller(ApexPages.StandardController controller){
		accRecord = (Account)controller.getRecord();
		populateDefaultSelections();
		prepareQueryFields();
		populateDropDowns();
	}
	
	private void populateDefaultSelections(){
		filterBySel = CATEGORY;
		monthSel = '0';
		dateRangeSel = CURRENT;
		typeSel = ALL;
		valueSel = VOLUME;
	}
	
	private void populateDropDowns(){
		filterBySOs = new List<SelectOption>();
		filterBySOs.add(new SelectOption(CATEGORY, CATEGORY));
		filterBySOs.add(new SelectOption(VENDOR, VENDOR));
		
		monthSOs = new List<SelectOption>();
		Integer monthCounter = latestDataMonth;
		Integer yearCounter = latestDataYear;
		for(Integer i = 0; i < 13; i++) {
			monthSOs.add(new SelectOption(i + '', monthmap.get(monthCounter) + ' ' + yearCounter));
			monthCounter--;
			if (monthCounter == 0) {
				monthCounter = 12;
				yearCounter--;
			}
		}
		
		dateRangeSOs = new List<SelectOption>();
		dateRangeSOs.add(new SelectOption(CURRENT, CURRENT));
		dateRangeSOs.add(new SelectOption(FISCAL, FISCAL));
		dateRangeSOs.add(new SelectOption(LAST12, LAST12));
		
		typeSOs = new List<SelectOption>();
		typeSOs.add(new SelectOption(ALL, ALL));
		typeSOs.add(new SelectOption(SPIRITS, SPIRITS));
		typeSOs.add(new SelectOption(WINE, WINE));
		
		valueSOs = new List<SelectOption>();
		valueSOs.add(new SelectOption(VOLUME, VOLUME));
		valueSOs.add(new SelectOption(SHELF, SHELF));
	}
	
	public void prepareQueryFields(){
		if(dateRangeSel == CURRENT){
			Integer monthOffset = -1 * Integer.valueOf(monthSel);
			if(valueSel == VOLUME){
				valueField = 'Month' + (36 + monthOffset) + '_9L_Volume__c';
				lastValueField = 'Month' + (24 + monthOffset) + '_9L_Volume__c';
			} else if(valueSel == SHELF){
				valueField = 'Month' + (36 + monthOffset) + '_ShelfDollar_Volume__c';
				lastValueField = 'Month' + (24 + monthOffset) + '_ShelfDollar_Volume__c';
			}
		} else if(dateRangeSel == FISCAL){
			Integer monthOffset = 1 + Integer.valueOf(monthSel);
			if(valueSel == VOLUME){
				valueField = 'Volume_for_Fiscal_Year_' + monthOffset + '__c';
				lastValueField = 'Volume_for_Last_Fiscal_Year_' + monthOffset + '__c';
			} else if(valueSel == SHELF){
				valueField = 'ShelfDollar_for_Fiscal_Year_' + monthOffset + '__c';
				lastValueField = 'ShelfDollar_for_Last_Fiscal_Year_' + monthOffset + '__c';
			}
		} else if(dateRangeSel == LAST12){
			Integer monthOffset = 1 + Integer.valueOf(monthSel);
			if(valueSel == VOLUME){
				valueField = 'Last_12_Months_Volume_' + monthOffset + '__c';
				lastValueField = 'Last_12_Months_Volume_' + (monthOffset + 12) + '__c';
			} else if(valueSel == SHELF){
				valueField = 'Last12_Months_Dollar_value_' + monthOffset + '__c';
				lastValueField = 'Last12_Months_Dollar_value_' + (monthOffset + 12) + '__c';
			}
		}
		if(filterBySel == VENDOR){
			groupingField = 'Brand__r.NABCA_Vendor__r.NABCA_Vendor_Description__c';
		} else if(filterBySel == CATEGORY){
			groupingField = 'Brand__r.Nabca_Category__r.NABCA_Major_Category_Description__c';
		}
		queryData();
	}
	
	private void queryData(){
		Set<String> top10GroupNames = new Set<String>();
		String q = '';
		q += 'SELECT SUM(' + valueField + ') value';
		q += ', SUM(' + lastValueField + ') lastValue';
		q += ', ' + groupingField + ' groupName';
		q += ' FROM NABCA_Sales_Data__c';
		q += ' WHERE Account__c =\'' + accRecord.id + '\'';
		q += ' AND ' + groupingField + ' != null';
		//q += ' AND ' + groupingField + ' != \'NOT DEFINED\'';
		q += ' GROUP BY ' + groupingField;
		q += ' ORDER BY SUM(' + valueField + ') DESC';
		
		List<AggregateResult> agrs = Database.query(q);
		totalValue = 0;
		totalLastValue = 0;		
		
		for(Integer i = 0; i < agrs.size(); i++){
			AggregateResult agr = agrs[i];
			totalValue += (Decimal)(agr.get('value'));
			totalLastValue += (Decimal)(agr.get('lastValue'));
			if(i < 10){
				top10GroupNames.add(String.valueOf(agr.get('groupName')));
			}
		}
		
		q = '';
		q += 'SELECT Id';
		q += ', Month_End_Date__c';
		q += ', ' + valueField;
		q += ', ' + lastValueField;
		q += ', ' + groupingField;
		q += ', Brand__r.Common_Description__c';
		q += ', Brand__r.NABCA_size_description__c';
		q += ' FROM NABCA_Sales_Data__c';
		q += ' WHERE Account__c =\'' + accRecord.id + '\'';
		q += ' AND ' + groupingField + ' IN :top10GroupNames';
		
		if(typeSel == SPIRITS){
			q += ' AND Brand__r.NABCA_Beverage_Type_Description__c = \'SPIRIT\'';
		} else if(typeSel == WINE){
			q += ' AND Brand__r.NABCA_Beverage_Type_Description__c = \'WINE\'';
		}
		
		q += ' AND (' + valueField + ' > 0';
		q += ' OR ' + lastValueField + ' > 0)';
		
		q += ' ORDER BY ' + valueField + ' DESC';
		
		System.debug('*** ' + q);
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'wha ' + q));
		
		allDataByGrouping = new Map<String, DataRow>();
		//Map<String, DataRow> allDataByGroupingAndBrandKey = new Map<String, DataRow>();
		
		for(NABCA_Sales_Data__c nsd : Database.query(q)){
			if(latestDataMonthYear == null){
				Date endDate = nsd.Month_End_Date__c;
				System.debug('&&&' + endDate);
				latestDataMonth = endDate.month();
				latestDataYear = endDate.year();
				latestDataMonthYear = monthMap.get(latestDataMonth) + ' ' +
									  endDate.year();
			}
			
			String groupName;
			if(filterBySel == VENDOR){
				groupName = nsd.Brand__r.NABCA_Vendor__r.NABCA_Vendor_Description__c;
			} else if(filterBySel == CATEGORY){
				groupName = nsd.Brand__r.Nabca_Category__r.NABCA_Major_Category_Description__c;
			}
			DataRow dataRow = allDataByGrouping.get(groupName);
			if(dataRow == null){
				dataRow = new DataRow(groupName);
				dataRow.value = 0;
				dataRow.lastValue = 0;
				dataRow.children = new List<DataRow>();
				dataRow.isExpanded = false;
				dataRow.isChild = false;
			}
			Decimal value = (Decimal)(nsd.get(valueField));
			dataRow.value += value;
			
			Decimal lastValue = (Decimal)(nsd.get(lastValueField));
			dataRow.lastValue += lastValue;
			
			if(dataRow.children.size() < 990){
				DataRow childRow = new DataRow(nsd.Brand__r.Common_Description__c + ' ' + nsd.Brand__r.NABCA_size_description__c);
				childRow.isChild = true;
				childRow.value = value;
				childRow.lastValue = lastValue;
				dataRow.children.add(childRow);
			}
			
			/*String brandName = nsd.Brand__r.Common_Description__c + ' ' + nsd.Brand__r.NABCA_size_description__c;
			String key = dataRow.label + '|' + brandName;
			DataRow existingChildRow = allDataByGroupingAndBrandKey.get(key);
			if(existingChildRow == null){
				DataRow childRow = new DataRow(brandName);
				childRow.isChild = true;
				childRow.value = value;
				childRow.lastValue = lastValue;
				dataRow.children.add(childRow);
				allDataByGroupingAndBrandKey.put(key, childRow);
			} else {
				existingChildRow.value += value;
				existingChildRow.lastValue += value;
				allDataByGroupingAndBrandKey.put(key, existingChildRow);
			}*/
			
			allDataByGrouping.put(groupName, dataRow);
		}
		
		for(DataRow row : allDataByGrouping.values()){
			row.finalize(totalValue, totalLastValue);
		}
		rebuildAllData();
		
		totalValue = totalValue.setScale(2);
		totalValueChange = 0;
		if(totalLastValue > 0){
			totalValueChange = (totalValue - totalLastValue) / totalLastValue * 100;
		}
		totalValueChange = totalValueChange.setScale(2);
	}
	
	private void rebuildAllData(){
		allData = new List<DataRow>();
		for(DataRow row : allDataByGrouping.values()){
			allData.add(row);
		}
		
		if(sortField == null){
			sortField = 'value';
		}
		
		sortData(allData);
		
		List<DataRow> tempData = new List<DataRow>();
		for(DataRow row : allData){
			tempData.add(row);
			if(row.isExpanded){
				sortData(row.children);
				for(DataRow childRow : row.children){
					tempData.add(childRow);
				}
			}
		}
		allData = tempData;
	}
	
	public void sortData(){
		if(sortField == oldSortField){
			if(sortDirection == 'ASC'){
				sortDirection = 'DESC';
			} else {
				sortDirection = 'ASC';
			}
		}
		rebuildAllData();
	}
	
	public void sortData(List<DataRow> dataToSort){
		if(sortField == oldSortField){
		} else {
			oldSortField = sortField;
			if(sortField == 'label'){
				sortDirection = 'DESC';
			} else {
				sortDirection = 'ASC';
			}
		}
		
		Integer dataSize = dataToSort.size();
		Integer inc = Integer.valueOf(Math.floor(dataSize / 2));
		
		while(inc > 0){
			for(Integer i = inc; i < dataSize; i++){
				DataRow tmp = dataToSort[i];
				Integer j;
				if(sortField == 'label'){
					String tmpValue = tmp.label;
					for(j = i;
						j >= inc &&
						(sortDirection == 'ASC' && dataToSort[j - inc].label < tmpValue
						 || sortDirection == 'DESC' && dataToSort[j - inc].label > tmpValue);
						j -= inc){
							dataToSort[j] = dataToSort[j - inc];
					}
				}
				if(sortField == 'value'){
					Decimal tmpValue = tmp.value;
					for(j = i;
						j >= inc &&
						(sortDirection == 'ASC' && dataToSort[j - inc].value < tmpValue
						 || sortDirection == 'DESC' && dataToSort[j - inc].value > tmpValue);
						j -= inc){
							dataToSort[j] = dataToSort[j - inc];
					}
				}
				if(sortField == 'valueChange'){
					Decimal tmpValue = convertToDecimal(tmp.valueChange);
					for(j = i;
						j >= inc &&
						(sortDirection == 'ASC' && convertToDecimal(dataToSort[j - inc].valueChange) < tmpValue
						 || sortDirection == 'DESC' && convertToDecimal(dataToSort[j - inc].valueChange) > tmpValue);
						j -= inc){
							dataToSort[j] = dataToSort[j - inc];
					}
				}
				if(sortField == 'share'){
					Decimal tmpValue = convertToDecimal(tmp.share);
					for(j = i;
						j >= inc &&
						(sortDirection == 'ASC' && convertToDecimal(dataToSort[j - inc].share) < tmpValue
						 || sortDirection == 'DESC' && convertToDecimal(dataToSort[j - inc].share) > tmpValue);
						j -= inc){
							dataToSort[j] = dataToSort[j - inc];
					}
				}
				if(sortField == 'shareChange'){
					Decimal tmpValue = convertToDecimal(tmp.shareChange);
					for(j = i;
						j >= inc &&
						(sortDirection == 'ASC' && convertToDecimal(dataToSort[j - inc].shareChange) < tmpValue
						 || sortDirection == 'DESC' && convertToDecimal(dataToSort[j - inc].shareChange) > tmpValue);
						j -= inc){
							dataToSort[j] = dataToSort[j - inc];
					}
				}
				dataToSort[j] = tmp;
			}
			inc = Math.round(inc / 2.2);
		}
	}
	
	private Decimal convertToDecimal(String s){
		try {
			return Decimal.valueOf(s);
		} catch(Exception e){
		}
		if(sortDirection == 'ASC'){
			return -1000000;
		}
		return 1000000;
	}
	
	public void expandRow(){
		if(currentExpandedRow != null){
			currentExpandedRow.isExpanded = false;
		}
		currentExpandedRow = allDataByGrouping.get(selectedRowLabel);
		currentExpandedRow.isExpanded = true;
		rebuildAllData();
	}
	
	public void collapseRow(){
		currentExpandedRow = allDataByGrouping.get(selectedRowLabel);
		currentExpandedRow.isExpanded = false;
		currentExpandedRow = null;
		rebuildAllData();
	}

}