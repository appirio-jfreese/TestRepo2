/*
	Class : APPIRIO_MyAssetsController_Test 
	Description :  Test Class for a APPIRIO_MyAssetsController
	Developed by : Manmeet Manethiya
	CreatedDate : Dec 07, 2012
*/

@isTest(SeeAllData=false)
private class APPIRIO_MyAssetsController_Test {
	
	//initialising static variables
	public static Digital_Published_Asset__c digiTalPublishedAsset;
	public static User usr;
	
	//test method to call functionality
	static testMethod void testMyAssetsForSystemAdministrator() {
		//creating test data
		createTestData(null);
		Test.startTest();
		//calling controller
		APPIRIO_MyAssetsController controller = new APPIRIO_MyAssetsController();
		controller.getMyAssets();
		controller.getUserAgent();
		controller.manageAsset();
		Test.stopTest();
		
		//assert to check Digital_Published_Asset__c
		System.assertEquals(1, controller.getMyAssets().size());
	}
	/*
	static testMethod void testMyAssetsForOtherProfile() {
		Profile prf = [Select id, name from Profile where name = 'Standard User']; 
		createTestData(prf);
		System.runAs(usr){
			Test.startTest();
			APPIRIO_MyAssetsController controller = new APPIRIO_MyAssetsController();
			controller.getMyAssets();
			Test.stopTest();
			//assert to check Digital_Published_Asset__c
			System.assertEquals(1, controller.getMyAssets().size());
		}
	}*/
	
	//test data function
	private static void createTestData(Profile prf){
		//creating digital published asset
		digiTalPublishedAsset = new Digital_Published_Asset__c();
		if(prf != null) digiTalPublishedAsset.Publisher__c = UserInfo.getUserId();
		insert digiTalPublishedAsset;
		/*
		UserRole role = new UserRole();
		role.name = 'Recipe - Admin';
		insert role;
		*/
		if(prf != null){
			usr = new User();
			usr.firstName = 'test1';
      usr.LastName = 'test2';
      usr.Alias = '112';
      usr.Email = 'test@test.com';
      usr.UserName='test12345@test.com' ;
      usr.ProfileId = prf.id;
      usr.CommunityNickname = usr.firstname+'_1'+usr.lastName;
      usr.EmailEncodingKey ='ISO-8859-1';
      usr.LanguageLocaleKey = 'en_US';
      usr.TimeZoneSidKey ='America/Indianapolis';
      usr.LocaleSidKey = 'en_US';
     // usr.UserRoleId = role.id;
      insert usr;
		}
	}
}