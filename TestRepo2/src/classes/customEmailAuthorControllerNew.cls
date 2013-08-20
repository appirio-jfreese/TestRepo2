public with sharing class customEmailAuthorControllerNew{
    
    public String emailSubject {get; set;}
    public String templateId   {get; set;}
    public String fromAddress  {get;set;}
    public String toAddress    {get; set;}
    public String CCAddress    {get; set;}
    public String BccAddress   {get; set;}
    public String emailBody    {get; set;}
    public Boolean emailSent   {get; set;}
    public String To    {get; set;}
    public Boolean renderNewTemplateSection {get; set;}
    public String owId               {get; set;} 
    /***Email template Used for Creation***/
    public EmailTemplate newEmailTemplate {get;set;}
    //public Boolean error
    
    public customEmailAuthorControllerNew() {
        renderNewTemplateSection = false;
        emailSent                = false;  
        owId = ApexPages.currentPage().getParameters().get('owId');
        newEmailTemplate = new EmailTemplate(TemplateType='text');
         fromAddress = 'diageodirect@diageo.com';
    }
    
    public PageReference selectTemplate() {
        return null;
    }
   public List<SelectOption> getTemplates() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('--None--','--None--'));
            for(EmailTemplate  eTemplate : [Select e.Name, e.Id From EmailTemplate e order by e.Name asc])
            {
                options.add(new SelectOption(eTemplate.Id,eTemplate.Name));
            }
            return options;
        }
        
        public PageReference redirect() {
        return new pageReference('/'+owId);
}
   public PageReference sendEmail() {
       //system.debug('***From-- '+fromAddress+'**ToAddress--'+toAddress); 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       mail.saveAsActivity = false;
       List<String> toaddresses = new List<String>();
       /*if(toAddress==null || toAddress=='')
       {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'To address cannot be blank'));
        return NULL;
       }*/
       if(emailSubject==null || emailSubject=='')
       {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Subject Cannot be blank'));
        return NULL;
       }
       if(toAddress != null && toAddress != '' )
        toaddresses = toAddress.split(';');
       //toaddresses.add('k.sugan77@gmail.com');
       //String[] toAddresses = new String[] {toAddress}; 
       //String[] ccAddresses = new String[] {/*'rhalpin@aconex.com',*/'palaniraja.pandurangan@listertechnologies.com','aruna.narayanan@listertechnologies.com','sugankarthik.k@listertechnologies.com','balamurali.c@listertechnologies.com'}; 
       //mail.setFromAdress(fromAddress);
       mail.setReplyTo(fromAddress);
       mail.setToAddresses(toAddresses);
       if(CCAddress != null && CCAddress != '')
       mail.setCcAddresses(CCAddress.split(';'));
       if(BccAddress != null && BccAddress != '')
       mail.setBccAddresses(BccAddress.split(';'));
       mail.setSubject(emailSubject);
       mail.setPlainTextBody(emailBody);
       for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]) {
       if(owa.Address.contains('diageodirect@diageo.com')) mail.setOrgWideEmailAddressId(owa.id); } 
       try{
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       }catch(Exception err)
       {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage()));
        return NULL;
       }
       
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Mail sent successfully'));
        emailSent = true;
        renderNewTemplateSection = false;
        return null;
    } 
    
   public PageReference createNewTemplate() {
       
        //system.debug('***Sub-- '+ emailSubject+'--Body-- '+emailBody); 
        
        if(!renderNewTemplateSection)
        {
            renderNewTemplateSection = true;
            return null;
        }
        else
        {
          Id folder;
          try{
               folder  = [Select f.Type, f.Name, f.Id From Folder f where f.Type  = 'Email' and Name='Templates For POS Order windows'].Id;
            }catch(Exception err)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure that the Folder("Templates For POS Order windos") exists for the new Template to be stored.'));
                return NULL;
            }  
        newEmailTemplate.Subject=emailSubject;
        newEmailTemplate.Body=emailBody;
        newEmailTemplate.FolderId=folder;
        
        try{
            insert newEmailTemplate;
        }catch(Exception err)
        {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage()));
           return NULL;
        } 
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Template created successfully'));
        renderNewTemplateSection = false;
        return null;  
       //EmailTemplate newEmailTemplate = new EmailTemplate();
       }
   }
  public PageReference cancelNewTemplate() {
    renderNewTemplateSection = false;
    return null;
  }
   public static testMethod void testCustomEmailAuthorController()
   {
    Test.startTest();
            customEmailAuthorControllerNew testController = new customEmailAuthorControllerNew();
            testController.getTemplates();
            testController.toAddress = 'test@gmail.com;\n';
            testController.newEmailTemplate.Name = 'Temaplate Name';
            testController.createNewTemplate();
            testController.newEmailTemplate.DeveloperName = 'TemaplateName';
            testController.sendEmail();
            testController.selectTemplate();
            testController.createNewTemplate();
            testController.createNewTemplate();
            testController.cancelNewTemplate();
            Test.stopTest();
   }
}