@IsTest
private class Service_Test {
    
    /**
    * @author Denise Bacher
    * @date 04/08/2011
    * @description Test the brand controller, insert brands, child brands, and test that the user has access to the correct ones.
    */
    static testmethod void testBrands(){
        // insert test user data
        Account a = Test_Helper.testInsertAccount('Test Account');
        Contact c = Test_Helper.testInsertContact('TestFirst', 'TestLast', a.ID);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];   
        User u;
        System.runAs (thisUser) {
        	u = Test_Helper.testInsertDistributorPortalUser(c.ID);
        }
        
        // insert test brands
        Brand__c brandA = Test_Helper.testInsertBrand('Test Brand A');
        Brand__c brandAchildA = Test_Helper.testInsertChildBrand('Test Brand A Child A', brandA.ID);
        Brand__c brandAchildB = Test_Helper.testInsertChildBrand('Test Brand A Child B', brandA.ID);

        Brand__c brandB = Test_Helper.testInsertBrand('Test Brand B');
        Brand__c brandBchildA = Test_Helper.testInsertChildBrand('Test Brand B Child A', brandB.ID);
        Brand__c brandBchildB = Test_Helper.testInsertChildBrand('Test Brand B Child B', brandB.ID);
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand1 = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        AccountBrand__c accBrand2 = Test_Helper.testInsertAccountBrand(a.ID, brandB.ID);
        AccountBrand__c accBrand3 = Test_Helper.testInsertAccountBrand(a.ID, brandBchildA.ID);
        AccountBrand__c accBrand4 = Test_Helper.testInsertAccountBrand(a.ID, brandAchildA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        ContentVersion contentA = Test_Helper.testInsertDistributorContent('rose', 'http://pixabay.com/static/uploads/photo/2011/05/31/21/33/rose-7771_150.jpg', null);
        ContentVersion contentB = Test_Helper.testInsertDistributorContent('orchid', 'http://pixabay.com/static/uploads/photo/2011/02/18/00/04/flower-4935_150.jpg', null);
        ContentVersion contentC = Test_Helper.testInsertDistributorContent('tulip', 'http://pixabay.com/static/uploads/photo/2011/03/16/14/53/tulips-5255_150.jpg', null);

        // insert the join records between content and brand        
        ContentBrand__c cbA = Test_Helper.testInsertContentBrand(contentA.Content_Description__c, brandA.id);
        ContentBrand__c cbB = Test_Helper.testInsertContentBrand(contentB.Content_Description__c, brandB.id);
        
        Test.startTest();
        // test that the user can only see brandA that links to his account
        System.runAs(u){
            Set<ID> brandIDs = Service_API.getAccBrandIds();
            
            System.assert(brandIDs.contains(brandA.id));
            System.assert(brandIDs.contains(brandB.id));
            System.assert(brandIDs.contains(brandBchildA.id));
            System.assert(brandIDs.contains(brandAchildA.id));
            
            System.assert(!brandIDs.contains(brandAchildB.id));
            System.assert(!brandIDs.contains(brandBchildB.id));
        }
        
        // check child access
        System.runAs(u){
            List<Brand__c> myChildBrandsA = Service_API.getChildBrands(brandA.ID);
            System.assertEquals(myChildBrandsA.size(), 1);
            for(Brand__c ab: myChildBrandsA){
                System.assertEquals(ab.Parent_Brand__c, brandA.Id);
            }


            List<Brand__c> myChildBrandsB = Service_API.getChildBrands(brandB.ID);
            System.assertEquals(myChildBrandsB.size(), 1);
            
            for(Brand__c ab: myChildBrandsB){
                System.assertEquals(ab.Parent_Brand__c, brandB.Id);
            }
            
            List<ContentVersion> brandContent = Service_API.getBrandContent(brandA.ID);
            System.assert(brandContent.size() > 0);
            for(ContentVersion cv: brandContent){ 
                System.assert(Service_API.getContentBrandIDs(brandA.ID).contains(cv.Content_Description__r.Content_ID__c));
            }
        }
        
        // test that the user cannot see child brands or content of brandAchildB and brandBchildB
        System.runAs(u){
            List<Brand__c> myChildBrandsAB = Service_API.getChildBrands(brandAchildB.ID);
            System.assert(myChildBrandsAB.size() == 0);
            
            List<Brand__c> myChildBrandsBB = Service_API.getChildBrands(brandBchildB.ID);
            System.assert(myChildBrandsBB.size() == 0);
            
            List<ContentVersion> brandContentAB = Service_API.getBrandContent(brandAchildB.ID);
            System.assert(brandContentAB.size() == 0);
            
            List<ContentVersion> brandContentBB = Service_API.getBrandContent(brandBchildB.ID);
            System.assert(brandContentBB.size() == 0);
        }
        
        delete brandA;
        delete brandB;
        
        Test.stopTest();
    }
   
}