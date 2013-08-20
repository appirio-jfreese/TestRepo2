@isTest
private class Test_Controller_ActionCreationPage {
/*
    static testMethod void testController() {
        // This page is largely written in JS and JQuery, not Apex,
        //   so this test will be minimal
        Controller_ActionCreationPage cont = new Controller_ActionCreationPage();
        cont.addReadOnlyMessage();
        cont.addRepReadOnlyMessage();
        
        Controller_ActionCreationPage.getAccounts(new List<String>());
        Controller_ActionCreationPage.getChannels();
        Controller_ActionCreationPage.getManagerGoals();
        Controller_ActionCreationPage.getManagerTerritories();
        Controller_ActionCreationPage.getRepGoals();
        Controller_ActionCreationPage.getRepTerritories();
        
        Goal__c parentGoal = new Goal__c();
        parentGoal.Goal_Type__c = 'Off-Premise';
        insert parentGoal;
        
        List<Goal__c> goals = new List<Goal__c>();
        Goal__c goal = new Goal__c();
        goal.Parent_Goal__c = parentGoal.Id;
        goals.add(goal);
        
        Test_RecordUtil.ensureBrandCanBeCreated();
        Brand__c brand = Test_RecordUtil.newBrand('test brand');
        insert brand;
        Bottle_Size__c bs = Test_RecordUtil.newBottleSize('test bs');
        insert bs;
        BrandBottle_Size__c bbs = Test_RecordUtil.newBrandBottleSize('test bbs', brand.Id, bs.Id);
        insert bbs;
        Brand_Bottle_Goal__c parentBBG = new Brand_Bottle_Goal__c();
        parentBBG.Goal__c = parentGoal.Id;
        parentBBG.BrandBottle_Size__c = bbs.Id;
        insert parentBBG;
        
        Controller_ActionCreationPage.saveGoals(goals, false);
        
        Controller_ActionCreationPage.saveActions(new List<Action__c>(), false);
        
        cont = new Controller_ActionCreationPage();
        cont.getUserAgent();
        cont.addReadOnlyMessage();
        cont.addRepReadOnlyMessage();
        cont.assignDummyViewGoal();
        
        List<RecordType> goalRTs = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Goal__c'];
        Map<String, Id> goalRTIdsByName = new Map<String, Id>();
        for(RecordType rt : goalRTs){
        	goalRTIdsByName.put(rt.Name, rt.Id);
        }
        cont.dummyGoalId = parentGoal.Id;
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Display Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Distribution Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('General Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Ad Execution');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Ease of Shop');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Feature Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Menu Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Shelf Set Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Staff Training Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Window Display Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Bar Promotion Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Cold Box Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        parentGoal.RecordTypeId = goalRTIdsByName.get('Tasting Goals');
        update parentGoal;
        cont.assignDummyGoal();
        
        cont.dummyBBG = new Brand_Bottle_Goal__c();
        cont.dummyBBG.BrandBottle_Size__c = bbs.Id;
        cont.bbgSelName = 'dummy BBG';
        cont.addBBG();
        cont.removeBBGs();
        
        cont.saveGoal();
    }*/
}