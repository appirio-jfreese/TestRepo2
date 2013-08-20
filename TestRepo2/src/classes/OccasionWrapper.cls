public class OccasionWrapper {
    public Boolean checked {get;set;}
    public Occasion__c occ {get;set;}
    public String image {get;set;}
    public String publishStatus {get;set;}
    
    public OccasionWrapper() {
        occ = new Occasion__c();
        checked = false;
    }
 
    public OccasionWrapper(Occasion__c o, String pubStatus){
    	occ = o;
    	publishStatus = pubStatus;
        if(publishStatus.equals('Published')) {
        	checked = true;
        } else {
        	checked = false;	
        }
        
        if(o.Recipe_Occasion_Image__c != null)
        	image = o.Recipe_Occasion_Image__r.Content_id__c;
        else
        	image = null;
    }
    
    public static testMethod void testMe() {
 
      	OccasionWrapper re = new OccasionWrapper();
      	System.assertEquals(re.checked,false);
 
 	  	Occasion__c occasion = new Occasion__c(Name_Of_The_Occasion__c='Test1');
 	  
 	  	ContentVersion myImage = new ContentVersion();
 	  	myImage.title='TITLE';
 		myImage.contentUrl='http://www.salesforce.com';
        insert myImage;
       
        Recipe_Media__c media = new Recipe_Media__c();
        media.Content_id__c=myImage.Id;
        insert media;
      
        
        occasion.Recipe_Occasion_Image__c = media.Id;        
        OccasionWrapper oc2 = new OccasionWrapper(occasion,'Published');
        System.assertEquals(oc2.checked,true);
        
        occasion.Recipe_Occasion_Image__c = null;
        oc2 = new OccasionWrapper(occasion,'Suppressed');
        	  
      	System.assertEquals(oc2.occ.Name_Of_The_Occasion__c,'Test1');
      	System.assertEquals(oc2.checked,false);
    }
}