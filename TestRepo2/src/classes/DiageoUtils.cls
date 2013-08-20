public with sharing class DiageoUtils {
	
	
	
	public static String getMonthFullnameFromMonthNumber(Integer month)
	{
		if(month == 1)
			return 'January';
		if(month == 2)
			return 'Febuary';
		if(month == 3)
			return 'March';
		if(month == 4)
			return 'April';
		if(month == 5)
			return 'May';
		if(month == 6)
			return 'June';
		if(month == 7)
			return 'July';
		if(month == 8)
			return 'August';
		if(month == 9)
			return 'September';
		if(month == 10)
			return 'October';
		if(month == 11)
			return 'November';
		if(month == 12)
			return 'December';
		
		
		return 'NA' ;
	}
	
	// Added here from Controller_AccountVolumeAndPointsView
	public static decimal calculateShare(decimal thisYear,decimal lastyear){
      // AT (09/27/12) Changed Calculation
      
      try{
      if (lastyear!=0 && thisYear!=0){
        // return (((thisYear-lastYear)/lastYear)*100);
       //  Decimal d1 = (((thisYear-lastyear)/lastyear)*100);
       //  long l1 = d1.round();
       //  return l1;
        // return (((thisYear.setscale(2)-lastyear.setscale(2))/lastyear.setscale(2))*100).setscale(2);
        return (((thisYear-lastYear)/lastYear)*100);
      }
         
      else if(lastyear==0 && thisYear!=0){     
         return 100;
      }
         
      else{
         return 0;
      }
      }catch (exception e){
         return 0;
      }
    }
    
    // START : Changes For US585/TA1081	: Parul Gupta
    public static List<SelectOption> getMonthOptions() {
    	List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1','Jan'));
        options.add(new SelectOption('2','Feb'));
        options.add(new SelectOption('3','Mar'));
        options.add(new SelectOption('4','Apr'));
        options.add(new SelectOption('5','May'));
        options.add(new SelectOption('6','Jun'));
        options.add(new SelectOption('7','Jul'));
        options.add(new SelectOption('8','Aug'));
        options.add(new SelectOption('9','Sep'));
        options.add(new SelectOption('10','Oct'));
        options.add(new SelectOption('11','Nov'));
        options.add(new SelectOption('12','Dec')); 
        return options;
    }
    
    public static List<SelectOption> getYearOptions(Integer startYear, 
    								Integer totalYrs) {
        List<SelectOption> options = new List<SelectOption>();
        Integer year = startYear;
        for(Integer index = 0; index < totalYrs; index++){
        	options.add(new SelectOption(String.valueOf(year), 
        				String.valueOf(year)));
        	year++;
        }       
        return options;
    }
    // END : Changes For US585/TA1081	: Parul Gupta
   
	
}