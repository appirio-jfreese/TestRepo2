public with sharing class pageLink {
    public String link {get; set;}
    public String linkName {get; set;}
    public String className {get; set;}
    public pageLink[] subLinks{get; set;}
    
    public pageLink() {
        this.link      = '';
        this.linkName  = '';
        this.className = ''; 
        this.subLinks  = new List<PageLink>(); 
    }      

    public pageLink(String link, String linkName) {
        this.link      = link;
        this.linkName  = linkName;
        this.className = ''; 
        this.subLinks  = new List<PageLink>(); 
    }
          
    public pageLink(String link, String linkName, String className) {
        this.link      = link;
        this.linkName  = linkName;
        this.className = className; 
        this.subLinks  = new List<PageLink>(); 
    }      
    
    public void addSubLinks(pageLink[] newSubLinks) {
    	if (newSubLinks!= null) {
    		subLinks.addAll(newSubLinks);
    	}
    }
}