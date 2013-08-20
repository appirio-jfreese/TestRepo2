public without sharing class BreadcrumbsHolder {
	public list<OrganizationalUnit> ouSteps { public get; public set; }
	public map<id, Organizational_Unit__c> organizationalUnitsMap {get; set;} // helper
	 
 	public BreadcrumbsHolder(){
		ouSteps = new list<OrganizationalUnit>();
		organizationalUnitsMap = new map<id, Organizational_Unit__c>();
 	}
 
 
 	public void setupOrganizationalUnitsMap (list<Organizational_Unit__c> ol){
 		organizationalUnitsMap = new map<id, Organizational_Unit__c>(ol);
 	}
 
 	public void addOrganizationalUnit(OrganizationalUnit o){
 		ouSteps.add(o);
 	}	

	public void clear(){
		ouSteps = new list<OrganizationalUnit>();
	}
}