public with sharing class Controller_LegalPDFGenerator{
    
    private List<String> theIds;
    private PDF_State_Rules__c pdf;
    public List<State_Rules__c> Issues {get; set;}
     
    public Controller_LegalPDFGenerator(){
        
        
        pdf = new PDF_State_Rules__c();
        pdf = [SELECT State_Rules_ID__c FROM PDF_State_Rules__c WHERE Id =: ApexPages.CurrentPage().getParameters().get('id')];
        
          
        theIds = pdf.State_Rules_ID__c.split(',');
        
        Issues = [SELECT id, name, State__c, Rule_Applies__c, Rule__r.Name, State__r.Name, Rule__c , Applicability_Comment__c, Statute_Ref__c 
                        FROM State_Rules__c 
                       WHERE id in :theIds
                    ORDER BY State__r.Name, Rule__r.Name];     
        
    }
    
    
}