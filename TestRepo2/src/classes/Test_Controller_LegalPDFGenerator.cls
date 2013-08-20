@isTest(SeeAllData=false)
private class Test_Controller_LegalPDFGenerator {

   //Arrange, Act, Assert
   static testMethod void test_Controller_LegalPDFGenerator() {     

    //Arrange
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
    
    String theIds = null;
    for( State_Rules__c rul : stateRules)
    {
        theIds = theIds + ',' + rul.id;
    }
    
    PDF_State_Rules__c pdf = new PDF_State_Rules__c(State_Rules_ID__c =  theIds);        
    insert pdf;   

    PageReference pageRef = new PageReference('/apex/LegalPDF?id=' + pdf.id);        
    Test.setCurrentPage(pageRef);
       
    //Act 0    
    Controller_LegalPDFGenerator controller = new Controller_LegalPDFGenerator();   
     
        
    //Assert 0
    System.assertequals(500, controller.Issues.size());
    
   }
}