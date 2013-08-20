public with sharing class File {

	public String cvid {get; set;}
	public String videoId {get; set;}
	public String name {get; set;}
	public String filesize {get; set;}
	public String filetype {get; set;}
		
	public File(String fId, String fName, String fSize, String fType) {
		cvid = fId;
		name = fName;
		filesize = fSize;
		filetype = fType;
		videoId = null;
	}

	public File(String fId, String fName, String fSize, String fType, String fvid) {
		cvid = fId;
		name = fName;
		filesize = fSize;
		filetype = fType;
		videoId = fvid;
	}
}