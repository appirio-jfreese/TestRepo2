/* 
  @An Apex Class that is Associated with MM_Media Page.
  @Returns all the Images from the Media to Assocuate to a Recipe.
  @Author  : Raj Avirneni
  @Date    : Mar 23 2012
  @Version : 1.0
*/
/* Modified By  : Rishi Khirbat(Appirio Offshore on 15th-Dec-2012)
   Details      : Modified against T-104362: Add Logic to govern image addition behavior
   				  When a user clicks on the "Manage Images" from the view mode of MM_ViewRecipe, 
   				  they should not be able to change or edit existing selections.
					- For all image fields in which there is a value lock the selection and do not 
					  allow the user to change it. Replace the Trashcan icon with a Lock icon, 
					  if possible. (See below for list of image fields)
					- If the image field is blank, allow the user to add an image.
					
				  This logic should only apply when accessed from the "View" mode of the page, 
				  and when in Create New Recipe mode, it should function as the currently specced.
*/
public class MM_MediaController extends MM_RecipeBase {
    
    public ContentVersion myImage {get;set;}
    public String imageName {get; set; }
    public Recipe__c recipe {get; set;}
    public List<Recipe_Media__c> mediaList {get; set;}
    public static String selectedMedia {get; set;}
    public String selectedMedia2 {get; set;}
    public String redirect {get; set;}
    public PageReference pageRef {get; set;}  
    public Boolean uploadMediaMode{get;set;}
    public Boolean selectMediaMode{get;set;}   
    public String currentImageId {get;set;}
    public String imageNameFilter {get;set;}
    
    public String currentImageName {get;set;}
    public string selectedAlphabet{get;set;}
    public string currentAlpha{get;set;}
    
    transient map<Id,Recipe_Media__c> mediaMap {get;set;}
    
    /*Modified By Rishi Khirbat -> T-104362: Add Logic to govern image addition behavior*/
    
    //Maintains the status of edit mode
    public String editMode {get;set;}
    public String recipeTitle {get;set;}
    //Maintains the set of  already present images
    set<String> setAlreadyPresentImages;
    /**/
    
    public String mediaName {
        get;
        set {
            System.debug('in set medianame'+ value);
            this.mediaName = value;
        }
    }
    

    public MM_MediaController(String recipeId) {
        selectedAlphabet = 'A';
        processMediaController(recipeId);
    }

    public MM_MediaController(){      
        selectedAlphabet = 'A';
        String recipeId = ApexPages.currentPage().getParameters().get('recipeId');
        editMode = ApexPages.currentPage().getParameters().get('editMode');
        recipeTitle = ApexPages.currentPage().getParameters().get('title');
        processMediaController(recipeId);
        mediaName='mainRecipe';       
    }
    
    private void processMediaController (String recipeID) {
        myImage = new ContentVersion();
        system.debug('@@@@@@@@@@@@@@@RecipeId@@@@@@@@@@@@@'+recipeId);
        
        try {
        
        recipe = [SELECT Comments__c, CreatedById, CreatedDate, IsDeleted, Language__c, LastActivityDate, LastModifiedById, 
            LastModifiedDate, Main_Drink_Image__r.Content_id__c, Main_Drink_Image_URL__c, Search_Recipe_Image__c,Background_Image__c,Brand_Recipe_Image__c,
            Master_Recipe__r.Name, Master_Recipe__r.Id, Menu_Description__c, Mobile_Drink_Image__c, Mobile_Drink_Image_URL__c, 
            Mobile_Selected_Image__c, Mobile_Selected_Image_URL__c, Mobile_Unselected_Image__c,Mobile_Unselected_Image_URL__c,Recipe_Title__c,Preparation_Steps__c, 
            Recipe_Tag__c, Name, Recipe_Type_del__c,Recipe_Version__c, Id, Short_Description__c, Status__c, SystemModstamp, 
            Thumbnail_Drink_Image__c, Thumbnail_Drink_Image_URL__c, Additional_Image_1__c, Additional_Image_2__c 
            FROM Recipe__c
            WHERE Id = :recipeId];
        
        /*Modified By Rishi Khirbat -> T-104362: Add Logic to govern image addition behavior*/      
        //Set up the already present Images
    	setAlreadyPresentImages = new set<String>();  
    	if (recipe.Main_Drink_Image__c != null)
        	 setAlreadyPresentImages.add('mainRecipe');
        if (recipe.Mobile_Drink_Image__c != null)
            setAlreadyPresentImages.add('mobileDrink');
        if (recipe.Mobile_Selected_Image__c != null)
        	setAlreadyPresentImages.add('mobileSelected');
        if (recipe.Mobile_Unselected_Image__c != null)
            setAlreadyPresentImages.add('mobileUnselected');
        if (recipe.Background_Image__c != null)
        	setAlreadyPresentImages.add('background');
        if (recipe.Brand_Recipe_Image__c != null)
        	setAlreadyPresentImages.add('brandRecipe');
        if (recipe.Search_Recipe_Image__c != null)
        	setAlreadyPresentImages.add('searchRecipe');
        if (recipe.Additional_Image_1__c != null)
        	setAlreadyPresentImages.add('additional1');
        if (recipe.Additional_Image_2__c != null)
        	setAlreadyPresentImages.add('additional2');
        /**/
        
        pageRef = new PageReference('/apex/MM_RecipeView?editMode='+editMode+'&recipeId=' + recipe.Id + '&title=' + recipeTitle);
        redirect = '/apex/MM_RecipeView?editMode='+editMode+'&recipeId=' + recipe.Id + '&title=' + recipeTitle + '&reloadImages=true';
        
        loadMediaMap();
        System.debug('*** MAIN DRINK IMAGE: '+recipe.Main_Drink_Image__c);
        if (recipe.Main_Drink_Image__c!=null) {
            currentImageId = mediaMap.get(recipe.Main_Drink_Image__c).Content_Id__c;
            //
            System.debug('Current image Id: '+currentImageId);
        }
        
        } catch (exception e) {
            System.debug(e);
        }
               
        system.debug('@@@@@@@@@@@@@@@@MediaList@@@@@@@@@@@@@@@@'+mediaList);                      
                              
        myImage = new ContentVersion();
    }
    
    public PageReference loadRecentImages () {
        mediaList = [Select Version_Number__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Image__c, Id, 
                    File_Type__c, CreatedDate, CreatedById, Content_id__c, Content_URL__c, Content_Display_ID__c, Available__c 
               From Recipe_Media__c order by CreatedDate DESC LIMIT 5];
        return null;
    }
    
    public PageReference loadAllImages () {
        mediaList = [Select Version_Number__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Image__c, Id, 
                    File_Type__c, CreatedDate, CreatedById, Content_id__c, Content_URL__c, Content_Display_ID__c, Available__c 
               From Recipe_Media__c where Name like 'A%' order by Name ASC limit 999];
               
        loadMediaMap();
        
        return null;
    }
    
    private void loadMediaMap () {
        
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@103 Came Into This@@@@@@@@@@@@@@@@@@@@@@');
         mediaMap = new Map<Id,Recipe_Media__c>([Select Version_Number__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Image__c, Id, 
            File_Type__c, CreatedDate, CreatedById, Content_id__c, Content_URL__c, Content_Display_ID__c, Available__c 
            From Recipe_Media__c order by Name ASC]);
            
            
    }
    
    public PageReference upload(){
        PageReference pageRef = null;
        
        try {
            System.debug('*** Upload Invoked*** myImage.PathOnClient' + myImage.PathOnClient);
            if (myImage.PathOnClient != null){
            	  //myImage.FirstPublishLocationID = '058Z000000006H3'; //workspace Id of Drink Image Workspace
                List<ContentWorkspace> lstCW = [SELECT DefaultRecordTypeId, Id, Name FROM ContentWorkspace WHERE Name = 'Drink Image Workspace']; //workspace Id of Drink Image Workspace
                //system.assert(lstCW.isEmpty(),'Entry missing for Drink Image Workspace in ContentWorkspace!!');
                if(!lstCW.isEmpty()) {                  	
	                myImage.FirstPublishLocationID = lstCW.get(0).Id;
	                myImage.Title=currentImageName;
	                insert myImage;
	                ContentVersion c = [select id,contentDocumentId,Title,VersionNumber,FileType from ContentVersion where id=: myImage.Id];
	               
	                Recipe_Media__c newMedia = new Recipe_Media__c();
	                newMedia.Content_Display_ID__c = c.ContentDocumentId;
	                newMedia.Content_id__c = c.Id;
	                newMedia.Name = c.Title;
	                newMedia.Available__c = 'TRUE';
	                newMedia.File_Type__c = c.FileType;
	                newMedia.Version_Number__c = c.VersionNumber;
	                insert newMedia;
	                
	                System.debug('*** Image inserted');
	                String imageId=myImage.Id;
	                
	                
	                loadAllImages();
	                Recipe_Media__c media = [Select Id from Recipe_Media__c where Content_Id__c = :imageId];
	                System.debug('*** Associating with: '+media.Id);
	                
	                mediaId = media.Id;
	                associateMedia();
	/*                
	                Recipe_Media__c newMedia = new Recipe_Media__c();
	                newMedia.Content_Display_ID__c = myImage.ContentDocumentId;
	                newMedia.Content_id__c = myImage.Id;
	                newMedia.Available__c = 'TRUE';
	                insert newMedia;
	 */                   
              } 
              else {              	
              	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'ContentWorkspace entry for \'Drink Image Workspace\' is missing!!'));
              }  
            }
        } catch (Exception e){
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
        finally{
                myImage = new ContentVersion();
        }
        return pageRef;
    }
   
    @RemoteAction
    public static String setMediaType(String value) {
            selectedMedia = value;
            System.debug('selectedMedia is: ' + value);
            return selectedMedia;
    }
    
    public String mediaId {
        get;
        set {
            this.mediaId = value;
            System.debug('setting mediaId: ' + value);
        }
    }
    
    /*Modified By Rishi Khirbat -> T-104362: Add Logic to govern image addition behavior*/
    //For all image fields in which there is a value, lock the selection and do not allow the user to change it. 
    //If the image field is blank, allow the user to add an image.
    private String setImage(String fieldValue, String fieldName) {
    	if(editMode.equals('false') && setAlreadyPresentImages.contains(fieldName)) {
    		return fieldValue;
    	}else{
    		return mediaId;
    	}
    }
    
    public PageReference associateMedia(){
        if (mediaName == 'mainRecipe'){
        	recipe.Main_Drink_Image__c = setImage(recipe.Main_Drink_Image__c, mediaName);
        } else if (mediaName == 'mobileDrink'){
            recipe.Mobile_Drink_Image__c = setImage(recipe.Mobile_Drink_Image__c, mediaName);
        } else if (mediaName == 'mobileSelected'){
        	recipe.Mobile_Selected_Image__c = setImage(recipe.Mobile_Selected_Image__c, mediaName);
        } else if (mediaName == 'mobileUnselected'){
            recipe.Mobile_Unselected_Image__c = setImage(recipe.Mobile_Unselected_Image__c, mediaName);
        } else if (mediaName == 'background'){
        	recipe.Background_Image__c = setImage(recipe.Background_Image__c, mediaName);
        } else if (mediaName == 'brandRecipe'){
        	recipe.Brand_Recipe_Image__c = setImage(recipe.Brand_Recipe_Image__c, mediaName);
        } else if (mediaName == 'searchRecipe'){
        	recipe.Search_Recipe_Image__c = setImage(recipe.Search_Recipe_Image__c, mediaName);
        }else if (mediaName == 'additional1'){
        	recipe.Additional_Image_1__c = setImage(recipe.Additional_Image_1__c, mediaName);
        } else if (mediaName == 'additional2'){
        	recipe.Additional_Image_2__c = setImage(recipe.Additional_Image_2__c, mediaName);
        }
        
        //loadMediaMap();
        //Recipe_Media__c recipeMedia = mediaMap.get(mediaIdNew);
        Recipe_Media__c recipeMedia = this.getRecipeMedia(mediaId);
        currentImageId = recipeMedia.Content_id__c;
        
        return null;
    }
    
    //For all image fields in which there is a value, lock the selection and do not allow the user to change/remove it. 
    private String removeImage(String fieldValue, String fieldName) {
    	if(editMode.equals('false') && setAlreadyPresentImages.contains(fieldName)) {
    		return fieldValue;
    	}else{
    		currentImageId = '';
    		return null;
    	}
    }
    
    public PageReference disassociateMedia () {
        if (mediaName == 'mainRecipe'){
        	recipe.Main_Drink_Image__c = removeImage(recipe.Main_Drink_Image__c, mediaName);
        } else if (mediaName == 'mobileDrink'){
            recipe.Mobile_Drink_Image__c = removeImage(recipe.Mobile_Drink_Image__c, mediaName);
        } else if (mediaName == 'mobileSelected'){
        	recipe.Mobile_Selected_Image__c = removeImage(recipe.Mobile_Selected_Image__c, mediaName);
        } else if (mediaName == 'mobileUnselected'){
            recipe.Mobile_Unselected_Image__c = removeImage(recipe.Mobile_Unselected_Image__c, mediaName);
        } else if (mediaName == 'background'){
        	recipe.Background_Image__c = removeImage(recipe.Background_Image__c, mediaName);
        } else if (mediaName == 'brandRecipe'){
        	recipe.Brand_Recipe_Image__c = removeImage(recipe.Brand_Recipe_Image__c, mediaName);
        } else if (mediaName == 'searchRecipe'){
        	recipe.Search_Recipe_Image__c = removeImage(recipe.Search_Recipe_Image__c, mediaName);
        }else if (mediaName == 'additional1'){
        	recipe.Additional_Image_1__c = removeImage(recipe.Additional_Image_1__c, mediaName);
        } else if (mediaName == 'additional2'){
        	recipe.Additional_Image_2__c = removeImage(recipe.Additional_Image_2__c, mediaName);
        }
              
        return null;    
    }
    /**/
    
    public Recipe_Media__c getRecipeMedia(String mediaId) {
        try {  return [Select Version_Number__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Image__c, Id, File_Type__c, CreatedDate, CreatedById, Content_id__c, Content_URL__c, Content_Display_ID__c, Available__c 
             From Recipe_Media__c where Id = :mediaId];
        } 
        Catch (Exception e) {
            return null;
        }
 
    }           
    public PageReference setMediaType2(){
        System.debug('setMediaType2 mediaName: ' + mediaName);
        //loadMediaMap();
        String mediaId = null;
        
        if (mediaName == 'mainRecipe'){
            mediaId = recipe.Main_Drink_Image__c;
        }
        else if (mediaName == 'mobileDrink'){
            mediaId = recipe.Mobile_Drink_Image__c;
        }
        else if (mediaName == 'mobileSelected'){
            mediaId = recipe.Mobile_Selected_Image__c;
        }
        else if (mediaName == 'mobileUnselected'){
            mediaId = recipe.Mobile_Unselected_Image__c;
        }
        else if (mediaName == 'background'){
            mediaId = recipe.Background_Image__c;        
        }
        else if (mediaName == 'brandRecipe'){
            mediaId = recipe.Brand_Recipe_Image__c;     
        }
        else if (mediaName == 'searchRecipe'){
            mediaId = recipe.Search_Recipe_Image__c;  
        }
        else if (mediaName == 'additional1'){
            mediaId = recipe.Additional_Image_1__c;      
        }
        else if (mediaName == 'additional2'){
            mediaId = recipe.Additional_Image_2__c;      
        }
        
        Recipe_Media__c recipeMedia = this.getRecipeMedia(mediaId);
        if (recipeMedia==null) {
            currentImageId = '';
        }
        else {
            currentImageId = recipeMedia.Content_id__c;
        }
        
        
        return null;    
    }
    
    public PageReference saveImages () {
        update recipe;
        return null;
    }
    
    
    public PageReference close(){
        
        PageReference pageRef = new PageReference('/apex/MM_RecipeView?editMode='+editMode+'&recipeId=' + recipe.Id + '&title=' + recipeTitle);
        pageRef.setRedirect(true);
        
        return pageRef;

    }
    
    public PageReference showUpload () {
        selectMediaMode=false;
        uploadMediaMode=true;
        return null;
    }
    
    
    public PageReference showSelectImages () {
        selectMediaMode=true;
        uploadMediaMode=false;
        return null;
    }

    public PageReference filterImages () {
        if(imageNameFilter != null && imageNameFilter.trim()!= ''){
                    
        String filterClause = '%'+imageNameFilter+'%';
        mediaList = [Select Version_Number__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Image__c, Id, 
                    File_Type__c, CreatedDate, CreatedById, Content_id__c, Content_URL__c, Content_Display_ID__c, Available__c 
               From Recipe_Media__c where Name like :filterClause order by Name ASC limit 999];
        } 
        else{
            
            system.debug('@@@@@@@@@@@@@@@@@306 Current Alphabet@@@@@@@@@@@@@@'+selectedAlphabet);
            string currentAlphabet;
            if(selectedAlphabet != null && selectedAlphabet.trim()!=''){
                system.debug('@@@@@@@@@@@@@@@@@309 Selected Alphabet@@@@@@@@@@@@@@'+selectedAlphabet);
                currentAlphabet = selectedAlphabet;
                currentAlpha = selectedAlphabet;
            }
            else{
                system.debug('@@@@@@@@@@@@@@@@@314 Else Loop Current Alphabet@@@@@@@@@@@@@@'+selectedAlphabet);
                currentAlphabet = 'A';
                currentAlpha = 'A';
            }
            
            currentAlphabet = ''+currentAlpha+'%';
            mediaList = [Select Version_Number__c, Name, LastModifiedDate, LastModifiedById, IsDeleted, Image__c, Id, 
                    File_Type__c, CreatedDate, CreatedById, Content_id__c, Content_URL__c, Content_Display_ID__c, Available__c 
                    From Recipe_Media__c where Name like:currentAlphabet order by Name ASC limit 999];
        
        }     
        return null;
    }

    public String getUserAgent() { 
        return ApexPages.currentPage().getHeaders().get('User-Agent');
    }
    
    //returns the list of alphabets to display on to the screen.
    private list<string> alphaSet = new list<string>();
    public list<string> getAlphabets(){
        alphaSet.clear();
            alphaSet.add('A');
            alphaSet.add('B');
            alphaSet.add('C');
            alphaSet.add('D');
            alphaSet.add('E');
            alphaSet.add('F');
            alphaSet.add('G');
            alphaSet.add('H');
            alphaSet.add('I');
            alphaSet.add('J');
            alphaSet.add('K');
            alphaSet.add('L');
            alphaSet.add('M');
            alphaSet.add('N');
            alphaSet.add('O');
            alphaSet.add('P');
            alphaSet.add('Q');
            alphaSet.add('R');
            alphaSet.add('S');
            alphaSet.add('T');
            alphaSet.add('U');
            alphaSet.add('V');
            alphaSet.add('W');
            alphaSet.add('X');
            alphaSet.add('Y');
            alphaSet.add('Z');
            
            return alphaSet;    
    }
}