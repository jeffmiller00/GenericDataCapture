<!doctype html>
<!--[if lt IE 7 ]> <html lang="en" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>    <html lang="en" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>    <html lang="en" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>    <html lang="en" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]> <html lang="en" class="no-js"> <![endif]-->


<head>
	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	
	<title>eshots Online Data Capture</title>
	<meta name="description" content="eshots, the leader in interactive event marketing - Online Data Entry Solution">
	<meta name="author" content="eshots, Inc.">
	
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	
	<link rel="shortcut icon" href="/favicon.ico">

	<link href="css/base.css" rel="stylesheet" type="text/css" media="all" />
	<link href="css/layout.css" rel="stylesheet" type="text/css" media="all" />

	<link rel="stylesheet" href="css/boilerplate.css?v=2">
	<link rel="stylesheet" href="css/style.css">

	<!--[if IE]><link href="css/ie.css" rel="stylesheet" type="text/css" media="all" /><![endif]-->
	<!--[if IE 6]><link href="css/ie6.css" rel="stylesheet" type="text/css" media="all" /><![endif]-->

	<link rel="stylesheet" media="handheld" href="css/handheld.css?v=2">
	<script src="js/libs/modernizr-1.7.min.js"></script>
	<!--- <script src="https://eshots.com/webentry/js/jquery-1.7.1.min.js" type="text/javascript"></script> --->
 	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript"></script>


</head>
<body>
<cfif IsDefined('SESSION.debug') AND SESSION.debug EQ true>
<cfdump var="#APPLICATION#" expand="false">
<cfdump var="#SESSION#" expand="false">
<cfdump var="#COOKIE#" expand="false">
<cfdump var="#FORM#" expand="false">
</cfif>
	<div id="container">
	
		<div id="solutions"></div>	
		
		<a id="home" href="index.cfm"><img src="images/eshots_logo.gif" alt="Home" /></a>

		<cfif NOT FindNoCase("index.cfm", CGI.SCRIPT_NAME)>
			<ul id="settings">
				<!--- <li class="oe_heading">Change Client License ID</li> --->
				<cfif ListLen(SESSION.availClientLicenseID) GT 1>
				<li><a href="campaign.cfm?change">Change Campaign</a></li>
				</cfif>
				<cfif SESSION.eventDayID GT 0>
				<li><a href="event.cfm?change">Change Event</a></li>
				</cfif>
				<cfif SESSION.multiFlow AND NOT FindNoCase("event.cfm", CGI.SCRIPT_NAME)>
				<li><a href="flow.cfm?change">Change Brand or Survey</a></li>
				</cfif>
				<li><a href="index.cfm?logout">Logout</a></li>
			</ul>
		</cfif>

		<div id="wrapper">