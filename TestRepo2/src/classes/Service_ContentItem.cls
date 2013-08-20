/*****************************************************************************************************************
Name        : Sertvice_ContentItem.cls

Updated By  : Jonathan Freese (Appirio)   
Date        : 5/29/13
Story/Task  : US507/TA918

Updated By  : Basant Verma (AppirioOffShore)   
Date        : 6/17/13
Story/Task  : US495/DE600
******************************************************************************************************************/

global public with sharing class Service_ContentItem {
    
    public Boolean isIpadComponent{get;set;}
    // Start : Changed for US495/DE600 - Basant Verma
   	public Set<id> canEditIds {get; set;}
   	public String editableIdsString {get; set;}
   	// End : Changed for US495/DE600 - Basant Verma
    
    public Service_ContentItem(){    	
    	String myuserAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
    	if(myuserAgent != null && myuserAgent.contains('iPad')){
    		isIpadComponent = true;	
    	}else{
    		isIpadComponent = false;
    	}
    }
    
    public Boolean editable{
    	get{
    		try{
    			// Start : Changed for US495/DE600 - Basant Verma
    			if(editableIdsString != null){
    				canEditIds = new Set<Id>();
    				for(String str : editableIdsString.split(', ')){
    					canEditIds.add((Id)(str.trim()));
    				}
	    			if(aggregated.result.get('cvid') != null && aggregated.result.get('cvid') != '')
	    				return canEditIds.contains((id)aggregated.result.get('cvid'));
	    			else
	    				return canEditIds.contains((id)aggregated.result.get('cvidlow'));
	    			} 
    			else{    				
    				return aggregated.result.get('OwnerID') == UserInfo.getUserId();
    			}
    			// End : Changed for US495/DE600 - Basant Verma
    		} catch(Exception ex){
    			return false;
    		}
    	}
    }
    public Datetime createdDate1 {
    	get{
    		try{
    			return (Datetime)aggregated.result.get('createdDate');
    		} catch(Exception ex){
    			return system.now();
    		}
    	}
    	set;
    }
    public Datetime lastLoginDateItem1 {
    	get;
    	set;
    }
    public String cvid1 {
    	get{
    		try{
    			String tmp = (String)aggregated.result.get('cvid');
    			if(tmp != null && tmp != ''){
    				return tmp;
    			} else {
    				return null;
    			} 
    		} catch(Exception ex){
    			return null;
    		}
    	}
    	set;
    }
    public String cvidlow1 {
    	get{
    		try{
    			String tmp = (String)aggregated.result.get('cvidlow');
    			if(tmp != null && tmp != ''){
    				return tmp;
    			} else {
    				return null;
    			} 
    		} catch(Exception ex){
    			return null;
    		}
    	}
    	set;
    }
    public String imageRes1 {
    	get{
    		try{
    			String tmp = (String)aggregated.result.get('imageRes');
    			if(tmp != null && tmp != ''){
    				return tmp;
    			} else {
    				return null;
    			}
    		} catch(Exception ex){
    			return null;
    		}
    	}
    	set;
    }
    public String fileType1 {
    	get{
    		try{
    			return (String)aggregated.result.get('filetype');
    		} catch(Exception ex){
    			return '';
    		}
    	}
    	set;
    }
    public String fileSize1 {
    	get{
    		try{
    			return (String)aggregated.result.get('filesize');
    		} catch(Exception ex){
    			return '';
    		}
    	}
    	set;
    }
    public Boolean displayUploadDate1 {
    	get;
    	set;
    }
    public Boolean showDownloadShare1 {
    	get;
    	set;
    }
    public Boolean showListButtons1 {
    	get;
    	set;
    }
    public Boolean isVideo1 {
    	get{
    		try{
    			return (Boolean)aggregated.result.get('is_video');
    		} catch(Exception ex){
    			return false;
    		}
    	}
    	set;
    }
    public String videoId1 {
    	get{
    		try{
    			String tmp = (String)aggregated.result.get('video_id');
    			if(tmp != null && tmp != ''){
    				return tmp;
    			} else {
    				return null;
    			}
    		} catch(Exception ex){
    			return null;
    		}
    	}
    	set;
    }
    public Boolean previewAvailable1 {
    	get{
    		try{
    			return (Boolean)aggregated.result.get('previewAvailable');
    		} catch(Exception ex){
    			return false;
    		}
    	}
    	set;
    }
    public String previewId1 {
    	get{
    		try{
    			String tmp = (String)aggregated.result.get('previewId');
    			if(tmp != null && tmp != ''){
    				return tmp;
    			} else {
    				return null;
    			}
    		} catch(Exception ex){
    			return null;
    		}
    	}
    	set;
    }
    public String width1 {
    	get;
    	set;
    }
    public String height1 {
    	get;
    	set;
    }
    public String margin1 {
    	get{
    		try{
    			return (String)aggregated.result.get('margin');
    		} catch(Exception ex){
    			return null;
    		}
    	}
    	set;
    }
    public Boolean renderAsList1 {
    	get;
    	set;
    }
    public String description2 {
    	get{
	        try{
    			return (String)aggregated.result.get('description');
    		} catch(Exception ex){
    			return null;
    		}
    	}
    	set;
    }
    public String cutoffDescription2 {
        get{
            try{
	               String ret=description2;
	               if (ret.length() > 25){
	               	  ret=ret.substring(0,25).trim()+'...';
	               }
                   return ret;
            } catch(Exception ex){
                return null;
            }
        }
        set;
    }

    /* Start: changes for TA918 Jonathan Freese */
    public String title1 {
    	get{
	        try{
    			return (String)aggregated.result.get('title');
    		} catch(Exception ex){
    			return '';
    		}
    	}
    	set;
    }
    /*   End: changes for TA918 Jonathan Freese */
    
    public AggregateResultHolder aggregated {get;
    	set{
    		aggregated = value;
    		}
    }
    
    public Set<id> basketIds {get; set;}
    
    public Set<id> followIds {get; set;}
    
	public Boolean inBasket {
    	get{
	        try{
	        	if(basketIds != null){
	        		if(basketIds.contains(cvid1) || basketIds.contains(cvidlow1)){
	        			return true;
	        		} else {
	        			return false;
	        		}
	        	} else {
	        		return false;
	        	}
    		} catch(Exception ex){
    			return false;
    		}
    	}
    	set;
    }
    
	public Boolean inFollow {
    	get{
	        try{
	        	if(followIds != null){
	        		if(followIds.contains(cvid1) || followIds.contains(cvidlow1)){
	        			return true;
	        		} else {
	        			return false;
	        		}
	        	} else {
	        		return false;
	        	}
    		} catch(Exception ex){
    			return false;
    		}
    	}
    	set;
    }
    
    public void setaggregated(object a){
    	aggregated = (AggregateResultHolder)a;
    }
    
    
    public Date getcreatedDate2() {
    	createdDate1 = (createdDate1 == null) ? system.now() : createdDate1;
    	Date convertedDate = Date.newInstance(createdDate1.year(),createdDate1.month(),createdDate1.day());
    	return convertedDate;       
    }   
    
    public void setlastLoginDateItem(object b)
    {
    	 lastLoginDateItem1 = (Datetime)b;   
    	
    }
        
	public Boolean getisNew(){
		if(lastLoginDateItem1 < createdDate1)
		{
			return true;
		}else{
			return false;
		}		
	}
	
	public Boolean canEdit(){
		return aggregated.result.get('OwnerId') == UserInfo.getUserId();
	}
	
	public String cid {
    	get{
    		try{
    			String tmp = (String)aggregated.result.get('id');
    			if(tmp != null && tmp != ''){
    				return tmp;
    			} else {
    				return null;
    			} 
    		} catch(Exception ex){
    			return null;
    		}
    	}
    	set;
    }
    public String fileTypePath {
        get{
            try{
                String ret = '';
                if (fileType1=='AI'){
                    ret='/i/filetype/ai_120.png';
                }
                else if  (fileType1=='BMP'){
                    ret='/i/filetype/bmp_120.png';
                }
                else if  (fileType1=='EPS'){
                    ret='/i/filetype/eps_120.png';
                }
                else if  (fileType1=='EXCEL' || fileType1=='EXCEL_M' || fileType1=='EXCEL_X'){
                    ret='/i/filetype/xls_120.png';
                }
                else if  (fileType1=='M4V'){
                    ret='/i/filetype/m4v_120.png';
                }
                else if  (fileType1=='MP3'){
                    ret='/i/filetype/mp3_120.png';
                }
                else if  (fileType1=='MP4'){
                    ret='/i/filetype/mp4_120.png';
                }
                else if  (fileType1=='PDF'){
                    ret='/i/filetype/pdf_120.png';
                }
                else if  (fileType1=='PNG'){
                    ret='/i/filetype/png_120.png';
                }
                else if  (fileType1=='POWER_POINT' || fileType1=='POWER_POINT_M' || fileType1=='POWER_POINT_X'){
                    ret='/i/filetype/ppt_120.png';
                }
                else if  (fileType1=='PSD'){
                    ret='/i/filetype/psd_120.png';
                }
                else if  (fileType1=='TEXT'){
                    ret='/i/filetype/txt_120.png';
                }
                else if  (fileType1=='TIFF'){
                    ret='/i/filetype/TIFF_120.png';
                }
                else if  (fileType1=='WMV'){
                    ret='/i/filetype/wmv_120.png';
                }
                else if  (fileType1=='WORD' || fileType1=='WORD_X'){
                    ret='/i/filetype/doc_120.png';
                }
                else if  (fileType1=='ZIP'){
                    ret='/i/filetype/zip_120.png';
                }
                else {
                	ret='/i/filetype/general_120_2.png';
                }
                return ret; 
            } catch(Exception ex){
                return null;
            }
        }
        set;
    }
}