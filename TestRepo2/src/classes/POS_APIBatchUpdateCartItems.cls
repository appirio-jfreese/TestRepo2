@RestResource(urlMapping='/BatchUpdateCartItems/')
global with sharing class POS_APIBatchUpdateCartItems {
   
   @HttpPost
    global static boolean doPost (boolean isFull, List<String> orderWindowId) {
      RestRequest req = RestContext.request; 
      RestResponse res = RestContext.response;  
      try{
          POS_BatchUpdateCartItems batch = new POS_BatchUpdateCartItems(isFull, orderWindowId); 
          Database.executebatch(batch);
         }catch(exception e){
             res.StatusCode=500;
             return false;
         }
      return true;
    }
}