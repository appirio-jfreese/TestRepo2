public with sharing class POS_WBSUtil {
	
	public static final String FUND_TYPE='A';
	public static final String CONSUMER_TYPE='1';
	public static final String ACTIVITY='PP';
	
	List<Cart_Item__c> cartItems;
	Order_Window__c ow;
	Map<Id,Account> agencyMap;
	Map<Id,Ship_To__c> shipToMap;
	Map<Id,Brand__c> brandMap;
	Map<String,String> planningAccountMap; //Map of district codes to planning accounts
	Map<Id,Program__c> programMap;
	Map<Id,Item__c> itemMap;
	Map<Id,Order_Window__c> windowMap;
	
	String SPIRITS_COMPANY_CODE='2290';
	String WINES_COMPANY_CODE='2185';
	
	private String DIAGEO_SPIRITS_DISTRICT;
	private String DIAGEO_SPIRITS_RESPONSIBLE;
	private String DIAGEO_WINE_DISTRICT;
	private String DIAGEO_WINE_RESPONSIBLE;
	
	private String diageoId;
		
	
	public POS_WBSUtil (List<Cart_Item__c> cartItems) {
		
		
		//If a cart item comes through without a shipto we do not want 
		//to touch the WBS.  This should only happen when an update is processed
		//to an existing cart item		
		List<Cart_Item__c> cartItemsToProcess = new List<Cart_Item__c>();
		for (Cart_Item__c cartItem: cartItems) {
			if (cartItem.Ship_To__c!=null) {
				cartItemsToProcess.add(cartItem);
			}
		}
		
		this.cartItems=cartItemsToProcess;
		this.ow=ow;
		
		POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
		this.DIAGEO_SPIRITS_DISTRICT=settings.Diageo_Spirits_District__c;
		this.DIAGEO_SPIRITS_RESPONSIBLE=settings.Diageo_Spirits_Responsible__c;
		this.DIAGEO_WINE_DISTRICT=settings.Diageo_Spirits_District__c;
		this.DIAGEO_WINE_RESPONSIBLE=settings.Diageo_Spirits_Responsible__c;
		
		List<Account> diageoAccounts = [select Id from Account where name='DIAGEO' and RecordType.Name='Distributor'];
		if (diageoAccounts.size()>0) {
			diageoId = diageoAccounts.get(0).Id;
		}
		else {
			if (Test.isRunningTest()) {
				//Existing unit tests can break here so we just fake an account for this
				//Shouldn't affect legitimate unit test
				Account fakeAccount = new Account();
				fakeAccount.Name='UNIT TEST ACCOUNT';
				insert fakeAccount;
				diageoId=fakeAccount.Id;
			}
		}
		
		//Get list of shiptos and query to get account/org unit information
		shipToMap = new Map<Id, Ship_To__c>();
		Set<Id> brandIds = new Set<Id>();
		Set<Id> programIds = new Set<Id>();
		List<Id> itemIds = new List<Id>();
		
		for (Cart_Item__c cartItem:cartItems) {
			if (cartItem.Ship_To__c==null) {
				//bad data, ignore it
				continue;
			}
			itemIds.add(cartItem.Item__c);
			shipToMap.put(cartItem.Ship_to__c,cartItem.Ship_to__r);
		}
		
		//Build map of items 
		itemMap=new Map<Id,Item__c>([select Id, Name, Agency__c, (select Id, Brand__c, Primary__c from Item_Brands__r where Primary__c = true), Channel__c, Program__c from Item__c
		 where Id in :itemIds]);
		 
		for (Id itemId:itemMap.keySet()) {
			Item__c item = itemMap.get(itemId);
			Id brandId = item.Item_Brands__r.get(0).Brand__c;
			brandIds.add(brandId);
			programIds.add(item.Program__c);
		}
		
		Set<Id> shipToIds=shipToMap.keySet();
		
		
		System.debug('SHIP TO IDs: '+shipToIds);
		
		shipToMap = new Map<Id,Ship_To__c>([select Id, Account__r.Spirits_Hierarchy__r.Responsible_Code__c, 
		  Account__r.Wine_Hierarchy__r.Responsible_Code__c, Account__r.Spirits_Hierarchy__r.District_Code__c,
		  Account__r.Wine_Hierarchy__r.District_Code__c,Account__r.Program_Code__c from Ship_To__c where Id in :shipToIds]);
		
		System.debug('Ship to map: '+shipToMap);
		
		//Build map of account ID to account objects for all shipto related accounts and the agency accounts
		agencyMap=new Map<Id,Account>([select Id,Spirits_Hierarchy__r.Responsible_Code__c,
		  Wine_Hierarchy__r.Responsible_Code__c, Spirits_Hierarchy__r.District_Code__c, Wine_Hierarchy__r.District_Code__c,
		  Program_Code__c from Account where Account.RecordType.Name='POS Production Agency']);
		  
		  
		System.debug('Accounts: '+agencyMap);
		
		//Build map of brand data
		brandMap = new Map<Id,Brand__c>([select Id, WBS_Level_3__c, WBS_Level_5__c, Parent_Brand__r.WBS_Level_5__c, 
		  Classification__c from Brand__c where Id in :brandIds]);
		
		
		//Build map of program data
		programMap = new Map<Id,Program__c>([select Id, Program_Code__c, Order_Window__r.Id, Order_Window__r.Name, Order_Window__r.Fiscal_Year__c from Program__c where Id in :programIds]);
		
		
		List<Planning_Account__c> planningAccounts = [select Name, District_Code__c, Sub_Channel_Code__c 
		  from Planning_Account__c];
		  
		System.debug('Planning accounts: '+planningAccounts);
		
		planningAccountMap=new Map<String,String>();
		for (Planning_Account__c pa:planningAccounts) {
			String key = pa.District_Code__c+':';
			if (pa.Sub_Channel_Code__c!=null) {
				key = key+pa.Sub_Channel_Code__c;
			}
			planningAccountMap.put(key,pa.Name);
		}
		
		System.debug('PA Map: '+planningAccountMap); 
		
		 
	}
	
	public List<Cart_Item__c> populateWBSData () {
		for (Cart_Item__c cartItem:cartItems) {
			populateSingleWBS(cartItem);
		}
		return cartItems;
	}
	
	private void populateSingleWBS (Cart_Item__c cartItem) {
		String WBS='';
		
		System.debug('CART ITEM SHIPTO: '+cartItem.Ship_To__c);
		//Get shipto account, agency, brand, and order window for this item
		
		Item__c item = itemMap.get(cartItem.Item__c);
		Account shipToAccount = (shipToMap.get(cartItem.Ship_To__c)).Account__r;
		Account agency = agencyMap.get(item.Agency__c);
		System.debug('PROGRAM: '+item.Program__c);
		Program__c program = programMap.get(item.Program__c);
		Order_Window__c ow = program.Order_Window__r;
		
		WBS=WBS+ow.Fiscal_Year__c.substring(3); //Get the last digit of the year
		
		
		Id primaryBrandId=null;
		
		
		for (Item_Brand__c itemBrand: item.Item_Brands__r) {
			if (itemBrand.Primary__c) {
				primaryBrandId=itemBrand.Brand__c;
			}
		}
		
		Brand__c brand = brandMap.get(primaryBrandId);
		
		
		//RESPONSIBILITY CODE//
		String responsibilityCode='??';  //Default to populating ?'s if we don't know
		if (brand.Classification__c=='Spirits') {
			if (shipToAccount.Spirits_Hierarchy__r!=null) {
				if (shipToAccount.Spirits_Hierarchy__r.Responsible_Code__c!=null) {
					responsibilityCode=shipToAccount.Spirits_Hierarchy__r.Responsible_Code__c;
				}
			}
			else if (shipToAccount.Id==diageoId) {
				responsibilityCode=this.DIAGEO_SPIRITS_RESPONSIBLE;
			}
		}
		else {
			if (shipToAccount.Wine_Hierarchy__r!=null) {
				if (shipToAccount.Wine_Hierarchy__r.Responsible_Code__c!=null) {
					responsibilityCode=shipToAccount.Wine_Hierarchy__r.Responsible_Code__c;
				}
			}
			else if (shipToAccount.Id==diageoId) {
				responsibilityCode=this.DIAGEO_WINE_RESPONSIBLE;
			}
		}
		
		WBS=WBS+responsibilityCode; 
		
		
	
		//PH CODES//
		String PH3Code='???';
		if (brand.WBS_Level_3__c!=null) {
			PH3Code=brand.WBS_Level_3__c; //PH3
		}
		
		WBS=WBS+PH3Code;
		
		String PH5Code='???';
		if (brand.WBS_Level_5__c==null) {
			if (brand.Parent_Brand__r.WBS_Level_5__c!=null) {
				PH5Code=brand.Parent_Brand__r.WBS_Level_5__c;
			}
		}
		else {
			PH5Code=brand.WBS_Level_5__c; //PH5
		}
		
		WBS=WBS+PH5Code;
		
		
		//FUND TYPE//
		WBS=WBS+FUND_TYPE; //Hard coded fund type
		
		//Channel//
		String channelCode=item.Channel__c=='Off-premise'?'9':'H'; //On or Off Channel (9 for Off, H for on)
		WBS=WBS+channelCode;
		
		// District Code //
		String districtCode='????';  
		
		if (brand.Classification__c=='Spirits') {
			if (shipToAccount.Spirits_Hierarchy__r.District_Code__c!=null) {
				districtCode=shipToAccount.Spirits_Hierarchy__r.District_Code__c;
			} 
			else if (shipToAccount.Id==diageoId) {
				districtCode=this.DIAGEO_SPIRITS_DISTRICT;
			}
		}
		else if (brand.Classification__c=='Wine') {
			if (shipToAccount.Wine_Hierarchy__r.District_Code__c!=null) {
				districtCode=shipToAccount.Wine_Hierarchy__r.District_Code__c;
			}
			else if (shipToAccount.Id==diageoId) {
				districtCode=this.DIAGEO_WINE_DISTRICT;
			}
		}
		
		System.debug('District code: "'+districtCode+'"');
		WBS=WBS+districtCode;

		String planningAccount='???';
		
		if (districtCode!='????') {
			planningAccount = planningAccountMap.get(districtCode+':'+channelCode);
			if (planningAccount==null) {
				//try without a channel code
				planningAccount = planningAccountMap.get(districtCode+':');
				if (planningAccount==null) {
					planningAccount='???';
				}
			}
		}
		
		System.debug('Planning account: '+planningAccount);
		
		WBS=WBS+planningAccount;
		
		// PROGRAM CODE //
		String programCode='???';
		
		if (program.Program_Code__c!=null) {
			programCode = program.Program_Code__c;
		}
		else {
			//Try to get it from the agency
			if (agency.Program_Code__c!=null) {
				programCode = agency.Program_Code__c;
			}
		}
		
		WBS=WBS+programCode; //Program code
		
		// HARD CODED REMAINING VALUES //
		WBS=WBS+CONSUMER_TYPE;
		WBS=WBS+ACTIVITY;
		
		//Set the value
		cartItem.WBS__c=WBS;
		
		//Then update company code as well
		if (brand.Classification__c=='Spirits') {
			cartItem.Company_Code__c=SPIRITS_COMPANY_CODE;
		}
		else if (brand.Classification__c=='Wine') {
			cartItem.Company_Code__c=WINES_COMPANY_CODE;
		}
		
	}
	
	@isTest
	public static void testWBS () {
		
		//Get the current time
    	Datetime now = System.now();
    	
    	Profile p = [select id from profile where name='System Administrator'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		
		System.runAs(u) {
			
			POS_TestDataUtil.initializeTestData();
    	
    		//Create Agency
    		Account agency = POS_TestDataUtil.createProductionAgency();
    		Account account = POS_TestDataUtil.createAccount();
    		Account_Member__c member = POS_TestDataUtil.createAccountMember(account,u);

			Planning_Account__c pa = new Planning_Account__c();
			pa.Name='PAC';
			pa.District_Code__c='DIST';
			pa.Sub_Channel_Code__c = 'H';
			insert pa;

			Organizational_Unit__c org = new Organizational_Unit__c();
			org.District_Code__c = 'DIST'; 
			org.Responsible_Code__c = 'RC';
			insert org;
			
			account.Spirits_Hierarchy__c = org.Id;
			update account;
	    	
	    	Brand__c brand = POS_TestDataUtil.createBrand();
	    	brand.WBS_Level_3__c = 'PH3';
	    	brand.WBS_Level_5__c = 'PH5';
	    	brand.Classification__c = 'Spirits';
	    	update brand;
	    	
	    	Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
	    	
	    	Program__c program = POS_TestDataUtil.createProgram(brand.Id,ow.Id);
	    	program.Program_Code__c='PRG';
	    	update program;
	    	
	    	Item__c item = POS_TestDataUtil.populateItem(program, agency);
	    	item.Channel__c = 'On-Premise';
	    	
	    	insert item;
	    	
	    	
	    	Cart__c crt = POS_TestDataUtil.createCart(u, ow);
	    	
	    	Cart_Item__c ci = POS_TestDataUtil.populateCartItem(item, crt);
	    	Ship_To__c shipTo = POS_TestDataUtil.createShipTo(account);
	    	ci.Ship_To__c = shipTo.Id;
	    	
	    	insert ci;
	    	 
	    	List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
	    	cartItems.add(ci);
	    	
	    	POS_WBSUtil util = new POS_WBSUtil(cartItems);
	    	cartItems = util.populateWBSData();
			
			System.debug('WBS: '+ci.WBS__c);
		 	System.assert(ci.WBS__c == '2RCPH3PH5AHDISTPACPRG1PP');
		 	System.assert(ci.Company_Code__c=='2290');
		 	
		 	//Now test without a heirarchy
		 	account.Spirits_Hierarchy__c=null;
		 	update account;
		 	
		 	util = new POS_WBSUtil(cartItems);
		 	cartItems = util.populateWBSData();
		 	System.debug('WBS NOW: '+ci.WBS__c);
		 	System.assert(ci.WBS__c == '2??PH3PH5AH???????PRG1PP');
		 	
		 	//Now test without a shipto in an update
		 	ci = [select Id from Cart_Item__c where Id=:ci.Id];
		 	ci.Ship_To__c=null;
		 	cartItems = new List<Cart_Item__c>();
		 	cartItems.add(ci);
		 	util = new POS_WBSUtil(cartItems);
		 	cartItems = util.populateWBSData();
		 	
		 	//No need for assertion here, if it fails we'll get an exception
		}
	}
}