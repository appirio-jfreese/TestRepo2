/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        07/03/2012
 * @description Controller to generate a "ordering sheet" which is a dump of the programs, brands, and items 
 *				associated with a given ordering window
 **/
public without sharing class POS_GenerateOrderingSheetController {
	
    public List<Program__c> orderwindowData{get; set;}
    public Order_Window__c orderWindow{get; set;}
    public List<Order_Window__c> orderWindowTotal{get; set;}
    public List<UserAddressWrapper> userAddresses{get; set;}
    
    public POS_GenerateOrderingSheetController() {
    	String owId = ApexPages.currentPage().getParameters().get('owId');
    	String magentoId = ApexPages.currentPage().getParameters().get('owMagentoId');
    	
    	if (owId!=null) {
    		orderWindow = [SELECT Name, Status__c, Order_Start_Date__c, Order_Close_Date__c  from Order_Window__c where id=:owId];
    	}
    	else { 
    		orderWindow = [SELECT Name, Status__c, Order_Start_Date__c, Order_Close_Date__c  from Order_Window__c where Magento_Id__c=:magentoId limit 1];
    		owId=orderWindow.Id;
    	}
    	
    	System.debug('ORDER WINDOW: '+orderWindow);
    	orderWindowTotal = new List<Order_Window__c>();
    	orderWindowTotal.add(orderWindow);
    	
		orderwindowData = [SELECT Order_Window__r.Name, Brand__r.name, Program_ID__c,Id,Name, 
							(select id, Name, Packout_Quantity__c, Estimated_Price__c, Estimated_Shipping_Tax__c, Current_Price__c from Items__r 
							where Status__c not in ('Development', 'Cancelled', 'Removed') and RecordType.DeveloperName!='Roll_Up' and Kit_Only__c!=true order by Name) 
							FROM Program__c where Order_Window__r.Id= :owId order by Brand__r.name, Name];
							
		for(Integer i=0; orderwindowData!=null && i<orderwindowData.size(); i++) {
			Program__c prg = orderwindowData.get(i);
			if(prg.Items__r.isEmpty()) {
				orderwindowData.remove(i);
				i--;
			}
		}					
							
		List<User_Ship_To__c> userShipTos = [Select u.Id, u.User__c, u.Magento_Ship_To_ID__c, u.Ship_To__r.Name, u.Ship_To__r.Account__r.Name, u.Ship_To__r.Street__c, u.Ship_To__r.City__c, 
						u.Ship_To__r.State__c, u.Ship_To__r.Zip__c, u.Ship_To__r.Phone__c, u.Ship_To__r.Attention__c 
						From User_Ship_To__c u where u.User__c=:UserInfo.getUserId() and u.Ship_to__r.Removed__c=false];
		
		System.debug('Order window data: '+orderWindowData);
		System.debug('userShipTos - ' + userShipTos);
		if(userShipTos!=null) {
			userAddresses = new List<UserAddressWrapper>();
			
			Integer addrCt = 0;
			for(User_Ship_To__c u : userShipTos) {
				UserAddressWrapper ua = new UserAddressWrapper(u);
				ua.setColumnPositions(addrCt); // sets the Columns Name to be referred in the VF
				userAddresses.add(ua);
				
				addrCt++;
			}
		}
		System.debug('Wrappers: '+userAddresses);
		//System.debug('userShipTos 1 - ' + userShipTos[0].Ship_To__r.State__c + ' userShipTos 2 - ' + userShipTos[1].Ship_To__r.State__c	);				
    }
    
	public class UserAddressWrapper {
	 
	    public String itemQtyColumn { get; set; }
	    public String itemTotalColumn { get; set; }
	    public String itemTotalSnHColumn { get; set; }
	    public User_Ship_To__c usrShipTo { get; set;}

	    public UserAddressWrapper(User_Ship_To__c u){
	        usrShipTo = u;
	    }
	    
	    public void setColumnPositions(Integer addrCt) {
	    	Integer itemQtyColumnPosition =  colStartPosition + noOfItemCols*addrCt;
	    	itemQtyColumn = excelColumns[itemQtyColumnPosition];
	    	itemTotalColumn = excelColumns[itemQtyColumnPosition+2];
	    	itemTotalSnHColumn = excelColumns[itemQtyColumnPosition+3];
	    }
	 
	}     
    
    public static String[] excelColumns = new String[]{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R',
    								'S','T','U','V','W','X','Y','Z',
    								'AA','AB','AC','AD','AE','AF','AG','AH','AI','AJ','AK',
    								'AL','AM','AN','AO','AP','AQ','AR','AS','AT','AU','AV','AW','AX','AY','AZ', 
    								'BA','BB','BC','BD','BE','BF','BG','BH','BI','BJ','BK',
    								'BL','BM','BN','BO','BP','BQ','BR','BS','BT','BU','BV','BW','BX','BY','BZ',
    								'CA','CB','CC','CD','CE','CF','CG','CH','CI','CJ','CK',
    								'CL','CM','CN','CO','CP','CQ','CR','CS','CT','CU','CV','CW','CX','CY','CZ',
    								'DA','DB','DC','DD','DE','DF','DG','DH','DI','DJ','DK',
    								'DL','DM','DN','DO','DP','DQ','DR','DS','DT','DU','DV','DW','DX','DY','DZ',
    								'EA','EB','EC','ED','EE','EF','EG','EH','EI','EJ','EK',
    								'EL','EM','EN','EO','EP','EQ','ER','ES','ET','EU','EV','EW','EX','EY','EZ',
    								'FA','FB','FC','FD','FE','FF','FG','FH','FI','FJ','FK',
    								'FL','FM','FN','FO','FP','FQ','FR','FS','FT','FU','FV','FW','FX','FY','FZ',
    								'GA','GB','GC','GD','GE','GF','GG','GH','GI','GJ','GK',
    								'GL','GM','GN','GO','GP','GQ','GR','GS','GT','GU','GV','GW','GX','GY','GZ',
    								'HA','HB','HC','HD','HE','HF','HG','HH','HI','HJ','HK',
    								'HL','HM','HN','HO','HP','HQ','HR','HS','HT','HU','HV','HW','HX','HY','HZ',
    								'IA','IB','IC','ID','IE','IF','IG','IH','II','IJ','IK',
    								'IL','IM','IN','IO','IP','IQ','IR','IS','IT','IU','IV','IW','IX','IY','IZ',
    								'JA','JB','JC','JD','JE','JF','JG','JH','JI','JJ','JK',
    								'JL','JM','JN','JO','JP','JQ','JR','JS','JT','JU','JV','JW','JX','JY','JZ',
    								'KA','KB','KC','KD','KE','KF','KG','KH','KI','KJ','KK',
    								'KL','KM','KN','KO','KP','KQ','KR','KS','KT','KU','KV','KW','KX','KY','KZ',
    								'LA','LB','LC','LD','LE','LF','LG','LH','LI','LJ','LK',
    								'LL','LM','LN','LO','LP','LQ','LR','LS','LT','LU','LV','LW','LX','LY','LZ',
    								'MA','MB','MC','MD','ME','MF','MG','MH','MI','MJ','MK',
    								'ML','MM','MN','MO','MP','MQ','MR','MS','MT','MU','MV','MW','MX','MY','MZ',
    								'NA','NB','NC','ND','NE','NF','NG','NH','NI','NJ','NK',
    								'NL','NM','NN','NO','NP','NQ','NR','NS','NT','NU','NV','NW','NX','NY','NZ'   								    								    								    								    								
    								};
    public static Integer itemPricePosition = 5;  
    public static Integer colStartPosition = 7;
    public static Integer noOfItemCols = 4;  								
    								
    public String getItemPriceColumn() {
    	return excelColumns[itemPricePosition];
    }
    
    public String getItemSnHColumn() {
    	return excelColumns[itemPricePosition+1];
    }  
    
    public String getFirstQtyColumn() {
    	return excelColumns[itemPricePosition+2];
    }    

    public String getTotalAcrossColumn() {
    	return excelColumns[itemPricePosition+1 + (noOfItemCols*userAddresses.size()) + 1];
    }

    public String getTotalAcrossSnHColumn() {
    	return excelColumns[itemPricePosition+1 + (noOfItemCols*userAddresses.size()) + 2];
    }
            
    public Integer getColStartPosition() {
    	return colStartPosition;
    }
    
    public Integer getNoOfItemCols() {
    	return noOfItemCols;
    }
    
    @isTest(SeeAllData=true)
	public static void testGenerateOrderingSheet () {
		
		Profile p = [select id from profile where name='POS - CM Administrator'];
         
		User u = new User(alias = 'posmmtst', email='posmmunittest@diageo.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
		localesidkey='en_US', profileid = p.Id,
		timezonesidkey='America/Chicago', username='posmmunittest@diageo.com');
		
		System.runAs(u) {
			//Create some test data
			Account account = new Account();
			account.Name='POS Unit Test Account';
			insert account;
			
			Account_Member__c am = new Account_Member__c();
			am.Account__c = account.Id;
			am.User__c = u.Id;
			insert am;
			
			Ship_To__c shipTo = new Ship_To__c();
			shipTo.Account__c = account.Id;
			shipTo.Name='Test Ship To';
			insert shipTo;  
			
			User_Ship_To__c userShipTo = new User_Ship_To__c(Ship_To__c=shipTo.Id, User__c=u.Id);
			insert userShipTo;			 
			
		    Account agency = POS_TestDataUtil.createProductionAgency();
		   
		    Program__c program = POS_TestDataUtil.createProgram();
		    Item__c item = POS_TestDataUtil.populateItem(program, agency);
		    insert item;
		   
		    String owId = program.Order_Window__c;
			Test.setCurrentPageReference(new PageReference('Page.POS_GenerateOrderingSheet'));
			System.currentPagereference().getParameters().put('owId',owId);		    
		    
		    POS_GenerateOrderingSheetController ctrl = new POS_GenerateOrderingSheetController();	
		    
		    System.assertEquals(4, ctrl.getNoOfItemCols());
		    System.assertEquals(7, ctrl.getColStartPosition());
		    System.assertEquals('F', ctrl.getItemPriceColumn());
		    System.assertEquals('G', ctrl.getItemSnHColumn());
		    
		}
	} 
    
}