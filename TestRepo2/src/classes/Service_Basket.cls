public with sharing class Service_Basket {
	
	
    public static void addToBasket(list<ID> contentIds){
		list<Basket__c> newBasketItems = new List<Basket__c>();
		Set<Id> currentContentIds = Service_Basket.getBasketIds();
		
		for(ID contentId : contentIds){
			if(contentId != null && !currentContentIds.contains(contentId)){
				Basket__c item = new Basket__c(Content_Version_Id__c = contentId);
				newBasketItems.add(item);
			}
		}
			
		// add to basket
		if(newBasketItems.size() !=0 ){
			insert newBasketItems;
		}
    }
    
    public static List<Basket__c> getBasketItems(){
		List<Basket__c> basketItems = new List<Basket__c>();
		
		if(Service_API.getUID() != null){
			basketItems = [Select Content_Version_Id__c from Basket__c where OwnerId = :Service_API.getUID()];
		}
		
		return basketItems;
    }
    
    public static Set<Id> getBasketIds(){
		Set<Id> contentIds = new Set<Id>();

		List<Basket__c> basketItems = Service_Basket.getBasketItems();
		
		for(Basket__c item : basketItems){
			if(item.Content_Version_Id__c != null && item.Content_Version_Id__c != ''){
				if(!contentIds.contains(item.Content_Version_Id__c)){
					contentIds.add(item.Content_Version_Id__c);
				}				
			}
		}
		
		return contentIds;
    }
    
    public static Integer getNumberOfItems(){
		Set<Id> contentIds = Service_Basket.getBasketIds();
		return contentIds.size();
    }    
    
    public static void removeFromBasket(list<ID> contentIds){
		Id userId = Service_API.getUID();
		if(userId != null){
			list<Basket__c> toDeleteItems = [select id from Basket__c where Content_Version_Id__c in :contentIds AND OwnerId = :userId];
			delete toDeleteItems;
		}
    }
    
    public static void clearBasket(){
		Id userId = Service_API.getUID();
		if(userId != null){
			list<Basket__c> toDeleteItems = [select id from Basket__c where OwnerId = :userId];
			delete toDeleteItems;
		}
    }
}