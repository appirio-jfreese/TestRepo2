trigger POS_CartTrigger on Cart__c (after insert, after update) {
	boolean cartItemDeletion = POS_MagentoCartRESTResource.deleteCartItem ;// Code optimization done by Jai Gupta [Appirio Jaipur] on June 26,13 for case 00048953
	for(Cart__c newCart : trigger.new) {					
		Cart__c oldCart = null;
		if (trigger.isUpdate) {
			oldCart = trigger.oldMap.get(newCart.Id);
		}
		
		System.debug('Submitting: '+newCart);
		System.debug('Old cart was: '+oldCart);
		
		//if (newCart.Status__c=='Submitted' && (oldCart==null || oldCart.Status__c=='Open')) { // commented out this as budget totals needs to be re-calculated even after submission to reflect Cancelled Items, Price Changes. VK: 11/13/2012
		// // Code optimization done by Jai Gupta [Appirio Jaipur] on June 26,13 for case 00048953
			if(!cartITemDeletion && (newCart.Status__c == 'Submitted' || newCart.Status__c == 'Cancelled') && (oldCart == null || newCart.Status__c != oldCart.Status__c)){
				// ENd for case 00048953
			//New cart submitted so need to query underlying cart items to recalculate budget totals
			//Get list of budgets assigned to the cart owner
			List<Budget__c> budgets = [select Id, My_Spent_Amount__c, My_Spent_Overage__c, Brand__c, Brand__r.Name, Brand__r.Parent_Brand__c, Unallocated_Amount__c, Spent_Amount__c, Remaining_Amount__c, 
							My_Spent_Item_Quantity__c, Item__c, Unallocated_Item_Quantity__c from Budget__c where Order_Window__c=:newCart.Order_Window__c and Shopper__c = :newCart.Shopper__c];

			//Get list of cart items
			List<Cart_Item__c> cartItems = [select Id, Quantity__c, Item__c from Cart_Item__c where Cart__c=:newCart.Id];
			
			
			//Get map of Item information (need to get seperately because of brand subquery)
			List<Id> itemIds = new List<Id>();
			for (Cart_Item__c cartItem:cartItems) {
				itemIds.add(cartItem.Item__c);
			}
			
			Map<Id,Item__c> itemMap = new Map<Id,Item__c>([Select Id, Name, Current_Price__c, Estimated_Shipping_Tax__c, On_Allocation__c, 
																	(Select Brand__r.Name, Brand__r.Id, Brand__r.Parent_Brand__c From Item_Brands__r where Primary__c=true) 
															from Item__c where Id in :itemIds and Status__c not in ('Cancelled', 'Removed')]);
			
			//Now build a map of brands to budgets that we'll be updating and zero out Spent_Amount__c while doing it
			Map<Id,List<Budget__c>> brandBudgetMap = new Map<Id,List<Budget__c>>(); //ID is Brand
			Map<Id,List<Budget__c>> itemBudgetMap = new Map<Id,List<Budget__c>>(); //ID is Item
			for (Budget__c budget:budgets) {
				
				if(budget.Brand__c != null) {
					budget.My_Spent_Amount__c=0; // IMP: Note that at individul Budget level My_Spent_Amount__c is reset and calulated from scratch.
					budget.My_Spent_Overage__c=0;
					List<Budget__c> budgetsFromBrand = brandBudgetMap.get(budget.Brand__c);
					if (budgetsFromBrand == null) {
						budgetsFromBrand = new List<Budget__c>();
						brandBudgetMap.put(budget.Brand__c,budgetsFromBrand);
					}
					budgetsFromBrand.add(budget);
						
				} else if (budget.Item__c != null) {
					budget.My_Spent_Item_Quantity__c=0;
					List<Budget__c> budgetsFromItem = itemBudgetMap.get(budget.Item__c);
					if (budgetsFromItem == null) {
						budgetsFromItem = new List<Budget__c>();
						itemBudgetMap.put(budget.Item__c,budgetsFromItem);
					}
					budgetsFromItem.add(budget);					
					
				}
			}			
			
			Map<Id, Decimal> limitedItemQtyMap = new Map<Id, Decimal>(); //ID is Item, stores #of LimitedQtyItem that's in the cart
			
			//Now iterate through the cart and start spending against the  directly assigned Individual budgets
			//If we have two Individual budgets on one brand, we divide the spend proportionally against them so we don't blow one budget and leave another one wide open
			for (Cart_Item__c cartItem:cartItems) {
				
				Item__c item = itemMap.get(cartItem.Item__c);
				if(item == null) { // Cancelled, Removed or Deleted Item, should not be account for Spent calculation. VK:11/13/2012
					continue;
				}
				
				if(!item.On_Allocation__c) { // regular budget by Brand
					//Calculate total spend
					Decimal totalSpend = cartItem.Quantity__c*(1+(item.Estimated_Shipping_Tax__c/100))*item.Current_Price__c;
					if(totalSpend == 0) {
						continue;
					}
					
					Brand__c brand = (item.Item_Brands__r.get(0)).Brand__r;
					List<Budget__c> budgetsFromBrand = brandBudgetMap.get(brand.Id);
					
					if (budgetsFromBrand==null || budgetsFromBrand.size()==0) {
						//There is no budget for this brand/shopper, check if the parent brand has budget for this shopper.
						budgetsFromBrand = brandBudgetMap.get(brand.Parent_Brand__c);
						
						if (budgetsFromBrand==null || budgetsFromBrand.size()==0) {
							//There is no budget even for the parent brand move on					
							continue;
						}
					}
					
					//Determine total budget
					Decimal totalAvailableBudget=0;
					for (Budget__c budget:budgetsFromBrand) {
						Decimal availableBudget = budget.Unallocated_Amount__c - budget.Spent_Amount__c;
						if(availableBudget > 0) { // don't add the budget items which are already consumed or -ve.
							totalAvailableBudget = totalAvailableBudget + availableBudget;
						}
					}
					
					//Now we have the total available, so we can figure out the proportion to assign to each budget
					for (Budget__c budget:budgetsFromBrand) {
						
						System.debug('1:beforeCalculation budget.My_Spent_Amount__c - ' + budget.My_Spent_Amount__c + ' budget.My_Spent_Overage__c - ' + budget.My_Spent_Overage__c + ' id - ' + budget.Id);
						
						if (totalAvailableBudget == 0) {
							//if zero totalAvailable need to handle it by splitting equally
							budget.My_Spent_Amount__c = budget.My_Spent_Amount__c+(totalSpend/budgetsFromBrand.size());
							
							// check if there is Overage
							decimal individualOverage = budget.Unallocated_Amount__c - (budget.Spent_Amount__c + budget.My_Spent_Amount__c);
							if(individualOverage < 0) {
								budget.My_Spent_Overage__c = Math.abs(individualOverage);
							}
						}
						else {
							if(budget.Unallocated_Amount__c - budget.Spent_Amount__c > 0) { // will skip deducting from budget where there is no money left
								Decimal percentOfBudget = budget.Unallocated_Amount__c/totalAvailableBudget;
								budget.My_Spent_Amount__c = budget.My_Spent_Amount__c+(percentOfBudget*totalSpend);
							
								// check if there is Overage
								decimal individualOverage = budget.Unallocated_Amount__c - (budget.Spent_Amount__c + budget.My_Spent_Amount__c);
								if(individualOverage < 0) {
									budget.My_Spent_Overage__c = Math.abs(individualOverage);
								}	
							}					
						}
						System.debug('1:afterCalculation budget.My_Spent_Amount__c - ' + budget.My_Spent_Amount__c + ' budget.My_Spent_Overage__c - ' + budget.My_Spent_Overage__c + ' id - ' + budget.Id);
				  	} 
				  	
				} else { // budgeting by ItemAllocation
					
					// create limitedItemQtyMap on the first pass through CartItems, validation and allocation will be done in seperate loop below
					if(cartItem.Quantity__c > 0) {
						Decimal qtySoFar = (limitedItemQtyMap.get(item.Id) == null)? 0 : limitedItemQtyMap.get(item.Id);
						limitedItemQtyMap.put(item.id, qtySoFar+cartItem.Quantity__c);
					}
				}
			}
			
			//Now iterate through the limitedItemQtyMap and start spending against the Item Qty allocation budgets
			for (Id itemId:limitedItemQtyMap.keySet()) {
				Item__c item = itemMap.get(itemId);
		
				// logic to assign Limited Qty Items if there is enough budget, else raise error
				List<Budget__c> budgetsFromItem = itemBudgetMap.get(item.Id);
				if (budgetsFromItem==null) { // No budget corresponding to this Limited Qty Items exists for this Shopper
					// VK: commenting out Budget validation in Trigger as this is done upfront in the CartRestResource (11/20/2012)
					//newCart.addError('Failed to Submit Cart. Your cart contains Limited Quantity Item &quot;' + item.Name + '&quot; for which you do not have a budget assigned.');
					continue;
				}

				//Determine total budget
				Decimal totalAvailableBudget=0;
				for (Budget__c budget:budgetsFromItem) {
					totalAvailableBudget = totalAvailableBudget+budget.Unallocated_Item_Quantity__c;
				}
					
				System.debug('1:totalAvailableBudget - ' + totalAvailableBudget + '  2:limitedItemQtyMap.get(itemId) - ' + limitedItemQtyMap.get(itemId));	
				
				// VK: commenting out Budget validation in Trigger as this is done upfront in the CartRestResource (11/20/2012)
				/*if(limitedItemQtyMap.get(itemId) > totalAvailableBudget) {
					
					newCart.addError('Failed to Submit Cart. Quantity chosen for Limited Quantity Item &quot;' + item.Name + '&quot; is more than assigned budget of '+totalAvailableBudget +'.');
				} else {*/
					
					System.debug('Calculating Item Qty Spent for - ' + item.Name);
					//Now we have the total available, so we can figure out the proportion to assign to each budget
					for (Budget__c budget:budgetsFromItem) {
						Decimal percentOfBudget = budget.Unallocated_Item_Quantity__c/totalAvailableBudget;
						budget.My_Spent_Item_Quantity__c = budget.My_Spent_Item_Quantity__c+(percentOfBudget*limitedItemQtyMap.get(itemId));
						System.debug('budget.My_Spent_Item_Quantity__c - ' + budget.My_Spent_Item_Quantity__c);
					}	
				//}	
			}		
		
			// logic to CASCADE the individual budget overage to PARENT brand budget if exists for the same Shopper, Window
			for(Budget__c budget:budgets) {
				//Decimal availableBudget = budget.Unallocated_Amount__c - budget.Spent_Amount__c;
				
				if(budget.My_Spent_Overage__c > 0 && brandBudgetMap.get(budget.Brand__r.Parent_Brand__c) != null) {
					List<Budget__c> budgetsFromParentBrand = brandBudgetMap.get(budget.Brand__r.Parent_Brand__c);
					//Decimal overageAtIndividual = budget.My_Spent_Amount__c - availableBudget;
					System.debug('Calculation overageAtIndividual for - ' + budget.Brand__r.Name + ' = ' + budget.My_Spent_Overage__c);
					
					//Determine total available budget on the parent budget items
					Decimal totalAvailableBudgetAtParent=0;
					for (Budget__c pbudget:budgetsFromParentBrand) {
						Decimal availableBudgetAtParent = pbudget.Remaining_Amount__c - pbudget.My_Spent_Overage__c; // Note this can't be : pbudget.Unallocated_Amount__c - pbudget.Spent_Amount__c; as My_Spent_Amount__c is not recalculted inline here
						if(availableBudgetAtParent > 0) { // don't add the budget items which are already consumed or -ve.
							totalAvailableBudgetAtParent = totalAvailableBudgetAtParent + availableBudgetAtParent;
						}
					}
					
					//Now we have the total available at Parent, so we can figure out the proportion to assign to each parent budget
					for (Budget__c pbudget:budgetsFromParentBrand) {
						System.debug('2:beforeCalculation budget.My_Spent_Amount__c - ' + budget.My_Spent_Amount__c+ ' pbudget.My_Spent_Amount__c - ' + pbudget.My_Spent_Amount__c);
						
						if (totalAvailableBudgetAtParent == 0) {
							//if zero totalAvailable need to handle it by splitting equally
							decimal cascadeAmt = budget.My_Spent_Overage__c/budgetsFromParentBrand.size();
							pbudget.My_Spent_Amount__c = pbudget.My_Spent_Amount__c+cascadeAmt;
							budget.My_Spent_Amount__c = budget.My_Spent_Amount__c-cascadeAmt;
							System.debug('2:Calculation totalAvailableBudgetAtParent == 0 ');
						}
						else {
							if(pbudget.Remaining_Amount__c - pbudget.My_Spent_Overage__c > 0) { // will skip deducting from parent where there is no Remaining_Amount__c left
								Decimal percentOfBudget = (pbudget.Remaining_Amount__c- pbudget.My_Spent_Overage__c)/totalAvailableBudgetAtParent;
								decimal cascadeAmt = percentOfBudget*budget.My_Spent_Overage__c;
								pbudget.My_Spent_Amount__c = pbudget.My_Spent_Amount__c+cascadeAmt;
								budget.My_Spent_Amount__c = budget.My_Spent_Amount__c-cascadeAmt;
								System.debug('2:Calculation pbudget.Remaining_Amount__c > 0 ');
							}
						}
						
						System.debug('2:afterCalculation budget.My_Spent_Amount__c - ' + budget.My_Spent_Amount__c+ ' pbudget.My_Spent_Amount__c - ' + pbudget.My_Spent_Amount__c);
						
					}					
				}
			}			
			
			update budgets;
			
		}			
	}
	POS_MagentoCartRESTResource.deleteCartItem = false ;// Code optimization done by Jai Gupta [Appirio Jaipur] on June 26,13 for case 00048953
}