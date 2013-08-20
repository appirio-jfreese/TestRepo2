public with sharing class ControllerCalendar {
  
    private ApexPages.StandardController con;
	private Calendar__c calendarRecord;
    public Id currentBrandTheme {public get; public set;}

		 
    public String gradientTop {public get; public set;}
    public String gradientBottom {public get; public set;}
    public String fontColor {public get; public set;}
	public Id calendarSmallLogo {public get; public set;}
	public Id calendarLargeLogo {public get; public set;}

	public String calendarName {public get; private set;}
	public String calendarImg {public get; private set;}
	public String calendarImgLarge {public get; private set;}

	public String orginalCalendarImg {public get; private set;}
	public String orginalCalendarImgLarge {public get; private set;}
    public String orginalGradientTop {public get; public set;}
    public String orginalGradientBottom {public get; public set;}
    public String orginalFontColor {public get; public set;}
	public String orginalStyleBackground { public get; public set; }

	public String styleBackgroundTemplate { public get; public set; }

    public ControllerCalendar(ApexPages.StandardController controller) {
        con = controller;
        calendarRecord = (Calendar__c)controller.getRecord();
        Calendar__c calendar = [select name, Logo_Image_Small__r.content_id__c, Logo_Image_Large__r.content_id__c, background_color__c, Background_Color2__c, Text_Color__c  from Calendar__c where id = :calendarRecord.id];
        calendarName = calendar.Name;
        orginalGradientTop = calendar.background_color__c;
        orginalGradientBottom = calendar.Background_Color2__c;
        orginalFontColor = calendar.Text_Color__c;
		ContentDocument[] cds = [SELECT LatestPublishedVersionId from ContentDocument where Id=: calendar.Logo_Image_Small__r.content_id__c];
		if (cds != null && cds.size()>0) {
			orginalCalendarImg = 'background-image: url(/sfc/servlet.shepherd/version/download/' + cds[0].LatestPublishedVersionId + ');';
		}
		ContentDocument[] cdl = [SELECT LatestPublishedVersionId from ContentDocument where Id=: calendar.Logo_Image_Large__r.content_id__c];
		if (cdl != null && cdl.size()>0) {
			orginalCalendarImgLarge = 'background-image: url(/sfc/servlet.shepherd/version/download/' + cdl[0].LatestPublishedVersionId + ');';
		}   
	    initDefaultTheme();
	    
       	styleBackgroundTemplate = 'background: #START_COLOR;';
		styleBackgroundTemplate += 'background: -moz-linear-gradient(top, #START_COLOR 0%, #END_COLOR 100%);';
		styleBackgroundTemplate += 'background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#START_COLOR), color-stop(100%,#END_COLOR));';
		styleBackgroundTemplate += 'background: -webkit-linear-gradient(top, #START_COLOR 0%,#END_COLOR 100%);';
		styleBackgroundTemplate += 'background: -o-linear-gradient(top, #START_COLOR 0%,#END_COLOR 100%);';
		styleBackgroundTemplate += 'background: -ms-linear-gradient(top, #START_COLOR 0%,#END_COLOR 100%);';
		styleBackgroundTemplate += 'filter: progid:DXImageTransform.Microsoft.gradient(startColorStr=\'#START_COLOR\', EndColorStr=\'#END_COLOR\');';

		if (calendar.background_color__c != null && calendar.background_color2__c == null) {
	    	orginalStyleBackground = 'background-color: #' + calendar.background_color__c + ';';
		} else if (calendar.background_color__c == null && calendar.background_color2__c != null) {
	    	orginalStyleBackground = 'background-color: #' + calendar.background_color2__c + ';';
		} else if (calendar.background_color__c != null && calendar.background_color2__c != null) {
			orginalStyleBackground = 'background: #' + calendar.background_color__c + ';';
			orginalStyleBackground += 'background: -moz-linear-gradient(top, #' + calendar.background_color__c + ' 0%, #' + calendar.background_color2__c + ' 100%);';
			orginalStyleBackground += 'background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#' + calendar.background_color__c + '), color-stop(100%,#' + calendar.background_color2__c + '));';
			orginalStyleBackground += 'background: -webkit-linear-gradient(top, #' + calendar.background_color__c + ' 0%,#' + calendar.background_color2__c + ' 100%);';
			orginalStyleBackground += 'background: -o-linear-gradient(top, #' + calendar.background_color__c + ' 0%,#' + calendar.background_color2__c + ' 100%);';
			orginalStyleBackground += 'background: -ms-linear-gradient(top, #' + calendar.background_color__c + ' 0%,#' + calendar.background_color2__c + ' 100%);';
			orginalStyleBackground += 'filter: progid:DXImageTransform.Microsoft.gradient(startColorStr=\'#' + calendar.background_color__c + '\', EndColorStr=\'#' + calendar.background_color2__c + '\');';
		}
    }
    
    private void initDefaultTheme(){
        gradientTop = 'B9B8B8';
        gradientBottom = 'B9B8B8';
        fontColor = '000000';
        calendarSmallLogo = null;
        calendarLargeLogo = null;
        calendarImg = null;
        calendarImgLarge = null;
    }
    
    public list<SelectOption> getBrandThemes(){
        List<Brand__c> brands = [select id, name, gradient_bottom_color__c, gradient_top_color__c, font_color__c, stroke_color__c from Brand__c order by name];
        List<SelectOption> brandThemes = new List<SelectOption>();
		brandThemes.add(new SelectOption('', 'Default Theme'));
        for(Brand__c brand : brands){
			brandThemes.add(new SelectOption(brand.id, brand.name));
        }
        return brandThemes;
    }

    public pageReference updateCalendarColors(){
    	calendarRecord.background_color__c = gradientTop;
    	calendarRecord.Background_Color2__c = gradientBottom;
    	calendarRecord.Text_Color__c = fontColor;
		return con.save();
    }

    public pageReference updateCalendarLogos(){
    	calendarRecord.Logo_Image_Small__c = calendarSmallLogo;
    	calendarRecord.Logo_Image_Large__c = calendarLargeLogo;
		return con.save();
    }

    public pageReference updateCalendar(){
    	calendarRecord.Logo_Image_Small__c = calendarSmallLogo;
    	calendarRecord.Logo_Image_Large__c = calendarLargeLogo;
    	calendarRecord.background_color__c = gradientTop;
    	calendarRecord.Background_Color2__c = gradientBottom;
    	calendarRecord.Text_Color__c = fontColor;
		return con.save();
    }


    public void switchTheme(){
    	if(currentBrandTheme == null){
    		initDefaultTheme();
    		return;
    	}
    	Brand__c brand = [select Calendar_small_logo__c, Calendar_large_logo__c, Calendar_small_logo__r.content_id__c, Calendar_large_logo__r.content_id__c, gradient_bottom_color__c, gradient_top_color__c, font_color__c from Brand__c where id = :currentBrandTheme];
    	gradientTop = brand.gradient_top_color__c;
		gradientBottom = brand.gradient_bottom_color__c;
		fontColor = brand.font_color__c;
		calendarSmallLogo = brand.Calendar_small_logo__c;
		calendarLargeLogo = brand.Calendar_large_logo__c;
		ContentDocument[] cds = [SELECT LatestPublishedVersionId from ContentDocument where Id=: brand.Calendar_small_logo__r.content_id__c];
		if (cds != null && cds.size()>0) {
			calendarImg = 'background-image: url(/sfc/servlet.shepherd/version/download/' + cds[0].LatestPublishedVersionId + ');';
		} else {
			calendarImg = null;
		}
		ContentDocument[] cdl = [SELECT LatestPublishedVersionId from ContentDocument where Id=: brand.Calendar_large_logo__r.content_id__c];
		if (cdl != null && cdl.size()>0) {
			calendarImgLarge = 'background-image: url(/sfc/servlet.shepherd/version/download/' + cdl[0].LatestPublishedVersionId + ');';
		} else {
			calendarImgLarge = null;
		}	
    }
    
}