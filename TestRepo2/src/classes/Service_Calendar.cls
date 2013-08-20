/**
* @author Denise Bacher
* @date 31/08/2011
* @description API Service class to handle date ranges for calendar pages
*/
public class Service_Calendar {
    //first month of the fiscal year
    private Integer fiscalStartMonth = 7;

    //Specify month range: 1-month view, 3,6,12 - fiscal quarter, half, year
    public Integer dateRange {get;private set;}
    public Date startDate    {get;private set;}
    public Date endDate      {get;private set;}

    /**
    * @author Wojciech Migas
    * @date 22/11/2011
    * @description Return fiscal quarter which contains start date
    */
    public Integer fiscalQuarter {
        get {
            if (startDate.month() == fiscalStartMonth) {
                return 1;
            } else if(startDate.month() == fiscalStartMonth+3) {
                return 2;
            } else if (startDate.month() == fiscalStartMonth-6) {
                return 3;
            } else {
                return 4;
            }        
        }
        private set;
    }
    
    /**
    * @author Mateusz Malik
    * @date 22/11/2011
    * @description Return fiscal month which contains start date
    */
    public Integer fiscalMonth{
        get {
            if (startDate.month() == fiscalStartMonth) {
                return 1;
            } else if(startDate.month() == fiscalStartMonth+1) {
                return 2;
            } else if(startDate.month() == fiscalStartMonth+2) {
                return 3;
            } else if(startDate.month() == fiscalStartMonth+3) {
                return 4;
            } else if(startDate.month() == fiscalStartMonth+4) {
                return 5;
            } else if(startDate.month() == fiscalStartMonth+5) {
                return 6;
            } else if(startDate.month() == fiscalStartMonth+6) {
                return 7;
            } else if(startDate.month() == fiscalStartMonth+7) {
                return 8;
            } else if(startDate.month() == fiscalStartMonth+8) {
                return 9;
            } else if(startDate.month() == fiscalStartMonth+9) {
                return 10;
            } else if(startDate.month() == fiscalStartMonth+10) {
                return 11;
            } else{
            	return 12;
            }
        }
        private set;
    }

    /**
    * @author Wojciech Migas
    * @date 22/11/2011
    * @description Return fiscal year which contains start date
    */
    public Integer fiscalYear {
        get {
            if(startDate.month() >= fiscalStartMonth){
                return startDate.year() + 1;
            } else {
                return startDate.year();
            }
        }
        private set;
    }
    
    /**
    * @author Wojciech Migas
    * @date 22/11/2011
    * @description Default constructor. Set month range to 1 month and date to current
    */
    public Service_Calendar() {
        initDateRange(1, null);
    }

    /**
    * @author Wojciech Migas
    * @date 22/11/2011
    * @param monthRange  
    * @description Constructor. Allow to set time month range
    */
    public Service_Calendar(Integer monthRange) {
        initDateRange(monthRange, null);
    }

    /**
    * @author Wojciech Migas
    * @date 22/11/2011
    * @param monthRange
    * @param startFromDate  
    * @description Constructor. Allow to set time month range and start date
    */
    public Service_Calendar(Integer monthRange, Date startFromDate) {
        initDateRange(monthRange, startFromDate);
    }

    /**
    * @author Wojciech Migas
    * @date 22/11/2011
    * @param monthRange
    * @param startFromDate  
    * @description Set start and end date for specified month range and date
    */
    public void initDateRange(Integer monthRange, Date startFromDate) {
        dateRange = monthRange;
        //set start date
        Date currDate;
        if (startFromDate != null){
            currDate = startFromDate;   
        } else {
            currDate = date.today();
        }

        if (dateRange == 1) {
            startDate = date.valueof(currDate.year() + '-' + currDate.month() + '-01');
            endDate   = date.valueof(currDate.year() + '-' + currDate.month() + '-' + date.daysInMonth(currDate.year(), currDate.month()));
        } else if (dateRange == 3) {
            Integer modMonth = math.mod(currDate.month(), 3);
            if (modMonth == 0) {
                modmonth = 2;
            } else {
                modMonth--;
            }
            startDate = date.valueof(currDate.year() + '-' + (currDate.month()-modmonth) + '-01');
            endDate   = startDate.addMonths(2);
            endDate   = date.valueof(endDate.year() + '-' + endDate.month() + '-' + date.daysInMonth(endDate.year(), endDate.month()));
        } else if (dateRange == 6) {
            if (currDate.month() >= fiscalStartMonth) {
                startDate = date.valueof(currDate.year() + '-07-01');
                endDate = date.valueof(currDate.year() + '-12-31');
            } else {
                startDate = date.valueof(currDate.year() + '-01-01');
                endDate = date.valueof(currDate.year() + '-06-30');
            }
        } else {
            if (currDate.month() >= fiscalStartMonth) {
                startDate = date.valueof(currDate.year() + '-07-01');
                endDate = date.valueof((currDate.year()+1) + '-06-30');
            } else {
                startDate = date.valueof((currDate.year()-1) + '-07-01');
                endDate = date.valueof(currDate.year() + '-06-30');
            }
        }
    }

    /**
    * @author Wojciech Migas
    * @date 22/11/2011
    * @param span The number of months to change the date range (+/-)
    * @description Reset the date range for the new increment
    */
    public void incrementDates(Integer span) {
        startDate = startDate.addMonths(span);
        initDateRange(dateRange, startDate);
    }

    /**
    * @author Bartek Dudziak
    * @date 08/09/2011
    * @param span The number of month to change the date range
    */
    public void incrementMonth(Integer span) {
        startDate = startDate.addMonths(span);
        initDateRange(dateRange, startDate);
    }

    /**
    * @author Bartek Dudziak
    * @date 08/09/2011
    * @param span The number of quarters to change the date range (include change of fiscal year)
    */
    public void incrementQuarter(Integer span) {
        startDate = startDate.addMonths(span*3);
        initDateRange(dateRange, startDate);
    }

    /**
    * @author Bartek Dudziak
    * @date 08/09/2011
    * @param span The number of half to change the date range (include change of fiscal year)
    */
    public void incrementHalf(Integer span) {
        startDate = startDate.addMonths(span*6);
        initDateRange(dateRange, startDate);
    }

    /**
    * @author Bartek Dudziak
    * @date 08/09/2011
    * @param span The number of year to change the date range (include change of fiscal year)
    */
    public void incrementYear(Integer span) {
        startDate = startDate.addYears(span);
        initDateRange(dateRange, startDate);
    }
}