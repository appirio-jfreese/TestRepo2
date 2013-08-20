public with sharing class Controller_VideoDownload {

	public String videoId {set; get;}
	public String videoUrl {set; get;}
	public String description {set;get;}
	public String userAgent{set;get;}
	public String browser{set;get;}
	
	 
	public Controller_VideoDownload()
	{
		videoId 	 = ApexPages.currentPage().getParameters().get('videoid');
		description  = ApexPages.currentPage().getParameters().get('videodesc');
				
		userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
		if(userAgent.contains('Chrome')){
			browser = 'chrome';
		}else if(userAgent.contains('Safari')){
			browser = 'safari';
		}else if(userAgent.contains('Firefox')){
			browser = 'firefox';		
		}else{
			browser = 'ie';
		}
		videoUrl = Controller_BaseRemote.downloadVideoFromBC(videoId);
	}
}