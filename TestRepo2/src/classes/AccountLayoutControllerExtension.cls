/**
*   @this class is global because of my need to implement the Comparable interface.
*
*   @Author     : Jeremy Mooer
*   @Date       : 12 Jun 2012
*/
global with sharing class AccountLayoutControllerExtension 
{
    
    public Account accountRecord{get;set;}
    
    public List<Sales_Volume__c> listOps1a{get;set;}
    public List<DataFor3a> listTopPerformance3a{get;set;}
    public List<DataFor3a> listBottomPerformance3a{get;set;}
    public List<Sales_Volume__c> list2a{get;set;}
    
    public List<SelectOption> brandListFor2a{get;set;}
    
    public String selected1aWineSpirit{get;set;}
    public String chart3aSelectedDiv{get;set;}
    public String chart2aSelectedBrand{get;set;}
    
    public Boolean display2a{get;set;}
    
    
    private List<Sales_Volume__c> allSalesVolumeFor1a;
    private List<Sales_Volume__c> allSalesVolumeFor3a;
    private List<Sales_Volume__c> allSalesVolumeFor2a;
    
    public AccountLayoutControllerExtension(ApexPages.StandardController controller) 
    {
        accountRecord = (Account)controller.getRecord();
        system.debug('=========chart2aSelectedBrand======1====='+chart2aSelectedBrand);
        String selected1aWineSpirit = ApexPages.currentPage().getParameters().get('selected1aWineSpirit') ;
        String chart2aSelectedBrand = ApexPages.currentPage().getParameters().get('chart2aSelectedBrand') ;
        String chart3aSelectedDiv = ApexPages.currentPage().getParameters().get('chart3aSelectedDiv') ;
        system.debug('@@@BEN@@@ page parm in constuctor is ' + chart2aSelectedBrand );
                
        
        if(chart2aSelectedBrand != null)
            chart2aSelectedBrand = EncodingUtil.urlDecode(chart2aSelectedBrand, 'UTF-8');
        system.debug('@@@BEN@@@ chart2aSelectedBrand after url decode is ' + chart2aSelectedBrand);
        
        init(accountRecord, selected1aWineSpirit, chart2aSelectedBrand, chart3aSelectedDiv);
    }
    
    
    public List<SelectOption> getWineSpiritsOptions()
    {
        List<SelectOption> optionsToReturn = new List<SelectOption>();
        optionsToReturn.add(new SelectOption('Spirits','Spirits'));
        optionsToReturn.add(new SelectOption('Wines','Wines'));
        
        return optionsToReturn;
    }
    
    
    public void init(Account acct, String spiritsWineText, String c2aSelectedBrand, String c3aSelectedDiv)
    {
        display2a = false;
        selected1aWineSpirit = spiritsWineText;
       // brandListFor2a = new List<SelectOption>();
        
        chart2aSelectedBrand = c2aSelectedBrand;
        chart3aSelectedDiv = c3aSelectedDiv ; //if this one is null later on, it gets set post loop.
        
        if(selected1aWineSpirit == null || selected1aWineSpirit == 'Spirits') {
            selected1aWineSpirit = 'Spirits'; //if statement for code coverage.
        }
        
        if(chart2aSelectedBrand == null) {
            chart2aSelectedBrand = '';
        }
        system.debug('@@@BEN@@@ check value of chart2aSelectedBrand after setting to empty ' + chart2aSelectedBrand);
        
        if(chart3aSelectedDiv == null)
            chart3aSelectedDiv = 'Spirits';
        
        
        initOps1aList(acct) ;
        init3aPerformance(acct);
        init2aData(acct);
    }
    
    private void init2aData(Account acct)
    {
        allSalesVolumeFor2a = new list<Sales_Volume__c>();
        /* Start for case 00037876 */
        if(chart2aSelectedBrand == null || chart2aSelectedBrand == '') {
                chart2aSelectedBrand = 'Total Spirits';
        }
        date latestDataDate ;
        for(Sales_Volume__c  sv : [select Id, Month_End__c from Sales_Volume__c where 
                                    Batf_Volume_12_Mo_TY_vs_LY_Chg__c <> null                                   
                                    and Month_End__c <> null
                                    and Division__c <> null                                
                                    and Batf_Volume_12_Mo_TY_vs_LY_Chg__c <> null
                                    and  Batf_Volume_12_Mo_TY__c = null
                                    and Individual_Brand__c =: chart2aSelectedBrand                        
                                    and Account__c = :acct.Id order by Month_end__c desc Limit 1]){
            latestDataDate = sv.Month_End__c;
        }                                        
        
        if(latestDataDate == null){
             latestDataDate = Date.today();   
        }                    
        date  periodStart = date.newInstance(latestDataDate.year()-1,latestDataDate.month(), latestDataDate.day()); 
        /* End for case 00037876 */
        
        brandListFor2a = new List<SelectOption>();
        system.debug('@@@BEN@@@ we are in teh init2data method'); 
        allSalesVolumeFor2a = [select Id, Batf_Volume_12_Mo_TY_vs_LY_Chg__c, Month_End__c,  Account__c, Division__c, 
                                    Individual_Brand__c, State_Batf_Volume_12_Mo_TY__c, State_Distro__c, Generic_Brand__c, 
                                    Brcat_Fin_Plan_Brand__c, Year_End__c, Batf_Volume_12_Mo_TY__c, State_12M_Chg_vs_YA__c, 
                                    Acct_List_Rep_CT_w_ROM_and_ON__c, Batf_Volume_TY_vs_LY_Chg__c, 

Batf_Volume_FYTD_TY_vs_LY_Chg__c, 
                                    Batf_Volume_3_Mo_TY_vs_LY_Chg__c, Batf_Volume_6_Mo_TY_vs_LY_Chg__c, Size__c
                                from Sales_Volume__c
                                where Batf_Volume_12_Mo_TY_vs_LY_Chg__c <> null
                                and Month_End__c <> null
                                and Month_End__c >=: periodStart
                                and Division__c <> null
                                
                                and Batf_Volume_12_Mo_TY_vs_LY_Chg__c <> null
                                and  Batf_Volume_12_Mo_TY__c = null
                                
                                and Account__c = :acct.Id
                                order by individual_brand__c, month_end__c] ;
        
        system.debug('@@@BEN@@@ size of sales volume list is ' + allSalesVolumeFor2a.size());
        
        if(allSalesVolumeFor2a != null && !allSalesVolumeFor2a.isEmpty()) {
            display2a = true;
            Map<String,String> brandStringSet = new Map<String,String>();
            for(Sales_Volume__c sv : allSalesVolumeFor2a) {
                if(sv.Individual_Brand__c != null && brandStringSet.get(sv.Individual_Brand__c) == null) {
                    brandStringSet.put(sv.Individual_Brand__c, sv.Individual_Brand__c);
                    brandListFor2a.add(new SelectOption(sv.Individual_Brand__c,sv.Individual_Brand__c));
                }
            }
            
            
            if(chart2aSelectedBrand == null || chart2aSelectedBrand == '') {
                chart2aSelectedBrand = 'Total Spirits';
            }
            system.debug('@@@BEN@@@ value of chart2aSelectedBrand should be total spirits and it is ==>' + 

chart2aSelectedBrand);
            
            filterList2aByBrand(chart2aSelectedBrand);
            
        }
    }
    
    private void filterList2aByBrand(String brand)
    {
        chart2aSelectedBrand = brand;
        list2a = new List<Sales_Volume__c>();
        for(Sales_Volume__c sv : allSalesVolumeFor2a) {
            if(sv.Individual_Brand__c == brand) {
                list2a.add(sv);
            }
        }
        system.debug('@@@BEN@@@ size of sv list is ' + list2a.size());
        system.debug('@@@BEN@@@ the list is ' + list2a);
    }
    
    
    
    private void init3aPerformance(Account acct)
    {
      
        listTopPerformance3a = new List<DataFor3a>();
        listBottomPerformance3a = new List<DataFor3a>();
        List<DataFor3a> dataList = new List<DataFor3a>();
        for(Sales_Volume__c salesVol : [select Id, State_12M_Chg_vs_YA__c, Batf_Volume_12_Mo_TY_vs_LY_Chg__c,
                                            brcat_fin_plan_brand__c, Individual_Brand__c, Generic_Brand__c, Division__c
                                        from Sales_Volume__c
                                        where  Account__c = :acct.Id  
                                        and Batf_Volume_12_Mo_TY_vs_LY_Chg__c <> null 
                                        and State_12M_Chg_vs_YA__c <> null
                                        and Division__c = :chart3aSelectedDiv ])
        {
            dataList.add( new DataFor3a(salesVol) );
        }
        
        if(dataList != null && !dataList.isEmpty()) {
            dataList.sort();
            Integer listSize = dataList.size() ;
            Integer topPoint = listSize / 2;
            if(topPoint > 10)
                topPoint = 10;
            Integer bottomPoint = listSize / 2;
            if(bottomPoint > 10)
                bottomPoint = listSize - 11;
            
            if(listSize > 1) {
                for(Integer i = 0; i < dataList.size(); i++)
                {
                    if(i <= topPoint && listBottomPerformance3a.size() < 10) { //FOR BOTTOM PERFORMERS
                        listBottomPerformance3a.add(dataList[i]);
                    }
                    else if(i > bottomPoint){ //FOR TOP PERFORMERS
                        listTopPerformance3a.add(dataList[i]);
                    }
                }
            }
            else
            {
                listTopPerformance3a.add(dataList[0]);
            }
            
            utilityReverseTopPerformance3aList();
        }
        
    }
    
    private void utilityReverseTopPerformance3aList()
    {
        if(listTopPerformance3a != null && listTopPerformance3a.size() > 1) {
            List<DataFor3a> tempList = new List<DataFor3a>();
            for(Integer i = listTopPerformance3a.size() - 1; i > -1; i--) {
                tempList.add(listTopPerformance3a[i]);
            }
            
            listTopPerformance3a = tempList ;
        }
    }
    
    
    
    
    
    private void initOps1aList(Account acct)
    {
      allSalesVolumeFor2a = new list<Sales_Volume__c>();
        allSalesVolumeFor1a = [select Id, Division__c, Individual_Brand__c,state_batf_volume_12_mo_ty__c, 
                                    State_Distro__c, Batf_Volume_12_Mo_TY_vs_LY_Chg__c, Size__c
                                from Sales_Volume__c
                                where state_batf_volume_12_mo_ty__c <> null and
                                Account__c = :acct.Id
                                order by state_distro__c desc
                                ] ;
        
        filterOpps1aByType();
    }
    
    public void filterOpps1aByType()
    {
        String wineOrSpirit = selected1aWineSpirit ;
        listOps1a = new List<Sales_Volume__c>();
        Integer recordCount = 0;
        if(allSalesVolumeFor1a != null && !allSalesVolumeFor1a.isEmpty())
        {
            for(Sales_Volume__c salesVolRecord : allSalesVolumeFor1a) {
                
                if(salesVolRecord.Division__c == wineOrSpirit && recordCount <= 10) {
                    listOps1a.add(salesVolRecord);
                    recordCount++;
                }
            }
        }
    }
    //Changes done by Jai gupta for case 00037225 on Dec 17,2012
    public PageReference executeChartBrandChange()
    {
      ApexPages.currentPage().getParameters().put('selected1aWineSpirit',selected1aWineSpirit);
      initOps1aList(accountRecord);
       /* String urlString = '/apex/AccountPageLayout?id=' + accountRecord.Id ; 
        urlString += '#href1a' ;
        PageReference newPage = new PageReference(urlString);
        newPage.getParameters().put('chart2aSelectedBrand', chart2aSelectedBrand);
        return newPage ; //to avoid special character html encoding*/
        return null ;
    } 
    
    public PageReference executeChartBrandChange2()
    {
      system.debug('=========chart2aSelectedBrand====2======='+chart2aSelectedBrand);
      //init(accountRecord, selected1aWineSpirit, chart2aSelectedBrand, chart3aSelectedDiv);
        ApexPages.currentPage().getParameters().put('chart2aSelectedBrand', chart2aSelectedBrand);
        init2aData(accountRecord);
        return null;
    }
    // End for case 00037225
    public PageReference executeChartBrandChange3()
    {
        ApexPages.currentPage().getParameters().put('chart3aSelectedDiv', chart3aSelectedDiv);
        init3aPerformance(accountRecord);
        return null;
    }
    
    global class DataFor3a implements Comparable
    {
        public String Brcat_Fin_Plan_Brand { get; set; }
        public String Individual_Brand { get; set; }
        public String Generic_Brand { get; set; }
        
        public Integer State_12M_Chg_vs_YA { get; set; }
        public Integer Batf_Volume_12_Mo_TY_vs_LY_Chg { get; set; }
        
        public Integer diffBetweenStateAndAcct{
            get {
                if(this.Batf_Volume_12_Mo_TY_vs_LY_Chg != null && this.State_12M_Chg_vs_YA != null)
                    return this.Batf_Volume_12_Mo_TY_vs_LY_Chg - this.State_12M_Chg_vs_YA  ;
                
                return 0;
            }
        }
        
        public DataFor3a(Sales_Volume__c salesVolumeObj) 
        {
            this.Brcat_Fin_Plan_Brand = salesVolumeObj.Brcat_Fin_Plan_Brand__c;
            this.Individual_Brand = salesVolumeObj.Individual_Brand__c;
            this.Generic_Brand = salesVolumeObj.Generic_Brand__c;
            
            this.State_12M_Chg_vs_YA = Integer.valueOf(salesVolumeObj.State_12M_Chg_vs_YA__c);
            this.Batf_Volume_12_Mo_TY_vs_LY_Chg = Integer.valueOf(salesVolumeObj.Batf_Volume_12_Mo_TY_vs_LY_Chg__c);
        }
        
        global Integer compareTo(Object compareTo) {
            DataFor3a compareToDataObj = (DataFor3a)compareTo;
            
            if (diffBetweenStateAndAcct == compareToDataObj.diffBetweenStateAndAcct) 
                return 0;
            if (diffBetweenStateAndAcct > compareToDataObj.diffBetweenStateAndAcct) 
                return 1;
            
            return -1;        
        }
    }
    
    

}