public with sharing class Controller_RepDailyActivities {

    public String footerLeftContent								{get;set;}
    
    public List<Id> goalIdsByDueDate							{get;set;}
    public Map<Id, List<Action__c>> actionListsByGoalId			{get;set;}
    public List<GoalWrapper> goalWrapperList					{get;set;}

        
    public class GoalWrapper {
        public Id goalId							{get;set;}
        
    	public List<Action__c> actionList			{get;set;}
    	public String accountString					{get;set;}
    	public Action__c dummyAction				{get;set;}
        
        public boolean showBrandType				{get;set;}
        public boolean showBrandCategory			{get;set;}
        public boolean showTypeOfAd					{get;set;}
        public boolean showSizeOfAd					{get;set;}
        public boolean showSuggestedPrice			{get;set;}
        public boolean showFeatureType				{get;set;}
        public boolean showLocationGrade			{get;set;}
        public boolean showPercentOfUniverse		{get;set;}
        public boolean showFeatures					{get;set;}
        public boolean showCasesDisplayed			{get;set;}
        public boolean showSFAPOS					{get;set;}
        public boolean showProductSamples			{get;set;}
        public boolean showTrainer					{get;set;}
        public boolean showTrainingAudience			{get;set;}
        public boolean showLengthOfTraining			{get;set;}
    }
    
    public Controller_RepDailyActivities(){
        init();
    }
   
    public void init(){
    	footerLeftContent = System.Label.Rep_Footer_Comment_Instructions + ' ' + System.Label.Rep_Footer_Legal_Disclaimer;
    	
        Map<id,goal__c> goalMap = new Map<id,goal__c>();    
        goalWrapperList = new List<GoalWrapper>();
        List<Action__c> actionList =
        	[SELECT Account__c,
        			Account__r.Name,
        			Goal__c,
        			Goal__r.Program__r.Name,
        			Goal__r.Sales_Channel__c, 
        			Goal__r.Account_Grade__c, 
        			Goal__r.Due_Date__c, 
        			Goal__r.SFA_POS_Items__c, 
        			Goal__r.Location_Grade__c,
        			Goal__r.Cases_Displayed__c, 
        			Goal__r.Minimum_of_Accounts__c, 
        			Goal__r.RecordTypeId,
        			Goal__r.recordType.name,
        			Goal__r.Type_of_Ad__c,
        			Goal__r.Size_of_Ad__c,
        			Goal__r.Brand_Type__r.Name,
        			Goal__r.Feature_Type__c,  
        			Goal__r.Suggested_Price__c,  
        			Goal__r.Features_Displayed__c,  
        			Goal__r.Percent_of_Universe__c,
        			Goal__r.Brand_Category__c,
        			Goal__r.Brand_Category__r.Category__c,
        			Goal__r.Accomplishment_Recap__c,
        			Goal__r.Length_of_Training__c,
        			Goal__r.Trainer__c,
        			Goal__r.Training_Audience__c,
        			Goal__r.Product_Sample_s__c
        	FROM Action__c
        	WHERE Goal__c != null
        	  AND Account__c != null
        	  AND Due_Date__c != null
        	  AND OwnerId = :UserInfo.getUserid()
        	ORDER BY Goal__r.Due_Date__c, 
        			 Goal__r.Program__r.Name,
        			 Account__r.Name
        	];
        
        if(actionList.size() > 0){
        	actionListsByGoalId = new Map<Id, List<Action__c>>();
        	goalIdsByDueDate = new List<Id>();
            
            for(Action__c act: ActionList){
            	if(actionListsByGoalId.get(act.Goal__c) == null){
                	actionListsByGoalId.put(act.Goal__c, new List<Action__c>());
                	goalIdsByDueDate.add(act.Goal__c);
                }
                
                actionListsByGoalId.get(act.Goal__c).add(act);
                
               	goalMap.put(act.goal__c,act.goal__r);
            }
            
            goalWrapperList = new List<GoalWrapper>();
            for(Id goalId : goalIdsByDueDate){
            	GoalWrapper gw = new GoalWrapper();
            	
            	gw.goalId = goalId;
            	gw.actionList = actionListsByGoalId.get(goalId);
            	gw.accountString = '';
            	for(Action__c act : actionListsByGoalId.get(goalId)){
            		gw.accountString += act.Account__r.Name + ', ';
            	}
            	gw.accountString = gw.accountString.subString(0, gw.accountString.length() - 2);
    			gw.dummyAction = gw.actionList[0];
    			
    			String recType = gw.dummyAction.Goal__r.RecordType.Name;
    			
        		gw.showBrandType			= false;
        		gw.showBrandCategory		= false;
        		gw.showTypeOfAd				= false;
        		gw.showSizeOfAd				= false;
        		gw.showSuggestedPrice		= false;
        		gw.showFeatureType			= false;
        		gw.showLocationGrade		= false;
        		gw.showPercentOfUniverse	= false;
        		gw.showFeatures				= false;
        		gw.showCasesDisplayed		= false;
        		gw.showSFAPOS				= false;
        		gw.showProductSamples		= false;
        		gw.showTrainer				= false;
        		gw.showTrainingAudience		= false;
        		gw.showLengthOfTraining		= false;
    			
    			if(recType == 'Display Goals'){
	        		gw.showLocationGrade		= true;
	        		gw.showPercentOfUniverse	= true;
	        		gw.showFeatures				= true;
	        		gw.showCasesDisplayed		= true;
	        		gw.showSFAPOS				= true;
    			} else if(recType == 'Distribution (Accts Sold) Goals'){
	        		gw.showLocationGrade		= true;
	        		gw.showPercentOfUniverse	= true;
	        		gw.showSuggestedPrice		= true;
    			} else if(recType == 'Distribution (POD) Goals'){
	        		gw.showLocationGrade		= true;
	        		gw.showPercentOfUniverse	= true;
	        		gw.showSuggestedPrice		= true;
    			} else if(recType == 'General Goals'){
        			gw.showBrandType			= true;
    			} else if(recType == 'Ad Execution'){
	        		gw.showBrandType			= true;
	        		gw.showTypeOfAd				= true;
	        		gw.showSizeOfAd				= true;
	        		gw.showSuggestedPrice		= true;
	        		gw.showFeatureType			= true;
    			} else if(recType == 'Feature Goals'){
        			gw.showBrandType			= true;
        			gw.showSuggestedPrice		= true;
        			gw.showFeatureType			= true;
        			gw.showSFAPOS				= true;
    			} else if(recType == 'Menu Goals'){
    				gw.showSuggestedPrice		= true;
        			gw.showFeatureType			= true;
        			gw.showSFAPOS				= true;
    			} else if(recType == 'Shelf Set Goals'){
    				gw.showBrandType			= true;
        			gw.showBrandCategory		= true;
        			gw.showSuggestedPrice		= true;
        			gw.showSFAPOS				= true;
    			} else if(recType == 'Staff Training Goals'){
    				gw.showBrandType			= true;
    				gw.showSuggestedPrice		= true;
    				gw.showProductSamples		= true;
	        		gw.showTrainer				= true;
	        		gw.showTrainingAudience		= true;
	        		gw.showLengthOfTraining		= true;
	        		gw.showSFAPOS				= true;
    			} else if(recType == 'Window Display Goals'){
    				gw.showBrandType			= true;
    				gw.showSFAPOS				= true;
    			}
            	
            	goalWrapperList.add(gw);
            }
            
            
            
            
            /*
            for(Id goalId : goalMapAction.keySet()){
            	GoalWrapper wrapperRecord=new GoalWrapper();
                wrapperRecord.goalRecord=goalMap.get(goalId);
                wrapperRecord.actionRecordList=goalMapAction.get(goalId);
                wrapperRecord.sizeofActionRecord=goalMapAction.get(goalId).size();
                                
                if(goalMap.get(goalId).recordtype.name=='Display Goals'){
                        wrapperRecord.showBrandBottle=true;
                        wrapperRecord.showCasesDisplayed=true;
                        wrapperRecord.showFeatureType=true;
                        wrapperRecord.showLocationGrade=true;
                        wrapperRecord.showSFAPost=true;
                        
                } else if(goalMap.get(goalId).recordtype.name=='Distribution Goals'){
                        wrapperRecord.showBrandBottle=true;
                        wrapperRecord.showSuggestedDisplay=true;  
                                
                } else if(goalMap.get(goalId).recordtype.name=='General Goals'){
                        
                } else if(goalMap.get(goalId).recordtype.name=='Ad Execution'){
                        wrapperRecord.showBrandBottle=true;
                        wrapperRecord.showSFAPost=true;
                        wrapperRecord.showFeatureType=true;
                        wrapperRecord.showSizeOfAd=true;
                        wrapperRecord.showTypeOfAd=true;
                        
                } else if(goalMap.get(goalId).recordtype.name=='Ease of Shop'){
                        wrapperRecord.showAccomplishmentRecap=true;
                        
                } else if(goalMap.get(goalId).recordtype.name=='Feature Goals'){
                        wrapperRecord.showSFAPost=true;
                        wrapperRecord.showBrandBottle=true;
                        wrapperRecord.showFeatureType=true;
                        
                } else if(goalMap.get(goalId).recordtype.name=='Menu Goals'){
                        wrapperRecord.showSFAPost=true;
                        wrapperRecord.showFeatureType=true;
                        wrapperRecord.showBrandBottle=true;
                        
                } else if(goalMap.get(goalId).recordtype.name=='Shelf Set Goals'){
                        wrapperRecord.showSFAPost=true;
                        wrapperRecord.showBrandBottle=true;
                        wrapperRecord.showBrandBottleCategory=true;
                                                                                        
                } else if(goalMap.get(goalId).recordtype.name=='Staff Training Goals'){
                        wrapperRecord.showSFAPost=true;
                        wrapperRecord.showBrandBottle=true;
                        
                } else if(goalMap.get(goalId).recordtype.name=='Window Display Goals'){
                        wrapperRecord.showSFAPost=true;
                        wrapperRecord.showBrandBottle=true;   
                }                       
                            
        		goalWrapperList.add(wrapperRecord);                  
        	}     */
        }
    }

}