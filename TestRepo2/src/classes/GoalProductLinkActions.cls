public without sharing class GoalProductLinkActions {
	
	public static void checkToPopulateReportBrand(List<Goal_Product_Link__c> gpls){
		List<Goal_Product_Link__c> validGPLs = new List<Goal_Product_Link__c>();
		for(Goal_Product_Link__c gpl : gpls){
			if(gpl.Report_Brand__c == null && gpl.Generic_Brand__c != null){
				validGPLs.add(gpl);
			}
		}
		if(validGPLs.size() > 0){
			populateReportBrand(validGPLs);
		}
	}
	
	public static void checkToPopulateReportBrand(Map<Id, Goal_Product_Link__c> oldMap, List<Goal_Product_Link__c> gpls){
		List<Goal_Product_Link__c> validGPLs = new List<Goal_Product_Link__c>();
		for(Goal_Product_Link__c gpl : gpls){
			Goal_Product_Link__c old = oldMap.get(gpl.Id);
			if(gpl.Generic_Brand__c != old.Generic_Brand__c || gpl.Sub_Brand__c != old.Sub_Brand__c){
				validGPLs.add(gpl);
			}
		}
		if(validGPLs.size() > 0){
			populateReportBrand(validGPLs);
		}
	}
	
	public static void populateReportBrand(List<Goal_Product_Link__c> gpls){
		Set<String> gBrands = new Set<String>();
		Set<String> sBrands = new Set<String>();
		
		for(Goal_Product_Link__c gpl : gpls){
			gBrands.add(gpl.Generic_Brand__c);
			sBrands.add(gpl.Sub_Brand__c);
		}
		
		List<Product__c> prods = [
			SELECT Id,
				   Generic_Brand__c,
				   Sub_Brand__c,
				   Report_Brand__c
			  FROM Product__c
			 WHERE Generic_Brand__c IN :gBrands
			    OR Sub_Brand__c IN :sBrands
		];
		
		Map<String, String> rBrandsByKey = new Map<String, String>();
		for(Product__c prod : prods){
			rBrandsByKey.put(prod.Generic_Brand__c + '|' + prod.Sub_Brand__c, prod.Report_Brand__c);
		}
		
		for(Goal_Product_Link__c gpl : gpls){
			String match = rBrandsByKey.get(gpl.Generic_Brand__c + '|' + gpl.Sub_Brand__c);
			if(match != null){
				gpl.Report_Brand__c = match;
			} else {
				gpl.Report_Brand__c = gpl.Generic_Brand__c;
			}
		}
	}

	public static void deduplicateLinks(Map<Id, Goal_Product_Link__c> linksById){
		Set<String> linkKeys = new Set<String>();
		List<Goal_Product_Link__c> insertLinks = [SELECT Id, Duplication_Key__c FROM Goal_Product_Link__c WHERE Id IN :linksById.keyset()];
		for(Goal_Product_Link__c link : insertLinks){
			linkKeys.add(link.Duplication_Key__c);
		}
		
		List<Goal_Product_Link__c> allLinks = [SELECT Id, Duplication_Key__c FROM Goal_Product_Link__c WHERE Duplication_Key__c IN :linkKeys ORDER BY CreatedDate];
		Map<String, Goal_Product_Link__c> linksByKey = new Map<String, Goal_Product_Link__c>();
		List<Goal_Product_Link__c> dupeLinks = new List<Goal_Product_Link__c>();
		
		for(Goal_Product_Link__c link : allLinks){
			if(linksByKey.get(link.Duplication_Key__c) == null){
				linksByKey.put(link.Duplication_Key__c, link);
			} else {
				dupeLinks.add(link);
			}
		}
		
		delete dupeLinks;
	}

}