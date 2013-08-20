public with sharing class POS_MagentoRedirectController {
	
	public String destination {get;set;}
	
	public POS_MagentoRedirectController () { 
		String itemId = System.currentPagereference().getParameters().get('itemid');
		String magentoItemId = System.currentPagereference().getParameters().get('magentoid');
		if (itemId==null && magentoItemId==null) {
			//This is a return back to magento so 
			Cookie returnUrlCookie = ApexPages.currentPage().getCookies().get('returnUrl');
			destination = returnUrlCookie.getValue();
			System.debug('destination: '+destination);
		}
		else if (itemId!=null) {
			String referer = ApexPages.currentPage().getHeaders().get('Referer');
			Cookie returnUrl = new Cookie('returnUrl',referer,'/',null,false);
			List<Cookie> cookies = new List<Cookie>();
			cookies.add(returnUrl);
			ApexPages.currentPage().setCookies(cookies);
			destination = '/'+itemid+'/e?retURL=/apex/POS_MagentoRedirect';
			System.debug('destination: '+destination);
		}
		else if (magentoItemId!=null) {
			POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
			String itemPath = settings.Item_URL__c;
			Cookie returnUrl = new Cookie('returnUrl',itemPath+magentoItemId,'/',null,false);
			List<Cookie> cookies = new List<Cookie>();
			cookies.add(returnUrl);
			ApexPages.currentPage().setCookies(cookies);
			destination=settings.IDP_Url__c;
			
			System.debug('destination: '+destination);
		}
	}
	
	
	@isTest
	static public void testRedirect () {
		Program__c p = POS_TestDataUtil.createProgram();
		Item__c i = POS_TestDataUtil.createItem(p);
		Test.setCurrentPageReference(new PageReference('Page.POS_MagentoRedirect'));
		System.currentPagereference().getParameters().put('itemid',(String)i.Id);
		System.currentPageReference().getHeaders().put('referer','TESTREFERER');
		POS_MagentoRedirectController controller = new POS_MagentoRedirectController();
		
		//Should have the item ID in the url
		System.assert(controller.destination.indexOf(i.Id)>-1);
		
		//Now test the return case
		System.currentPagereference().getParameters().put('itemid',null);
		controller = new POS_MagentoRedirectController();
		System.assert(controller.destination.indexOf('TESTREFERER')>-1);
		
		System.currentPagereference().getParameters().put('magentoid','TESTVAL');
		controller = new POS_MagentoRedirectController();
		POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
			
		System.assert(controller.destination.indexof(settings.IDP_Url__c)>-1);
		
	}
}