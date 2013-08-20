public class POS_OrderHistoryController extends Controller_Base {

	public integer selectedYear {get;set;}
	private DateTime selectedDateTime {get;set;}
	private Id currentUser {get;set;}
	public String baseUrl {get;set;}
	public String idpUrl {get;set;}
	
	public List<SelectOption> orderWindowFilter {get;set;}
	public String filterValue {get;set;}
	private String [] selectedFilters {get;set;}
	
	public List <Order_Window_Customer__c> orderWindowCustomers {get;set;}
	public Map <Id,Cart__c> carts {get;set;}
	public Map<Id,List<Program__c>> programs {get;set;}

	public Map<Id,Double> sub_totals {get;set;}
	public Map<Id,Double> nett_totals {get;set;}
	
	public List<POS_BreadCrumb> breadCrumbs {get;set;}
	
	public POS_OrderHistoryController () {
		
		currentUser = UserInfo.getUserId();
		if (selectedYear==null) {
			selectedDateTime = System.now();
			selectedYear = selectedDateTime.year();
		}
		
		selectedFilters = new List<String>{'Monthly','Quarterly'};
		
		loadOrderWindows();
		
		POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
       	baseUrl = settings.Magento_Catalog_Path__c;
       	idpUrl = settings.IDP_Url__c;
       	
       	loadOrderWindowFilter();
       	
       	breadCrumbs = new List<POS_BreadCrumb>();
       	breadCrumbs.add(new POS_BreadCrumb('POS','POS_OrderWindowView'));
       	breadCrumbs.add(new POS_BreadCrumb('Order History','#'));
		
	}
	
	private void loadOrderWindowFilter () {
        orderWindowFilter = new List<SelectOption>();
        orderWindowFilter.add(new SelectOption('','Select Filter:'));
        orderWindowFilter.add(new SelectOption('Monthly,Quarterly','All'));
        orderWindowFilter.add(new SelectOption('Monthly','Monthly'));
        orderWindowFilter.add(new SelectOption('Quarterly','Quarterly'));
        
	}
	
	public PageReference previousYear () {
		selectedDateTime = selectedDateTime.addYears(-1);
		selectedYear = selectedDateTime.year();
		loadOrderWindows();
		
		return null;
	}
	
	public PageReference nextYear () {
		selectedDateTime = selectedDateTime.addYears(1);
		selectedYear = selectedDateTime.year();
		loadOrderWindows();
		return null;
	}
	
	public PageReference filterList () {
		if (filterValue==null || filterValue=='') {
			return null; //do nothing
		}
		selectedFilters = filterValue.split(',');
		loadOrderWindows();
		return null;
		
	}

	private void loadOrderWindows () {
		Date beginningOfYear = Date.newInstance(selectedYear,1,1);
		Date endOfYear = Date.newInstance(selectedYear,12,31);
		
		List<Order_Window_Customer__c> tempOrderWindowCustomers = [Select Open_For_Shopping__c, o.Order_Window__r.Name, o.Order_Window__r.Type__c, 
		 o.Order_Window__r.Status__c, o.Order_Window__r.Order_Start_Date__c, 
		 o.Order_Window__r.Order_Delivery_Date__c, o.Order_Window__r.Order_Close_Date__c, 
		 o.Order_Window__r.On_Demand_Site_URL__c, o.Order_Window__r.Magento_Id__c, 
		 o.Order_Window__r.Icon_Label__c from Order_Window_Customer__c o
		 where Customer__c = :currentUser and o.Order_Window__r.Status__c in ('Open','Budgeting','Closed', 'In Review') 
		 and o.Order_Window__r.Order_Start_Date__c >= :beginningOfYear
		 and o.Order_Window__r.Order_Start_Date__c <= :endOfYear
		 and o.Order_Window__r.Type__c in :selectedFilters
		 order by o.Order_Window__r.Order_Start_Date__c DESC
		]; 
		
		carts = new Map<Id,Cart__c>();
		
		
		List<Cart__c> cartList = [Select c.Status__c, c.Last_Submitted__c, c.Order_Window__c, c.Id From Cart__c c where c.Shopper__c = :currentUser ];
		for (Cart__c cart:cartList) {
			if (cart.Order_Window__c != null) {
				carts.put(cart.Order_Window__c,cart);
			}
		}
		
		//Only include order windows with carts
		orderWindowCustomers = new List<Order_Window_Customer__c>();
		for (Order_Window_Customer__c owc:tempOrderWindowCustomers) {
			Cart__c cart = carts.get(owc.Order_Window__c);
			if (cart != null) {
				System.debug('Cart status: '+cart.Status__c);
				if (cart.Status__c!='Open' && cart.Status__c!='Removed') {
					orderWindowCustomers.add(owc);
				}
			}
		}

		sub_totals = new Map<Id, Double>();
		nett_totals = new Map<Id, Double>();

		// loop through carts to calculate sub_totals & nett_totals
		List<Cart_Item__c> cartItemList = [Select ci.Item__c, ci.Cart__r.Order_Window__r.Id, ci.Total_Spend__c, ci.Quantity__c, ci.Item__r.Current_Price__c From Cart_Item__c ci where ci.Cart__r.Shopper__c = :currentUser];
		system.debug('======cartItemList.size()====='+cartItemList.size());
		for (Cart_Item__c cartItem:cartItemList) {
			System.debug('### BEFORE Cart IF' + sub_totals.keySet() + '::CartItem List::' + cartItem.Cart__r.Order_Window__r.Id);
			system.debug('========cartItem.Quantity__c======'+cartItem.Quantity__c);
			system.debug('========cartItem.Item__r.Current_Price__c======'+ cartItem.Item__r.Current_Price__c);
			system.debug('========sub_totals.get(cartItem.Cart__r.Order_Window__r.Id)======'+sub_totals.get(cartItem.Cart__r.Order_Window__r.Id));
			system.debug('========cartItem.Cart__r.Order_Window__r.Id======'+cartItem.Cart__r.Order_Window__r.Id);
			if(sub_totals.containsKey(cartItem.Cart__r.Order_Window__r.Id)) {
				sub_totals.put(cartItem.Cart__r.Order_Window__r.Id, sub_totals.get(cartItem.Cart__r.Order_Window__r.Id) + cartItem.Quantity__c * cartItem.Item__r.Current_Price__c);
				System.debug('### Cart IF' + sub_totals);
			} else {
				//Commented out by Luke Slevin for case 3849
				//0 was causing an issue if the user only had one cart item
				//sub_totals.put(cartItem.Cart__r.Order_Window__r.Id, 0);
				sub_totals.put(cartItem.Cart__r.Order_Window__r.Id, cartItem.Quantity__c * cartItem.Item__r.Current_Price__c);
					
				System.debug('### Cart ELSE' + sub_totals);			
			}

			if(nett_totals.containsKey(cartItem.Cart__r.Order_Window__r.Id)) {
				nett_totals.put(cartItem.Cart__r.Order_Window__r.Id, nett_totals.get(cartItem.Cart__r.Order_Window__r.Id) + cartItem.Total_Spend__c);								
			} else {
				//Commented out by Luke Slevin for case 3849
				//0 was causing an issue if the user only had one cart item
				//nett_totals.put(cartItem.Cart__r.Order_Window__r.Id, 0);
				nett_totals.put(cartItem.Cart__r.Order_Window__r.Id, cartItem.Total_Spend__c);
			}
		}

		System.debug(sub_totals.keySet());

		
		System.debug('Carts: '+carts);
		
		List<Id> windowIds = new List<Id>();
		programs = new Map<Id,List<Program__c>>();
		
		//Build a map of related programs to display their details in a hover
		for (Order_Window_Customer__c owc:orderWindowCustomers) {
			if (owc.Order_Window__r.Type__c == 'Monthly') {
				windowIds.add(owc.Order_Window__c);
			}
			programs.put(owc.Order_Window__c,new List<Program__c>());
		}
		
		
		List<Program__c> programList = [Select Order_Window__c, Name from Program__c where Order_Window__c in :windowIds];
		for (Program__c program:programList) {
			List<Program__c> programListFromMap = programs.get(program.Order_Window__c);
			programListFromMap.add(program);
		}
		
		System.debug('Programs: '+programs);
		
		System.debug('Order window customers: '+orderWindowCustomers);
	}
	
	@isTest
	public static void testOrderHistory () {
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
			
			POS_OrderHistoryController controller = new POS_OrderHistoryController();
			System.assert(controller.orderWindowCustomers.size()==1);
			
			controller.previousYear();
			System.assert(controller.orderWindowCustomers.size()==0);  //No windows in previous year
			controller.nextYear();
			System.assert(controller.orderWindowCustomers.size()==1);  //Back to current year so should see that record
			
			controller.filterValue='Quarterly';
			controller.filterList();
			System.assert(controller.orderWindowCustomers.size()==0); //Test window is monthly so shouldn't see it now
			
		}
	}
	
}