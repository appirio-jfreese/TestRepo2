public with sharing class Controller_AccountBrandRelationEdit {
    
    public Controller_AccountBrandRelationEdit(ApexPages.StandardController controller) {
    }
    
    public PageReference redirect() {
    	string id = ((string)Apexpages.currentpage().getparameters().get('retURL')).substring(1,4);
    	PageReference res = null;
    	if(id=='001')
    		res = Page.AccountBrandEdit;
    	else
    		res = Page.BrandAccountEdit;
    	for(string key : apexpages.currentpage().getparameters().keyset()){
    		res.getparameters().put(key, apexpages.currentpage().getparameters().get(key));
    	}
    	res.setRedirect(true);
    	return res;
    }
}