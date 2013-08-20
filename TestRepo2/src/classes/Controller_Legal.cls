// Copyright (c) 2011, Nick Eales, Sales Engineering, Salesforce.com Inc.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
// Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// Neither the name of the salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 // EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
public with sharing class Controller_Legal extends Controller_Base
{

    public Boolean tooManyRecords {get; set;}   
    public List<String> selectedState {get; set;}
    public List<String> selectedRule {get; set;}
    private List<State__c> stas {get; set;}
    private List<Rule__c> ruls {get; set;}
    public List<State_Rules__c> issues {get; set;}
    private String theIds;

    public Boolean displayList {get;set;}
    
    public Controller_Legal()
    {
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), 'Legal');
  
        displayList = false;
        tooManyRecords = false;
        theIds = ',';
        stas = [SELECT id, name FROM State__c ORDER BY name];
        ruls = [SELECT id, name FROM Rule__c ORDER BY name];
    }
    
          
    public List<SelectOption> getStatesForList()
    {   
        List<SelectOption> options = new List<SelectOption>();
        for( State__c sta : stas)
        {
          options.add(new SelectOption(sta.id, sta.name));
        }
        return options;
    }
    
    public List<SelectOption> getRulesForList()
    {   
        List<SelectOption> options = new List<SelectOption>();
        for( Rule__c rul : ruls)
        {
          options.add(new SelectOption(rul.id, rul.name));
        }
        return options;
    }
    
    
  
    public void findIssues(){
    
        issues = new List<State_Rules__c>();
        theIds = null;
    
            if(selectedState.size() > 0 && selectedRule.size() > 0)
            {
                issues = [SELECT id, name, State__c, Rule_Applies__c, Rule__r.Name, State__r.Name, Rule__c, Applicability_Comment__c, Statute_Ref__c 
                        FROM State_Rules__c 
                       WHERE (State__c in :selectedState AND Rule__c in :selectedRule) 
                    ORDER BY State__r.Name, Rule__r.Name
                    LIMIT 400];
             }
             else if(selectedState.size() > 0)
             {
                issues = [SELECT id, name, State__c, Rule_Applies__c, Rule__r.Name, State__r.Name, Rule__c, Applicability_Comment__c, Statute_Ref__c
                        FROM State_Rules__c 
                       WHERE (State__c in :selectedState) 
                    ORDER BY State__r.Name, Rule__r.Name
                    LIMIT 400];
             }
             else if(selectedRule.size() > 0)
             {
                issues = [SELECT id, name, State__c, Rule_Applies__c, Rule__r.Name, State__r.Name, Rule__c, Applicability_Comment__c, Statute_Ref__c
                            FROM State_Rules__c 
                           WHERE (Rule__c in :selectedRule) 
                        ORDER BY State__r.Name, Rule__r.Name
                        LIMIT 400];
             }
             else
             {
                  return;
             }
        
        if(issues.isEmpty())
        {
            displayList = false;
            tooManyRecords = false;
        }
        else if (issues.size() > 399)
        {
            displayList = false;
            tooManyRecords = true;
        }
        else
        {
            for( State_Rules__c rul : issues)
            {
                theIds = theIds + ',' + rul.id;
            }
            displayList = true;
            tooManyRecords = false;
        }
    }
    
     public PageReference sendPDF()
    {             
        PDF_State_Rules__c pdf = new PDF_State_Rules__c(State_Rules_ID__c =  theIds);        
        insert pdf;        
        PageReference pdfPage = new PageReference('/apex/LegalPDF?id=' + pdf.id);        
        return pdfPage;              
    }

     
}