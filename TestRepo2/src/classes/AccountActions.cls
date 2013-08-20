public with sharing class AccountActions {

	public static void updateRecordTypes(List<Account> newList, Map<Id, Account> oldMap){
		//used for update
		
		List<Account> accsToUpdate = new List<Account>();
		for(Account acc : newList){
			if(acc.NABCA_Sector_Code__c != oldMap.get(acc.Id).NABCA_Sector_Code__c){
				accsToUpdate.add(acc);
			}
		}
		
		if(accsToUpdate.size() > 0){
			updateRecordTypes(accsToUpdate);
		}
	}

	public static void updateRecordTypes(List<Account> newList){
		//used for insert
		
		//get proper record type IDs
		Id onPremId;
		Id offPremId;
		
		List<RecordType> accRecTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name LIKE '% - Control'];
		for(RecordType rt : accRecTypeList){
			if(rt.Name == 'On-Premise - Control'){
				onPremId = rt.Id;
			} else if(rt.Name == 'Off-Premise - Control'){
				offPremId = rt.Id;
			}
		}
		
		//loop through incoming accounts and set their record types appropriately
		for(Account acc : newList){
			if(acc.NABCA_Sector_Code__c == 'o' || acc.NABCA_Sector_Code__c == 'O'){
				acc.RecordTypeId = onPremId;
			} else if(acc.NABCA_Sector_Code__c == 'f' || acc.NABCA_Sector_Code__c == 'F' || acc.NABCA_Sector_Code__c == 'c' || acc.NABCA_Sector_Code__c == 'C'){
				acc.RecordTypeId = offPremId;
			}
		} 
	}
	
	public static void checkNabcaTerritory(List<Account> accs){
		List<Account> accsToModify = new List<Account>();
		Set<String> terrNames = new Set<String>();
		
		for(Account acc : accs){
			if(acc.Nabca_Account_Name__c != null && acc.Nabca_Account_Name__c.contains('(') && acc.NABCA_Licensee_State_Abbreviation__c  != null && acc.Territory__c == null){
				accsToModify.add(acc);
				terrNames.add(acc.NABCA_Licensee_State_Abbreviation__c  + '1 Holding');
			}
		}
		
		if(accsToModify.size() > 0){
			List<Territory__c> terrs =
				[SELECT Id,
						Name
				   FROM Territory__c
				  WHERE Name IN :terrNames
				];
				
			if(terrs.size() > 0){
				Map<String, Id> terrIdsByName = new Map<String, Id>();
				for(Territory__c terr : terrs){
					terrIdsByName.put(terr.Name, terr.Id);
				}
				
				for(Account acc : accsToModify){
					acc.Territory__c = terrIdsByName.get(acc.NABCA_Licensee_State_Abbreviation__c  + '1 Holding');
				}
			}
		}
	}
	
	public static void updateSURIs(List<Account> accs, Boolean isInsert){
		Map<Id, String> accRTNamesById = new Map<Id, String>();
		for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name LIKE '%Premise%']){
			if(rt.Name == 'On Premise' || rt.Name == 'On-Premise - Control'){
				accRTNamesById.put(rt.Id, 'On');
			} else if(rt.Name == 'Off Premise' || rt.Name == 'Off-Premise - Control'){
				accRTNamesById.put(rt.Id, 'Off');
			}
		}
		
		List<Account> validAccs = new List<Account>();
		Map<String, Integer> newSuriKeysToIncrement = new Map<String, Integer>();
		Map<String, Integer> newSuriCalledOnKeysToIncrement = new Map<String, Integer>();
		String accStateId;
		String accOwnerId;
		
		Boolean isValid;
		String prem;
		for(Account acc : accs){
			isValid = false;
			prem = accRTNamesById.get(acc.RecordTypeId);
			if(prem != null){
				if(acc.State__c != null){
					accStateId = String.valueOf(acc.State__c).subString(0, 15);
					if(acc.Account_Segmentatiobn__c != null){
						isValid = true;
						incrementKeyMap(newSuriKeysToIncrement, accStateId + '|' + acc.Account_Segmentatiobn__c + '|' + prem);
						if(acc.Called_On__c){
							incrementKeyMap(newSuriCalledOnKeysToIncrement, accStateId + '|' + acc.Account_Segmentatiobn__c + '|' + prem);
						}
					}
					if(acc.Primary_Demographic__c != null){
						isValid = true;
						incrementKeyMap(newSuriKeysToIncrement, accStateId + '|' + acc.Primary_Demographic__c + '|' + prem);
						if(acc.Called_On__c){
							incrementKeyMap(newSuriCalledOnKeysToIncrement, accStateId + '|' + acc.Primary_Demographic__c + '|' + prem);
						}
					}
				}
				if(acc.OwnerId != null){
					accOwnerId = String.valueOf(acc.OwnerId).subString(0, 15);
					if(acc.Account_Segmentatiobn__c != null){
						isValid = true;
						incrementKeyMap(newSuriKeysToIncrement, accOwnerId + '|' + acc.Account_Segmentatiobn__c + '|' + prem);
						if(acc.Called_On__c){
							incrementKeyMap(newSuriCalledOnKeysToIncrement, accOwnerId + '|' + acc.Account_Segmentatiobn__c + '|' + prem);
						}
					}
					if(acc.Primary_Demographic__c != null){
						isValid = true;
						incrementKeyMap(newSuriKeysToIncrement, accOwnerId + '|' + acc.Primary_Demographic__c + '|' + prem);
						if(acc.Called_On__c){
							incrementKeyMap(newSuriCalledOnKeysToIncrement, accOwnerId + '|' + acc.Primary_Demographic__c + '|' + prem);
						}
					}
				}
				if(isValid){
					validAccs.add(acc);
				}
			}
		}
		
		if(newSuriKeysToIncrement.size() > 0){
			List<State_User_Report_Item__c> suris =
				[SELECT Id,
						Key__c,
						Accounts__c,
						Called_On_Accounts__c
				   FROM State_User_Report_Item__c
				  WHERE Key__c IN :newSuriKeysToIncrement.keySet()
				];
			Map<String, State_User_Report_Item__c> surisToUpsertByKey = new Map<String, State_User_Report_Item__c>();
			for(State_User_Report_Item__c suri : suris){
				surisToUpsertByKey.put(suri.Key__c, suri);
			}
			
			for(Account acc : validAccs){
				prem = accRTNamesById.get(acc.RecordTypeId);
				createSuriIfNeeded(surisToUpsertByKey, acc, prem);
			}
			for(String key : newSuriKeysToIncrement.keySet()){
				if(isInsert){
					modifySuri(surisToUpsertByKey, key, newSuriKeysToIncrement.get(key), false, false);
					modifySuri(surisToUpsertByKey, key, newSuriCalledOnKeysToIncrement.get(key), true, false);
				} else {
					modifySuri(surisToUpsertByKey, key, newSuriKeysToIncrement.get(key), false, true);
					modifySuri(surisToUpsertByKey, key, newSuriCalledOnKeysToIncrement.get(key), true, true);
				}
			}
			upsert surisToUpsertByKey.values();
		}
	}
	
	public static void checkToUpdateSURIs(Map<Id, Account> oldAccMap, List<Account> accs){
		Map<Id, String> accRTNamesById = new Map<Id, String>();
		for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name LIKE '%Premise%']){
			if(rt.Name == 'On Premise' || rt.Name == 'On-Premise - Control'){
				accRTNamesById.put(rt.Id, 'On');
			} else if(rt.Name == 'Off Premise' || rt.Name == 'Off-Premise - Control'){
				accRTNamesById.put(rt.Id, 'Off');
			}
		}
		
		List<Account> validAccs = new List<Account>();
		Set<Id> repointAccIds = new Set<Id>();
		Map<String, Integer> newSuriKeysToIncrement = new Map<String, Integer>();
		Map<String, Integer> newSuriCalledOnKeysToIncrement = new Map<String, Integer>();
		Map<String, Integer> oldSuriKeysToDecrement = new Map<String, Integer>();
		Map<String, Integer> oldSuriCalledOnKeysToDecrement = new Map<String, Integer>();
		String accStateId;
		String accOwnerId;
		String oldStateId;
		String oldOwnerId;
		String prem;
		
		for(Account acc : accs){
			prem = accRTNamesById.get(acc.RecordTypeId);
			if(prem != null){
				Account old = oldAccMap.get(acc.Id);
				if(acc.Called_On__c != old.Called_On__c ||
				   acc.State__c != old.State__c ||
				   acc.OwnerId != old.OwnerId ||
				   acc.Account_Segmentatiobn__c != old.Account_Segmentatiobn__c ||
				   acc.Primary_Demographic__c != old.Primary_Demographic__c){
					validAccs.add(acc);
					
					if(acc.State__c != null){
						accStateId = String.valueOf(acc.State__c).subString(0, 15);
						if(acc.Account_Segmentatiobn__c != null){
							incrementKeyMap(newSuriKeysToIncrement, accStateId + '|' + acc.Account_Segmentatiobn__c + '|' + prem);
							if(acc.Called_On__c){
								incrementKeyMap(newSuriCalledOnKeysToIncrement, accStateId + '|' + acc.Account_Segmentatiobn__c + '|' + prem);
							}
						}
						if(acc.Primary_Demographic__c != null){
							incrementKeyMap(newSuriKeysToIncrement, accStateId + '|' + acc.Primary_Demographic__c + '|' + prem);
							if(acc.Called_On__c){
								incrementKeyMap(newSuriCalledOnKeysToIncrement, accStateId + '|' + acc.Primary_Demographic__c + '|' + prem);
							}
						}
					}
					if(acc.OwnerId != null){
						accOwnerId = String.valueOf(acc.OwnerId).subString(0, 15);
						if(acc.Account_Segmentatiobn__c != null){
							incrementKeyMap(newSuriKeysToIncrement, accOwnerId + '|' + acc.Account_Segmentatiobn__c + '|' + prem);
							if(acc.Called_On__c){
								incrementKeyMap(newSuriCalledOnKeysToIncrement, accOwnerId + '|' + acc.Account_Segmentatiobn__c + '|' + prem);
							}
						}
						if(acc.Primary_Demographic__c != null){
							incrementKeyMap(newSuriKeysToIncrement, accOwnerId + '|' + acc.Primary_Demographic__c + '|' + prem);
							if(acc.Called_On__c){
								incrementKeyMap(newSuriCalledOnKeysToIncrement, accOwnerId + '|' + acc.Primary_Demographic__c + '|' + prem);
							}
						}
					}
					
					if(old.State__c != null){
						oldStateId = String.valueOf(old.State__c).subString(0, 15);
						if(old.Account_Segmentatiobn__c != null){
							incrementKeyMap(oldSuriKeysToDecrement, oldStateId + '|' + old.Account_Segmentatiobn__c + '|' + prem);
							if(old.Called_On__c){
								incrementKeyMap(oldSuriCalledOnKeysToDecrement, oldStateId + '|' + old.Account_Segmentatiobn__c + '|' + prem);
							}
						}
						if(old.Primary_Demographic__c != null){
							incrementKeyMap(oldSuriKeysToDecrement, oldStateId + '|' + old.Primary_Demographic__c + '|' + prem);
							if(acc.Called_On__c){
								incrementKeyMap(oldSuriCalledOnKeysToDecrement, oldStateId + '|' + old.Primary_Demographic__c + '|' + prem);
							}
						}
					}
					if(old.OwnerId != null){
						oldOwnerId = String.valueOf(old.OwnerId).subString(0, 15);
						if(old.Account_Segmentatiobn__c != null){
							incrementKeyMap(oldSuriKeysToDecrement, oldOwnerId + '|' + old.Account_Segmentatiobn__c + '|' + prem);
							if(old.Called_On__c){
								incrementKeyMap(oldSuriCalledOnKeysToDecrement, oldOwnerId + '|' + old.Account_Segmentatiobn__c + '|' + prem);
							}
						}
						if(old.Primary_Demographic__c != null){
							incrementKeyMap(oldSuriKeysToDecrement, oldOwnerId + '|' + old.Primary_Demographic__c + '|' + prem);
							if(acc.Called_On__c){
								incrementKeyMap(oldSuriCalledOnKeysToDecrement, oldOwnerId + '|' + old.Primary_Demographic__c + '|' + prem);
							}
						}
					}
					
					if(acc.State__c != old.State__c ||
				   	   acc.OwnerId != old.OwnerId ||
				   	   acc.Account_Segmentatiobn__c != old.Account_Segmentatiobn__c ||
				   	   acc.Primary_Demographic__c != old.Primary_Demographic__c){
				   	   	repointAccIds.add(acc.Id);
					}
				}
			}
		}
		
		if(validAccs.size() > 0){
			List<State_User_Report_Item__c> suris =
				[SELECT Id,
						Key__c,
						Accounts__c,
						Called_On_Accounts__c
				   FROM State_User_Report_Item__c
				  WHERE Key__c IN :newSuriKeysToIncrement.keySet()
				     OR Key__c IN :oldSuriKeysToDecrement.keySet()
				];
			Map<String, State_User_Report_Item__c> surisToUpsertByKey = new Map<String, State_User_Report_Item__c>();
			for(State_User_Report_Item__c suri : suris){
				surisToUpsertByKey.put(suri.Key__c, suri);
			}
			
			for(Account acc : validAccs){
				prem = accRTNamesById.get(acc.RecordTypeId);
				createSuriIfNeeded(surisToUpsertByKey, acc, prem);
			}
			for(String key : newSuriKeysToIncrement.keySet()){
				modifySuri(surisToUpsertByKey, key, newSuriKeysToIncrement.get(key), false, false);
			}
			for(String key : newSuriCalledOnKeysToIncrement.keySet()){
				modifySuri(surisToUpsertByKey, key, newSuriCalledOnKeysToIncrement.get(key), true, false);
			}
			for(String key : oldSuriKeysToDecrement.keySet()){
				modifySuri(surisToUpsertByKey, key, oldSuriKeysToDecrement.get(key), false, true);
			}
			for(String key : oldSuriCalledOnKeysToDecrement.keySet()){
				modifySuri(surisToUpsertByKey, key, oldSuriCalledOnKeysToDecrement.get(key), true, true);
			}
			
			upsert surisToUpsertByKey.values();
			
			if(repointAccIds.size() > 0){
				repointGARIs(repointAccIds);
			}
		}
	}
	
	private static void createSuriIfNeeded(Map<String, State_User_Report_Item__c> surisByKey, Account acc, String prem){
		String key;
		State_User_Report_Item__c suri;
		if(acc.State__c != null){
			String stateId = String.valueOf(acc.State__c).subString(0, 15);
			if(acc.Account_Segmentatiobn__c != null){
				key = stateId + '|' + acc.Account_Segmentatiobn__c + '|' + prem;
				if(surisByKey.get(key) == null){
					suri = new State_User_Report_Item__c();
					suri.State__c = stateId;
					suri.Account_Segmentation__c = acc.Account_Segmentatiobn__c;
					suri.Premise__c = prem;
					suri.Accounts__c = 0;
					suri.Called_On_Accounts__c = 0;
					surisByKey.put(key, suri);
				}
			}
			if(acc.Primary_Demographic__c != null){
				key = stateId + '|' + acc.Primary_Demographic__c + '|' + prem;
				if(surisByKey.get(key) == null){
					suri = new State_User_Report_Item__c();
					suri.State__c = stateId;
					suri.Primary_Demographic__c = acc.Primary_Demographic__c;
					suri.Premise__c = prem;
					suri.Accounts__c = 0;
					suri.Called_On_Accounts__c = 0;
					surisByKey.put(key, suri);
				}
			}
		}
		if(acc.OwnerId != null){
			String userId = String.valueOf(acc.OwnerId).subString(0, 15);
			if(acc.Account_Segmentatiobn__c != null){
				key = userId + '|' + acc.Account_Segmentatiobn__c + '|' + prem;
				if(surisByKey.get(key) == null){
					suri = new State_User_Report_Item__c();
					suri.User__c = userId;
					suri.Account_Segmentation__c = acc.Account_Segmentatiobn__c;
					suri.Premise__c = prem;
					suri.Accounts__c = 0;
					suri.Called_On_Accounts__c = 0;
					surisByKey.put(key, suri);
				}
			}
			if(acc.Primary_Demographic__c != null){
				key = userId + '|' + acc.Primary_Demographic__c + '|' + prem;
				if(surisByKey.get(key) == null){
					suri = new State_User_Report_Item__c();
					suri.User__c = userId;
					suri.Primary_Demographic__c = acc.Primary_Demographic__c;
					suri.Premise__c = prem;
					suri.Accounts__c = 0;
					suri.Called_On_Accounts__c = 0;
					surisByKey.put(key, suri);
				}
			}
		}
	}
	
	private static void modifySuri(Map<String, State_User_Report_Item__c> surisByKey, String key, Integer delta, Boolean isCalledOn, Boolean isDecrement){
		if(delta != null){
			if(isDecrement){
				delta = -1 * delta;
			}
			State_User_Report_Item__c suri = surisByKey.get(key);
			if(suri != null){
				if(isCalledOn){
					suri.Called_On_Accounts__c += delta;
				} else {
					suri.Accounts__c += delta;
				}
			}
		}
	}
	
	private static void incrementKeyMap(Map<String, Integer> keyMap, String key){
		Integer val = keyMap.get(key);
		if(val == null){
			val = 1;
		} else {
			val++;
		}
		keyMap.put(key, val);
	}
	
	public static void checkToPopulateStateField(List<Account> accs){
		List<Account> validAccs = new List<Account>();
		for(Account acc : accs){
			if(acc.NABCA_Licensee_State__c != null &&
			   acc.NABCA_Licensee_State__c != 'N1' &&
			   acc.State__c == null){
				validAccs.add(acc);
			}
		}
		if(validAccs.size() > 0){
			populateStateField(validAccs);
		}
	}
	
	public static void populateStateField(List<Account> accs){
		Set<String> stateAbrvs = new Set<String>();
		for(Account acc : accs){
			stateAbrvs.add(acc.NABCA_Licensee_State__c);
		}
		
		Map<String, Id> stateIdsByAbrv = new Map<String, Id>();
		for(State__c state : [SELECT Id, Abbreviation__c FROM State__c WHERE Abbreviation__c IN :stateAbrvs]){
			stateIdsByAbrv.put(state.Abbreviation__c, state.Id);
		}
		
		for(Account acc : accs){
			acc.State__c = stateIdsByAbrv.get(acc.NABCA_Licensee_State__c);
		}
	}
	
	private static void repointGARIs(Set<Id> changedAccIds){
		List<Goal_Account_Report_Item__c> garis = 
			[SELECT Id,
					Account__r.State__c,
					Account__r.OwnerId,
					Account__r.Account_Segmentatiobn__c,
					Account__r.Primary_Demographic__c,
					Account__r.RecordType.Name
			   FROM Goal_Account_Report_Item__c
			  WHERE Account__c IN :changedAccIds
			];
			
		Set<String> keys = new Set<String>();
		String stateId;
		String userId;
		String prem;
		for(Goal_Account_Report_Item__c gari : garis){
			if(gari.Account__r.RecordType.Name == 'On Premise' || gari.Account__r.RecordType.Name == 'On-Premise - Control'){
				prem = 'On';
			} else {
				prem = 'Off';
			}
			
			if(gari.Account__r.State__c != null){
				stateId = String.valueOf(gari.Account__r.State__c).subString(0, 15);
				if(gari.Account__r.Account_Segmentatiobn__c != null){
					keys.add(stateId + '|' + gari.Account__r.Account_Segmentatiobn__c + '|' + prem);
				}
				if(gari.Account__r.Primary_Demographic__c != null){
					keys.add(stateId + '|' + gari.Account__r.Primary_Demographic__c + '|' + prem);
				}
			}
			if(gari.Account__r.OwnerId != null){
				userId = String.valueOf(gari.Account__r.OwnerId).subString(0, 15);
				if(gari.Account__r.Account_Segmentatiobn__c != null){
					keys.add(userId + '|' + gari.Account__r.Account_Segmentatiobn__c + '|' + prem);
				}
				if(gari.Account__r.Primary_Demographic__c != null){
					keys.add(userId + '|' + gari.Account__r.Primary_Demographic__c + '|' + prem);
				}
			}
		}
		
		List<State_User_Report_Item__c> suris =
			[SELECT Id, Key__c FROM State_User_Report_Item__c WHERE Key__c IN :keys];
		Map<String, Id> suriIdsByKey = new Map<String, Id>();
		for(State_User_Report_Item__c suri : suris){
			suriIdsByKey.put(suri.Key__c, suri.Id);
		}
			
		for(Goal_Account_Report_Item__c gari : garis){
			if(gari.Account__r.RecordType.Name == 'On Premise' || gari.Account__r.RecordType.Name == 'On-Premise - Control'){
				prem = 'On';
			} else {
				prem = 'Off';
			}
			
			if(gari.Account__r.State__c != null){
				stateId = String.valueOf(gari.Account__r.State__c).subString(0, 15);
				if(gari.Account__r.Account_Segmentatiobn__c != null){
					gari.State_AS_SURI__c = suriIdsByKey.get(stateId + '|' + gari.Account__r.Account_Segmentatiobn__c + '|' + prem);
				}
				if(gari.Account__r.Primary_Demographic__c != null){
					gari.State_PD_SURI__c = suriIdsByKey.get(stateId + '|' + gari.Account__r.Primary_Demographic__c + '|' + prem);
				}
			}
			if(gari.Account__r.OwnerId != null){
				userId = String.valueOf(gari.Account__r.OwnerId).subString(0, 15);
				if(gari.Account__r.Account_Segmentatiobn__c != null){
					gari.User_AS_SURI__c = suriIdsByKey.get(userId + '|' + gari.Account__r.Account_Segmentatiobn__c + '|' + prem);
				}
				if(gari.Account__r.Primary_Demographic__c != null){
					gari.User_PD_SURI__c = suriIdsByKey.get(userId + '|' + gari.Account__r.Primary_Demographic__c + '|' + prem);
				}
			}
		}
		
		update garis;
		
	}
	
	public static void checkChangedFieldsForGARI(Map<Id, Account> oldMap, List<Account> accs){
		Set<Id> accIds = new Set<Id>();
		for(Account acc : accs){
			Account old = oldMap.get(acc.Id);
			if(acc.OwnerId != old.OwnerId || acc.Primary_Demographic__c != old.Primary_Demographic__c){
				accIds.add(acc.Id);
			}
		}
		if(accIds.size() > 0){
			List<Goal_Account_Report_Item__c> garis = [SELECT Id, Account__c FROM Goal_Account_Report_Item__c WHERE Account__c IN :accIds];
			GoalAccountReportItemActions.copyFieldsFromAccount(garis);
			update garis;
		}
	}

}