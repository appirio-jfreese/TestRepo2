public with sharing class Folder {

	public String folderId {public get; public set;}
	public String folderName {public get; public set;}
	public list<Folder> dirs {public get; public set;}	
	public list<File> files {public get; public set;}
	
    public Boolean allowFileUpload {public get; public set;}    
    public Boolean allowAddComment {public get; public set;}    
    
    public Boolean filterByBrand {public get; public set;}    
    public Boolean filterByTime {public get; public set;}    

	public Folder(String fId, String fName) {
		folderId = fId;
		folderName = fName;
		allowFileUpload = false;
		allowAddComment = false;
		dirs = new List<Folder>();
		files = new List<File>();
	}

    public Folder(String fId, String fName, Boolean fUpload, Boolean fComment) {
        folderId = fId;
        folderName = fName;
        allowFileUpload = fUpload;
        allowAddComment = fComment;
        dirs = new List<Folder>();
        files = new List<File>();
    }

    public Folder(String fId, String fName, Boolean fUpload, Boolean fComment, Boolean fFilterBrand, Boolean fFilterTime) {
        folderId = fId;
        folderName = fName;
        allowFileUpload = fUpload;
        allowAddComment = fComment;
        filterByBrand = fFilterBrand;
        filterByTime = fFilterTime;
        dirs = new List<Folder>();
        files = new List<File>();
    }
	
	public void addToFolder(Folder subFolder){
		dirs.add(subFolder);
	}

	public void addToFolder(List<File> fileList){
		files = fileList;
	}
}