body {overflow-x:hidden;overflow-y:hidden; font-family:"Arial", "Arial", sans-serif; font-size: 16px; background-image:url('/resource/1320196970000/dashboardBg');}
.imageText {font-size: 13px;}
.imagePanel { border-radius: 8px; -moz-border-radius: 8px; float: right; height: 402px; overflow: auto;-webkit-overflow-scrolling:touch; width: 360px; background-color: #fff;}
.imageContainer { margin: 1px; border: 1px solid #000; border-radius: 8px; -moz-border-radius: 8px; float: left; height: 120px; width: 100px; vertical-align: top; padding: 5px; text-align:center;max-width:100px;}
.h { padding: 5px; float: left; height: 75px; width: 800px; background-color: #d0d0d0;}

.imageTypeSelection {margin: 1px; border: 2px solid #fff; float: left; width: 150px; font-size: 12px; padding-left: 2px; padding-top: 5px; padding-bottom: 5px; text-decoration: none; color: #000;}
.imageTypeSelection:hover {background-color: #CCC; border: 2px solid #CCC; margin: 1px;}
.imageTypeHighlight {margin: 1px; background-color: #99bad1; border: 2px solid #99bad1}
.imageTypeSelected {border: 2px solid #dc3270; margin:1px;}
.imageTypeSelected:hover {border: 2px solid #dc3270; margin:1px; background-color: #CCC;}

#mediaTypeSelectionPanel { border-radius: 8px; -moz-border-radius: 8px; width: 155px; background-color: #fff; border: 1px solid #000; float: left; margin-top: 45px; padding: 5px; margin-left: 5px;}
.noImageText {margin-top: 75px; float: left; margin-left: 3px;}
#filterBar {padding-top: 5px; padding-bottom: 5px;height:23px;}
#mainContainer {float: left; width: 760px;height:900px;}
#trashcan {z-index: 2; position: absolute; margin-left: 145px; margin-top:0px; background-color: #fff; }
.filterInput {width: 75px;}
.popupHeader {min-width: 100%;}
.imageSelectHeader { float: left; margin-top: 20px; background-color: #f00;}
#uploadButtonDiv { float: left; margin-top: 3px; margin-left: 35px;}
#hiddenUpload {z-index: -1; visibility:hidden;position:absolute;top:0;left:0}
#imageSelectButton { float: left; margin-left: -5px;}

#verticalSeparator { margin-left: 5px; margin-top: 40px; width: 1px; float: left; height: 402px; background-color: #CCC}

.currentImageStyle {border-radius: 8px; -moz-border-radius: 8px;}
.hidden {display: none;}
#imageLabelDiv {display: none; top: 250px; left: 180px; padding: 5px; border: 2px solid #000; width: 200px; height: 90px; font-size: 12px; z-index: +1; position: absolute; background-color: #fff; border-radius: 8px; -moz-border-radius: 8px;}
.imageLabelInput {margin-left: 40px; margin-top: 10px; }
.imageLabelButton {margin-left: 15px; margin-top: 10px;}
.imageNameLabel {margin-left: 40px; font-weight: bold;}
#noImagesAvailable {padding: 75px;}

.imageContainerWidth {
	max-width:100px;
}

.smallActionButton {
	-moz-box-shadow: 0px 2px 2px 2px #888;
	-webkit-box-shadow:  0px 2px 2px 2px #888;
	box-shadow: 0px 2px 2px 2px #888;
	-moz-border-radius:16px;
	-webkit-border-radius:16px;
	border-radius:16px;
	border:2px solid #ffffff;
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#B4064C', endColorstr='#A20644',GradientType=0 );
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#B4064C), color-stop(49%,#B4064C),color-stop(50%,#A20644));
	display:inline-block;
	color:#ffffff;
	font-family:Arial;
	font-size:12px;
	font-weight:bold;
	padding:3px 10px;	
	text-decoration:none;
}.smallActionButton:hover {
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #C50052), color-stop(1, #C50052) );
    background:-moz-linear-gradient( center top, #C50052 5%, #C50052 100% );
    filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#C50052', endColorstr='#C50052');
}.smallActionButton:active {
	position:relative;
	top:1px;
}
.greenActionButton  {
	background: -webkit-gradient(linear, left top, left bottom,color-stop(0%,#037f43), color-stop(49%,#037f43),color-stop(50%,#02713c)) ;
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#037f43', endColorstr='#02713c',,GradientType=0);
}