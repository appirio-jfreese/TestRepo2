/*
Last Modified by : Jai Gupta
Date : Nov 29,2012
Related to case : 00003340 , show sorted column first by Rep name then by account name.
*/

public class Controller_ActivitiesByAcct 
{
	
	public List<DataObj> dataObjList{get;set;}
	public Integer fieldCount{get;set;}
	public Map<Integer,String> mapOfIntegerToFieldName{get;set;}
	/*Changes done by Jai Gupta for case #00003340 on Nov 29,2012*/
	public Map<String,List<DataObj>> mapToSortValuesRepName ;
	
	public Controller_ActivitiesByAcct() 
	{
		/*Changes done by Jai Gupta for case #00003340 on Nov 29,2012*/
		mapToSortValuesRepName = new Map<String,List<DataObj>>();
		dataObjList = new List<DataObj>();
		initData();
	}
	
	public void initData()
	{
		fieldCount = 0;
		Map<Id,DataObj> mapDataObjsByAccountId = new Map<Id,DataObj>();
		mapOfIntegerToFieldName = new Map<Integer,String>();
		mapOfObjectiveNameToDataFieldName = new Map<String,Integer>();
		/*Changes done by Jai Gupta for case #00003340 on Nov 29,2012*/
		List<DataObj> unsortedDataObjList = new List<DataObj>(); 
		for(Action__c action : [select Id, Objective__r.Name, OwnerId, Account__c, Account__r.Name, Objective__c, Status__c,
									Account__r.OwnerId, Account__r.Owner.Name
									from Action__c
									where Account__c <> null
									and Objective__c <> null
									and Objective__r.due_date__c > TODAY
									
									order by account__r.OwnerId])
									//order by account__r.Owner.Name
		{
			putActionDataIntoMap(action, mapDataObjsByAccountId);
			/*Changes done by Jai Gupta for case #00003340 on Nov 29,2012*/
			unsortedDataObjList = mapDataObjsByAccountId.values();
		}
		/*Changes done by Jai Gupta for case #00003340 on Nov 29,2012*/
		createMapToSortByRepName(unsortedDataObjList);
		doRidiculousActionsBecauseOfVfLimitations();
	}
	/*Method added by Jai Gupta for case #00003340 on Nov 29,2012*/
	private void createMapToSortByRepName(List<DataObj> unsortedDataObjList) {
		for(DataObj dobj : unsortedDataObjList){
			list<dataObj> dObjList = mapToSortValuesRepName.get(dobj.rep);
			if(dObjList == null) {
				dObjList = new list<dataObj>();
			}
			dObjList.add(dobj);
			mapToSortValuesRepName.put(dObj.rep,dObjList);
		}
		list<string> repSetToList = new list<string>();
		repSetToList.addAll(mapToSortValuesRepName.keySet());
		repSetToList.sort();
		secondSortUsingAccountName(repSetToList);
	}
	/*Method added by Jai Gupta for case #00003340 on Nov 29,2012*/
	private void secondSortUsingAccountName(List<string> sortedReps) {
		for(String repName : sortedReps) {
			list<DataObj> listOfDObj = mapToSortValuesRepName.get(repName);
			listOfDObj.sort();
			dataObjList.addAll(listOfDObj);
		}
	}
	
	private Map<String,Integer> mapOfObjectiveNameToDataFieldName;
	private void putActionDataIntoMap(Action__c action, Map<Id,DataObj> mapDataObjsByAccountId)
	{
		DataObj obj = mapDataObjsByAccountId.get(action.Account__c);
		
		if(obj == null)
			obj = new DataObj(action.Account__r.Name, action.Account__c, action.Account__r.Owner.Name);
		
		Integer fieldNumberInt = mapOfObjectiveNameToDataFieldName.get(action.Objective__r.Name);
		
		if(fieldNumberInt > 0) {
			setDataObjValueFromFieldNumber(fieldNumberInt, obj, action.Status__c);
		}else{
			fieldCount++;
			fieldNumberInt = fieldCount;
			mapOfObjectiveNameToDataFieldName.put(action.Objective__r.Name, fieldNumberInt);
			mapOfIntegerToFieldName.put(fieldNumberInt, action.Objective__r.Name);
			
			setDataObjValueFromFieldNumber(fieldNumberInt, obj, action.Status__c);
		}
		
		mapDataObjsByAccountId.put( action.Account__c, obj );
		
	}
	
	private void setDataObjValueFromFieldNumber(Integer fieldNumberInt, DataObj obj, String value)
	{
		if(fieldNumberInt == 1)
			obj.activity1Status = value;
		
		if(fieldNumberInt == 2)
			obj.activity2Status = value;
		
		if(fieldNumberInt == 3)
			obj.activity3Status = value;
		
		if(fieldNumberInt == 4)
			obj.activity4Status = value;
		
		if(fieldNumberInt == 5)
			obj.activity5Status = value;
		
		if(fieldNumberInt == 6)
			obj.activity6Status = value;
			
		if(fieldNumberInt == 7)
			obj.activity7Status = value;
		
		if(fieldNumberInt == 8)
			obj.activity8Status = value;
		
		if(fieldNumberInt == 9)
			obj.activity9Status = value;
		
		if(fieldNumberInt == 10)
			obj.activity10Status = value;
		
		if(fieldNumberInt == 11)
			obj.activity11Status = value;
		
		if(fieldNumberInt == 12)
			obj.activity12Status = value;
		
		if(fieldNumberInt == 13)
			obj.activity13Status = value;
		
		if(fieldNumberInt == 14)
			obj.activity14Status = value;
			
		if(fieldNumberInt == 15)
			obj.activity15Status = value;
	}
	
	private String getFieldNameFromInteger(Integer i)
	{
		return 'activity' + String.valueOf(i) + 'Status';
	}
	
	public Component.Apex.PageBlockTable getDynamicPageBlockTableContent()
	{
		Component.Apex.PageblockTable table = new Component.Apex.PageblockTable();
		table.value = dataObjList;
		table.var = 'obj';
		
		Component.Apex.Column column1 = new Component.Apex.Column();
		column1.expressions.value = '{!obj.accountName}';
		table.childComponents.add(column1);
		
		for (Integer i = 1; i <= 15; i++) {
			String headerValue = mapOfIntegerToFieldName.get(i);
			if(headerValue != null) 
			{
				Component.Apex.Column column = new Component.Apex.Column();
				Component.Apex.OutputText outputText = new Component.Apex.OutputText();
				outputText.escape = false;
				//outputText.expressions.value = '<img src=\'{!URLFOR($Resource.dashboardButtons, \'yellowButton.jpg\')}\'  />' ;
				//outputText.expressions.rendered = '{!(obj.' + getFieldNameFromInteger(i) + ' == \'Closed - Incomplete\')}';
				
				
				Component.Apex.Image img1 = new Component.Apex.Image();
				img1.expressions.value = '{!URLFOR($Resource.dashboardButtons, \'yellowButton.jpg\')}' ;
				
				Component.Apex.Image img2 = new Component.Apex.Image();
				img2.expressions.value = '{!URLFOR($Resource.dashboardButtons, \'greenButton.jpg\')}' ;
				img2.expressions.styleClass = '{!IF(obj.' + getFieldNameFromInteger(i) + ' == \'Closed - Complete\', \'display:none\', \'\')}';
				
				Component.Apex.Image img3 = new Component.Apex.Image();
				img3.expressions.value = '{!URLFOR($Resource.dashboardButtons, \'redButton.jpg\')}' ;
				img3.expressions.rendered = '{!obj.' + getFieldNameFromInteger(i) + ' == \'Closed - Incomplete\'}';
				
				Component.Apex.Image img4 = new Component.Apex.Image();
				img4.expressions.value = '{!URLFOR($Resource.dashboardButtons, \'greenButton.jpg\')}' ;
				
				//column.childComponents.add(img1);
				column.childComponents.add(img2);
				//column.childComponents.add(img3);
				//column.childComponents.add(img4);
				//column.childComponents.add(outputText);
				
				//column.expressions.value = '<img src=\'{!obj.' + getFieldNameFromInteger(i) + '}\' />';
				column.headerValue = headerValue;
				table.childComponents.add(column);
			}
		}
		return table ;
	}
	
	private void doRidiculousActionsBecauseOfVfLimitations()
	{
		label1 = mapOfIntegerToFieldName.get(1);
		label2 = mapOfIntegerToFieldName.get(2);
		label3 = mapOfIntegerToFieldName.get(3);
		label4 = mapOfIntegerToFieldName.get(4);
		label5 = mapOfIntegerToFieldName.get(5);
		label6 = mapOfIntegerToFieldName.get(6);
		label7 = mapOfIntegerToFieldName.get(7);
		label8 = mapOfIntegerToFieldName.get(8);
		label9 = mapOfIntegerToFieldName.get(9);
		label10 = mapOfIntegerToFieldName.get(10);
		label11 = mapOfIntegerToFieldName.get(11);
		label12 = mapOfIntegerToFieldName.get(12);
		label13 = mapOfIntegerToFieldName.get(13);
		label14 = mapOfIntegerToFieldName.get(14);
		label15 = mapOfIntegerToFieldName.get(15);
	}
	
	public String label1{get;set;}
	public String label2{get;set;}
	public String label3{get;set;}
	public String label4{get;set;}
	public String label5{get;set;}
	public String label6{get;set;}
	public String label7{get;set;}
	public String label8{get;set;}
	public String label9{get;set;}
	public String label10{get;set;}
	public String label11{get;set;}
	public String label12{get;set;}
	public String label13{get;set;}
	public String label14{get;set;}
	public String label15{get;set;}
	
	
	/*Changes done by Jai Gupta for case #00003340 on Nov 29,2012*/
	public class DataObj implements Comparable
	{
		public String accountName {get; set;}
		public Id accountId{get; set;}
		public String rep{get;set;}
		
		public String activity1Status{get;set;}
		public String activity2Status{get;set;}
		public String activity3Status{get;set;}
		public String activity4Status{get;set;}
		public String activity5Status{get;set;}
		public String activity6Status{get;set;}
		public String activity7Status{get;set;}
		public String activity8Status{get;set;}
		public String activity9Status{get;set;}
		public String activity10Status{get;set;}
		public String activity11Status{get;set;}
		public String activity12Status{get;set;}
		public String activity13Status{get;set;}
		public String activity14Status{get;set;}
		public String activity15Status{get;set;}
		
		
		public DataObj(String accountName, Id accountId, String ownerName) 
		{
			this.accountName = accountName ;
			this.accountId = accountId;
			this.rep = ownerName;
		}
		/*Method implemented by Jai Gupta for case #00003340 on Nov 29,2012*/
		public Integer compareTo(Object objToCompare) {

        //Sort by Account name Alphabetically
            return accountName.compareTo(((DataObj)objToCompare).accountName);

        }
	}
}