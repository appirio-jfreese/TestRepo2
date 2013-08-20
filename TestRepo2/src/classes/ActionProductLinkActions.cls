public with sharing class ActionProductLinkActions {
	
	public static void updateOnlineFields(List<Action_Product_Link__c> apls){
		List<Action_Product_Link__c> aplsToCopyOffToOn = new List<Action_Product_Link__c>();
		List<Action_Product_Link__c> aplsToCopyOnToOff = new List<Action_Product_Link__c>();
		for(Action_Product_Link__c apl : apls){
			if(apl.Individual_Brand_Offline__c != null && apl.Individual_Brand__c == null){
				aplsToCopyOffToOn.add(apl);
			} else if(apl.Individual_Brand_Offline__c == null && apl.Individual_Brand__c != null){
				aplsToCopyOnToOff.add(apl);
			}
		}
		if(aplsToCopyOffToOn.size() > 0){
			transferOfflineToOnline(aplsToCopyOffToOn);
		}
		if(aplsToCopyOnToOff.size() > 0){
			transferOnlineToOffline(aplsToCopyOnToOff);
		}
	}
	
	public static void updateOnlineFields(Map<Id, Action_Product_Link__c> oldAPLMap, List<Action_Product_Link__c> apls){
		List<Action_Product_Link__c> changedAPLs = new List<Action_Product_Link__c>();
		List<Action_Product_Link__c> aplsToCopyOffToOn = new List<Action_Product_Link__c>();
		List<Action_Product_Link__c> aplsToCopyOnToOff = new List<Action_Product_Link__c>();
		
		for(Action_Product_Link__c apl : apls){
			Action_Product_Link__c old = oldAPLMap.get(apl.Id);
			if(old.Individual_Brand_Offline__c != apl.Individual_Brand_Offline__c || old.Size_Offline__c != apl.Size_Offline__c){
				aplsToCopyOffToOn.add(apl);
			} else if(old.Match_Key__c != apl.Match_Key__c){
				aplsToCopyOnToOff.add(apl);
			}
		}
		
		if(aplsToCopyOffToOn.size() > 0){
			transferOfflineToOnline(aplsToCopyOffToOn);
		}
		if(aplsToCopyOnToOff.size() > 0){
			transferOnlineToOffline(aplsToCopyOnToOff);
		}
	}
	
	private static void transferOfflineToOnline(List<Action_Product_Link__c> apls){
		Set<String> indBrands = new Set<String>();
		
		for(Action_Product_Link__c apl : apls){
			indBrands.add(apl.Individual_Brand_Offline__c);
		}
		
		List<Product__c> possibleProds =
			[SELECT Id,
					Product_Classification__c,
					Product_Group__c,
					Generic_Brand__c,
					Sub_Brand__c,
					Individual_Brand__c,
					Size__c,
					Report_Brand__c
			   FROM Product__c
			  WHERE Individual_Brand__c IN :indBrands
			];
			
		Map<String, Product__c> prodsByIndBrand = new Map<String, Product__c>();
		Map<String, Product__c> prodsByIndBrandAndSize = new Map<String, Product__c>();
		for(Product__c prod : possibleProds){
			prodsByIndBrand.put(prod.Individual_Brand__c, prod);
			prodsByIndBrandAndSize.put(prod.Individual_Brand__c + '|' + prod.Size__c, prod);
		}
		
		for(Action_Product_Link__c apl : apls){
			Product__c match;
			if(apl.Size_Offline__c == null){
				match = prodsByIndBrand.get(apl.Individual_Brand_Offline__c);
			} else {
				match = prodsByIndBrandAndSize.get(apl.Individual_Brand_Offline__c + '|' + apl.Size_Offline__c);
			}
			
			if(match == null){
				if(apl.Size_Offline__c == null){
					apl.addError(' A brand could not be found that matches your choice: ' + apl.Individual_Brand_Offline__c + '. Please change your selection and try again.');
				} else {
					apl.addError(' A match could not be found for your brand and size choice: ' + apl.Individual_Brand_Offline__c + ', ' + apl.Size_Offline__c + '. Please change your selection and try again.');
					apl.Size_Offline__c = null;
					apl.Size__c = null;
				}
			} else {
				apl.Product_Classification__c = match.Product_Classification__c;
				apl.Product_Group__c = match.Product_Group__c;
				apl.Report_Brand__c = match.Report_Brand__c;
				apl.Generic_Brand__c = match.Generic_Brand__c;
				apl.Sub_Brand__c = match.Sub_Brand__c;
				apl.Individual_Brand__c = match.Individual_Brand__c;
				if(apl.Size_Offline__c != null){
					apl.Size__c = apl.Size_Offline__c;
				}
				apl.Report_Brand__c = match.Report_Brand__c;
			}
		}
	}
	
	private static void transferOnlineToOffline(List<Action_Product_Link__c> apls){
		for(Action_Product_Link__c apl : apls){
			apl.Individual_Brand_Offline__c = apl.Individual_Brand__c;
			apl.Size_Offline__c = apl.Size__c;
		}
	}
	
	public static void checkToPopulateReportBrand(List<Action_Product_Link__c> apls){
		List<Action_Product_Link__c> validAPLs = new List<Action_Product_Link__c>();
		for(Action_Product_Link__c apl : apls){
			if(apl.Report_Brand__c == null && apl.Generic_Brand__c != null){
				validAPLs.add(apl);
			}
		}
		if(validAPLs.size() > 0){
			populateReportBrand(validAPLs);
		}
	}
	
	public static void checkToPopulateReportBrand(Map<Id, Action_Product_Link__c> oldMap, List<Action_Product_Link__c> apls){
		List<Action_Product_Link__c> validAPLs = new List<Action_Product_Link__c>();
		for(Action_Product_Link__c apl : apls){
			Action_Product_Link__c old = oldMap.get(apl.Id);
			if(apl.Generic_Brand__c != old.Generic_Brand__c || apl.Sub_Brand__c != old.Sub_Brand__c){
				validAPLs.add(apl);
			}
		}
		if(validAPLs.size() > 0){
			populateReportBrand(validAPLs);
		}
	}
	
	public static void populateReportBrand(List<Action_Product_Link__c> apls){
		Set<String> gBrands = new Set<String>();
		Set<String> sBrands = new Set<String>();
		
		for(Action_Product_Link__c apl : apls){
			gBrands.add(apl.Generic_Brand__c);
			sBrands.add(apl.Sub_Brand__c);
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
		
		for(Action_Product_Link__c apl : apls){
			String match = rBrandsByKey.get(apl.Generic_Brand__c + '|' + apl.Sub_Brand__c);
			if(match != null){
				apl.Report_Brand__c = match;
			} else {
				apl.Report_Brand__c = apl.Generic_Brand__c;
			}
		}
	}

	public static void deduplicateLinks(Map<Id, Action_Product_Link__c> linksById){
		Set<String> linkKeys = new Set<String>();
		Set<Id> actionIds = new Set<Id>();
		List<Action_Product_Link__c> insertLinks = [SELECT Id, Duplication_Key__c, Action__c FROM Action_Product_Link__c WHERE Id IN :linksById.keyset()];
		for(Action_Product_Link__c link : insertLinks){
			linkKeys.add(link.Duplication_Key__c);
			actionIds.add(link.Action__c);
		}
		
		List<Action_Product_Link__c> allLinks = [SELECT Id, Duplication_Key__c, Action__c FROM Action_Product_Link__c WHERE Action__c IN :actionIds AND Duplication_Key__c IN :linkKeys ORDER BY CreatedDate];
		Map<String, Action_Product_Link__c> linksByKey = new Map<String, Action_Product_Link__c>();
		List<Action_Product_Link__c> dupeLinks = new List<Action_Product_Link__c>();
		
		for(Action_Product_Link__c link : allLinks){
			if(linksByKey.get(link.Duplication_Key__c) == null){
				linksByKey.put(link.Duplication_Key__c, link);
			} else {
				dupeLinks.add(link);
			}
		}
		
		delete dupeLinks;
	}

}