/* 
  @An Apex Class that is Associated with MM_RecipeView Page.
  @Displays all Sections for creating A Recipe.
  @Author  : Raj Avirneni
  @Date    : Mar 23 2012
  @Version : 1.0
*/
/* Modified By  : Deepak Sharma(Appirio Offshore on 11-Sep-2012)
   Details      : Modified against T-81876: Modify Code - Workflow rules / code   
*/
/* Modified By  : Rishi Khirbat(Appirio Offshore)
   Details      : Modified against: 
                    T-98032  - Updates to MM_RecipeView (on 29th-Nov-2012) 
                    T-103789 - Add Manage Images to Recipe View screen (on 13th-Dec-2012)
                    T-104879 - Add Measurement Conversion button to MM_ViewRecipe (on 18th-Dec-2012)
                    T-105835 - Conditonally Add "Edit Recipe" button on MM_ViewRecipe (on 2nd-Jan-2013)
*/
/* Modified By  : Harshit Jain(Appirio Offshore on 05th-Dec-2012)
   Details      : Modified against T-101442: Add a Publish Button on MM_RecipeView 
*/
public with sharing class MM_RecipeViewController extends MM_RecipeBase {
  
    //T-81876
    public static final String  RECIPE_EDITOR = 'Recipe - Editor';  
    public static final String  RECIPE_REVIEWER = 'Recipe - Reviewer';
    public static final String  RECIPE_APPORVER = 'Recipe - Approver';
    public static final String  RECIPE_ADMIN =  'Recipe - Admin';
    //T-105835 - Conditonally Add "Edit Recipe" button on MM_ViewRecipe
    public static final String  RECIPE_PUBLISHER =  'Recipe - Publisher';
    //-------
  
    private String recipeId;
    private String templateId;
    public String rejectComments {get; set;}
    public Id swapId {get; set;}
    public Boolean canEdit = false;
    public Boolean cUser = false;
    public Boolean assetListEmpty {get;set;}
    public Boolean showCustom {get; set;}
    public String cssStatus {get; set;}
    public String ingredientType {get; set;}
    public String output {get; set;}
    public String eTable {get; set;}
    public String eId {get; set;}
    public Boolean isReorder {get; set;}        
    public Boolean renderMaster { get; set; }   
    public String quantity {get; set;}
    public String modifier {get; set;}
    public String unit {get; set;}
    public String ingredient {get; set;}
    public Boolean featured {get; set;}
    public Boolean isProduct {get; set;}
    public Boolean isDiageo {get; set;}
    public Non_Diageo_Ingredient__c editNDI{ get; set; }
    public Diageo_Ingredient__c editDI{ get; set; }
    public Custom_Ingredient__c editCustom{ get; set; }
    public Boolean isEdit { get; set; }
   
    private List<recipeImageWrapper> recipeImages;
    private List<recipeImageWrapper> attributeImages;
    public list<Recipe_Media__c> recipeImageMedia;
    public Recipe__c currentRecipe {get; set; }
    private Recipe_Generic_Ingredient__c currentIngredient {get; set; }
    public list<publishedRecipeWrapper>  publishRecipeWrapperList {get;set;}
    public String selectedAssetId {get;set;}
    public List<Id> recipeBrands;
    
    private List<IngredientWrapper> ingredients;
    public String modifiedIngredientIndex {get;set;}
    
    public Id selectedAdmin {get;set;}
    
    public Id selectedReviewer {get;set;}
    public Id selectedApprover {get;set;}
    public Id selectedEditor {get;set;} 
    public Id selectedUser {get;set;}   
    public Map<Id, Diageo_Brand__c> brandMap { get; set; }
    //public Set<String> assetList {get; set;}
    public List<Published_Recipe__c> assetList {get; set;}
    public Map<Id, Id> productToBrandMap {get; set;}
    public Map<Id, Id> recipeToAssetMap {get; set;}
    public Boolean editMode {get; set;}
    public Boolean submitMode {get;set;}
    public User recipeCreator;
    private String diageoProductId = '';    
    public boolean displayPopup {get; set;}
    public boolean displayProduct {get; set;}
    public boolean editingIngredient {get; set;}
    public String currentComment {get; set;}
    public String currentRejectComment {get; set;}  
    public String[] preparationSteps {get; set;}
    public Integer preparationStep {get; set;}
    private String currentStep; 
    public Boolean displayPrep {get; set;}  
    public boolean comingfromViewAll{get;set;}
    public String prepStepDescription { get; set; }
    public static Integer stepNumber { get; set; }
    public  static integer tabIndexDiageoCount{get;set;}
    public static Integer tabIndexNonDiageoCount{get;set;}
    public static Integer prepStepsIndexCount{get;set;}
    
    public String preparationId { get; set; }
    public String prepOp { get; set; }
    public Boolean isPrepEdit {get; set;}
    public Preparation_Step__c pEdit { get; set; }
    public Boolean isCreateNew { get; set; }
    public string brand{get;set;}
    public string searchTerm {get;set;}
    public string currentBrand {get;set;}
    public string currentColor {get;set;}
    
    public string currentFlavor {get;set;}
    public string currentIngredientNumber {get;set;}
    public string isNavigatingFromDetail {get;set;}
    public string comingFromViewAllRecipesPage{get;set;}
    
    public string recipeFlavor {get;set;}
    public string recipeoccasionType {get; set;}
    public string prevPage {get; set;}
    private final String NONE_STRING = ' - None - ';    
    public Integer errorMsg {get; set;}
    public string errorMessage{get;set;}
    public string topRow {get; set;}
    
    public list<Attribute__c> attrTypes = new list<Attribute__c>();
    public list<Occasion__c> occnTypes = new list<Occasion__c>();
    private list<selectOption> colorOptions;
    private list<selectOption> languageOptions;
    private list<selectOption> celebration1Options;
    private list<selectOption> celebration2Options;
    private list<selectOption> celebration3Options;
    private list<selectOption> celebration4Options;
    private list<selectOption> themeParty1Options;
    private list<selectOption> themeParty2Options;
    private list<selectOption> themeParty3Options;
    private list<selectOption> themeParty4Options;
    private list<selectOption> holidays1Options;
    private list<selectOption> holidays2Options;
    private list<selectOption> holidays3Options;
    private list<selectOption> holidays4Options;
    private list<selectOption> outdoor1Options;
    private list<selectOption> outdoor2Options;
    private list<selectOption> outdoor3Options;
    private list<selectOption> outdoor4Options;
    private list<string> sortedLanguageList;
    map<string,Id> languageMap;
    map<string,Id> totalAttrImageMap;
    map<string,Id> attributeImageMap;
    private list<string> sortedImageList;
    map<string,id> colorMap = new map<string,id>();
    public Id selColor{get;set;}
    public string recipeColor{get;set;}
    public Id selLanguage{get;set;}
    public string recipeLanguage{get;set;}
    
    public Integer pSize {
    get{
        return prepSteps.size();
    }
    set;
   }
    
    public MM_RecipeViewController(String recipeId) {
        this.recipeId = recipeId;
        
    }
    
    /*Modified By Rishi Khirbat -> T-98032:Updates to MM_RecipeView*/
    
    private list<selectOption> effortOptions;
    private list<selectOption> glasswareOptions;
    private list<selectOption> servingOptions;
    private list<selectOption> wineTasteOptions;
    private list<selectOption> wineTypeOptions;
    private list<selectOption> flavorOptions;
    private list<selectOption> barwareOptions;
    private list<selectOption> drinkOptions;
    private list<selectOption> typeOptions;
    
    public string currentEffort {get;set;}
    public string currentGlassware {get;set;}
    public string currentServing {get;set;}
    public string currentWineTaste {get;set;}
    public string currentWineType {get;set;}
    
    public string currentBarware {get;set;}
    public string currentDrink {get;set;}
    public string currentType {get;set;}
    public string currentOccasion {get;set;}
    public string currentStatus {get;set;}
    
    public string recipeBarware {get;set;}
    public string recipeDrink {get;set;}
    public string recipeoccasion {get; set;}
    public string recipeType {get; set;}
    
    public Id selEffort{get;set;}
    public Id selGlassware{get;set;}
    public Id selServing{get;set;}
    public Id selWineTaste{get;set;}
    public Id selWineType{get;set;}
    
    public string recipeEffort{get;set;}
    public string recipeGlassware{get;set;}
    public string recipeServing{get;set;}
    public string recipeWineTaste{get;set;}
    public string recipeWineType{get;set;}
    
    public string descriptionOverview {get;set;}
    public string recipeStory {get;set;}
    //public string servings {get;set;}
    public string servingSize {get;set;}
    public string foodPairings {get;set;}
    public string standardAverageAnalysis {get;set;}
    public string tastingNotes {get;set;}
    
    public string selLocaleDetailsFilter{get;set;}
    public string selLocaleAddOccasionsFilter{get;set;}
    // Changed by Rahul Chitkara Case  - 00005214
    public string selLocaleIngredientsFilter{
    get
    {
       if(selLocaleIngredientsFilter=='-None-')
           selLocaleIngredientsFilter='EN-US';
           return selLocaleIngredientsFilter;
    }
    set;
    }
    // Changes End
    public boolean publishedRecipeExist{get;set;}
    //T-103789 - Add Manage Images to Recipe View screen
    public boolean showManageImages{get;set;}
    public boolean showAddTagsLink{get;set;}
    public String concatenateTagsValue{get;set;}
    public boolean showAddOccasionsLink{get;set;}
    
    //T-104879 - Add Measurement Conversion button to MM_ViewRecipe
    public boolean isConvertMeasurement {get;set;}
    //I-40834 - While creating the new recipe, recipe name is getting removed ,after selecting an image.
    public String recipeTitle {get;set;}
    
    
    transient map<String, Convert_Measurements__c> mapConvertMeasurements;
    private map<String, String> mapOZTo5Mils;   
    private map<String, String> mapMLToOZ;
    private boolean isConvertOZMeasurement;
    private boolean isConvertMLMeasurement;
    
    //T-105835 - Conditonally Add "Edit Recipe" button on MM_ViewRecipe
    //I-47100 - For Draft Recipes, only can be edited by Recipe-Admin or user in Recipe__c.CurrentEditor__c
    public boolean isEditRecipeButtonShow {
        get {
            //I-47102 - No user can edit recipe while status = Pending Approval
            if(currentRecipe.Status__c.equals('Pending Approval')) {
                return false;
            }
            return  !editMode && canEdit;
        }
        set;
    }
    //I-41400-Recipe Publisher Role unable to create new recipe or clone from existing recipe
    private boolean isClone;
    public boolean isCloneRecipeButtonShow {
        get {
            if(!editMode && currentRecipe.Status__c == 'Approved')
                return true;
            
            return false;
        }
        set;
    }
    
    
    public boolean isBodyHeaderBlackShow {
        get {
            if(canEdit && (
                        (editMode && currentRecipe.Status__c == 'Approved') ||
                        (editMode && currentRecipe.Status__c =='Draft') || 
                        (cUser && currentRecipe.Status__c !='Approved') || 
                        ((isReviewer || isApprover || isSuperAdmin) && currentRecipe.Status__c =='Pending Review' && getcRevApp()) || 
                        ((isApprover || isSuperAdmin || isPublisher) && currentRecipe.Status__c =='Pending Approval'))){
                return true;            
            } else {
                return false;   
            }
        }
        set;
    }
    /*****/
    
    public MM_RecipeViewController() {
        editMode = false;
        mapOZTo5Mils = new map<String, String>();
        mapMLToOZ = new map<String, String>();
        mapConvertMeasurements = Convert_Measurements__c.getAll();
    
        //Getting all the Values from the View All Reicpe Page If the User Views a Reicpe from the Serach Page.
        recipeId = ApexPages.currentPage().getParameters().get('recipeId');
        searchTerm = ApexPages.currentPage().getParameters().get('searchTerm');
        currentBrand = ApexPages.currentPage().getParameters().get('currentBrand');
        currentColor = ApexPages.currentPage().getParameters().get('currentColor');
        currentEffort = ApexPages.currentPage().getParameters().get('currentEffort');
        currentGlassware = ApexPages.currentPage().getParameters().get('currentGlassware');
        currentServing = ApexPages.currentPage().getParameters().get('currentServing');
        currentWineTaste = ApexPages.currentPage().getParameters().get('currentWineTaste');
        currentWineType = ApexPages.currentPage().getParameters().get('currentWineType');
        currentFlavor = ApexPages.currentPage().getParameters().get('currentFlavor');
        currentBarware = ApexPages.currentPage().getParameters().get('currentBarware');
        currentDrink = ApexPages.currentPage().getParameters().get('currentDrink');
        currentType = ApexPages.currentPage().getParameters().get('currentType');
        currentOccasion = ApexPages.currentPage().getParameters().get('currentOccasion');
        currentStatus = ApexPages.currentPage().getParameters().get('currentStatus');
        currentIngredientNumber = ApexPages.currentPage().getParameters().get('currentIngredientNumber');
        comingFromViewAllRecipesPage = ApexPages.currentPage().getParameters().get('comingFromViewAllRecipesPage');
        prevPage=ApexPages.currentPage().getParameters().get('prevPage');
        recipeTitle = ApexPages.currentPage().getParameters().get('title');
        isClone=ApexPages.currentPage().getParameters().get('isClone') == 'true'?true:false;
            
        stepNumber=0;
        errorMsg = 0;
        isDiageo = true;
        isProduct = true;
        isEdit = false;
        showManageImages = false;
        showAddTagsLink = false;
        showAddOccasionsLink = false;
        brand='';
        tabIndexDiageoCount = 1;
        tabIndexNonDiageoCount = 1050;
        prepStepsIndexCount = 0;
        isConvertMeasurement = false;
        isConvertOZMeasurement = false;
        isConvertMLMeasurement = false;
        isEditRecipeButtonShow = false;
        
        if(comingFromViewAllRecipesPage == 'true')
            comingfromViewAll = true;
            
        for(String name :mapConvertMeasurements.keySet()) {
            Convert_Measurements__c convertMeasurements = mapConvertMeasurements.get(name);
            system.debug('====================convertMeasurements: '+convertMeasurements);
            if(convertMeasurements != null) {
                mapOZTo5Mils.put(convertMeasurements.fl_Oz__c.trim(),convertMeasurements.X5Mils__c.trim());
                // Modified by Rahul Chitkara on 30th July , case 6067
                //mapMLToOZ.put(convertMeasurements.mL__c.trim(),convertMeasurements.fl_Oz__c.trim());
                mapMLToOZ.put(convertMeasurements.X5Mils__c.trim(),convertMeasurements.fl_Oz__c.trim());
                // End Changes 6067
            }
        }
    }
    
    public PageReference checkNull() {
        
        PageReference pageRef;
        
        if (!ApexPages.currentPage().getParameters().containsKey('recipeId') && !ApexPages.currentPage().getParameters().containsKey('newRecipe'))
            pageRef = Page.MM_RecipeDashboard;
        
        return pageRef;
    }
    
    public Integer currentStepNumber {
            get{
                return currentStepNumber++;
            }
            set;
    }   
    
    /*By Rishi Khirbat -> T-104879: Add Measurement Conversion button to MM_ViewRecipe ********/
    //Used for View Mode Display
    public List<Diageo_Ingredient__c> getDiageoIngredient() {
        List<Diageo_Ingredient__c> ingredients = new List<Diageo_Ingredient__c>();
        List<Diageo_Ingredient__c> dIngredients = new List<Diageo_Ingredient__c>();
        dIngredients = [ Select Id,Units__c,Ingredient_Unit__c,Non_Diageo_Product_Units__c,Recipe_Diageo_Product__c,
                        Recipe_Non_Diageo_Product__c,Recipe_Diageo_Product__r.Name,
                        Recipe_Diageo_Product__r.Diageo_Product_Image__r.Content_Id__c, 
                        Recipe_Non_Diageo_Product__r.Name, Quantity__c, Featured_Brand__c 
                        from Diageo_Ingredient__c 
                        where Recipe__c =: recipeId 
                        and (Recipe_Diageo_Product__c <> null or Recipe_Non_Diageo_Product__c <> null)];    
        return dIngredients;
    }
    
    public List<WrapperDiageoIngredient> getWrapperDiageoIngredient() {
        List<WrapperDiageoIngredient> wrDiageoIngredients = new List<WrapperDiageoIngredient>();
        for(Diageo_Ingredient__c ingredients :getDiageoIngredient()) {
            WrapperDiageoIngredient wrDiageoIngredient;
            
            wrDiageoIngredient = new WrapperDiageoIngredient(ingredients,ingredients.Ingredient_Unit__c,ingredients.Quantity__c);
            
            if(isConvertMLMeasurement && wrDiageoIngredient.convertedUnit.equals('oz.') && wrDiageoIngredient.convertedQuantity != null) {
                if(mapOZTo5Mils.get(wrDiageoIngredient.convertedQuantity) != null)
                    wrDiageoIngredient = new WrapperDiageoIngredient(ingredients , 'ml.', mapOZTo5Mils.get(wrDiageoIngredient.convertedQuantity));
            } 
            
            if(isConvertOZMeasurement && wrDiageoIngredient.convertedUnit.equals('ml.') && wrDiageoIngredient.convertedQuantity != null) {
                if(mapMLToOZ.get(wrDiageoIngredient.convertedQuantity) != null)
                    wrDiageoIngredient = new WrapperDiageoIngredient(ingredients , 'oz.', mapMLToOZ.get(wrDiageoIngredient.convertedQuantity));
            }
            
            wrDiageoIngredients.add(wrDiageoIngredient);
        }
        
        isConvertMeasurement = false;
        if(isConvertOZMeasurement || isConvertMLMeasurement)
            isConvertMeasurement = true;
            
        return wrDiageoIngredients;
    }
   
    public class WrapperDiageoIngredient {
        public Diageo_Ingredient__c ingredients {get;set;}
        public String convertedUnit {get;set;}
        public String convertedQuantity {get;set;}
        
        public WrapperDiageoIngredient(Diageo_Ingredient__c ingred, String conUnit, String conQuanty) {
            ingredients = ingred;
            convertedUnit = conUnit;
            convertedQuantity = conQuanty;
        }
    }
    
    public PageReference convertOZMeasurements() {
        isConvertOZMeasurement = true;
        isConvertMLMeasurement = false;
        return null;
    }
    public PageReference convertMLMeasurements() {
        isConvertMLMeasurement = true;
        isConvertOZMeasurement = false;
        return null;
    }
    /************/
    
    /*By Rishi Khirbat -> T-98032: Updates to MM_RecipeView ********/
    public PageReference saveTags() {
        if(concatenateTagsValue == null || concatenateTagsValue.trim() == '') {
            return null;
        }
        if(currentRecipe.Recipe_Tags__c == null) {
            currentRecipe.Recipe_Tags__c = concatenateTagsValue; 
        } else {
            currentRecipe.Recipe_Tags__c = currentRecipe.Recipe_Tags__c + ', ' + concatenateTagsValue;
        }
        update currentRecipe;
        return null;
    }
    
    public PageReference LocaleAddOccasionsFilter() {
        selLocaleDetailsFilter = selLocaleAddOccasionsFilter;
        return localeDetailsFilter();
    }
    public PageReference localeDetailsFilter() {
        /*By Rishi Khirbat -> I-39172*/
        selCurrFlavorIds = retainingSelections(selFlavorIds, selCurrFlavorIds, selShowFlavorIds);
        selCurrTypeIds = retainingSelections(selTypeIds, selCurrTypeIds, selShowTypeIds);
        selCurrBarwareIds = retainingSelections(selBarwareIds, selCurrBarwareIds, selShowBarwareIds);
        selCurrDrinkIds = retainingSelections(selDrinkIds, selCurrDrinkIds, selShowDrinkIds);
        
        selCurrCelebration1Ids = retainingSelections(selCelebration1Ids, selCurrCelebration1Ids, selShowCelebration1Ids);
        selCurrCelebration2Ids = retainingSelections(selCelebration2Ids, selCurrCelebration2Ids, selShowCelebration2Ids);
        selCurrCelebration3Ids = retainingSelections(selCelebration3Ids, selCurrCelebration3Ids, selShowCelebration3Ids);
        selCurrCelebration4Ids = retainingSelections(selCelebration4Ids, selCurrCelebration4Ids, selShowCelebration4Ids);
         
        selCurrThemeParty1Ids = retainingSelections(selThemeParty1Ids, selCurrThemeParty1Ids, selShowThemeParty1Ids);
        selCurrThemeParty2Ids = retainingSelections(selThemeParty2Ids, selCurrThemeParty2Ids, selShowThemeParty2Ids);
        selCurrThemeParty3Ids = retainingSelections(selThemeParty3Ids, selCurrThemeParty3Ids, selShowThemeParty3Ids);
        selCurrThemeParty4Ids = retainingSelections(selThemeParty4Ids, selCurrThemeParty4Ids, selShowThemeParty4Ids);
        
        selCurrHoliday1Ids = retainingSelections(selHoliday1Ids, selCurrHoliday1Ids, selShowHoliday1Ids);
        selCurrHoliday2Ids = retainingSelections(selHoliday2Ids, selCurrHoliday2Ids, selShowHoliday2Ids);
        selCurrHoliday3Ids = retainingSelections(selHoliday3Ids, selCurrHoliday3Ids, selShowHoliday3Ids);
        selCurrHoliday4Ids = retainingSelections(selHoliday4Ids, selCurrHoliday4Ids, selShowHoliday4Ids);
        
        selCurrOutdoor1Ids = retainingSelections(selOutdoor1Ids, selCurrOutdoor1Ids, selShowOutdoor1Ids);
        selCurrOutdoor2Ids = retainingSelections(selOutdoor2Ids, selCurrOutdoor2Ids, selShowOutdoor2Ids);
        selCurrOutdoor3Ids = retainingSelections(selOutdoor3Ids, selCurrOutdoor3Ids, selShowOutdoor3Ids);
        selCurrOutdoor4Ids = retainingSelections(selOutdoor4Ids, selCurrOutdoor4Ids, selShowOutdoor4Ids);
        
        createTempRecipe();
        return null;
    }
    
    private set<Id> retainingSelections(Id[] selIds, set<Id> currSelIds, set<Id> showIds) {
        set<Id> setSelIds = new set<Id>();
        setSelIds.addAll(selIds);
        
        if(currSelIds.size() == 0) {
            currSelIds.addAll(selIds);
        } else {
            currSelIds.addAll(selIds);
            for(Id currId :currSelIds) {
                if(!setSelIds.contains(currId) && !showIds.contains(currId)) {
                    setSelIds.add(currId);
                } else if(!setSelIds.contains(currId) && showIds.contains(currId)) {
                    currSelIds.remove(currId);
                } 
            }
        }
        return currSelIds;
    }
    
    public PageReference localeIngredientsFilter() {
        //nonDiagIng = null;
        return null;
    }
    /*********/
   
    //Method that is being called as soon as the Page loads.    
    public void createTempRecipe() {
        //By Rishi Khirbat -> T-98032: Updates to MM_RecipeView 
        colorOptions = new list<selectOption>();
        effortOptions = new list<selectOption>();
        glasswareOptions = new list<selectOption>();
        servingOptions = new list<selectOption>();
        wineTasteOptions = new list<selectOption>();
        wineTypeOptions = new list<selectOption>();
        flavorOptions = new list<selectOption>();
        barwareOptions = new list<selectOption>();
        drinkOptions = new list<selectOption>();
        typeOptions = new list<selectOption>();
        languageOptions = new list<selectOption>();
        celebration1Options = new list<selectOption>();
        celebration2Options = new list<selectOption>();
        celebration3Options = new list<selectOption>();
        celebration4Options = new list<selectOption>();
        themeParty1Options = new list<selectOption>();
        themeParty2Options = new list<selectOption>();
        themeParty3Options = new list<selectOption>();
        themeParty4Options = new list<selectOption>();
        holidays1Options = new list<selectOption>();
        holidays2Options = new list<selectOption>();
        holidays3Options = new list<selectOption>();
        holidays4Options = new list<selectOption>();
        outdoor1Options = new list<selectOption>();
        outdoor2Options = new list<selectOption>();
        outdoor3Options = new list<selectOption>();
        outdoor4Options = new list<selectOption>();
        totalAttrImageMap = new map<string,Id>();
        sortedLanguageList = new list<string>();
        languageMap = new map<string,Id>();
        languageOptions.add(new SelectOption('','-None-'));
        colorOptions.add(new SelectOption('','-None-'));
        effortOptions.add(new SelectOption('','-None-'));
        glasswareOptions.add(new SelectOption('','-None-'));
        servingOptions.add(new SelectOption('','-None-'));
        wineTasteOptions.add(new SelectOption('','-None-'));
        wineTypeOptions.add(new SelectOption('','-None-'));
        
        selShowFlavorIds = new set<Id>();
        selShowTypeIds = new set<Id>();
        selShowBarwareIds = new set<Id>();
        selShowDrinkIds = new set<Id>();
        
        selShowCelebration1Ids = new set<Id>();
        selShowCelebration2Ids = new set<Id>();
        selShowCelebration3Ids = new set<Id>();
        selShowCelebration4Ids = new set<Id>();
                 
        selShowThemeParty1Ids = new set<Id>();
        selShowThemeParty2Ids = new set<Id>();
        selShowThemeParty3Ids = new set<Id>();
        selShowThemeParty4Ids = new set<Id>();
        
        selShowHoliday1Ids = new set<Id>();
        selShowHoliday2Ids = new set<Id>();
        selShowHoliday3Ids = new set<Id>();
        selShowHoliday4Ids = new set<Id>();
        
        selShowOutdoor1Ids = new set<Id>();
        selShowOutdoor2Ids = new set<Id>();
        selShowOutdoor3Ids = new set<Id>();
        selShowOutdoor4Ids = new set<Id>();
     
        //Getting all the Attributes and Occasions existing in the System and addign them to respective Types for displaying as list of Options on to the UI
        if(selLocaleDetailsFilter == null || selLocaleDetailsFilter.trim().equals('-None-')) {
            attrTypes = [select id,Attribute_Value__c,Attribute_Type__c,Attribute_Value_Image__c,Attribute_Value_Image__r.Content_Id__c from Attribute__c order by Attribute_Value__c];
            occnTypes = [select id,Occasion_Type__c,Name_Of_The_Occasion__c,Recipe_Occasion_Image__c,Recipe_Occasion_Image__r.Content_Id__c from Occasion__c order by Name_Of_The_Occasion__c]; 
        } else  {
            attrTypes = [select id,Attribute_Value__c,Attribute_Type__c,Attribute_Value_Image__c,Attribute_Value_Image__r.Content_Id__c from Attribute__c Where Locale__c =:selLocaleDetailsFilter order by Attribute_Value__c];
            occnTypes = [select id,Occasion_Type__c,Name_Of_The_Occasion__c,Recipe_Occasion_Image__c,Recipe_Occasion_Image__r.Content_Id__c from Occasion__c Where Locale__c =:selLocaleDetailsFilter order by Name_Of_The_Occasion__c];
        }
     
        if(attrTypes.size()>0 && attrTypes!= null) {
            for(Attribute__c attr : attrTypes) {
                if(attr.Attribute_Type__c =='Color') {
                    colorOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    if(attr.Attribute_Value_Image__c != null)   
                    totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                } else if(attr.Attribute_Type__c =='Effort Level') {
                    effortOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    if(attr.Attribute_Value_Image__c != null)
                    totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                } else if(attr.Attribute_Type__c =='Glassware') {
                    glasswareOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    if(attr.Attribute_Value_Image__c != null)
                    totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                } else if(attr.Attribute_Type__c =='Serving Style') {
                    servingOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    if(attr.Attribute_Value_Image__c != null)
                    totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                } else if(attr.Attribute_Type__c =='Wine Taste') {
                    wineTasteOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    if(attr.Attribute_Value_Image__c != null)
                    totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                } else if(attr.Attribute_Type__c =='Wine Type') {
                    wineTypeOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    if(attr.Attribute_Value_Image__c != null)
                    totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                } else if(attr.Attribute_Type__c =='Flavor') {
                    selShowFlavorIds.add(attr.Id);
                    flavorOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    if(attr.Attribute_Value_Image__c != null)
                    totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                } else if(attr.Attribute_Type__c =='Barware Needed') {
                    selShowBarwareIds.add(attr.Id);
                    barwareOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    if(attr.Attribute_Value_Image__c != null)
                    totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                } else if(attr.Attribute_Type__c =='Drink Classification') {
                    selShowDrinkIds.add(attr.Id);
                    drinkOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    if(attr.Attribute_Value_Image__c != null)
                    totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                } else if(attr.Attribute_Type__c =='Drink Type') {
                    selShowTypeIds.add(attr.Id);
                    typeOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    if(attr.Attribute_Value_Image__c != null)
                    totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                } else if(attr.Attribute_Type__c =='Language') {
                    if(attr.Attribute_Value__c == 'English')
                        languageOptions.add(new SelectOption(attr.Id,attr.Attribute_Value__c));
                    else {
                        sortedLanguageList.add(attr.Attribute_Value__c);
                        languageMap.put(attr.Attribute_Value__c,attr.Id);
                    }
                    if(attr.Attribute_Value_Image__c != null)
                        totalAttrImageMap.put(attr.Attribute_Type__c+' - '+attr.Attribute_Value__c,attr.Attribute_Value_Image__r.Content_Id__c);
                }
            }   
        }
        //---   
        if(sortedLanguageList.size()>0)
            sortedLanguageList.sort();
        for(string s : sortedLanguageList) {
            languageOptions.add(new SelectOption(languageMap.get(s),s));
        }
        
        //seperating Occasions based on Type and displayig them on to the respective Tab Content
        if(occnTypes.size()>0 && occnTypes!= null) {
            double totalCelCount = 0;
            double totalThemeCount = 0;
            double totalHoliCount = 0;
            double totalOutdoorCount = 0;
            
            integer celCount = 1;
            integer themeCount = 1;
            integer holiCount = 1;
            integer outdoorCount = 1;
            
            for(Occasion__c occCount :occnTypes) {
                if(occCount.Occasion_Type__c =='Celebrations') {
                    totalCelCount++;
                }
                else if(occCount.Occasion_Type__c =='Theme Parties') {
                    totalThemeCount++;
                }
                else if(occCount.Occasion_Type__c =='Holidays') {
                    totalHoliCount++;
                }
                else if(occCount.Occasion_Type__c =='Outdoor Gatherings') {
                    totalOutdoorCount++;
                }
            }
            for(Occasion__c occsn : occnTypes) {
                if(occsn.Occasion_Type__c =='Celebrations' && occsn.Name_Of_The_Occasion__c != null) {
                    if(occsn.Recipe_Occasion_Image__c != null) {
                        totalAttrImageMap.put(occsn.Occasion_Type__c+' - '+occsn.Name_Of_The_Occasion__c,occsn.Recipe_Occasion_Image__r.Content_Id__c);
                    }
                    if(celCount <= Math.CEIL(totalCelCount/4)){
                        selShowCelebration1Ids.add(occsn.Id);
                        celebration1Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else if((celCount > Math.CEIL(totalCelCount/4)) && (celCount <= (2*Math.CEIL(totalCelCount/4)))) {
                        selShowCelebration2Ids.add(occsn.Id);
                        celebration2Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else if((celCount > (2*Math.CEIL(totalCelCount/4))) && (celCount <= (3*Math.CEIL(totalCelCount/4)))) {
                        selShowCelebration3Ids.add(occsn.Id);
                        celebration3Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else {
                        selShowCelebration4Ids.add(occsn.Id);
                        celebration4Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    }
                    celCount++;         
                    
                }
                else if(occsn.Occasion_Type__c =='Theme Parties' && occsn.Name_Of_The_Occasion__c != null) {
                    if(occsn.Recipe_Occasion_Image__c != null) {
                        totalAttrImageMap.put(occsn.Occasion_Type__c+' - '+occsn.Name_Of_The_Occasion__c,occsn.Recipe_Occasion_Image__r.Content_Id__c);
                    }
                    if(themeCount <= Math.CEIL(totalThemeCount/4)) {
                        selShowThemeParty1Ids.add(occsn.Id);
                        themeParty1Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else if((themeCount > Math.CEIL(totalThemeCount/4)) && (themeCount <= (2*Math.CEIL(totalThemeCount/4)))) {
                        selShowThemeParty2Ids.add(occsn.Id);
                        themeParty2Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else if((themeCount > (2*Math.CEIL(totalThemeCount/4))) && (themeCount <= (3*Math.CEIL(totalThemeCount/4)))) {
                        selShowThemeParty3Ids.add(occsn.Id);
                        themeParty3Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else {
                        selShowThemeParty4Ids.add(occsn.Id);
                        themeParty4Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    }
                    themecount++;   
                }
                else if(occsn.Occasion_Type__c =='Holidays' && occsn.Name_Of_The_Occasion__c != null) {
                    if(occsn.Recipe_Occasion_Image__c != null) {
                        totalAttrImageMap.put(occsn.Occasion_Type__c+' - '+occsn.Name_Of_The_Occasion__c,occsn.Recipe_Occasion_Image__r.Content_Id__c);
                    }
                    if(holiCount <= Math.CEIL(totalHoliCount/4)) {
                        selShowHoliday1Ids.add(occsn.Id);
                        holidays1Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else if((holiCount > Math.CEIL(totalHoliCount/4)) && (holiCount <= (2*Math.CEIL(totalHoliCount/4)))) {
                        selShowHoliday2Ids.add(occsn.Id);
                        holidays2Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else if((holiCount > (2*Math.CEIL(totalHoliCount/4))) && (holiCount <= (3*Math.CEIL(totalHoliCount/4)))) {
                        selShowHoliday3Ids.add(occsn.Id);
                        holidays3Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c)); 
                    } else {
                        selShowHoliday4Ids.add(occsn.Id);
                        holidays4Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    }
                    holiCount++;
                }
                else if(occsn.Occasion_Type__c =='Outdoor Gatherings' && occsn.Name_Of_The_Occasion__c != null) {
                    if(occsn.Recipe_Occasion_Image__c != null) {
                        totalAttrImageMap.put(occsn.Occasion_Type__c+' - '+occsn.Name_Of_The_Occasion__c,occsn.Recipe_Occasion_Image__r.Content_Id__c);
                    }   
                    if(outdoorCount <= Math.CEIL(totalOutdoorCount/4)) {
                        selShowOutdoor1Ids.add(occsn.Id); 
                        outdoor1Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else if((outdoorCount > Math.CEIL(totalOutdoorCount/4)) && (outdoorCount <= (2*Math.CEIL(totalOutdoorCount/4)))) {
                        selShowOutdoor2Ids.add(occsn.Id);
                        outdoor2Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else if((outdoorCount > (2*Math.CEIL(totalOutdoorCount/4)) && outdoorCount <= (3*Math.CEIL(totalOutdoorCount/4)))) {
                        selShowOutdoor3Ids.add(occsn.Id);
                        outdoor3Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } else {
                        selShowOutdoor4Ids.add(occsn.Id);
                        outdoor4Options.add(new SelectOption(occsn.Id,occsn.Name_Of_The_Occasion__c));
                    } 
                    outdoorCount++;
                }
            }   
        }
        system.debug('==========================create: ' + recipeTitle);
        recipeId = ApexPages.currentPage().getParameters().get('recipeId');
        //Creates a Temp Reicpe as soon as the page gets loaded
        if(recipeId == null) {
            isCreateNew = true;
            currentRecipe = new Recipe__c();
            currentRecipe.Recipe_Title__c = 'temp recipe'+system.now();
            currentRecipe.current_Editor__c = UserInfo.getUserId();
            if (currentRecipe.Master_Recipe__c == null) {
                Master_Recipe__c master = new Master_Recipe__c();
                if(currentRecipe.Recipe_Title__c.contains('temp recipe'))
                  master.Name = 'temp recipe';
                else  
                  master.Name = currentRecipe.Recipe_Title__c;
                insert master;
                currentRecipe.Master_Recipe__c = master.Id;
            }
            insert currentRecipe;
            recipeId = currentRecipe.Id;
        }
        tabIndexDiageoCount = 1;
        tabIndexNonDiageoCount = 1050;
        prepStepsIndexCount = 0;
        getCurrentRecipe();
        displayPopup = false;
        displayProduct = false;
        editingIngredient = false;
        showCustom = false;
        
        if(currentRecipe.Recipe_Title__c == currentRecipe.Master_Recipe__r.Name || currentRecipe.Master_Recipe__r.Name=='temp recipe'|| currentRecipe.Master_Recipe__c==null)
            renderMaster=false;
        else
            renderMaster=true;
       
        if (ApexPages.currentPage().getParameters().get('editMode') == null || ApexPages.currentPage().getParameters().get('editMode') == 'false')
            editMode = false;
        else if (getCanEdit()) {    
            editMode = true;
        } else {
            system.debug('=================editMode');
            editMode = false;
        }
        
        if(getCanEdit()&&((editMode && currentRecipe.Status__c =='Draft') || (getCUser() && currentRecipe.Status__c !='Approved') || (getIsReviewer() && currentRecipe.Status__c =='Pending Review' && getcRevApp()) ||((getIsApprover() || getIsPublisher()) && currentRecipe.Status__c =='Pending Approval' && getcRevApp())))
            topRow='x';
        else
            topRow='topR';
            
        if (currentRecipe.Status__c == 'Draft')
            cssStatus = 'draft';
        else if (currentRecipe.Status__c == 'Pending Review')
            cssStatus = 'pendingReview';
        else if (currentRecipe.Status__c == 'Pending Approval')
            cssStatus = 'pendingApproval';
        else if (currentRecipe.Status__c == 'Rejected')
            cssStatus = 'rejected';
        else if (currentRecipe.Status__c == 'Approved')
            cssStatus = 'approved';
      
        
        if(editMode && currentRecipe.Status__c != 'Approved') {
            showManageImages = true;
        } else if(!editMode && currentRecipe.Status__c == 'Approved') {
            showManageImages = true;
            showAddTagsLink = true;
            if(getIsPublisher() || getIsSuperAdmin())
                showAddOccasionsLink = true;
        } else {
            showManageImages = false;
        }
        
        recipeCreator = getUserById(currentRecipe.CreatedById);
   
            
        brandMap = new Map<Id, Diageo_Brand__c>([SELECT Available__c, Brand_Category__c, CreatedById, CreatedDate, IsDeleted, 
                                                     Name, LastModifiedById, LastModifiedDate, Long_Description__c, OwnerId, Id, 
                                                     Short_Description__c, SystemModstamp 
                                                FROM Diageo_Brand__c]);
        Set<Id> rBrandId = new Set<Id>();                                        
        for(Diageo_Ingredient__c d: [ select Recipe_Diageo_Product__r.Diageo_Brand_Id__c from Diageo_Ingredient__c where Recipe__c =: currentRecipe.Id ]) {                                        
            rBrandId.add(d.Recipe_Diageo_Product__r.Diageo_Brand_Id__c);
        }
                                                       
                                                    
        /*assetList = new Set<String>();                                              
        for(Asset_Brand_Mapping__c a: [Select Diageo_Asset__r.Name
                                            From Asset_Brand_Mapping__c
                                            WHERE Recipe_Brand__c in : rBrandId
                                            AND Available__c = true
                                            AND Assigned__c = true ]) {
            assetList.add(a.Diageo_Asset__r.Name);
        }*/
        
        publishedRecipeExist = false;
        assetList = new List<Published_Recipe__c>();                                              
        for(Published_Recipe__c a: [Select Status__c, Digital_Published_Asset__r.Name, Digital_Published_asset__r.Publisher__r.Name
                                            From Published_Recipe__c 
                                            WHERE Status__c = 'Published' And Recipe__c =:recipeId]) {
            assetList.add(a);
            publishedRecipeExist = true;
        }
        
        assetListEmpty = assetList.IsEmpty();
                                                      
        productToBrandMap = new Map<Id,Id>();                                     
        for (Diageo_Product__c dp : [Select Id, Diageo_Brand_Id__c from Diageo_Product__c]) {
            productToBrandMap.put(dp.Id, dp.Diageo_Brand_Id__c);
        }
            publishRecipe();                    
    }
   
    //Grabbing/getting all the details of the Selected recipe that is already created and displaying the details as Readonly on to the UI
    public Recipe__c getCurrentRecipe() {
            integer cCount = 0;
            integer tCount = 0;
            integer hCount = 0;
            integer oCount = 0;
            attributeImageMap = new map<string,Id>();
            if (recipeId != null )
                currentRecipe = [SELECT Comments__c, lastModifiedTime__c, CreatedById, CreatedDate, IsDeleted,LastActivityDate, LastModifiedById, 
                                        LastModifiedDate, Main_Drink_Image__r.Content_id__c, Main_Drink_Image__c, Main_Drink_Image__r.Name, Language__c,
                                        Master_Recipe__r.Name, Master_Recipe__r.Id, Menu_Description__c, Mobile_Drink_Image__r.Content_Id__c, Occasion__c, Occasion_Type__c, Preparation_Steps__c, 
                                        Recipe_Flavor_del__c, Recipe_Tags__c, Name, Recipe_Type_del__c,Mobile_Selected_Image__c,Mobile_Selected_Image__r.Content_Id__c,
                                        Mobile_Unselected_Image__c,Mobile_Unselected_Image__r.Content_Id__c,Background_Image__c,Background_Image__r.Content_Id__c,
                                        Brand_Recipe_Image__c,Brand_Recipe_Image__r.Content_Id__c,Search_Recipe_Image__c,Search_Recipe_Image__r.Content_Id__c,
                                        Recipe_Version__c, Id,Recipe_Title__c,RecordSaved__c, Short_Description__c, Status__c, SystemModstamp, 
                                        Has_Legal_Approval__c, Additional_Image_1__r.Content_Id__c, Additional_Image_2__r.Content_Id__c, Locale__c,  
                                        Current_Editor__c,reviewedBy__c,approvedBy__c, Additional_Image_5__r.Content_Id__c, (select Id,Name from Attachments)
                                   ,(select id,Recipe__c,Attribute__c,Attribute__r.Attribute_Type__c,Attribute__r.Attribute_Value__c,Attribute__r.Attribute_Value_Image__c,Dynamic_Value__c,Attribute__r.Locale__c from Recipe_Attributes__r) 
                                   ,(select id,Recipe__c,Occasion__c,Occasion__r.Occasion_Type__c,Occasion__r.Name_Of_The_Occasion__c,Occasion__r.Recipe_Occasion_Image__c from Recipe_Occasions__r)
                                   ,(select id,Recipe__c,Recipe_Diageo_Product__r.Name,Recipe_Diageo_Product__r.Diageo_Product_Image__c,Recipe_Diageo_Product__r.Diageo_Product_Image__r.Content_Id__c,Recipe_Non_Diageo_Product__r.Name,Recipe_Non_Diageo_Product__r.Non_Diageo_Ingredient_Image__c,Recipe_Non_Diageo_Product__r.Non_Diageo_Ingredient_Image__r.Content_Id__c,Recipe_Diageo_Product__r.Diageo_Brand_Id__r.Name,Recipe_Diageo_Product__r.Diageo_Brand_Id__r.Brand_Image__c,Recipe_Diageo_Product__r.Diageo_Brand_Id__r.Brand_Image__r.Content_Id__c from Diageo_Ingredients__r)
                                   FROM Recipe__c WHERE Id = :recipeId];
                                   
             list<string>  flavorIdList = new list<string>();
             list<string>  barwareIdList = new list<string>();
             list<string>  drinkIdList = new list<string>();
             list<string>  typeIdList = new list<string>();
             list<string> occasionList = new list<String>();
             list<string> occasionTypeList = new list<String>();
             
             if(currentRecipe != null && !currentRecipe.Recipe_Title__c.contains('temp recipe')) {
                recipeTitle = currentRecipe.Recipe_Title__c;    
             }
             
             //Getting all the Recipe Attributes based on the Respective Attribute Type.
             for(Recipe_Attribute__c rat : currentRecipe.Recipe_Attributes__r) {
                /*By Rishi Khirbat -> T-98032: Updates to MM_RecipeView ********/
                    if (rat.Attribute__r.Attribute_Type__c == 'Color') {
                        selColor = rat.Attribute__c;
                        if(rat.Attribute__r.Locale__c != null)
                            recipeColor = rat.Attribute__r.Attribute_Value__c + ' ('+rat.Attribute__r.Locale__c+')';
                        else
                            recipeColor = rat.Attribute__r.Attribute_Value__c;
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }
                    if (rat.Attribute__r.Attribute_Type__c == 'Effort Level') {
                        selEffort = rat.Attribute__c;
                        if(rat.Attribute__r.Locale__c != null)
                            recipeEffort = rat.Attribute__r.Attribute_Value__c + ' ('+rat.Attribute__r.Locale__c+')';
                        else
                            recipeEffort = rat.Attribute__r.Attribute_Value__c;         
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }
                    if (rat.Attribute__r.Attribute_Type__c == 'Glassware') {
                        selGlassware = rat.Attribute__c;
                        if(rat.Attribute__r.Locale__c != null)
                            recipeGlassware = rat.Attribute__r.Attribute_Value__c+ ' ('+rat.Attribute__r.Locale__c+')';
                        else
                            recipeGlassware = rat.Attribute__r.Attribute_Value__c;
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }
                    if (rat.Attribute__r.Attribute_Type__c == 'Serving Style') {
                        selServing = rat.Attribute__c;
                        if(rat.Attribute__r.Locale__c != null)
                            recipeServing = rat.Attribute__r.Attribute_Value__c+ ' ('+rat.Attribute__r.Locale__c+')';
                        else
                            recipeServing = rat.Attribute__r.Attribute_Value__c;
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }
                    if (rat.Attribute__r.Attribute_Type__c == 'Wine Taste') {
                        selWineTaste = rat.Attribute__c;
                        if(rat.Attribute__r.Locale__c != null)
                            recipeWineTaste = rat.Attribute__r.Attribute_Value__c+ ' ('+rat.Attribute__r.Locale__c+')';
                        else
                            recipeWineTaste = rat.Attribute__r.Attribute_Value__c;
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }
                    if (rat.Attribute__r.Attribute_Type__c == 'Wine Type') {
                        selWineType = rat.Attribute__c;
                        if(rat.Attribute__r.Locale__c != null)
                            recipeWineType = rat.Attribute__r.Attribute_Value__c+ ' ('+rat.Attribute__r.Locale__c+')';
                        else
                            recipeWineType = rat.Attribute__r.Attribute_Value__c;
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }
                    if (rat.Attribute__r.Attribute_Type__c == 'Language') {
                        selLanguage = rat.Attribute__c;
                        if(rat.Attribute__r.Locale__c != null)
                            recipeLanguage = rat.Attribute__r.Attribute_Value__c+ ' ('+rat.Attribute__r.Locale__c+')';
                        else
                            recipeLanguage = rat.Attribute__r.Attribute_Value__c;
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }   
                    
                    if(rat.Attribute__r.Attribute_Type__c == 'Flavor') {
                        if(rat.Attribute__r.Locale__c != null)
                            flavorIdList.add(rat.Attribute__r.Attribute_Value__c+ ' ('+rat.Attribute__r.Locale__c+')');
                        else
                            flavorIdList.add(rat.Attribute__r.Attribute_Value__c);
                        selFlavorIds.add(rat.Attribute__c); 
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }
                    if(rat.Attribute__r.Attribute_Type__c == 'Barware Needed') {
                        if(rat.Attribute__r.Locale__c != null)
                            barwareIdList.add(rat.Attribute__r.Attribute_Value__c+ ' ('+rat.Attribute__r.Locale__c+')');
                        else
                            barwareIdList.add(rat.Attribute__r.Attribute_Value__c);
                        selbarwareIds.add(rat.Attribute__c);    
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }
                    if(rat.Attribute__r.Attribute_Type__c == 'Drink Classification') {
                        if(rat.Attribute__r.Locale__c != null)
                            drinkIdList.add(rat.Attribute__r.Attribute_Value__c+ ' ('+rat.Attribute__r.Locale__c+')');
                        else
                            drinkIdList.add(rat.Attribute__r.Attribute_Value__c);
                        selDrinkIds.add(rat.Attribute__c);  
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }
                    if(rat.Attribute__r.Attribute_Type__c == 'Drink Type') {
                        if(rat.Attribute__r.Locale__c != null)
                            typeIdList.add(rat.Attribute__r.Attribute_Value__c+ ' ('+rat.Attribute__r.Locale__c+')');
                        else
                            typeIdList.add(rat.Attribute__r.Attribute_Value__c);
                        selTypeIds.add(rat.Attribute__c);   
                        if(rat.Attribute__r.Attribute_Value_Image__c != null)
                            attributeImageMap.put(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c,totalAttrImageMap.get(rat.Attribute__r.Attribute_Type__c+' - '+rat.Attribute__r.Attribute_Value__c));
                    }
                    if(rat.Attribute__r.Attribute_Type__c.equals('Description/Overview')) {
                        descriptionOverview = rat.Dynamic_Value__c;
                    }
                    if(rat.Attribute__r.Attribute_Type__c.equals('Recipe Story')) {
                        recipeStory = rat.Dynamic_Value__c;
                    }
                    if(rat.Attribute__r.Attribute_Type__c.equals('Serving Size')) {
                        servingSize = rat.Dynamic_Value__c;
                    }
                    if(rat.Attribute__r.Attribute_Type__c.equals('Food Pairings')) {
                        foodPairings = rat.Dynamic_Value__c;
                    }
                    if(rat.Attribute__r.Attribute_Type__c.equals('Standard Average Analysis')) {
                        standardAverageAnalysis = rat.Dynamic_Value__c;
                    }
                    if(rat.Attribute__r.Attribute_Type__c.equals('Tasting Notes')) {
                        tastingNotes = rat.Dynamic_Value__c;
                    }
                    /***************/               
             }
             
             //Getting all the Recipe Occasions based on the Respective Occasion Type.  
             for(Recipe_Occasion__c rOcc : currentRecipe.Recipe_Occasions__r) {
                    if(rOcc.Occasion__r.Occasion_Type__c == 'Celebrations') {
                        if(cCount<1)
                        occasionTypeList.add(rOcc.Occasion__r.Occasion_Type__c);
                        selCelebration1Ids.add(rOcc.Occasion__c);
                        selCelebration2Ids.add(rOcc.Occasion__c);
                        selCelebration3Ids.add(rOcc.Occasion__c);
                        selCelebration4Ids.add(rOcc.Occasion__c);
                        occasionList.add(rOcc.Occasion__r.Name_Of_The_Occasion__c);
                        if(rOcc.Occasion__r.Recipe_Occasion_Image__c != null)
                        attributeImageMap.put(rOcc.Occasion__r.Occasion_Type__c+' - '+rOcc.Occasion__r.Name_Of_The_Occasion__c,totalAttrImageMap.get(rOcc.Occasion__r.Occasion_Type__c+' - '+rOcc.Occasion__r.Name_Of_The_Occasion__c));
                        cCount++;
                    }
                    if(rOcc.Occasion__r.Occasion_Type__c == 'Theme Parties') {
                        if(tCount<1)
                        occasionTypeList.add(rOcc.Occasion__r.Occasion_Type__c);
                        selThemeParty1Ids.add(rOcc.Occasion__c);
                        selThemeParty2Ids.add(rOcc.Occasion__c);
                        selThemeParty3Ids.add(rOcc.Occasion__c);
                        selThemeParty4Ids.add(rOcc.Occasion__c);
                        occasionList.add(rOcc.Occasion__r.Name_Of_The_Occasion__c);
                        if(rOcc.Occasion__r.Recipe_Occasion_Image__c != null)
                        attributeImageMap.put(rOcc.Occasion__r.Occasion_Type__c+' - '+rOcc.Occasion__r.Name_Of_The_Occasion__c,totalAttrImageMap.get(rOcc.Occasion__r.Occasion_Type__c+' - '+rOcc.Occasion__r.Name_Of_The_Occasion__c));
                        tCount++;
                    }
                    if(rOcc.Occasion__r.Occasion_Type__c == 'Holidays') {
                        if(hCount<1)
                        occasionTypeList.add(rOcc.Occasion__r.Occasion_Type__c);
                        selHoliday1Ids.add(rOcc.Occasion__c);
                        selHoliday2Ids.add(rOcc.Occasion__c);
                        selHoliday3Ids.add(rOcc.Occasion__c);
                        selHoliday4Ids.add(rOcc.Occasion__c);
                        occasionList.add(rOcc.Occasion__r.Name_Of_The_Occasion__c);
                        if(rOcc.Occasion__r.Recipe_Occasion_Image__c != null)
                        attributeImageMap.put(rOcc.Occasion__r.Occasion_Type__c+' - '+rOcc.Occasion__r.Name_Of_The_Occasion__c,totalAttrImageMap.get(rOcc.Occasion__r.Occasion_Type__c+' - '+rOcc.Occasion__r.Name_Of_The_Occasion__c));
                        hCount++;
                    }
                    if(rOcc.Occasion__r.Occasion_Type__c == 'Outdoor Gatherings') {
                        if(oCount<1)
                        occasionTypeList.add(rOcc.Occasion__r.Occasion_Type__c);
                        selOutdoor1Ids.add(rOcc.Occasion__c);
                        selOutdoor2Ids.add(rOcc.Occasion__c);
                        selOutdoor3Ids.add(rOcc.Occasion__c);
                        selOutdoor4Ids.add(rOcc.Occasion__c);
                        occasionList.add(rOcc.Occasion__r.Name_Of_The_Occasion__c);
                        if(rOcc.Occasion__r.Recipe_Occasion_Image__c != null)
                        attributeImageMap.put(rOcc.Occasion__r.Occasion_Type__c+' - '+rOcc.Occasion__r.Name_Of_The_Occasion__c,totalAttrImageMap.get(rOcc.Occasion__r.Occasion_Type__c+' - '+rOcc.Occasion__r.Name_Of_The_Occasion__c));
                        oCount++;
                    }
             }
             
             //Getting all the Recipe Ingredients and its Associated Images. 
             for(Diageo_Ingredient__c dIn : currentRecipe.Diageo_Ingredients__r) {
                    if(dIN.Recipe_Diageo_Product__r.Diageo_Product_Image__c != null) {
                        attributeImageMap.put('DiageoProduct - '+dIN.Recipe_Diageo_Product__r.Name,dIN.Recipe_Diageo_Product__r.Diageo_Product_Image__r.Content_Id__c); 
                    }
                    if(dIN.Recipe_Diageo_Product__r.Diageo_Brand_Id__r.Brand_Image__c != null) {
                        attributeImageMap.put('DiageoBrand - '+dIN.Recipe_Diageo_Product__r.Diageo_Brand_Id__r.Name,dIN.Recipe_Diageo_Product__r.Diageo_Brand_Id__r.Brand_Image__r.Content_Id__c);
                    }
                  if(dIn.Recipe_Non_Diageo_Product__r.Non_Diageo_Ingredient_Image__c != null)   
                        attributeImageMap.put('NonDiageoProduct - '+dIN.Recipe_Non_Diageo_Product__r.Name,dIN.Recipe_Non_Diageo_Product__r.Non_Diageo_Ingredient_Image__r.Content_Id__c);
              }
               sortedImageList = new list<string>();
               
               if(occasionList.size()>0)
                    occasionList.sort();
               if(occasionTypeList.size()>0)
                    occasionTypeList.sort();
                    
                if(!attributeImageMap.isEmpty())    
                    sortedImageList.addAll(attributeImageMap.keySet());
                    
               sortedImageList.sort();
              
               recipeFlavor = MM_Utility.listToString(flavorIdList, ', ');
               /*Modified By Rishi Khirbat -> T-98032:Updates to MM_RecipeView*/
               recipeBarware = MM_Utility.listToString(barwareIdList, ', ');
               recipeDrink = MM_Utility.listToString(drinkIdList, ', ');
               recipeType = MM_Utility.listToString(typeIdList, ', ');
               recipeOccasion = MM_Utility.listToString(occasionList, ', ');
               recipeOccasionType = MM_Utility.listToString(occasionTypeList, ', ');
               /**************/

            if(recipeTitle != null) {
                currentRecipe.Recipe_Title__c = recipeTitle;    
            } else if(currentRecipe.Recipe_Title__c.contains('temp recipe')) {
                  currentRecipe.Recipe_Title__c = 'Enter Recipe Name';
            }
           
            tabIndexDiageoCount = 1;
            tabIndexNonDiageoCount = 1050;
            prepStepsIndexCount = 0;
            
            /*By Rishi Khirbat -> I-39172*/
            selFlavorIds = updateRetainingSelections(selFlavorIds, selCurrFlavorIds);
            selTypeIds = updateRetainingSelections(selTypeIds, selCurrTypeIds);
            selBarwareIds = updateRetainingSelections(selBarwareIds, selCurrBarwareIds);
            selDrinkIds = updateRetainingSelections(selDrinkIds, selCurrDrinkIds);
            
            selCelebration1Ids = updateRetainingSelections(selCelebration1Ids, selCurrCelebration1Ids);
            selCelebration2Ids = updateRetainingSelections(selCelebration2Ids, selCurrCelebration2Ids);
            selCelebration3Ids = updateRetainingSelections(selCelebration3Ids, selCurrCelebration3Ids);
            selCelebration4Ids = updateRetainingSelections(selCelebration4Ids, selCurrCelebration4Ids);
             
            selThemeParty1Ids = updateRetainingSelections(selThemeParty1Ids, selCurrThemeParty1Ids);
            selThemeParty2Ids = updateRetainingSelections(selThemeParty2Ids, selCurrThemeParty2Ids);
            selThemeParty3Ids = updateRetainingSelections(selThemeParty3Ids, selCurrThemeParty3Ids);
            selThemeParty4Ids = updateRetainingSelections(selThemeParty4Ids, selCurrThemeParty4Ids);
            
            selHoliday1Ids = updateRetainingSelections(selHoliday1Ids, selCurrHoliday1Ids);
            selHoliday2Ids = updateRetainingSelections(selHoliday2Ids, selCurrHoliday2Ids);
            selHoliday3Ids = updateRetainingSelections(selHoliday3Ids, selCurrHoliday3Ids);
            selHoliday4Ids = updateRetainingSelections(selHoliday4Ids, selCurrHoliday4Ids);
            
            selOutdoor1Ids = updateRetainingSelections(selOutdoor1Ids, selCurrOutdoor1Ids);
            selOutdoor2Ids = updateRetainingSelections(selOutdoor2Ids, selCurrOutdoor2Ids);
            selOutdoor3Ids = updateRetainingSelections(selOutdoor3Ids, selCurrOutdoor3Ids);
            selOutdoor4Ids = updateRetainingSelections(selOutdoor4Ids, selCurrOutdoor4Ids);
            
            return currentRecipe;
    }
    
    private Id[] updateRetainingSelections(Id[] selIds, set<Id> currSelIds) {
        currSelIds.addAll(selIds);
        selIds = new Id[]{};
        selIds.addAll(currSelIds);
        return selIds;
    }
    
    public Boolean getHasError() {
        
        List<recipeImageWrapper> tmpList = getRecipeImages();
        List<Preparation_Step__c> ps=[ select Id from Preparation_Step__c where Recipe__c =: currentRecipe.Id ];
      
        if (!tmpList.isEmpty() && tmpList.size() > 0 && bCheck() && ps.size()>0 && oneDCheck())
            return true;
        else
            return false;   
    }
    
    public Boolean getHasImages() {
        List<recipeImageWrapper> tmpList = getRecipeImages();
        if (!tmpList.isEmpty() && tmpList.size() > 0)
         return true;
      return false;
    }
    
    public Boolean bCheck() {
        List<Diageo_Ingredient__c> di = getDiageoIngredient();
      for(Diageo_Ingredient__c d: di)
      {
         if(d.Featured_Brand__c)
         {
         return true;
        
         }
         
      }
      return false;
    }
    
    public Boolean oneDCheck() {
        List<Diageo_Ingredient__c> di = [ select Id from Diageo_Ingredient__c where recipe__c =:currentRecipe.Id and Featured_Brand__c = true];
        if(di.size()>1)
        return false;
        else
        return true;
    }
    
    public void addError(String msg)
    {
        if(errorMessage == null)
        {
           errorMessage = 'Error: ';
           errorMessage += msg;
        }
        else
       {
           errorMessage +='; ';
           errorMessage+= msg;
       }
    }
    
    //Method that checks all the Required Elements for a reicpe Before submitting it to a Reviewer.
    public Pagereference checkImg() {
        Boolean brandCheck = false;
        errorMessage=null;
        list<recipeImageWrapper> mainImgcheckList = new list<recipeImageWrapper>();
        List<recipeImageWrapper> tmpList = getRecipeImages();
        
        if(tmpList.isEmpty() ||tmpList.size() <= 0) {
            addError('Image required');
          
        }
        else{
            for(recipeImageWrapper riw :tmpList ) {
                if(riw.imageType == 'Main Drink Image'&& riw.contentId == currentRecipe.Main_Drink_Image__r.content_Id__c)
                    mainImgcheckList.add(riw);
                
            }
        }
        
        if(mainImgcheckList.isEmpty() || mainImgcheckList.size() <=0) {
            addError('Main Drink Image required');
        }
            
        list<Preparation_Step__c> ps=[ select Id from Preparation_Step__c where Recipe__c =: currentRecipe.Id ];
        if(ps.size()<=0 || ps == null)
        { 
             
            addError('Preparation Steps required \r \n');
            
        }
        
        if(!bCheck())
        {
            addError('Featured Diageo Ingredient required \r\n');
            
        }
        if(!oneDCheck())
        {
            addError('Only one Featured Diageo Ingredient allowed');
        }
      return null;
    }
    
    
    //Getting all the Attribute Images on the UI in View mode   
    public list<recipeImageWrapper> getAttributeImages() {
        if (attributeImages == null)
                attributeImages = new List<recipeImageWrapper>();
            else
                attributeImages.clear();
                
        if(sortedImageList.size()>0) {
            
            for(string s:sortedImageList) {
                attributeImages.add(new recipeImageWrapper(s,attributeImageMap.get(s)));
            }
        }
        return attributeImages;
        
    }
    
    //Getting all the  Recipe Images on to the UI 
    public list<recipeImageWrapper> getRecipeImages() {

        try{
            map<id,Id> imageContentMap = new map<Id,Id>();
            if (recipeImages == null)
                recipeImages = new List<recipeImageWrapper>();
            else
                recipeImages.clear();
            
          if (currentRecipe.Main_Drink_Image__c != null) {
            recipeImages.add(new recipeImageWrapper('Main Drink Image',currentRecipe.Main_Drink_Image__r.Content_Id__c));
          }
          if (currentRecipe.Mobile_Drink_Image__c != null) {
            recipeImages.add(new recipeImageWrapper('Mobile Drink Image',currentRecipe.Mobile_Drink_Image__r.Content_Id__c) );
          }
          if (currentRecipe.Mobile_Selected_Image__c != null) {
            recipeImages.add(new recipeImageWrapper('Mobile Selected Image',currentRecipe.Mobile_Selected_Image__r.Content_Id__c)); 
          }      
          if (currentRecipe.Mobile_Unselected_Image__c != null) {
            recipeImages.add(new recipeImageWrapper('Mobile Unselected Image',currentRecipe.Mobile_Unselected_Image__r.Content_Id__c) );
          }
          if (currentRecipe.Background_Image__c != null) {
            recipeImages.add(new recipeImageWrapper('Background Image',currentRecipe.Background_Image__r.Content_Id__c) );
          }
          if (currentRecipe.Brand_Recipe_Image__c != null) {
            recipeImages.add(new recipeImageWrapper('Brand Recipe Image',currentRecipe.Brand_Recipe_Image__r.Content_Id__c) );
          }
          if (currentRecipe.Search_Recipe_Image__c != null) {
            recipeImages.add(new recipeImageWrapper('Search Recipe Image',currentRecipe.Search_Recipe_Image__r.Content_Id__c) );
          }
          if (currentRecipe.Additional_Image_1__c != null) {
            recipeImages.add(new recipeImageWrapper('Additional Recipe Image1',currentRecipe.Additional_Image_1__r.Content_Id__c) );
          }
          if (currentRecipe.Additional_Image_2__c != null) {
            recipeImages.add(new recipeImageWrapper('Additional Recipe Image2',currentRecipe.Additional_Image_2__r.Content_Id__c) );        
          }                             
          if (!recipeImages.isEmpty() && recipeImages.size() > 0 && swapId == null) 
                    swapId = recipeImages[0].contentId;
          }
          catch (DMLException e) {
            String message = e.getMessage();
            system.debug('===========message===============' + message);
            swapId = null;  
          }
        return recipeImages;
    }
    
   //Methods to get the Current State of the System ie, Edit mode/View Mode and also used to display the respective Buttons basesd on the logged in User Role.
    public Boolean getCanEdit() {
        if (currentRecipe != null) {
            
            //I-41400-Recipe Publisher Role unable to create new recipe or clone from existing recipe
            if(isClone || (isCreateNew != null && isCreateNew && getIsPublisher())) {
                canEdit = true;
            }
            
            //T-83190
            if(getIsSuperAdmin()) {
                if(currentRecipe.Current_Editor__c != UserInfo.getUserId()) {
                    canEdit = currentRecipe.Status__c != 'Archive';
                } else {
                    canEdit = (currentRecipe.Status__c == 'Draft' || currentRecipe.Status__c == 'Rejected');
                }
            }
            
            if(getIsEditor()) { ////T-83190 if(getIsEditor() || getIsSuperAdmin()) 
                if(currentRecipe.Current_Editor__c == UserInfo.getUserId()) {
                    canEdit = (currentRecipe.Status__c != 'Pending Approval') && (currentRecipe.Status__c != 'Pending Review')&& (currentRecipe.Status__c != 'Archive');
                } else {
                    canEdit = false;    
                } 
            }
            
            if(getIsReviewer()) {
                if(currentRecipe.Current_Editor__c != UserInfo.getUserId()) {
                    canEdit = (currentRecipe.Status__c != 'Pending Approval') && (currentRecipe.Status__c != 'Rejected');
                 } else{
                    canEdit = currentRecipe.Status__c != 'Pending Approval' && currentRecipe.Status__c != 'Pending Review' ;
                }
            }
            
            if(getIsApprover() || getIsPublisher()) {
                if(currentRecipe.Current_Editor__c != UserInfo.getUserId()) {
                    canEdit = currentRecipe.Status__c != 'Rejected';
                }
                else
                    canEdit = currentRecipe.Status__c != 'Pending Approval' && currentRecipe.Status__c != 'Pending Review';
            }
            
            /*By Rishi Khirbat -> T-105835 - Conditonally Add "Edit Recipe" button on MM_ViewRecipe
            //Update MM_ViewRecipe to display the "Edit Recipe" button for Recipes where Recipe_Status__c = Approved only if the following conditions are
            //met:
            //Current user role = Recipe-Publisher
            //IF Recipe Publisher ALL Published_Recipe__c.Asset__r.Publisher__c where status__c=Published must equal current user, or do not display button.
            */
            if(currentRecipe.Status__c == 'Approved') {
                canEdit = false;
                
                if(getCurrentRole() == RECIPE_PUBLISHER) {
                    for(Published_Recipe__c pRecipe :[Select Digital_Published_Asset__r.Publisher__c From Published_Recipe__c 
                                                        Where Status__c = 'Published'
                                                        And Recipe__c =: currentRecipe.Id]) {
                        if(pRecipe.Digital_Published_Asset__r.Publisher__c == UserInfo.getUserId()) {
                            canEdit = true;     
                        } 
                    }
                } 
            }
            
            //I-47100 - For Draft Recipes, only can be edited by Recipe-Admin or user in Recipe__c.CurrentEditor__c
            if(currentRecipe.Status__c.equals('Draft')) {
                if(getIsSuperAdmin() || currentRecipe.Current_Editor__c == UserInfo.getUserId()) {
                    canEdit = true; 
                } else {
                    canEdit = false;
                }
            }
        } else {
            system.debug('=================canEdit5');
            canEdit = false;
        }
        return canEdit;
    }
    
    //Methods to get the Current State of the System ie, Edit mode/View Mode and also used to display the respective Buttons basesd on the logged in User Role.
    public boolean getCUser() {
                if(currentRecipe.Current_Editor__c != UserInfo.getUserId()) {
                    cUser = false;          
                }
                else
                    cUser = true;
        return cUser;
    }
 
    public boolean getCRevApp() {
        List<Id> ids = MM_Utility.getRecipesByApprover(UserInfo.getUserId());
        
        if(getIsReviewer()) 
        {
            
            for(Id i:ids)
            {
                if(i==currentRecipe.Id)
                {
                    if(currentRecipe.status__c=='Pending Review')
                    return true;
                }
            }
            
        }
        else if (getIsApprover() || getIsSuperAdmin() || getIsPublisher()) //T-83190: else if (getIsApprover())
        {
            for(Id i:ids)
            {
            if(i==currentRecipe.Id)
            {
               //if(currentRecipe.status__c=='Pending Approval') 
               if(currentRecipe.status__c=='Pending Review' || currentRecipe.status__c=='Pending Approval') //T-83188
               return true;
            }
         }
      }      
      return false;
    }
    
    public String getCurrentStep() {
        return currentStep;
    }
     
    //Method that is called when an Image popup is being opened to Asspciate Images to the Respective Recipe.
    //First Saves all the Selected Atributes,Occasions,Ingredients and Preparation steps Entered so as to retrieve them after selecting the Image.
    public PageReference upsertTempRecipe() {
        try{
            currentRecipe.lastModifiedTime__c = currentRecipe.LastModifiedDate;
            saveAttributes();
            saveDiagIng();
            saveNDiagIng();
            savePrepSteps();
            upsert currentRecipe;
        } catch(DMLException e) {
            String message = e.getMessage();
            system.debug('===========message===============' + message);
      }
      return null;
    }
    
   public void setDiageoProductId(String n) {
      diageoProductId = n;
   }
   
   public String getDiageoProductId()
   {
      return   diageoProductId;
         
   }
   
   public void setRecipeId(String n) {
      
      recipeId = n;
      
   }
   
   public String getRecipeId() {
      
      return recipeId;
   }
   
   public void setTemplateId(String n) {
      
      templateId = n;
      
   }
   
   public String getTemplateId() {
      
      return templateId;
   }  
   
   
   //Recipe Image Wrapper
   
   public class recipeImageWrapper{
    public string imageType{get;set;}
    public id contentId{get;set;}
    public recipeImageWrapper(string iType,id CId) {
        this.imageType =iType;
        this.contentId = cId;
    }   
  }
    
   //diageo Ingredeints
   public class dWrapper{
   
   public Diageo_Ingredient__c ingredient {get; set;}
   public string brand { get; set;} 
   public string dProduct {get; set{System.debug('in set');this.dProduct = value;}}
   public integer indexCount{get;set;}
   
   public dWrapper(string b, Diageo_Ingredient__c i,String p, Integer index) {
      this.brand = b;
      this.ingredient = i;
      this.dProduct = p;
      this.indexCount = index;
  }
   
    public List<selectOption> getDiageoProducts() {
      list<Diageo_Product__c> tmpList = [Select Version_Number__c, Units__c, SystemModstamp, Short_Description__c, Name,
       Long_Description__c, LastModifiedDate, LastModifiedById, IsDeleted, Image__c, Id,
        Equivalent_Units__c, Diageo_Brand_Id__c, CreatedDate, CreatedById, Content_ID__c, Content_Display_ID__c, 
        Available__c From Diageo_Product__c 
        where Diageo_Brand_Id__c=: this.brand
        order by Name];
      
      list<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
         for (Diageo_Product__c dp : tmpList) {
            options.add(new selectOption(dp.Id, dp.Name));
         } 
         if(options.size()>0)
         {
           options.add(0,new selectOption('select','-Select-'));
         }
     return options;     
   }  
 }
   //Wrapper that holds all the Diageo Ingredients .Creates five Rows Upon Opening the Page to enter the Diageo Ingredients for the Recipe.
   public List<dWrapper> diagIng{
      
      get{
         if(diagIng == null)
         {
         diagIng = new List<dWrapper>();
         for( Diageo_Ingredient__c d: [ select Id,Recipe_Brand__c,Ingredient_Number__c,Units__c,Non_Diageo_Product_Units__c,Ingredient_Unit__c,Recipe_Diageo_Product__c,Featured_Brand__c, Recipe_Diageo_Product__r.Name,Recipe_Diageo_Product__r.Diageo_Brand_Id__c,  Quantity__c
         from Diageo_Ingredient__c 
         where Recipe__c=: currentRecipe.Id and Recipe_Diageo_Product__c <> null
         order by Ingredient_Number__c
         ])
         {
            if(d.Ingredient_Number__c == null)
               d.Ingredient_Number__c = diagIng.size()+1;
            diagIng.add( new dWrapper(d.Recipe_Brand__c,d,d.Recipe_Diageo_Product__c,10+((diagIng.size()+1)*(diagIng.size()+1)*(diagIng.size()+1))+10));
            system.debug('==diagIng=1==='+diagIng.size());
         }
         
         if( diagIng != null && diagIng.size() > 0 )
         {
          if(diagIng.size() == 5)
          return diagIng;
          else
          {
          for(Integer i=diagIng.size();i<5;i++)
          {
            diagIng.add(new dWrapper(null,new Diageo_Ingredient__c(Recipe__c = currentRecipe.Id, Ingredient_Number__c = i+1),null,((diagIng.size()+1)*(diagIng.size()+1)*(diagIng.size()+1))+10));
            system.debug('==diagIng=2==='+diagIng.size());
          }
          return diagIng;
          }
         
         }
         else
          {
            diagIng = new List<dWrapper>();
            for( Integer i=0; i<5;i++)
            {  
               diagIng.add(new dWrapper(null,new Diageo_Ingredient__c(Recipe__c = currentRecipe.Id, Ingredient_Number__c = i+1),null,((diagIng.size()+1)*(diagIng.size()+1)*(diagIng.size()+1))+10));
               system.debug('==diagIng=3==='+diagIng.size());
            }
            return diagIng;
          }
         }
         else 
           return diagIng;
      }
      
      set {
        this.diagIng = value;
      }
   }
   
   public void addADiagIng() {
      
      diagIng.add(new dWrapper(null,new Diageo_Ingredient__c(Recipe__c = currentRecipe.Id, Ingredient_Number__c =diagIng.size()+1 ),null,((diagIng.size()+1)*(diagIng.size()+1)*(diagIng.size()+1))+10));
      system.debug('==diagIng=4==='+diagIng.size());
   }
   
  //Saves all the Entered Diageo Ingredients with the Current Reicpe Id. 
   public void saveDiagIng() {
      errorMsg = 0;
      List<Diageo_Ingredient__c> di = new List<Diageo_Ingredient__c>();
      ApexPages.Message myMsg;
       system.debug('==diagIng=5==='+diagIng.size());
      for(Integer i=0; i< diagIng.size(); i++)
      {
        System.debug('Recipe diageo product in save'+diagIng[i].dProduct);
         if(diagIng[i].dProduct == null)
         {
            
             
         }
         else if(diagIng[i].dProduct =='select')
         {
            errorMsg = 1;
            addError('please add diageo product');
            return;
         }
         else
         {
          diagIng[i].ingredient.Recipe_Diageo_Product__c = diagIng[i].dProduct;
          if(diagIng[i].Ingredient.Units__c != 'None' && diagIng[i].Ingredient.Quantity__c != 'None')
          {
            diagIng[i].Ingredient.recipe_brand__c = diagIng[i].brand;
            di.add(diagIng[i].ingredient);
          }
          else
          {
            errorMsg = 1;
            if(diagIng[i].Ingredient.Units__c == 'None' )
            addError('Unit required for Diageo Products\n');
            else
            addError('Quantity required for Diageo Products');
              
            return;
          }
         }
      }
      
      try{
        upsert di;
      } catch(Exception e) {
         String message = e.getMessage();
        system.debug('===========message===============' + message);
      }
   }
   
  //Deletes the Respective Diageo Ingrediet ROw using Ingredient Number.
   public PageReference deleteDiagIng() {
      Integer diageoIng = Integer.valueOf(ApexPages.currentPage().getParameters().get('ing'));
      List<Diageo_Ingredient__c> ddel = [ Select Id, Ingredient_Number__c from Diageo_Ingredient__c where Recipe__c =: currentRecipe.Id and Ingredient_Number__c =: diageoIng ];
      if(ddel.size() > 0)
      {
      delete ddel;
      List<Diageo_Ingredient__c> dList = [ Select Id, Ingredient_Number__c from Diageo_Ingredient__c where Recipe__c =: currentRecipe.Id
        AND Ingredient_Number__c >: ddel.get(0).Ingredient_Number__c];
      for(Diageo_Ingredient__c p: dList)
         p.Ingredient_Number__c = p.Ingredient_Number__c - 1;
      if(dList!=null && dList.size()>0)
      update dList;
      }
      
      
      for(Integer i=0;i < diagIng.size(); i++)
      {
         if(diagIng[i].ingredient.Ingredient_Number__c == diageoIng)
         {
            diagIng.remove(i);
            break;
         }
       } 
     for(Integer i=0;i < diagIng.size(); i++)
      {
         if(diagIng[i].ingredient.Ingredient_Number__c > diageoIng)
         {
            diagIng[i].ingredient.Ingredient_Number__c-=1;
            
         }
       } 
       if(diagIng.size()<5) {
       diagIng.add(new dWrapper(null,new Diageo_Ingredient__c(Recipe__c = currentRecipe.Id, Ingredient_Number__c =diagIng.size()+1 ),null,((diagIng.size()+1)*(diagIng.size()+1)*(diagIng.size()+1))+10)); 
       
       }
     return null;
   }
   
  //non diageo Ingredeints
  
  public class ndWrapper{
    public Diageo_Ingredient__c nd {get; set;}
    public string unit { get; set;} 
    public string customUnit { get; set;}
    public string ingredient { get; set;}
    public string customIng { get; set; }
    public boolean showI {get; set;}
    public boolean showU {get; set;}
    public integer nonIndexCount{get;set;}
    public ndWrapper(string i, Diageo_Ingredient__c n,Integer index) {
        this.ingredient = i;
        this.nd = n;
        this.showI = false;
        this.showU = false;
        this.nonIndexCount = index;
    }
    
    public void setU(Boolean t) {
        this.showU = t;
    }
    
    public void setI(Boolean t) {
      this.showI = t;
   }
  }
   
   //Method that is being Called to Add a New Custom Ingredient which is not present in the DropDown to the Recipe.
   public Pagereference showUnit() {
    String st = ApexPages.currentPage().getParameters().get('step');
    if(st == null)
    return null;
    
    Integer s = Integer.valueOf(st);
    String f = ApexPages.currentPage().getParameters().get('field');
    for(Integer i=0;i < nondiagIng.size(); i++)
      {
         if(nondiagIng[i].nd.Ingredient_Number__c == s )
         {
            
            if(f=='ingredient')
            {
                if(nondiagIng[i].ingredient == 'custom')
                nondiagIng[i].setI(true);
                else
                 nondiagIng[i].setI(false);
                break;
            }
         }
       } 
    return null;
   }
   
    //Wrapper that Cretaes Non Diageo Ingredient Rows to enter the NonDiageo/Custom Ingredients.
    public List<ndWrapper> nonDiagIng {
        get {
            if(nonDiagIng == null) {
                nonDiagIng = new List<ndWrapper>();
                for(Diageo_Ingredient__c nt: [ select Id,Ingredient_Number__c,Units__c,Non_Diageo_Product_Units__c,Ingredient_Unit__c,Recipe_Non_Diageo_Product__c, Quantity__c
                                                from Diageo_Ingredient__c 
                                                where Recipe__c=: currentRecipe.Id and Recipe_Non_Diageo_Product__c <> null
                                                order by Ingredient_Number__c]) {
                    
                    if(nt.Ingredient_Number__c == null)
                        nt.Ingredient_Number__c = nonDiagIng.size()+1;
                    nonDiagIng.add(new ndWrapper(nt.Recipe_Non_Diageo_Product__c,nt,((nonDiagIng.size()+1)*(nonDiagIng.size()+1)*(nonDiagIng.size()+1))+1000));
                }
                
                if( nondiagIng != null && nonDiagIng.size() > 0 ) {
                    if(nonDiagIng.size() >= 5)
                        return nonDiagIng;
                    else {
                        for(Integer i=nonDiagIng.size();i<5;i++) {
                            nonDiagIng.add(new ndWrapper(null,new Diageo_Ingredient__c(Recipe__c = currentRecipe.Id, Ingredient_Number__c = i+1),((nonDiagIng.size()+1)*(nonDiagIng.size()+1)*(nonDiagIng.size()+1))+1000));
                        }
                        return nonDiagIng;
                    }
                } else {
                    nonDiagIng = new List<ndWrapper>();
                    for( Integer i=0; i<5;i++) {  
                        nonDiagIng.add(new ndWrapper(null,new Diageo_Ingredient__c(Recipe__c = currentRecipe.Id, Ingredient_Number__c = i+1),((nonDiagIng.size()+1)*(nonDiagIng.size()+1)*(nonDiagIng.size()+1))+1000));
                    }
                    return nonDiagIng;
                }
            } else {
                return nonDiagIng;
            }
        }
        set;
    }
   
    public void addANDiagIng() {
        nonDiagIng.add(new ndWrapper(null,new Diageo_Ingredient__c(Recipe__c = currentRecipe.Id, Ingredient_Number__c =nonDiagIng.size()+1 ),((nonDiagIng.size()+1)*(nonDiagIng.size()+1)*(nonDiagIng.size()+1))+1000));
    }
   
    //Saves all the Entered NonDiageo Ingredients with the Current Reicpe Id.
    public void saveNDiagIng() {
        List<Diageo_Ingredient__c> ntemp = new List<Diageo_Ingredient__c>();
        List<Diageo_Ingredient__c> t = new List<Diageo_Ingredient__c>();
        for(Integer i=0; i< nonDiagIng.size(); i++) {
            if(nonDiagIng[i].ingredient != null && nonDiagIng[i].ingredient != 'None') {
                if(nonDiagIng[i].nd.Quantity__c == 'None') {
                    errorMsg=1;
                    addError('Quantity required for Other Diageo Products\n');   
                    return; 
                }
                
                if(nonDiagIng[i].ingredient == 'custom') {
                    if(nonDiagIng[i].customIng != '' && nonDiagIng[i].customIng != null ) {
                        set<string> nt = new set<string>();
                        for(Recipe_Non_Diageo_Product__c rn:[Select Name From Recipe_Non_Diageo_Product__c order by Name]) {
                            nt.add(rn.name);
                        }
                        if(!nt.contains(nonDiagIng[i].customIng)) {
                            String loc = null;
                            if(selLocaleIngredientsFilter != null && !selLocaleIngredientsFilter.trim().equals('-None-')) {
                                loc = selLocaleIngredientsFilter;
                            }
                            Recipe_Non_Diageo_Product__c rn = new Recipe_Non_Diageo_Product__c(
                                                                            Name = nonDiagIng[i].customIng,
                                                                            Locale__c = loc);
                            insert rn;
                            nonDiagIng[i].nd.Recipe_Non_Diageo_Product__c = rn.Id;
                        } else {
                            nonDiagIng[i].nd.Recipe_Non_Diageo_Product__c = [ select Id from  Recipe_Non_Diageo_Product__c where Name =: nonDiagIng[i].customIng].Id;
                        }
                    } else {
                        nonDiagIng[i].nd.Recipe_Non_Diageo_Product__c = null;
                    } 
                } else {
                    if(nonDiagIng[i].ingredient != 'none')
                        nonDiagIng[i].nd.Recipe_Non_Diageo_Product__c = nonDiagIng[i].ingredient;
                    else {
                        if(nonDiagIng[i].nd.id!=null)
                        t.add(nonDiagIng[i].nd);
                    }
                }
            }  
        }
        
        for(Integer i=0; i< nonDiagIng.size(); i++) {
            if(nonDiagIng[i].nd.Recipe_Non_Diageo_Product__c == null || nonDiagIng[i].ingredient == 'none') {
            } else {
                ntemp.add(nonDiagIng[i].nd);    
            }
        }
         
        try {
            delete t;
            upsert ntemp;
            
        } catch(Exception e) {
            String message = e.getMessage();
            system.debug('===========message===============' + message);
        }
    }
   
   //Deletes the Respective NonDiageo/custom Ingredient Row based on Ingredient Number.
   public PageReference deleteNonDiagIng() {
      Integer ndiageoIng = Integer.valueOf(ApexPages.currentPage().getParameters().get('ing'));
      List<Diageo_Ingredient__c> nddel = [ Select Id, Ingredient_Number__c from Diageo_Ingredient__c where Recipe__c =: currentRecipe.Id and Ingredient_Number__c =: ndiageoIng ];
      if(nddel.size() > 0)
      {
      delete nddel;
      List<Diageo_Ingredient__c> ndList = [ Select Id, Ingredient_Number__c from Diageo_Ingredient__c where Recipe__c =: currentRecipe.Id
        AND Ingredient_Number__c >: nddel.get(0).Ingredient_Number__c];
      for(Diageo_Ingredient__c p: ndList)
         p.Ingredient_Number__c = p.Ingredient_Number__c - 1;
      if(ndList!=null && ndList.size()>0)
      update ndList;
      }
      
      
      for(Integer i=0;i < nonDiagIng.size(); i++)
      {
         if(nonDiagIng[i].nd.Ingredient_Number__c == ndiageoIng)
         {
            nonDiagIng.remove(i);
            break;
         }
       } 
    for(Integer i=0;i < nonDiagIng.size(); i++)
      {
         if(nonDiagIng[i].nd.Ingredient_Number__c > ndiageoIng)
         {
            nonDiagIng[i].nd.Ingredient_Number__c-=1;
           
         }
       } 
       if(nonDiagIng.size()<5)
       nonDiagIng.add(new ndWrapper(null,new Diageo_Ingredient__c(Recipe__c = currentRecipe.Id, Ingredient_Number__c =nonDiagIng.size()+1 ),((nonDiagIng.size()+1)*(nonDiagIng.size()+1)*(nonDiagIng.size()+1))+1000));
  
     return null;
   }
   
   
  // preparation step
   public void showPopupPrep() {    
        displayPrep = true;
   } 
   
  //Displays the Preparation steps 
   public List<Preparation_Step__c> prepSteps{
    
    get{
        if(prepSteps == null)
        {
        prepSteps=[ select Id, Description__c, Step_Number__c 
         from Preparation_Step__c 
         where Recipe__c=: currentRecipe.Id
         order by Step_Number__c ];
         if( prepSteps != null && prepSteps.size() > 0 )
         {
          if(prepSteps.size() == 5)
          return prepSteps;
          else
          {
          for(Integer i=prepSteps.size();i<5;i++)
          {
            prepSteps.add(new Preparation_Step__c(Step_Number__c= i+1, Recipe__c = currentRecipe.Id));
          }
          return prepSteps;
          }
         }
         else
          {
            prepSteps = new List<Preparation_Step__c>();
            for( Integer i=0; i<5;i++)
            {  
                prepSteps.add(new Preparation_Step__c(Step_Number__c= i+1, Recipe__c = currentRecipe.Id));
            }
            return prepSteps;
          }
        }
        else 
          return prepSteps;
    }
    
    set;
   }
   
   public void addAStep() {
    
    prepSteps.add(new Preparation_Step__c(Step_Number__c = prepSteps.size()+1, Recipe__c = currentRecipe.Id));
   }
   
    //Saves all the Entered Preparation steps with the Current Reicpe Id.
    public void savePrepSteps() {
        List<Preparation_Step__c> ptemp = new List<Preparation_Step__c>();
        for(Integer i=0; i< prepSteps.size(); i++) {
            if(prepSteps[i].description__c == null || prepSteps[i].Description__c == '') {
                List<Preparation_Step__c> pt = [ Select Id, Step_Number__c from Preparation_Step__c where Recipe__c =: currentRecipe.Id and Step_Number__c =: prepSteps[i].step_number__c ];
                if(pt != null)
                    delete pt;
            } else
                ptemp.add(prepSteps[i]);
        }
      
        for(Integer i=0; i< ptemp.size(); i++) {
            ptemp[i].Step_Number__c=i+1;
        }
        
        try {
            upsert ptemp;
        
            List<Preparation_Step__c> pdel = [ Select Id from Preparation_Step__c where Recipe__c =:currentRecipe.Id and Description__c = null ];
            delete pdel;
        
        } catch(Exception e) {
            String message = e.getMessage();
            system.debug('===========message===============' + message);
        }
   }
   
   //Deletes the Selected Preparation step based on Step Number.
   public void deletePreparationStep() {
      preparationStep = Integer.valueOf(ApexPages.currentPage().getParameters().get('pStep'));
      List<Preparation_Step__c> pdel = [ Select Id, Step_Number__c from Preparation_Step__c where Recipe__c =: currentRecipe.Id and Step_Number__c =: preparationStep ];
      if(pdel.size() > 0)
      {
      delete pdel;
      List<Preparation_Step__c> pList = [ Select Id, Step_Number__c from Preparation_Step__c where Recipe__c =: currentRecipe.Id
        AND Step_Number__c >: pdel.get(0).Step_Number__c];
      for(Preparation_Step__c p: pList)
         p.Step_Number__c = p.Step_Number__c - 1;
      if(pList!=null && pList.size()>0)
      update pList;
      }
      
      
      for(Integer i=0;i < prepSteps.size(); i++)
      {
        if(prepSteps[i].Step_Number__c == preparationStep)
        {
            prepSteps.remove(i);
           break;
        }
       } 
      for(Integer i=0;i < prepSteps.size(); i++)
      {
         if(prepSteps[i].Step_Number__c > preparationStep)
         {
            prepSteps[i].Step_Number__c-=1;
            
         }
       } 
      if(prepSteps.size()<5)
      prepSteps.add(new Preparation_Step__c(Step_Number__c = prepSteps.size()+1, Recipe__c = currentRecipe.Id));
   }
   
   //Methods that perform the Move Up and Move down Functionality for a preparation Step.Preparationsteps can be reordered after entering.
   
   public void moveUp()
   {
    preparationStep = Integer.valueOf(ApexPages.currentPage().getParameters().get('pStep'));
    String temp;
      for(Integer i=0;i < prepSteps.size(); i++)
      {
         if(prepSteps[i].Step_Number__c == preparationStep)
         {
            temp = prepSteps[i-1].description__c;
            prepSteps[i-1].description__c = prepSteps[i].description__c;
            prepSteps[i].description__c = temp;
            break;
         }
       } 
      
   }
   
   //Methods that perform the Move Up and Move down Functionality for a preparation Step.Preparationsteps can be reordered after entering.
    public void movedown()
   {
      preparationStep = Integer.valueOf(ApexPages.currentPage().getParameters().get('pStep'));
      String temp;
      for(Integer i=0;i < prepSteps.size(); i++)
      {
         if(prepSteps[i].Step_Number__c == preparationStep)
         {
            temp = prepSteps[i+1].description__c;
            prepSteps[i+1].description__c = prepSteps[i].description__c;
            prepSteps[i].description__c = temp;
            break;
         }
       } 
      
   }
   
   //Getting all the Diageo Brands to display on to the Diageo Ingredients section.
   public List<selectOption> getDiageoBrands() {
      
      List<Diageo_Brand__c> tmpList = [SELECT Available__c, Brand_Category__c, CreatedById, CreatedDate, IsDeleted, Name, LastModifiedById, LastModifiedDate, Long_Description__c, OwnerId, Id, Short_Description__c, SystemModstamp FROM Diageo_Brand__c Order by Name];
      
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

         options.add(new selectOption('None', ''));

         for (Diageo_Brand__c db : tmpList) {
            options.add(new selectOption(db.Id, db.Name));
         }
         
         return options;
      
   }
   
   //Getting the list of all available Reviewers to select for submitting a Recipe.
   //T-83195:  An Editor that Submits the recipe can Not choose himself as the Reviewer
   public List<selectOption> getReviewerList() {
      Id currentUser = UserInfo.getUserId();
      //List<User> tmpList = [SELECT Id, Name FROM User WHERE UserRole.Name = 'Reviewer' and isActive =true];
      List<User> tmpList = [SELECT Id, Name FROM User 
                            WHERE Id <>: currentUser //AND UserRole.Name =: RECIPE_REVIEWER and isActive =true];
                            AND ( UserRole.Name =: RECIPE_PUBLISHER
                                  OR UserRole.Name =: RECIPE_APPORVER
                                  OR UserRole.Name =: RECIPE_ADMIN ) 
                            and isActive =true];
      
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

         for (User u : tmpList) {
            if(currentRecipe.Current_Editor__c != u.Id && currentRecipe.CreatedById != u.Id)
            options.add(new selectOption(u.Id, u.Name));
         }
         
         return options;
      
   }
   
   //Getting the list of all Reviewers to Reassign by the current Reviewer.
   public List<selectOption> getReviewerReassignList() {
      Id currentUser = UserInfo.getUserId();
      //List<User> tmpList = [SELECT Id, Name FROM User WHERE UserRole.Name = 'Reviewer' and isActive =true];
      List<User> tmpList = [SELECT Id, Name FROM User WHERE Id <>: currentUser AND UserRole.Name =: RECIPE_REVIEWER and isActive =true];
      
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

         for (User u : tmpList) {
            if(currentRecipe.Current_Editor__c != u.Id  && currentRecipe.CreatedById != u.Id) //&& currentRecipe.reviewedBy__c != u.Id
            options.add(new selectOption(u.Id, u.Name));
         }
         
         return options;
      
   }
  
   //Getting the List of all Editors to Reassign a Reicpe that is created by a User but unable to submit it.
   public List<selectOption> getEditorList() {
      Id currentUser = UserInfo.getUserId();
      //List<User> tmpList = [SELECT Id, Name FROM User WHERE UserRole.Name = 'Editor'];
      List<User> tmpList = [SELECT Id, Name FROM User WHERE Id <>: currentUser AND  UserRole.Name =: RECIPE_EDITOR];
      
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

         for (User u : tmpList) {
            if(currentRecipe.Current_Editor__c != u.Id && currentRecipe.CreatedById != u.Id)
            options.add(new selectOption(u.Id, u.Name));
         }
         
         return options;
      
   }     
   
   //Getting the list of all available Approvers to select for Approving a Recipe.
   public List<selectOption> getApproverList() {
      Id currentUser = UserInfo.getUserId();
      //List<User> tmpList = [SELECT Id, Name FROM User WHERE UserRole.Name = 'Approver'];
      List<User> tmpList = [SELECT Id, Name FROM User 
                              WHERE Id <>: currentUser 
                              AND (UserRole.Name =: RECIPE_APPORVER 
                                    OR UserRole.Name =: RECIPE_ADMIN
                                    OR UserRole.Name =: RECIPE_PUBLISHER
                                    )];
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

         for (User u : tmpList) {
            if(currentRecipe.Current_Editor__c != u.Id  && currentRecipe.CreatedById != u.Id) {
                options.add(new selectOption(u.Id, u.Name));
            }   
         }
         
         return options;
      
   }    
   
    //Getting the list of all Approvers to Reassign by the current Approver.
   public List<selectOption> getApproverReassignList() {
      Id currentUser = UserInfo.getUserId();
      //List<User> tmpList = [SELECT Id, Name FROM User WHERE UserRole.Name = 'Approver'];
      List<User> tmpList = [SELECT Id, Name FROM User WHERE Id <>: currentUser AND  UserRole.Name =: RECIPE_APPORVER];
      
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

         for (User u : tmpList) {
            if(currentRecipe.Current_Editor__c != u.Id  && currentRecipe.CreatedById != u.Id) //&& currentRecipe.approvedBy__c != u.Id
            options.add(new selectOption(u.Id, u.Name));
         }
         
         return options;
      
   }    
   
   //T-83190: While review/apporve, Admin user can reassign to any other admin 
    //Getting the list of all Admin users to Reassign by the current admin user.
   public List<selectOption> getAdminReassignList() {
      Id currentUser = UserInfo.getUserId();
      //List<User> tmpList = [SELECT Id, Name FROM User WHERE UserRole.Name = 'Approver'];
      List<User> tmpList = [SELECT Id, Name FROM User WHERE Id <>: currentUser AND  UserRole.Name =: RECIPE_ADMIN];
      
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

         for (User u : tmpList) {
          if(currentRecipe.Current_Editor__c != u.Id   && currentRecipe.CreatedById != u.Id) //&& currentRecipe.approvedBy__c != u.Id
            options.add(new selectOption(u.Id, u.Name));
         }
         
         return options;
      
   }     
   
   //Getting the list of all Users to Reassign a Recipe that is created by the current Administrator.
   public List<selectOption> getAllUserList() {
      Id currentUser = UserInfo.getUserId();
      //List<User> tmpList = [SELECT Id, Name FROM User where IsActive =: true];
      List<User> tmpList = [SELECT Id, Name FROM User where Id <>: currentUser AND IsActive =: true];
      
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

         for (User u : tmpList) {
            if(currentRecipe.Current_Editor__c != u.Id && currentRecipe.CreatedById != u.Id)
            options.add(new selectOption(u.Id, u.Name));
         }
         
         return options;
      
   }  
   
  
   public List<selectOption> getAllUserReassignList() {
      Id currentUser = UserInfo.getUserId();
      //List<User> tmpList = [SELECT Id, Name FROM User where IsActive =: true];
      List<User> tmpList = [SELECT Id, Name FROM User where Id <>: currentUser AND IsActive =: true];
      
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
         for (User u : tmpList) {
            if(currentRecipe.Current_Editor__c != u.Id && currentRecipe.CreatedById != u.Id) //currentRecipe.approvedBy__c != u.Id && 
            options.add(new selectOption(u.Id, u.Name));
         }
         
         return options;
      
   }  
   
   public Pagereference sBrand() { 
     return null;
   }

   //Getting all the Diageo Products Associated with the current Brand.
   public List<selectOption> getDiageoProducts() {
      
      List<Diageo_Product__c> tmpList = [Select Version_Number__c, Units__c, SystemModstamp, Short_Description__c, Name,
       Long_Description__c, LastModifiedDate, LastModifiedById, IsDeleted, Image__c, Id,
        Equivalent_Units__c, Diageo_Brand_Id__c, CreatedDate, CreatedById, Content_ID__c, Content_Display_ID__c, 
        Available__c From Diageo_Product__c 
        where Diageo_Brand_Id__c=: brand
        order by Name];
      
      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

         for (Diageo_Product__c dp : tmpList) {
            options.add(new selectOption(dp.Id, dp.Name));
         }
         brand='';
         return options;
      
   }  
   
    //Recipe_Non_Diageo_Product__c
    map<Id,String> mapIdIngredientName = new map<Id,String>();
    public List<selectOption> getNonDiageoProducts() {
        
        List<Recipe_Non_Diageo_Product__c> tmpList;
        if(selLocaleIngredientsFilter == null || selLocaleIngredientsFilter.trim().equals('-None-')) {
            tmpList = [Select SystemModstamp, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById, Available__c From Recipe_Non_Diageo_Product__c order by Name]; 
        } else {
            tmpList = [Select SystemModstamp, Name, LastModifiedDate, LastModifiedById, IsDeleted, Id, CreatedDate, CreatedById, Available__c From Recipe_Non_Diageo_Product__c Where Locale__c =:selLocaleIngredientsFilter order by Name];
        }
        
        set<Id> ingredientIds = new set<Id>();
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('none',''));
        options.add(new selectOption('custom','-Add Custom Ingredient-'));
        for (Recipe_Non_Diageo_Product__c dp : tmpList) {
            options.add(new selectOption(dp.Id, dp.Name));
            mapIdIngredientName.put(dp.Id,dp.Name);
            ingredientIds.add(dp.Id);
        }
        
        if(nondiagIng != null && nondiagIng.size() > 0) {
            for(ndWrapper ndw :nondiagIng){ 
                if(ndw.Ingredient != null && !ndw.Ingredient.equals('none') && !ndw.Ingredient.equals('custom')){
                    if(!ingredientIds.contains(ndw.Ingredient) && mapIdIngredientName.get(ndw.Ingredient) != null) {
                        options.add(new selectOption(ndw.Ingredient, mapIdIngredientName.get(ndw.Ingredient))); 
                    }
                }
            }
        }
        return options;
    }
   
   public User getRecipeCreator() {
      return recipeCreator;
   }
   
  //Converts an Archived Recipe to Draft Mode. 
   public pageReference saveArchiveRecipe() {
    if(currentRecipe.Status__c == 'Archive') {
        currentRecipe.Status__c = 'Draft';
        currentRecipe.Current_Editor__c = UserInfo.getUserId();
    }
    update currentRecipe;
    PageReference pageRef = new PageReference('/apex/MM_RecipeView?recipeId=' + recipeId + '&editMode=true');
    pageRef.setRedirect(true);
    return pageRef;
    
   }
   
    //Method that Creates/Upserts already created Recipe when all the required elements are filled in
    public PageReference saveRecipe() {
        system.debug('===========saveRecipe============');
        errorMessage=null;
        if(currentRecipe.Recipe_Title__c == 'Enter Recipe Name'||currentREcipe.Recipe_Title__c == null ||currentRecipe.Recipe_Title__c=='') {
            addError('Recipe name required');     
            return null;
        } else {
            try {
                if (currentRecipe.Master_Recipe__c == null) {
                    Master_Recipe__c master = new Master_Recipe__c();
                    master.Name = currentRecipe.Recipe_Title__c;
                    insert master;
                    currentRecipe.Master_Recipe__c = master.Id;
                } else {
                    Master_Recipe__c mtemp = [ select Name from Master_Recipe__c where Id=: currentRecipe.Master_Recipe__c];
                    update mtemp;
                }
                saveAttributes();
                saveDiagIng();
                saveNDiagIng();
                savePrepSteps();
                if(errorMsg != 1) {
                    currentRecipe.recordSaved__c = true;
                    currentRecipe.lastModifiedTime__c = system.now();
                    integer val = updateRecipe();
                    if(val == 0) {
                        editMode = false;
                        submitMode = true;
      
                        if (recipeId == null)
                            recipeId = currentRecipe.Id;
                                   
                        PageReference pageRef1 = new PageReference('/apex/MM_RecipeView?recipeId=' + recipeId);
                        pageRef1.setRedirect(true);
                        return pageRef1;
                    } else {
                        return null;
                    }
                } else {
                    return null;
                }
            } catch(Exception e) {
                String message = e.getMessage();
                system.debug('===========message===============' + message);
            }
        }
        return null;
    }
   
    public integer updateRecipe() {
        try {
            system.debug('===========currentRecipe============' + currentRecipe);
            if(currentRecipe.Status__c.equals('Approved') && getIsSuperAdmin()) {
                currentRecipe.Edit_Notification_To_Publisher__c = true;
            }
            upsert currentRecipe;
        } catch(Exception e) {
            String s = e.getMessage();
            system.debug('===========message===============' + s);
            if(s != '' && s.length()>0) {
                addError('This Recipe Name already exists for this Locale.');
                //currentRecipe.Recipe_Title__c = '';
            }
            return 1;
        }
        return 0;
    }
   
    //Getting all the Flavor Ids that are being selected
    public Id[] selFlavorIds = new Id[]{};
    set<Id> selCurrFlavorIds = new set<Id>();
    set<Id> selShowFlavorIds = new set<Id>();
   
    public id[] getSelFlavorIds() {
        return selFlavorIds;
    }

    public void setSelFlavorIds(Id[] selFlavorIds) {
        this.selFlavorIds = selFlavorIds;
    }
    
    //Getting all the Barware Needed Ids that are being selected
    public Id[] selBarwareIds = new Id[]{};
    public set<Id> selCurrBarwareIds = new set<Id>();
    public set<Id> selShowBarwareIds = new set<Id>();
   
    public id[] getSelBarwareIds() {
        return selBarwareIds;
    }

    public void setSelBarwareIds(Id[] selBarwareIds) {
        this.selBarwareIds = selBarwareIds;
    }
    
    //Getting all the Drink Needed Ids that are being selected
    public Id[] selDrinkIds = new Id[]{};
    public set<Id> selCurrDrinkIds = new set<Id>();
    public set<Id> selShowDrinkIds = new set<Id>();
   
    public id[] getSelDrinkIds() {
        return selDrinkIds;
    }

    public void setSelDrinkIds(Id[] selDrinkIds) {
        this.selDrinkIds = selDrinkIds;
    }
    
    //Getting all the Type Ids that are being selected 
    public Id[] selTypeIds = new Id[]{};
    public set<Id> selCurrTypeIds = new set<Id>();
    public set<Id> selShowTypeIds = new set<Id>();
   
    public id[] getSelTypeIds() {
        return selTypeIds;
    }

    public void setSelTypeIds(Id[] selTypeIds) {
        this.selTypeIds = selTypeIds;
    }
  
    //getting & setting the Selected Celebration Ids
    public Id[] selCelebration1Ids = new Id[]{};
    public set<Id> selCurrCelebration1Ids = new set<Id>();
    public set<Id> selShowCelebration1Ids = new set<Id>();
   
    public id[] getSelCelebration1Ids() {
        return selCelebration1Ids;
    }

    public void setSelCelebration1Ids(Id[] selCelebration1Ids) {
        this.selCelebration1Ids = selCelebration1Ids;
    }
    
    public Id[] selCelebration2Ids = new Id[]{};
    public set<Id> selCurrCelebration2Ids = new set<Id>();
    public set<Id> selShowCelebration2Ids = new set<Id>();
   
    public id[] getSelCelebration2Ids() {
        return selCelebration2Ids;
    }

    public void setSelCelebration2Ids(Id[] selCelebration2Ids) {
        this.selCelebration2Ids = selCelebration2Ids;
    }
    
   public Id[] selCelebration3Ids = new Id[]{};
   public set<Id> selCurrCelebration3Ids = new set<Id>();
    public set<Id> selShowCelebration3Ids = new set<Id>();
   
   public id[] getSelCelebration3Ids() {
        return selCelebration3Ids;
    }

    public void setSelCelebration3Ids(Id[] selCelebration3Ids) {
        this.selCelebration3Ids = selCelebration3Ids;
    }
    
    public Id[] selCelebration4Ids = new Id[]{};
    public set<Id> selCurrCelebration4Ids = new set<Id>();
    public set<Id> selShowCelebration4Ids = new set<Id>();
   
    public id[] getSelCelebration4Ids() {
        return selCelebration4Ids;
    }

    public void setSelCelebration4Ids(Id[] selCelebration4Ids) {
        this.selCelebration4Ids = selCelebration4Ids;
    }
    
    //Getting & setting  all the Selected ThemeParty Ids
    public Id[] selThemeParty1Ids = new Id[]{};
    public set<Id> selCurrThemeParty1Ids = new set<Id>();
    public set<Id> selShowThemeParty1Ids = new set<Id>();
    
    public id[] getSelThemeParty1Ids() {
        return selThemeParty1Ids;
    }

    public void setSelThemeParty1Ids(Id[] selThemeParty1Ids) {
        this.selThemeParty1Ids = selThemeParty1Ids;
    }
    
    public Id[] selThemeParty2Ids = new Id[]{};
    public set<Id> selCurrThemeParty2Ids = new set<Id>();
    public set<Id> selShowThemeParty2Ids = new set<Id>();
   
    public id[] getSelThemeParty2Ids() {
        return selThemeParty2Ids;
    }

    public void setSelThemeParty2Ids(Id[] selThemeParty2Ids) {
        this.selThemeParty2Ids = selThemeParty2Ids;
    }
    
    public Id[] selThemeParty3Ids = new Id[]{};
    public set<Id> selCurrThemeParty3Ids = new set<Id>();
    public set<Id> selShowThemeParty3Ids = new set<Id>();
   
    public id[] getSelThemeParty3Ids() {
        return selThemeParty3Ids;
    }

    public void setSelThemeParty3Ids(Id[] selThemeParty3Ids) {
        this.selThemeParty3Ids = selThemeParty3Ids;
    }
    
    public Id[] selThemeParty4Ids = new Id[]{};
    public set<Id> selCurrThemeParty4Ids = new set<Id>();
    public set<Id> selShowThemeParty4Ids = new set<Id>();
   
    public id[] getSelThemeParty4Ids() {
        return selThemeParty4Ids;
    }

    public void setSelThemeParty4Ids(Id[] selThemeParty4Ids) {
        this.selThemeParty4Ids = selThemeParty4Ids;
    }
    
    //Gettiing all the Selected Holidays Ids
    public Id[] selHoliday1Ids = new Id[]{};
    public set<Id> selCurrHoliday1Ids = new set<Id>();
    public set<Id> selShowHoliday1Ids = new set<Id>();
   
    public id[] getSelHoliday1Ids() {
        return selHoliday1Ids;
    }

    public void setSelHoliday1Ids(Id[] selHoliday1Ids) {
        this.selHoliday1Ids = selHoliday1Ids;
    }
    
    public Id[] selHoliday2Ids = new Id[]{};
    public set<Id> selCurrHoliday2Ids = new set<Id>();
    public set<Id> selShowHoliday2Ids = new set<Id>();
   
    public id[] getSelHoliday2Ids() {
        return selHoliday2Ids;
    }

    public void setSelHoliday2Ids(Id[] selHoliday2Ids) {
        this.selHoliday2Ids = selHoliday2Ids;
    }
    
    public Id[] selHoliday3Ids = new Id[]{};
    public set<Id> selCurrHoliday3Ids = new set<Id>();
    public set<Id> selShowHoliday3Ids = new set<Id>();
   
    public id[] getSelHoliday3Ids() {
        return selHoliday3Ids;
    }

    public void setSelHoliday3Ids(Id[] selHoliday3Ids) {
        this.selHoliday3Ids = selHoliday3Ids;
    }
    
    public Id[] selHoliday4Ids = new Id[]{};
    public set<Id> selCurrHoliday4Ids = new set<Id>();
    public set<Id> selShowHoliday4Ids = new set<Id>();
   
    public id[] getSelHoliday4Ids() {
        return selHoliday4Ids;
    }

    public void setSelHoliday4Ids(Id[] selHoliday4Ids) {
        this.selHoliday4Ids = selHoliday4Ids;
    }
  
  
    //Getting & setting  all the Selected Outdoor Gatherings Ids  
    public Id[] selOutdoor1Ids = new Id[]{};
    public set<Id> selCurrOutdoor1Ids = new set<Id>();
    public set<Id> selShowOutdoor1Ids = new set<Id>();
   
    public id[] getSelOutdoor1Ids() {
        return selOutdoor1Ids;
    }

    public void setSelOutdoor1Ids(Id[] selOutdoor1Ids) {
        this.selOutdoor1Ids = selOutdoor1Ids;
    }   
  
    public Id[] selOutdoor2Ids = new Id[]{};
    public set<Id> selCurrOutdoor2Ids = new set<Id>();
    public set<Id> selShowOutdoor2Ids = new set<Id>();
   
    public id[] getSelOutdoor2Ids() {
        return selOutdoor2Ids;
    }

    public void setSelOutdoor2Ids(Id[] selOutdoor2Ids) {
        this.selOutdoor2Ids = selOutdoor2Ids;
    }  
    
    public Id[] selOutdoor3Ids = new Id[]{};
    public set<Id> selCurrOutdoor3Ids = new set<Id>();
    public set<Id> selShowOutdoor3Ids = new set<Id>();
   
    public id[] getSelOutdoor3Ids() {
        return selOutdoor3Ids;
    }

    public void setSelOutdoor3Ids(Id[] selOutdoor3Ids) {
        this.selOutdoor3Ids = selOutdoor3Ids;
    }  
    
    public Id[] selOutdoor4Ids = new Id[]{};
    public set<Id> selCurrOutdoor4Ids = new set<Id>();
    public set<Id> selShowOutdoor4Ids = new set<Id>();
   
    public id[] getSelOutdoor4Ids() {
        return selOutdoor4Ids;
    }

    public void setSelOutdoor4Ids(Id[] selOutdoor4Ids) {
        this.selOutdoor4Ids = selOutdoor4Ids;
    }  
  
    //Saving all the Selected Attributes to the Recipe and deleting the Unselected ones that were previously Selected
    public void saveAttributes() {
        set<Id> selFlvrIdSet = new set<Id>();
        set<Id> selBarwIdSet = new set<Id>();
        set<Id> selDrnkIdSet = new set<Id>();
        set<Id> selTypeIdSet = new set<Id>();
        set<Id> selOccasionIdSet = new set<Id>();
        
        for(Id flavr :selFlavorIds) {
            if(flavr != null)
                selFlvrIdSet.add(flavr);    
        }
    
        for(Id barw :selBarwareIds) {
            if(barw != null)
                selBarwIdSet.add(barw); 
        }
    
        for(Id drnk :selDrinkIds) {
            if(drnk != null)
                selDrnkIdSet.add(drnk); 
        }
    
        for(Id typ : selTypeIds) {
            if(typ != null)
                selTypeIdSet.add(typ);  
        }
    
        if(selCelebration1Ids.size() > 0)
            selOccasionIdSet.addAll(selCelebration1Ids);
        if(selCelebration2Ids.size()>0)
            selOccasionIdSet.addAll(selCelebration2Ids);
        if(selCelebration3Ids.size()>0)
            selOccasionIdSet.addAll(selCelebration3Ids);
        if(selCelebration4Ids.size()>0)
            selOccasionIdSet.addAll(selCelebration4Ids);
        if(selThemeParty1Ids.size()>0)
            selOccasionIdSet.addAll(selThemeParty1Ids);
        if(selThemeParty2Ids.size()>0)
            selOccasionIdSet.addAll(selThemeParty2Ids); 
        if(selThemeParty3Ids.size()>0)
            selOccasionIdSet.addAll(selThemeParty3Ids);
        if(selThemeParty4Ids.size()>0)
            selOccasionIdSet.addAll(selThemeParty4Ids);
        if(selHoliday1Ids.size()>0)
            selOccasionIdSet.addAll(selHoliday1Ids);
        if(selHoliday2Ids.size()>0)
            selOccasionIdSet.addAll(selHoliday2Ids);
        if(selHoliday3Ids.size()>0)
            selOccasionIdSet.addAll(selHoliday3Ids);
        if(selHoliday4Ids.size()>0)
            selOccasionIdSet.addAll(selHoliday4Ids);
        if(selOutdoor1Ids.size()>0)
            selOccasionIdSet.addAll(selOutdoor1Ids);    
        if(selOutdoor2Ids.size()>0)
            selOccasionIdSet.addAll(selOutdoor2Ids);
        if(selOutdoor3Ids.size()>0)
            selOccasionIdSet.addAll(selOutdoor3Ids);
        if(selOutdoor4Ids.size()>0)
            selOccasionIdSet.addAll(selOutdoor4Ids);
    
        list<Recipe_Attribute__c> recAttributeList = [select id,Recipe__c,Attribute__c,Attribute__r.Attribute_Type__c,Attribute__r.Attribute_Value__c from Recipe_Attribute__c where Recipe__c =:currentRecipe.Id];
        list<Recipe_Attribute__c> colorList = new list<Recipe_Attribute__c>();
        list<Recipe_Attribute__c> effortList = new list<Recipe_Attribute__c>();
        list<Recipe_Attribute__c> glasswareList = new list<Recipe_Attribute__c>();
        list<Recipe_Attribute__c> servingList = new list<Recipe_Attribute__c>();
        list<Recipe_Attribute__c> wineTasteList = new list<Recipe_Attribute__c>();
        list<Recipe_Attribute__c> wineTypeList = new list<Recipe_Attribute__c>();
        list<Recipe_Attribute__c> languageList = new list<Recipe_Attribute__c>();
        set<Id> flavorList = new set<Id>();
        set<Id> barwareList = new set<Id>();
        set<Id> drinkList = new set<Id>();
        set<Id> typeList = new set<Id>();
        set<Id> occasionList = new set<id>();
    
        list<Recipe_Attribute__c> insertList = new list<Recipe_Attribute__c>();
        list<Recipe_Attribute__c> deleteList = new list<Recipe_Attribute__c>();
        list<Recipe_Occasion__c> insertOccList = new list<Recipe_Occasion__c>();
        list<Recipe_Occasion__c> deleteOccList = new list<Recipe_Occasion__c>();
    
        map<id,Recipe_Attribute__c> flavorRecpAttrMap = new map<Id,Recipe_Attribute__c>();
        map<id,Recipe_Attribute__c> barwareRecpAttrMap = new map<Id,Recipe_Attribute__c>();
        map<id,Recipe_Attribute__c> drinkRecpAttrMap = new map<Id,Recipe_Attribute__c>();
        map<id,Recipe_Attribute__c> typeRecpAttrMap = new map<Id,Recipe_Attribute__c>();
        map<id,Recipe_Occasion__c> occasionRecOccsnMap = new map<Id,Recipe_Occasion__c>();
    
        if(recAttributeList != null && recAttributeList.size()>0) {
            for(Recipe_Attribute__c ratr : recAttributeList) {  
                if(ratr.Attribute__r.Attribute_Type__c == 'Color') {
                    colorList.add(ratr);            
                }
                if(ratr.Attribute__r.Attribute_Type__c == 'Effort Level') {
                    effortList.add(ratr);           
                }
                if(ratr.Attribute__r.Attribute_Type__c == 'Glassware') {
                    glasswareList.add(ratr);            
                }
                if(ratr.Attribute__r.Attribute_Type__c == 'Serving Style') {
                    servingList.add(ratr);          
                }
                if(ratr.Attribute__r.Attribute_Type__c == 'Wine Taste') {
                    wineTasteList.add(ratr);            
                }
                if(ratr.Attribute__r.Attribute_Type__c == 'Wine Type') {
                    wineTypeList.add(ratr);         
                }
                if(ratr.Attribute__r.Attribute_Type__c == 'Language') {
                    languageList.add(ratr);         
                }
                if(ratr.Attribute__r.Attribute_Type__c == 'Flavor') {
                    flavorList.add(ratr.Attribute__c);
                    flavorRecpAttrMap.put(ratr.Attribute__c,ratr);
                }
                if(ratr.Attribute__r.Attribute_Type__c == 'Barware Needed') {
                    barwareList.add(ratr.Attribute__c);
                    barwareRecpAttrMap.put(ratr.Attribute__c,ratr);
                }
                if(ratr.Attribute__r.Attribute_Type__c == 'Drink Classification') {
                    drinkList.add(ratr.Attribute__c);
                    drinkRecpAttrMap.put(ratr.Attribute__c,ratr);
                }
                if(ratr.Attribute__r.Attribute_Type__c == 'Drink Type') {
                    typeList.add(ratr.Attribute__c);
                    typeRecpAttrMap.put(ratr.Attribute__c,ratr);
                }
            }
        }   
    
        list<Recipe_Occasion__c> recOccasionsList = [select id,Occasion__r.Occasion_Type__c , Occasion__r.Name_Of_The_Occasion__c from Recipe_Occasion__c where recipe__c =: currentRecipe.Id];
        if(recOccasionsList.size()>0) {
            for(Recipe_Occasion__c recOcc : recOccasionsList) {
                occasionList.add(recOcc.Occasion__c);
                occasionRecOccsnMap.put(recOcc.Occasion__c,recOcc);
            }
        }
 
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(colorList.isEmpty()) {
            if(selColor != null) {
                Recipe_Attribute__c recAttrColor = new Recipe_Attribute__c();
                recAttrColor.Attribute__c = selColor;
                recAttrColor.Recipe__c = currentRecipe.Id;
                insertList.add(recAttrColor);
            }
        } else if(colorList != null && !colorList.isEmpty()) {
            for(Recipe_Attribute__c recAttrClr : colorList) {
                if((selColor != null && recAttrClr.Attribute__c != selColor) || (selColor == null)) {
                    deleteList.add(recAttrClr);
                    if(selColor != null) {
                        Recipe_Attribute__c recAttrColorNew = new Recipe_Attribute__c();
                        recAttrColorNew.Attribute__c = selColor;
                        recAttrColorNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrColorNew);            
                    }
                }   
            }
        }
    
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(effortList.isEmpty()) {
            if(selEffort != null) {
                Recipe_Attribute__c recAttrEffort = new Recipe_Attribute__c();
                recAttrEffort.Attribute__c = selEffort;
                recAttrEffort.Recipe__c = currentRecipe.Id;
                insertList.add(recAttrEffort);
            }
        } else if(effortList != null && !effortList.isEmpty()) {
            for(Recipe_Attribute__c recAttrClr : effortList) {
                if((selEffort != null && recAttrClr.Attribute__c != selEffort) || (selEffort == null)) {
                    deleteList.add(recAttrClr);
                    if(selEffort != null) {
                        Recipe_Attribute__c recAttrEffortNew = new Recipe_Attribute__c();
                        recAttrEffortNew.Attribute__c = selEffort;
                        recAttrEffortNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrEffortNew);           
                    }
                }   
            }
        }
    
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(glasswareList.isEmpty()) {
            if(selGlassware != null) {
                Recipe_Attribute__c recAttrGlassware = new Recipe_Attribute__c();
                recAttrGlassware.Attribute__c = selGlassware;
                recAttrGlassware.Recipe__c = currentRecipe.Id;
                insertList.add(recAttrGlassware);
            }
        } else if(glasswareList != null && !glasswareList.isEmpty()) {
            for(Recipe_Attribute__c recAttrClr : glasswareList) {
                if((selGlassware != null && recAttrClr.Attribute__c != selGlassware) || (selGlassware == null)) {
                    deleteList.add(recAttrClr);
                    if(selGlassware != null) {
                        Recipe_Attribute__c recAttrGlasswareNew = new Recipe_Attribute__c();
                        recAttrGlasswareNew.Attribute__c = selGlassware;
                        recAttrGlasswareNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrGlasswareNew);            
                    }
                }   
            }
        }
    
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(servingList.isEmpty()) {
            if(selServing != null) {
                Recipe_Attribute__c recAttrServing = new Recipe_Attribute__c();
                recAttrServing.Attribute__c = selServing;
                recAttrServing.Recipe__c = currentRecipe.Id;
                insertList.add(recAttrServing);
            }
        } else if(servingList != null && !servingList.isEmpty()) {
            for(Recipe_Attribute__c recAttrClr : servingList) {
                if((selServing != null && recAttrClr.Attribute__c != selServing) || (selServing == null)) {
                    deleteList.add(recAttrClr);
                    if(selServing != null) {
                        Recipe_Attribute__c recAttrServingNew = new Recipe_Attribute__c();
                        recAttrServingNew.Attribute__c = selServing;
                        recAttrServingNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrServingNew);          
                    }
                }   
            }
        }
    
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(wineTasteList.isEmpty()) {
            if(selWineTaste != null) {
                Recipe_Attribute__c recAttrWineTaste = new Recipe_Attribute__c();
                recAttrWineTaste.Attribute__c = selWineTaste;
                recAttrWineTaste.Recipe__c = currentRecipe.Id;
                insertList.add(recAttrWineTaste);
            }
        } else if(wineTasteList != null && !wineTasteList.isEmpty()) {
            for(Recipe_Attribute__c recAttrClr : WineTasteList) {
                if((selWineTaste != null && recAttrClr.Attribute__c != selWineTaste) || (selWineTaste == null)) {
                    deleteList.add(recAttrClr);
                    if(selWineTaste != null) {
                        Recipe_Attribute__c recAttrWineTasteNew = new Recipe_Attribute__c();
                        recAttrWineTasteNew.Attribute__c = selWineTaste;
                        recAttrWineTasteNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrWineTasteNew);            
                    }
                }   
            }
        }
    
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(wineTypeList.isEmpty()) {
            if(selWineType != null) {
                Recipe_Attribute__c recAttrWineType = new Recipe_Attribute__c();
                recAttrWineType.Attribute__c = selWineType;
                recAttrWineType.Recipe__c = currentRecipe.Id;
                insertList.add(recAttrWineType);
            }
        } else if(wineTypeList != null && !wineTypeList.isEmpty()) {
            for(Recipe_Attribute__c recAttrClr : WineTypeList) {
                if((selWineType != null && recAttrClr.Attribute__c != selWineType) || (selWineType == null)) {
                    deleteList.add(recAttrClr);
                    if(selWineType != null) {
                        Recipe_Attribute__c recAttrWineTypeNew = new Recipe_Attribute__c();
                        recAttrWineTypeNew.Attribute__c = selWineType;
                        recAttrWineTypeNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrWineTypeNew);         
                    }
                }   
            }
        }
    
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(languageList.isEmpty()) {
            if(selLanguage != null) {
                Recipe_Attribute__c recAttrLanguage = new Recipe_Attribute__c();
                recAttrLanguage.Attribute__c = selLanguage;
                recAttrLanguage.Recipe__c = currentRecipe.Id;
                insertList.add(recAttrLanguage);
            }
        } else if(!languageList.isEmpty()) {
            for(Recipe_Attribute__c recAttrLang : languageList) {
                if((selLanguage != null && recAttrLang.Attribute__c != selLanguage)) {
                    deleteList.add(recAttrLang);
                    if(selLanguage != null) {
                        Recipe_Attribute__c recAttrLanguageNew = new Recipe_Attribute__c();
                        recAttrLanguageNew.Attribute__c = selLanguage;
                        recAttrLanguageNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrLanguageNew);
                    }
                }   
            }   
        }
    
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(flavorList.isEmpty()) {
            if(selFlvrIdSet != null && selFlvrIdSet.size() > 0) {
                for(Id flvr : selFlvrIdSet) {
                    Recipe_Attribute__c recAttrFlavor = new Recipe_Attribute__c();
                    recAttrFlavor.Attribute__c = flvr;
                    recAttrFlavor.Recipe__c = currentRecipe.Id;
                    insertList.add(recAttrFlavor);
                }
            }
        } else {
            if(selFlvrIdSet == null || selFlvrIdSet.size() == 0) {
                deleteList.addAll(flavorRecpAttrMap.values());
            } else {
                for(Id fl : flavorList) {
                    if(!selFlvrIdSet.contains(fl)) {
                        deleteList.add(flavorRecpAttrMap.get(fl));
                        flavorList.remove(fl);
                    }
                }
                for(Id sel : selFlvrIdSet) {
                    if(!flavorList.contains(sel)) {
                        Recipe_Attribute__c recAttrFlavorNew = new Recipe_Attribute__c();
                        recAttrFlavorNew.Attribute__c = sel;
                        recAttrFlavorNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrFlavorNew);
                    }
                }   
            }               
        }
    
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(barwareList.isEmpty()) {
            if(selBarwIdSet != null && selBarwIdSet.size() > 0) {
                for(Id barw : selBarwIdSet) {
                    Recipe_Attribute__c recAttrBarware = new Recipe_Attribute__c();
                    recAttrBarware.Attribute__c = barw;
                    recAttrBarware.Recipe__c = currentRecipe.Id;
                    insertList.add(recAttrBarware);
                }
            }
        } else {
            if(selBarwIdSet == null || selBarwIdSet.size() == 0) {
                deleteList.addAll(barwareRecpAttrMap.values());
            } else {
                for(Id barw : barwareList) {
                    if(!selBarwIdSet.contains(barw)) {
                        deleteList.add(barwareRecpAttrMap.get(barw));
                        barwareList.remove(barw);
                    }
                }
                for(Id sel : selBarwIdSet) {
                    if(!barwareList.contains(sel)) {
                        Recipe_Attribute__c recAttrBarwareNew = new Recipe_Attribute__c();
                        recAttrBarwareNew.Attribute__c = sel;
                        recAttrBarwareNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrBarwareNew);
                    }
                }   
            }               
        }
    
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(drinkList.isEmpty()) {
            if(selDrnkIdSet != null && selDrnkIdSet.size() > 0) {
                for(Id drnk : selDrnkIdSet) {
                    Recipe_Attribute__c recAttrDrink = new Recipe_Attribute__c();
                    recAttrDrink.Attribute__c = drnk;
                    recAttrDrink.Recipe__c = currentRecipe.Id;
                    insertList.add(recAttrDrink);
                }
            }
        } else {
            if(selDrnkIdSet == null || selDrnkIdSet.size() == 0) {
                deleteList.addAll(drinkRecpAttrMap.values());
            } else {
                for(Id drnk : drinkList) {
                    if(!selDrnkIdSet.contains(drnk)) {
                        deleteList.add(drinkRecpAttrMap.get(drnk));
                        drinkList.remove(drnk);
                    }
                }
                for(Id sel : selDrnkIdSet) {
                    if(!drinkList.contains(sel)) {
                        Recipe_Attribute__c recAttrDrinkNew = new Recipe_Attribute__c();
                        recAttrDrinkNew.Attribute__c = sel;
                        recAttrDrinkNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrDrinkNew);
                    }
                }   
            }               
        }
    
        //Inserts the Newly seleted ones and deletes unselected ones.
        if(typeList.isEmpty()) {
            if(selTypeIdSet != null && selTypeIdSet.size() > 0) {
                for(Id typ : selTypeIdSet) {
                    Recipe_Attribute__c recAttrType = new Recipe_Attribute__c();
                    recAttrType.Attribute__c = typ;
                    recAttrType.Recipe__c = currentRecipe.Id;
                    insertList.add(recAttrType);
                }
            }
        } else {
            if(selTypeIdSet == null || selTypeIdSet.size() == 0) {
                deleteList.addAll(typeRecpAttrMap.values());
            } else {
                for(Id typ : typeList) {
                    if(!selTypeIdSet.contains(typ)) {
                        deleteList.add(typeRecpAttrMap.get(typ));
                        typeList.remove(typ);
                    }
                }
                for(Id sel : selTypeIdSet) {
                    if(!typeList.contains(sel)) {
                        Recipe_Attribute__c recAttrTypeNew = new Recipe_Attribute__c();
                        recAttrTypeNew.Attribute__c = sel;
                        recAttrTypeNew.Recipe__c = currentRecipe.Id;
                        insertList.add(recAttrTypeNew);
                    }
                }   
            }               
        }

        //inserts the Newly seleted Occasions and deletes unselected ones.
        if(occasionList.isEmpty()) {
            if(selOccasionIdSet != null && selOccasionIdSet.size()>0) {
                for(Id recOcc : selOccasionIdSet) {
                    Recipe_Occasion__c recAttrOcc = new Recipe_Occasion__c();
                    recAttrOcc.Occasion__c = recOcc;
                    recAttrOcc.Recipe__c = currentRecipe.Id;
                    insertOccList.add(recAttrOcc);
                }
            }
        }
        
        if(!occasionList.isEmpty()) {
            if(selOccasionIdSet == null || selOccasionIdSet.size() == 0 ) {
                deleteOccList.addAll(occasionRecOccsnMap.values());
            } else {
                for(Id occ : occasionList) {
                    if(selOccasionIdSet.size() > 0 && selOccasionIdSet != null) {
                        if(!selOccasionIdSet.contains(occ)) {
                            deleteOccList.add(occasionRecOccsnMap.get(occ));
                            occasionList.remove(occ);
                        }
                    }
                }
                
                for(Id sOcc : selOccasionIdSet) {
                    if(!occasionList.contains(sOcc)) {
                        Recipe_Occasion__c recAttrOccNew = new Recipe_Occasion__c();
                        recAttrOccNew.Occasion__c = sOcc;
                        recAttrOccNew.Recipe__c = currentRecipe.Id;
                        insertOccList.add(recAttrOccNew);
                    }
                }
            }
        }
        
        /*By Rishi Khirbat -> T-98032: Updates to MM_RecipeView
        //Add the following items to Details as text boxes. When the user enters a value and saves the recipe, 
        //create a Recipe_Attribute__c junction object using where the Attribute__c.Attribute_Type__c maps to the name of the field. 
        //Save the value entered in the textbox in Recipe_Attribute__c.Dynamic_Value__c.
        */
        map<String,Id> mapTypeAttributeIds = new map<String,Id>();
        set<String> setAttributeTypes = new set<String>();
        setAttributeTypes.add('Description/Overview');
        setAttributeTypes.add('Recipe Story');
        //setAttributeTypes.add('Servings');
        setAttributeTypes.add('Serving Size');
        setAttributeTypes.add('Food Pairings');
        setAttributeTypes.add('Standard Average Analysis');
        setAttributeTypes.add('Tasting Notes');
        
        for(Attribute__c att :[Select Id, Attribute_Type__c From Attribute__c Where Attribute_Type__c IN :setAttributeTypes]) {
            mapTypeAttributeIds.put(att.Attribute_Type__c, att.Id);
        }
        
        //Description/Overview - textbox
        if(descriptionOverview != null && descriptionOverview.trim() != '' && mapTypeAttributeIds.get('Description/Overview') != null) {
            Recipe_Attribute__c recRecAttrNew = new Recipe_Attribute__c();
            recRecAttrNew.Attribute__c = mapTypeAttributeIds.get('Description/Overview');
            recRecAttrNew.Recipe__c = currentRecipe.Id;
            recRecAttrNew.Dynamic_Value__c = descriptionOverview;
            insertList.add(recRecAttrNew);
        }
        //Recipe Story - textbox
        if(recipeStory != null && recipeStory.trim() != '' && mapTypeAttributeIds.get('Recipe Story') != null) {
            Recipe_Attribute__c recRecAttrNew = new Recipe_Attribute__c();
            recRecAttrNew.Attribute__c = mapTypeAttributeIds.get('Recipe Story');
            recRecAttrNew.Recipe__c = currentRecipe.Id;
            recRecAttrNew.Dynamic_Value__c = recipeStory;
            insertList.add(recRecAttrNew);
        }
        //Serving Size - textbox
        if(servingSize != null && servingSize.trim() != '' && mapTypeAttributeIds.get('Serving Size') != null) {
            Recipe_Attribute__c recRecAttrNew = new Recipe_Attribute__c();
            recRecAttrNew.Attribute__c = mapTypeAttributeIds.get('Serving Size');
            recRecAttrNew.Recipe__c = currentRecipe.Id;
            recRecAttrNew.Dynamic_Value__c = servingSize;
            insertList.add(recRecAttrNew);
        }
        //Food Pairings - textbox
        if(foodPairings != null && foodPairings.trim() != '' && mapTypeAttributeIds.get('Food Pairings') != null) {
            Recipe_Attribute__c recRecAttrNew = new Recipe_Attribute__c();
            recRecAttrNew.Attribute__c = mapTypeAttributeIds.get('Food Pairings');
            recRecAttrNew.Recipe__c = currentRecipe.Id;
            recRecAttrNew.Dynamic_Value__c = foodPairings;
            insertList.add(recRecAttrNew);
        }
        //Standard Average Analysis - textbox
        if(standardAverageAnalysis != null && standardAverageAnalysis.trim() != '' && mapTypeAttributeIds.get('Standard Average Analysis') != null) {
            Recipe_Attribute__c recRecAttrNew = new Recipe_Attribute__c();
            recRecAttrNew.Attribute__c = mapTypeAttributeIds.get('Standard Average Analysis');
            recRecAttrNew.Recipe__c = currentRecipe.Id;
            recRecAttrNew.Dynamic_Value__c = standardAverageAnalysis;
            insertList.add(recRecAttrNew);
        }
        //Tasting Notes - textbox
        if(tastingNotes != null && tastingNotes.trim() != '' && mapTypeAttributeIds.get('Tasting Notes') != null) {
            Recipe_Attribute__c recRecAttrNew = new Recipe_Attribute__c();
            recRecAttrNew.Attribute__c = mapTypeAttributeIds.get('Tasting Notes');
            recRecAttrNew.Recipe__c = currentRecipe.Id;
            recRecAttrNew.Dynamic_Value__c = tastingNotes;
            insertList.add(recRecAttrNew);
        }
        /**********/
        
        try {
            if(insertList.size() > 0) {
                system.debug('===========insertList===============');
                insert insertList;
            }
            if(deleteList.size() > 0) {
                system.debug('===========deleteList===============');
                delete deleteList;
            }
            if(insertOccList.size() > 0) {
                system.debug('===========insertOccList===============');
                insert insertOccList;
            }
            if(deleteOccList.size() > 0) {
                system.debug('===========deleteOccList===============');
                delete deleteOccList;
            }
        } catch (Exception e) {
            String message = e.getMessage();
            system.debug('===========message===============' + message);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,message));
        }                   
    }
            
   public PageReference editRecipe() {
      editMode = true;
      PageReference pageRef = new PageReference('/apex/MM_RecipeView?recipeId=' + recipeId + '&editMode=true');
      pageRef.setRedirect(true);
      return pageRef;
   }
   
    //Method That is being called when a Reviewer/Approver Rejects a Recipe.
    public PageReference rejectRecipe() {
        
        System.debug('currentCOmments should not be null: ' + currentComment);
        
        if (currentRecipe.Comments__c != null)
            currentRecipe.Comments__c = currentRecipe.Comments__c + '<br/><br/>' + System.now().format('MM/dd/yy h:mm a') + ' - ' + getCurrentUser().Name + ' <b>Rejected</b> the Recipe.<br/>&nbsp;&nbsp;&nbsp;&nbsp;<b>Comments:</b>  ' + currentRejectComment;
        else
            currentRecipe.Comments__c = System.now().format('MM/dd/yy h:mm a') + ' - ' + getCurrentUser().Name + ' <b>Rejected</b> the Recipe.<br/>&nbsp;&nbsp;&nbsp;&nbsp;<b>Comments:</b>  ' + currentRejectComment;
        
        update currentRecipe;
        Boolean success = processApproval('Reject');        
        PageReference pageRef = new PageReference('/apex/MM_RecipeView?recipeId=' + recipeId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    //Processes Approval on Pending Recipe Submissions
    public PageReference approveRecipe() {
        if (currentRecipe.Has_Legal_Approval__c) {
            if (currentRecipe.Comments__c != null)
                currentRecipe.Comments__c = currentRecipe.Comments__c + '<br/><br/>' + System.now().format('MM/dd/yy h:mm a') + ' - ' + getCurrentUser().Name + ' <b>Approved</b> the Recipe.<br/>&nbsp;&nbsp;&nbsp;&nbsp;<b>Comments:</b>  ' + currentComment;
            else
                currentRecipe.Comments__c = System.now().format('MM/dd/yy h:mm a') + ' - ' + getCurrentUser().Name + ' <b>Approved</b> the Recipe.<br/>&nbsp;&nbsp;&nbsp;&nbsp;<b>Comments:</b>  ' + currentComment;
            
            update currentRecipe;
            Boolean success = processApproval('Approve');
            PageReference pageRef = new PageReference('/apex/MM_RecipeView?recipeId=' + recipeId);
            pageRef.setRedirect(true);      
            return pageRef; 
            
        }
        else{
            
            addError('Legal Approval Required.');
            return null;
        }
    }
    
    public PageReference displayCustom() {
        showCustom = true;
        return null;
    }


    //Process APproval Method That is being called when a Recipe Passes the First Submission Action.
    public Boolean processApproval(String status) {

        Boolean success = false;
        List<ProcessInstanceWorkitem> processWorkItems = new List<ProcessInstanceWorkitem>();
        
        try{
            
            currentRecipe.approvedBy__c = selectedApprover;

            upsert currentRecipe;
            
            processWorkItems = MM_Utility.getProcessWorkItemsByRecipe(currentRecipe.Id);
            System.debug('currentRecipe, processWorkItems '+ currentRecipe.Id + ', ' + processWorkItems);
            if (!processWorkItems.isEmpty() && processWorkItems.size() > 0) {
                
                System.debug('selectedApprover: ' + selectedApprover);
                Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
                req3.setAction(status);
                
                req3.setNextApproverIds(new Id[] {selectedApprover});
        
                // Use the ID from the newly created item to specify the item to be worked 
                req3.setWorkitemId(processWorkItems[0].Id);
                
                // Submit the request for approval 
                Approval.ProcessResult result2 =  Approval.process(req3);
                
                success = result2.isSuccess();
                System.debug('currentRecipe and success? ' + currentRecipe.Id + ', ' + success);
            }
                
        }  catch (Exception e) {
            String message = e.getMessage();
            system.debug('===========message===============' + message);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,message));
        }   
        
        return success; 
        
        
    }
    
    //Method that is Callesd when Reassign needs to happen
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
  
        if (!processInstances.isEmpty() && processInstances.size() > 0) {
           for (ProcessInstance pi: processInstances) {
              pis.add(pi.Id);
           }
        }     
        
        //Get the Work Items related to the current Approval
        processWorkItems = [SELECT ActorId, CreatedById, CreatedDate, IsDeleted, OriginalActorId, ProcessInstanceId, Id FROM ProcessInstanceWorkitem where ProcessInstanceId in : pis];
        
        //Change the Approver by updating the Approver
        if (!processWorkItems.isEmpty() && processWorkItems.size() > 0) {
            ProcessInstanceWorkitem p = processWorkItems[0];
            if(getIsReviewer()) {
            p.ActorId = selectedReviewer;
            }
            else if(getIsApprover() || getIsPublisher()) {
            p.ActorId = selectedApprover;
            }
            else if(getIsSuperAdmin()) { //T-83190: At the time of review/approve, an Admin user can reassign to other Admins only
                p.ActorId = selectedAdmin;
            }
            
           update p;
           
           PageReference pref=new PageReference('/apex/MM_RecipeDashboard');
           pref.setRedirect(true);
           return pref;
           
        }
      
     }
     catch (Exception e) {
        String message = e.getMessage();
        system.debug('===========message===============' + message);
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Reassigning Approval'));
     }
     
     return null;
     
  }
  
  
  public pageReference reassignWhenCreated() {
    
         if(getIsEditor() && selectedEditor != null) {
             currentRecipe.current_Editor__c = selectedEditor;
             update currentRecipe;
             PageReference pref=new PageReference('/apex/MM_RecipeDashboard');
             pref.setRedirect(true);
             return pref;            
         }
         else if(getIsSuperAdmin()  && selectedEditor != null) {
             currentRecipe.current_Editor__c = selectedEditor;
             update currentRecipe;
             PageReference pref=new PageReference('/apex/MM_RecipeDashboard');
             pref.setRedirect(true);
             return pref;
         } 
         else if(getIsReviewer()  && selectedReviewer != null) {
             currentRecipe.current_Editor__c = selectedReviewer;
             update currentRecipe;
             PageReference pref=new PageReference('/apex/MM_RecipeDashboard');
             pref.setRedirect(true);
             return pref;
         } 
         else if(getIsApprover()  && selectedApprover != null) {
             currentRecipe.current_Editor__c = selectedApprover;
             update currentRecipe;
             PageReference pref=new PageReference('/apex/MM_RecipeDashboard');
             pref.setRedirect(true);
             return pref;
         }
       
       return null;  
    
  }
    
    public PageReference swapImage() {
        
        //swapId = ApexPages.currentPage().getParameters().get('swapId');
        System.debug('swapId: ' + swapId);
        return null;
    }
    
    //create publish recipe record list
    public void publishRecipe() {
        map<Id, Published_Recipe__c> assetPublishedRecipeMap = new map<Id, Published_Recipe__c>();
        list<Digital_Published_Asset__c> digitalPublishedAssetList = new list<Digital_Published_Asset__c>();
        User user = [Select u.UserRole.Name, u.Profile.Name From User u where Id =: Userinfo.getUserId()];
        for(Published_Recipe__c publishedRecipe : [Select p.Status__c, p.Recipe__c, p.Id, p.Digital_Published_Asset__c From Published_Recipe__c p where Recipe__c =: currentRecipe.Id]) {
            assetPublishedRecipeMap.put(publishedRecipe.Digital_Published_Asset__c, publishedRecipe);   
        }
        if(user.UserRole.Name == 'Recipe - Admin' || user.Profile.Name == 'System Administrator')   {
            digitalPublishedAssetList = [Select d.Publisher__r.Name, d.Name, d.Id From Digital_Published_Asset__c d];
            cretePublishedRecipeList(assetPublishedRecipeMap, digitalPublishedAssetList);           
        }   else {
            digitalPublishedAssetList = [Select d.Publisher__r.Name, d.Name, d.Id From Digital_Published_Asset__c d where Publisher__c =: UserInfo.getUserId()];
            cretePublishedRecipeList(assetPublishedRecipeMap, digitalPublishedAssetList);   
        }
    }
    
    public void cretePublishedRecipeList(map<Id, Published_Recipe__c> assetPublishedRecipeMap, list<Digital_Published_Asset__c> assetList) {
        publishRecipeWrapperList = new list<publishedRecipeWrapper>();
        Published_Recipe__c publishRecipe;
        for(Digital_Published_Asset__c digitalPublishedAsset : assetList) {
            if(assetPublishedRecipeMap.containsKey(digitalPublishedAsset.Id)) {
                publishRecipeWrapperList.add(new publishedRecipeWrapper(digitalPublishedAsset.Name,digitalPublishedAsset.Publisher__r.Name, assetPublishedRecipeMap.get(digitalPublishedAsset.Id)));
            }else {
                publishRecipe = new Published_Recipe__c(Digital_Published_Asset__c = digitalPublishedAsset.Id,
                                                                                                Recipe__c = currentRecipe.Id,
                                                                                                Status__c = 'Ready to Publish');
                publishRecipeWrapperList.add(new publishedRecipeWrapper(digitalPublishedAsset.Name, digitalPublishedAsset.Publisher__r.Name, publishRecipe));                                                                                                                           
            }   
        }       
    }
    
    //Update and crete publish recipe record
    public void updatePublishRecipeRecords() {
        list<Published_Recipe__c>   updatedPublishedRecipeList = new list<Published_Recipe__c>();
        for(publishedRecipeWrapper prwObject : publishRecipeWrapperList) {
            if(selectedAssetId == prwObject.publishedRecipe.Digital_Published_Asset__c) {
                if(prwObject.publishedRecipe.Status__c == 'Published') {
                    prwObject.publishedRecipe.Status__c = 'Suppressed'; 
                }else if(prwObject.publishedRecipe.Status__c == 'Suppressed') {
                    prwObject.publishedRecipe.Status__c = 'Published';  
                }else if(prwObject.publishedRecipe.Status__c == 'Ready to Publish') {
                    prwObject.publishedRecipe.Status__c = 'Published';      
                }
                updatedPublishedRecipeList.add(prwObject.publishedRecipe);
            }
        }
        if(updatedPublishedRecipeList.size() > 0) {
            upsert updatedPublishedRecipeList;
        }
        publishRecipe();
    }
    
    //Wrapper class
    public class publishedRecipeWrapper {
        public String assetName {get; set;}
        public String publisherName {get;set;}
        public Published_Recipe__c publishedRecipe {get;set;}
        
        public publishedRecipeWrapper(String assetName, String publisherName, Published_Recipe__c publishedRecipe) {
            this.assetName = assetName;
            this.publisherName = publisherName;
            this.publishedRecipe = publishedRecipe;
        }  
    }
    
    //Cloning an Approved Recipe
    public PageReference cloneRecipe() {
        Id newId = MM_Utility.cloneRecipeInformation(currentRecipe.Id);
        PageReference pageRef = new PageReference('/apex/MM_RecipeView?recipeId=' + newId + '&editMode=true&isClone=true');
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    //Deleting a Created Recipe.
    public PageReference deleteRecipe() {
        
        Boolean success = MM_Utility.deleteRecipe(currentRecipe);
        PageReference pageRef = new PageReference('/apex/MM_RecipeDashboard');
        pageRef.setRedirect(true);
        
        if (!success) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Deleting Recipe.'));
            pageRef = null;
        }

        return pageRef;
    }   
    
    //Deleting already associated Images to the Recipe.
    public PageReference deleteImage () {
        try{
            Recipe_Media__c currentImage = [select Id,Name from Recipe_Media__c where Content_Id__c = :swapId];
            
            if (currentRecipe.Additional_Image_1__c == currentImage.Id)
                currentRecipe.Additional_Image_1__c = null;
            else if (currentRecipe.Additional_Image_2__c == currentImage.Id)
                currentRecipe.Additional_Image_2__c = null;
            else if (currentRecipe.Search_Recipe_Image__c == currentImage.Id)
                currentRecipe.Search_Recipe_Image__c = null;                
            else if (currentRecipe.Brand_Recipe_Image__c == currentImage.Id)
                currentRecipe.Brand_Recipe_Image__c = null;         
            else if (currentRecipe.Background_Image__c == currentImage.Id)
                currentRecipe.Background_Image__c = null;
            else if (currentRecipe.Mobile_Unselected_Image__c == currentImage.Id)
                currentRecipe.Mobile_Unselected_Image__c = null;                
            else if (currentRecipe.Mobile_Drink_Image__c == currentImage.Id)
                currentRecipe.Mobile_Drink_Image__c = null;             
            else if (currentRecipe.Mobile_Selected_Image__c == currentImage.Id)
                currentRecipe.Mobile_Selected_Image__c = null;              
            else if (currentRecipe.Main_Drink_Image__c == currentImage.Id)
                currentRecipe.Main_Drink_Image__c = null;
            
            update currentRecipe;           
                            
            swapId = null;
        }
        catch (DMLException e) {
            String message = e.getMessage();
            system.debug('===========message===============' + message);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,message));
        }
        return null;
    }
    
    //Archiving a Recipe
    public PageReference archiveRecipe() {
        
        Boolean success = MM_Utility.archiveRecipe(currentRecipe);
        PageReference pageRef = new PageReference('/apex/MM_RecipeDashboard');
        pageRef.setRedirect(true);
        
        if (!success) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Archiving Recipe'));
            pageRef = null;
        }

        return pageRef;
    }       
    
    public PageReference dlRecipe() {
        
        PageReference pageRef = new PageReference('/apex/MM_ExportRecipe?masterRecipeId=' + currentRecipe.Master_Recipe__r.Id + '&recipeId=' + currentRecipe.Id);
        pageRef.setRedirect(true);
        
        return pageRef;
        
    }
    
    //Cancelling the Edit after entering/modifying an existing Reicpe.
    public PageReference cancelEdit() {
        system.debug('============================cancelEdit()');
        PageReference pageRef;
        if(recipeId != null) {
            editMode = false;
            if(currentRecipe.recordSaved__c == true) {
                list<Recipe_Attribute__c> ratr = [select Id,CreatedDate,LastModifiedDate,SystemModstamp from Recipe_Attribute__c where recipe__c =: currentRecipe.Id and createdDate >: currentRecipe.lastModifiedTime__c];
                if(ratr.size()>0)
                    delete ratr;
              
                list<Recipe_Occasion__c> rocc = [select Id,CreatedDate,LastModifiedDate,SystemModstamp from Recipe_Occasion__c where recipe__c =: currentRecipe.Id and createdDate >: currentRecipe.lastModifiedTime__c];
                if(rocc.size()>0)
                    delete rocc;
              
                list<Diageo_Ingredient__c> din = [ select Id,CreatedDate,LastModifiedDate,SystemModstamp from Diageo_Ingredient__c where recipe__c =:currentRecipe.Id and createdDate >: currentRecipe.lastModifiedTime__c];
                if(din.size()>0)
                    delete din;
              
                list<Preparation_Step__c> pL = [ select Id from Preparation_Step__c where recipe__c =:currentRecipe.Id and CreatedDate >: currentRecipe.lastModifiedTime__c ];
                if(pL.size()>0)
                    delete pL;
                pageRef = new PageReference('/apex/MM_RecipeView?recipeId=' + recipeId);
             } else {
                list<Recipe_Attribute__c>  rat = [select Id,LastModifiedDate,SystemModstamp from Recipe_Attribute__c where recipe__c =: currentRecipe.Id and LastModifiedDate >: currentRecipe.lastModifiedTime__c];
                
                if(rat.size()>0)
                    delete rat;
                 
                list<Recipe_Occasion__c> roc = [select id from Recipe_Occasion__c where recipe__c =: currentRecipe.Id and LastModifiedDate >: currentRecipe.lastModifiedTime__c ];
                delete roc;
                
                list<Diageo_Ingredient__c> diL = [ select Id,LastModifiedDate,SystemModstamp from Diageo_Ingredient__c where recipe__c =:currentRecipe.Id and LastModifiedDate >: currentRecipe.lastModifiedTime__c ];
                if(diL.size()>0)
                    delete diL;
                 
                List<Preparation_Step__c> pL = [ select Id from Preparation_Step__c where recipe__c =:currentRecipe.Id and CreatedDate >: currentRecipe.lastModifiedTime__c and LastModifiedDate >: currentRecipe.lastModifiedTime__c];
                if(pL.size()>0)
                    delete pL;
                  
                Recipe__c tempRec = [select id from Recipe__c where Id=:currentRecipe.Id];
                    delete tempRec;
                 
                pageRef = new PageReference('/apex/MM_RecipeDashboard');
            }
            pageRef.setRedirect(true);
            return pageRef;
        } else {
            system.debug('============================Yes===');
            PageReference pageRef1 = new PageReference('/apex/MM_RecipeView?newRecipe=true&editMode=true');
            return pageRef1;
        }
    }
    
    public Boolean assetListEmpty() {
        if (assetList != null)
            return assetList.IsEmpty();
        else
            return true;
    }
    
    public Boolean validateRecipe() {
        
        Boolean recipeVal = false;
        
        if (currentRecipe.Name != null && ingredients.size() > 0 && currentRecipe.Preparation_Steps__c != null)
            recipeVal = true;
        
        
        return recipeVal;
        
    }
    
    //First Initial Submission Action that is performed upon submitting a Recipe.
    public PageReference submitRecipe() {
        
        try{
                if (currentRecipe.Comments__c != null)
                    currentRecipe.Comments__c = currentRecipe.Comments__c + '<br/>' + System.now().format('MM/dd/yy h:mm a') + ' ' + getCurrentUser().Name + ' <b>Submitted</b> the Recipe for Approval.';
                else
                    currentRecipe.Comments__c = System.now().format('MM/dd/yy h:mm a') + ' ' + getCurrentUser().Name + ' <b>Submitted</b> the Recipe for Approval.';    
                /* here upstae the fueld with selected reviewers email Id */
                
            
                currentRecipe.reviewedBy__c = selectedReviewer;
                
                update currentRecipe;
                
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                system.debug('==============selectedReviewer=============' + selectedReviewer);
                req1.setNextApproverIds(new Id[]{selectedReviewer});
                req1.setObjectId(currentRecipe.Id);   
                Approval.ProcessResult result = Approval.process(req1);
        }
        catch (Exception e) {
            String message = e.getMessage();
            system.debug('===========message===============' + message);
            if (message.contains('ALREADY_IN_PROCESS'))
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Recipe has already been Submitted for Approval'));

            
        }

        PageReference pageRef = new PageReference('/apex/MM_RecipeView?recipeId=' + recipeId);
        //ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;         
        
    }
    
    //Approving a Recipe Submitted by Reviewer.
    public PageReference approveRecipeSubmittedByReviewer() {
        if (currentRecipe.Has_Legal_Approval__c) {
            if (currentRecipe.Comments__c != null)
                currentRecipe.Comments__c = currentRecipe.Comments__c + '<br/><br/>' + System.now().format('MM/dd/yy h:mm a') + ' - ' + getCurrentUser().Name + ' <b>Approved</b> the Recipe.<br/>&nbsp;&nbsp;&nbsp;&nbsp;<b>Comments:</b>  ' + currentComment;
            else
                currentRecipe.Comments__c = System.now().format('MM/dd/yy h:mm a') + ' - ' + getCurrentUser().Name + ' <b>Approved</b> the Recipe.<br/>&nbsp;&nbsp;&nbsp;&nbsp;<b>Comments:</b>  ' + currentComment;
            
            update currentRecipe;
            Boolean success = processApproval('Approve');
            PageReference pageRef = new PageReference('/apex/MM_RecipeView?recipeId=' + recipeId);
            pageRef.setRedirect(true);      
            return pageRef; 
            
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Legal Approval Required.'));
            return null;
            }
    }
    
    public List<selectOption> getQuantities() {
      return getPickValues(new Diageo_Ingredient__c(), 'Quantity__c', 'None',null);
    }
      
   public List<selectOption> getUnits() {
      return getPickValues(new Diageo_Ingredient__c(), 'Units__c','None',null);
   }   
   
   public List<selectOption> getCustomUnits() {
      return getPickValues(new Diageo_Ingredient__c(), 'Non_Diageo_Product_Units__c','None',null);
   }  
 
   public List<selectOption> getRecipeColors() {
      return colorOptions;
   }
   
   public List<selectOption> getRecipeFlavors() {
      return flavorOptions;
   }
   
   /*Modified By Rishi Khirbat -> T-98032:Updates to MM_RecipeView*/
   public List<selectOption> getRecipeBarwares() {
      return barwareOptions;
   }  
   
   public List<selectOption> getRecipeDrinks() {
      return drinkOptions;
   }
   
   public List<selectOption> getRecipeEfforts() {
      return effortOptions;
   }
   
   public List<selectOption> getRecipeGlasswares() {
      return glasswareOptions;
   }
   
   public List<selectOption> getRecipeServings() {
      return servingOptions;
   }
   
   public List<selectOption> getRecipeWineTastes() {
      return wineTasteOptions;
   }
   
   public List<selectOption> getRecipeWineTypes() {
      return wineTypeOptions;
   }
   
   public List<selectOption> getLocaleDetailsFilter() {
      return getPickValues(new Attribute__c(), 'Locale__c','-None-',null);
   }
   
   public List<selectOption> getLocaleIngredientsFilter() {
      return getPickValues(new Recipe_Non_Diageo_Product__c(), 'Locale__c','-None-',null);
   }
   /***************/
      
   public List<selectOption> getRecipeTypes() {
      return typeOptions;
   }

   public List<selectOption> getLanguages() {
     return languageOptions;
   }     
 
   public List<selectOption> getCelebrations1() {
        return celebration1Options;
   }  
    public List<selectOption> getCelebrations2() {
        return celebration2Options;
    }   
    public List<selectOption> getCelebrations3() {
        return celebration3Options;
    } 
    public List<selectOption> getCelebrations4() {
        return celebration4Options;
    }
    
    
   public List<selectOption> getThemeParties1() {
        return themeParty1Options;
   }  
   public List<selectOption> getThemeParties2() {
        return themeParty2Options;
   }
   public List<selectOption> getThemeParties3() {
        return themeParty3Options;
   }
   public List<selectOption> getThemeParties4() {
        return themeParty4Options;
   }
    
    
   public List<selectOption> getHolidays1() {
        return holidays1Options;
   }
   public List<selectOption> getHolidays2() {
        return holidays2Options;
   }
   public List<selectOption> getHolidays3() {
        return holidays3Options;
   }
   public List<selectOption> getHolidays4() {
        return holidays4Options;
   }
   
   public List<selectOption> getOutdoors1() {
        return outdoor1Options;
   }
   public List<selectOption> getOutdoors2() {
        return outdoor2Options;
   }
   public List<selectOption> getOutdoors3() {
        return outdoor3Options;
   }
   public List<selectOption> getOutdoors4() {
        return outdoor4Options;
   }
  
        
   public List<selectOption> getPickValues(Sobject object_name, String field_name, String first_val, String last_val) {
      
         List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
      
         if (first_val != null) { //if there is a first value being provided
            if(first_val=='none')
             options.add(new selectOption(first_val, ''));
            else
             options.add(new selectOption(first_val, first_val)); //add the first option
         }
         
         Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
         Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
         Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
         List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
         
         for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            options.add(new selectOption(a.getLabel(), a.getValue())); //add the value and label to our final list
         }
         
         if (last_val != null) { //if there is a first value being provided
            options.add(new selectOption(last_val, last_val)); //add the first option
         }
         return options; //return the List
   }
   
   public void deleteIngredient() {
         delete ingredients[Integer.valueOf(modifiedIngredientIndex)].rgi;
   }
    
    public String getUserAgent() { 
        return ApexPages.currentPage().getHeaders().get('User-Agent');
    }
    
    //Method that is called when the user wants to go back to the Filtered Results View of search Page.
    public pageReference FilteredResultsView() {
        recipeId = ApexPages.currentPage().getParameters().get('recipeId');
        searchTerm = ApexPages.currentPage().getParameters().get('searchTerm');
        currentBrand = ApexPages.currentPage().getParameters().get('currentBrand');
        currentColor = ApexPages.currentPage().getParameters().get('currentColor');
        currentFlavor = ApexPages.currentPage().getParameters().get('currentFlavor');
        currentType = ApexPages.currentPage().getParameters().get('currentType');
        currentOccasion = ApexPages.currentPage().getParameters().get('currentOccasion');
        currentStatus = ApexPages.currentPage().getParameters().get('currentStatus');
        currentIngredientNumber = ApexPages.currentPage().getParameters().get('currentIngredientNumber');
        
        isNavigatingFromDetail = 'true';
        pageReference pref = new PageReference('/apex/MM_ViewAllRecipes');
        if(searchTerm != '')
         pref.getParameters().put('searchTerm',searchTerm); 
        if(currentBrand != '')
        pref.getParameters().put('currentBrand',currentBrand);
        if(currentColor != '')
        pref.getParameters().put('currentColor',currentColor);
        if(currentFlavor != '')
        pref.getParameters().put('currentFlavor',currentFlavor);
        if(currentType != '')
        pref.getParameters().put('currentType',currentType);
        if(currentStatus != '')
        pref.getParameters().put('currentStatus',currentStatus);
        if(currentIngredientNumber != '') {
             pref.getParameters().put('currentIngredientNumber',currentIngredientNumber.replace('+','%2B'));
        } 
        
        pref.getParameters().put('isNavigatingFromDetail', 'true');
        
        pref.setRedirect(true);
        return pref;
    }
        
}