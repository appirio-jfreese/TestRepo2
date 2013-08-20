@isTest(SeeAllData=false)
private class Test_Controller_Legal {

   //Arrange, Act, Assert
   static testMethod void test_findIssues() {     

    //Arrange
  //  test.startTest();
    
    PageReference pageRef = Page.Legal;
    Test.setCurrentPage(pageRef);

    
    List<State__c> states = new List<State__c>{};
    for(Integer i = 0; i < 50; i++){
        State__c s = new State__c(Name = 'State ' + i, Name__c = 'State ' + i);
        states.add(s);
    }
    insert states;
        
    List<Rule__c> rules = new List<Rule__c>{};
    for(Integer i = 0; i < 10; i++){
        Rule__c r = new Rule__c(Name = 'Rule ' + i);
        rules.add(r);
    }
    insert rules;
    
        
    List<State_Rules__c> stateRules = new List<State_Rules__c>{};
    for(State__c s : states)
    {
        for(Rule__c r : rules)
        {
            State_Rules__c sr = new State_Rules__c(
                State__c = s.id,
                Rule__c = r.id,
                Applicability_Comment__c = 'New Comment',
                Rule_Applies__c = 'Yes');
                
            stateRules.add(sr);
        }
    }
    insert stateRules;
       
    
    Controller_Legal controller = new Controller_Legal();   
     
    List<SelectOption> actualStateOptions = controller.getStatesForList();     // Gets all states 
    List<SelectOption> actualRuleOptions = controller.getRulesForList();      //Gets all issue topics
    
    //Act 0
    controller.selectedState = new List<String>{};
    controller.selectedRule = new List<String>{};
    controller.findIssues(); //Gets issues for selected topics & states
        
    //Assert 0
    System.assertequals(50, actualStateOptions.size()); 
    System.assertequals(10, actualRuleOptions.size());
    System.assertequals(0, controller.selectedRule.size()); 
    System.assertequals(0, controller.selectedState.size());
    System.assertequals(false, controller.displayList);
    //System.assertequals(null, controller.issues);  //how do i test for nulls??
    
    //Act 1
    controller.selectedState = new List<String>{states[0].id};
    controller.selectedRule = new List<String>{};
    controller.findIssues(); //Gets issues for selected topics & states
        
    //Assert 1
    System.assertequals(50, actualStateOptions.size()); 
    System.assertequals(10, actualRuleOptions.size());
    System.assertequals(0, controller.selectedRule.size()); 
    System.assertequals(1, controller.selectedState.size());
    System.assertequals(10, controller.issues.size());
    System.assert(controller.displayList);
    
    //Act 2
    controller.selectedState = new List<String>{};
    controller.selectedRule = new List<String>{rules[0].id};
    controller.findIssues(); //Gets issues for selected topics & states
        
    //Assert 2
    System.assertequals(50, actualStateOptions.size()); 
    System.assertequals(10, actualRuleOptions.size());
    System.assertequals(1, controller.selectedRule.size()); 
    System.assertequals(0, controller.selectedState.size());
    System.assertequals(50, controller.issues.size());
    System.assert(controller.displayList);
    
    //Act 3
    controller.selectedState = new List<String>{states[0].id};
    controller.selectedRule = new List<String>{rules[0].id};
    controller.findIssues(); //Gets issues for selected topics & states
        
    //Assert 3
    System.assertequals(50, actualStateOptions.size()); 
    System.assertequals(10, actualRuleOptions.size());
    System.assertequals(1, controller.selectedRule.size()); 
    System.assertequals(1, controller.selectedState.size());
    System.assertequals(1, controller.issues.size());
    System.assert(controller.displayList);
  
    //Arrange
    //PageReference ref = controller.sendPDF(); //inserts a new pdf_state_rules_c with the searched ids and returns a reference to view those ids.    

//    test.stopTest();
    
    //ApexPages.StandardController sc = new ApexPages.standardController(calendarMep);      
         
    //System.assertequals(4, (controller.getRecordTypes()).size());
    
    
    //PageReference pr = controller.saveCloneCalendar();
    //String url = pr.getUrl();
    //String colonedId = url.substring(1, url.length());
    
    //Calendar__c clonedCalendar = [Select c.background_color__c, c.Type__c, c.Theme__c, c.Text_Color__c, c.SystemModstamp, c.Start_Date__c, c.Specification_Text__c, c.Specification_Content_Description__c, c.Situation_Text__c, c.Situation_Content_Description__c, c.Ship_Date__c, c.Segment__c, c.Sales_Channel__c, c.RecordTypeId, c.Programs__c, c.Priority__c, c.Name, c.Logo_Image_Small__c, c.Logo_Image_Large__c, c.Launch_Date__c, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Idea_Text__c, c.Idea_Content_Description__c, c.Id, c.How_it_Works_Text__c, c.How_it_Works_Content_Description__c, c.Folder__c, c.End_Date__c, c.Description__c, c.Description_Content_Description__c, c.CreatedDate, c.CreatedById, c.Consumer_Target_Text__c, c.Consumer_Target_Content_Description__c, c.Background_Color2__c, c.Archive__c From Calendar__c c Where c.Id = :colonedId];
   
   }
}