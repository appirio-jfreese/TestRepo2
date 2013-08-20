/* Override default skin to fit DD look better*/
.header {
}
.wrapper {
	position: relative;
}
.footer-wrapper {
	margin: 0 auto;
	position: absolute;
	width: 100%;
	bottom: 0;
	left: 0;
	height: 60px;
}
.footer-container {
	margin: 0 auto !important;
	background: none repeat scroll 0 0 transparent !important;
	height: auto !important;
}
.footer ul.links {
	padding: 0 !important;
}
.main {
	padding: 0 !important;
}



/* Skin extensions for Order tracking */
.backLink {
	margin-left: 20px;
	margin-top: 10px;
	text-align: left;
	color: #000;
}

.BackToWindow {
	margin-left: 400px;
}




.col-full-layout {
	
	background: white;
	padding:0 0 8px;
	overflow:hidden;
}

/******* visual block ********/                                              
                                                         
.visual-block .items-list{                                 
    margin:0 0 0 2px;                                    
    padding:0;                                             
    list-style:none;                                       
    overflow:hidden;                                       
}    
                                                
.visual-block .items-list li:hover a{text-decoration:none;}
.visual-block .items-list li .text{                        
    width:280px;                                           
    overflow:hidden;                                       
    padding:42px 13px 0;                                   
    display:block;                                         
    height:128px;                                           
}   
/*title*/                                                       
.visual-block .items-list li .text .title{                      
    font:bold 23px/27px Tahoma, Geneva, sans-serif;             
    color:#fff;                                                 
    float:left;                                                 
    letter-spacing:-1px;                                        
}                                                               
.visual-block .items-list li .holder{                           
    width:100%;                                                 
    overflow:hidden;                                            
    display:block;                                              
    padding:0 0 8px;                                            
}                                                               
.visual-block .items-list li .text .state{                      
    margin:0 0 0 6px;                                           
    color:#40c62c;                                              
    font:bold 20px/27px Tahoma, Geneva, sans-serif;             
}
.visual-block .items-list li .text .state.coming{color:#deba3a; background: none;}
.visual-block .items-list li .text .state.closed{color:#de4040; background: none;}
/*date*/                                                        
.visual-block .items-list li .text .date{                       
    font:18px/20px Tahoma, Geneva, sans-serif;                  
    color:#fff;                                                 
    display:block;                                              
}                                                               
/*images*/                                                      
.visual-block .items-list img{                                  
    position:absolute;                                          
    top:0;                                                      
    left:0;
    border-radius: 10px 10px 10px 10px;                                                     
}                                                               
.visual-block .items-list .text{                                
    position:relative;                                          
    z-index:1;                                                  
}

.visual-block .brand-list {
  list-style: none outside none;
}
.visual-block .brand-list {
  list-style: none outside none;
  margin: 0 140px;
  overflow: hidden;
  padding: 0;
}
.visual-block .brand-list li {
  overflow: hidden;
  vertical-align: top;
  width: 940px;
}
.visual-block .brand-list .text {
  float: left;
  padding: 6px 0 0 27px;
  position: relative;
  width: 265px;
}
.visual-block .brand-list .text-holder {
  color: #FFFFFF;
  font: bold 23px/27px Tahoma,Geneva,sans-serif;
}
.visual-block .brand-list .text-holder:after {
  clear: both;
  content: "";
  display: block;
}
.visual-block .brand-list .text-fr {
  display: table;
}
.visual-block .brand-list .text-fr span {
  display: table-cell;
  vertical-align: middle;
}
.visual-block .brand-list ul {
  float: left;
  list-style: none outside none;
  margin: 0;
  overflow: hidden;
  padding: 0;
}
.visual-block .brand-list ul li:first-child {
  margin: 0;
}
.visual-block .brand-list ul li a {
  color: #FFFFFF;
  display: table-cell;
  height: 55px;
  padding: 0 48px 0 10px;
  vertical-align: middle;
  width: 250px;
  text-decoration: none;
}
.visual-block .back {
  -moz-border-bottom-colors: none;
  -moz-border-image: none;
  -moz-border-left-colors: none;
  -moz-border-right-colors: none;
  -moz-border-top-colors: none;
  background: none repeat scroll 0 0 #20295E;
  border-color: #101539;
  border-style: solid;
  border-width: 0 1px 1px 0;
  color: #FFFFFF;
  font-size: 14px;
  font-weight: bold;
  left: 50px;
  line-height: 16px;
  padding: 5px 8px 3px;
  position: absolute;
  top: 10px;
}
.visual-block .brand-list ul.submenu {
  display: none;
}

.order-history thead th.first, .calendarContainer thead th.first {
	text-align: center;
	color: #FFFFFF;
	background-color: #202b62;
	border: 1px solid #666;
	height: 30px;
	*zoom: 1;
}
.orderWindowColumn {
	width: 350px;
}
.leftArrow, .rightArrow {
	*display: inline;
	*zoom: 1;
	width: 10px;
	clear: none;
}
.leftArrow {
	float: left;
}
.rightArrow {
	float: right;
}
.order-history {
	border-collapse:separate;
	border-spacing:0px 5px;
	table-layout: fixed;
}


.order-history tbody {
}

.scrollingTable {
}

.order-history tbody tr {
	font-size: 13px;
	padding: 3px;
	color: #000;
	background-color: #E8E8E8;
	height: 70px;
}

.order-history tbody tr td {	
	vertical-align: middle;
	background-color: #E8E8E8;
	border: none;
	
}

.noWindowsColumn {
	text-align: center;
	font-weight: bold;
	font-size: 12px;
	background-color: #fff !important;
}

.order-history tr:last-child td {
	border-bottom: 0px;
}

.order-history li {
	list-style-type: none;
}

.orderSubmittedColumn {
	width: 100px;
	text-align: right;
	vertical-align: middle;
}

orderSubmittedColumnValue {
	text-align: left;
	vertical-align: middle;
}

.leftYear {
	float:left;
	margin-left: 0px;
}

.rightYear {
	margin-right: 0px;
	float: right;
}

.windowFilter {
	float: right;
	font-size: 12px;
	padding: 10px 40px;
	*position: relative;
	*top: 36px;
}

.monthlyDetails {
	display: none;
	
}

.monthlyDetailBody {
	margin-left: 5px;
	margin-top: 5px;
	height: 200px;
	overflow-y: auto;
	overflow-x: none;
	
}

.monthlyDetailBody li {
	text-indent: 20px;
	margin-top: 2px;
	
}

.monthlyDetailHeader {
	font-weight: bold;
	font-size: 12px;
}

/* Order History Detail CSS additions*/
.orderDetail  tr {
	font-size: 10px;
	padding: 3px;
	color: #000;
}


.orderDetail  tr td {	
	vertical-align: text-top;
	border: none;
}

.shipToHeader {
	border: 1px solid #666;
}

.shipToHeader td {
	font-size: 14px;
	background-color: #E8E8E8;
}

.shipToBreak td {
	height: 10px;
}

.shippedItem { 
	border: 0px;
}

.shippedItem td {
	font-size: 12px;
	background-color: #FFF;
	border: 0px;
}


.itemHeader {
	border-bottom: 2px solid #E8E8E8;
}

.itemHeader td {
	font-size: 12px;
	color: #000;
	font-weight: bold;
	background-color: #fff;
}

.showDivArrow {
	float: right;
}

.previousOrdersArrow {
	float:left;
	margin-left: 0px;
}

.nextOrdersArrow {
	margin-right: 0px;
	float: right;
}

.std table td  {
	border: 0px;
	color: #000;
}

.loadingText {
	position: absolute;
	margin-left: 20px;
	font-size: 10px;
	font-weight: bold;
	color: #000;
}

/* Timeline */

.calendarContainer {
	font-size: 10px;
	position: static !important;
}

.orderWindowRow {
	height: 50px;
	margin-top: 12px;
	margin-left: 15px;
}

.calendarSpacerLead {
	float: left;
	width: 67px;
	height: 50px;
}

.calendarSpacerTail {
	float: left;
	width: 67px;
	height: 50px;
}

.orderWindowCell { 
/*	border: 1px solid #ccc; */
	float: left;
	width: 73px;
	height: 100%;
	padding-left: 3px;
	padding-right: 3px;
	text-align: center;
	vertical-align: middle;
  	text-overflow: ellipsis;
  	overflow: hidden;
}

.orderWindowCell.Closed {
/*	border: 1px dashed #ccc; */
}

.orderWindowCell.Archived {
/*	border: 1px dashed #ccc; */
}	

.orderWindowCell.Open {
/*	border: 1px solid #000; */
}

.calendarSubsection {
	width: 930px;
	margin-left: 2px;
}

.calendarHeader {
	width: 71px;
	float: left;
	border: 1px solid #ccc;
	margin-left: 1px;
	margin-right: 1px;
	text-align: center;
	font-weight: bold;
}

.calendarHeaderRow {
	height: 15px;
	margin-left: 15px;
	width: 930px;
}

.orderWindowDetails {
	display: none;
	
}

.orderWindowDetailsBody {
	font-size: 12px;
	background-color: #fff;
	text-align: left;
	width: 350px;
}

.orderWindowDetailHeader {
	font-size: 12px;
	margin-left: 5px;
	margin-top: 5px;
	display: block;
}

.orderWindowDetailsBody ul {
	margin-left: 20px;
	margin-top: 2px;
	height: 50px;
}

.orderWindowDetailsBody ul li {
	list-style-type: none;
}

.orderWindowDetailsBody .ui-icon {
	float: right;
}

/* NAV CCS FROM DD */
/*breadcrumb*/

div.breadcrumb-home.over{
    background-position: -20px 0px;
}



div.breadcrumb-links {
    padding:     0px;
	padding-top: 2px;
    float:       left;
    font-size:   14px;
    font-family: Tahoma, Arial;
    font-weight: notmal;
    color:       #dfd8d8;
}

div.breadcrumb-links a {
    font-size:       14px;
    font-family:     Tahoma, Arial;
    color:           #dfd8d8;
    text-decoration: none;
}

a.breadcrumb-links-current {
    color:           #FFFFFF !important;
}



ul.topnav {
    list-style: none;
    padding:    2px 0px 0px 27px;
    margin:     0px;
    float:      left;
    width:      130px;
}

div.over ul.topnav {
    color: #C7C7C7;
}

ul.topnav li {
    float:    left;
    margin:   0px 7px 0px 0px;
    padding:  0px;
    position: relative;
    height:   20px;
}

ul.topnav li ul li {
    height: auto;
}

ul.topnav li a {
    padding:         0px;
    color:           #FFFFFF;
    display:         block;
    text-decoration: none;
    float:           left;
}

ul.topnav li a:hover {
	background: #8d8d8d; /* Old browsers */
	background: -moz-linear-gradient(top, #8d8d8d 0%, #6d6d6d 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#8d8d8d), color-stop(100%,#6d6d6d)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #8d8d8d 0%,#6d6d6d 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #8d8d8d 0%,#6d6d6d 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #8d8d8d 0%,#6d6d6d 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#8d8d8d', endColorstr='#6d6d6d',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #8d8d8d 0%,#6d6d6d 100%); /* W3C */	
}

ul.topnav li span.topNavRoot {
    float: left;
}

ul.topnav li ul.subnav {
    list-style: none;
    position:   absolute; 
    left:       -47px;
    top:        26px;
    background: #999999;
    margin:     0px;
    padding:    0px;
    display:    none;
    float:      left;
    width:      240px;
    border:     1px solid #A5A5A5;
    z-index:    30;
	border-bottom: none;
}

ul.topnav li ul.subnav2 {
    left: 241px!important;
    top:  0px!important;
	margin-top: 0px !important;
}

ul.topnav li ul.subnav li {
    margin:  0;
    padding: 0px;
    clear:   both;
    width:   206px;
}

html ul.topnav li ul.subnav li a {
    float:        left;
    width:        225px;
	padding: 	  8px;
	font-size:	  12px;
	background: #9c9c9c; /* Old browsers */
	background: -moz-linear-gradient(top, #9c9c9c 0%, #797979 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#9c9c9c), color-stop(100%,#797979)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #9c9c9c 0%,#797979 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #9c9c9c 0%,#797979 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #9c9c9c 0%,#797979 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#9c9c9c', endColorstr='#797979',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #9c9c9c 0%,#797979 100%); /* W3C */
    border-bottom:1px solid #A5A5A5;
}

/* color menu items*/
html ul.topnav li ul.subnav li.menu-mep a:hover { 
	background: #d40759; /* Old browsers */
	background: -moz-linear-gradient(top, #d40759 1%, #8f043c 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#d40759), color-stop(100%,#8f043c)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #d40759 1%,#8f043c 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #d40759 1%,#8f043c 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #d40759 1%,#8f043c 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#d40759', endColorstr='#8f043c',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #d40759 1%,#8f043c 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-bmi a:hover { 
	background: #5ebfd3; /* Old browsers */
	background: -moz-linear-gradient(top, #5ebfd3 1%, #2c8ea1 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#5ebfd3), color-stop(100%,#2c8ea1)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #5ebfd3 1%,#2c8ea1 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #5ebfd3 1%,#2c8ea1 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #5ebfd3 1%,#2c8ea1 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#5ebfd3', endColorstr='#2c8ea1',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #5ebfd3 1%,#2c8ea1 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-pil a:hover { 
	background: #ad2b5f; /* Old browsers */
	background: -moz-linear-gradient(top, #ad2b5f 1%, #7e0c3a 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#ad2b5f), color-stop(100%,#7e0c3a)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #ad2b5f 1%,#7e0c3a 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #ad2b5f 1%,#7e0c3a 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #ad2b5f 1%,#7e0c3a 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ad2b5f', endColorstr='#7e0c3a',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #ad2b5f 1%,#7e0c3a 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-sm a:hover { 
	background: #863b93; /* Old browsers */
	background: -moz-linear-gradient(top, #863b93 1%, #4f2158 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#863b93), color-stop(100%,#4f2158)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #863b93 1%,#4f2158 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #863b93 1%,#4f2158 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #863b93 1%,#4f2158 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#863b93', endColorstr='#4f2158',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #863b93 1%,#4f2158 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-isv a:hover { 
	background: #cbd92b; /* Old browsers */
	background: -moz-linear-gradient(top, #cbd92b 1%, #a6b713 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#cbd92b), color-stop(100%,#a6b713)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #cbd92b 1%,#a6b713 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #cbd92b 1%,#a6b713 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #cbd92b 1%,#a6b713 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#cbd92b', endColorstr='#a6b713',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #cbd92b 1%,#a6b713 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-pos a:hover { 
	background: #202B62; /* Old browsers */
	background: -moz-linear-gradient(top, #202B62 1%, #263375 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#202B62), color-stop(100%,#263375)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #202B62 1%,#263375 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #202B62 1%,#263375 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #202B62 1%,#263375 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#202B62', endColorstr='#263375',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #202B62 1%,#263375 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-pm a:hover {
	background: rgb(248,110,27); /* Old browsers */
	background: -moz-linear-gradient(top,  rgba(248,110,27,1) 0%, rgba(183,79,17,1) 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(248,110,27,1)), color-stop(100%,rgba(183,79,17,1))); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  rgba(248,110,27,1) 0%,rgba(183,79,17,1) 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  rgba(248,110,27,1) 0%,rgba(183,79,17,1) 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  rgba(248,110,27,1) 0%,rgba(183,79,17,1) 100%); /* IE10+ */
	background: linear-gradient(top,  rgba(248,110,27,1) 0%,rgba(183,79,17,1) 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f86e1b', endColorstr='#b74f11',GradientType=0 ); /* IE6-9 */

}
html ul.topnav li ul.subnav li.menu-dws a:hover {
	background: #95c97c; /* Old browsers */
	background: -moz-linear-gradient(top,  #95c97c 0%, #4a643e 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#95c97c), color-stop(100%,#4a643e)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #95c97c 0%,#4a643e 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #95c97c 0%,#4a643e 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #95c97c 0%,#4a643e 100%); /* IE10+ */
	background: linear-gradient(top,  #95c97c 0%,#4a643e 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#95c97c', endColorstr='#4a643e',GradientType=0 ); /* IE6-8 */
}

html ul.topnav li ul.subnav li.menu-col a:hover { 
	background: rgb(198,85,76); /* Old browsers */
	background: -moz-linear-gradient(top, rgba(198,85,76,1) 0%, rgba(178,34,22,1) 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(198,85,76,1)), color-stop(100%,rgba(178,34,22,1))); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, rgba(198,85,76,1) 0%,rgba(178,34,22,1) 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, rgba(198,85,76,1) 0%,rgba(178,34,22,1) 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top, rgba(198,85,76,1) 0%,rgba(178,34,22,1) 100%); /* IE10+ */
	background: linear-gradient(top, rgba(198,85,76,1) 0%,rgba(178,34,22,1) 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#c6554c', endColorstr='#b22216',GradientType=0 ); /* IE6-9 */
}
html ul.topnav li ul.subnav li.menu-plan a:hover { 
	background: rgb(247,173,130); /* Old browsers */
	background: -moz-linear-gradient(top, rgba(247,173,130,1) 0%, rgba(236,128,65,1) 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(247,173,130,1)), color-stop(100%,rgba(236,128,65,1))); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, rgba(247,173,130,1) 0%,rgba(236,128,65,1) 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, rgba(247,173,130,1) 0%,rgba(236,128,65,1) 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top, rgba(247,173,130,1) 0%,rgba(236,128,65,1) 100%); /* IE10+ */
	background: linear-gradient(top, rgba(247,173,130,1) 0%,rgba(236,128,65,1) 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f7ad82', endColorstr='#ec8041',GradientType=0 ); /* IE6-9 */
}


/* color menu items: active*/
html ul.topnav li ul.subnav li.menu-mep a.active-item { 
	background: #d40759; /* Old browsers */
	background: -moz-linear-gradient(top, #d40759 1%, #8f043c 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#d40759), color-stop(100%,#8f043c)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #d40759 1%,#8f043c 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #d40759 1%,#8f043c 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #d40759 1%,#8f043c 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#d40759', endColorstr='#8f043c',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #d40759 1%,#8f043c 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-bmi a.active-item { 
	background: #5ebfd3; /* Old browsers */
	background: -moz-linear-gradient(top, #5ebfd3 1%, #2c8ea1 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#5ebfd3), color-stop(100%,#2c8ea1)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #5ebfd3 1%,#2c8ea1 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #5ebfd3 1%,#2c8ea1 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #5ebfd3 1%,#2c8ea1 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#5ebfd3', endColorstr='#2c8ea1',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #5ebfd3 1%,#2c8ea1 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-pil a.active-item{ 
	background: #ad2b5f; /* Old browsers */
	background: -moz-linear-gradient(top, #ad2b5f 1%, #7e0c3a 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#ad2b5f), color-stop(100%,#7e0c3a)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #ad2b5f 1%,#7e0c3a 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #ad2b5f 1%,#7e0c3a 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #ad2b5f 1%,#7e0c3a 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ad2b5f', endColorstr='#7e0c3a',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #ad2b5f 1%,#7e0c3a 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-sm a.active-item { 
	background: #863b93; /* Old browsers */
	background: -moz-linear-gradient(top, #863b93 1%, #4f2158 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#863b93), color-stop(100%,#4f2158)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #863b93 1%,#4f2158 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #863b93 1%,#4f2158 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #863b93 1%,#4f2158 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#863b93', endColorstr='#4f2158',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #863b93 1%,#4f2158 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-isv a.active-item{ 
	background: #cbd92b; /* Old browsers */
	background: -moz-linear-gradient(top, #cbd92b 1%, #a6b713 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#cbd92b), color-stop(100%,#a6b713)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #cbd92b 1%,#a6b713 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #cbd92b 1%,#a6b713 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #cbd92b 1%,#a6b713 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#cbd92b', endColorstr='#a6b713',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #cbd92b 1%,#a6b713 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-pos a.active-item { 
	background: #fbd100; /* Old browsers */
	background: -moz-linear-gradient(top, #fbd100 1%, #c4a30b 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#fbd100), color-stop(100%,#c4a30b)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #fbd100 1%,#c4a30b 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #fbd100 1%,#c4a30b 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #fbd100 1%,#c4a30b 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fbd100', endColorstr='#c4a30b',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #fbd100 1%,#c4a30b 100%); /* W3C */
}
html ul.topnav li ul.subnav li.menu-pm a.active-item {
	background: rgb(248,110,27); /* Old browsers */
	background: -moz-linear-gradient(top,  rgba(248,110,27,1) 0%, rgba(183,79,17,1) 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(248,110,27,1)), color-stop(100%,rgba(183,79,17,1))); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  rgba(248,110,27,1) 0%,rgba(183,79,17,1) 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  rgba(248,110,27,1) 0%,rgba(183,79,17,1) 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  rgba(248,110,27,1) 0%,rgba(183,79,17,1) 100%); /* IE10+ */
	background: linear-gradient(top,  rgba(248,110,27,1) 0%,rgba(183,79,17,1) 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f86e1b', endColorstr='#b74f11',GradientType=0 ); /* IE6-9 */

}
html ul.topnav li ul.subnav li.menu-dws a.active-item {
	background: rgb(169,231,243); /* Old browsers */
	background: -moz-linear-gradient(top,  rgba(169,231,243,1) 0%, rgba(94,191,211,1) 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(169,231,243,1)), color-stop(100%,rgba(94,191,211,1))); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  rgba(169,231,243,1) 0%,rgba(94,191,211,1) 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  rgba(169,231,243,1) 0%,rgba(94,191,211,1) 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  rgba(169,231,243,1) 0%,rgba(94,191,211,1) 100%); /* IE10+ */
	background: linear-gradient(top,  rgba(169,231,243,1) 0%,rgba(94,191,211,1) 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#a9e7f3', endColorstr='#5ebfd3',GradientType=0 ); /* IE6-9 */
}

html ul.topnav li ul.subnav li.menu-col a.active-item{ 
	background: rgb(198,85,76); /* Old browsers */
	background: -moz-linear-gradient(top, rgba(198,85,76,1) 0%, rgba(178,34,22,1) 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(198,85,76,1)), color-stop(100%,rgba(178,34,22,1))); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, rgba(198,85,76,1) 0%,rgba(178,34,22,1) 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, rgba(198,85,76,1) 0%,rgba(178,34,22,1) 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top, rgba(198,85,76,1) 0%,rgba(178,34,22,1) 100%); /* IE10+ */
	background: linear-gradient(top, rgba(198,85,76,1) 0%,rgba(178,34,22,1) 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#c6554c', endColorstr='#b22216',GradientType=0 ); /* IE6-9 */
}
html ul.topnav li ul.subnav li.menu-plan a.active-item { 
	background: rgb(247,173,130); /* Old browsers */
	background: -moz-linear-gradient(top, rgba(247,173,130,1) 0%, rgba(236,128,65,1) 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(247,173,130,1)), color-stop(100%,rgba(236,128,65,1))); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, rgba(247,173,130,1) 0%,rgba(236,128,65,1) 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, rgba(247,173,130,1) 0%,rgba(236,128,65,1) 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top, rgba(247,173,130,1) 0%,rgba(236,128,65,1) 100%); /* IE10+ */
	background: linear-gradient(top, rgba(247,173,130,1) 0%,rgba(236,128,65,1) 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f7ad82', endColorstr='#ec8041',GradientType=0 ); /* IE6-9 */
}

html body div table.stupid_ie_workaround {
	border: 0;
	margin: 0;
	padding: 0;
	width: 930px;
}
html body div table.stupid_ie_workaround tr {
	border: 0;
}
html body div table.stupid_ie_workaround td, table.stupid_ie_workaround tr {
	background: none !important;
	border: none !important; 
	height: auto;
}
html body div table.stupid_ie_workaround td.yearArrow {
	width: 10px;
}
html body div table.stupid_ie_workaround td.year {
	width: 995px;
	text-align: center;
	color: #FFFFFF;
}
html body .OW_actions {
	width: 300px;
}
html body .OW_actions ul li{
	display: inline;
}
html body .orderWindowDetailsBody li {
	display: inline;
}
.breadcrumbs li {
	*width: 100%;
}
.reports-filters-single {
	float: left;
	width: 175px;
	padding: 5px;
	background: #AAAAAA;
	min-height: 105px;
}
.reports-filters-single select {
	width: 175px;
}
.reports-filters h2 {
	color: white;
}
.reports-content {
	color: black;
}
.reports-content-list a {
	color: #555555;
}
.loaderDialog {
	position:		absolute;
	top:			0px;
	left:			0px;
	z-index:		2501;
}
.ajaxLoaderBox {
	background: #606060; /* Old browsers */
	background: -moz-linear-gradient(top, #606060 0%, #2d2d2d 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#606060), color-stop(100%,#2d2d2d)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top, #606060 0%,#2d2d2d 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top, #606060 0%,#2d2d2d 100%); /* Opera11.10+ */
	background: -ms-linear-gradient(top, #606060 0%,#2d2d2d 100%); /* IE10+ */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#606060', endColorstr='#2d2d2d',GradientType=0 ); /* IE6-9 */
	background: linear-gradient(top, #606060 0%,#2d2d2d 100%); /* W3C */
	width:					300px;
	height:					70px;
    color:                 	#ffffff;
    font-size:             	15px;
    font-weight:           	bold;
    padding:               	10px;
	padding-top:			10px;
    font-family:           	Tahoma, Arial;
    text-align:            	center;
	-webkit-box-shadow: 1px 1px 4px 4px rgba(0, 0, 0, 0.5);
	-moz-box-shadow: 1px 1px 4px 4px rgba(0, 0, 0, 0.5);
	box-shadow: 1px 1px 4px 4px rgba(0,0, 0, 0.5);
	border: 1px solid #333333;	
}
span.ajaxLoaderMoreInfo{
    font-size:   11px;
    color:       #ffffff;
    font-weight: normal;    
}
#ajaxLoader > .sectionBackground {
    background: -moz-linear-gradient(center top , #258596 0%, #025D6D 100%) repeat scroll 0 0 transparent !important;
}
#ajaxLoader > .sectionBorder {
    border-color: #258596 !important;
}
#loaderOverlayDisable {
    background-color: #555555;
    height: 0;
    left: 0;
    opacity: 0;
    position: absolute;
    top: 0;
    width: 100%;
    z-index: 2500;
}
#ajaxLoader {
	margin-left: -150px;
	margin-top: -50px;
}