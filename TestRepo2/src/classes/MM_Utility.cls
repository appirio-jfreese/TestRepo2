public class MM_Utility extends MM_RecipeBase {
	
	/*
	 * @param Id The recipe__c.Id record being cloned
	 * @return Id of the new cloned recipe
	 */
	public static Id cloneRecipeInformation(Id clonedRecipeId) {
      
      System.Savepoint sp = Database.setSavepoint();
      
      try{

         
         Recipe__c oldRecipe = [SELECT Comments__c, lastModifiedTime__c, CreatedById, CreatedDate, IsDeleted,LastActivityDate, LastModifiedById, 
										LastModifiedDate, Main_Drink_Image__r.Content_id__c, Main_Drink_Image__c, Main_Drink_Image__r.Name,
										Master_Recipe__r.Name, Master_Recipe__r.Id, Menu_Description__c, Mobile_Drink_Image__r.Content_Id__c, Occasion__c, Occasion_Type__c, Preparation_Steps__c, 
										 Recipe_Flavor_del__c, Recipe_Tag__c, Name, Recipe_Type_del__c,Mobile_Selected_Image__c,Mobile_Selected_Image__r.Content_Id__c,
										Mobile_Unselected_Image__c,Mobile_Unselected_Image__r.Content_Id__c,Background_Image__c,Background_Image__r.Content_Id__c,
										Brand_Recipe_Image__c,Brand_Recipe_Image__r.Content_Id__c,Search_Recipe_Image__c,Search_Recipe_Image__r.Content_Id__c,
										Recipe_Version__c, Id,Recipe_Title__c,RecordSaved__c, Short_Description__c, Status__c, SystemModstamp, 
										Has_Legal_Approval__c, Additional_Image_1__r.Content_Id__c, Additional_Image_2__r.Content_Id__c, 
	                                    Current_Editor__c,reviewedBy__c,approvedBy__c, Additional_Image_5__r.Content_Id__c, (select Id,Name from Attachments)
								   ,(select id,Recipe__c,Attribute__c,Attribute__r.Attribute_Type__c,Attribute__r.Attribute_Value__c,Attribute__r.Attribute_Value_Image__c from Recipe_Attributes__r) 
								   ,(select id,Recipe__c,Occasion__c,Occasion__r.Occasion_Type__c,Occasion__r.Name_Of_The_Occasion__c,Occasion__r.Recipe_Occasion_Image__c from Recipe_Occasions__r)
                           FROM Recipe__c
                          WHERE Id = :clonedRecipeId
                          AND recordSaved__c = true];
            system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@25OldRecipe@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+oldRecipe);
            list<Master_Recipe__c> mastRec = [select id,Name from Master_Recipe__c where Name =:oldRecipe.Recipe_Title__c];
             Master_Recipe__c m1 = new Master_Recipe__c();
             
            system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@MasterRecipe@@@@@@@@@@@@@@@@@@@@@@@'+mastRec);
            
    //cloning Recipe involves Recipe_Brand, Recipe_Attributes
   		system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Old Recipe@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+oldRecipe);
         Recipe__c newRecipe = new Recipe__c();
         // newRecipe.Language__c = oldRecipe.Language__c;
         //newRecipe.Recipe_Color_del__c=oldRecipe.Recipe_Color_del__c;
         //newRecipe.Recipe_Flavor_del__c=oldRecipe.Recipe_Flavor_del__c;
         //newRecipe.Occasion__c=oldRecipe.Occasion__c;
         // newRecipe.Occasion_Type__c=oldRecipe.Occasion_Type__c;
         //newRecipe.Recipe_Type_del__c=oldRecipe.Recipe_Type_del__c;
         newRecipe.Recipe_Tag__c=oldRecipe.Recipe_Tag__c;
         //oldRecipe.Master_Recipe__c
        if(mastRec.isEmpty()){
            	m1.Name = oldRecipe.Recipe_Title__c; 
            	insert m1;
            	newRecipe.Master_Recipe__c = m1.Id;
         }
         else{
           		newRecipe.Master_Recipe__c = mastRec[0].Id; 	
         }
         
         newRecipe.Recipe_Title__c = 'temp recipe'+system.Now();
         newRecipe.Status__c = 'Draft';
         newRecipe.current_Editor__c = UserInfo.getUserId();
         
         
         newRecipe.Comments__c = System.now().format('MM/dd/yy h:mm a') + ' - ' + UserInfo.getName() + ' <b>Cloned</b> this recipe from ' + oldRecipe.Recipe_Title__c + '<br/>&nbsp;&nbsp;&nbsp;&nbsp;';
         insert newRecipe;
         
         list<Recipe_Attribute__c> recAttrList = new list<Recipe_Attribute__c>();
         list<Recipe_Occasion__c> recOccList = new list<Recipe_Occasion__c>();
         
         for(Recipe_Attribute__c att : oldRecipe.Recipe_Attributes__r){
         	Recipe_Attribute__c ra = new Recipe_Attribute__c();
         	ra.Recipe__c = newRecipe.Id;
         	ra.Attribute__c = att.Attribute__c;
         	recAttrList.add(ra);
         }
         
         for(Recipe_Occasion__c occ : oldRecipe.Recipe_Occasions__r){
         	Recipe_Occasion__c ro = new Recipe_Occasion__c();
         	ro.Recipe__c = newRecipe.Id;
         	ro.Occasion__c = occ.Occasion__c;
         	recOccList.add(ro);
         }
         
         if(recOccList.size()>0)
         	insert recOccList;
         if(recAttrList.size()>0)
         	insert recAttrList;
         List<Preparation_Step__c> oldPrepSteps = [ select Description__c, Step_Number__c from Preparation_Step__c where Recipe__c =: clonedRecipeId];
         List<Preparation_Step__c> newPrepSteps = new List<Preparation_Step__c>();
         for(Preparation_Step__c pc:oldPrepSteps)
         {
            newPrepSteps.add(new Preparation_Step__c(Description__c = pc.Description__c, Step_Number__c = pc.Step_Number__c, Recipe__c = newRecipe.Id));
         }
         insert newPrepSteps;
        /* List<Recipe_Brand__c> oldRecipeBrands = [Select SystemModstamp, Recipe_Id__c, Name, LastModifiedDate, LastModifiedById, 
                                             IsDeleted, Id, Diageo_Brand_Id__c, CreatedDate, CreatedById 
                                          From Recipe_Brand__c 
                                         Where Recipe_Id__c = :clonedRecipeId]; 

         System.debug('oldRecipeBrands: ' + oldRecipeBrands);*/

         //Clone Recipe_Brand records                               
            
         list<Diageo_Ingredient__c> oldDiageoIngredients = [Select Units__c,Ingredient_Unit__c,Non_Diageo_Product_Units__c,Featured_Brand__c, 
                                                           Recipe_Diageo_Product__c,Recipe_Non_Diageo_Product__c,Quantity__c,Ingredient_Number__c,Recipe_Brand__c
                                                       From Diageo_Ingredient__c
                                                      Where Recipe__c = :clonedRecipeId]; 
         system.debug('@@@@@@@@@@@@@@@@@@@@@@103 Old Ingredients@@@@@@@@@@@@@@@@@@@@@@@'+oldDiageoIngredients);
         List<Diageo_Ingredient__c> newDiageoIngredients = new List<Diageo_Ingredient__c>();
         List<Diageo_Ingredient__c> newNDiageoIngredients = new List<Diageo_Ingredient__c>();
         for(Diageo_Ingredient__c di: oldDiageoIngredients){
         system.debug('=====di.Recipe_Brand__c=='+di.Recipe_Brand__c);
         system.debug('=====di.Recipe_Diageo_Product__c=='+di.Recipe_Diageo_Product__c);
          if(di.Recipe_Brand__c != null && di.Recipe_Diageo_Product__c != null)
          //if(di.Recipe_Diageo_Product__c != null)
             	newDiageoIngredients.add(new Diageo_Ingredient__c(Recipe__c = newRecipe.Id,Recipe_Brand__c=di.Recipe_Brand__c,Ingredient_Number__c=di.Ingredient_Number__c,Featured_Brand__c = di.Featured_Brand__c, Units__c = di.Units__c, Recipe_Diageo_Product__c = di.Recipe_Diageo_Product__c, Quantity__c = di.Quantity__c));
            else if(di.Recipe_Non_Diageo_Product__c != null)
            	newDiageoIngredients.add(new Diageo_Ingredient__c(Recipe__c = newRecipe.Id,Ingredient_Number__c=di.Ingredient_Number__c,Non_Diageo_Product_Units__c = di.Non_Diageo_Product_Units__c, Recipe_Non_Diageo_Product__c = di.Recipe_Non_Diageo_Product__c,Quantity__c = di.Quantity__c));
         }
         
         insert newDiageoIngredients;                       
        // insert newNDiageoIngredients;                                          
       
         return newRecipe.Id; 
      }
      catch (DMLException e){
         //Rollback all transactions if any of them fail
         Database.rollback(sp);
         return null;
      }
   
   }
   
   public static void deleteRecordNotSaved(){
      List<Recipe__c> r = [ select Id from Recipe__c where recordSaved__c = false ];
      try{
         delete r;
      }
      catch(DMLException e)
      {
         System.debug(e);
      }
   }
   
   public static String listToString(list<string> theList, String separator) {
   		system.debug('@@@@@@@@@@@@@@@@@@@Came to Util Class@@@@@@@@@@@@@@'+theList);
      String result = !theList.isEmpty() ? String.valueOf(theList[0]) : '';
      for (Integer i = 1; i < theList.size(); ++i) {
         result += separator + String.valueOf(theList[i]);
      }
      return result;
   }
   
	
	/*
	 * @param String - The salesforce Id of the Recipe__c record
	 * @return List<ProcessInstanceWorkitem> - A list of Approval items for a particular Recipe__c record
	 */	
	public static List<ProcessInstanceWorkitem> getProcessWorkItemsByRecipe(String recipeId){

		List<ProcessInstance> processInstances = new List<ProcessInstance>();
		List<ProcessInstanceWorkitem> processWorkItems = new List<ProcessInstanceWorkitem>();
		List<Id> pis = new List<Id>();

		try{
			
			processInstances = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :recipeId];

			
			if (!processInstances.isEmpty() && processInstances.size() > 0){
				
				for (ProcessInstance pi: processInstances) {
					
					pis.add(pi.Id);
					
				}
				
				processWorkItems = [SELECT ActorId, CreatedById, CreatedDate, IsDeleted, OriginalActorId, ProcessInstanceId, Id FROM ProcessInstanceWorkitem where ProcessInstanceId in : pis];
						
			}
		}
		catch (DMLException e){
			
		}
		
		return processWorkItems;	
		
	}
	
	/*
	 * @param Id - The salesforce Id of the Reviewer/Approver
	 * @return List<Id> - A list of Recipe__c Ids which are pending approval by Reviewer/Approver
	 */
	public static List<Id> getRecipesByApprover(Id userId){

		system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@145UserId@@@@@@@@@@@@@@@@@@@@@@@@@@'+userId);
		List<Id> recipeList = new List<Id>();
		List<ProcessInstance> processInstances = new List<ProcessInstance>();
		List<ProcessInstanceWorkitem> processWorkItems = new List<ProcessInstanceWorkitem>();
		List<Id> pis = new List<Id>();

		try{
			
			processWorkItems = [SELECT ActorId, OriginalActorId, ProcessInstanceId, Id FROM ProcessInstanceWorkitem where ActorId =: userId];
			
			system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@155ProcessWorkItems@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+processWorkItems);

			if (!processWorkItems.isEmpty() && processWorkItems.size() > 0){
				for (ProcessInstanceWorkitem pwi: processWorkItems) {
					pis.add(pwi.ProcessInstanceId);
				}
			}
			
			if (!pis.isEmpty() && pis.size() > 0){
				processInstances = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE Id in :pis];
				
				for (ProcessInstance pi : processInstances){
					recipeList.add(pi.TargetObjectId);
				}
			}
			
		}
		catch (DMLException e){
			
		}
		
		return recipeList;	
		
	}
	
	/*
	 * @param Id - The salesforce Id of the Reviewer/Approver
	 * @return List<Id> - A list of Recipe__c Ids which are rejected by the Reviewer/Approver
	 */
	public static List<Id> getCurrentRejectedRecipesByUser(Id userId, String status){

		List<Id> recipeList = new List<Id>();
		List<ProcessInstance> processInstances = new List<ProcessInstance>();
		List<ProcessInstanceStep> processWorkItems = new List<ProcessInstanceStep>();
		List<Id> pis = new List<Id>();

		try{
			
			processWorkItems = [SELECT ProcessInstanceId, Id FROM ProcessInstanceStep where ActorId =: userId AND StepStatus = :status];
            system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@192ActorId@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+processWorkItems);
			if (!processWorkItems.isEmpty() && processWorkItems.size() > 0){
				for (ProcessInstanceStep pwi: processWorkItems) {
					pis.add(pwi.ProcessInstanceId);
				}
			}
			
			if (!pis.isEmpty() && pis.size() > 0){
				processInstances = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE Id in :pis];
				
				for (ProcessInstance pi : processInstances){
					recipeList.add(pi.TargetObjectId);
				}
			}
			
		}
		catch (DMLException e){
			
		}
		
		return recipeList;	
		
	}
	
	
	/*
	 * @param Id - The salesforce Id of the Reviewer/Approver
	 * @return List<Id> - A list of Recipe__c Ids which are rejected by the Reviewer/Approver
	 */
	public static List<Id> getCurrentRecipesApprovedByUser(Id userId, String status){

		List<Id> recipeList = new List<Id>();
		List<ProcessInstance> processInstances = new List<ProcessInstance>();
		List<ProcessInstanceStep> processWorkItems = new List<ProcessInstanceStep>();
		List<Id> pis = new List<Id>();

		try{
			
			processWorkItems = [SELECT ProcessInstanceId, Id FROM ProcessInstanceStep where ActorId =: userId AND StepStatus = :status];
            system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@233ActorId@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+processWorkItems);
			if (!processWorkItems.isEmpty() && processWorkItems.size() > 0){
				for (ProcessInstanceStep pwi: processWorkItems) {
					pis.add(pwi.ProcessInstanceId);
				}
			}
			
			if (!pis.isEmpty() && pis.size() > 0){
				processInstances = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE Id in :pis];
				
				for (ProcessInstance pi : processInstances){
					recipeList.add(pi.TargetObjectId);
				}
			}
			
		}
		catch (DMLException e){
			
		}
		
		return recipeList;	
		
	}
	
	/*
	 * @param rec - The Recipe__c record to be deleted
	 * @return Boolean - success or failure of the delete
	 */	
	public static Boolean deleteRecipe(Recipe__c rec){
		
		Boolean success;
		
		try {
			delete rec;
			success = true;
		}
		catch (DMLException e){
			success = false;
		}
		
		return success;

	}	

	/*
	 * @param rec - The Recipe__c record to be archived
	 * @return Boolean - success or failure of the archive
	 */	
	public static Boolean archiveRecipe(Recipe__c rec){
		
		Boolean success;
		
		try {
			rec.Status__c = 'Archive';
			update rec;
			success = true;
		}
		catch (DMLException e){
			success = false;
		}
		
		return success;

	}
	
	public class IngredientsWrapper_New{
		List<Custom_Ingredient__c> cIngredients = new List<Custom_Ingredient__c>();
		List<Non_Diageo_Ingredient__c> ndIngredients = new List<Non_Diageo_Ingredient__c>();
		public IngredientsWrapper_New(Id recipeId){
			this.cIngredients = [ Select Units__c, Modifier__c, Ingredient__c, Quantity__c from Custom_Ingredient__c where Recipe__c =: recipeId ];
         this.ndIngredients = [ Select Units__c, Recipe_Modifiers__c, Recipe_Non_Diageo_Product__c, Quantity__c from Non_Diageo_Ingredient__c where Recipe__c =: recipeId ];		
		}
	}
	
	
	public static Boolean isEmptyPickListValue(String s){
		String tmp;
		Boolean rVal;
		if (s != null){
			tmp = s.replaceAll('\\[', '').replaceAll('\\]','');
	    	tmp = tmp.trim();
	    	if (tmp.length() > 0)
	    		rVal = false;
	    	else
	    		rVal = true;
		}
		else
			rVal = false;
			
		return rVal;

	}
/*	
	public PageReference submitRecipe() {

		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Submit Recipe:'+ currentRecipe.Name);
		
		req1.setNextApproverIds(new Id[]{selectedReviewer});
		req1.setObjectId(currentRecipe.Id);   
		Approval.ProcessResult result = Approval.process(req1);
		
		PageReference pageRef = ApexPages.currentPage();
		pageRef.setRedirect(true);
		return pageRef;			
		
	}
	
	public PageReference reassignRecipe() {
		
	
		Boolean success = false;
		List<ProcessInstance> processInstances = new List<ProcessInstance>();
		List<ProcessInstanceWorkitem> processWorkItems = new List<ProcessInstanceWorkitem>();
		List<Id> pis = new List<Id>();
		
		try{
			//Locate the current Approval by current Recipe Id
			processInstances = [SELECT Id
								  FROM ProcessInstance 
								 WHERE TargetObjectId = :currentRecipe.Id];
	
			if (!processInstances.isEmpty() && processInstances.size() > 0){
				for (ProcessInstance pi: processInstances) {
					pis.add(pi.Id);
				}
			}		
			
			//Get the Work Items related to the current Approval
			processWorkItems = [SELECT ActorId, CreatedById, CreatedDate, IsDeleted, OriginalActorId, ProcessInstanceId, Id FROM ProcessInstanceWorkitem where ProcessInstanceId in : pis];
			
			//Change the Approver by updating the Approver
			if (!processWorkItems.isEmpty() && processWorkItems.size() > 0){
				ProcessInstanceWorkitem p = processWorkItems[0];
				p.ActorId = selectedReviewer;
				update p;
			}
		
		}
		catch (Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Reassigning Approval'));
		}
		
		return null;
		
	}
*/	
	public static Boolean processApproval(String status, Id recipeId, Id approverId){

		Boolean success = false;
		List<ProcessInstanceWorkitem> processWorkItems = new List<ProcessInstanceWorkitem>();
		
		try{
		
			processWorkItems = MM_Utility.getProcessWorkItemsByRecipe(recipeId);
			
			if (!processWorkItems.isEmpty() && processWorkItems.size() > 0){
				
				Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
				//Valid status: Approve, Reject
	    		req2.setAction(status);
	    		req2.setNextApproverIds(new Id[] {approverId});
	    
	    		// Use the ID from the newly created item to specify the item to be worked 
	    		req2.setWorkitemId(processWorkItems[0].Id);
	    		
	    		// Submit the request for approval 
	    		Approval.ProcessResult result2 =  Approval.process(req2);
	    		
	    		success = result2.isSuccess();
    		
			}
				
		}  catch (Exception e) {
			System.debug('e: ' + e);
		}	
		
		return success;	
		
		
	}				
	

}