	function loading(isLoading,elementId) {
	    if (isLoading) {
	        document.getElementById(elementId).style.display = 'inline';
	    }
	    else {
	        document.getElementById(elementId).style.display = 'none';
	    }
	}
	
	var updatesRunning=0;
	function toggleShipTo(shipToId,checkboxElement) {
		shipToState = jQuery(checkboxElement).attr('state');
		var loadingPanel = document.getElementById('loadingPanel');
		loadingPanel.style.display='inline';
		checkboxElement.disabled=true;
		updatesRunning++;
	
		//We flip the state here because the "shipToState" reflects what it's currently set to, not what it should become
		if (shipToState=='true') {
			sendState=false;
		}
		else {
			sendState=true;
		}

		POS_ManageShipTosController.toggleShipToAjax(shipToId, sendState, function(result, event){
	    	updatesRunning--;
	    	checkboxElement.disabled=false;
	    	if (updatesRunning==0) {
				loadingPanel.style.display='none';
	    	}
	    	if (event.status) {
               
            } else if (event.type === 'exception') {
                document.getElementById("responseErrors").innerHTML = event.message;
            } else {
                document.getElementById("responseErrors").innerHTML = event.message;
            }
        }, {escape:true});
	    
	    if(shipToState == 'false'){
	    	jQuery(checkboxElement).attr('src', blueStarUrl);
	    	jQuery(checkboxElement).attr('state','true');
	    } else {
	    	jQuery(checkboxElement).attr('src', whiteStarUrl);
	    	jQuery(checkboxElement).attr('state','false');
	    }
	    
		
	}
	
	function hideNewAddress (elementLocation) {
		//jQuery('#newShipTo').css('display','none');
		jQuery('#newShipTo').hide();
		resetAddress();
	}
	
	function showNewAddress (accountId) {
			// Changes done for case #00003681 by Jai Gupta on 25th Jan,2013 
			//document.getElementById(accountField).value=accountId;
		accountField.value = accountId;
			//alert('after');
			// end for case #00003681
			//jQuery('.newAccount').val(accountId);
			//newShipToDiv = document.getElementById('newShipTo');
			//elementLocation.appendChild(newShipToDiv);
			//newShipToDiv.style.display='block';
			
			// Changes done for case #00003681 by Jai Gupta on 25th Jan,2013
			//jQuery(elementLocation).parent().append(jQuery('#newShipTo'));
			//jQuery(elementLocation).parent().append(addressDiv);
		jQuery('#newShipTo').show();		
			//jQuery('#newShipTo').css('display','block');
			//jQuery('#newShipTo').show();
			// end for case #00003681
			// handle form validation
		var validate_address = function(){
			var valid = true;
			jQuery('form.display .new_required input, form.display .new_required select').each(function(){
				jQuery(this).css('border-color', '#F0F0F0');
				if(jQuery(this).val() == '' || jQuery(this).val() == '--None--'){
					jQuery(this).css('border-color', 'red');
					valid = false;
				}
			});
			return valid;
		}
		
		// save and unbind the Salesforce inline onclick action
		//window.add_action = jQuery('.addButton').attr('onclick');
		//window.add_action = window.add_action.replace(';return false', '');
		//window.add_action = window.add_action.replace('event', '"click"');
		
		jQuery('.addButton').attr('onclick', '');
		
		jQuery('.addButton').click(function(){
		    var valid = validate_address();
		    if(valid){
		    	eval(window.add_action);
		    } else {
		        alert('One or more required fields are empty.');
		        return false;
		    }
		});
	}
	
