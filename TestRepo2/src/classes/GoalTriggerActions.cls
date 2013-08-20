public without sharing class GoalTriggerActions {
	
	public static Boolean shouldCreateBlanksOrFilled = true;

    public static void createBlankGBRIs(List<Goal__c> goals){
        List<Goal_Brand_Report_Item__c> gbris = new List<Goal_Brand_Report_Item__c>();
        for(Goal__c goal : goals){
            Goal_Brand_Report_Item__c gbri = new Goal_Brand_Report_Item__c();
            gbri.Goal__c = goal.Id;
            gbri.Product_Classification__c = '(Undefined)';
            gbris.add(gbri);
            
            gbri = new Goal_Brand_Report_Item__c();
            gbri.Goal__c = goal.Id;
            gbri.Product_Group__c = '(Undefined)';
            gbris.add(gbri);
            
            gbri = new Goal_Brand_Report_Item__c();
            gbri.Goal__c = goal.Id;
            gbri.Generic_Brand__c = '(Undefined)';
            gbris.add(gbri);
            
            gbri = new Goal_Brand_Report_Item__c();
            gbri.Goal__c = goal.Id;
            gbri.Sub_Brand__c = '(Undefined)';
            gbris.add(gbri);
            
            gbri = new Goal_Brand_Report_Item__c();
            gbri.Goal__c = goal.Id;
            gbri.Individual_Brand__c = '(Undefined)';
            gbris.add(gbri);
            
            gbri = new Goal_Brand_Report_Item__c();
            gbri.Goal__c = goal.Id;
            gbri.Size__c = '(Undefined)';
            gbris.add(gbri);
            
            gbri = new Goal_Brand_Report_Item__c();
            gbri.Goal__c = goal.Id;
            gbri.Report_Brand__c = '(Undefined)';
            gbris.add(gbri);
            
            gbri = new Goal_Brand_Report_Item__c();
            gbri.Goal__c = goal.Id;
            gbri.Ind_Brand_Size__c = '(Undefined)';
            gbris.add(gbri);
        }
        
       	insert gbris;
    }
    
    public static void createBlankOrFilledGBRIs(Map<Id, Goal__c> oldMap, List<Goal__c> goals){
        List<Goal__c> createBlankGoals = new List<Goal__c>();
        List<Goal__c> createFilledGoals = new List<Goal__c>();
        for(Goal__c goal : goals){
            if(goal.Product_Link_Count__c == 0 && goal.Goal_Brand_Report_Item_Count__c == 0){
            	createBlankGoals.add(goal);
            } else {
	            Goal__c old = oldMap.get(goal.Id);
	            if(goal.Product_Link_Count__c > 0 && (old.Product_Link_Count__c == 0 || goal.Goal_Brand_Report_Item_Count__c == 0)){
	                createFilledGoals.add(goal);
	            }
            }
        }
        
        if(createBlankGoals.size() > 0){
        	createBlankGBRIs(createBlankGoals);
        }
       	
        if(createFilledGoals.size() > 0){
        	createFilledGBRIs(createFilledGoals);
        }
    }
    
    public static void createFilledGBRIs(List<Goal__c> createFilledGoals){
        List<Goal__c> goals = [
            SELECT Id,
                   (SELECT Id,
                           Product_Classification__c,
                           Product_Group__c,
                           Generic_Brand__c,
                           Sub_Brand__c,
                           Individual_Brand__c,
                           Size__c,
                           Report_Brand__c,
                           Ind_Brand_Size__c
                      FROM Goal_Product_Links__r
                   ),
                   (SELECT Id
                      FROM Goal_Brand_Report_Items__r
                   )
              FROM Goal__c
             WHERE Id IN :createFilledGoals
        ];
        
        List<Goal_Brand_Report_Item__c> gbrisToDelete = new List<Goal_Brand_Report_Item__c>();
        Map<String, Goal_Brand_Report_Item__c> gbrisToInsertByKey = new Map<String, Goal_Brand_Report_Item__c>();
        String key;
        Goal_Brand_Report_Item__c gbri;
        Goal_Brand_Report_Item__c blankGBRI;
        for(Goal__c goal : goals){
        	gbrisToDelete.addAll(goal.Goal_Brand_Report_Items__r);
        	
        	Boolean hasProductClassification = false;
        	Boolean hasProductGroup = false;
        	Boolean hasGenericBrand = false;
        	Boolean hasSubBrand = false;
        	Boolean hasIndividualBrand = false;
        	Boolean hasSize = false;
        	Boolean hasReportBrand = false;
        	Boolean hasIndBrandSize = false;
        	
            for(Goal_Product_Link__c gpl : goal.Goal_Product_Links__r){
            	if(gpl.Product_Classification__c != null){
            		hasProductClassification = true;
                	key = goal.Id + '|Product_Classification__c|' + gpl.Product_Classification__c;
                	gbri = gbrisToInsertByKey.get(key);
                	if(gbri == null){
	                    gbri = new Goal_Brand_Report_Item__c();
	                    gbri.Goal__c = goal.Id;
	                    gbri.Product_Classification__c = gpl.Product_Classification__c;
	                    gbrisToInsertByKey.put(key, gbri);
                	}
            	}
            	
            	if(gpl.Product_Group__c != null){
            		hasProductGroup = true;
                	key = goal.Id + '|Product_Group__c|' + gpl.Product_Group__c;
                	gbri = gbrisToInsertByKey.get(key);
                	if(gbri == null){
	                    gbri = new Goal_Brand_Report_Item__c();
	                    gbri.Goal__c = goal.Id;
	                    gbri.Product_Group__c = gpl.Product_Group__c;
	                    gbrisToInsertByKey.put(key, gbri);
                	}
            	}
            	
            	if(gpl.Generic_Brand__c != null){
            		hasGenericBrand = true;
                	key = goal.Id + '|Generic_Brand__c|' + gpl.Generic_Brand__c;
                	gbri = gbrisToInsertByKey.get(key);
                	if(gbri == null){
	                    gbri = new Goal_Brand_Report_Item__c();
	                    gbri.Goal__c = goal.Id;
	                    gbri.Generic_Brand__c = gpl.Generic_Brand__c;
	                    gbrisToInsertByKey.put(key, gbri);
                	}
            	}
            	
            	if(gpl.Sub_Brand__c != null){
            		hasSubBrand = true;
                	key = goal.Id + '|Sub_Brand__c|' + gpl.Sub_Brand__c;
                	gbri = gbrisToInsertByKey.get(key);
                	if(gbri == null){
	                    gbri = new Goal_Brand_Report_Item__c();
	                    gbri.Goal__c = goal.Id;
	                    gbri.Sub_Brand__c = gpl.Sub_Brand__c;
	                    gbrisToInsertByKey.put(key, gbri);
                	}
            	}
            	
            	if(gpl.Individual_Brand__c != null){
            		hasIndividualBrand = true;
                	key = goal.Id + '|Individual_Brand__c|' + gpl.Individual_Brand__c;
                	gbri = gbrisToInsertByKey.get(key);
                	if(gbri == null){
	                    gbri = new Goal_Brand_Report_Item__c();
	                    gbri.Goal__c = goal.Id;
	                    gbri.Individual_Brand__c = gpl.Individual_Brand__c;
	                    gbrisToInsertByKey.put(key, gbri);
                	}
            	}
            	
            	if(gpl.Size__c != null){
            		hasSize = true;
                	key = goal.Id + '|Size__c|' + gpl.Size__c;
                	gbri = gbrisToInsertByKey.get(key);
                	if(gbri == null){
	                    gbri = new Goal_Brand_Report_Item__c();
	                    gbri.Goal__c = goal.Id;
	                    gbri.Size__c = gpl.Size__c;
	                    gbrisToInsertByKey.put(key, gbri);
                	}
            	}
            	
            	if(gpl.Report_Brand__c != null){
            		hasReportBrand = true;
                	key = goal.Id + '|Report_Brand__c|' + gpl.Report_Brand__c;
                	gbri = gbrisToInsertByKey.get(key);
                	if(gbri == null){
	                    gbri = new Goal_Brand_Report_Item__c();
	                    gbri.Goal__c = goal.Id;
	                    gbri.Report_Brand__c = gpl.Report_Brand__c;
	                    gbrisToInsertByKey.put(key, gbri);
                	}
            	}
            	
            	if(gpl.Ind_Brand_Size__c != null){
            		hasIndBrandSize = true;
                	key = goal.Id + '|Ind_Brand_Size__c|' + gpl.Ind_Brand_Size__c;
                	gbri = gbrisToInsertByKey.get(key);
                	if(gbri == null){
	                    gbri = new Goal_Brand_Report_Item__c();
	                    gbri.Goal__c = goal.Id;
	                    gbri.Ind_Brand_Size__c = gpl.Ind_Brand_Size__c;
	                    gbrisToInsertByKey.put(key, gbri);
                	}
            	}
            }
            
            if(!hasProductClassification){
            	gbri = new Goal_Brand_Report_Item__c();
                gbri.Goal__c = goal.Id;
                gbri.Product_Classification__c = '(Undefined)';
                gbrisToInsertByKey.put(goal.Id + '|Product_Classification__c|(Undefined)', gbri);
            }
            if(!hasProductGroup){
            	gbri = new Goal_Brand_Report_Item__c();
                gbri.Goal__c = goal.Id;
                gbri.Product_Group__c = '(Undefined)';
                gbrisToInsertByKey.put(goal.Id + '|Product_Group__c|(Undefined)', gbri);
            }
            if(!hasGenericBrand){
            	gbri = new Goal_Brand_Report_Item__c();
                gbri.Goal__c = goal.Id;
                gbri.Generic_Brand__c = '(Undefined)';
                gbrisToInsertByKey.put(goal.Id + '|Generic_Brand__c|(Undefined)', gbri);
            }
            if(!hasSubBrand){
            	gbri = new Goal_Brand_Report_Item__c();
                gbri.Goal__c = goal.Id;
                gbri.Sub_Brand__c = '(Undefined)';
                gbrisToInsertByKey.put(goal.Id + '|Sub_Brand__c|(Undefined)', gbri);
            }
            if(!hasIndividualBrand){
            	gbri = new Goal_Brand_Report_Item__c();
                gbri.Goal__c = goal.Id;
                gbri.Individual_Brand__c = '(Undefined)';
                gbrisToInsertByKey.put(goal.Id + '|Individual_Brand__c|(Undefined)', gbri);
            }
            if(!hasSize){
            	gbri = new Goal_Brand_Report_Item__c();
                gbri.Goal__c = goal.Id;
                gbri.Size__c = '(Undefined)';
                gbrisToInsertByKey.put(goal.Id + '|Size__c|(Undefined)', gbri);
            }
            if(!hasReportBrand){
            	gbri = new Goal_Brand_Report_Item__c();
                gbri.Goal__c = goal.Id;
                gbri.Report_Brand__c = '(Undefined)';
                gbrisToInsertByKey.put(goal.Id + '|Report_Brand__c|(Undefined)', gbri);
            }
            if(!hasIndBrandSize){
            	gbri = new Goal_Brand_Report_Item__c();
                gbri.Goal__c = goal.Id;
                gbri.Ind_Brand_Size__c = '(Undefined)';
                gbrisToInsertByKey.put(goal.Id + '|Ind_Brand_Size__c|(Undefined)', gbri);
            }
        }

       insert gbrisToInsertByKey.values(); 
       delete gbrisToDelete;
    }

}