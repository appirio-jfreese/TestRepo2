global class POS_BatchNotifyOverageCascade implements Database.Batchable<sObject> {

	private List<Budget__c> exceededBudgets;
	List<Budget__c> parentBudgets = new List<Budget__c>();
	Map<Id,Budget__c> budgetMap = new Map<Id,Budget__c>();
	POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
	
	
	public static String query = 'Select b.Order_Window__c, b.Id, b.Shopper__c, b.CreatedById, b.CreatedBy.Name, b.CreatedBy.Email, '+
    	  ' b.Brand__c, b.Brand__r.Name, b.Amount__c, b.Parent__c, Spent_Amount__c, My_Spent_Amount__c, Remaining_Amount__c, '+
    	  ' b.Shopper__r.Name, b.Shopper__r.Email, b.Budget_Creator__r.Name, b.Budgeter__r.Email, b.Budgeter__r.Name, Order_Window__r.Name '+
    	  ' From Budget__c b ';
	
	public POS_BatchNotifyOverageCascade (List<Budget__c> exceededBudgets) {
		this.exceededBudgets = exceededBudgets;
	}
	
	public POS_BatchNotifyOverageCascade () {
		this.exceededBudgets = exceededBudgets;
	}
	
	global database.queryLocator start(Database.BatchableContext BC) 
	{
		String filteredQuery = getQuery();
		return database.getQueryLocator(filteredQuery);
	} 
	
	
    global String getQuery () {
    	System.debug('EXCEEDED BUDGETS: '+exceededBudgets);
		Order_Window__c window = exceededBudgets.get(0).Order_Window__r;
		if (Test.isRunningTest() && window==null) {
			window=[select Id, Name from Order_Window__c where Id=:exceededBudgets.get(0).Order_Window__c];
			exceededBudgets.get(0).Order_Window__r = window;
		}
		
		String filteredQuery = query+' where Order_Window__c =\''+window.Id+'\' and Remaining_Amount__c < 0 ';
		return filteredQuery;
    }
	
	global void executeNoBatch () {
		String filteredQuery = getQuery();
		List<Budget__c> budgets =  database.query(filteredQuery);
		process(budgets);
		
	}
	
	global void execute(Database.BatchableContext BC, List<Budget__c> budgets) {
		
		process (budgets);
	}
	
	global void process (List<Budget__c> budgets) {
		List <Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
	
    	//Build a map of all budgets that are over
    	
    	for (Budget__c budget:budgets) {
    		budgetMap.put(budget.Id,budget);
    	}
    	
    	System.debug('Potential exceeded budget map: '+budgetMap);
    	
    	//Iterate through list of budgets that are over and find their parents
    	System.debug('Exceeded budgets: '+exceededBudgets);
    	for (Budget__c exceededBudget:exceededBudgets) {
    		getParentBudgets(exceededBudget);
    	}
    	
    	Decimal overagePercentage;
    	Decimal overageAmount;
    	if (Test.isRunningTest()) {
    		overagePercentage=.01;
    		overageAmount=1;
    	}
    	else {
	    	overagePercentage = settings.Budget_Overage_Percent__c/100;
		 	overageAmount = settings.Budget_Overage_Amount__c;
    	}
	 	
    	//Should now have a list of potentially exceeded budgets, so must see if they fit the overage limits
	 	List<Budget__c> notifyBudgets = new List<Budget__c>();
	 	
    	for (Budget__c parentBudget:parentBudgets) {
    		System.debug('Checking Parent: '+parentBudget);
    		if (parentBudget.Spent_Amount__c == null || parentBudget.Spent_Amount__c==0) {
    			//This shouldn't happen but if the data isn't there just move on
    			continue;
    		}
    		
    		if (parentBudget.My_Spent_Amount__c == null) {
    			parentBudget.My_Spent_Amount__c = 0;
    		}
    		
    		System.debug('Test 1: '+parentBudget.Amount__c*overagePercentage);
    		System.debug('Test 1: '+(parentBudget.Amount__c+overageAmount));
    		System.debug('Test 2: '+parentBudget.Spent_Amount__c);
            
            //figure out which is greater, percent or dollar, then go from there
            Decimal overageMaxAllowed = overageAmount;
            if (parentBudget.Amount__c*overagePercentage>overageAmount) {
            	overageMaxAllowed = parentBudget.Amount__c*overagePercentage;
            } 
            
			// check if there is overage that more than the overageMaxAllowed
			decimal budgetOverage = 0;
			/*if(parentBudget.My_Spent_Overage__c != null) { // VK: My_Spent_Overage__c should not be part of Overage (11/20/2012)
				budgetOverage = parentBudget.My_Spent_Overage__c;
			}*/
			if(parentBudget.Remaining_Amount__c != null && parentBudget.Remaining_Amount__c < 0) {
				budgetOverage=Math.abs(parentBudget.Remaining_Amount__c);
			}
			
			System.debug('overageMaxAllowed: '+overageMaxAllowed + ' budgetOverage: ' + budgetOverage);
			
            if (budgetOverage > overageMaxAllowed) {
                //overage.amountSpent=parentBudget.Spent_Amount__c + parentBudget.My_Spent_Amount__c + parentBudget.My_Spent_Overage__c;
                notifyBudgets.add(parentBudget);
            }
                            
    		/*if (parentBudget.Amount__c*overagePercentage>overageAmount) {
	    		if ((parentBudget.Spent_Amount__c+parentBudget.My_Spent_Amount__c)>parentBudget.Amount__c*overagePercentage) { 
	    			notifyBudgets.add(parentBudget);
	    			System.debug('ADDED');
	    			continue;
	    		}
    		}
	    	else {
	    		if ((parentBudget.Spent_Amount__c+parentBudget.My_Spent_Amount__c)>parentBudget.Amount__c+overageAmount) {
	    			System.debug('ADDED (2)');
	    			notifyBudgets.add(parentBudget);
	    			continue;
	    		}
	    	}*/
    	}
    	
    	System.debug('NOTIFY ITEMS: '+notifyBudgets);
    	
    	//Now we have a list of budgets with sufficient overages.  Time to notify
    	//First build a map of notified users to budgets
    	
    	Map<Id,List<Budget__c>> notifyMap = new Map<Id,List<Budget__c>>();
    	for (Budget__c notifyBudget:notifyBudgets) {
    		List<Budget__c> budgetsFromMap = notifyMap.get(notifyBudget.Budgeter__c);
    		if (budgetsFromMap==null) {
    			budgetsFromMap=new List<Budget__c>();
    			notifyMap.put(notifyBudget.Budgeter__c,budgetsFromMap);
    		}
    		budgetsFromMap.add(notifyBudget);
    	}
    	
    	System.debug('NOTIFY MAP: '+notifyMap);
    	
    	//Now iterate through keyset and send messages
    	User sender = [select Email, Name from User where Id = :Service_API.getUID()];
    	
    	Set<Id> notifyIds = notifyMap.keySet();
    	for (Id id:notifyIds) {
    		System.debug('Adding messages...');
    		List<Budget__c> budgetsFromMap = notifyMap.get(id);
    		messages.add(getOverageNotificationMessage(sender,budgetsFromMap));
    	}
    	
    	Messaging.sendEmail(messages);
	} 
	
	global Messaging.SingleEmailMessage getOverageNotificationMessage (User sender, List<Budget__c> budgets) {
		User notifiedUser = budgets.get(0).Budgeter__r;	
		Order_Window__c orderWindow = budgets.get(0).Order_Window__r;
	
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new list<String>{notifiedUser.Email});
        mail.setReplyTo('pos-order-confirmation@diageo.com');
    	mail.setSubject('Diageo POS: Sub-Allocated Budget Overage Notification');
    	mail.setSenderDisplayName('Diageo Budget Notification');
		mail.setBccSender(false);
		mail.setUseSignature(false);
		
		String body = 'Dear '+notifiedUser.Name+', \n'+
		  '\n'+
		  'The budget for the order window "'+orderWindow.Name+'" has been exceeded by spending on a sub-allocated budget: \n\n';
		for (Budget__c budget:budgets) {
			if (budget.My_Spent_Amount__c==null) {
				budget.My_Spent_Amount__c = 0;
			}
				
			body=body+'  * '+budget.Brand__r.Name+' allocated to '+budget.Shopper__r.Name+': spent $'+formatCurrency(budget.Spent_Amount__c+budget.My_Spent_Amount__c)+' and is over budget by ';
			body=body+'$'+formatCurrency(-1*budget.Remaining_Amount__c);   
			body=body+'\n';
		}
		
		body=body+'\n';
		//body=body+'For more details please go to: https://'++'/apex/POS_BudgetingGrid?owId='+orderWindow.Id;
		mail.setPlainTextBody(body);
		
    	return mail;
    }
    
    public static String formatCurrency (Decimal val) {
    	String formatted=val.SetSCale(2).format();
    	if (formatted.indexOf('.')==formatted.length()-2) {
    		formatted=formatted+'0';
    	}
    	return formatted;
    }
	
	/*
	This will operate recursively, chaning up through budgets.  All budgets are preassumed to have 
	been identified as being over based on the initial query.  So if they are in the map, then they are 
	over
	*/
	global void getParentBudgets(Budget__c exceededBudget) {
		System.debug('Exceeded budget (getParentBudgets): '+exceededBudget);
		Budget__c parentBudget = budgetMap.get(exceededBudget.Parent__c);
		if (parentBudget==null) {
			return;
		}
		else {
			parentBudgets.add(parentBudget);
			getParentBudgets(parentBudget);
		}
	}

    global void finish(Database.BatchableContext BC) {
    	
    }
    
    @IsTest
    public static void testUpsertItem () {
    	Brand__c brand1 = POS_TestDataUtil.createBrand();
    	Brand__c brd = new Brand__c(Name = 'Test Brand', Classification__c='Spirits', Diageo_Direct_Visible__c=true, Brand_Type__c='Individual');
        insert brd;
        Brand__c brand = new Brand__c(Name = 'Test Brand', Classification__c='Spirits', Diageo_Direct_Visible__c=true, Brand_Type__c='Individual',Parent_Brand__c = brd.Id);
        insert brand;
    	brand.Classification__c='Spirits';
    	update brand;
    	
    	Profile p = [select id from profile where name='Diageo Employee'];
    	
        //Create Agency
        Account agency = POS_TestDataUtil.createProductionAgency();
    	
    	//Create Distributor Account
        Account dist = POS_TestDataUtil.createDistributorAccount(); 
    	
    	Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
    	
    	Program__c program = POS_TestDataUtil.createProgram(brand.Id, ow.Id);
		Item__c item = POS_TestDataUtil.populateItem(program, agency);
        item.RecordTypeId = [select Id, Name, DeveloperName from RecordType where DeveloperName='Standard' limit 1].id;
        insert item;      	
    	
        // Associate Brand with Item
        Item_Brand__c ib = new Item_Brand__c(Brand__c = brand.Id, Item__c=item.id);
        insert ib;    	
    	
    	AccountBrand__c ab = POS_TestDataUtil.createAccountBrand(dist, brand);
    	
         
		User budgeter = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		insert budgeter;
		
        Order_Window_Customer__c cust1 = new Order_Window_Customer__c();
        cust1.Order_Window__c = ow.Id;
        cust1.Customer__c=budgeter.Id;
        cust1.Open_For_Shopping__c=true;
        insert cust1; 		
		
		User shopper = new User(alias = 'posmmtt2', email='posmmunittest2@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest2@diageo.com');
		insert shopper;
		
        Order_Window_Customer__c cust2 = new Order_Window_Customer__c();
        cust2.Order_Window__c = ow.Id;
        cust2.Customer__c=shopper.Id;
        cust2.Open_For_Shopping__c=true;
        insert cust2;
		
		POS_TestDataUtil.createAccountMember(dist, budgeter);
		POS_TestDataUtil.createAccountMember(dist, shopper);
		
		
		//System.debug('BRANDS: '+Service_API.getAccBrandIdsForUser(shopper.Id));
    	
    	Budget__c parentBudget = new Budget__c();
    	parentBudget.Budget_Creator__c=budgeter.Id;
    	parentBudget.Budgeter__c=budgeter.Id;
    	parentBudget.Brand__c=brand.Id;
    	parentBudget.Amount__c=100;
    	parentBudget.Spent_Amount__c=10000;
    	parentBudget.My_Spent_Amount__c=5000;
    	parentBudget.Shopper__c=shopper.Id;
    	//budget.Order_Window__r=ow;
    	parentBudget.Order_Window__c = ow.Id;
    	insert parentBudget;
    	
    	Budget__c budget = new Budget__c();
    	budget.Budget_Creator__c=budgeter.Id;
    	budget.Budgeter__c=budgeter.Id;
    	budget.Brand__c=brand.Id;
    	budget.Amount__c=100;
    	budget.Spent_Amount__c=10000;
    	budget.My_Spent_Amount__c=5000;
    	budget.Shopper__c=shopper.Id;
    	//budget.Order_Window__r=ow;
    	budget.Order_Window__c = ow.Id;
    	budget.Parent__c = parentBudget.Id;
    	insert budget;
    	
    	
    	
    	
    	List<Budget__c> overBudgets=new List<Budget__c>();
    	overBudgets.add(budget);
    	
    	POS_BatchNotifyOverageCascade cascade = new POS_BatchNotifyOverageCascade(overBudgets);
    	Test.startTest();
    	database.executeBatch(cascade);
    	Test.stopTest();
    	
    	
    }
}