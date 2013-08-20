global class POS_OrderWindowRow implements Comparable {
	public Order_Window__c orderWindow {get;set;}
	public Integer monthSpan {get;set;}
	public Integer startMonth {get;set;}
	
	public POS_OrderWindowRow (Order_Window__c orderWindow) {
		this.orderWindow=orderWindow;
		startMonth = orderWindow.Order_Start_Date__c.month();
		monthSpan = orderWindow.Order_Start_Date__c.monthsBetween(orderWindow.Order_Close_Date__c);
		
	}
	
	global Integer compareTo(Object compareTo) {
	    POS_OrderWindowRow comparison = (POS_OrderWindowRow)compareTo;
	    return this.startMonth-comparison.startMonth;
	}
}