/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/23/2012
 * @description validate to make sure 'Potfolio' or Generic brand is not marked as primary.
 *				validate one and only one Brand is marked as Primary while associating Brands to Item.
 */
trigger POS_ItemBrand on Item_Brand__c (before insert, before update) {
	Id portfolioBrandId = [Select b.Id From Brand__c b where b.Name = 'Portfolio'][0].id;
	for(Item_Brand__c n : trigger.new) {

		if(n.Brand__c==portfolioBrandId && n.Primary__c==true) {
			n.addError('\'Potfolio\' brand cannot be marked as Primary');
		}
	}
	
	   	   Map<Id,Item_Brand__c> itemIds = new Map<Id, Item_Brand__c>();	
		   for(Item_Brand__c n : trigger.new) {
		   		if(n.Brand__c != portfolioBrandId) { // skip portfolioBrandId
		   			itemIds.put(n.Item__c, n);
		   		}
			}	
		   System.debug('itemIds.size() -' +itemIds.size());
		   //Fetch Item records with related Item Brands, if there are no other brands associated then create error message back to user 
		   List<Item__c> itemsWithItemBrands = [Select i.Id, 
		   			(Select Id, Brand__c, Primary__c From Item_Brands__r where Brand__c != :portfolioBrandId) 
		   				From Item__c i where i.id in :itemIds.keySet() and i.Status__c in ('Approved w/Est Price', 'Accepted w/Final Price')];
						 
			for(Item__c itm: itemsWithItemBrands) {
				Item_Brand__c ib = itemIds.get(itm.id);

				if(!ib.Primary__c) { // assumes only Primary__c is a updatable field on the record
					Boolean primaryExists = false;
					for(Item_Brand__c currentIb:itm.Item_Brands__r) {
						if(currentIb.Primary__c  && currentIb.id != ib.id) {
							primaryExists=true;
							break;
						}
					}
						
					if(!primaryExists) {
						ib.addError('One and only one Brand must be designated as the "Primary" for an Item.');
					}						
				} else { 
					Boolean primaryExists = false;
					System.debug('primaryExists 1 -' +primaryExists);
					
					for(Item_Brand__c currentIb:itm.Item_Brands__r) {
						System.debug('primaryExists 2 -' +primaryExists);
						if(currentIb.Primary__c && currentIb.id != ib.id) {
							primaryExists=true;
							System.debug('primaryExists 3 -' +primaryExists);
							break;
						}
					}
						
					if(primaryExists) {
						ib.addError('One and only one Brand must be designated as the "Primary" for an Item.');
					}
				}
			}
}