public without sharing class Service_FolderComments {

	private File__c fileObject { private get; private set; }
	public String fileName { get; private set; }
	public String folderName { get; set; }
	public Integer numberOfCommentsToShow { get; set; }
	public Integer incrementNumberOfComments { get; set; }
	public Integer commentPage { get; set; }
	public String currentUserId { get; private set; }
	public Boolean isInternalUser { get; set; }
	public Boolean hasMoreComments { get; private set; }
	public String removeCommentId { get; set; }	
	public list<Folder_Comment__c> comments {get; protected set;}
	public String commentBody { get; set; }
	public String distributorId { get; set{
		distributorId = value;
		getFileComments();
	}}
	public String distributor { get; set{
		distributor = value;
		getFileComments();
	}}
	public String folderId { get; set{
		folderId = value;
		getFileComments();
	}}
	public String fileId { get; set{
		if(fileId != value){
			commentPage = 0;
		}
		if(fileId != null && fileId.equals('')){
			fileId = null;
		} else {
			fileId = value;
		}
		getFileComments();
		if(fileId != null && !fileId.equals('')){
			try {
 				File__c fileObject = [select Id, Content_ID__c, Content_Version_Id__c, Description__c, filetype__c, Is_Video__c, Title__c, Video_Id__c, Preview_Id__c, Preview_Available__c, share_link__c from File__c where Id = :fileId limit 1 ];
 				fileName = fileObject.Description__c;
			}
			catch (Exception e) {
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load file name.' ));
				fileName = null;
			}
		} else {
			fileName = folderName;
		}
	}}
	public Boolean isAdded {
		public get{
			if(isAdded) {
				isAdded=false;
	            commentBody = null;
				return true;
			}
			return isAdded;
		}
		public set;
	}

	public Service_FolderComments() {
		init();
	}

	private Boolean validateBeforeSave(){
		if(commentBody == null || commentBody.equals('') || commentBody.length() > 999){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to add comment. Comment text is required.' ));
			isAdded = false;
			return false;
		}
		if(commentBody.length() > 999){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to add comment. Comment text is to long.' ));
			isAdded = false;
			return false;
		}

		return true;
	}

    public void removeCommentMsg(){
		try{
			Folder_Comment__c comment = Service_API.getFileComment(distributorId, folderId, fileId, removeCommentId);
			if(!isInternalUser){
				if(comment.OwnerId != currentUserId){
					ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to remove comment. Permission deny.' ));
					return;
				}
			}
			delete comment;
			getFileComments();
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'Comment removed.'));
		}
		catch (Exception e) {
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to remove comment.' ));
			return;
		}
    }

    public void addCommentMsg(){
		try{
			if(validateBeforeSave()){
				Folder_Comment__c fcomment = new Folder_Comment__c();
				fcomment.Comment_Body__c = commentBody;
				fcomment.Distributor_Name__c = Service_API.getAID();
				fcomment.Distributor_Access__c = distributorId;
				fcomment.folder__c = folderId;
				if(fileId != null && !fileId.equals('')){
					fcomment.file__c = fileId;
				}
				fcomment.Classification__c = Service_Api.getSectionTheme();
				fcomment.OwnerId = currentUserId;
				insert fcomment;
				isAdded = true; 
				getFileComments();
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'Comment added.' ));
				commentBody = null;
			}
		}
		catch (Exception e) {
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to add comment.' ));
			isAdded = false;
			return;
		}
    }   

	public List<Folder_Comment__c> getFileComments(){
		comments = new List<Folder_Comment__c>();
		if(folderId != null && !folderId.equals('') && distributorId != null && !distributorId.equals('')){
			try{
				comments = Service_API.getFileComments(distributorId, folderId, fileId);
			}
			catch (Exception e) {
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load comment.' ));
			}
		}		
		return comments;
    }
    
    public void showMoreComments(){
    	if(hasMoreComments){
    		commentPage++;
    	}
    }

	public List<Folder_Comment__c> getCommentsToShow(){
		List<Folder_Comment__c> toShow = new List<Folder_Comment__c>();
		hasMoreComments = false;
		if(comments != null){
			Integer commentLimit = numberOfCommentsToShow + (commentPage * incrementNumberOfComments);
			Integer alreadyAdded = 0;
			for(Folder_Comment__c comment : comments){
				if(alreadyAdded == commentLimit){
					hasMoreComments = true;
					break;
				}
				toShow.add(comment);
				alreadyAdded++;
			}
		}
		return toShow;
    }
    
    private void init(){
		currentUserId = UserInfo.getUserId();
		comments = new List<Folder_Comment__c>();
		isAdded = false;
		commentBody = null;
		distributorId = null;
		folderId = null;
		fileId = null;
		if(numberOfCommentsToShow == null){
			String setting_numberOfCommentsToShow = Service_API.getSetting('numberOfCommentsToShow.default');
			if(setting_numberOfCommentsToShow == null || setting_numberOfCommentsToShow.equals('')){
				numberOfCommentsToShow = 20;
			} else {
				numberOfCommentsToShow = Integer.valueOf(setting_numberOfCommentsToShow);
			}
		}
		if(incrementNumberOfComments == null){
			String setting_incrementNumberOfComments = Service_API.getSetting('numberOfCommentsToShow.increment');
			if(setting_incrementNumberOfComments == null || setting_incrementNumberOfComments.equals('')){
				incrementNumberOfComments = 20;
			} else {
				incrementNumberOfComments = Integer.valueOf(setting_incrementNumberOfComments);
			}
		}
		commentPage = 0;
    }
}