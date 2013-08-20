@isTest
private class Test_ControllerBrightcoveUpload {

    static testMethod void controllerFileTest() {
        
		ControllerBrightcoveUpload con = new ControllerBrightcoveUpload();
		
		system.assert(con.getLibraries().size() != 0);
		system.assert(con.libsOptions.size() == con.getLibraries().size());
		
		con.videoId = '123456789';
		con.videoDesc = 'TestVideo';
		con.selectedLibrary = con.getLibraries()[0].getValue();
		
		con.submit();
    }
    
    static testMethod void controllerCDTest() {
        
		ControllerBrightcoveUpload con = new ControllerBrightcoveUpload();
		
		system.assert(con.getLibraries().size() != 0);
		system.assert(con.libsOptions.size() == con.getLibraries().size());
		
		con.videoId = '123456789';
		con.videoDesc = 'TestVideo';
		con.selectedLibrary = con.getLibraries()[1].getValue();
		
		con.submit();
    }
}