public class MLAMB_ContentSOSLPOCController {

    public List<ContentVersion> cvResults {get; set;}
    public String searchTerm {get; set;}
    public boolean haveResults {get; set;}
    
    public MLAMB_ContentSOSLPOCController(){
        cvResults = new List<ContentVersion>();
        searchTerm = null;
        haveResults = false;
    }
    
    public void getDoSOSLSearch() {
        doSOSLSearch();
    }
    
    public void doSOSLSearch() {
        String SOSL_search_string = 'FIND \'' + searchTerm + '\' IN ALL FIELDS RETURNING ContentVersion (ContentDocumentId, '
                                    + 'ReasonForChange, VersionNumber, PositiveRatingCount, NegativeRatingCount, IsLatest, '
                                    + 'Title, FileType, ContentUrl, ContentSize)';
        
        List<List <sObject>> myQuery = search.query(SOSL_search_string);
        haveResults = true;             
        cvResults = myQuery[0];
    }
}