/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        08/29/2012
 * @description populate some lookup field data
 */
trigger POS_Budget on Budget__c (before insert, before update, after insert, after update, after delete) {
	
	if(trigger.isBefore) {
		
        List<Id> shopperIds = new List<Id>();
        for(Budget__c n : trigger.new) {
            shopperIds.add(n.Shopper__c);
        }
        Map<Id, User> shopperAccts = new Map<Id, User>([SELECT Id, Name FROM User where id in :shopperIds]);
        
        List<Id> parentIds = new List<Id>();
        for (Budget__c n:trigger.new) {
            if (n.Parent__c!=null) {
                parentIds.add(n.Parent__c);
            }
        }
        
        Map<Id, Id> orderWindowMap = new Map<Id,Id>();
        for(Budget__c n: trigger.new){
            if(n.Order_Window__c != null){
                orderWindowMap.put(n.Id,n.Order_Window__c);
            }
        }
        
		Map<Id, List<Item_Brand__c>> iBrandsMap = new Map<Id, List<Item_Brand__c>>(); // Id is Order_Window__c
		Map<Id, List<Item_Brand__c>> iParentBrandsMap = new Map<Id, List<Item_Brand__c>>(); // Id is Order_Window__c
		
		List<Item_Brand__c> itemBrandList = [SELECT Brand__c, Brand__r.Parent_Brand__c,Item__r.Program__r.Order_Window__c FROM Item_Brand__c where Item__r.Program__r.Order_Window__r.Id=
												: orderWindowMap.values() and Primary__c=true and Item__r.Status__c not in ('Cancelled', 'Removed')] ;
			System.debug('---------itemBrandList'+itemBrandList);									
		//4.22.2013-CASE 4878 - LSLEVIN - START//
		//Renamed below list from iBarndList to iBrandList to fix typo
		//List<Item_Brand__c> iBrandList = new List<Item_Brand__c>();
		//4.22.2013-CASE 4878 - LSLEVIN - END//
		
		for(Budget__c n: trigger.new){	
			if(n.Order_Window__c != null){
			  	List<Item_Brand__c> iBrandList = new List<Item_Brand__c>();
				List<Item_Brand__c> iParentBrandList = new List<Item_Brand__c>();
				for(Item_Brand__c ib: itemBrandList){
					if(n.Order_Window__c == ib.Item__r.Program__r.Order_Window__c){
						iBrandList.add(ib);
						//4.22.2013-CASE 4878 - LSLEVIN - START//
						//System.debug('-----iBrandList'+iBrandList);
						//4.22.2013-CASE 4878 - LSLEVIN - END//
						if(ib.Brand__r.Parent_Brand__c != null){
							iParentBrandList.add(ib);
						}
					}
					//4.22.2013-CASE 4878 - LSLEVIN - START//
					//System.debug('----iParentBrandList'+iParentBrandList);
					//4.22.2013-CASE 4878 - LSLEVIN - END//
				}
				if(iBrandList.size() > 0)
					iBrandsMap.put(n.Order_Window__c, iBrandList);
				if(iParentBrandList.size() > 0)
					iParentBrandsMap.put(n.Order_Window__c, iParentBrandList);
			}
			//4.22.2013-CASE 4878 - LSLEVIN - START//
			//System.debug('----iParentBrandsMap' +iParentBrandsMap );
			//4.22.2013-CASE 4878 - LSLEVIN - END//
		}
		
		
		Map<Id,Budget__c> parentMap = new Map<Id,Budget__c>([select Id, Spent_Amount__c, Spent_Item_Quantity__c, Budget_Creator__c from Budget__c where Id in: parentIds]);
		List<Budget__c> updateParents = new List<Budget__c>();
		
		Map<Id, Set<Id>> accBrandIdsForUserMap = new Map<Id, Set<Id>>(); // Id is Shopper__c
		
		for(Budget__c n : trigger.new) {
			
			if(n.Brand__c != null) { // Budget Allocation by Brand, check for Shopper, Brand combination to be valid
				Boolean shopperBrandValid = false;
				Set<Id> accBrandIdsForUser = accBrandIdsForUserMap.get(n.Shopper__c);
				if(accBrandIdsForUser == null) {
					accBrandIdsForUser = POS_ServiceAPI.getAccBrandIdsWithParentForUser(n.Shopper__c);
					accBrandIdsForUserMap.put(n.Shopper__c, accBrandIdsForUser);
				}
				for(Id bdId : accBrandIdsForUser) {
					if(bdId == n.Brand__c) {
						shopperBrandValid = true;
						break;
					}
				}
				//4.22.2013-CASE 4878 - LSLEVIN - START//
				//System.debug('n.Brand__c =' + n.Brand__c);
				//4.22.2013-CASE 4878 - LSLEVIN - END//
				if(!shopperBrandValid) {
					n.addError('Shopper "' + shopperAccts.get(n.Shopper__c).Name + '" doesnot have access to the Brand you are trying to assign. ' + n.Brand__c);
					
				} else {
					//4.22.2013-CASE 4878 - LSLEVIN - START//
					//System.debug('n.Order_Window__c -' + n.Order_Window__c);
					//4.22.2013-CASE 4878 - LSLEVIN - END//
					Set<Id> iBrandIds = new Set<Id>();
					
					List<Item_Brand__c> iBrands = iBrandsMap.get(n.Order_Window__c);
					/*if(iBrands == null) {
						iBrands = [SELECT Brand__c FROM Item_Brand__c where Item__r.Program__r.Order_Window__r.Id= :n.Order_Window__c 
													and Primary__c=true and Item__r.Status__c not in ('Cancelled', 'Removed')];
						iBrandsMap.put(n.Order_Window__c, iBrands);						
					}*/
			        for(Item_Brand__c ib : iBrands) {
			        	iBrandIds.add(ib.Brand__c);
			        }	
			        
					List<Item_Brand__c> iParentBrands = iParentBrandsMap.get(n.Order_Window__c);
					//4.22.2013-CASE 4878 - LSLEVIN - START//
					//System.debug('-----iParentBrands' + iParentBrands);
					//4.22.2013-CASE 4878 - LSLEVIN - END//
					/*if(iParentBrands == null) {
						iParentBrands = [SELECT Brand__r.Parent_Brand__c FROM Item_Brand__c where Item__r.Program__r.Order_Window__r.Id= :n.Order_Window__c 
													and Primary__c=true and Item__r.Status__c not in ('Cancelled', 'Removed') and Brand__r.Parent_Brand__c!=null];
						iParentBrandsMap.put(n.Order_Window__c, iParentBrands);						
					}*/					
			        for(Item_Brand__c ib : iParentBrands) {
			        	iBrandIds.add(ib.Brand__r.Parent_Brand__c);
			        }		        
			        
			        if(!iBrandIds.contains(n.Brand__c)) {
			        	n.addError('The Brand you are trying to assign to Shopper "' + shopperAccts.get(n.Shopper__c).Name + '" is not associated with this Order Window. ' + n.Brand__c);
			        }					
				}
			}
	
			// set Budget_Creator__c one time, for child lineitems it will be derrived from the parent
			if(n.Budget_Creator__c == null) {
				if(n.Parent__c==null) {
					n.Budget_Creator__c = UserInfo.getUserId();
				} else {
					n.Budget_Creator__c = (parentMap.get(n.Parent__c)).Budget_Creator__c;
				}
			}
			
			//Get parents so we have their spend amounts
			if (n.Parent__c !=null) {
				decimal oldTotalSpend = 0;
				Budget__c parent = parentMap.get(n.Parent__c);
				//4.22.2013-CASE 4878 - LSLEVIN - START//
				//System.debug('PARENT: '+parent);
				//4.22.2013-CASE 4878 - LSLEVIN - END//
				if(n.Brand__c != null) {	
								
					if (trigger.isUpdate) {
						Budget__c old = trigger.oldMap.get(n.Id);
						
						oldTotalSpend = old.Spent_Amount__c;
						if (old.My_Spent_Amount__c!=null) {
							oldTotalSpend=oldTotalSpend+old.My_Spent_Amount__c;
						}
					}
					
	
					Decimal originalValue = parent.Spent_Amount__c;
					parent.Spent_Amount__c = parent.Spent_Amount__c-oldTotalSpend;
					parent.Spent_Amount__c = parent.Spent_Amount__c+n.Spent_Amount__c;
					if (n.My_Spent_Amount__c!=null) {
						parent.Spent_Amount__c = parent.Spent_Amount__c+n.My_Spent_Amount__c;
					} 
					
					//4.22.2013-CASE 4878 - LSLEVIN - START//
					//System.debug('New value: '+parent.Spent_Amount__c);
					//System.debug('Old value: '+originalValue);
					//4.22.2013-CASE 4878 - LSLEVIN - END//
					
					if (originalValue!=parent.Spent_Amount__c) {
						updateParents.add(parent);
					}
					
				} else if (n.Item__c != null) {
					
					if (trigger.isUpdate) {
						Budget__c old = trigger.oldMap.get(n.Id);
						
						oldTotalSpend = old.Spent_Item_Quantity__c;
						if (old.My_Spent_Item_Quantity__c!=null) {
							oldTotalSpend=oldTotalSpend+old.My_Spent_Item_Quantity__c;
						}
					}
					
	
					Decimal originalValue = parent.Spent_Item_Quantity__c;
					parent.Spent_Item_Quantity__c = parent.Spent_Item_Quantity__c-oldTotalSpend;
					parent.Spent_Item_Quantity__c = parent.Spent_Item_Quantity__c+n.Spent_Item_Quantity__c;
					if (n.My_Spent_Item_Quantity__c!=null) {
						parent.Spent_Item_Quantity__c = parent.Spent_Item_Quantity__c+n.My_Spent_Item_Quantity__c;
					} 
					//4.22.2013-CASE 4878 - LSLEVIN - START//
					//System.debug('New value Item: '+parent.Spent_Item_Quantity__c);
					//System.debug('Old value Item: '+originalValue);
					//4.22.2013-CASE 4878 - LSLEVIN - END//
					
					if (originalValue!=parent.Spent_Item_Quantity__c) {
						updateParents.add(parent);
					}					
					
				}
			}
		}
		update updateParents;
			
	} else { 
		
		// START - Logic to update the Sub-allocation, Spent amount of the parent budget item where applicable
		Map<Id, Double> parentBudgetSubAllocationMap = new Map<Id, Double>();
		Map<Id, Double> parentBudgetSpentAmountMap = new Map<Id, Double>();
		Map<Id, Double> parentItemSubAllocationMap = new Map<Id, Double>();
		Map<Id, Double> parentItemSpentAmountMap = new Map<Id, Double>();		
		
		if (trigger.isInsert) {
			for(Budget__c n: trigger.new) {
				if(n.Parent__c != null) {
					if(n.Brand__c != null) {
						Double existingSuballocationValue = parentBudgetSubAllocationMap.get(n.Parent__c);
						Double existingSpentValue = parentBudgetSpentAmountMap.get(n.Parent__c);
						
						if(existingSuballocationValue == null) {
							parentBudgetSubAllocationMap.put(n.Parent__c, n.Amount__c);
						} else {
							parentBudgetSubAllocationMap.put(n.Parent__c, existingSuballocationValue + n.Amount__c);
						}
						
						if(existingSpentValue == null) {
							parentBudgetSpentAmountMap.put(n.Parent__c, n.Spent_Amount__c);
						} else {
							parentBudgetSpentAmountMap.put(n.Parent__c, existingSpentValue + n.Spent_Amount__c);
						}	
					} else if (n.Item__c != null) {
						Double existingItemSuballocationValue = parentItemSubAllocationMap.get(n.Parent__c);
						Double existingItemSpentValue = parentItemSpentAmountMap.get(n.Parent__c);
						
						if(existingItemSuballocationValue == null) {
							parentItemSubAllocationMap.put(n.Parent__c, n.Item_Allocation_Quantity__c);
						} else {
							parentItemSubAllocationMap.put(n.Parent__c, existingItemSuballocationValue + n.Item_Allocation_Quantity__c);
						}
						
						if(existingItemSpentValue == null) {
							parentItemSpentAmountMap.put(n.Parent__c, n.Spent_Item_Quantity__c);
						} else {
							parentItemSpentAmountMap.put(n.Parent__c, existingItemSpentValue + n.Spent_Item_Quantity__c);
						}						
					}			
				}
				//System.debug('parentBudgetSubAllocationMap.get(n.Parent__c) -' + parentBudgetSubAllocationMap.get(n.Parent__c));
			}				
					 
		} else if (trigger.isUpdate) {
			Double oldAmt;   
			Double oldSpentdAmt;
			Double oldQty;   
			Double oldSpentdQty;
			
			for(Budget__c n: trigger.new) {
				oldAmt = trigger.oldMap.get(n.id).Amount__c;
				oldSpentdAmt = trigger.oldMap.get(n.id).Spent_Amount__c;
				oldQty = trigger.oldMap.get(n.id).Item_Allocation_Quantity__c;
				oldSpentdQty = trigger.oldMap.get(n.id).Spent_Item_Quantity__c;				
				
				if(n.Parent__c != null) {
					if (n.Brand__c != null) {
						if(oldAmt != n.Amount__c) { 
							Double existingSuballocationValue = parentBudgetSubAllocationMap.get(n.Parent__c);
							Double existingSpentValue = parentBudgetSpentAmountMap.get(n.Parent__c);
							
							if(existingSuballocationValue == null) {
								parentBudgetSubAllocationMap.put(n.Parent__c, n.Amount__c - oldAmt);
							} else {
								parentBudgetSubAllocationMap.put(n.Parent__c, existingSuballocationValue + n.Amount__c - oldAmt);
							}
							
							if(existingSpentValue == null) {
								parentBudgetSpentAmountMap.put(n.Parent__c, n.Spent_Amount__c - oldSpentdAmt);
							} else {
								parentBudgetSpentAmountMap.put(n.Parent__c, existingSpentValue + n.Spent_Amount__c - oldSpentdAmt);
							}						
						} 
					} else if (n.Item__c != null) {
						if(oldQty != n.Item_Allocation_Quantity__c) { 
							Double existingItemSuballocationValue = parentItemSubAllocationMap.get(n.Parent__c);
							Double existingItemSpentValue = parentItemSpentAmountMap.get(n.Parent__c);
							
							if(existingItemSuballocationValue == null) {
								parentItemSubAllocationMap.put(n.Parent__c, n.Item_Allocation_Quantity__c - oldQty);
							} else {
								parentItemSubAllocationMap.put(n.Parent__c, existingItemSuballocationValue + n.Item_Allocation_Quantity__c - oldQty);
							}
							
							if(existingItemSpentValue == null) {
								parentItemSpentAmountMap.put(n.Parent__c, n.Spent_Item_Quantity__c - oldSpentdQty);
							} else {
								parentItemSpentAmountMap.put(n.Parent__c, existingItemSpentValue + n.Spent_Item_Quantity__c - oldSpentdQty);
							}						
						}						
					}

				}
				//System.debug('n.Parent__c -' + n.Parent__c + ' oldAmt -' + oldAmt  + ' n.Amount__c -' + n.Amount__c 
					//+ ' oldSubAllocatedAmt -' + oldSubAllocatedAmt + ' n.Sub_Allocated_Amount__c -' + n.Sub_Allocated_Amount__c);
			}					
										
		} else if (trigger.isDelete) {
			for(Budget__c o: trigger.old) {
				if(o.Parent__c != null) {
					if (o.Brand__c != null) {
						Double existingSuballocationValue = parentBudgetSubAllocationMap.get(o.Parent__c);
						Double existingSpentValue = parentBudgetSpentAmountMap.get(o.Parent__c);					
	
						if(existingSuballocationValue == null) {
							parentBudgetSubAllocationMap.put(o.Parent__c, -o.Amount__c);
						} else {
							parentBudgetSubAllocationMap.put(o.Parent__c, existingSuballocationValue + (-o.Amount__c));
						}
						
						if(existingSpentValue == null) {
							parentBudgetSpentAmountMap.put(o.Parent__c, -o.Spent_Amount__c);
						} else {
							parentBudgetSpentAmountMap.put(o.Parent__c, existingSuballocationValue + (-o.Spent_Amount__c));
						}	
					} else if (o.Item__c != null) {	
						Double existingItemSuballocationValue = parentItemSubAllocationMap.get(o.Parent__c);
						Double existingItemSpentValue = parentItemSpentAmountMap.get(o.Parent__c);					
	
						if(existingItemSuballocationValue == null) {
							parentItemSubAllocationMap.put(o.Parent__c, -o.Item_Allocation_Quantity__c);
						} else {
							parentItemSubAllocationMap.put(o.Parent__c, existingItemSuballocationValue + (-o.Item_Allocation_Quantity__c));
						}
						
						if(existingItemSpentValue == null) {
							parentItemSpentAmountMap.put(o.Parent__c, -o.Spent_Item_Quantity__c);
						} else {
							parentItemSpentAmountMap.put(o.Parent__c, existingItemSpentValue + (-o.Spent_Item_Quantity__c));
						}							
					}			
				}	
			}	   	
		}
		
		if(parentBudgetSubAllocationMap.size() > 0) { // both Budget Maps will have same Ids, so iterating through one of them is enough here
			List<Budget__c> parBudgetList = [SELECT Id, Sub_Allocated_Amount__c, Spent_Amount__c from Budget__c 
												where id in :parentBudgetSubAllocationMap.keySet()];
			System.debug('parentBudgetSubAllocationMap -' + parentBudgetSubAllocationMap + '\n parBudgetList -' + parBudgetList);
				
			for(Budget__c budgetRec : parBudgetList) {
				budgetRec.Sub_Allocated_Amount__c = budgetRec.Sub_Allocated_Amount__c + parentBudgetSubAllocationMap.get(budgetRec.Id);
				budgetRec.Spent_Amount__c = budgetRec.Spent_Amount__c + parentBudgetSpentAmountMap.get(budgetRec.Id);
			}
			
			update parBudgetList;
		}
		
		if(parentItemSubAllocationMap.size() > 0) { // both Item Maps will have same Ids, so iterating through one of them is enough here
			List<Budget__c> parBudgetList = [SELECT Id, Sub_Allocated_Item_Quantity__c, Spent_Item_Quantity__c from Budget__c 
												where id in :parentItemSubAllocationMap.keySet()];
			System.debug('parentItemSubAllocationMap -' + parentItemSubAllocationMap + '\n parBudgetList -' + parBudgetList);
				
			for(Budget__c budgetRec : parBudgetList) {
				budgetRec.Sub_Allocated_Item_Quantity__c = budgetRec.Sub_Allocated_Item_Quantity__c + parentItemSubAllocationMap.get(budgetRec.Id);
				budgetRec.Spent_Item_Quantity__c = budgetRec.Spent_Item_Quantity__c + parentItemSpentAmountMap.get(budgetRec.Id);
			}
			
			update parBudgetList;
		}		
		// END - Logic to update the Sub-allocation, Spent amount of the parent budget item where applicable
		
		// START - Logic to proporatinally distribute the Decreased budget amount among sub-allocations
		if (trigger.isUpdate) {
			
			for(Budget__c n: trigger.new) {
				//oldAmt = trigger.oldMap.get(n.id).Amount__c;
				//oldUnallocatedAmt = trigger.oldMap.get(n.id).Unallocated_Amount__c;
				if (n.Brand__c != null) {
					
					//4.22.2013-CASE 4878 - LSLEVIN - START//
					//System.debug('n.Amount__c -' + n.Amount__c + ' n.Sub_Allocated_Amount__c -' + n.Sub_Allocated_Amount__c + ' n.Unallocated_Amount__c -' + n.Unallocated_Amount__c);
					//4.22.2013-CASE 4878 - LSLEVIN - END//
					
					if(n.Unallocated_Amount__c < 0) {
						Double overagePctg = (n.Unallocated_Amount__c/n.Sub_Allocated_Amount__c)*-1;
						//4.22.2013-CASE 4878 - LSLEVIN - START//
						//System.debug('overagePctg -' + overagePctg);
						//4.22.2013-CASE 4878 - LSLEVIN - END//
						
						// get sub-allocations and distribute the decreased amount proportionally																		
						List<Budget__c> suballocations = [SELECT Id, Amount__c FROM Budget__c where Parent__c=:n.Id];
						//4.22.2013-CASE 4878 - LSLEVIN - START//
						//System.debug('suballocations -' + suballocations);
						//4.22.2013-CASE 4878 - LSLEVIN - END//
						for(Budget__c sa : suballocations) {
							sa.Amount__c = sa.Amount__c - (sa.Amount__c * overagePctg);
						}
						
						//4.22.2013-CASE 4878 - LSLEVIN - START//
						//System.debug('suballocations -' + suballocations);
						//4.22.2013-CASE 4878 - LSLEVIN - END//
						update suballocations;				
					}
					
				} else if (n.Item__c != null) {
					//4.22.2013-CASE 4878 - LSLEVIN - START//
					//System.debug('n.Item_Allocation_Quantity__c -' + n.Item_Allocation_Quantity__c + ' n.Sub_Allocated_Item_Quantity__c -' + n.Sub_Allocated_Item_Quantity__c + ' n.Unallocated_Item_Quantity__c -' + n.Unallocated_Item_Quantity__c);
					//4.22.2013-CASE 4878 - LSLEVIN - END//
					if(n.Unallocated_Item_Quantity__c < 0) {
						Double overagePctg = (n.Unallocated_Item_Quantity__c/n.Sub_Allocated_Item_Quantity__c)*-1;
						//4.22.2013-CASE 4878 - LSLEVIN - START//
						//System.debug('overagePctg -' + overagePctg);
						//4.22.2013-CASE 4878 - LSLEVIN - START//
						// get sub-allocations and distribute the decreased amount proportionally																		
						List<Budget__c> suballocations = [SELECT Id, Item_Allocation_Quantity__c FROM Budget__c where Parent__c=:n.Id];
						//4.22.2013-CASE 4878 - LSLEVIN - START//
						//System.debug('suballocations -' + suballocations);
						//4.22.2013-CASE 4878 - LSLEVIN - START//
						for(Budget__c sa : suballocations) {
							sa.Item_Allocation_Quantity__c = sa.Item_Allocation_Quantity__c - (sa.Item_Allocation_Quantity__c * overagePctg);
						}
						//4.22.2013-CASE 4878 - LSLEVIN - START//
						//System.debug('suballocations -' + suballocations);
						//4.22.2013-CASE 4878 - LSLEVIN - END//
						update suballocations;				
					}
				}

			}
		}
		// END - Logic to proporatinally distribute the Decreased budget amount among sub-allocations
		
	}

}