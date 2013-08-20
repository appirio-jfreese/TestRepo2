/*****************************************************************************************************************
Name        : CheckboxOption.cls

Updated By  : Basant Verma (Appirio Offshore)   
Date        : 5/27/13
Story/Task  : US85/TA910
*****************************************************************************************************************/
public with sharing class CheckboxOption {
    public String name {get;set;}
    public Boolean chosen {get;set;}
    public Boolean disabled {get;set;}
    // Start : For US85/TA910
    public List<CheckboxOption> subOptions {get; set;}
    // End : For US85/TA910
    public CheckboxOption (String name, Boolean chosen, Boolean disabled) {
        this.name = name;
        this.chosen = chosen;
        this.disabled = disabled;
        // Start : For US85/TA910
        this.subOptions = new List<CheckboxOption>();
        // End : For US85/TA910
    }
    
    public CheckboxOption (String name, Boolean chosen, Boolean disabled, List<CheckboxOption> subOptions) {
        this.name = name;
        this.chosen = chosen;
        this.disabled = disabled;
        // Start : For US85/TA910
        this.subOptions = subOptions;
        // End : For US85/TA910
    }
}