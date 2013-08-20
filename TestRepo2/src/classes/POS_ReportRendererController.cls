public with sharing class POS_ReportRendererController {
	public List<String>			orderWindows 		{ get; set; }
	public string 				classification 		{ get; set; }
	public List<String> 		brands 				{ get; set; }
	public List<String> 		organizationalUnits { get; set; }
	public List<String> 		distributors 		{ get; set; }
	
	public POS_ReportRendererController(){
		PageReference ref = ApexPages.currentPage();
		Map<String, String> params = ref.getParameters();
		String ow = params.get('ow');
		String cl = params.get('cl');
		String br = params.get('br');
		String ou = params.get('ou');
		String ds = params.get('ds'); 
		if(ow!=null)
			orderWindows = ow.split(',');
		if(cl!=null)
			classification = cl;
		if(br!=null)
			brands = br.split(',');
		if(ou!=null)
			organizationalUnits = ou.split(',');
		if(ds!=null)
			distributors = ds.split(',');
	}
}