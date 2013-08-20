/**
 * @author      Model Metrics {Venkatesh Kamat}
 * @date        06/22/2012
 * @description Class exposing User and User Access details as REST Outbound service.
 */

@RestResource(urlMapping='/syncmagentocart/*')
global without sharing class POS_MagentoCartRESTResource {
    
    private static String GENERIC_ERROR='There was an error Submitting your cart. Please try again or contact Diageo Direct support';
    public static boolean deleteCartItem = false ;
    private static Integer CART_LIMIT=500;
    //private static Integer CART_LIMIT=5;
    private static RestRequest req;
    private static RestResponse res;
    //added by LSLEVIN Case-3987/START-1
    private static decimal sfCartTotal=0;
    private static decimal mCartTotal=0;
    //End-1
    @HttpGet
    global static String doGet() {
        req = RestContext.request;
        res = RestContext.response;
        
        Map<String, String> pMap = req.params;
        String mCartId = pMap.get('cart_id');
        
        
        if (mCartId==null) {
            res.StatusCode = 400;
            res.addHeader('Error','required parameter "cart_id" is missing');
            
            return null;
        }
        
        return processCart(mCartId,false) ;
    }
    
    global static String batchProcessCart (String mCartId) {
        System.debug('++++++++++ mCartId ' + mCartId );
        res = new RestResponse(); //Need to fill this in since it's not a REST request
        return processCart(mCartId,true);
    }

    private static String processCart (String mCartId, boolean batchMode) {
        System.debug('mCartId ' + mCartId );
        
        String msessionId = POS_MagentoIntegrationUtil.getMagentoSessionId();
        String API_CALL = 'metrics_carts.listitems';
        String API_ARGUMENTS = '&arg2[cart_id]=' + EncodingUtil.urlEncode(mCartId+'','UTF-8'); 

        // synchronous callout to Magento
        Dom.Document resp = POS_MagentoIntegrationUtil.getMagentoCallDocument(msessionId, API_CALL, API_ARGUMENTS); 
        String status = POS_MagentoIntegrationUtil.getMagentoResponseElement(resp, 'status');
        System.debug('***** status-' + status);
           
        if(status == 'success') { 
            // logic to process cart and cartItem data
            List<CartItemWrapper> cartItems = parseResponseXML(resp);

            System.debug(Logginglevel.ERROR,'***** cartItems.size()-' + cartItems.size());
            
            if (batchMode || cartItems.size()<CART_LIMIT) {
                try {
                    // call to saveCartItems in SFDC
                    String errorMessage = validateBudget(cartItems);
                    if (errorMessage == null) {
                        System.debug('Validation of budget passed; save cart');
                        
                        saveCartItems(cartItems);

                        sendOverageNotification(cartItems);
                    }
                    else {
                        if (batchMode) {
                            //Changes done by Jai Gupta [Appirio Jaipur] for case 00005338 on May 24,2013
                            sendError(null,cartItems,errorMessage,true);
                            // End for 00005338
                            System.debug('ERROR: '+errorMessage);
                        }
                        res.StatusCode = 400;
                        res.addHeader('Error', errorMessage);
                        return 'failed';
                    }
                }   
                catch(DmlException ex) { // 
                    if (batchMode) {

                        throw ex;
                    }
                    if(ex.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                        res.StatusCode = 400;
                        System.debug('Handling FIELD_CUSTOM_VALIDATION_EXCEPTION - ' + ex.getNumDml());
                       
                        String errorMessage = '';
                        for(Integer i=0; i<ex.getNumDml(); i++) {
                            errorMessage = errorMessage + '<br>' + ex.getDmlMessage(i);
                        }

                        res.addHeader('Error', errorMessage );
                        return 'failed';
                    }   
                    else {
                        res.StatusCode = 400;
                        res.addHeader('Error',GENERIC_ERROR);
                        //Changes done by Jai Gupta [Appirio Jaipur] for case 00005338 on May 24,2013
                        sendError(ex,cartItems,null,false);
                        // end 00005338
                        return 'failed';
                    }      
                } catch (Exception ex) {
                    System.debug('Handling uncaught exception===='+batchMode);
                    if (batchMode) {
                        
                        throw ex;
                    }
                    res.StatusCode = 400;
                    res.addHeader('Error',GENERIC_ERROR);
                    //Changes done by Jai Gupta [Appirio Jaipur] for case 00005338 on May 24,2013
                    sendError(ex,cartItems,null,false);
                    // end 00005338
                    return 'failed';
                }
    /*  //3.21.2013-LSLEVIN-Case3987//Start-2
             //SFDC Cart
             Cart__c sfCart = [SELECT Id,Magento_ID__c, Name from Cart__c WHERE Magento_ID__c =: mCartId ];
             //Magento Cart
             Cart__c mCart = [SELECT ID, Magento_ID__c, Name from Cart__c WHERE Magento_ID__c =: cartItems.get(0).magentoCartId];
             //SFDC Cart
             list<Cart_Item__c> sfCartItems = [SELECT Account_Name__c,Cart__c,Id,Item__r.Current_Price__c, Item__r.Estimated_Shipping_Tax__c,Name,Quantity__c FROM Cart_Item__c WHERE Cart__c =: sfCart.Id];
             //Magento Cart
             list<Cart_Item__c> mCartItems = [SELECT Account_Name__c,Cart__c,Id,Item__r.Current_Price__c, Item__r.Estimated_Shipping_Tax__c,Name,Quantity__c FROM Cart_Item__c WHERE Cart__c =: mCart.Id];
             //Calculate Cart for SFDC
             for(Cart_Item__c sItems : sfCartItems){
                decimal taxRate = sItems.Item__r.Estimated_Shipping_Tax__c.Divide(100,2);
                decimal taxShipping =  taxRate * sItems.Item__r.Current_Price__c;
                decimal indTotal = taxShipping + sItems.Item__r.Current_Price__c;
                decimal cTotal = indTotal * sItems.Quantity__c;
                
                sfCartTotal += cTotal;
                sfCartTotal = sfCartTotal.setScale(2,RoundingMode.Half_UP);
             }
             //Calculate Cart for Magento
             for(Cart_Item__c mItems : mCartItems){
                decimal taxRate = mItems.Item__r.Estimated_Shipping_Tax__c.Divide(100,2);
                decimal taxShipping =  taxRate * mItems.Item__r.Current_Price__c;
                decimal indTotal = taxShipping + mItems.Item__r.Current_Price__c;
                decimal cTotal = indTotal * mItems.Quantity__c;
                
                mCartTotal += cTotal;
                mCartTotal = mCartTotal.setScale(2,RoundingMode.Half_UP);
             }
             //Success Message sent to sync.log
                res.StatusCode = 200;
                res.addHeader('Success',' [CLIENT INFO]: Magento Cart Submission Start: {Magento Cart Id: ' + mCartId + '} {Magento Cart Quantity: ' + cartItems.size()  + '} {Magento Cart Total: $'+ mCartTotal
                + '} [SERVICE INFO] Success: {SFDC Cart Id: ' + sfCart.Name + '} {SFDC Cart Quantity: ' + sfCartItems.size() + '} {SFDC Cart Total: $' + sfCartTotal+'}' +
                ' [CLIENT INFO]: '+ ' Magento Cart Submission End:    [CLIENT INFO]: Success');
        //Case3987End-2   */ 
            }
            else {
                //Cart too big, so need to process offline
                POS_PullMagentoCartsBatch batch = new POS_PullMagentoCartsBatch(mCartId);
                // Changes done by Jai Gupta [Appirio Jaipur] for case 00005338 on May 23,2013
                batch.errorCartItems.addAll(cartItems);
                // End for case 00005338
                Database.executeBatch(batch);
                res.StatusCode = 400;
                res.addHeader('Notice', 'Due to large cart size it will take time to process this request. You will recieve an email when it is complete.');
                return'failed';
                 
            }
        } 
        else {
            res.StatusCode = 400;
            res.addHeader('Error',GENERIC_ERROR);
        }

        return status;
    }
    
    class CartProcessingException extends Exception {
    
    }
    // Changed signature of the function to include more information in the email
    // Changes done by Jai Gupta [Appirio Jaipur] for case 00005338 on May 24,2013
    public static void sendError(Exception e , List<CartItemWrapper> cartItems , String errorMessage, boolean batchMode) {
        try {
            // Changes done by Jai Gupta [Appirio Jaipur] for case 00005338
            List<String> toAddresses = new list<String>{'pos-order-confirmation@diageo.com'};
            // End for case 00005338
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Changes done by Jai Gupta [Appirio Jaipur] for case 00005338
            //Commented out below line
            //mail.setToAddresses(new list<String>{'pos-order-confirmation@diageo.com'});
            // End for case 00005338
            //mail.setToAddresses(new list<String>{'sstearns@modelmetrics.com'});
            
            mail.setReplyTo('pos-order-confirmation@diageo.com');
            mail.setSubject('Diageo POS: Error Processing Cart');
            mail.setSenderDisplayName('Diageo POS Processing');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            // Changes done by Jai Gupta [Appirio Jaipur] for case 00005338 on May 24,2013
            String body = 'There was an error received when processing your Cart:\n\n';
            if(errorMessage != null) {
                body = 'The Cart you submitted failed to be successfully processed due to:\n';
                body += errorMessage +'\n\n';
            }
            // End for case 00005338
            String server = System.URL.getSalesforceBaseURL().getHost();
            
            if (server.indexOf('na7.salesforce.com')>-1) {
                // Changes done by Jai Gupta [Appirio Jaipur] for case 00005338 on June 05,13
               // body=body+'This error was experienced in the live PRODUCTION environment\n';
            }
            else {
                body=body+'This error was received in the SANDBOX environment and is a result of testing/development there.  Please forward '+
                    'this message to the development/qa team';
            }
            //body=body+'\n';
            //body=body+'Error occurred on server: '+server;
            // End for case 00005338
            if(e != null){
                body=body+'\n\nError was: '+e.getMessage();
                body=body+'\nTrace was: \n';
                body=body+e.getStackTraceString();
                body=body+'\n';
            }
            // For case 00003703 by Jai Gupta on 17 Jan , 2013
            body=body+'\nCart contained '+cartItems.size()+' item(s)\n';
            // Changes done by Jai Gupta [Appirio Jaipur] for case 00005338 on May 24,2013
            if(req != null) {
                body=body+'\nRequest XML is : \n'+req+'\n';
            }
            if(res.responseBody != null) {
                body=body+'\nResponse XML is : \n'+res+'\n';    
            }
            // End for case 00005338
            //body = body+' User name : '+Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
            if (cartItems!=null && cartItems.size()>0) {
                //body=body+'  Cart contained '+cartItems.size()+' items\n';
                String magentoCartId = cartItems.get(0).magentoCartId;
                if(magentoCartId != null){
                    Order_Window__c orderWindow = [Select Id, Order_Window__r.Id, Order_Window__r.Name from Order_Window_Customer__c where Magento_Id__c =:magentoCartId limit 1].Order_Window__r;
                    if(orderWindow != null){
                        body=body+'\nOrder window name is : '+ orderWindow.Name+'\n';
                        body=body+'Order window Id is : '+orderWindow.Id+'\n\n';
                    }
                }
                // End for case 00003703
                // Changes done by Jai Gupta [Appirio Jaipur] for case 00005338 // Querying email and storing in a variable to send email
                String userId = cartItems.get(0).magentoCustomerId;
                if (userId!=null) {
                    User user = [select Id, Name,Email from User where Magento_Id__c=:userId];
                    if (user!=null) {
                        body=body+'Cart submission for user: '+user.Name+'\n\n';
                        toAddresses.add(user.Email);
                    }
                }
            }
            // Changes done by Jai Gupta [Appirio Jaipur] for case 00005338
            mail.setToAddresses(toAddresses);
            // End for case 00005338
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
        catch (Exception ex) {
            System.debug('FAILURE TO SEND EMAIL: '+ex.getMessage());
        }
    }
        
    /*
    This method validates the budget.  If the user is blocked from submission (distributor with no budget) this
    method will return false.  Otherwise it returns true.
    */
    private static String validateBudget (List<CartItemWrapper> cartItems) {

        //Make sure there are items in the cart.  If not, no need to worry about going over budget
        if (cartItems.size()==0) {
            System.debug('No items in cart: budget is valid');
            return null;
        }
        
        String bErrorMsg = '';
        String iErrorMsg = '';
        
        //Get user based on item ownership
        String magentoCustomerId = cartItems.get(0).magentoCustomerId;
        User user = [select Id, Name, Profile.Name from User where Magento_Id__c = :magentoCustomerId];
          
        if (user.Profile.Name.startsWith('Distributor')) {
            System.debug('Distributor user, check for budgets to exists');        
            
            //Get order window
            String magentoCartId = cartItems.get(0).magentoCartId;
            Order_Window__c orderWindow = [Select Id, Order_Window__r.Id, Order_Window__r.Name from Order_Window_Customer__c where Magento_Id__c =:magentoCartId limit 1].Order_Window__r;
            
            Map<Id,List<Budget__c>> itemBudgetMap = new Map<Id,List<Budget__c>>(); //ID is Item
            //get assigned budgets
            List<Budget__c> budgets = [Select b.Order_Window__c, b.Id, b.Shopper__c, b.CreatedById, b.CreatedBy.Name, b.CreatedBy.Email, 
              b.Brand__c, b.Brand__r.Name, b.Amount__c, b.Parent__c, b.Budgeter__r.Name, b.Order_Window__r.Name, b.Item__c, b.Unallocated_Item_Quantity__c
               From Budget__c b where b.Shopper__c = :user.Id and b.Order_Window__c = :orderWindow.Id];            
            
            // check to see there is Budget at either Individual Brand or Parent Brand for every Cart Item in the cart.
            // Reject the whole cart even if one of the Cart Item has no budget. 
            Set<Id> itemIds = new Set<Id>();
            for(CartItemWrapper ciw : cartItems) {
                if(ciw.citm.Quantity__c!=null && ciw.citm.Quantity__c!=0) { // Zero Qty item will not be passed by API anymore, check was initally there to allow shopper to clearout qty if the brand budget now has been removed for them.
                    itemIds.add(ciw.citm.Item__c);
                }
            } 
            System.debug('itemIds - ' + itemIds);
            
            Set<Id> budgettedBrands = new Set<Id>();
            for(Budget__c budget : budgets) {
                if (budget.Item__c != null) {
                    //budget.My_Spent_Item_Quantity__c=0;
                    List<Budget__c> budgetsForItem = itemBudgetMap.get(budget.Item__c);
                    if (budgetsForItem == null) {
                        budgetsForItem = new List<Budget__c>();
                        itemBudgetMap.put(budget.Item__c,budgetsForItem);
                    }
                    budgetsForItem.add(budget);                 
                    
                } else { // budgetting by Brand             
                    budgettedBrands.add(budget.Brand__c);
                }
            } 
            System.debug('budgettedBrands - ' + budgettedBrands);
            
            //1:Brand budhget check: get the Primary Brand and it's Parent Brand for every Item in the Cart that is budgetted by Brand
            List<Item_Brand__c> primaryBrandWithParent = [select Brand__c, Brand__r.Name, Brand__r.Parent_Brand__c, Brand__r.Parent_Brand__r.Name from Item_Brand__c where Primary__c=true and Item__c in :itemIds and Item__r.On_Allocation__c != true];
            Set<String> brandsWithoutBudget = new Set<String>();
            
            for(Item_Brand__c brd : primaryBrandWithParent)   { // check if every brand is budgetted for
                System.debug('Brand__r.Name - ' + brd.Brand__r.Name + ' Brand__r.Parent_Brand__r.Name - ' + brd.Brand__r.Parent_Brand__r.Name);
                if(!budgettedBrands.contains(brd.Brand__c) && !budgettedBrands.contains(brd.Brand__r.Parent_Brand__c)) {
                    
                    System.debug('One or more Cart Items do not have Budget at Brand or parent Brand level of - ' + brd.Brand__r.Name);
                    if(!brandsWithoutBudget.contains(brd.Brand__r.Name)) {
                        brandsWithoutBudget.add(brd.Brand__r.Name);
                    }
                }
            } 
            
            if(brandsWithoutBudget.size() > 0) {
                
                for(String bWithoutB : brandsWithoutBudget) {
                    bErrorMsg = bErrorMsg + ', ' + bWithoutB.replace('"', '&quot;'); 
                }
                bErrorMsg = 'You must have a budget assigned for every brand you are trying to shop. Please contact your marketing director to receive a budget for:'
                                        + bErrorMsg.replaceFirst(', ', ' ') + '.';
                
                System.debug('bErrorMsg - ' + bErrorMsg);
            }   
            
            //2:Item budget check: check if there are any Limited Qty Items in the cart and make sure they are budgetted for and ALSO not over budgetted Qty(No overrage allowed here, this is a Hard Stop).
            Map<Id, Item__c> itemsOnAllocation = new Map<Id, Item__c>([select Id, Name from Item__c where Id in :itemIds and On_Allocation__c = true]);
            if(itemsOnAllocation != null && itemsOnAllocation.size() > 0) {
                // make a list of all Cart Items that are onAllocation
                List<CartItemWrapper> onAllocationCartItems = new List<CartItemWrapper>();
                for(CartItemWrapper ciw : cartItems) {
                    if(itemsOnAllocation.get(ciw.citm.Item__c)!=null) { 
                        onAllocationCartItems.add(ciw);
                    }
                }
            
                Map<Id, Decimal> limitedItemQtyMap = new Map<Id, Decimal>(); //ID is Item, stores #of LimitedQtyItem that's in the cart
                for(CartItemWrapper ciw : onAllocationCartItems) {
                    // create limitedItemQtyMap on the first pass through CartItems, validation and allocation will be done in seperate loop below
                    if(ciw.citm.Quantity__c > 0) {
                        Decimal qtySoFar = (limitedItemQtyMap.get(ciw.citm.Item__c) == null)? 0 : limitedItemQtyMap.get(ciw.citm.Item__c);
                        limitedItemQtyMap.put(ciw.citm.Item__c, qtySoFar+ciw.citm.Quantity__c);
                    }               
                }
                
                String noBudgetErrorStr = '<br>Your cart contains the following Limited Quantity Item(s) for which you do not have a budget assigned - ';
                String notEnoughBudgetErrorString = '';
                Boolean hasNoBudgetError = false;
                Boolean hasNotEnoughError = false;
                for (Id itemId:limitedItemQtyMap.keySet()) {
                    Item__c item = itemsOnAllocation.get(itemId);
    
                    // logic to check if there is enough budget for  Limited Qty Items
                    List<Budget__c> budgetsForItem = itemBudgetMap.get(itemId);
                    if (budgetsForItem==null) { // No budget corresponding to this Limited Qty Items exists for this Shopper
                        noBudgetErrorStr = noBudgetErrorStr + item.Name.replace('"', '&quot;') + ', ';
                        hasNoBudgetError = true;
                        continue;
                    } 
                    Decimal totalAvailableBudget=0; //Determine total Qty budget available for Item on Allocation
                    for (Budget__c budget:budgetsForItem) {
                        totalAvailableBudget = totalAvailableBudget+budget.Unallocated_Item_Quantity__c;
                    }
                        
                    System.debug('CartRest1:totalAvailableBudget - ' + totalAvailableBudget + ' CartRest2:limitedItemQtyMap.get(itemId) - ' + limitedItemQtyMap.get(itemId));   
                    // Hard-stop if the totalAvailableBudget (item budget) is less than the cartItem.Quantity__c
                    if(limitedItemQtyMap.get(itemId) > totalAvailableBudget) {
                        
                        notEnoughBudgetErrorString = notEnoughBudgetErrorString + '<br>Quantity chosen for Limited Quantity Item &quot;' + item.Name.replace('"', '&quot;') + '&quot; is more than assigned budget of '+totalAvailableBudget +'.';
                        hasNotEnoughError = true;
                    }   
                }  
                
                if(hasNoBudgetError || hasNotEnoughError)   {
                    if(hasNoBudgetError) {
                        iErrorMsg = iErrorMsg + noBudgetErrorStr.removeEnd(', ') + '.';
                    }
                    if(hasNotEnoughError) {
                        iErrorMsg = iErrorMsg + notEnoughBudgetErrorString;
                    }
                    
                    System.debug('CartRest:bErrorMsg -' + iErrorMsg);
                } 
            }    
        }
        
        if(bErrorMsg+iErrorMsg != '') {
            return bErrorMsg+iErrorMsg;
        } else {
            return null;
        }
    } 
    
    /*
    This method sends the relevant notification to users responsible for the budgets directly touched by this Cart Submission.
    */
    private static void sendOverageNotification (List<CartItemWrapper> cartItems) {
        system.debug(':::----cartItems----::'+cartItems);
        POS_Magento_Configuration__c settings = POS_Magento_Configuration__c.getOrgDefaults();
        Decimal overagePercentage;
        Decimal overageAmount;
        
        if (Test.isRunningTest()) {
            overagePercentage = 1+(1/100);
            overageAmount = 500;
        }
        else {
            //Check for dollar amount over
            overagePercentage = settings.Budget_Overage_Percent__c/100;
            overageAmount = settings.Budget_Overage_Amount__c;
        }
        System.debug('Overage percent: '+overagePercentage + ' overageAmount: '+overageAmount); 
        // Added by Jai gupta to avoid Null pointer exception / list index out of bounds exceptions       
        if(cartItems.size() == 0 ) {
            return ;
        }
        // end
        //Get user based on item ownership
        String magentoCustomerId = cartItems.get(0).magentoCustomerId;
        User user = [select Id, Name, Profile.Name from User where Magento_Id__c = :magentoCustomerId];
        
        //Get order window
        String magentoCartId = cartItems.get(0).magentoCartId;
        Order_Window__c orderWindow = [Select Id, Order_Window__r.Id, Order_Window__r.Name from Order_Window_Customer__c where Magento_Id__c =:magentoCartId limit 1].Order_Window__r;
        
        //get assigned budgets
        List<Budget__c> owBudgetsWithOverage = [Select b.Id, b.Order_Window__c, b.Order_Window__r.Name, b.Shopper__c, 
                    b.CreatedById, b.CreatedBy.Name, b.CreatedBy.Email, b.Brand__c, b.Brand__r.Name, b.Amount__c, 
                    b.Parent__c, b.Budgeter__r.Name, b.Spent_Amount__c, b.My_Spent_Amount__c, b.Remaining_Amount__c
                    From Budget__c b 
                    where b.Shopper__c = :user.Id and b.Order_Window__c = :orderWindow.Id and b.Remaining_Amount__c != null and b.Remaining_Amount__c < 0];    
        
        Map<Id,List<BudgetOverage>> notificationMap = new Map<Id,List<BudgetOverage>>(); // Id is the budget CreatedBy Id
        Map<Id,User> budgeterMap = new Map<Id,User>();
        for(Budget__c bdg : owBudgetsWithOverage) {
            //Check for percentage over
            BudgetOverage overage=new BudgetOverage();
            overage.brandName=bdg.Brand__r.Name;
            budgeterMap.put(bdg.CreatedById, bdg.CreatedBy);

            //figure out which is greater, percent or dollar, then go from there
            Decimal overageMaxAllowed = overageAmount;
            if (bdg.Amount__c*overagePercentage>overageAmount) {
                overageMaxAllowed = bdg.Amount__c*overagePercentage;
            }
            
            // check if there is overage that more than the overageMaxAllowed
            decimal budgetOverage = 0;
            /*if(bdg.My_Spent_Overage__c != null) { // VK: My_Spent_Overage__c should not be part of Overage (11/20/2012)
                budgetOverage = bdg.My_Spent_Overage__c;
            }
            if(bdg.Remaining_Amount__c != null && bdg.Remaining_Amount__c < 0) {
                budgetOverage=Math.abs(bdg.Remaining_Amount__c);
            }*/
            budgetOverage=Math.abs(bdg.Remaining_Amount__c);
            System.debug('overageMaxAllowed: '+overageMaxAllowed + ' budgetOverage: ' + budgetOverage);
            
            if (budgetOverage > overageMaxAllowed) {
                overage.amountSpent=bdg.Spent_Amount__c + bdg.My_Spent_Amount__c;
                /*if(bdg.Remaining_Amount__c == null || bdg.Remaining_Amount__c == 0) { // Individual Budget with No parent Brand budget
                    overage.amountSpent=overage.amountSpent + bdg.My_Spent_Overage__c; // VK: My_Spent_Overage__c should not be part of Overage (11/20/2012)
                }*/
                
                if (bdg.Amount__c*overagePercentage>overageAmount) {
                    overage.amountOverPercent=Math.round((overage.amountSpent-bdg.Amount__c)/bdg.Amount__c);
                } else {
                    overage.amountOverTotal=budgetOverage;
                }
                
                //We have an overage so add it to the list maintained by Creator Id
                List<BudgetOverage> userOverages = notificationMap.get(bdg.CreatedById);
                if (userOverages==null) {
                    userOverages = new List<BudgetOverage>();
                    notificationMap.put(bdg.CreatedById, userOverages);
                }
                userOverages.add(overage);                
            }
            
        }
        
        Set<Id> notifiedUsers = notificationMap.keySet();
        System.debug('Users to be notified: '+notifiedUsers.size());
        
        User sender = [select Email, Name from User where Id = :Service_API.getUID()];
        
        List <Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for (Id notifiedUser:notifiedUsers) {
            List<BudgetOverage> overageList = notificationMap.get(notifiedUser);
            Messaging.SingleEmailMessage mail = getOverageNotificationMessage(sender, budgeterMap.get(notifiedUser), orderWindow, overageList, user);
            messages.add(mail);
        }
        
        if (messages.size()>0) {
            Messaging.sendEmail(messages);
        }
        
        //Now initiate the cascade
        if (owBudgetsWithOverage.size()>0) {
            POS_BatchNotifyOverageCascade notifyCascade = new POS_BatchNotifyOverageCascade(owBudgetsWithOverage);
            notifyCascade.executeNoBatch();
        }
    }   
    
    public static Messaging.SingleEmailMessage getOverageNotificationMessage (User sender, User notifiedUser, Order_Window__c orderWindow, List<BudgetOverage> notifiedOverages, User shopper) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new list<String>{notifiedUser.Email});
        mail.setReplyTo('pos-order-confirmation@diageo.com');
        mail.setSubject('Diageo POS: Budget Overage Notification');
        mail.setSenderDisplayName('Diageo Budget Notification');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        
        String body = 'Dear '+notifiedUser.Name+', \n'+
          '\n'+
          'The budget for the order window "'+orderWindow.Name+'" has been exceeded by '+shopper.Name+' as follows: \n\n';
        
        for (BudgetOverage overage:notifiedOverages) {
            body=body+'  * '+overage.brandName+': spent $'+POS_BatchNotifyOverageCascade.formatCurrency(overage.amountSpent)+' and is over budget by ';
            if (overage.amountOverPercent!=null) {
                body=body+(overage.amountOverPercent.format())+'%';
            }
            else {
                body=body+'$'+POS_BatchNotifyOverageCascade.formatCurrency(overage.amountOverTotal); 
            }
            body=body+'\n';
        }
        
        body=body+'\n';
        //body=body+'For more details please go to: https://'++'/apex/POS_BudgetingGrid?owId='+orderWindow.Id;
        mail.setPlainTextBody(body);
        
        return mail;
    }
    
    public class BudgetOverage  {
        public String brandName;
        public Decimal amountSpent;
        public Decimal amountOverPercent;
        public Decimal amountOverTotal;
    }
    
    /* Wrapper class to hold MagentoIds of all the related objects of an Cart_Item*/
    public class CartItemWrapper {
        public Cart_Item__c citm {get;set;}
        public String magentoShipToId {get;set;}
        public String magentoCustomerId {get;set;}
        public String magentoCartId {get;set;}
        public String magentoOWId {get;set;}
        public String magentoOptionId {get;set;}
        public String magentoOptionValue {get;set;}
        //Adding sfdcShipToId for Case 00003923 - Diana - 2/22/2013
        public String sfdcShipToId {get;set;}
        //End case 00003923
                
        CartItemWrapper() {
            citm = new Cart_Item__c();
        }

    }    
    
    
    private static List<CartItemWrapper> parseResponseXML(Dom.Document doc) {
    
        System.debug('doc.toXmlString() - ' + doc.toXmlString());
        List<CartItemWrapper> cartItems = new List<CartItemWrapper>();
        Dom.XMLNode root = doc.getRootElement();
        Dom.XMLNode call = root.getChildElements()[0];
        Dom.XMLNode cartItemsNode = call.getChildElements()[0];
        
        System.debug('cartItemsNode.getChildElements().size() - ' + cartItemsNode.getChildElements().size());
        for(Dom.XMLNode keyNode : cartItemsNode.getChildElements()) {
            // this will be the key element, create a CartItem object corresponding to this node
            CartItemWrapper citmW = new CartItemWrapper();
            
            //Dom.XMLNode product_idNode = keyNode.getChildElement('product_id', null); // not needed as SFDC Id is used as sku
            Dom.XMLNode skuNode = keyNode.getChildElement('sku', null); 
            if(skuNode != null) {
            citmW.citm.Item__c = skuNode.getText().trim();
            }
            Dom.XMLNode qtyNode = keyNode.getChildElement('qty', null); 
            if(qtyNode != null) {
                citmW.citm.Quantity__c = decimal.valueOf(qtyNode.getText().trim());
            }
            Dom.XMLNode address_idNode = keyNode.getChildElement('address_id', null); 
            if(address_idNode != null) {
            citmW.magentoShipToId = address_idNode.getText().trim();
            }
            Dom.XMLNode customer_idNode = keyNode.getChildElement('customer_id', null); 
            if(customer_idNode != null) {
            citmW.magentoCustomerId = customer_idNode.getText();
            }
            Dom.XMLNode cart_idNode = keyNode.getChildElement('cart_id', null); 
            if(cart_idNode != null) {
            citmW.magentoCartId = cart_idNode.getText();
            }
            Dom.XMLNode ow_idNode = keyNode.getChildElement('order_window_id', null); 
            if(ow_idNode != null) {
            citmW.magentoOWId = ow_idNode.getText();
            }
            //Adding shipTo_idNode for Case 00003923 - Diana - 2/22/2013
            Dom.XMLNode shipTo_idNode = keyNode.getChildElement('shipto_id', null); 
            if(shipTo_idNode != null) {
                citmW.sfdcShipToId = shipTo_idNode.getText();
            }//End case 00003923
            
            Dom.XMLNode optionsNode = keyNode.getChildElement('options', null); 
            Dom.XMLNode firstOptionKeyNode = null;
            Dom.XMLNode option_codeNode = null;
            Dom.XMLNode option_valueNode = null;
            
            if(optionsNode != null) {
                firstOptionKeyNode = optionsNode.getChildElements()[0];
                option_codeNode = firstOptionKeyNode.getChildElement('code', null);
                option_valueNode = firstOptionKeyNode.getChildElement('value', null);
                
                if(option_codeNode.getText()!='attributes' && option_codeNode.getText()!='parent_product_id') { // skip options for Rollup variation submission
                    citmW.magentoOptionId = option_codeNode.getText().substring('option_'.length());
                    citmW.magentoOptionValue = option_valueNode.getText();
                }
            }           
            
            System.debug('citmW- ' + citmW);
            
            if(option_codeNode == null || option_codeNode.getText()!='parent_product_id') { // skip adding cartItem corresponding to Rollup parent
                cartItems.add(citmW);
            }
        }         
        
        return cartItems;

}




private static Boolean saveCartItems(List<CartItemWrapper> cartItemWrappers) {

    Boolean opSuccess = false;
    // form Cart and Cart_Item objects from the CartItemWrapper
    Cart__c cart = null;
    List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
     
    System.debug(Logginglevel.ERROR,'******** cartItemWrappers ' + cartItemWrappers); 
    if(cartItemWrappers == null) {
        return opSuccess;
    } 
    
    Map<String, Id> shopperMap = new Map<String, Id>(); // key is User magentoId, Id is User sfdcId
    Map<String, Id> cartMap = new Map<String, Id>(); // key is Cart magentoId, Id is Order_Window_Customer Id
    if(cartItemWrappers.size() > 0) { 
        cart = new Cart__c();
        CartItemWrapper cw1 = cartItemWrappers.get(0); // form the Cart Object from the first node object
        cart.Magento_ID__c = cw1.magentoCartId;
        
        cart.Shopper__c = shopperMap.get(cw1.magentoCustomerId);
        if(cart.Shopper__c == null) {
            cart.Shopper__c = [Select Id from User where Magento_Id__c =:cw1.magentoCustomerId limit 1].id;
            shopperMap.put(cw1.magentoCustomerId, cart.Shopper__c);
        }
        
        cart.Order_Window__c = cartMap.get(cw1.magentoCartId);
        if(cart.Order_Window__c == null) {
            cart.Order_Window__c = [Select Id, Order_Window__c from Order_Window_Customer__c where Magento_Id__c =:cw1.magentoCartId limit 1].Order_Window__c;
            cartMap.put(cw1.magentoCartId, cart.Order_Window__c);
        }

        
        // create Lists and Maps for magentoId to sfdcId lookups
        //List<String> shipToMagentoIds = new List<String>();
        List<String> owMagentoIds = new List<String>();
        List<String> customOptionMagentoIds = new List<String>();
        List<CartItemWrapper> itemsWithCustomOption = new List<CartItemWrapper>();
        List<Id> itemIds = new List<Id> ();
        //Map<String, User_Ship_To__c> userShipTosMap = new Map<String, User_Ship_To__c>();
        
        for(CartItemWrapper cw :cartItemWrappers) {
            
            //shipToMagentoIds.add(cw.magentoShipToId);
            owMagentoIds.add(cw.magentoOWId);
            itemIds.add(cw.citm.Item__c);
            
            if(cw.magentoOptionId != null) {
                customOptionMagentoIds.add(cw.magentoOptionId);
                itemsWithCustomOption.add(cw);
            }
        }
        
        /*
        //Commented out by Diana for Case 00003923 on 2/22/2013
        //Changes made by Jai gupta for case 00003802 on Feb 01,2013
        
        Map<String,List<user_ship_to__c>> userShipToMapTest = new Map<String,List<user_ship_to__c>>();
        for(User_Ship_To__c usrShip : [Select Ship_To__c, Magento_Ship_To_ID__c from User_Ship_To__c]){
            List<User_Ship_To__c> tempList = userShipToMapTest.get(usrShip.Magento_Ship_To_ID__c);
            if(tempList == null) {
                    tempList = new List<User_Ship_To__c>();
                }
            tempList.add(usrShip);
            userShipToMapTest.put(usrShip.Magento_Ship_To_ID__c,tempList);
        }
        
        // get the corresponding sfdcIds for ShipTos
        List<User_Ship_To__c> userShipTos = new List<User_Ship_To__c>();
        for(String stmId: shipToMagentoIds) {
            User_Ship_To__c userShipTo = userShipTosMap.get(stmId);
            if(userShipTo == null) {
                //List<User_Ship_To__c> userShipToList = [Select Ship_To__c, Magento_Ship_To_ID__c from User_Ship_To__c where Magento_Ship_To_ID__c = :stmId];
                List<User_Ship_To__c> userShipToList = userShipToMapTest.get(stmId);
                system.debug('==============userShipToList============='+userShipToList);
                if(userShipToList == null) { // Added this condition to avoind null pointer exception
                    userShipToList = new List<User_Ship_To__c>();
                }
                // End for case 00003802
                if(userShipToList.size() > 0) { // there should always be one and only one ShipTo returned, but handling this to support any data descrepancies b/w Magento/SFDC that may exists
                    userShipTo = userShipToList.get(0);
                    userShipTosMap.put(stmId, userShipTo);
                    
                } else {
                    System.debug(Logginglevel.ERROR,'******** shipTo Data descrepancy b/w Magento and SFDC for Magento_Ship_To_ID__c:' + stmId + ' and magentoCustomerId:' + cw1.magentoCustomerId); 
                    continue;
                }
                
            }
            userShipTos.add(userShipTo);
        }
        
        
        Map<String, Id> shipToMap = new Map<String, Id> ();
        for (User_Ship_To__c userShipTo:userShipTos) {
            shipToMap.put(userShipTo.Magento_Ship_To_ID__c,userShipTo.Ship_To__c);
        }
        */ //end case 00003923
        
        // get the corresponding sfdcIds for Custom Options if any
        Map<String, Id> optionsMap = new Map<String, Id> ();
        if(customOptionMagentoIds.size() > 0) {
            List<Item_Customization__c> itemCustomizations = [Select Id, Magento_Id__c from Item_Customization__c where Magento_Id__c in :customOptionMagentoIds];
            
            for (Item_Customization__c option:itemCustomizations) {
                optionsMap.put(option.Magento_Id__c, option.Id);
            }       
        }
        
        // START DML Operation. Create Cart if one with same MagentoId doesn't exists already, then update, create, delete CartItems to represent latest state
        List<Cart_Item__c> cartItemsRetained = new List<Cart_Item__c>();
        List<Cart_Item__c> cartItemsRemoved = new List<Cart_Item__c>();
        
        System.debug(Logginglevel.ERROR,'******** cart.Magento_ID__c ' + cart.Magento_ID__c); 
        if(cart.Magento_ID__c != null && cart.Magento_ID__c.trim() != '') {
            List<Cart__c> existingCart = [Select Id, Status__c from Cart__c where Magento_ID__c=:cart.Magento_ID__c]; // should return one or zero records
            System.debug(Logginglevel.ERROR,'******** existingCart ' + existingCart); 
            
            if(existingCart==null || existingCart.size()==0) {
                cart.Status__c = 'Open';
                insert cart; 
                System.debug(Logginglevel.ERROR,'********new Cart Created: Magento_ID__c- ' + cart.Magento_ID__c + ' SFDC id- ' + cart.Id);
        
            } else { // for a Map for existing CartIds with corresponging ItemId
                cart = existingCart.get(0);
                //if (cart.Status__c != 'Submitted') { // commented this out as to trigger email notification even on re-submission
                    cart.Status__c = 'Open';
                    update cart;
                //}
                
                System.debug(Logginglevel.ERROR,'********EXISTING CART');
                List<Cart_Item__c> existingCartItems = [Select Id, Cart__c, Item__c, Ship_To__c from Cart_Item__c where Cart__c=:cart.Id];
                
                
                Boolean retained;
                
                Map<String,String> cwMap = new Map<String,String>();
                for(CartItemWrapper cw :cartItemWrappers) {
                    //Commented out for Case 00003923 - Diana - 2/22/2013
                    //cwMap.put(cw.citm.Item__c+':'+shipToMap.get(cw.magentoShipToId),'exists');
                    cwMap.put(cw.citm.Item__c+':'+cw.sfdcShipToId,'exists');
                }
                
                for(Cart_Item__c c:existingCartItems) {
                    retained = false;
                    String exists = cwMap.get(c.Ship_To__c+':'+c.Item__c);
                    if (exists==null) {
                        cartItemsRemoved.add(c);
                    } else  {
                        cartItemsRetained.add(c);
                    }
                    
                    /*for(CartItemWrapper cw :cartItemWrappers) {
                        if(shipToMap.get(cw.magentoShipToId) == c.Ship_To__c && cw.citm.Item__c == c.Item__c) {
                            
                            cartItemsRetained.add(c);
                            
                            retained = true;
                            break;
                        }
                    }
                    
                    if(!retained) {
                        cartItemsRemoved.add(c);
                    }*/
                }
            
                
            }
        }
        
        
        System.debug(Logginglevel.ERROR,'********cartItemsRetained - '+ cartItemsRetained + ' cartItemsRemoved - ' + cartItemsRemoved);
        
        Map<String, Cart_Item__c> existingCartItemMap = new Map<String, Cart_Item__c>();
        for (Cart_Item__c ct:cartItemsRetained) {
            String skuAddrCombinationKey = ''+ct.Item__c+ct.Ship_To__c;
            existingCartItemMap.put(skuAddrCombinationKey, ct);
        }
        
        
        if(cartItemsRemoved != null) {
        	deleteCartItem = true ;// Code optimization done by Jai Gupta [Appirio Jaipur] on June 26,13 for case 00048953
            delete cartItemsRemoved;
        }
        
        
        for(CartItemWrapper cw :cartItemWrappers) {
            Cart_Item__c cItem = cw.citm;
            //Commented out for case 00003923 - Diana - 2/22/2013
            //String shipToId = shipToMap.get(cw.magentoShipToId);
            String shipToId = cw.sfdcShipToId;
                        
            if(existingCartItemMap.get(cw.citm.Item__c+shipToId) != null) { // will have the Cart Item with existing ItemId + ShipTo Id combination
                cItem = existingCartItemMap.get(cw.citm.Item__c+shipToId);
                cItem.Quantity__c = cw.citm.Quantity__c;
            }
            
            cItem.Cart__c = cart.Id;
            cItem.Ship_To__c=shipToId;
            if(shipToId == null) { // this should not happen if userShipTos from SFDC and Magento Cart are in Sync
                if (cw.citm.Quantity__c==0) {
                    continue;
                }
                else {
                    //They have no shipto match but they have oitem quantities so this needs manual intervention
                    throw new CartProcessingException('ERROR: User cart has mismatch between SFDC address and Magento addresses');
                }
            }
            if(cw.magentoOptionId != null) {
                cItem.Item_Customization__c = optionsMap.get(cw.magentoOptionId);
                cItem.Custom_Attribute_Value__c = cw.magentoOptionValue;
            }
            System.debug('******** cItem.Item_Customization__c ' + cItem.Item_Customization__c + ' cItem.Custom_Attribute_Value__c ' + cItem.Custom_Attribute_Value__c);
            
            cartItems.add(cItem);
        }
        
        //Process WBS
        
        System.debug(Logginglevel.ERROR,'******** cartItems ' + cartItems);
        POS_WBSUtil util = new POS_WBSUtil(cartItems);
        util.populateWBSData(); 
        
        upsert cartItems;
        
        cart.Status__c = 'Submitted';
        cart.Last_Submitted__c = Datetime.now();
        system.debug('Last Submitted 2' + cart.Last_Submitted__c); //Testing
        
        update cart;
        
        opSuccess = true;
    }
    
    return opSuccess;
}
    
  
   @isTest(SeeAllData=true) // required as the End-Point required for getting Magento session is stored as Custom Setting
   static void testDoGet() {
  
      // setup test data
      User u = createStdUser();
      u.Magento_Id__c = '12345';
      update u;
        
        //Create Agency
        Account agency = POS_TestDataUtil.createProductionAgency();
        
        //Create Distributor Account
        Account dist = POS_TestDataUtil.createDistributorAccount();         
        
        Program__c program = POS_TestDataUtil.createProgram();
        Item__c item = POS_TestDataUtil.populateItem(program, agency);
        item.RecordTypeId = [select Id, Name, DeveloperName from RecordType where DeveloperName='Customizable' limit 1].id;
        insert item;
                 
        Item_Customization__c iCust = new Item_Customization__c(Name='Personalization Label 1', Custom_Attribute_Length__c=120, Item__c=item.Id, Magento_Id__c='60');
        insert iCust;
        
        Order_Window__c ow = POS_TestDataUtil.createOrderWindow();
        Cart__c crt = POS_TestDataUtil.createCart(u, ow);
        crt.Magento_ID__c='12345';
        crt.Status__c = 'Open';
        update crt;
        
        Order_Window_Customer__c cust = new Order_Window_Customer__c();
        cust.Order_Window__c = ow.Id;
        cust.Customer__c=u.Id;
        cust.Magento_Id__c='12345';
        insert cust;
        
        
        Cart_Item__c ci0 = POS_TestDataUtil.populateCartItem(item, crt);
        insert ci0;
        delete ci0;
        
        Cart_Item__c ci = POS_TestDataUtil.populateCartItem(item, crt);
        insert ci;
      
        req = new RestRequest();
        res = new RestResponse();
       
        req.addParameter('sfdcid', u.id);
        req.addParameter('magentoid', u.Magento_Id__c);
        req.addParameter('cart_id','12345');
    
        req.requestURI =  POS_Magento_Configuration__c.getOrgDefaults().Salesforce_apexrest_uri__c +'syncmagentocart';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
    
        String result = POS_MagentoCartRESTResource.doGet();
        System.debug('results -' + result);
   }
   
   
   
   @isTest(SeeAllData=true) // required as the End-Point required for getting Magento session is stored as Custom Setting
   static void testBudgetValidation() {
      User u = createStdUser();
      u.Magento_Id__c = '12345';
      update u;     
    
        //Create Agency
        Account agency = POS_TestDataUtil.createProductionAgency();
        
        //Create Distributor Account
        Account dist = POS_TestDataUtil.createDistributorAccount();   
        
        Order_Window__c ow = POS_TestDataUtil.createOrderWindow();        
        Brand__c brand = POS_TestDataUtil.createBrand();
        //Brand__c brand = new Brand__c(Name = 'Test Brand', Classification__c='Spirits', diageo_direct_visible__c=true, Brand_Type__c='Individual');
        //insert brand;      
        
        Program__c program = POS_TestDataUtil.createProgram(brand.Id, ow.Id);
        Item__c item = POS_TestDataUtil.populateItem(program, agency);
        item.RecordTypeId = [select Id, Name, DeveloperName from RecordType where DeveloperName='Customizable' limit 1].id;
        insert item;    
        
        Item_Customization__c iCust = new Item_Customization__c(Name='Personalization Label 1', Custom_Attribute_Length__c=120, Item__c=item.Id, Magento_Id__c='60');
        insert iCust;            
        
        Cart__c crt = POS_TestDataUtil.createCart(u, ow);
        crt.Magento_ID__c='12345'; 
        crt.Status__c = 'Open';
        update crt;
        
        Order_Window_Customer__c cust = new Order_Window_Customer__c();
        cust.Order_Window__c = ow.Id;
        cust.Customer__c=u.Id;
        cust.Magento_Id__c='12345';
        insert cust;   
        
        Ship_To__c shipTo = new Ship_To__c();
        shipTo.Account__c = dist.Id;
        shipTo.Name='Test Ship To';
        insert shipTo;  
        
        User_Ship_To__c uShipTo = new User_Ship_To__c(Ship_To__c=shipTo.id, User__c=u.id, Magento_Ship_To_ID__c='12345');
        insert uShipTo;             
                
        Cart_Item__c ci = POS_TestDataUtil.populateCartItem(item, crt);
        insert ci;
        
        String xmlString = '<?xml version="1.0" encoding="UTF-8"?><Mage_Api_Model_Server_Handler generator="zend" version="1.0"><call><cartItems><key_0><product_id>460</product_id><sku>' + ci.Item__c + '</sku><quote_id>160</quote_id><qty>10000</qty><shipto_id>' + shipto.id +'</shipto_id><customer_id>12345</customer_id><cart_id>12345</cart_id><order_window_id>12345</order_window_id><options><key_0><code>option_60</code><value>John Doe</value></key_0></options></key_0></cartItems><status>success</status></call></Mage_Api_Model_Server_Handler>';
        Dom.Document doc = new Dom.Document();
   
        Test.startTest();
        doc.load(xmlString);    
        List<CartItemWrapper> cartItems = POS_MagentoCartRESTResource.parseResponseXML(doc);
        POS_MagentoCartRESTResource.saveCartItems(cartItems);
        Test.stopTest();
        
        System.assertEquals(1, cartItems.size());
        
        validateBudget(cartItems); //Validate without budget
        
        // Associate Brand with Item
        Item_Brand__c ib = new Item_Brand__c(Brand__c = brand.Id, Item__c=item.id);
        insert ib;
        
        //Associate a brand with the account so we can budget on that brand
        AccountBrand__c ab = new AccountBrand__c();
        ab.Account__c = dist.Id;
        ab.Brand__c = program.Brand__c;
        insert ab; 
        
        Account_Member__c member = new Account_Member__c();
        member.Account__c = dist.Id;
        member.User__c = u.Id;
        insert member;
        
        //Create a budget and try again
        Budget__c budget = new Budget__c();
        budget.Shopper__c = u.Id;
        //budget.Brand__c = program.Brand__c;
        System.debug('budget.Brand__c' + budget.Brand__c);
        budget.Amount__c = 1;
        budget.Order_Window__c = ow.Id;
        insert budget;
        
        validateBudget(cartItems); //Validate with budget          
    
   }
   
   @isTest(SeeAllData=true) 
   static void testBadAddressData () {
        User u = createStdUser();
        u.Magento_Id__c = '12345';
        update u;     
    
        //Create Agency
        Account agency = POS_TestDataUtil.createProductionAgency();
        
        //Create Distributor Account
        Account dist = POS_TestDataUtil.createDistributorAccount();   
        
        Order_Window__c ow = POS_TestDataUtil.createOrderWindow();        
        Brand__c brand = POS_TestDataUtil.createBrand();
        //Brand__c brand = new Brand__c(Name = 'Test Brand', Classification__c='Spirits', diageo_direct_visible__c=true, Brand_Type__c='Individual');
        //insert brand;      
        
        Program__c program = POS_TestDataUtil.createProgram(brand.Id, ow.Id);
        Item__c item = POS_TestDataUtil.populateItem(program, agency);
        item.RecordTypeId = [select Id, Name, DeveloperName from RecordType where DeveloperName='Customizable' limit 1].id;
        insert item;    
        
        Item_Customization__c iCust = new Item_Customization__c(Name='Personalization Label 1', Custom_Attribute_Length__c=120, Item__c=item.Id, Magento_Id__c='60');
        insert iCust;            

        Cart__c crt = POS_TestDataUtil.createCart(u, ow);
        crt.Magento_ID__c='12345'; 
        crt.Status__c = 'Open';
        update crt;
        
        Order_Window_Customer__c cust = new Order_Window_Customer__c();
        cust.Order_Window__c = ow.Id;
        cust.Customer__c=u.Id;
        cust.Magento_Id__c='12345';
        insert cust;   
        
        Ship_To__c shipTo = new Ship_To__c();
        shipTo.Account__c = dist.Id;
        shipTo.Name='Test Ship To';
        insert shipTo;  
        
        User_Ship_To__c uShipTo = new User_Ship_To__c(Ship_To__c=shipTo.id, User__c=u.id, Magento_Ship_To_ID__c='12345');
        insert uShipTo;             
                
        Cart_Item__c ci = POS_TestDataUtil.populateCartItem(item, crt);
        insert ci;
        
        String xmlString = '<?xml version="1.0" encoding="UTF-8"?><Mage_Api_Model_Server_Handler generator="zend" version="1.0"><call><cartItems><key_0><product_id>460</product_id><sku>' + ci.Item__c + '</sku><quote_id>160</quote_id><qty>10000</qty><address_id>1</address_id><customer_id>12345</customer_id><cart_id>12345</cart_id><order_window_id>12345</order_window_id><options><key_0><code>option_60</code><value>John Doe</value></key_0></options></key_0></cartItems><status>success</status></call></Mage_Api_Model_Server_Handler>';
        Dom.Document doc = new Dom.Document();
        
        
        Test.startTest();
        try {
            doc.load(xmlString);    
            List<CartItemWrapper> cartItems = POS_MagentoCartRESTResource.parseResponseXML(doc);
            POS_MagentoCartRESTResource.saveCartItems(cartItems);
            System.assert(false); //We shouldn't get here because it should have errored out
        }
        catch (CartProcessingException e) {
            //This is expected because we have a quantity.  Now try the same thing without
            xmlString = '<?xml version="1.0" encoding="UTF-8"?><Mage_Api_Model_Server_Handler generator="zend" version="1.0"><call><cartItems><key_0><product_id>460</product_id><sku>' + ci.Item__c + '</sku><quote_id>160</quote_id><qty>0</qty><address_id>1</address_id><customer_id>12345</customer_id><cart_id>12345</cart_id><order_window_id>12345</order_window_id><options><key_0><code>option_60</code><value>John Doe</value></key_0></options></key_0></cartItems><status>success</status></call></Mage_Api_Model_Server_Handler>';
            doc = new Dom.Document();
            doc.load(xmlString);
            List<CartItemWrapper> cartItems = POS_MagentoCartRESTResource.parseResponseXML(doc);
            POS_MagentoCartRESTResource.saveCartItems(cartItems);
            //If we get here without failure then it's working properly
        }
        Test.stopTest();
   }
   // For case 00003802
   private static User createStdUser(){
        Profile p = [select id from profile where name='Standard User' limit 1]; 
        User testUser = new User(alias = 'standt', email='standarduser@modelmetrics.pos.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, firstname='phil',
        timezonesidkey='America/Los_Angeles', username='standarduser'+system.now().getTime()+'@modelmetrics.pos.com');
        insert testUser;
        return testUser ;
    }    

}