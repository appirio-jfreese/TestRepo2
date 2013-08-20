public class Controller_Auth {

    // login and forgot login "actions"
    public String userName {get; set;}
    public String userPassword {get; set;}
    public String startUrlPage {get; set;}    
    public String userEmail {get; set;}
    
    // change password "actions"
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}   
    private String IP {private get; private set;}
    public String redirTo {public get; private set;}
       
    public Controller_Auth() {
		PageReference currentPage =  ApexPages.currentPage();
		Map<String,String> headerParams = currentPage.getHeaders();
		IP = headerParams.get('X-Salesforce-SIP');
		redirTo = null;
				
    }
    
    public Boolean isDiageoNetwork(){
    	    	
    	if(IP == null || IP == ''){
    		return false;
    	}
    	
		String IPrange = Service_API.getSetting('iprange');
        if(IPrange == null || IPrange == ''){
            return false;
        }
		List<String> ipRangeList = IPrange.split('-');
		if(ipRangeList.size() == 2){
			Integer ipInt = IpToNumber(IP);				
			Integer startInt = IpToNumber(ipRangeList[0]);
			Integer endInt = IpToNumber(ipRangeList[1]);
			if (ipInt >= startInt && ipInt <= endInt){
				// user from diageo network
				return true;
			} else {
			// normal user
				return false;			
			}
		}
		    	
		return false;    	
    }
    
    //chech whether already logged in
    public PageReference checkLoggedIn(){
		if (ApexPages.currentPage().getHeaders().get('CipherSuite') == null) {
			string tmp = ApexPages.currentPage().getParameters().get('startURL');
			String uu;
			if(tmp!=null) {
				uu = 'https://diageodirect.secure.force.com'+tmp;
			} else {
				uu = System.URL.getCurrentRequestUrl().toExternalForm().replace('http://','https://').replace('www.diageodirect.com','diageodirect.secure.force.com').replace('diageodirect.force.com','diageodirect.secure.force.com');
			}	
    		PageReference pr = new Pagereference(uu);
    		return pr;	
   		}
		
    	startUrlPage = Page.Init.getUrl();
    	PageReference pr = new Pagereference(startUrlPage);
    	String guestUserName = Service_API.getSetting('guestUserName');
		
		String url = ApexPages.currentPage().getParameters().get('startURL');
		String www = EncodingUtil.urlEncode('https://diageodirect.secure.force.com','UTF-8'); 

		if(isDiageoNetwork()){
			// diageo network
    		if(Userinfo.getUserName() == guestUserName){
				// user not logged
    			// check cookie	
    			Cookie forceLogin = ApexPages.currentPage().getCookies().get('forcelogin');
    		   	if (forceLogin == null) {
					redirTo = Service_API.getSetting('ssologinurl');
					String target = '';
					if(url.length() > 0){
						target = '&TargetResource='+ www + url;					
					}
	    			pr = new Pagereference(redirTo+target);
					// set cookie
        			forceLogin = new Cookie('forcelogin','1',null,60,false);
					pr.setCookies(new Cookie[]{forceLogin});
	    			return pr;
				} else {
					return null;
				}
    		}
		} else {
	    	if(Userinfo.getUserName() == guestUserName){
    			return null;
    		}
		}

    	return pr;
    }

    // log user
    public PageReference logUser(){
    	startUrlPage = Page.Init.getUrl();
		String url = ApexPages.currentPage().getParameters().get('startURL');
		if (url!=null || url!='') {
			startUrlPage=url;
		}
        pagereference pr = Site.login(userName,userPassword,startUrlPage);
        
        return pr;
    }
    
    // forgot password
    public PageReference forgotPassword() {
        boolean success = Site.forgotPassword(userName);
        PageReference pr = Page.ForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        
        return null;
    }
    
    // change password
    public PageReference changePassword() {
    	return Site.changePassword(newPassword, verifyNewPassword, oldpassword);
    }
    
    // forgot password
    public PageReference forgotUsername() {
    	if(userEmail != null && userEmail != ''){
    		Forgot_User_Name__c notify = new Forgot_User_Name__c();
    		notify.User_mail__c = userEmail;
    		insert notify;
	        PageReference pr = Page.ForgotUserNameConfirm;
	        return pr;
    	}
        return null;
    }
    
    private Integer IpToNumber(String IPaddress){
    	Integer result = 0;
    	list<String> ipPart = IPaddress.split('\\.');
   	
		Integer i = 0;
		for (String part : ipPart){
			Integer partValue = Integer.valueOf(part);
			Integer power = 3-i;
			result +=  (math.mod(partValue, 256)  * Integer.valueof(Math.pow(256,power)));
			i++;
    	}

    	return result;
    }
}