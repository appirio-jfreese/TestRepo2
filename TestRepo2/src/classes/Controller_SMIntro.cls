/*******************************************************************************
Name				: Controller_SMIntro.cls

Updated By  : Basant Verma (Appirio OffShore)   
Date        : 7/19/13
Story/Task  : US609/DE654
*******************************************************************************/
public with sharing class Controller_SMIntro extends Controller_Base {
		// Start : Changes for US609/DE654 - Basant Verma
		public String selectedSection {get; set;}
		// End : Changes for US609/DE654 - Basant Verma
	// main sections 
    public List<string> sections {get; set;}
    public MAP<string, string> idMap {get; set;}
	public MAP<string, string> descriptionMap {get; set;}
	    
    // sub sections
    public MAP<string, List<string>> subSectionsMap {get; set;}
    public MAP<string, string> totalSubSectionsMap {get; set;}
    
    public Controller_SMIntro() {
    	// Start: Changes for responsive site - Randy Wandell (Appirio) 7/10/13
		//pageUrl = Page.MonthlyExecutionPlan.getUrl();
		pageUrl = ApexPages.currentPage().getUrl();
		setResponsiveState();
		// End:
		// Start : Changes for US609/DE654 - Basant Verma
		addBreadcrumbItem(currentUserPage(), Constant.SELLING_MATERILAS);
    // End : Changes for US609/DE654 - Basant Verma
		sections = new List<String>();
		
    	list<Sections__c> sectionTabs = Service_API.getSectionTabs(CONSTANT.SELLING_MATERILAS);
    	for(Sections__c s : sectionTabs ){
    		if(s.Parent_Tab__c == null || s.Parent_Tab__c == ''){
    			sections.add(s.Tab__c);
    		}
    	}
			
		subSectionsMap = new MAP<string, List<string>>();
		totalSubSectionsMap = new map<string, string>();
		idMap = new map<string, string>();
		descriptionMap = new map<string, string>();		

		for(String section : sections){
			List<String> subSections = new List<String>();

	    	for(Sections__c s : sectionTabs ){
	    		if(section != null && section != '' && s.Parent_Tab__c == section ){
	    			subSections.add(s.Tab__c);
	    		}
	    	}
			descriptionMap.put(section, section);	    	

	        if(subSections.size() == 0){
	        	subSections.add(section);
	        }

    		subSectionsMap.put(section, subSections);
    		idMap.put(section, section.replaceAll('[^a-zA-Z0-9]', ''));
    		
    		for(string name: subSections){
    			totalSubSectionsMap.put(name, name);
    		}
    	}
    	// Start : Changes for US609/DE654 - Basant Verma
    	if(isResponsive){
    		if(ApexPages.currentPage().getParameters().get('section') != null && ApexPages.currentPage().getParameters().get('section') != ''){
    			selectedSection = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('section'), 'UTF-8');
    			addBreadcrumbItem(Apexpages.currentPage().getUrl(), selectedSection);
    		}
    	}    	
    	// End : Changes for US609/DE654 - Basant Verma
    }
    
	// Start: Changes for Responsive Site - Randy Wandell (Appirio) 7/10/13    
    public void setResponsiveState() {
		if(pageUrl.toLowerCase().indexOf('r_smintro') > -1) {
			isResponsive = true;
			preapareSiteNavigationMenu();
		} else {
			isResponsive = false;
			preapareSiteNavigationMenu();
		}    	
    }
    // End:
}