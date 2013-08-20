public without sharing virtual class POS_ReportRenderer {
    protected Set<String>   orderWindows    {get; private set;}
    protected Set<String>   orderWindowsNo  {get { return orderWindows; }}
    protected String        classification  {get; private set;}
    protected Set<String>   brands          {get; private set;}
    protected Set<String>   orgUnits        {get; private set;}
    protected Set<String>   distributors    {get; private set;}
    protected Set<String>   shoppers    {get; private set;}
    
    protected String query {get; private set;}
    protected virtual String getQuerySelect() {return '';}
    protected String queryWhere { get {
            String queryWhereAdd = getQueryWhereAdd();
            String queryWhereFilter = getQueryWhereFilter();
            if(queryWhereFilter!=''){
                return (queryWhereAdd != null && queryWhereAdd != '')
                        ?
                        'where ('+queryWhereFilter+') and ('+queryWhereAdd+')'
                        :
                        'where '+queryWhereFilter;
            } else {
                return (queryWhereAdd != null && queryWhereAdd != '') ? 'where '+queryWhereAdd : '';
            }
        }
    }
    protected virtual String getQueryWhereFilter() {return initQueryFilters();}
    protected virtual String getQueryWhereAdd() {return '';}
    protected virtual String getQueryGroup() {return '';}
    protected virtual String getQueryOrder() {return '';}
    
    protected virtual String getOrderWindowWhereName() {return '';}
    protected virtual String getClassificationWhereName() {return '';}
    protected virtual String getBrandsWhereName() {return '';}
    protected virtual String getOrgUnits1WhereName() {return '';}
    protected virtual String getOrgUnits2WhereName() {return '';}
    protected virtual String getOrgUnits3WhereName() {return '';}
    protected virtual String getOrgUnits4WhereName() {return '';}
    protected virtual String getDistributorsWhereName() {return '';}
    protected virtual String getShoppersWhereName() {return '';}
    
    protected virtual String getBaseTableName() {return '';}
    
    protected Boolean isCsv  {get; private set;}
    
    protected POS_ReportRenderer(){
    }
    
    public PageReference initializerAction(){
        if (ApexPages.currentPage().getUrl().indexOf('CSV')>0) {
          isCsv=true;
        }
        else {
          isCsv=false;
        }        
        initFilters();
        query = getQuerySelect() + ' ' + queryWhere + ' ' + getQueryGroup() + ' ' + getQueryOrder();
        initData();

        return null;
    }
    
    private void initFilters(){
        PageReference ref = ApexPages.currentPage();
        Map<String, String> params = ref.getParameters();
        String tmpId = params.get('id');
        ReportTmpObj__c tmp = [select ow__c, cl__c, br__c, ou__c, ds__c, ss__c from ReportTmpObj__c where id = :tmpId];
        String ow = tmp.ow__c;
        String cl = tmp.cl__c;
        String br = tmp.br__c;
        String ou = tmp.ou__c;
        String ds = tmp.ds__c;
        String ss = tmp.ss__c;
        if(ow!=null)
            orderWindows = new Set<String>(ow.split(','));
        if(cl!=null)
            classification = cl;
        if(br!=null)
            brands = new Set<String>(br.split(','));
        if(ou!=null)
            orgUnits = new Set<String>(ou.split(','));
        if(ds!=null)
            distributors = new Set<String>(ds.split(','));
        if(ss!=null)
            shoppers = new Set<String>(ss.split(','));
    }
    
    private String initQueryFilters(){
        Set<String> params = new Set<String>();
        if(orderWindows != null && getOrderWindowWhereName() != ''){
            String param = '('+getOrderWindowWhereName() + ' in (';
            param += stringSetToString(orderWindows);
            param += ')';
            param += ' or '+getOrderWindowWhereName() + ' in (';
            param += stringSetToStringTrim(orderWindows);
            param += '))';            
            params.add(param);
        }
        if(classification != null && classification != '' && classification != 'All'){
            String param = getClassificationWhereName() + ' = \'';
            param += classification;
            param += '\'';
            params.add(param);
        }
        if(brands != null){
            String param = getBrandsWhereName() + ' in (';
            param += stringSetToString(brands);
            param += ')';
            params.add(param);
        }
        if(orgUnits != null){
            //this is a work around to the sfdc restriction on complex queries
            //get matching ids from the four levels of the hierarchy
            //if any were selected, filter by shopper as well to keep the result set smaller

            Map<id,sObject> ids1;
            Map<id,sObject> ids2;
            Map<id,sObject> ids3;
            Map<id,sObject> ids4;

            if(shoppers != null){
                ids1 = new Map<id,sObject>((List<sObject>)Database.query('Select id from '+getBaseTableName()+' where '+getShoppersWhereName()+' in :shoppers and '+getOrgUnits1WhereName()+' in :orgUnits'));
                ids2 = new Map<id,sObject>((List<sObject>)Database.query('Select id from '+getBaseTableName()+' where '+getShoppersWhereName()+' in :shoppers and '+getOrgUnits2WhereName()+' in :orgUnits'));
                ids3 = new Map<id,sObject>((List<sObject>)Database.query('Select id from '+getBaseTableName()+' where '+getShoppersWhereName()+' in :shoppers and '+getOrgUnits3WhereName()+' in :orgUnits'));
                ids4 = new Map<id,sObject>((List<sObject>)Database.query('Select id from '+getBaseTableName()+' where '+getShoppersWhereName()+' in :shoppers and '+getOrgUnits4WhereName()+' in :orgUnits'));
            } else {
                ids1 = new Map<id,sObject>((List<sObject>)Database.query('Select id from '+getBaseTableName()+' where '+getOrgUnits1WhereName()+' in :orgUnits'));
                ids2 = new Map<id,sObject>((List<sObject>)Database.query('Select id from '+getBaseTableName()+' where '+getOrgUnits2WhereName()+' in :orgUnits'));
                ids3 = new Map<id,sObject>((List<sObject>)Database.query('Select id from '+getBaseTableName()+' where '+getOrgUnits3WhereName()+' in :orgUnits'));
                ids4 = new Map<id,sObject>((List<sObject>)Database.query('Select id from '+getBaseTableName()+' where '+getOrgUnits4WhereName()+' in :orgUnits'));
            }
                   
            ids1.putAll(ids2);
            ids1.putAll(ids3);
            ids1.putAll(ids4);
    
            if(ids1.size()>0){
                String param = '( id in (';
                param += stringSetToString(ids1.keySet());
                param += '))';
                params.add(param);
            }
            else{
                // force zero results
                return '(id = null)';
            }
        }
        if(distributors != null){
            String param = getDistributorsWhereName() + ' in (';
            param += stringSetToString(distributors);
            param += ')';
            params.add(param);
        }
        // shoppers defined by user
        if(shoppers != null && orgUnits == null){ // #soe - 07/01/13
            String param = getShoppersWhereName() + ' in (';
            param += stringSetToString(shoppers);
            param += ')';
            params.add(param);
        }                
        String toReturn = '';
        String glue = '';
        for(String param : params){
            toReturn += glue + param;
            glue = ' and ';
        }

        return toReturn;
    }
    
    protected String stringSetToString(Set<String> strings){
        String toReturn = '';
        String glue = '';
        for(String str : strings){
            toReturn += glue + '\''+str+'\'';
            glue = ','; 
        }
        return toReturn;
    }
    protected String stringSetToString(Set<Id> strings){
        String toReturn = '';
        String glue = '';
        for(Id str : strings){
            toReturn += glue + '\''+str+'\'';
            glue = ','; 
        }
        return toReturn;
    }
    protected String stringSetToStringTrim(Set<String> strings){
        String toReturn = '';
        String glue = '';
        for(String str : strings){
            toReturn += glue + '\''+str.substring(0,15)+'\'';
            glue = ','; 
        }
        return toReturn;
    }
    
    protected virtual void initData() {}
    
    protected virtual void calculate() {}
}