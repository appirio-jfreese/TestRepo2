public without sharing class ControllerControlMarketCases {
    public List<WrapperCase> WrapperOpenCaseList {get; set;}
    public List<WrapperCase> WrapperClosedCaseList {get; set;}
    public String sortIdentifier {get; set;}
    set<String> profileIds;
    public List<Case> cases;
    public Boolean isAsc {get;set;}
    public String sortField {get;set;}
    public String isCsv;
    //rahul changes 00005400
     private String sortDirection = 'ASC';
     private String sortExp = 'Case_Age__c';
     public String sortExpression
     {
     get
     {
        return sortExp;
     }
     set
     {
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp)
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'ASC';
       sortExp = value;
     }
   }
    //rahul changes End
    
    public ControllerControlMarketCases(){
        WrapperOpenCaseList = new List<WrapperCase>();
        WrapperClosedCaseList = new List<WrapperCase>();
        List<Control_Market_Profile__c> cmp = Control_Market_Profile__c.getall().values();
        profileIds= new Set<String>();
        for(Control_Market_Profile__c controlMarketProfile : cmp ){
            profileIds.add(controlMarketProfile.ProfileId__c);
        }
        
        isCsv = ApexPages.CurrentPage().getParameters().get('csv');
        system.debug('====isCsv=' + isCsv);
        sortIdentifier = 'AllCases';
       ViewData();
    }
 
   //Commented getter out for Case 5400 and moved logic to constructor/ViewData method - Diana Acker - 5/31/13
    /*public List<WrapperCase> getWrapperOpenCaseList(){
    WrapperOpenCaseList = new list<WrapperCase>();
    String caseComment;
    String caseComment2;*/
     /*cases =  [SELECT  Id,Owner.Username,Contact.Name, CreatedDate, ClosedDate, State__c, Subject,Case_Age__c,Appirio_Request_Type__c,Description, CaseNumber, status, priority, type, LastModifiedDate,(Select Id,CommentBody, LastModifiedDate From CaseComments order by LastModifiedDate DESC)
                    FROM Case where CreatedBy.ProfileId in : profileIds ORDER BY CreatedDate
                    ]; */
        // string sortFullExp = sortExpression  + ' ' + sortDirection;           
         //cases = Database.query('SELECT Id,Owner.Username,Contact.Name, CreatedDate, ClosedDate, State__c, Subject,Case_Age__c,Appirio_Request_Type__c,Description, CaseNumber, status, priority, type, LastModifiedDate,(Select Id,CommentBody, LastModifiedDate From CaseComments order by LastModifiedDate DESC) FROM Case where CreatedBy.ProfileId in : profileIds AND closedDate = null ORDER BY '+ sortFullExp + ' limit 1000');
                 
        /*if(cases.size() > 0){
            for(Case c : cases){
                if (c.ClosedDate == null){
                 WrapperCase wrappedCase = new WrapperCase();
                 wrappedCase.userName = c.Owner.Username;
                 wrappedCase.CaseNumber = c.CaseNumber;
                 wrappedCase.openDate = getOpenDate(c.Case_Age__c);
                 wrappedCase.subject = c.Subject;
                 wrappedCase.age = c.Case_Age__c;
                 wrappedCase.Appirio_Request_Type = c.Appirio_Request_Type__c;
                 wrappedCase.Description = c.Description;
                 if(c.CaseComments.size() > 0 ){
                 caseComment = c.CaseComments[0].CommentBody;
                 caseComment=caseComment.replaceAll(',','');
                 System.debug('----Case Comment after removal of comma'+caseComment);
                 
                 wrappedCase.caseComement = caseComment;
                 System.debug('-----------'+wrappedCase.caseComement);
                 }
                 else
                 wrappedCase.caseComement = '';
                 //START Case 00005400 - DIANA ACKER
                 wrappedCase.contact = c.Contact.Name;
                 wrappedCase.state = c.State__c;
                 if(c.ClosedDate != null){
                    wrappedCase.closeDate = getCloseDate(c.ClosedDate);
                }
                 //END Case 00005400
                 WrapperOpenCaseList.add(wrappedCase);
                }
                
            }
            
        }
        
        return   WrapperOpenCaseList;          
  }*/
  
 
  
  private String getOpenDate(Decimal age){
    datetime todayDate = datetime.now();
    datetime openDate = todayDate.addDays(integer.valueof(-age));
    return openDate.format('MM/dd/yyyy');
  }
  
  private String getCloseDate(DateTime closedDate){
    return closedDate.format('MM/dd/yyyy', 'America/New_York');
  }
  //rahul changes 00005400
    public PageReference ViewData() {
         String caseComment;
        String caseComment2;

       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       //query the database based on the sort expression
       cases = Database.query('SELECT Id,Owner.Username,Contact.Name, CreatedDate, ClosedDate, State__c, Subject,Case_Age__c,Appirio_Request_Type__c,Description, CaseNumber, status, priority, type, LastModifiedDate,(Select Id,CommentBody, LastModifiedDate From CaseComments order by LastModifiedDate DESC) FROM Case where CreatedBy.ProfileId in : profileIds ORDER BY '+ sortFullExp + ' limit 1000');
       if(sortIdentifier.equalsIgnoreCase('ClosedCases')) {
            WrapperClosedCaseList = new List<WrapperCase>();
       } else if(sortIdentifier.equalsIgnoreCase('OpenCases')) {
            WrapperOpenCaseList = new List<WrapperCase>();
       } 
       
       
       if(cases.size() > 0){
            for(Case c : cases){
                 WrapperCase wrappedCase = new WrapperCase();
                 wrappedCase.userName = c.Owner.Username;
                 wrappedCase.CaseNumber = c.CaseNumber;
                 wrappedCase.openDate = getOpenDate(c.Case_Age__c);
                 wrappedCase.subject = c.Subject;
                 wrappedCase.age = c.Case_Age__c;
                 wrappedCase.Appirio_Request_Type = c.Appirio_Request_Type__c;
                 wrappedCase.Description = c.Description;
                 
                 
                 if(c.CaseComments.size() > 0 ){
                    caseComment = c.CaseComments[0].CommentBody;
                    caseComment=caseComment.replaceAll(',','');
                 
                    System.debug('----Case Comment after removal of comma'+caseComment);
                    
                    wrappedCase.caseComement = caseComment;
                    System.debug('-----------'+wrappedCase.caseComement);
                    }
                 else
                    wrappedCase.caseComement = '';
                 
                 if(isCsv == 'true'){
                    wrappedCase.Description = wrappedCase.Description.replaceAll('\n', ' ');
                    wrappedCase.Description = wrappedCase.Description.replaceAll('\r', ' ');
                    wrappedCase.Description = wrappedCase.Description.replaceAll('\t', ' '); 
                    wrappedCase.Description = wrappedCase.Description.replaceAll(',', ' ');
                    if(c.CaseComments.size() > 0 ){
                        wrappedCase.caseComement=wrappedCase.caseComement.replaceAll('\n','');
                        wrappedCase.caseComement=wrappedCase.caseComement.replaceAll('\r','');
                        wrappedCase.caseComement=wrappedCase.caseComement.replaceAll('\t','');
                    }
                 }
                 //START Case 00005400 - DIANA ACKER
                 wrappedCase.contact = c.Contact.Name;
                 wrappedCase.state = c.State__c;
                 if(c.ClosedDate != null &&  (sortIdentifier.equalsIgnoreCase('AllCases')|| sortIdentifier.equalsIgnoreCase('ClosedCases'))){
                    wrappedCase.closeDate = getCloseDate(c.ClosedDate);
                    WrapperClosedCaseList.add(wrappedCase);
                }
                else if (c.ClosedDate == null &&  (sortIdentifier.equalsIgnoreCase('AllCases')|| sortIdentifier.equalsIgnoreCase('OpenCases')))
                     WrapperOpenCaseList.add(wrappedCase);
            }
       }
       return null;
   }
    public String getSortDirection()
 {
    //if not column is selected 
    if (sortExpression == null || sortExpression == '')
      return 'ASC';
    else
     return sortDirection;
 }

 public void setSortDirection(String value)
 {  
   sortDirection = value;
 }
  
  
  //rahul changes End
  public class WrapperCase{
   public String userName{get;set;}
   public String openDate{get;set;}
   public String subject{get;set;}
   public Double age{get;set;}
   public String Appirio_Request_Type{get;set;}
   public String Description{get;set;}
   public String CaseNumber{get;set;}
   public string caseComement{get;set;}
   //START Case 00005400 - DIANA ACKER
   public string contact{get;set;}
   public string state{get;set;}
   public string closeDate{get;set;}
   //END Case 00005400
    
 }  
  
}