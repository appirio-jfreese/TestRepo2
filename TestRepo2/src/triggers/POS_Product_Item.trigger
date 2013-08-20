/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        05/21/2012
 * @description Takes care of synching updates to Magento.
 *              Create/Update Item Brand record based on the Program an Item is associated with.
 
 
     Modified By - Rahul Chitkara(Appirio Offshore)
     Date - 27th Feb 2013
     Related to - To prevent test class failure.
 */
 
trigger POS_Product_Item on Item__c (after delete, after insert, after update) {
    
    
    
    // Changes Done for case 00043945 By Jai Gupta [Appirio Jaipur] on April 23,2013
	// added Current_Price and Name field in the query to avoid SOQL exceptions.
    private static String itemsWithBrands = 'Select i.Id, i.Status__c, i.Program__r.Magento_Id__c, i.Program__r.Order_Window__r.Magento_Id__c, i.Order_Window_Name__c, i.Name, i.Current_Price__c,' +
         'i.Description__c, i.Estimated_Price__c, i.Category__c, i.Minimum_Quantity__c, i.Packout_Quantity__c, i.Item_Category__r.Name, i.Item_Category__r.Friendly_Name__c,' +
         'i.RecordTypeId, i.Estimated_Shipping_Tax__c, i.RecordType.DeveloperName, i.Parent__c, i.Kit_Only__c, i.Magento_Option_Id__c,' +
         '(Select Brand__r.Magento_Id__c, Primary__c From Item_Brands__r), (SELECT Id,Magento_ID__c,Current_Price__c,Name FROM Items__r where Status__c != \'Removed\') From Item__c i where i.id in';
    // End for case 00043945
    Set<Id> itemsImpactingCartPrice = new Set<Id>();    // store Id of Item__c 
    
    if (trigger.isInsert) {
        
           Map<Id, Id> itemProgamIdMap = new Map<Id, Id>(); 
           for(Item__c n : trigger.new) {
                
                itemProgamIdMap.put(n.id, n.program__c); 
                System.debug('n.Name -' +n.Name);
                
            }
            Set<ID> itemIdsForSync = itemProgamIdMap.keySet();
            List<Item__c> itemsForSync = Database.query(itemsWithBrands + ' :itemIdsForSync');
            
            for(Item__c itm: itemsForSync) {
                if(itemsForSync.size() > 2 ) {
                    POS_MagentoProduct.syncMagentoProduct(itm, 'create', false); // donot useFutureCall
                } else {
                    POS_MagentoProduct.syncMagentoProduct(itm, 'create', true); // useFuturecall
                }               

            }   
           
           //Create Item Brand record based on the Program an Item is associated with.
           List<Item_Brand__c> ibCreateList = new List<Item_Brand__c>();
           Map<Id, Program__c> programMap = new Map<Id, Program__c>([Select Id, Brand__c, Brand__r.Portfolio_Brand__c, Brand__r.Brand_Type__c from Program__c where id in :itemProgamIdMap.values()]);
           
           for(Id itmId:itemProgamIdMap.keySet()) {
                System.debug('itmId - ' + itmId + ' itemProgamIdMap.get(itmId) - ' + itemProgamIdMap.get(itmId));
                Program__c prg = programMap.get(itemProgamIdMap.get(itmId));
                System.debug('prg.Brand__c -' + prg.Brand__c + ' prg.Brand__r.Portfolio_Brand__c -' + prg.Brand__r.Portfolio_Brand__c);
                
                Boolean primary = true;
                //If the Program is tied to a Portfolio Brand or Non-Individual Type, Item Brand record is not marked as Primary
                if (prg.Brand__r.Portfolio_Brand__c || prg.Brand__r.Brand_Type__c != 'Individual') { 
                    primary = false;
                }
                System.debug('itmId - ' + itmId + ' prg.Brand__c - ' + prg.Brand__c);
                Item_Brand__c ib = new Item_Brand__c(Brand__c=prg.Brand__c, Item__c=itmId, Primary__c=primary);
                ibCreateList.add(ib);
            }   
            System.debug('ibCreateList.size() -' + ibCreateList.size());
            insert  ibCreateList;           
               
    } else if (trigger.isUpdate) {
        
           Id kitRecTypeId;
           Id rollupRecTypeId;
           Id custRecTypeId;
        
           List<RecordType> recTypes = [select id,DeveloperName from RecordType where DeveloperName in ('Kit','Roll_Up','Customizable')];
           for (RecordType recType:recTypes) {
                if (recType.DeveloperName=='Kit') {
                    kitRecTypeId=recType.Id;
                }
                if (recType.DeveloperName=='Roll_Up') {
                    rollupRecTypeId = recType.Id;
                }
                if (recType.DeveloperName == 'Customizable') {
                    custRecTypeId = recType.Id;
                }
           }
           
           if (Test.isRunningTest()) {
                System.assert(kitRecTypeId!=null);
                System.assert(rollupRecTypeId!=null);
                System.assert(custRecTypeId!=null);
           }
           
           Map<Id, Id> itemProgamIdMap = new Map<Id, Id>(); 
           Map<Id, Item__c> itemsIdsForBrandCheck = new Map<Id, Item__c>();
           Map<Id, Item__c> itemsIdsForKitCheck = new Map<Id, Item__c>();
           Map<Id, Item__c> itemsIdsForRollupCheck = new Map<Id, Item__c>();
           Map<Id, Item__c> itemsIdsForCustomizationCheck = new Map<Id, Item__c>();
           
           List<Id> itemIdsForSync = new List<Id>();
           
           for(Item__c n : trigger.new) {
                // check for magentoId to be present before doing the update, display error back to the user if it doesn't
                /*if (n.Magento_Id__c == null) {  
                    n.addError('Magento Product Id missing for this Item, please make sure the data is synched to Magento successfully before making any updates.');
                    continue;
                }*/
                
                Item__c o = trigger.oldMap.get(n.id);
                //add to the list for updating itembarnds only if the Program field on the Item has changed.
                if (o.Program__c != n.Program__c) {
                    itemProgamIdMap.put(n.id, n.program__c); 
                }
                
                //add to the list of Items to be checked for having atleast 1 brand marked as "primary", Kit to have more than one Kit Item
                if (n.Status__c == 'Approved w/Est Price' || n.Status__c == 'Accepted w/Final Price') {
                    itemsIdsForBrandCheck.put(n.id, n); 
                    
                    if(n.RecordTypeId == kitRecTypeId) {
                        itemsIdsForKitCheck.put(n.id, n);
                    } else if(n.RecordTypeId == rollupRecTypeId) {
                        itemsIdsForRollupCheck.put(n.id, n);
                    } else if(n.RecordTypeId == custRecTypeId) {
                        itemsIdsForCustomizationCheck.put(n.id, n);
                    }
                }
                
                // check if Item status changed To or From Cancelled, Removed OR Price Changed. 
                // If it did it will impact Cart pricing // VK: 11/13/2012
                if( (o.Status__c != n.Status__c 
                     && (o.Status__c == 'Cancelled' || o.Status__c == 'Removed' 
                        || n.Status__c == 'Cancelled' || n.Status__c == 'Removed')) // Status changed
                    || o.Current_Price__c != n.Current_Price__c) {                  // price changed
                        
                        itemsImpactingCartPrice.add(n.id);      
                }       
                
                // add to the list of items to be synced with magento
                
                // commented out the if condition below as to allow update of an Item even before the magentoID is updated on the record
                //if (o.CreatedDate != o.LastModifiedDate && o.Magento_Id__c != null) { // when record created timestamp will be same
                    itemIdsForSync.add(o.id);
                //}
                System.debug('n.CreatedDate -' +n.CreatedDate + ' n.LastModifiedDate -' +n.LastModifiedDate);
            }

            List<Item__c> itemsForSync  = Database.query(itemsWithBrands  + ' :itemIdsForSync');
            List<Id> parentItemIds = new List<Id>();
            for(Item__c itm: itemsForSync) {
                
                System.debug('itemsForSync.size() -' +itemsForSync.size());
                // trigger Update on Parent Item so that Magento is reflecting this as a change to associated Items
                // IMP: Done only when Magento_Option_Id__c is changed on the Rolup Child
                System.debug('trigger.newMap.get(itm.id).Magento_Option_Id__c =' + trigger.newMap.get(itm.id).Magento_Option_Id__c +
                    ' itm.Magento_Option_Id__c =' + itm.Magento_Option_Id__c);
                if(itm.Parent__c != null) {
                    
                    if(trigger.oldMap.get(itm.id).Name != itm.Name) { // Child Item Name change needs to reflected in the rollup selection on magento
                        POS_MagentoProduct.syncMagentoProduct(itm, 'update', false, true);
                    } else {
                        POS_MagentoProduct.syncMagentoProduct(itm, 'update', false); // rollup child always sync through Queue
                    }
                    
                    if(trigger.oldMap.get(itm.id).Magento_Option_Id__c != itm.Magento_Option_Id__c) {
                        parentItemIds.add(itm.Parent__c);
                    }
                }   
                /* Adding Condition Test.isRunningTest() for Case 00003590
                   Modified By - Rahul Chitkara(Appirio Offshore)
                   Date - 27th Feb 2013
                                    
                */
                else if(itemsForSync.size() > 2 || Test.isRunningTest()) {
                    POS_MagentoProduct.syncMagentoProduct(itm, 'update', false); // donot useFutureCall
                } else {
                    POS_MagentoProduct.syncMagentoProduct(itm, 'update', true); // useFuturecall
                }                                       
            }
                        
            if(parentItemIds.size() > 0) {
                List<Item__c> parentItemsForSync  = Database.query(itemsWithBrands  + ' :parentItemIds');
                System.debug('parentItemsForSync.size() -' +parentItemsForSync.size());
                
                for(Item__c pitm: parentItemsForSync) {
                    POS_MagentoProduct.syncMagentoProduct(pitm, 'update', false);  // rollup parent always route through Queue
                }
            }           
                        
            // Update Item Brand record based on the new Program an Item is associated with.    
           /* delete any existing ItemBrand records per requirment - 
            Upon changing Program, existing Item Brand record(s) is/are deleted and follow logic above to set */
           List<Item_Brand__c> ibDeleteList = [Select id from Item_Brand__c where Item__c in :itemProgamIdMap.keySet() ];
           delete ibDeleteList;
           
           List<Item_Brand__c> ibCreateList = new List<Item_Brand__c>();
           Map<Id, Program__c> programMap = new Map<Id, Program__c>([Select Id, Brand__c, Brand__r.Portfolio_Brand__c, Brand__r.Brand_Type__c from Program__c where id in :itemProgamIdMap.values()]);
           
           for(Id itmId:itemProgamIdMap.keySet()) {
                System.debug('itmId - ' + itmId + ' itemProgamIdMap.get(itmId) - ' + itemProgamIdMap.get(itmId));
                Program__c prg = programMap.get(itemProgamIdMap.get(itmId));
                System.debug('prg.Brand__c -' + prg.Brand__c + ' prg.Brand__r.Portfolio_Brand__c -' + prg.Brand__r.Portfolio_Brand__c);
                
                Boolean primary = true;
                //If the Program is tied to a Portfolio Brand or Non-Individual Type, Item Brand record is not marked as Primary
                if (prg.Brand__r.Portfolio_Brand__c || prg.Brand__r.Brand_Type__c != 'Individual') { 
                    primary = false;
                }
                System.debug('itmId - ' + itmId + ' prg.Brand__c - ' + prg.Brand__c);
                Item_Brand__c ib = new Item_Brand__c(Brand__c=prg.Brand__c, Item__c=itmId, Primary__c=primary);
                ibCreateList.add(ib);
            }   
            System.debug('ibCreateList.size() -' + ibCreateList.size());
            insert  ibCreateList;
            
            // check to make sure there is atleast one Brand marked as 'Primary' if the Item is in 'Approved w/Est Price or Accepted w/Final Price' status
            Set<Id> itemIds = itemsIdsForBrandCheck.keySet();
            
            if(itemIds.size() > 0) {
                List<Item__c> itemsForBrandCheck  = Database.query(itemsWithBrands  + ' :itemIds');
                for(Item__c itm: itemsForBrandCheck) {
    
                    Boolean primaryExists = false;
                    for(Item_Brand__c currentIb:itm.Item_Brands__r) {
                        if(currentIb.Primary__c) {
                            primaryExists=true;
                            break;
                        }
                    }
                        
                    if(!primaryExists) {
                        Item__c tItm = itemsIdsForBrandCheck.get(itm.id);
                        tItm.addError('One and only one Brand must be designated as "Primary" for an Item before moving the Item status to Approved or Accepted');
                    }
                }
            }
            
            // check to make sure there is atleast 2 Kit Items in a Kit
            Set<Id> kitIds = itemsIdsForKitCheck.keySet();
            
            if(kitIds.size() > 0) {
                List<Item__c> itemsForKitCheck  = [Select i.Name, i.Id, (Select Item__c From Kit_Items__r) From Item__c i where i.id in:kitIds];
                            
                for(Item__c itm: itemsForKitCheck) {
                        System.debug('----KitItem'+itm.Kit_Items__r);
                        if(itm.Kit_Items__r.size() < 2) {
                            Item__c tItm = itemsIdsForKitCheck.get(itm.id);
                            tItm.addError('Kit must contain at least two different items while in status Approved or Accepted');
                        }                   
                }   
            }
            
            // check to make sure there is atleast 2 Rollup Child Items in a Rollup Parent Item
            Set<Id> rollupIds = itemsIdsForRollupCheck.keySet();
            
            if(rollupIds.size() > 0) {
                List<Item__c> itemsForRollupCheck  = [Select i.Name, i.Id, (Select Id From Items__r) From Item__c i where i.id in:rollupIds];
                            
                for(Item__c itm: itemsForRollupCheck) {

                        if(itm.Items__r.size() < 1) {
                            Item__c tItm = itemsIdsForRollupCheck.get(itm.id);
                            tItm.addError('Roll-Up Item must contain at least one Child items while in status Approved or Accepted');
                        }                   
                }   
            }   
            
            // check to make sure there is atleast 1 Custom Option for a Customizable Item
            Set<Id> custIds = itemsIdsForCustomizationCheck.keySet();
            
            if(custIds.size() > 0) {
                List<Item__c> itemsForCustCheck  = [Select i.Name, i.Id, (Select Id From Item_Customizations__r) From Item__c i where i.id in:custIds];
                            
                for(Item__c itm: itemsForCustCheck) {

                        if(itm.Item_Customizations__r.size() < 1) {
                            Item__c tItm = itemsIdsForCustomizationCheck.get(itm.id);
                            tItm.addError('Customizable Item must contain at least one Customization Option while in status Approved or Accepted');
                        }                   
                }   
            }           
            
                                            
                                    
    } else if (trigger.isDelete) {
                
           List<Id> parentItemIds = new List<Id>();
           for(Item__c o : trigger.old) {
                
                if(trigger.old.size() > 2) {
                    POS_MagentoProduct.deleteMagentoProduct(o.Id, false); // donot useFutureCall
                } else {
                    POS_MagentoProduct.deleteMagentoProduct(o.Id, true); // useFuturecall
                }               
                System.debug('o.Magento_Id__c -' +o.Magento_Id__c);
                
                // trigger Update on Parent Item so that that is Synched to Magento reflecting this as a change to associated Items
                if(o.Parent__c != null) {
                    parentItemIds.add(o.Parent__c);
                }
                
                // Item deletion will impact Cart pricing // VK: 11/13/2012
                itemsImpactingCartPrice.add(o.Id);
                                    
            }   
            
            if(parentItemIds.size() > 0) {
                List<Item__c> parentItemsForSync  = Database.query(itemsWithBrands  + ' :parentItemIds');
                System.debug('Delete parentItemsForSync.size() -' +parentItemsForSync.size());
                
                for(Item__c pitm: parentItemsForSync) {
                    POS_MagentoProduct.syncMagentoProduct(pitm, 'update', false);  // rollup parent always route through Queue
                }
            }       
        
      } 
 
    // Logic to trigger re-calculation of the Cart Pricing based on changes to Item that would impact the same.
    // Note: done as Batch to avoid bumping into Governor limit issues when price/status change on a item associated with multiple Carts is done.
    if (itemsImpactingCartPrice.size() > 0) {
        List<Cart__c> cartsImpacted = [Select Id from Cart__c where Id in (Select Cart__c from Cart_Item__c where Item__c in :itemsImpactingCartPrice )];
        if(cartsImpacted != null && cartsImpacted.size() > 0) {
            // this will trigger update of Carts which in turn will result in re-calulating og the Cart, Budget Spent Amounts
            POS_RecalculateCartBudgetTotalsBatch batch = new POS_RecalculateCartBudgetTotalsBatch(cartsImpacted);
            Database.executeBatch(batch, 10);
        }
    }

}