public class LegalIntroController extends Controller_Base {

    public List<POS_BreadCrumb> breadcrumbs {get;set;} 
    
    public LegalIntroController () {
        
        Id currentUser=UserInfo.getUserId();
        
 
        
        breadCrumbs = new List<POS_BreadCrumb>();
        breadCrumbs.add(new POS_BreadCrumb('Legal Intro','#'));
        
        
    }
    
       // for HTML conditional comments
    public String getLt(){
        return '<';
    }
        
    public String getGt(){
        return '>';
    } 
}