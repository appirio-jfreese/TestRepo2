.recipeStatusHeader { width: 1002px; height: 25px; border-top-left-radius: 6px; border-top-right-radius: 6px; background-color: #666666; font-size: 13px;margin-top:40px;}
.recipeStatusContainer {width: 1000px; min-height: 50px;background-color: #666666;  border-bottom-left-radius: 6px; border-bottom-right-radius: 6px; -moz-border-radius:6px; font-size: 13px;margin-bottom:10px;font-weight:normal;}
.recipeStatusContainer .approved { background: -webkit-gradient(linear, left top, right top, color-stop(1%,#a2ce6e), color-stop(48%,#9ec86b), color-stop(82%,#91b963));filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#a2ce6e', endColorstr='#91b963',GradientType=1 );}
.recipeStatusContainer .saved { background-color: #70a1b0;}
.recipeStatusContainer .rejected { background: -webkit-gradient(linear, left top, right top, color-stop(1%,#d62932), color-stop(48%,#D02730), color-stop(75%,#c5242d));filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#d62932', endColorstr='#c5242d',GradientType=1 );}
.recipeStatusContainer .pending { background-color: #799642;}
.recipeStatusContainer .archived { background-color: #C4BFBF;}
.headerText { font-size: 20px; font-weight:400;font-color:white;}

 body {  font-family:"Arial", "Arial", sans-serif;margin:0px!important;background:#CAC2BA;background:-webkit-gradient(linear, left top, left bottom, color-stop(1%,#CAC2BA), color-stop(100%,#B7ACA2));filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#cac2ba', endColorstr='#b7aca2',GradientType=0 ); } 
#bodyContainerDashboard { margin-left: 0px; margin-top:5px;top:0px!important;position:static!important;overflow-x:hidden;margin-right:0px;}
#blank { height: 10px; width: 100% }
.columnBar { float: left; postion: fixed; height: 20px; width: 985px; top: 5px; margin-top: 5px; margin-left: 15px; color: #ffffff; font-style:italic;}

.nameColumn { float: left; height: 15px; width: 30%;  }
.authorColumn { float: left; height: 15px; width: 25%;  }
.dateColumn { float: left; height: 15px; width: 20%;  }
.nameColumnData { float: left; height: 15px; width: 30%; }
.authorColumnData { float: left; height: 15px; width: 25%; }
.dateColumnData { float: left; height: 15px; width: 20%; }
.actionColumn { float: left; height: 15px; width: 20%;  } 

.nameColumnEditor { float: left; height: 15px; width: 29%; margin-left:5px  }
.authorColumnEditor { float: left; height: 15px; width: 12%; margin-left: 10px }
.dateColumnEditor { float: left; height: 15px; width: 19%; margin-left: 0px }
.nameColumnDataEditor { float: left; height: 15px; width: 30%;word-wrap:break-word;}
.authorColumnDataEditor { float: left; height: 15px; width: 11%;word-wrap:break-word;}
.dateColumnDataEditor { float: left; height: 15px; width: 20%;word-wrap:break-word;}
.actionColumnEditor { float: left; height: 15px; width: 10%; margin-left: 0px } 
.statusColumnEditor { float: left; height: 15px; width: 18%;  } 
.statusColumnDataEditor { float: left; height: 15px; width: 20%;word-wrap:break-word;}

.actionButton {
	-moz-box-shadow: 0px 1px 1px 1px #444;
	-webkit-box-shadow:  0px 1px 1px 1px #444;
	box-shadow: 0px 1px 1px 1px #444;
	-moz-border-radius:16px;
	-webkit-border-radius:16px;
	border-radius:16px;
	border:2px solid #ffffff;
    -moz-box-shadow:inset 0px 1px 0px 0px #ffffff;
    -webkit-box-shadow:inset 0px 1px 0px 0px #ffffff;
    box-shadow:inset 0px 1px 0px 0px #ffffff;
    -moz-border-radius:16px;
    -webkit-border-radius:16px;
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#b4064c), color-stop(49%,#b4064c),color-stop(50%,#a20644));
    filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#b4064c', endColorstr='#a20644',GradientType=0 );
    border-radius:16px;
    border:2px solid #ffffff;
    display:inline-block;
    color:#ffffff;
    font-family:"Arial", "Arial", sans-serif;
    font-size:13px;
    font-weight:bold;
    text-decoration:none;
    width:15%;
    float:left;
}.actionButton:hover {
   background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #C50052), color-stop(1, #C50052) );
    background:-moz-linear-gradient( center top, #C50052 5%, #C50052 100% );
    filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#C50052', endColorstr='#C50052');
}.actionButton:active {
    position:relative; 
    top:1px;
}

.horizontalRuleClass{
    width:96% !important;
    size:1px !important; 
    background-color: #9E9E9E;
    float:left;
    margin-bottom:1px;
    margin-top:1px; 
}

#bodyHeader {position: relative!important;left: 0px;background:-webkit-gradient(linear, left top, left bottom, from(#5985A3), to(#3E607F));filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#5985A3', endColorstr='#3E607F',GradientType=0 );color: #ffffff; height: 40px; font-family:"Arial", "Arial", sans-serif; width: 1150px!important; float: right;min-width:1120px;}
#headerInner { float: left; padding-right: 30px; height: 100%;}

.dashboardRow {
	margin-left: 10px;
	padding-left: 0px;
	padding-top: 10px;
	border-bottom: 1px solid #aaa;
	height: 35px;
	margin-right: 15px;
	margin-bottom: 0px;
	padding-bottom: 5px;
	width: 950px;
	
}

.borderBackgroundTop{
	border-top-style:solid;
	border-top-width:1px;
	border-top-color:#666666;
	border-left-style:solid;
	border-left-width:1px;
	border-left-color:#666666;
	border-right-style:solid;
	border-right-width:1px;
	border-right-color:#666666;
}

.borderBackgroundBottom{
	border-bottom-style:solid;
	border-bottom-width:2px;
	border-bottom-color:#666666;
	border-left-style:solid;
	border-left-width:2px;
	border-left-color:#666666;
	border-right-style:solid;
	border-right-width:2px;
	border-right-color:#666666;
}

.saved .dashboardRow {
	border-bottom: 1px solid #94c0cc;
}

.rejected .dashboardRow {
	border-bottom: 1px solid #Ec8287;
	color:white;
}

.approved .dashboardRow {
	border-bottom: 1px solid #A9D277;
}

.pending .dashboardRow {
	border-bottom: 1px solid #BCD0A4;
}

.dashboardRowNoValues {
	
	margin-left: 21px;
	padding-top:15px;
}

.italicClass{
	font-style : italic;
	padding-left:60px;

}
.dashboardSection { min-height: 50px; }

.header{
	padding-left: 15px;
	padding-top: 9px;
	float:left;
	text-decoration:none;
	color: white !important;
	font-size:14px;
}
.header1{
	padding-left: 10px;
	padding-top: 9px;
	float:left;
	text-decoration:none;
	color: white !important;
	font-size:14px;
}
.arrow{
	padding-top: 14px;
}
.arrow2{
	padding-top:15px;
}
.arrow3{
	padding-top:12px;
}

.aLink{
	text-decoration:none;
	color: black !important; 
	font-style:italic;
	font-weight:bold;
	padding-left:60px;
	float:left;
	text-align:left;
}
.aLink:hover{
	color: #b4064c !important;
}
.showLinksPanel{
	height:20px;
	float:left;
	width:400px;
	padding-left:60px;
}

.titleClass{
	width:100%;
	height:20px;
	//float:left;
	font-weight:bold;
	font-family:"Arial","Arial","sans-seriff";
	text-align:left;
	padding-left:60px;
}



.outerDiv{
	width:1150px;
	margin:10px auto 10px auto; 
	display:block;
	position:relative;
	height:100%;
	background-image:url('/resource/1320196970000/dashboardBg');
	
}
.innerDiv{
	width:1120px;
	margin:10px auto;
	overflow:hidden;
	position:relative;
	height:100%;
}
.statusHeaderClass{
	float:left;
	padding-left:0px;
}
.dataContainerClass{
	padding-left:5px;
	width:90%;
	text-align:left;
	float:left;
	display:block;
}
.savedHeaderClass{
	margin-top:0px!important;
}

.clearEnd{
	clear:both;
}