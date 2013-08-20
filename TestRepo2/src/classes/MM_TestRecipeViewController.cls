/*Test to check the Contorller Associated with MM_RecipeView Visualforce page.
* @Author  : Raj Avirneni
* @Date    : Mar 29 2012
* @Version : 1.0
* The @isTest class annotation indicates this class only contains test methods. 
* Classes defined with the @isTest annotation do not count against the organization size limit for all Apex scripts.
*/

/* Modified By  : Rishi Khirbat(Appirio Offshore)
   Details      : Modified against: 
                    T-98032  - Updates to MM_RecipeView (on 10th-Dec-2012) 
                    T-104879 - Add Measurement Conversion button to MM_ViewRecipe (on 18th-Dec-2012)
   
*/

@isTest
private class MM_TestRecipeViewController {
    static UserRole editorRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_EDITOR ];
    //static UserRole reviewerRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_REVIEWER];
    static UserRole approverRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_APPORVER];
    static UserRole publisherRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_PUBLISHER];
    static UserRole adminRole = [select Id from UserRole where Name =: MM_RecipeBase.RECIPE_ADMIN];
    
    static User editor;
    static User editor2;
    //static User reviewer;
    static User approver;
    static User publisher;
    static User admin;
    
    static Attribute__c attr1;
    static Attribute__c attr2;
    static Attribute__c attr3;
    static Attribute__c attr4;
    static Attribute__c attr5;
    static Attribute__c attr6;
    static Attribute__c attr7;
    static Attribute__c attr8;
    static Attribute__c attr9;
    static Attribute__c attr10;
    static Attribute__c attr11;
    
    /*By Rishi Khirbat on 10th Dec 2012*/
    static Attribute__c attr12;
    static Attribute__c attr13;
    static Attribute__c attr14;
    static Attribute__c attr15;
    static Attribute__c attr16;
    static Attribute__c attr17;
    static Attribute__c attr18;
    /**/
    
    static Occasion__c occ1;
    static Occasion__c occ2;
    static Occasion__c occ3;
    static Occasion__c occ4;
    static Occasion__c occ5;
    static Occasion__c occ6;
    static Occasion__c occ7;
    static Occasion__c occ8;
    static Occasion__c occ9;
    static Occasion__c occ10;
    static Occasion__c occ11;
    static Occasion__c occ12;
    static Occasion__c occ13;
    static Occasion__c occ14;
    static Occasion__c occ15;
    static Occasion__c occ16;
    
    static Diageo_Brand__c diagBrnd1;
    static Diageo_Brand__c diagBrnd2;
    
    static Diageo_Product__c diagPrdct1;
    static Diageo_Product__c diagPrdct2;
    static Diageo_Product__c diagPrdct3;
    static Diageo_Product__c diagPrdct4;
    
    static Recipe_Non_Diageo_Product__c nonDiagPrdct1;
    static Recipe_Non_Diageo_Product__c nonDiagPrdct2;
    
    static ContentVersion myImage;
    static Recipe_Media__c recm;
    static List<Convert_Measurements__c> convertMeasurements;
    
    static user user1;
    
    public static void createData() {
    createUser();
        editor = new User(alias = 'unittest', email='unittest@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = editorRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unittest@diageorecipes.com');
            
        editor2 = new User(alias = 'editor2', email='editor2@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = editorRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='editor2@diageorecipes.com');
        /*    
        reviewer = new User(alias = 'unitrev', email='unitrev@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = reviewerRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unitrev@diageorecipes.com');
        */  
        approver = new User(alias = 'unitapp', email='unitapp@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = approverRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unitapp@diageorecipes.com');
            
        publisher = new User(alias = 'unitpub', email='unitpub@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = publisherRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unitpub@diageorecipes.com');
        
        admin = new User(alias = 'unitadm', email='unitadm@diageorecipes.com', 
            emailencodingkey='UTF-8', lastname='Testing', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = UserInfo.getProfileId(), userroleid = adminRole.Id,
            timezonesidkey='America/Los_Angeles', 
            username='unitadm@diageorecipes.com');
            
        editor.isActive=true;
        editor2.isActive=true;
        //reviewer.isActive=true;
        approver.isActive=true;
        publisher.IsActive=true;
        admin.isActive=true;
            
        insert editor;
        insert editor2;
        //insert reviewer;
        insert approver;
        insert publisher;
        insert admin;
        
        system.runas(user1) {
        
            myImage = new ContentVersion();
            myImage.title='TITLE';
            myImage.contentUrl='http://www.salesforce.com';
            insert myImage;
            
            recm = new Recipe_Media__c();
            recm.Content_id__c = myImage.Id;
            recm.Name = 'TestImage';
            insert recm;
            
            //Creating all the Attribute,Occasion,Diageo Products,Non diageo Products Records
            //Creating a bunch of Attribute Records     
            attr1 = TestUtil.createAttribute('Color','TestBlue',recm.Id);
            attr2 = TestUtil.createAttribute('Color','TestBrown',recm.Id);
            attr3 = TestUtil.createAttribute('Color','TestPurple',recm.Id);
            attr4 = TestUtil.createAttribute('Language','TestEnglish',recm.Id);
            attr5 = TestUtil.createAttribute('Language','TestSpanish',recm.Id);
            attr6 = TestUtil.createAttribute('Flavor','TestStrawberry',recm.Id);
            attr7 = TestUtil.createAttribute('Flavor','TestBanana',recm.Id);
            attr8 = TestUtil.createAttribute('Flavor','TestMango',recm.Id);
            attr9 = TestUtil.createAttribute('Drink Type','TestCocktails',recm.Id);
            attr10 = TestUtil.createAttribute('Drink Type','TestBloody-Marys',recm.Id);
            attr11= TestUtil.createAttribute('Drink Type','TestBeerBased',recm.Id);
            /*By Rishi Khirbat on 10th Dec 2012*/
            attr12= TestUtil.createAttribute('Glassware','TestGlassware',recm.Id);
            attr13= TestUtil.createAttribute('Effort Level','TestEffortLevel',recm.Id);
            attr14= TestUtil.createAttribute('Serving Style','TestServingStyle',recm.Id);
            attr15= TestUtil.createAttribute('Wine Type','TestWineType',recm.Id);
            attr16= TestUtil.createAttribute('Wine Taste','TestWineTaste',recm.Id);
            attr17 = TestUtil.createAttribute('Barware Needed','TestBarwareNeeded',recm.Id);
            attr18 = TestUtil.createAttribute('Drink Classification','TestDrinkClassification',recm.Id);
            /**/
            
            //Creating a bunch of Occasions     
            occ1 = TestUtil.createOccasion('Holidays','TestLaborDay',recm.Id);
            occ2 = TestUtil.createOccasion('Holidays','TestPresidentsDay',recm.Id);
            occ3 = TestUtil.createOccasion('Holidays','TestMemorialDay',recm.Id);
            occ4 = TestUtil.createOccasion('Holidays','TestValentinesDay',recm.Id);
            occ5 = TestUtil.createOccasion('Celebrations','TestAnniversary',recm.Id);
            occ6 = TestUtil.createOccasion('Celebrations','TestBirthDay',recm.Id);
            occ7 = TestUtil.createOccasion('Celebrations','TestAcquisition',recm.Id);
            occ8 = TestUtil.createOccasion('Celebrations','TestResultsDay',recm.Id);
            occ9 = TestUtil.createOccasion('Outdoor Gatherings','TestBBQ',recm.Id);
            occ10 = TestUtil.createOccasion('Outdoor Gatherings','TestBeachParty',recm.Id);
            occ11 = TestUtil.createOccasion('Outdoor Gatherings','TestMidnightParty',recm.Id);
            occ12 = TestUtil.createOccasion('Outdoor Gatherings','TestCampingParty',recm.Id);
            occ13 = TestUtil.createOccasion('Theme Parties','TestDriveParty',recm.Id);
            occ14 = TestUtil.createOccasion('Theme Parties','TestMardigrass',recm.Id);
            occ15 = TestUtil.createOccasion('Theme Parties','TestWaterParty',recm.Id);
            occ16 = TestUtil.createOccasion('Theme Parties','TestDessertParty',recm.Id);
            
            //Creating a Diageo Brand(Parent Product)           
            diagBrnd1  = TestUtil.createDiageoBrand('ModelBrand1',recm.Id);
            diagBrnd2 = TestUtil.createDiageoBrand('ModelBrand2',recm.Id);
            
            //Creating a Recipe Diageo Product(Categeory/Sub Brand of Daigeo Brand)
            diagPrdct1 = TestUtil.createDiageoProduct('ModelBrand1Caramel',diagBrnd1.Id,recm.Id);
            diagPrdct2 = TestUtil.createDiageoProduct('ModelBrand1Irish',diagBrnd1.Id,recm.Id);
            diagPrdct3 = TestUtil.createDiageoProduct('ModelBrand2Cream',diagBrnd2.Id,recm.Id);
            diagPrdct4 = TestUtil.createDiageoProduct('ModelBrand2Cofee',diagBrnd2.Id,recm.Id);
            
            //Creating a Recipe Non Diageo Product
            nonDiagPrdct1 = TestUtil.createNonDiageoProduct('Big Banana',recm.Id);
            nonDiagPrdct2 = TestUtil.createNonDiageoProduct('TestIng',recm.Id);
            
            convertMeasurements = new List<Convert_Measurements__c>();
            convertMeasurements.add(new Convert_Measurements__c(Name='Test 1',fl_Oz__c='0.25',mL__c='7.393375',X5Mils__c='5', Mils__c='7'));
            convertMeasurements.add(new Convert_Measurements__c(Name='Test 2',fl_Oz__c='1',   mL__c='29.5735', X5Mils__c='30',Mils__c='30'));
            insert convertMeasurements;
        }
        
    } 

    //I-41400-Recipe Publisher Role able to create new recipe or clone from existing recipe
    static testMethod void recipeCreateCloneByPublisherTest(){
        createData();
        
        pageReference pRef = page.MM_RecipeView;
        Test.setCurrentPage(pRef);
        MM_RecipeViewController rvc = new MM_RecipeViewController();
        system.runas(publisher){
            rvc.createTempRecipe();
            Recipe__c tempRecipe = rvc.getCurrentRecipe();
                    
            system.assertNotEquals(tempRecipe.Id,null);
            system.assertEquals(tempRecipe.Recipe_Title__c,'Enter Recipe Name');
    
            tempRecipe.Recipe_Title__c = 'TestRecipe';
            rvc.saveRecipe();
                
            list<Recipe__c> rList = [select Recipe_Title__c from Recipe__c where id =: tempRecipe.id];
            system.assertEquals(rList.size(),1);
            system.assertEquals(rList[0].Recipe_Title__c,'TestRecipe');
        }
    }
    
    static testMethod void recipeCreateTest(){
        
        createData();
        
            // @#UseCase 1: Creating a Recipe .
            // @Description:1.Fill atleast One Color,Flavor,Occasion,Diageo Ingredients,Non Diageo Ingredients,preparation steps
            //              2.uplaod an Image to the Recipe
            // @Expected   : Recipe is Created with the Associated Attributes,Ingredients,Images and Preparation steps.
        
       
        pageReference pRef = page.MM_RecipeView;
        Test.setCurrentPage(pRef);
        MM_RecipeViewController rvc = new MM_RecipeViewController();
        system.runas(user1){
            rvc.createTempRecipe();
        }
        Recipe__c tempRecipe = rvc.getCurrentRecipe();
        
        system.assertNotEquals(tempRecipe.Id,null);
        system.assertEquals(tempRecipe.Recipe_Title__c,'Enter Recipe Name');

        tempRecipe.Recipe_Title__c = 'TestRecipe';
        
        list<selectOption> recColors = rvc.getRecipeColors();
        //By Rishi Khirbat on 10th Dec 2012
        list<selectOption> recGlasswares = rvc.getRecipeGlasswares();
        list<selectOption> recEfforts = rvc.getRecipeEfforts();
        list<selectOption> recServings = rvc.getRecipeServings();
        list<selectOption> recWineTastes = rvc.getRecipeWineTastes();
        list<selectOption> recWineTypes = rvc.getRecipeWineTypes();
        list<selectOption> recBarwares = rvc.getRecipeBarwares();
        list<selectOption> recDrinks = rvc.getRecipeDrinks();
        //----
        list<selectOption> recFlavors = rvc.getRecipeFlavors();
        list<selectOption> recTypes = rvc.getRecipeTypes();
        list<selectOption> recLanguages = rvc.getLanguages();
        list<selectOption> recOccasions1 = rvc.getCelebrations1();
        list<selectOption> recOccasions2 = rvc.getCelebrations2();
        list<selectOption> recOccasions3 = rvc.getCelebrations3();
        list<selectOption> recOccasions4 = rvc.getCelebrations4();
        list<selectOption> recOccasions5 = rvc.getThemeParties1();
        list<selectOption> recOccasions6 = rvc.getThemeParties2();
        list<selectOption> recOccasions7 = rvc.getThemeParties3();
        list<selectOption> recOccasions8 = rvc.getThemeParties4();
        list<selectOption> recOccasions9 = rvc.getHolidays1();
        list<selectOption> recOccasions10 = rvc.getHolidays2();
        list<selectOption> recOccasions11 = rvc.getHolidays3();
        list<selectOption> recOccasions12 = rvc.getHolidays4();
        list<selectOption> recOccasions13 = rvc.getOutdoors1();
        list<selectOption> recOccasions14 = rvc.getOutdoors2();
        list<selectOption> recOccasions15 = rvc.getOutdoors3();
        list<selectOption> recOccasions16 = rvc.getOutdoors4();
        
        rvc.selColor = attr1.Id;
        Id[] selFlavorIds = new Id[]{attr7.Id};
        rvc.setSelFlavorIds(selFlavorIds);
        rvc.selLanguage = attr5.Id;
        Id[] selTypeIds = new Id[]{attr9.Id};
        rvc.setSelTypeIds(selTypeIds);
        
        //By Rishi Khirbat on 10th Dec 2012
        rvc.selGlassware = attr12.Id;
        rvc.selEffort = attr13.Id;
        rvc.selServing = attr14.Id;
        rvc.selWineType = attr15.Id;
        rvc.selWineTaste = attr16.Id;
        Id[] selBarwareIds = new Id[]{attr17.Id};
        rvc.setSelBarwareIds(selBarwareIds);
        Id[] selDrinkIds = new Id[]{attr18.Id};
        rvc.setSelDrinkIds(selDrinkIds);
        //----
        
        Id[] selCelebration1Ids= new id[]{occ5.Id};
        rvc.setSelCelebration1Ids(selCelebration1Ids);
        Id[] selCelebration2Ids= new id[]{occ6.Id};
        rvc.setSelCelebration2Ids(selCelebration2Ids);
        Id[] selCelebration3Ids= new id[]{occ7.Id};
        rvc.setSelCelebration3Ids(selCelebration3Ids);
        Id[] selCelebration4Ids= new id[]{occ8.Id};
        rvc.setSelCelebration4Ids(selCelebration4Ids);
        
        
        Id[] selThemeParty1Ids = new id[]{occ13.Id};
        rvc.setSelThemeParty1Ids(selThemeParty1Ids);
        
        Id[] selThemeParty2Ids = new id[]{occ14.Id};
        rvc.setSelThemeParty2Ids(selThemeParty2Ids);
        
        Id[] selThemeParty3Ids = new id[]{occ15.Id};
        rvc.setSelThemeParty3Ids(selThemeParty3Ids);
        
        Id[] selThemeParty4Ids = new id[]{occ16.Id};
        rvc.setSelThemeParty4Ids(selThemeParty4Ids);
        
        Id[] selOutdoor1Ids = new id[]{occ9.Id};
        rvc.setSelOutdoor1Ids(selOutdoor1Ids);
        Id[] selOutdoor2Ids = new id[]{occ10.Id};
        rvc.setSelOutdoor2Ids(selOutdoor2Ids);
        Id[]selOutdoor3Ids = new id[]{occ11.Id};
        rvc.setSelOutdoor3Ids(selOutdoor3Ids);
        Id[] selOutdoor4Ids = new id[]{occ12.Id};
        rvc.setSelOutdoor4Ids(selOutdoor4Ids);
        
        Id[] selHoliday1Ids = new id[]{occ1.Id};
        rvc.setSelHoliday1Ids(selHoliday1Ids);
        Id[]selHoliday2Ids = new id[]{occ2.Id};
        rvc.setSelHoliday2Ids(selHoliday2Ids);
        Id[] selHoliday3Ids = new id[]{occ3.Id};
        rvc.setSelHoliday3Ids(selHoliday3Ids);
        Id[] selHoliday4Ids = new id[]{occ4.Id};
        rvc.setSelHoliday4Ids(selHoliday4Ids);
        
        rvc.getSelHoliday1Ids();
        rvc.getSelHoliday2Ids();
        rvc.getSelHoliday3Ids();
        rvc.getSelHoliday4Ids();
        
        
        rvc.getSelCelebration1Ids();
        rvc.getSelCelebration2Ids();
        rvc.getSelCelebration3Ids();
        rvc.getSelCelebration4Ids();
        
        rvc.getSelThemeParty1Ids();
        rvc.getSelThemeParty2Ids();
        rvc.getSelThemeParty3Ids();
        rvc.getSelThemeParty4Ids();
        
        rvc.getSelOutdoor1Ids();
        rvc.getSelOutdoor2Ids();
        rvc.getSelOutdoor3Ids();
        rvc.getSelOutdoor4Ids();
        
        
        rvc.getSelFlavorIds();
        rvc.getSelTypeIds();
        //By Rishi Khirbat on 10th Dec 2012
        rvc.getSelBarwareIds();
        rvc.getSelDrinkIds();
        //---

        rvc.getUnits();
        rvc.getQuantities();
        
        list<MM_RecipeViewController.dWrapper> dig = rvc.diagIng;
        list<MM_RecipeViewController.ndWrapper> dnig = rvc.nonDiagIng;
        list<Preparation_Step__c> pStep = rvc.prepSteps;
        //system.assertEquals(dig.size(),0);
        
        
        rvc.diagIng[0].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[0].ingredient.Units__c = 'ml';
        rvc.diagIng[0].ingredient.Featured_Brand__c = true;
        list<selectOption> diagBrands = rvc.getDiageoBrands();
        rvc.diagIng[0].brand = diagBrnd1.Id;
        list<selectOption> diagProduct = rvc.diagIng[0].getDiageoProducts();
        rvc.diagIng[0].dProduct = diagPrdct1.Id;
        rvc.diagIng[0].ingredient.Quantity__c = '100';
        
        
        list<selectOption> nonDiagProduct = rvc.getNonDiageoProducts();
        rvc.diagIng[1].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[1].ingredient.Units__c = 'ml';
        rvc.diagIng[1].ingredient.Featured_Brand__c = false;
        rvc.diagIng[1].dProduct = diagPrdct2.Id;
        rvc.diagIng[1].brand = diagBrnd1.Id;
        rvc.diagIng[1].ingredient.Quantity__c = '100';
        
        //rvc.nonDiagIng[0].ingredient = 'Big Banana';
        rvc.nonDiagIng[0].nd.Recipe_Non_Diageo_Product__c = nonDiagPrdct1.Id;
        rvc.nonDiagIng[0].nd.Units__c = 'ml.';
        rvc.nonDiagIng[0].nd.Quantity__c = '7.393375';
        rvc.nonDiagIng[0].nd.Recipe__c = tempRecipe.Id;
        
        ApexPages.currentPage().getParameters().put('step','2');
        ApexPages.currentPage().getParameters().put('field','ingredient');
    
        rvc.nonDiagIng[1].ingredient = 'custom';
        rvc.showUnit();
        rvc.nonDiagIng[1].customIng = 'TestIng';
        rvc.nonDiagIng[1].nd.Units__c = 'oz.';
        rvc.nonDiagIng[1].nd.Quantity__c = '1';
        rvc.nonDiagIng[1].nd.Recipe__c = tempRecipe.Id;
        
         ApexPages.currentPage().getParameters().put('step','2');
        
        
        rvc.prepSteps[0].Description__c = 'Test1';
        rvc.prepSteps[0].Step_Number__c = 1;
        rvc.prepSteps[1].Description__c = 'Test2';
        rvc.prepSteps[1].Step_Number__c = 2;
        rvc.prepSteps[2].Description__c = 'Test3';
        rvc.prepSteps[2].Step_Number__c = 3;
        rvc.prepSteps[3].Description__c = 'Test4';
        rvc.prepSteps[3].Step_Number__c = 4;
        rvc.prepSteps[4].Description__c = '';
        rvc.prepSteps[4].Step_Number__c = 5;
        rvc.addADiagIng();
        rvc.addANDiagIng();
        rvc.addAStep();
        
        ApexPages.currentPage().getParameters().put('pStep','2');
        rvc.moveUp();
        ApexPages.currentPage().getParameters().put('pStep','3');
        rvc.movedown();
        ApexPages.currentPage().getParameters().put('ing','4');
        rvc.deleteDiagIng();
        
        temprecipe.Additional_Image_1__c = recm.Id;
        temprecipe.Additional_Image_2__c  = recm.Id;
        temprecipe.Background_Image__c = recm.Id;
        temprecipe.Brand_Recipe_Image__c = recm.Id;
        temprecipe.Main_Drink_Image__c = recm.Id;
        temprecipe.Mobile_Drink_Image__c = recm.Id;
        temprecipe.Mobile_Selected_Image__c = recm.Id;
        temprecipe.Mobile_Unselected_Image__c = recm.Id;
        temprecipe.Search_Recipe_Image__c = recm.Id;
        
        //By Rishi Khirbat on 10th Dec 2012
        rvc.descriptionOverview = 'Test Description/Overview';
        rvc.recipeStory = 'Test Recipe Story';
        rvc.servingSize = 'Test Serving Size'; 
        rvc.foodPairings = 'Test Food Pairings'; 
        rvc.standardAverageAnalysis = 'Test Standard Average Analysis'; 
        rvc.tastingNotes = 'Test Tasting Notes'; 
        
        //rvc.currentRecipe.Recipe_Tag__c = 'Test Recipe Tag';
        rvc.currentRecipe.Recipe_Tags__c = 'Test Recipe Tag';
        //----
        
        
        system.runAs(editor){
            rvc.getCanEdit();
            rvc.getCUser();            
            rvc.upsertTempRecipe();
            boolean img = rvc.getHasImages();
            boolean bcheck = rvc.bCheck();
            boolean ingCheck = rvc.oneDCheck();
            boolean error = rvc.getHasError();
            
            rvc.saveRecipe();
            
            list<Recipe__c> rList = [select Recipe_Title__c from Recipe__c where id =: tempRecipe.id];
            system.assertEquals(rList.size(),1);
            list<Recipe_Attribute__c> raList = [select Attribute__c,Attribute__r.Attribute_Type__c,Attribute__r.Attribute_Value__c,Recipe__c, Dynamic_Value__c from Recipe_Attribute__c where Recipe__c =: tempRecipe.Id];
            system.assertEquals(raList.size(),23);
            //system.assertEquals(raList.size(),11);
            list<Recipe_Occasion__c> roList = [select Occasion__c,Recipe__c from Recipe_Occasion__c where Recipe__c =: tempRecipe.Id];
            system.assertEquals(roList.size(),16);
            list<Diageo_Ingredient__c> diagIng = [select Units__c,Featured_Brand__c,Recipe_Diageo_Product__r.Name,Recipe_Non_Diageo_Product__r.Name,Recipe__c from Diageo_Ingredient__c where Recipe__c =: tempRecipe.Id];
            system.assertEquals(diagIng.size(),4);
            list<Preparation_Step__c> pSteps = [select Description__c,Step_Number__c,Recipe__c from Preparation_Step__c where Recipe__c =: tempRecipe.Id];
            system.assertEquals(pSteps.size(),4);
            integer pCount = rvc.pSize;
            system.assertEquals(pCount,6);
            system.assertEquals(diagIng[0].Recipe_Diageo_Product__r.Name,'ModelBrand1Caramel');
            system.assertEquals(diagIng[2].Recipe_Diageo_Product__r.Name,null);
            system.assertEquals(diagIng[2].Recipe_Non_Diageo_Product__r.Name,'Big Banana');
            system.assertEquals(diagIng[3].Recipe_Non_Diageo_Product__r.Name,'TestIng');    
            
            //By Rishi Khirbat on 10th Dec 2012
            //system.assertEquals(rvc.currentRecipe.Recipe_Tag__c,'Test Recipe Tag');
            system.assertEquals(rvc.currentRecipe.Recipe_Tags__c,'Test Recipe Tag');
            
            for(Recipe_Attribute__c ra: raList){
                if(ra.Attribute__r.Attribute_Type__c.equals('Description/Overview')) {
                    system.assertEquals(ra.Dynamic_Value__c, 'Test Description/Overview');
                }
                if(ra.Attribute__r.Attribute_Type__c.equals('Recipe Story')) {
                    system.assertEquals(ra.Dynamic_Value__c, 'Test Recipe Story');
                }
                if(ra.Attribute__r.Attribute_Type__c.equals('Serving Size')) {
                    system.assertEquals(ra.Dynamic_Value__c, 'Test Serving Size');
                }
                if(ra.Attribute__r.Attribute_Type__c.equals('Food Pairings')) {
                    system.assertEquals(ra.Dynamic_Value__c, 'Test Food Pairings');
                }
                if(ra.Attribute__r.Attribute_Type__c.equals('Standard Average Analysis')) {
                    system.assertEquals(ra.Dynamic_Value__c, 'Test Standard Average Analysis');
                }
                if(ra.Attribute__r.Attribute_Type__c.equals('Tasting Notes')) {
                    system.assertEquals(ra.Dynamic_Value__c, 'Test Tasting Notes');
                }
            }
            
            //By Rishi Khirbat on 18th Dec 2012
            rvc.concatenateTagsValue = 'Concatenate Tags Value';
            rvc.saveTags();
            system.assertEquals(rvc.currentRecipe.Recipe_Tags__c,'Test Recipe Tag, Concatenate Tags Value');
            
            List<MM_RecipeViewController.WrapperDiageoIngredient> wrDiageoIngredients;
            
            rvc.convertOZMeasurements();
            rvc.convertMLMeasurements();
            wrDiageoIngredients = rvc.getWrapperDiageoIngredient();
            for(MM_RecipeViewController.WrapperDiageoIngredient wr :wrDiageoIngredients) {
                if(wr.ingredients.Ingredient_Unit__c.equals('oz.') && wr.ingredients.Quantity__c.equals('1')) {
                    system.assertEquals(wr.convertedUnit,'ml.');
                    system.assertEquals(wr.convertedQuantity,'25');
                }
                //if(wr.ingredients.Ingredient_Unit__c.equals('ml.') && wr.ingredients.Quantity__c.equals('7.393375')) {
                    //system.assertEquals(wr.convertedUnit,'oz.');
                    //system.assertEquals(wr.convertedQuantity,'0.25');
                //} 
            }
            //--
        }   
    }   

    static testMethod void ViewRecipeTest() {
        createData();
       //creating a Master Recipe
        Master_Recipe__c mastRec;
        Recipe__c rec1;
        system.runas(user1){
           mastRec = TestUtil.createMasterRecipe('MasterRecipe');
        
        //Creates a list of Recipes 
        
        rec1 = new Recipe__c();
        rec1.Recipe_Title__c = 'TestRecipe1'; 
        rec1.Master_Recipe__c = mastRec.Id;
        rec1.Status__c = 'Draft';
        rec1.recordSaved__c = true;
        rec1.Main_Drink_Image__c = recm.Id;
        rec1.Mobile_Drink_Image__c = recm.Id;
        rec1.Mobile_Selected_Image__c = recm.Id;
        rec1.Mobile_Unselected_Image__c = recm.Id;
        rec1.Background_Image__c = recm.Id;
        rec1.Brand_Recipe_Image__c = recm.Id;
        rec1.Search_Recipe_Image__c = recm.Id;
        rec1.Additional_Image_1__c = recm.Id;
        rec1.Additional_Image_2__c = recm.Id;
        
        insert rec1;
        
        //Mapping Recipes to the Attributes(Creating Junction Object Records)
        
        Recipe_Attribute__c recattr1 = TestUtil.createRecipeAttribute(rec1.Id,attr1.Id);
        Recipe_Attribute__c recattr2 = TestUtil.createRecipeAttribute(rec1.Id,attr5.Id);
        Recipe_Attribute__c recattr3 = TestUtil.createRecipeAttribute(rec1.Id,attr6.Id);
        Recipe_Attribute__c recattr4 = TestUtil.createRecipeAttribute(rec1.Id,attr7.Id);
        Recipe_Attribute__c recattr5 = TestUtil.createRecipeAttribute(rec1.Id,attr9.Id);
        Recipe_Attribute__c recattr6 = TestUtil.createRecipeAttribute(rec1.Id,attr11.Id);
        /*By Rishi Khirbat on 10th Dec 2012*/
        Recipe_Attribute__c recattr7 = TestUtil.createRecipeAttribute(rec1.Id,attr12.Id);
        Recipe_Attribute__c recattr8 = TestUtil.createRecipeAttribute(rec1.Id,attr13.Id);
        Recipe_Attribute__c recattr9 = TestUtil.createRecipeAttribute(rec1.Id,attr14.Id);
        Recipe_Attribute__c recattr10 = TestUtil.createRecipeAttribute(rec1.Id,attr15.Id);
        Recipe_Attribute__c recattr11 = TestUtil.createRecipeAttribute(rec1.Id,attr16.Id);
        Recipe_Attribute__c recattr13 = TestUtil.createRecipeAttribute(rec1.Id,attr17.Id);
        Recipe_Attribute__c recattr14 = TestUtil.createRecipeAttribute(rec1.Id,attr18.Id);
        /**/
        //Linking Occasions to Recipes Via Junction Object
        
        Recipe_Occasion__c recOcc1 = TestUtil.createRecipeOccasion(rec1.Id,occ1.Id);
        Recipe_Occasion__c recOcc2 = TestUtil.createRecipeOccasion(rec1.Id,occ2.Id);
        Recipe_Occasion__c recOcc3 = TestUtil.createRecipeOccasion(rec1.Id,occ3.Id);
        Recipe_Occasion__c recOcc4 = TestUtil.createRecipeOccasion(rec1.Id,occ4.Id);
        Recipe_Occasion__c recOcc5 = TestUtil.createRecipeOccasion(rec1.Id,occ5.Id);
        Recipe_Occasion__c recOcc6 = TestUtil.createRecipeOccasion(rec1.Id,occ6.Id);
        Recipe_Occasion__c recOcc7 = TestUtil.createRecipeOccasion(rec1.Id,occ7.Id);
        Recipe_Occasion__c recOcc8 = TestUtil.createRecipeOccasion(rec1.Id,occ8.Id);
        Recipe_Occasion__c recOcc9 = TestUtil.createRecipeOccasion(rec1.Id,occ9.Id);
        Recipe_Occasion__c recOcc10 = TestUtil.createRecipeOccasion(rec1.Id,occ10.Id);
        Recipe_Occasion__c recOcc11 = TestUtil.createRecipeOccasion(rec1.Id,occ11.Id);
        Recipe_Occasion__c recOcc12 = TestUtil.createRecipeOccasion(rec1.Id,occ12.Id);
        Recipe_Occasion__c recOcc13 = TestUtil.createRecipeOccasion(rec1.Id,occ13.Id);
        Recipe_Occasion__c recOcc14 = TestUtil.createRecipeOccasion(rec1.Id,occ14.Id);
        Recipe_Occasion__c recOcc15 = TestUtil.createRecipeOccasion(rec1.Id,occ15.Id);
        Recipe_Occasion__c recOcc16 = TestUtil.createRecipeOccasion(rec1.Id,occ16.Id);
        
        
        //Creating Recipe Ingredients
        
        Diageo_Ingredient__c diagIng1 = TestUtil.createRecipeIngredient(true,'1.23','Oz',rec1.Id,diagBrnd1.Id,diagPrdct1.id,null,1);
        Diageo_Ingredient__c diagIng2 = TestUtil.createRecipeIngredient(true,'1.23','Oz',rec1.Id,diagBrnd1.Id,diagPrdct2.id,null,2);
        Diageo_Ingredient__c nonDiagIng1 = TestUtil.createRecipeIngredient(true,'1.23','Oz',rec1.Id,null,null,nonDiagPrdct1.id,3);
        Diageo_Ingredient__c nonDiagIng2 = TestUtil.createRecipeIngredient(true,'1.23','Oz',rec1.Id,null,null,nonDiagPrdct2.id,4);
        
        //Creating Preparation Step 
    
        Preparation_Step__c prepStep1 = TestUtil.createPreparationStep('Test this Recipe1',rec1.Id);
        Preparation_Step__c prepStep2 = TestUtil.createPreparationStep('Test this Recipe2',rec1.Id);
        Preparation_Step__c prepStep3 = TestUtil.createPreparationStep('Test this Recipe3',rec1.Id);
        
        
        /*  * @#UseCase 2: Viewing a  Created Recipe
            * @Description:1.Create a Recipe With atleast One Color,Flavor,Occasion,Diageo Ingredients,Non Diageo Ingredients,preparation steps
            *              2.Select the already Saved Recipe
            * @Expected   : A Recipe in the View Mode is Presented with all the Associated Images,Attributes,Ingredients and Preparation Steps.*/
        
        
        pageReference pRef = page.MM_RecipeView;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('recipeId',rec1.Id);
        MM_RecipeViewController rvc = new MM_RecipeViewController();
        rvc.getCRevApp();
        rvc.editMode = true;
        rvc.createTempRecipe();
        Recipe__c tempRecipe = rvc.getCurrentRecipe();
        
        
        system.assertNotEquals(tempRecipe.Id,null);
        system.assertEquals(tempRecipe.Recipe_Title__c,'TestRecipe1');
        list<selectOption> diagProduct = rvc.getDiageoProducts();
        id colorId = rvc.selColor;
        string recipeColor = rvc.recipeColor;
        string recipeFlavor = rvc.recipeFlavor;
        string recipeType = rvc.recipeType;
        string recipeOcc = rvc.recipeoccasion;
        string recOccType = rvc.recipeoccasionType;
        string recLang = rvc.recipeLanguage;
        /*By Rishi Khirbat on 10th Dec 2012*/
        /**/
        list<Diageo_Ingredient__c> dInList = rvc.getDiageoIngredient();
        
        system.assertEquals(recipeColor,'TestBlue (EN-US)');
        system.assertEquals(recipeFlavor,'TestStrawberry (EN-US), TestBanana (EN-US)');
        //system.assertEquals(recipeFlavor,'TestBanana (EN-US), TestStrawberry (EN-US)');
        
        list<MM_RecipeViewController.dWrapper> dig = rvc.diagIng;
        
        system.assertEquals(dig[0].dProduct,diagPrdct1.Id);
        system.assertEquals(dig[0].ingredient.Ingredient_Number__c,1);
        
        
        list<MM_RecipeViewController.ndWrapper> dnig = rvc.nonDiagIng;
        list<Preparation_Step__c> pStep = rvc.prepSteps;
        
        
        ApexPages.currentPage().getParameters().put('ing','3');
        rvc.deleteDiagIng();
        ApexPages.currentPage().getParameters().put('ing','1');
        rvc.deleteNonDiagIng();
        ApexPages.currentPage().getParameters().put('pStep','2');
        rvc.deletePreparationStep();
        
        /*By Rishi Khirbat on 10th Dec 2012*/
        rvc.localeDetailsFilter();
        rvc.localeIngredientsFilter();
        /**/
        
        //selLocaleDetailsFilter 
        
        //system.assertEquals(pStep.size(),5);
        list<MM_RecipeViewController.recipeImageWrapper> recImage = rvc.getRecipeImages();
        list<MM_RecipeViewController.recipeImageWrapper> attrImage = rvc.getAttributeImages();
        system.runAs(admin){
            rvc.archiveRecipe();
            rvc.saveArchiveRecipe();    
        }
        pageReference pr = rvc.editRecipe();
        }
    }

    static testMethod void fromViewAllTest(){
        createData();
            // @#UseCase 3: Gettign the Values from the View All Recipes page on Search.
            // @Description:1.Search/Filter the Recipes by Selecting the desired Filter criteria
            //              2.A list of Recipes are Returned matching the Given Filter Criteria.
            //               3.Select on one of the Returned Reicpes to View the Recipe in Detail.
            //               4.Go back to the Filter Results Page on Viewing. 
            //@Expected   :The Recipe View gets all the Filter Criteria and Send them  back so that Filtered Results are retained upon going back to the View All Reicpes Page.
             
        //creating a Master Recipe
        Master_Recipe__c mastRec;
        system.runas(user1){
            mastRec = TestUtil.createMasterRecipe('MasterRecipe');
        }
        //Creates a list of Recipes 
        Recipe__c rec1;
        system.runas(user1){
            rec1 = new Recipe__c();
            rec1.Recipe_Title__c = 'TestRecipe1'; 
            rec1.Master_Recipe__c = mastRec.Id;
            rec1.Status__c = 'Draft';
            rec1.recordSaved__c = true;
            insert rec1;
        }
        ApexPages.currentPage().getParameters().put('comingFromViewAll','true');
        ApexPages.currentPage().getParameters().put('recipeId',rec1.Id);
        ApexPages.currentPage().getParameters().put('searchTerm','Test1');
        ApexPages.currentPage().getParameters().put('currentBrand','Test2');
        ApexPages.currentPage().getParameters().put('currentColor','Test3');
        ApexPages.currentPage().getParameters().put('currentFlavor','Test4');
        ApexPages.currentPage().getParameters().put('currentType','Test5');
        ApexPages.currentPage().getParameters().put('currentOccasion','Test6');
        ApexPages.currentPage().getParameters().put('currentStatus','Test7');
        ApexPages.currentPage().getParameters().put('currentIngredientNumber','Test8');
        
        MM_RecipeViewController reCont = new MM_RecipeViewController();
        reCont.checkNull();
        reCont.FilteredResultsView();
        
    }

    static testMethod void ErrorConditionsCheck(){
        createData();
            //@#UseCase 4: Checking/validating the Entered Data for a Recipe before Saving .
            //@Description:1.Enter details for a Recipe that violates the Recipe Creation Requirements.        
            //@Expected   :An Error is shown Specifying the Exact Details for not Saving the Recipe.
        
        pageReference pRef = page.MM_RecipeView;
        Test.setCurrentPage(pRef);
        MM_RecipeViewController rvc = new MM_RecipeViewController();
        system.runAs(editor){
         rvc.createTempRecipe();
        }
        Recipe__c tempRecipe = rvc.getCurrentRecipe();
        system.assertNotEquals(tempRecipe.Id,null);
        system.assertEquals(tempRecipe.Recipe_Title__c,'Enter Recipe Name');
        
        //Name Condition Check.Error Is thrown when Recipe name is not specified.
        system.runAs(editor){       
            rvc.saveRecipe();
            string s = rvc.errorMessage;
            system.assertEquals(s,'Error: Recipe name required');
        }
        
        tempRecipe.Recipe_Title__c = 'TestRecipe';
        
        list<MM_RecipeViewController.dWrapper> dig = rvc.diagIng;
        list<MM_RecipeViewController.ndWrapper> dnig = rvc.nonDiagIng;
        list<Preparation_Step__c> pStep = rvc.prepSteps;
        
        // Error is thrown when User selects Units and Quantity but fails to select a Diageo/Non Diageo Ingredient 
        rvc.diagIng[0].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[0].ingredient.Units__c = 'ml';
        rvc.diagIng[0].ingredient.Featured_Brand__c = true;
        list<selectOption> diagBrands = rvc.getDiageobrands();
        rvc.diagIng[0].brand = diagBrnd1.Id;
        rvc.diagIng[0].dProduct ='select';
        rvc.diagIng[0].ingredient.Quantity__c = '100';
        system.runAs(editor){       
            rvc.saveRecipe();
            string s = rvc.errorMessage;
            system.assertEquals(s,'Error: please add diageo product');
        }
        
        // Error is thrown when User selects Diageo/Non Diageo Ingredients but fails to select Units/Quantity. 
        rvc.diagIng[0].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[0].ingredient.Units__c = 'None';
        rvc.diagIng[0].ingredient.Featured_Brand__c = true;
        rvc.diagIng[0].brand = diagBrnd1.Id;
        rvc.diagIng[0].dProduct = diagPrdct1.Id;
        rvc.diagIng[0].ingredient.Quantity__c = 'None';
        
        system.runAs(editor){       
            rvc.saveRecipe();
            string s = rvc.errorMessage;
            s = s.trim();
            system.assertEquals(s,'Error: Unit required for Diageo Products');
        }
        /*
        rvc.diagIng[0].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[0].ingredient.Units__c = 'ml';
        rvc.diagIng[0].ingredient.Featured_Brand__c = true;
        rvc.diagIng[0].brand = diagBrnd1.Id;
        rvc.diagIng[0].dProduct = diagPrdct1.Id;
        rvc.diagIng[0].ingredient.Quantity__c = '20';
        system.runAs(editor){       
            rvc.saveRecipe();
            rvc.checkImg();
        }
        temprecipe.Additional_Image_1__c = recm.Id;
        
        rvc.prepSteps[0].Description__c = 'Test1';
        rvc.prepSteps[0].Step_Number__c = 1;
        
        //Error condition for atleast one Featured Diageo Ingredient
        rvc.diagIng[0].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[0].ingredient.Units__c = 'ml';
        rvc.diagIng[0].ingredient.Featured_Brand__c = false;
        rvc.diagIng[0].brand = diagBrnd1.Id;
        rvc.diagIng[0].dProduct = diagPrdct1.Id;
        rvc.diagIng[0].ingredient.Quantity__c = '20';
        system.runAs(editor){       
            rvc.saveRecipe();
            rvc.checkImg();
            string s = rvc.errorMessage;
            s = s.trim();
            string c = 'Error:Featured Diageo Ingredient required';
            //system.assertEquals(s,'Error: Featured Diageo Ingredient required');
        }
        
        //checking Error Condition for Two featured Ingredients
        rvc.diagIng[0].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[0].ingredient.Units__c = 'ml';
        rvc.diagIng[0].ingredient.Featured_Brand__c = true;
        rvc.diagIng[0].brand = diagBrnd1.Id;
        rvc.diagIng[0].dProduct = diagPrdct1.Id;
        rvc.diagIng[0].ingredient.Quantity__c = '20';
        
        rvc.diagIng[1].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[1].ingredient.Units__c = 'ml';
        rvc.diagIng[1].ingredient.Featured_Brand__c = true;
        rvc.diagIng[1].brand = diagBrnd1.Id;
        rvc.diagIng[1].dProduct = diagPrdct2.Id;
        rvc.diagIng[1].ingredient.Quantity__c = '20';
        system.runAs(editor){       
            rvc.saveRecipe();
            rvc.checkImg();
            string s = rvc.errorMessage;
            //system.assertEquals(s,'Error: Only one Featured Diageo Ingredient allowed');
        }
        
        //Error for not Entering units for Non Diageo Ingredients
        rvc.diagIng[0].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[0].ingredient.Units__c = 'ml';
        rvc.diagIng[0].ingredient.Featured_Brand__c = false;
        rvc.diagIng[0].brand = diagBrnd1.Id;
        rvc.diagIng[0].dProduct = diagPrdct1.Id;
        rvc.diagIng[0].ingredient.Quantity__c = '20';
        
        rvc.nonDiagIng[0].nd.Recipe_Non_Diageo_Product__c = nonDiagPrdct1.Id;
        rvc.nonDiagIng[0].nd.Units__c = 'ml';
        rvc.nonDiagIng[0].nd.Quantity__c = 'None';
        rvc.nonDiagIng[0].nd.Recipe__c = tempRecipe.Id;
        system.runAs(editor){       
            rvc.saveRecipe();
            string s = rvc.errorMessage;
        }
        */
    }

    static testMethod void cancelEditFunctionalityCheck(){
        createData();
        MM_RecipeViewController rvc = new MM_RecipeViewController();
        system.runas(user1){
            rvc.createTempRecipe();
        }
        Recipe__c tempRecipe = rvc.getCurrentRecipe();
        tempRecipe.Recipe_Title__c = 'testRecipe';
        
        list<MM_RecipeViewController.dWrapper> dig = rvc.diagIng;
        list<MM_RecipeViewController.ndWrapper> dnig = rvc.nonDiagIng;
        list<Preparation_Step__c> pStep = rvc.prepSteps;
        //system.assertEquals(dig.size(),0);
        
        
        rvc.diagIng[0].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[0].ingredient.Units__c = 'ml';
        rvc.diagIng[0].ingredient.Featured_Brand__c = true;
        list<selectOption> diagBrands = rvc.getDiageoBrands();
        rvc.diagIng[0].brand = diagBrnd1.Id;
        list<selectOption> diagProduct = rvc.diagIng[0].getDiageoProducts();
        rvc.diagIng[0].dProduct = diagPrdct1.Id;
        rvc.diagIng[0].ingredient.Quantity__c = '100';
        
        
        list<selectOption> nonDiagProduct = rvc.getNonDiageoProducts();
        rvc.diagIng[1].ingredient.Recipe__c = tempRecipe.Id;
        rvc.diagIng[1].ingredient.Units__c = 'ml';
        rvc.diagIng[1].ingredient.Featured_Brand__c = false;
        rvc.diagIng[1].dProduct = diagPrdct2.Id;
        rvc.diagIng[1].brand = diagBrnd1.Id;
        rvc.diagIng[1].ingredient.Quantity__c = '100';
        
        //rvc.nonDiagIng[0].ingredient = 'Big Banana';
        rvc.nonDiagIng[0].nd.Recipe_Non_Diageo_Product__c = nonDiagPrdct1.Id;
        rvc.nonDiagIng[0].nd.Units__c = 'ss';
        rvc.nonDiagIng[0].nd.Quantity__c = 'sd';
        rvc.nonDiagIng[0].nd.Recipe__c = tempRecipe.Id;
        
        
        rvc.prepSteps[0].Description__c = 'Test1';
        rvc.prepSteps[0].Step_Number__c = 1;
        rvc.prepSteps[1].Description__c = 'Test2';
        rvc.prepSteps[1].Step_Number__c = 2;
        rvc.prepSteps[2].Description__c = 'Test3';
        rvc.prepSteps[2].Step_Number__c = 3;
        rvc.prepSteps[3].Description__c = 'Test4';
        rvc.prepSteps[3].Step_Number__c = 4;
        
        temprecipe.Additional_Image_1__c = recm.Id;
        temprecipe.Additional_Image_2__c  = recm.Id;
        temprecipe.Background_Image__c = recm.Id;
        
        system.runAs(editor){
            rvc.upsertTempRecipe();
            rvc.cancelEdit();
        }
    }
    
    static testMethod void SubmissionTest(){
       createData();
        Recipe_Media__c recm1;
        Recipe__c rec1 ;
        //creating a Master Recipe
        Master_Recipe__c mastRec;
        system.runAs(editor){
        mastRec = TestUtil.createMasterRecipe('MasterRecipe');
          
        rec1 = new Recipe__c();
        rec1.Recipe_Title__c = 'TestRecipe1'; 
        rec1.Master_Recipe__c = mastRec.Id;
        rec1.Status__c = 'Draft';
        rec1.recordSaved__c = true;
        rec1.Main_Drink_Image__c = recm.Id;
        rec1.Mobile_Drink_Image__c = recm.Id;
        rec1.Mobile_Selected_Image__c = recm.Id;
        rec1.Mobile_Unselected_Image__c = recm.Id;
        rec1.Background_Image__c = recm.Id;
        rec1.Brand_Recipe_Image__c = recm.Id;
        rec1.Search_Recipe_Image__c = recm.Id;
        rec1.Additional_Image_1__c = recm.Id;
        rec1.Additional_Image_2__c = recm.Id;
        
        insert rec1;
        
        system.debug('====recm.Id====='+recm1);
        system.debug('====recm.Id====='+rec1);
        //Creates a list of Recipes 
        
        system.debug('====recm.Id====='+attr1);
        //Mapping Recipes to the Attributes(Creating Junction Object Records)
        
        Recipe_Attribute__c recattr1 = TestUtil.createRecipeAttribute(rec1.Id,attr1.Id);
        Recipe_Attribute__c recattr2 = TestUtil.createRecipeAttribute(rec1.Id,attr5.Id);
        Recipe_Attribute__c recattr3 = TestUtil.createRecipeAttribute(rec1.Id,attr6.Id);
        //By Rishi Khirbat on 10th Dec 2012
        Recipe_Attribute__c recattr4 = TestUtil.createRecipeAttribute(rec1.Id,attr7.Id);
        Recipe_Attribute__c recattr5 = TestUtil.createRecipeAttribute(rec1.Id,attr9.Id);
        Recipe_Attribute__c recattr6 = TestUtil.createRecipeAttribute(rec1.Id,attr11.Id);
        Recipe_Attribute__c recattr7 = TestUtil.createRecipeAttribute(rec1.Id,attr12.Id);
        Recipe_Attribute__c recattr8 = TestUtil.createRecipeAttribute(rec1.Id,attr13.Id);
        Recipe_Attribute__c recattr9 = TestUtil.createRecipeAttribute(rec1.Id,attr14.Id);
        Recipe_Attribute__c recattr10 = TestUtil.createRecipeAttribute(rec1.Id,attr15.Id);
        Recipe_Attribute__c recattr11 = TestUtil.createRecipeAttribute(rec1.Id,attr16.Id);
        Recipe_Attribute__c recattr12 = TestUtil.createRecipeAttribute(rec1.Id,attr17.Id);
        Recipe_Attribute__c recattr13 = TestUtil.createRecipeAttribute(rec1.Id,attr18.Id);
        //--
        //Linking Occasions to Recipes Via Junction Object
        
        Recipe_Occasion__c recOcc1 = TestUtil.createRecipeOccasion(rec1.Id,occ1.Id);
        Recipe_Occasion__c recOcc2 = TestUtil.createRecipeOccasion(rec1.Id,occ2.Id);
        Recipe_Occasion__c recOcc3 = TestUtil.createRecipeOccasion(rec1.Id,occ3.Id);
        Recipe_Occasion__c recOcc4 = TestUtil.createRecipeOccasion(rec1.Id,occ4.Id);
        Recipe_Occasion__c recOcc5 = TestUtil.createRecipeOccasion(rec1.Id,occ5.Id);
        Recipe_Occasion__c recOcc6 = TestUtil.createRecipeOccasion(rec1.Id,occ6.Id);
        Recipe_Occasion__c recOcc7 = TestUtil.createRecipeOccasion(rec1.Id,occ7.Id);
        Recipe_Occasion__c recOcc8 = TestUtil.createRecipeOccasion(rec1.Id,occ8.Id);
        Recipe_Occasion__c recOcc9 = TestUtil.createRecipeOccasion(rec1.Id,occ9.Id);
        Recipe_Occasion__c recOcc10 = TestUtil.createRecipeOccasion(rec1.Id,occ10.Id);
        Recipe_Occasion__c recOcc11 = TestUtil.createRecipeOccasion(rec1.Id,occ11.Id);
        Recipe_Occasion__c recOcc12 = TestUtil.createRecipeOccasion(rec1.Id,occ12.Id);
        Recipe_Occasion__c recOcc13 = TestUtil.createRecipeOccasion(rec1.Id,occ13.Id);
        Recipe_Occasion__c recOcc14 = TestUtil.createRecipeOccasion(rec1.Id,occ14.Id);
        Recipe_Occasion__c recOcc15 = TestUtil.createRecipeOccasion(rec1.Id,occ15.Id);
        Recipe_Occasion__c recOcc16 = TestUtil.createRecipeOccasion(rec1.Id,occ16.Id);
        
        
        //Creating Recipe Ingredients
        
        Diageo_Ingredient__c diagIng1 = TestUtil.createRecipeIngredient(true,'1.23','Oz',rec1.Id,diagBrnd1.Id,diagPrdct1.id,null,1);
        Diageo_Ingredient__c diagIng2 = TestUtil.createRecipeIngredient(true,'1.23','Oz',rec1.Id,diagBrnd1.Id,diagPrdct2.id,null,2);
        Diageo_Ingredient__c nonDiagIng1 = TestUtil.createRecipeIngredient(true,'1.23','Oz',rec1.Id,null,null,nonDiagPrdct1.id,3);
        Diageo_Ingredient__c nonDiagIng2 = TestUtil.createRecipeIngredient(true,'1.23','Oz',rec1.Id,null,null,nonDiagPrdct2.id,4);
        
        //Creating Preparation Step 
    
        Preparation_Step__c prepStep1 = TestUtil.createPreparationStep('Test this Recipe1',rec1.Id);
        Preparation_Step__c prepStep2 = TestUtil.createPreparationStep('Test this Recipe2',rec1.Id);
        Preparation_Step__c prepStep3 = TestUtil.createPreparationStep('Test this Recipe3',rec1.Id);
        
        pageReference pRef = page.MM_RecipeView;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('recipeId',rec1.Id);
        MM_RecipeViewController rvc = new MM_RecipeViewController();
        
        rvc.getCRevApp();
        rvc.editMode = true;
        rvc.createTempRecipe();
        Recipe__c tempRecipe = rvc.getCurrentRecipe();
        
        rvc.getApproverList();
        rvc.getEditorList();
        rvc.getReviewerList();  
        rvc.getReviewerReassignList();
        rvc.getAllUserList();
        rvc.getAllUserReassignList();
        rvc.getApproverReassignList();
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('TEST');
            //req1.setNextApproverIds(new Id[]{reviewer.Id});
            req1.setNextApproverIds(new Id[]{approver.Id});
            req1.setObjectId(tempRecipe.Id);   
            
            Approval.ProcessResult result = Approval.process(req1);
            system.runAs(editor){   
                rvc.submitMode = true;
                rvc.submitRecipe();
            }   
            system.runAs(approver){
                rvc.approveRecipe();
                rvc.processApproval('Approve');
            }
            
            system.runAs(approver){
                rvc.rejectRecipe();
                rvc.processApproval('reject');
            }
            
            rvc.archiveRecipe();
            rvc.saveArchiveRecipe();
            
            //By Rishi Khirbat on 10th Dec 2012
            callMiscellaneousFunctions(rvc);
            //--    
        }
    }

    static void createUser(){
        Profile pf = [Select id from Profile where  name = 'System Administrator' LIMIT 1];
        user1 = new User();
        user1.firstName = 'test1';
        user1.LastName = 'test2';
        user1.Alias = '112';
        user1.Email = 'nikita.jain1@metacube.com';
        user1.UserName='nikita.jain.poly1@gmail.com' ;
        user1.ProfileId = pf.id;
        user1.CommunityNickname = user1.firstname+'_1'+user1.lastName;
        user1.EmailEncodingKey ='ISO-8859-1';
        user1.LanguageLocaleKey = 'en_US';
        user1.TimeZoneSidKey ='America/Indianapolis';
        user1.LocaleSidKey = 'en_US';
        insert user1;
    }
    
    /*By Rishi Khirbat on 10th Dec 2012*/
    static void callMiscellaneousFunctions(MM_RecipeViewController rvc) {
        rvc.getAdminReassignList();
        rvc.sBrand();
        rvc.swapImage();
        rvc.showPopupPrep();
        rvc.updatePublishRecipeRecords();
        rvc.cloneRecipe();
        rvc.reassignRecipe();
        rvc.reassignWhenCreated();
        rvc.approveRecipeSubmittedByReviewer();
        rvc.deleteRecipe();
    }
    /**/
}