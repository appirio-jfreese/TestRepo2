public with sharing class Controller_POS extends Controller_Base {
    
    public String posAdHocFolderId {
        get {
            return Service_API.getPosAdHocFolderId();
        }
        set;
    }
    
    public String posToolFolderId {
        get {
            return Service_API.getPosToolFolderId();
        }
        set;
    }
    
    public Controller_POS() {
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), Constant.POS);
		pageUrl = Page.POS.getUrl();
        
    }
}