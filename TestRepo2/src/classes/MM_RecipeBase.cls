/* Class Name   : MM_RecipeBase
   Developer    : MM Developer  
   Purpose: 
   Modified By  : Deepak Sharma(Appirio Offshore on 11-Sep-2012)
   Details      : Modified against T-81876: Modify Code - Workflow rules / code   
*/



public virtual class MM_RecipeBase {
	//T-81876
	public static final String  RECIPE_EDITOR = 'Recipe - Editor';  
	public static final String  RECIPE_REVIEWER = 'Recipe - Reviewer';
	public static final String  RECIPE_APPORVER = 'Recipe - Approver';
	public static final String  RECIPE_ADMIN =  'Recipe - Admin';
	//-------
	//I-41400-Recipe Publisher Role unable to create new recipe or clone from existing recipe
	public static final String  RECIPE_PUBLISHER =  'Recipe - Publisher';
	//------
	
	public Boolean isReviewer;
	public Boolean isEditor;
	public Boolean isApprover;
	public Boolean isSuperAdmin;
	public Boolean isPublisher;
	public String currentServerInstance = null;			
	public String currentRole;
	public User currentUser;
	
	public virtual User getCurrentUser() {

		if (currentUser == null)
			currentUser = [SELECT Id, FirstName, Name FROM User WHERE Id = :UserInfo.getUserId()];
		
		return currentUser;
		
	}
	
	public virtual String getCurrentRole() {

		if (currentRole == null){
			User u = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
			String roleName = u.UserRole.Name;
			currentRole = roleName;
			System.debug('currentRole: ' + currentRole);
		}
		return currentRole;
		
		
	}
	
	//I-41400-Recipe Publisher Role unable to create new recipe or clone from existing recipe
	public virtual Boolean getIsPublisher() {
		if (isPublisher == null) {
			User u = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
			String roleName = u.UserRole.Name;

			if(roleName == RECIPE_PUBLISHER) {
				isPublisher = true;
			} else {
				isPublisher = false;
			}
		}
		return isPublisher;
	}
	//------------------------
	public virtual Boolean getIsReviewer() {
		
		if (isReviewer == null){
			User u = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
			String roleName = u.UserRole.Name;
			
			if(roleName == RECIPE_REVIEWER) {
				isReviewer = true;
			} else {
				isReviewer = false;
			}
		}
		return isReviewer;
	}
	
	public virtual Boolean getIsEditor() {
		
		if (isEditor == null){
			String roleName = getCurrentRole();
			System.debug('isEditor? ' + roleName);
			//if(roleName == 'Editor')
			if(roleName == RECIPE_EDITOR) {
				isEditor = true;
			}
			else {
				isEditor = false;
			}
		
		System.debug('isEditor? ' + isEditor);				
		}
			
		return isEditor;
		
	}
	
	public virtual Boolean getIsApprover() {
		
		if (isApprover == null){
			String roleName = getCurrentRole();
			//if(roleName == 'Approver')
			if(roleName == RECIPE_APPORVER) {
				isApprover = true;
			}
			else {
				isApprover = false;
			}
		}
			
		return isApprover;
		
	}	
	
	public virtual Boolean getIsSuperAdmin() {
		
		if (isSuperAdmin == null){
			String roleName = getCurrentRole();
			//if(roleName == 'Administrator')
			if(roleName == RECIPE_ADMIN) {
				isSuperAdmin = true;
			}
			else {
				isSuperAdmin = false;
			}
		}
			
		return isSuperAdmin;
		
	}		
	
	public virtual User getUserById(Id userId){
		try{
			if (userId != null)
				return [SELECT Id, FirstName, Name FROM User WHERE Id = :userId];
			else
				return [SELECT Id, FirstName, Name FROM User WHERE Id = :UserInfo.getUserId()];
		}
		catch (Exception e){
			return [SELECT Id, FirstName, Name FROM User WHERE Id = :UserInfo.getUserId()];
		}
		
	}
	 
	public virtual String getCurrentServerInstance() {
		String serverHeader = ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To');
		return getCurrentServerInstance(serverHeader); 
	}
	
	public virtual String getCurrentServerInstance(String tmp) {
		String[] tmplist = tmp.split('\\.');
		currentServerInstance = tmplist[0];
		return currentServerInstance;
	}	
	
	public Pagereference logoutmethod(){
		PageReference p = new PageReference('/secur/logout.jsp');
		return p;
	}


}