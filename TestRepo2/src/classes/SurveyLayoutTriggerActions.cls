public with sharing class SurveyLayoutTriggerActions 
{
    public static boolean batchJobSubmitted = false;
    
    public static void removeSurveyRecordsOnLayoutDelete(Map<Id,Survey_Layout__c> oldItems)
    {
        List<Survey__c> surveys = [select id from Survey__c where Survey_Layout__c in :oldItems.keySet() or Survey_Layout__c = null] ;
        List<SurveyLayout_Brand_Items__c> layoutItems = [select id from SurveyLayout_Brand_Items__c where Survey_Layout__c in :oldItems.keySet() or Survey_Layout__c = null] ;
        List<Survey_Layout_Brand_Bottle_Item__c> layoutBottles = [select id from Survey_Layout_Brand_Bottle_Item__c where Survey_Layout__c in :oldItems.keySet() or Survey_Layout__c = null] ;
        
        if(surveys != null && !surveys.isEmpty()) {
            database.delete(surveys) ;
        }
        
        if(layoutItems != null && !layoutItems.isEmpty()) {
            database.delete(layoutItems) ;
        }
        
        if(layoutBottles != null && !layoutBottles.isEmpty()) {
            database.delete(layoutBottles) ;
        }
    }
    
    
    public static void cloneSurveyLayoutRecordsIfApplicable(Map<Id,Survey_Layout__c> surveyLayoutMap)
    {
        Survey_Layout__c layoutRecordToClone ;
        
        for(Survey_Layout__c layoutItem : surveyLayoutMap.values())
        {
            system.debug('=======layoutItem.Clone_Survey_Layout__c========'+layoutItem.Clone_Survey_Layout__c);
            if(layoutItem.Clone_Survey_Layout__c == true) {
                layoutItem.Clone_Survey_Layout__c = false;
                //can only do one at a time.
                layoutRecordToClone = layoutItem ;
            }
        }
        system.debug('=======layoutRecordToClone ========'+layoutRecordToClone );
        if(layoutRecordToClone != null)
        {
            Survey_Layout__c newLayoutRecord = buildNewSurveyLayout(layoutRecordToClone) ;
            
            
            SurveyLayout_Brand_Items__c[] brandItems = [select Display_Checkbox_Not_Applicable__c, Brand__c, Brand__r.Name 
                                                        from SurveyLayout_Brand_Items__c 
                                                        where survey_layout__c = :layoutRecordToClone.Id
                                                        order by createddate] ;
            Survey_Layout_Brand_Bottle_Item__c[] brandBottleItems = [select BrandBottle_Size__c, BrandBottle_Size__r.Name
                                                                        from Survey_Layout_Brand_Bottle_Item__c 
                                                                        where survey_layout__c = :layoutRecordToClone.Id
                                                                        order by createddate] ;
            
            
            
            insert newLayoutRecord ;
            
            SurveyLayout_Brand_Items__c[] brandItemsToInsert = new SurveyLayout_Brand_Items__c[]{};
            Survey_Layout_Brand_Bottle_Item__c[] bottleItemsToInsert = new Survey_Layout_Brand_Bottle_Item__c[]{};
            if(brandItems != null) {
                for(SurveyLayout_Brand_Items__c brandItem : brandItems) {
                    SurveyLayout_Brand_Items__c brandItemToInsert = new SurveyLayout_Brand_Items__c();
                    brandItemToInsert.Brand__c = brandItem.Brand__c ;
                    brandItemToInsert.Display_Checkbox_Not_Applicable__c = brandItem.Display_Checkbox_Not_Applicable__c;
                    brandItemToInsert.Survey_Layout__c = newLayoutRecord.Id ;
                    //String newBrandName = brandItem.Brand__r.Name + ' ' + newLayoutRecord.Name ;
                    //if(newBrandName.length() > 80)
                    //  newBrandName = newBrandName.subString(0,80) ;
                    
                    //brandItemToInsert.Name = newBrandName ;
                    brandItemsToInsert.add(brandItemToInsert);
                }
                
                insert brandItemsToInsert ;
                
            }
            
            if(brandBottleItems != null)
            {
                for(Survey_Layout_Brand_Bottle_Item__c bottleItem : brandBottleItems) {
                    Survey_Layout_Brand_Bottle_Item__c bottleItemToInsert = new Survey_Layout_Brand_Bottle_Item__c();
                    bottleItemToInsert.BrandBottle_Size__c = bottleItem.BrandBottle_Size__c ;
                    bottleItemToInsert.Survey_Layout__c = newLayoutRecord.Id ;
                    //String newBottleName = bottleItem.BrandBottle_Size__r.Name + ' ' + newLayoutRecord.Name ;
                    //if(newBottleName.length() > 80)
                    //  newBottleName = newBottleName.subString(0,80) ;
                    //bottleItemToInsert.Name = newBottleName ;
                    bottleItemsToInsert.add(bottleItemToInsert);
                }
                
                insert bottleItemsToInsert ;
            }
            
            
        }
        
        
        
    }
    
      
    //method added by Diana Acker, 10/16/2012, Appirio Case 00034196, testing survey layout creation
    public static void createAccountSurveyRecordsFromLayoutRecord(Map<Id,Survey_Layout__c> newSurveyLayoutMap, Map<Id,Survey_Layout__c> oldSurveyLayoutMap)
    {
        if (!batchJobSubmitted)
        {
            BatchGenerateSurveysAfterActivation batch = new BatchGenerateSurveysAfterActivation();
            database.executebatch(batch,1);
            batchJobSubmitted = true;
        }
    }
    
    
    private static Survey_Layout__c buildNewSurveyLayout(Survey_Layout__c layoutRecordToClone)
    {
        Survey_Layout__c newLayoutRecord =  layoutRecordToClone.clone(false, true);
        
        newLayoutRecord.Activate_Survey__c = false;
        
        Integer nextMonth = Date.today().month() + 1 ;
        String nextMonthString = DiageoUtils.getMonthFullnameFromMonthNumber(nextMonth);
        Integer nextMonthYear = Date.today().addDays(31).year() ;
        if(nextMonth == 13)
            nextMonth = 1 ;
        
        if(newLayoutRecord.Name == null || newLayoutRecord.Name.length() == 0)
            newLayoutRecord.Name = nextMonthString + ' ' + String.valueOf(nextMonthYear);
        
        return newLayoutRecord ;
    }
    
    
    private static Map<Id,List<SurveyLayout_Brand_Items__c>> buildBrandItemMapBySurveyLayoutId(Map<Id, Survey_Layout__c> surveyLayout) {
        
        Map<Id,List<SurveyLayout_Brand_Items__c>> mapToReturn = new Map<Id,List<SurveyLayout_Brand_Items__c>>();
        
        for(SurveyLayout_Brand_Items__c brandItem : [select Id, Name, Brand__c, Survey_Layout__c from SurveyLayout_Brand_Items__c where Survey_Layout__c in :surveyLayout.keySet()] ) {
            
            List<SurveyLayout_Brand_Items__c> childList = mapToReturn.get(brandItem.Survey_Layout__c) ;
            
            if(childList == null || childList.isEmpty()) {
                childList = new List<SurveyLayout_Brand_Items__c>() ;
            }
            
            childList.add(brandItem);
            
            mapToReturn.put(brandItem.Survey_Layout__c, childList) ;
            
        }
        
        return mapToReturn ;
    }
    
    
    private static Map<Id,List<Survey_Layout_Brand_Bottle_Item__c>> buildBrandBottleItemMapBySurveyLayoutId(Map<Id, Survey_Layout__c> surveyLayoutMap) {
        
        Map<Id,List<Survey_Layout_Brand_Bottle_Item__c>> mapToReturn = new Map<Id,List<Survey_Layout_Brand_Bottle_Item__c>>();
        
        for(Survey_Layout_Brand_Bottle_Item__c brandBottleItem : [select Id, Name, BrandBottle_Size__c, BrandBottle_Size__r.Brand__c, Survey_Layout__c from Survey_Layout_Brand_Bottle_Item__c where Survey_Layout__c in :surveyLayoutMap.keySet()]) {
            
            List<Survey_Layout_Brand_Bottle_Item__c> childList = mapToReturn.get(brandBottleItem.Survey_Layout__c) ;
            
            if(childList == null || childList.isEmpty()) {
                childList = new List<Survey_Layout_Brand_Bottle_Item__c>() ;
            }
            
            childList.add(brandBottleItem);
            
            mapToReturn.put(brandBottleItem.Survey_Layout__c, childList) ;
            
        }
        
        return mapToReturn ;
    }
    
    
    
    
    
    
}