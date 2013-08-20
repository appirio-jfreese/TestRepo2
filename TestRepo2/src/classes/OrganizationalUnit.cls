global without sharing class OrganizationalUnit implements Comparable {

	public String organizationalUnitId {public get; public set;}
	public String organizationalUnitName {public get; public set;}
	public list<OrganizationalUnit> organizationalUnits {public get; public set;}	
	public list<Account> distributors {public get; public set;}

	public OrganizationalUnit(String ouId, String ouName) {
		organizationalUnitId = ouId;
		organizationalUnitName = ouName;
		organizationalUnits = new List<OrganizationalUnit>();
		distributors = new List<Account>();
	}

	public void addOrganizationalUnit(OrganizationalUnit subOu){
		organizationalUnits.add(subOu);
		organizationalUnits.sort();
	}

	public void assignDistributors(List<Account> a){
		distributors = a;
		distributors.sort();
	}
	
	// sort
    global Integer compareTo(Object compareTo) {
        OrganizationalUnit compareTo1 = (OrganizationalUnit)compareTo;
        if (organizationalUnitName == compareTo1.organizationalUnitName) return 0;
        if (organizationalUnitName > compareTo1.organizationalUnitName) return 1;
        return -1;        
    }
}