public class RecipeWrapper {

 
    public Boolean checked{ get; set; }
    public Recipe__c rec { get; set;}
    public String image { get; set;}
    public String publishStatus { get; set;}
    
    public RecipeWrapper() {
        rec = new Recipe__c();
        checked = false;
    }
 
    public RecipeWrapper(Recipe__c r){
        rec = r;
        checked = false;
        if(r.Main_Drink_Image__c!=null)
        	image=r.Main_Drink_Image__r.Content_id__c;
        else if(r.Mobile_Drink_Image__c!=null)
        	image=r.Mobile_Drink_Image__r.Content_id__c;
        else if(r.Mobile_Selected_Image__c!=null)
        	image=r.Mobile_Selected_Image__r.Content_id__c;
        else if(r.Mobile_Unselected_Image__c!=null)
        	image=r.Mobile_Unselected_Image__r.Content_id__c;
        else if(r.Background_Image__c!=null)
        	image=r.Background_Image__r.Content_id__c;
        else if(r.Brand_Recipe_Image__c!=null)
        	image=r.Brand_Recipe_Image__r.Content_id__c;
        else if(r.Search_Recipe_Image__c != null)
        	image = r.Search_Recipe_Image__r.Content_id__c;
        else if(r.Additional_Image_1__c!=null)
        	image=r.Additional_Image_1__r.Content_id__c;
        else if(r.Additional_Image_2__c!=null)
        	image=r.Additional_Image_2__r.Content_id__c;
        else
        	image=null;
    }
    
    public RecipeWrapper(Recipe__c r, String pubStatus){
    	rec = r;
    	publishStatus = pubStatus;
        if(publishStatus.equals('Published')) {
        	checked = true;
        } else {
        	checked = false;	
        }
        
        if(r.Main_Drink_Image__c!=null)
        	image=r.Main_Drink_Image__r.Content_id__c;
        else if(r.Mobile_Drink_Image__c!=null)
        	image=r.Mobile_Drink_Image__r.Content_id__c;
        else if(r.Mobile_Selected_Image__c!=null)
        	image=r.Mobile_Selected_Image__r.Content_id__c;
        else if(r.Mobile_Unselected_Image__c!=null)
        	image=r.Mobile_Unselected_Image__r.Content_id__c;
        else if(r.Background_Image__c!=null)
        	image=r.Background_Image__r.Content_id__c;
        else if(r.Brand_Recipe_Image__c!=null)
        	image=r.Brand_Recipe_Image__r.Content_id__c;
        else if(r.Search_Recipe_Image__c != null)
        	image = r.Search_Recipe_Image__r.Content_id__c;
        else if(r.Additional_Image_1__c!=null)
        	image=r.Additional_Image_1__r.Content_id__c;
        else if(r.Additional_Image_2__c!=null)
        	image=r.Additional_Image_2__r.Content_id__c;
        else
        	image=null;
    }
 
	public static testMethod void testMe() {
 
      	RecipeWrapper re = new RecipeWrapper();
      	System.assertEquals(re.checked,false);
 
 	  	Recipe__c recipe = new Recipe__c(Recipe_Title__c='Test1');
 	  
 	  	ContentVersion myImage = new ContentVersion();
 	  	//myImage.ContentDocumentId=Label.Drink_Image_Workspace_Name;
 		myImage.title='TITLE';
 		myImage.contentUrl='http://www.salesforce.com';
        insert myImage;
       
        Recipe_Media__c media = new Recipe_Media__c();
        media.Content_id__c=myImage.Id;
        insert media;
      
        
        recipe.Main_Drink_Image__c = media.Id;        
        RecipeWrapper re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Published');
        recipe.Main_Drink_Image__c = null;
        System.assertEquals(re2.checked,true);
        
        recipe.Search_Recipe_Image__c = media.Id;
        re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Suppressed');
        recipe.Search_Recipe_Image__c = null;
        
        recipe.Mobile_Selected_Image__c = media.Id;
        re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Published');
        recipe.Mobile_Selected_Image__c = null;
        
        recipe.Mobile_Unselected_Image__c = media.Id;
        re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Published');
        recipe.Mobile_Unselected_Image__c = null;
        
        
        recipe.Mobile_Drink_Image__c = media.Id;
        re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Published');
        recipe.Mobile_Drink_Image__c = null;
        
        recipe.Additional_Image_1__c =  media.Id;
        re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Published');
        recipe.Additional_Image_1__c = null;
        
        recipe.Additional_Image_2__c =  media.Id; 
        re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Published');
        recipe.Additional_Image_2__c = null;
       
        recipe.Search_Recipe_Image__c =  media.Id;
        re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Published');
        recipe.Search_Recipe_Image__c = null;
        
        recipe.Background_Image__c =  media.Id;
        re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Published');
        recipe.Background_Image__c = null;
        
        recipe.Brand_Recipe_Image__c =  media.Id;
        re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Published');
        recipe.Brand_Recipe_Image__c = null;
        
        recipe.Additional_Image_5__c =  media.Id;
        re2 = new RecipeWrapper(recipe);
        re2 = new RecipeWrapper(recipe,'Suppressed');
 	  
      	System.assertEquals(re2.rec.Recipe_Title__c,'Test1');
      	System.assertEquals(re2.checked,false);
    }
}