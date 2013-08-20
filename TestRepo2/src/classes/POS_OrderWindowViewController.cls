public class POS_OrderWindowViewController extends Controller_Base {

	public List <Order_Window_Customer__c> orderWindowCustomers {get;set;}
	public String baseUrl {get;set;}
	public String idpUrl {get;set;}
	
	public List<POS_BreadCrumb> breadcrumbs {get;set;} 
	public boolean ssoComplete {get;set;}
	//public boolean hasBrands {get;set;}
	
	//Maps magento Id for window to brand availability for user
	public Map <String,boolean> hasBrands {get;set;}
	
	public String hasBrandsJson {get;set;}
	
	
	
	public POS_OrderWindowViewController () {
		
		Id currentUser=UserInfo.getUserId();
		
		List<String> listOfVisibleWindowMagentoIds = new List<String>();
		
		//populate the order windows
		List <Order_Window_Customer__c> loadedOwc = [Select Open_For_Shopping__c, o.Order_Window__r.Name, o.Order_Window__r.Type__c, 
		 o.Order_Window__r.Status__c, o.Order_Window__r.Order_Start_Date__c, 
		 o.Order_Window__r.Order_Delivery_Date__c, o.Order_Window__r.Order_Close_Date__c, 
		 o.Order_Window__r.On_Demand_Site_URL__c, o.Order_Window__r.Magento_Id__c, 
		 o.Order_Window__r.Icon_Label__c from Order_Window_Customer__c o
		 where Customer__c = :currentUser and o.Order_Window__r.Status__c in ('Open','Budgeting','Closed', 'In Review') 
		 order by o.Order_Window__r.Type__c, o.Order_Window__r.Order_Start_Date__c
		]; 
		
		orderWindowCustomers=new List<Order_Window_Customer__c>();
		
		
		boolean foundQuarterly=false;
		boolean foundMonthly=false;
		
		//Need to filter order windows to ensure they meet business reqs beyond the initial query
		for (Order_Window_Customer__c owc:loadedOwc) {
			if (owc.Open_For_Shopping__c) {
				//Add any windows that are open to this user
				orderWindowCustomers.add(owc);
				listOfVisibleWindowMagentoIds.add(owc.Order_Window__r.Magento_Id__c);
				if (owc.Order_Window__r.Type__c=='Quarterly') {
					foundQuarterly=true;
					System.debug('FOUND QUARTERLY');
				}
				if (owc.Order_Window__r.Type__c=='Monthly'){
					foundMonthly=true;
					System.debug('FOUND MONTHLY');

				}
			}
			else {
				//If the window is not open to this user, add if it was recently closed
				if (owc.Order_Window__r.Status__c=='Closed') {
					DateTime thisTime = System.now();
					DateTime pastTime=thisTime.addDays(-5);
					if (pastTime<owc.Order_Window__r.Order_Close_Date__c &&
					     owc.Order_Window__r.Order_Close_Date__c<thisTime) {
						orderWindowCustomers.add(owc);
						if (owc.Order_Window__r.Type__c=='Quarterly') {
							foundQuarterly=true;
						}
						if (owc.Order_Window__r.Type__c=='Monthly'){
							foundMonthly=true;
						}
					}
				}
			}
		}
		
		//Now, if there aren't any order windows we need to just include the next 
		//upcoming window
		
		if (!foundQuarterly || !foundMonthly) {
			for (Order_Window_Customer__c owc:loadedOwc) {
				if (owc.Order_Window__r.Status__c=='In Review' || owc.Order_Window__r.Status__c=='Budgeting') {
					if (owc.Order_Window__r.Type__c=='Quarterly') {
						if (foundQuarterly) {
							continue;
						}
						else {
							System.debug('Added quarterly open window');
							orderWindowCustomers.add(owc);
							foundQuarterly=true;
						}
					}
					else if (owc.Order_Window__r.Type__c=='Monthly'){
						if (foundMonthly) {
							continue;
						}
						else {
							System.debug('Added monthly open window');
							orderWindowCustomers.add(owc);
							foundMonthly=true;
						}
					}
					
				}
			}
		}
		
		//Get a list of visible order windows 
		//populateBrandList(listOfVisibleWindowMagentoIds, currentUser);
		
		
		System.debug('Order windows: '+orderWindowCustomers);
		
		POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
       	baseUrl = settings.Magento_Catalog_Path__c;
       	idpUrl = settings.IDP_Url__c;
		
		
       	breadCrumbs = new List<POS_BreadCrumb>();
       	breadCrumbs.add(new POS_BreadCrumb('POS','#'));
		
	    
	}
	
	//This is commented out because the call to this method was commented out above.  
	/*private void populateBrandList (List<String> displayedOrderWindowMagentoIds, String currentUser) {
		//Get list of user's brands
		List<AccountBrand__c> accountBrands = [select Id,Brand__c from AccountBrand__c where Account__c in (select Account__c from Account_Member__c where User__c = :currentUser)];
	
		List<Program__c> programs = [select Brand__c, Order_Window__r.Magento_Id__c from Program__c where Order_Window__r.Magento_Id__c in :displayedOrderWindowMagentoIds];
		
		//Build map of brands to order windows
		Map<Id,List<Order_Window__c>> brandToWindowMap = new Map<Id,List<Order_Window__c>>();
		for (Program__c program:programs) {
			List<Order_Window__c> windowList = brandToWindowMap.get(program.Brand__c);
			if (windowList == null) {
				windowList = new List<Order_Window__c>();
		    	brandToWindowMap.put(program.Brand__c,windowList);
			}
			windowList.add(program.Order_Window__r);
		}
		
		//Now iterate through account brands and flag the windows that are allowed
		
		//First, initialize the map with false values
		for (String id:displayedOrderWindowMagentoIds) {
			hasBrands.put(id,false);
		}
		
		//Now add trues where applicable
		for (AccountBrand__c acctBrand:accountBrands) {
			List<Order_Window__c> windowList = brandToWindowMap.get(acctBrand.Brand__c);
			for (Order_Window__c window:windowList) {
				hasBrands.put(window.Magento_Id__c,true);
			}
		}
		
		hasBrandsJson='';
		//hasBrandsJson = System.JSON.serialize(hasBrands);
	}*/

	
	@isTest
	public static void testOrderWindow () {
		Profile p = [select id from profile where name='System Administrator'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {
			Test.startTest();
			PageReference pageRef = Page.HomePage;
        	Test.setCurrentPage(pageRef);
        	
			Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
			
			Order_Window_Customer__c owc = new Order_Window_Customer__c();
			owc.Customer__c = u.Id;
			owc.Order_Window__c = ow.Id;
			insert owc;
			
			POS_OrderWindowViewController controller = new POS_OrderWindowViewController();
			
			//Should have zero right now because window was in wrong state
			System.assert(controller.orderWindowCustomers.size()==0);
			
			ow.Status__c='Open';
			update ow;
			owc.Open_For_Shopping__c = true;
			update owc;
			
			
			controller = new POS_OrderWindowViewController();
			//Should have one right now because window is in open state
			System.assert(controller.orderWindowCustomers.size()==1);
			
			ow.Status__c='Closed';
			update ow;
			owc.Open_For_Shopping__c = false;
			update owc;
			
			controller = new POS_OrderWindowViewController();
			//Should have none right now because window is closed and not open for shopping
			System.assert(controller.orderWindowCustomers.size()==0);
			
			ow.Status__c='Budgeting';
			update ow;
			owc.Open_For_Shopping__c = false;
			update owc;
			
			controller = new POS_OrderWindowViewController();
			
			Test.stopTest();
			
		}
	}
	    
    // for HTML conditional comments
    public String getLt(){
		return '<';
	}
		
	public String getGt(){
		return '>';
	}	
}