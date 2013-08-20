/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_ControllerBasket {

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
        
        // hook one of the parent brands too the user's account
        AccountBrand__c accBrand = Test_Helper.testInsertAccountBrand(a.ID, brandA.ID);
        
        // insert test content that looks up to the previoulsy inserted brands
        Content_Description__c contentA = Test_Helper.testInsertContentDescriptionExtended('rose');
        Content_Description__c contentB = Test_Helper.testInsertContentDescriptionExtended('orchid');
        Content_Description__c contentC = Test_Helper.testInsertContentDescriptionExtended('tulip');
        
        contentA.Content_Version_Id_Low__c = contentA.Content_Version_Id__c;
        contentA.Content_Version_Id__c = null;
        update contentA;
        
        
        // insert the join records between content and brand        
        ContentBrand__c cbA = Test_Helper.testInsertContentBrand(contentA.id, brandA.id);
        ContentBrand__c cbB = Test_Helper.testInsertContentBrand(contentB.id, brandA.id);
        ContentBrand__c cbC = Test_Helper.testInsertContentBrand(contentC.id, brandA.id);
        
        Test.startTest();

        PageReference pageRef = Page.Basket;
        Test.setCurrentPage(pageRef);
                
        System.runAs(u){
            Controller_Basket cBasket = new Controller_Basket();
            
            // clear basket
            cBasket.clearBasket();
            System.assertEquals(0, cBasket.basketItemsNo);
            
            // add single
            cBasket.cVersionId = contentB.Content_Version_Id__c;
            
            cBasket.addToBasket();
            System.assertEquals(1, cBasket.basketItemsNo);
            
            //remove single
            cBasket.removeFromBasket();
            System.assertEquals(0 , cBasket.basketItemsNo);
            
            // add multiple
            cBasket.cVersionIds = contentA.Content_Version_Id_Low__c+','+contentB.Content_Version_Id__c;
            cBasket.addToBasketMultiple();
            System.assertEquals(2, cBasket.basketItemsNo);
            
            cBasket.refreshPageContent();
            
            //remove multiple
            cBasket.removeFromBasketMultiple();
            System.assertEquals(0, cBasket.basketItemsNo);


            Service_Basket.getNumberOfItems();

            cBasket.showFirstPage();
            cBasket.showPrevPage();

            delete cbA;
            delete cbB;
            delete cbC;
            cBasket.refreshPageContent();
            cBasket.removeTrashFromBasket();
            
        }
        
        Test.stopTest();
    }

}