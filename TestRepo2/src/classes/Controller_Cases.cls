public with sharing class Controller_Cases extends Controller_Base {

    // list of cases to display
    public list<Case> cases {get; set;}

    // current case information
    public Id currentCaseId {get; set;}  
    public list<Attachment> currentCaseAttachments {get; set;}    
    public Case currentCase {get; set;}
    public list<CaseComment> currentCaseComments {get; set;}

    public String actionUrl {get; set; }
   
    // and new comment
    public String newCommentText {get; set;}
    
    // add new cases
    public String newCaseText {get; set;}
    public String newCaseTitleText {get; set;}    
    public String newCasePhone {get; set;}
    public String newCaseEmail {get; set;}
    public String newCaseFirstName {get; set;}
    public String newCaseLastName {get; set;}
    public String newCaseType {get; set;}
    public String newApplication {get; set;}
    public String statusCaseNew {get {return 'New';} protected set;}
    public String statusCaseClosed {get {return 'Closed';} protected set;}
    public String caseOrigin {get {return 'Web';} protected set;}

    public Boolean isCaseAdded {get; protected set;}
    public Boolean isChangeView {get; protected set;}
    public Boolean isCasesExist {get; protected set;}
    
    private User userInfoData {get; private set;}
    
    public Attachment attachment {
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
        }
            set;
        }


    //filters value
    public String displayWithStatus {get; set;}
        
    public Controller_Cases(){
        pageUrl = Page.Cases.getUrl();
        actionUrl = Page.Cases.getUrl();
        addBreadcrumbItem(Page.Cases.getUrl(), Constant.CASES);
        displayWithStatus = statusCaseNew;
        isCaseAdded = false;
        isChangeView = true;
        isCasesExist = false;
        userInfoData = [select Phone, Alternate_Email__c, FirstName, LastName from User where id = :Service_API.getUID() limit 1];
        newCasePhone = userInfoData.Phone;
        newCaseEmail = userInfoData.Alternate_Email__c;
        newCaseFirstName = userInfoData.FirstName;
        newCaseLastName = userInfoData.LastName;
        if(ApexPages.currentPage().getParameters().get('id') != null){
            try {
                currentCaseId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));              
                currentCase = Service_API.getCase(currentCaseId);
                currentCaseAttachments = [select Id, Name from Attachment where ParentId =:currentCaseId and isDeleted = false];
                displayWithStatus = currentCase.Status;         
                currentCaseComments = Service_API.getCaseComment(currentCase);
                addBreadcrumbItem(Page.Cases.getUrl(), 'Case #'+currentCase.CaseNumber);
            } catch( Exception err ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load case.' ));
                return;
            }
        }
        if(ApexPages.currentPage().getParameters().get('caseType') != null && ApexPages.currentPage().getParameters().get('caseType') != ''){
            String requestedNewCaseType = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('caseType'), 'UTF-8');
            Schema.DescribeFieldResult fieldResult = Case.Type.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple)
            {
                if(f.getValue() == requestedNewCaseType){
                    newCaseType = requestedNewCaseType;
                }
            }
            isChangeView = false;               
        }
        cases = Service_API.getUserCases(displayWithStatus);
        system.debug('=======Cases=========='+Cases) ;
        List<Case> allCases = Service_API.getUserCases(null);

        if(allCases.size() == 0){
            isChangeView = false;           
        } else {
            isCasesExist = true;
        }
    }

    public void addNewComment(){
        isChangeView = false;
        isCaseAdded = false;
        if(newCommentText == null || newCommentText == ''){
            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Unable to add new comment. Comment text not found.' ));
        } else {
            CaseComment newCaseComment = new CaseComment();
            newCaseComment.CommentBody = newCommentText;
            newCaseComment.ParentId = currentCaseId;
            if(Service_API.insertCaseComment(newCaseComment)){
                newCommentText = null;
                refreshPageContent();           
            } else {
                ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Unable to add new comment. Error occured during processing.' ));             
            }
        }
    }
    /**
    * @author Appirio Jaipur
    * @date 30/08/2012
    * @ populated Application__c field in case object  
    **/
    public void addNewCase(){
        isCaseAdded = false;
        isChangeView = false;       
        if(newCaseText == null || newCaseText == '' || 
           newCaseTitleText == null || newCaseTitleText == '' ||
           newCaseType == null || newCaseType == '' || 
           newApplication == '' ||newApplication == null 
        ){
            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Unable to add new case. Please fill in form.' ));
        } else {
            Case newCase = new Case();
            newCase.Description = newCaseText;
            newCase.ContactId = Service_API.getCID();
            newCase.AccountId = Service_API.getAID();
            newCase.Status = statusCaseNew;
            newCase.Subject = newCaseTitleText;
            newCase.Phone__c = newCasePhone;
            newCase.Email__c = newCaseEmail;
            newCase.First_Name__c = newCaseFirstName;
            newCase.Last_Name__c = newCaseLastName;
            newCase.Type = newCaseType;
            newCase.Application__c = newApplication;
            newCase.Origin = caseOrigin;
            Id caseId = Service_API.insertCase(newCase);
            
            if(caseId != null){
                // clear user inputs
                newCaseText = null;
                newCaseTitleText = null;
                newCasePhone = userInfoData.Phone;
                newCaseEmail = userInfoData.Alternate_Email__c;
                newCaseFirstName = userInfoData.FirstName;
                newCaseLastName = userInfoData.LastName;
                newCaseType = null;
                newApplication = null;
                
                if(attachment.Body != null){
                    // create attachment
                    attachment.OwnerId = UserInfo.getUserId();
                    attachment.ParentId = caseId;
                    attachment.IsPrivate = true;
                    try {
                          insert attachment;
                        } catch (DMLException e) {
                          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
                        } finally {
                          attachment = new Attachment(); 
                        }
                }
                isCaseAdded = true;
                isCasesExist = true;
                refreshPageContent();
            } else {
                ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Unable to add new case.' ));
            }           
        }
    }

    public void changeViewStatus(){
        isChangeView = true;
        if(displayWithStatus == '' || displayWithStatus == null){
            displayWithStatus = statusCaseNew;
        }
        isCaseAdded = false;
        currentCase = null;
        currentCaseId = null;
        currentCaseComments = null;     
        refreshPageContent();
    }
    
    public List<SelectOption> getCaseStatusList() {
        return Service_UserInput.getCaseStatusList();
    }
    
    public List<SelectOption> getCaseTypeList() {
    	// For case 00003410 by Jai gupta on Jan 28,2013
        //return Service_UserInput.getCaseTypeList();
        return Service_UserInput.getCaseTypeList('Diageo Direct','Type');
        // end for case 00003410
    }
    
    /**
    * @author Appirio Jaipur
    * @date 30/08/2012
    * @description Get the option list of Case Application field
    * @return List<SelectOption> List of the case Application
    */
    public List<SelectOption> getApplicationList() {
    	// For case 00003410 by Jai gupta on Jan 28,2013
        return Service_UserInput.getApplicationList('Diageo Direct','Application__c');
        // end for case 00003410
    }
    
   /* public List<SelectOption> getCMApplicationList() {
        return Service_UserInput.getApplicationList('Control Market');
    }*/  
    
    public override void refreshPageContent(){
        if(currentCaseId != null){
            try {
                currentCase = Service_API.getCase(currentCaseId);
                displayWithStatus = currentCase.Status;         
                currentCaseComments = Service_API.getCaseComment(currentCase);
                cases = Service_API.getUserCases(displayWithStatus);                
            } catch( Exception err ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to reload case.' ));
            }           
        }
        cases = Service_API.getUserCases(displayWithStatus);
    }
    
   private class WrapperCases {
              
        
        
    }
}