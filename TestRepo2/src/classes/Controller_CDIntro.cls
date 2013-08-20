public without sharing class Controller_CDIntro extends Controller_Base {

	// main sections 
    public List<string> sections {get; set;}
    public MAP<string, string> idMap {get; set;}
	public MAP<string, string> descriptionMap {get; set;}
	
    // sub sections
    public MAP<string, List<string>> subSectionsMap {get; set;}
    public MAP<string, string> totalSubSectionsMap {get; set;}

    public Controller_CDIntro() {
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), Constant.CATEGOTY_DEVELOPMENT);
      	pageUrl = Page.CDIntro.getUrl();
      	
     	
		sections = new List<String>();
		
    	list<Sections__c> sectionTabs = Service_API.getSectionTabs(CONSTANT.CATEGOTY_DEVELOPMENT);
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
    }  
}