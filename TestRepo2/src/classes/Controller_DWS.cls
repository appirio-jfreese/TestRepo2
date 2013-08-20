public with sharing class Controller_DWS extends Controller_Base {
    public string hexDiageowines {get; private set;}
    public string hexDwsacademies {get;private set;}
    public string ssoId {get;private set;}
        
    public Controller_DWS() {
        addBreadcrumbItem(Apexpages.currentPage().getUrl(), Constant.DWS);
		pageUrl = Page.DWS.getUrl();
        
        ssoId = Service_API.getSSOId();

		User u = [select Id, FirstName, LastName, Title from User where Id = : UserInfo.getUserId()];
        
		String usrInfo = 'first_name=' + u.FirstName + ',last_name=' + u.LastName+', title=' + u.Title;
		
		Blob spBlob    = Blob.ValueOf('dest=diageowines.com,'+usrInfo );
		hexDiageowines = EncodingUtil.base64Encode(spBlob);
		
		spBlob          = Blob.ValueOf('dest=www.dwsacademies.com,'+usrInfo );
		hexDwsacademies = EncodingUtil.base64Encode(spBlob);        
    }
}