public class POS_OrderTimelineController extends Controller_Base {

	
	private Id currentUser {get;set;}
	public String baseUrl {get;set;}
	public String idpUrl {get;set;}
	
	public integer selectedYear {get;set;}
	private DateTime selectedDateTime {get;set;}
	
	public List <Order_Window_Customer__c> orderWindowCustomers {get;set;}
	public List<POS_BreadCrumb> breadCrumbs {get;set;}
	public Map<Id,List<Program__c>> programs {get;set;}
	
	public List<CalendarDisplay> calendarDisplays {get;set;}
	public List<POS_OrderWindowRow> orderWindowRows {get;set;}
	
	public Map <Id,Cart__c> carts {get;set;}
	
	public POS_OrderTimelineController () {
		
		
		
		currentUser = UserInfo.getUserId();
		
		if (selectedYear==null) {
			selectedDateTime = System.now();
			selectedYear = selectedDateTime.year();
		}
		
		loadOrderWindows();
		
		POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
       	baseUrl = settings.Magento_Catalog_Path__c;
       	idpUrl = settings.IDP_Url__c;
       	
       	loadOrderWindows();
       	
       	loadCalendarDisplays();
       	
       	breadCrumbs = new List<POS_BreadCrumb>();
       	breadCrumbs.add(new POS_BreadCrumb('POS','POS_OrderWindowView'));
       	breadCrumbs.add(new POS_BreadCrumb('Budgeting and Ordering Timeline','#'));
		
	}
	
	private void loadCalendarDisplays () {
		calendarDisplays = new List<CalendarDisplay>();
		Date month = Date.newInstance(selectedYear,1,1);
		for (integer x=0;x<12;x++) { 
			CalendarDisplay display = new CalendarDisplay();
			display.month=month;
			calendarDisplays.add(display);
			month = month.addMonths(1);
		}
		
		//Add order windows to the months
		orderWindowRows = new List<POS_OrderWindowRow>();
		for (Order_Window_Customer__c owc:orderWindowCustomers) {
			POS_OrderWindowRow row = new POS_OrderWindowRow(owc.Order_Window__r);
			orderWindowRows.add(row);
		}
		orderWindowRows.sort();
	}


	private void loadOrderWindows () {
		Date beginningOfYear = Date.newInstance(selectedYear,1,1);
		Date endOfYear = Date.newInstance(selectedYear,12,31);
		
		orderWindowCustomers = [Select Open_For_Shopping__c, o.Order_Window__r.Name, o.Order_Window__r.Type__c, 
		 o.Order_Window__r.Status__c, o.Order_Window__r.Order_Start_Date__c, 
		 o.Order_Window__r.Order_Delivery_Date__c, o.Order_Window__r.Order_Close_Date__c, 
		 o.Order_Window__r.On_Demand_Site_URL__c, o.Order_Window__r.Magento_Id__c, o.Order_Window__r.Fiscal_Year__c,
		 o.Order_Window__r.Icon_Label__c from Order_Window_Customer__c o
		 where Customer__c = :currentUser and o.Order_Window__r.Status__c in ('Open','Budgeting','Closed', 'In Review') 
		 and o.Order_Window__r.Order_Start_Date__c >= :beginningOfYear
		 and o.Order_Window__r.Order_Start_Date__c <= :endOfYear
		 order by o.Order_Window__r.Order_Start_Date__c DESC
		]; 
		
		carts = new Map<Id,Cart__c>();
		
		
		List<Cart__c> cartList = [Select c.Status__c, c.Last_Submitted__c, c.Order_Window__c, c.Id From Cart__c c where c.Shopper__c = :currentUser ];
		for (Cart__c cart:cartList) {
			if (cart.Order_Window__c != null) {
				carts.put(cart.Order_Window__c,cart);
			}
		}
	
		
		
		List<Id> windowIds = new List<Id>();
		programs = new Map<Id,List<Program__c>>();
		
		//Build a map of related programs to display their details in a hover
		for (Order_Window_Customer__c owc:orderWindowCustomers) {
			if (owc.Order_Window__r.Type__c == 'Monthly') {
				windowIds.add(owc.Order_Window__c);
			}
			programs.put(owc.Order_Window__c,new List<Program__c>());
			
			//Make sure that any windows that didn't have carts don't break the UI with nulls
			if (carts.get(owc.Order_Window__c)==null) {
				carts.put(owc.Order_Window__c,new Cart__c());
			}
		}
		
		
		List<Program__c> programList = [Select Order_Window__c, Name from Program__c where Order_Window__c in :windowIds];
		for (Program__c program:programList) {
			List<Program__c> programListFromMap = programs.get(program.Order_Window__c);
			programListFromMap.add(program);
		}
		
		System.debug('Programs: '+programs);
		
		System.debug('Order window customers: '+orderWindowCustomers);
	}
	
	public PageReference previousYear () {
		selectedDateTime = selectedDateTime.addYears(-1);
		selectedYear = selectedDateTime.year();
		loadOrderWindows();	
		loadCalendarDisplays();
		
		return null;
	}
	
	public PageReference nextYear () {
		selectedDateTime = selectedDateTime.addYears(1);
		selectedYear = selectedDateTime.year();
		loadOrderWindows();
		loadCalendarDisplays();
		
		return null;
	}
	
	public class CalendarDisplay {
		//public List<OrderWindowRow> orderWindows {get;set;}
		public Date month {get;set;}
		
	}
	
	
	
	@isTest
	public static void testOrderTimeline () {
		Profile p = [select id from profile where name='System Administrator'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {
			PageReference pageRef = Page.HomePage;
        	Test.setCurrentPage(pageRef);
        	
			Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
			
			Order_Window_Customer__c owc = new Order_Window_Customer__c();
			owc.Customer__c = u.Id;
			owc.Order_Window__c = ow.Id;
			insert owc;
			
			Cart__c cart = POS_TestDataUtil.createCart(u, ow);
			cart.Status__c = 'Submitted';
			update cart;
			
			POS_OrderTimelineController controller = new POS_OrderTimelineController();
			System.assert(controller.orderWindowCustomers.size()==1);
			
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