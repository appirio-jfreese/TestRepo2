/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        11/13/2012
 * @description Fires update on Carts which results in Recalulating the budget leaving out Cancelled, Removed, Deleted Item references.
 **/
global class POS_RecalculateCartBudgetTotalsBatch implements Database.Batchable<SObject> {
	global final List<Cart__c> cartsForBudgetRecalculation;

	global POS_RecalculateCartBudgetTotalsBatch(List<Cart__c> cartsForRecalculation) {
		cartsForBudgetRecalculation = cartsForRecalculation;
	}
		
    /**
     * @description Kicks off the batch job with the batch query.
     * @param       Database.BatchableContext bc - the context of the batch.
     * @return      Database.QueryLocator - an object which holds records that will be passed to the execute methods in batch.
     */
    global Iterable<SObject> start(Database.BatchableContext bc) {
        
        System.debug('Batch POS_RecalculateCartBudgetTotalsBatch start');
        return cartsForBudgetRecalculation;
    }
    
    /**
     * @description Executes one batch (suggested to pass 10 records per batch to avoid governor limit issues on DML).
     * @param       Database.BatchableContext bc - the context of the batch.
     * @return      List<SObject> scope - the set of records in this batch.
     */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        System.debug('Batch POS_RecalculateCartBudgetTotalsBatch execute - START');
		List<Cart__c> cartsBatch = (List<Cart__c>) scope;
        update cartsBatch;
    }
    
    /**
     * @description Executes when all records selected by the query have been processed.
     * @param       Database.BatchableContext bc - the context of the batch.
     */
    global void finish(Database.BatchableContext bc) {
  		System.debug('Batch POS_RecalculateCartBudgetTotalsBatch Finished');
    }

}