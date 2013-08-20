/*
Created by Jai Gupta
for case #00003104 to enable view and submit case functionality for platform user.
*/
public with sharing class Controller_CMCaseCreation{

	// list of cases to display
	public list<Case> cases {get; set;}
	
	public String siteTheme {get;set;}
	/*
		changes done by jai gupta [Appirio Jaipur] for case #00003104 on 21st Nov 2012.
	*/
	public list<wrapperCases> wrapperCaseList {get;set;}
	public wrapperCases currentWCase {get;set;}
	
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
	// For case 00003410 by Jai gupta on Jan 28,2013
	public String newMarketType {get; set;}
	public String newRole {get; set;}
	public String newState {get; set;}
	// End for case 00003410
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
    // For case 00003410 by Jai gupta on Jan 28,2013
    public String placeHolderLabel {get; set;}
    // End for case 00003410    
    public Controller_CMCaseCreation(){
    	// For case 00003410 by Jai gupta on Jan 28,2013
    	placeHolderLabel = Label.Placeholder ;
    	newCaseText = placeHolderLabel ;
    	// End for case 00003410
		//pageUrl = Page.CMCaseCreation.getUrl();
		actionUrl = Page.CMCaseCreation.getUrl();
		siteTheme = Service_API.getSectionTheme();
		//addBreadcrumbItem(Page.CMCaseCreation.getUrl(), Constant.CASES);
		displayWithStatus = statusCaseNew;
        isCaseAdded = false;
        isChangeView = true;
        isCasesExist = false;
        userInfoData = [select Phone, Alternate_Email__c, FirstName, LastName from User where id = :Service_API.getUID() limit 1];
        newCasePhone = userInfoData.Phone;
        newCaseEmail = userInfoData.Alternate_Email__c;
        newCaseFirstName = userInfoData.FirstName;
        newCaseLastName = userInfoData.LastName;
        system.debug('=ApexPages.currentPage().getParameters().get(\'id\')======'+ApexPages.currentPage().getParameters().get('id'));
        if(ApexPages.currentPage().getParameters().get('id') != null){
			try {
				currentCaseId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
				system.debug('===========CurrentCaseId===='+currentCaseId);				
				currentCase = Service_API.getCaseModified(currentCaseId);
				/*
					changes done by jai gupta [Appirio Jaipur] for case #00003104 on 21st Nov 2012.
				*/
				currentWCase = createWrapperCase(currentCase);
				currentCaseAttachments = [select Id, Name from Attachment where ParentId =:currentCaseId and isDeleted = false];
	        	displayWithStatus = currentCase.Status;			
	        	currentCaseComments = Service_API.getCaseComment(currentCase);
				//addBreadcrumbItem(Page.CMCaseCreation.getUrl(), 'Case #'+currentCase.CaseNumber);
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
  		cases = Service_API.getCurrentUserCases(displayWithStatus);
  		/*
			changes done by jai gupta [Appirio Jaipur] for case #00003104 on 21st Nov 2012.
		*/
  		system.debug('=======Cases=========='+Cases) ;
  		wrapperCaseList = refreshWrapperCase(cases);
  		system.debug('=======wrapper Cases=========='+wrapperCaseList);
  		List<Case> allCases = Service_API.getCurrentUserCases(null);

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
        // For case 00003410 by Jai gupta on Jan 28,2013		
		if(newCaseText == null || newCaseText == '' || newCaseText.equalsIgnoreCase(placeHolderLabel) ||
		   newCaseTitleText == null || newCaseTitleText == '' ||
		   newCaseType == null || newCaseType == '' || 
		   newApplication == '' ||newApplication == null ||
		   newCaseEmail == '' || newCaseEmail == null ||
		   newCasePhone == '' || newCasePhone == null
	    ){
	    	system.debug('============values======'+newCaseText+newCaseTitleText+newCaseType+newApplication+newCaseEmail+newCasePhone);
            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Unable to add new case. Please fill in form.' ));
		} else {
			Case newCase = new Case();
			newCase.Description = newCaseText;
			//newCase.ContactId = Service_API.getCID();
			try {
				newCase.AccountId = Service_API.getAID();
			}catch(exception e){
				newCase.AccountId = null ;
			}
			newCase.Status = statusCaseNew;
			newCase.Subject = newCaseTitleText;
			newCase.Phone__c = newCasePhone;
			newCase.Email__c = newCaseEmail;
			newCase.First_Name__c = newCaseFirstName;
			newCase.Last_Name__c = newCaseLastName;
			newCase.Type = newCaseType;
			newCase.Application__c = newApplication;
			newCase.Origin = caseOrigin;
			// For case 00003410 by Jai gupta on Jan 28,2013
			newCase.Market_Type__c = newMarketType ;
	    	newCase.Role__c = newRole ;
	    	newCase.State__c = newState ;
		    // end for case 00003410	
			Id caseId = Service_API.insertCase(newCase);
			
			if(caseId != null){
				// clear user inputs
				// For case 00003410 by Jai gupta on Jan 28,2013
				//newCaseText = null;
				newCaseText = placeHolderLabel;
				// End for case 00003410
				newCaseTitleText = null;
		        newCasePhone = userInfoData.Phone;
		        newCaseEmail = userInfoData.Alternate_Email__c;
		        newCaseFirstName = userInfoData.FirstName;
		        newCaseLastName = userInfoData.LastName;
				newCaseType = null;
				newApplication = null;
				// For case 00003410 by Jai gupta on Jan 28,2013
		    	newMarketType = null ;
		    	newRole = null ;
		    	newState = null ;
		    	// end for case 00003410
				
				if(attachment.Body != null){
					// create attachment
				    attachment.OwnerId = UserInfo.getUserId();
				    attachment.ParentId = caseId;
				    attachment.IsPrivate = true;
					try {
						// Changes done by Jai Gupta [Appirio Jaipur] for case #00003417 on Dec 07,2012
						  Service_API.insertAttachment(attachment);
					      //insert attachment;
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
    	return Service_UserInput.getCaseTypeList('Control Market','Type');
        //return Service_UserInput.getCaseTypeList();
    }
    
    /**
    * @author Appirio Jaipur
    * @date 30/08/2012
    * @description Get the option list of Case Application field
    * @return List<SelectOption> List of the case Application
    */
    public List<SelectOption> getCMApplicationList() {
    	//return null;
        return Service_UserInput.getApplicationList('Control Market','Application__c');
    }
    
     /**
    * @author Appirio Jaipur [Jai Gupta]
    * @date 28/01/2013
    * @description Get the option list of Case Market type field
    * @return List<SelectOption> List of the case Market Type
    */
     public List<SelectOption> getCMMarketTypeList() {
        return Service_UserInput.getMarketTypeList();
    }
    
     /**
    * @author Appirio Jaipur [Jai Gupta]
    * @date 28/01/2013
    * @description Get the option list of Case Role field
    * @return List<SelectOption> List of the case Role
    */
     public List<SelectOption> getCMRoleList() {
        return Service_UserInput.getRoleList();
    }
    /*
    	create a list of wrapper cases to access the case object by platform user.
    
		changes done by jai gupta [Appirio Jaipur] for case #00003104 on 21st Nov 2012.
	
    */
    private list<wrapperCases> refreshWrapperCase(List<Case> cases) {
    	list<wrapperCases> wrapperList = new list<wrapperCases>(); 
  		for(Case c : cases) {
  			wrapperCases wc = new wrapperCases();
  			wc.caseId = c.Id ;
  			wc.caseSubject = c.Subject ;
  			wc.caseLastModifiedDate = c.LastModifiedDate ;
  			wrapperList.add(wc) ;
  		}
  		return wrapperList ;
    }
    /*
    	create a wrapper case to access the case object by platform user.
    	changes done by jai gupta [Appirio Jaipur] for case #00003104 on 21st Nov 2012.
    */
    private wrapperCases createWrapperCase(Case caseObj) {
    	wrapperCases wc = new wrapperCases();
    	wc.caseId = caseObj.Id ;
    	wc.caseSubject = caseObj.Subject ;
    	wc.caseLastModifiedDate = caseObj.LastModifiedDate ;
    	wc.caseStatus = caseObj.Status ;
    	wc.caseNumber = caseObj.CaseNumber ;
    	wc.caseDescription = caseObj.Description ;
    	// For case 00003410 by Jai gupta on Jan 28,2013
    	//wc.State = caseObj.State__c ;
    	//wc.marketType = caseObj.Market_type__c ;
    	//wc.role = caseObj.Role__c ;
    	// end for case 00003410
    	return wc ;
    }
    
    public void refreshPageContent(){
    	if(currentCaseId != null){
			try {
				currentCase = Service_API.getCaseModified(currentCaseId);
	        	displayWithStatus = currentCase.Status;			
	        	currentCaseComments = Service_API.getCaseComment(currentCase);
  				cases = Service_API.getCurrentUserCases(displayWithStatus);
  				/*
  					changes done by jai gupta [Appirio Jaipur] for case #00003104 on 21st Nov 2012.
  				*/
  				wrapperCaseList = refreshWrapperCase(cases);	        	
	        } catch( Exception err ){
	            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to reload case.' ));
        	}    		
    	}
		cases = Service_API.getCurrentUserCases(displayWithStatus);
		/*
  			changes done by jai gupta [Appirio Jaipur] for case #00003104 on 21st Nov 2012.
  		*/
		wrapperCaseList = refreshWrapperCase(cases);
    }
	
	/*
	Wrapper class to show the cases on VF page for Platform license user
	changes done by jai gupta [Appirio Jaipur] for case #00003104 on 21st Nov 2012.
	*/
	public class WrapperCases {
		public id caseId {get;set;}
		public string caseSubject {get;set;}
		public string caseStatus {get;set;}
		public string caseNumber {get;set;}
		public string caseDescription {get;set;}
		// For case 00003410 by Jai gupta on Jan 28,2013
		//public string State {get;set;}
		//public string marketType {get;set;}
		//public string role {get;set;}
		// end for case 00003410
		public datetime caseLastModifiedDate {get;set;}
	}    
}