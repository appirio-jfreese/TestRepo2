#content {
	background-color: #DDDDDD;
	font-family: Arial, sans-serif;
	width: 820px;
	margin-left: auto;
	margin-right: auto;
	position:relative;
	z-index:1;
}
.ShippingHeader {
	font-size: 20px;
	font-weight: bold;
	margin: 5px;
	background: none repeat scroll 0 0 #202B62;
    padding: 6px 10px;
	text-align: center;
	color: white;s
}

.showNewAddress {
	font-size: 12px;
	font-weight: normal;
}


.ShipToList {
	border-top: 5px solid #000;
	border-bottom: 5px solid #000;
	border-collapse: separate;s
	border-spacing: 0 5px;
	margin: 5px;
	margin-top: 15px;
	padding: 10px 5px;
	overflow-y: auto;
}

.ShipTo {
	margin-top: 10px;
	display: inline-block;
	*display: inline;
	zoom: 1;
}

.ShipToAccount {
	font-size: 18px;
	font-weight: bold;
	background: none repeat scroll 0 0 #202B62;
    padding: 5px 0 0 0;
	text-align: center;
	color: white;
}

.ShipToFunctions {
	float: left;
	width: 16px;
}

.ShipToCheckbox  {
	margin-left: 2px;
}

.ShipToFunctions .ui-icon {
	float: left;
	margin-top: 3px;
}
 
.ShipToDetails {
	float: left;
	margin-left: 5px;
	width: 150px;
	height: 165px;
}

.ShipToName {
	font-weight: bold;
}

.NewShipTo {
	display: none;
	margin-top: 20px;
	background: white;
	color: black;
	margin: auto;
}

.NewShipToField {
	display: inline-block;
	padding: 2px;
}

.NewShipToHeader {
	font-size: 12px;
	font-weight: bold;
	margin-left: 2px;
	margin-top: 10px;
	margin-bottom: 5px;
}


.NewShipToFieldName {
	font-size: 12px;
}

.NewShipToVieldValue {
	border: 3px inset #F0F0F0; 
	font-size: 12px;
}

.NewShipToField input  {
	font-size: 12px;
}

.NewShipToField select  {
	font-size: 12px;
}

.addButton {
	font-size: 12px;
}

.cancelButton  {
	font-size: 12px;
}

.ShipToActions {
	width: 300px;
}

.waitState {
	display: inline;
	position: relative;
	position-x: 0;
	position-y: 0;
	z-index: 1;
	opacity:0.9;
	filter:alpha(opacity=9);
	background-color: #f00;
}

.readyState {
	display: none;
}

.toggleSpinner {
	
}

.disabledCheckbox {
	
	background-image:url('{!$Resource.POS_BWSpinner}');
}

.enabledChecbkox {
	width: 15px;
	height: 15px;
}

#loadingPanel {
   height: 10px;
}
#notes_div {
	vertical-align: top;
}
.NewShipToSubmit input {
	width: 90px;
	margin: auto;
}
.NewShipToSubmit {
	width: 200px;
	margin: auto;
}
html, body {
  height: 100%;
  margin: 0;
  padding: 0;
}
img#bg {
  position:fixed;
  top:0;
  left:0;
  width:100%;
  height:100%;
  z-index: -1;
} 

.showNewAddress > a {
  color: #DDDDDD;
}
.wrapper {
  margin: auto !important;
  width: 1066px !important;
}