public class Test_RecordUtil {

	public static User newUser(String uniqueKey, Id profileId){
        User use = new User();
        use.Alias = uniqueKey;
        use.Email = uniqueKey + '@testorg.com';
        use.EmailEncodingKey = 'UTF-8';
        use.LastName = 'Test' + uniqueKey;
        use.LanguageLocaleKey = 'en_US';
        use.LocaleSidKey = 'en_US';
        use.ProfileId = profileId;
        use.TimeZoneSidKey = 'America/Chicago';
        use.Username = uniqueKey + '@test' + Math.round(Math.random() * 10000) + '.com';
        use.UserRoleId = null;
        use.Country = 'United States';
        return use;
    }
    
    public static Territory__c newTerritory(String name){
    	Territory__c terr = new Territory__c();
    	terr.Name = name;
    	return terr;
    }
    
    public static Account newAccount(String name, Id terrId, Id rtId){
    	Account acc = new Account();
    	acc.Name = name;
    	acc.Territory__c = terrId;
    	acc.RecordTypeId = rtId;
    	return acc;
    }
    
    public static Calendar__c newCalendar(String name, String sChannel){
    	Calendar__c cal = new Calendar__c();
    	cal.Name = name;
    	cal.Sales_Channel__c = sChannel;
    	return cal;
    }
    
    public static void ensureBrandCanBeCreated(){
    	List<Account> diageoAccs = [SELECT Id FROM Account WHERE Name = 'Diageo'];
    	if(diageoAccs.isEmpty()){
    		Account acc = new Account();
    		acc.Name = 'Diageo';
    		insert acc;
    	}
    }
    
    public static Brand__c newBrand(String name){
    	Brand__c brand = new Brand__c();
    	brand.Name = name;
    	brand.Brand_Type__c = 'Individual';
    	return brand;
    }
    
    public static Bottle_Size__c newBottleSize(String name){
    	Bottle_Size__c bots = new Bottle_Size__c();
    	bots.Name = name;
    	return bots;
    }
    
    public static BrandBottle_Size__c newBrandBottleSize(String name, Id brandId, Id sizeId){
    	BrandBottle_Size__c bbs = new BrandBottle_Size__c();
    	bbs.Name = name;
    	bbs.Brand__c = brandId;
    	bbs.Bottle_Size__c = sizeId;
    	return bbs;
    }
	public static List<NABCA_Vendor__c> getVendors(Integer recCount){
		List<NABCA_Vendor__c> vendorList = new List<NABCA_Vendor__c>();
        for(Integer i = 0; i<recCount; i++){
	        vendorList.add(new NABCA_Vendor__c(NABCA_Vendor_Code__c = '1111'+i,NABCA_Vendor_Description__c = 'test' + i + ' description vendor'));
        }
        insert vendorList;
        return vendorList;
	}
	
	public static List<NABCA_Category__c> getCategories(Integer recCount){
		List<NABCA_Category__c> catList = new List<NABCA_Category__c>();
		for(Integer i = 0; i<recCount; i++){
	        catList.add(new NABCA_Category__c(NABCA_Major_Category_Code__c  = '1111'+i,NABCA_Major_Category_Description__c = 'test' + i + ' description cat'));
        }
        insert catList;
        return catList;
	}
    public static List<NABCA_Brand__c> getBrands(Integer recCount,List<NABCA_Vendor__c> vendorList,List<NABCA_Category__c> catList){
        List<NABCA_Brand__c> brandList = new List<NABCA_Brand__c>();
        Integer j = 0;
        string decs;
        for(Integer i = 0; i<recCount; i++){
	        if(i > vendorList.size() || i > catList.size()){
	        	j = 0;
	        }
	        if(math.mod(i,2) == 0)
	        	decs = 'Wine';
	        else
	        	decs = 	'Spirit';
	        	        
	        brandList.add(new NABCA_Brand__c(NABCA_Vendor__c = vendorList[j].id, NABCA_Category__c = catList[j].id,Brand_Composite_Key__c = '11'+i,nabca_beverage_type_description__c = decs));
	        j++;
        }
        insert brandList;   
        return brandList;
    } 
    
    public static List<NABCA_Sales_Data__c> getSalesData(Integer recCount,List<NABCA_Brand__c> brandList,Account acc){
    	List<NABCA_Sales_Data__c> dataList = new List<NABCA_Sales_Data__c>();
        Integer j = 0;
        for(Integer k = 0 ; k<recCount ; k++){
	        if(k > brandList.size()){
	        	j = 0;
	        }
	        NABCA_Sales_Data__c ISDC=new NABCA_Sales_Data__c();
	        ISDC.Brand__c = brandList[j].Id;
	        ISDC.Account__c = acc.id;
	        for(Integer i = 1; i<=36; i++){
	        	string fieldName = 'month' + i + '_9l_volume__c';
	        	string shelfFieldName = 'month' + i + '_ShelfDollar_Volume__c';
	        	ISDC.put(fieldName,10+i*10);
	        	ISDC.put(shelfFieldName,20+i*10);	
	        	ISDC.Sale_Composite_Key__c = string.ValueOf(math.random());
	        	ISDC.Month_End_Date__c = date.today();
	        }
	        dataList.add(ISDC);
	        j++;
        }
        insert dataList;  
        return dataList;
    }     
}