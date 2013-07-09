<cfif IsDefined('FORM.eshotsSUB') AND SESSION.userMsg EQ "">
	<cfif IsDefined('FORM.eshotsUN') AND TRIM(FORM.eshotsUN) EQ "" >
		<cfif TRIM(SESSION.userMsg) EQ "">
			<cfset SESSION.userMsg = "Please enter your Username">
		<cfelse>
			<cfset SESSION.userMsg = SESSION.userMsg & "<br />Please enter your Username">
		</cfif>
	</cfif>
	<cfif IsDefined('FORM.eshotsPW') AND TRIM(FORM.eshotsPW) EQ "" >
		<cfif TRIM(SESSION.userMsg) EQ "">
			<cfset SESSION.userMsg = "Please enter your Password">
		<cfelse>
			<cfset SESSION.userMsg = SESSION.userMsg & "<br />Please enter your Password">
		</cfif>
	</cfif>

	<cfif TRIM(SESSION.userMsg) EQ "">
		<cfquery name="qryUserValidation" datasource="#APPLICATION.read_dsn#">
			SELECT 	Users.user_ID
					, Users.sha1_password = SHA1(<cfqueryparam cfsqltype="cf_sql_varchar" list="false" value="#FORM.eshotsPW#">) as "valid"
					, auths.authorization_ID
					, Users.login_name
			FROM Users 
			LEFT JOIN R_User_Authorization auths ON auths.user_ID = Users.user_ID AND auths.authorization_ID = 17 
			WHERE login_name = <cfqueryparam cfsqltype="cf_sql_varchar" list="false" value="#FORM.eshotsUN#">  
		</cfquery>
		<cfif NOT qryUserValidation.recordCount>
			<cfif TRIM(SESSION.userMsg) EQ "">
				<cfset SESSION.userMsg = "User name does not exist.  Access denied">
			<cfelse>
				<cfset SESSION.userMsg = SESSION.userMsg & "<br />User name does not exist.  Access denied">
			</cfif>
		<cfelseif qryUserValidation.valid EQ 0>
			<cfif TRIM(SESSION.userMsg) EQ "">
			    <cfset SESSION.userMsg = "Invalid Password">
			<cfelse>
			    <cfset SESSION.userMsg = SESSION.userMsg & "<br />Invalid Password">
			</cfif>
		<cfelseif qryUserValidation.authorization_ID NEQ 17>
			<cfif TRIM(SESSION.userMsg) EQ "">
			    <cfset SESSION.userMsg = "Unable to grant access.  User not authorized">
			<cfelse>
			    <cfset SESSION.userMsg = SESSION.userMsg & "<br />Unable to grant access.  User not authorized">
			</cfif>
		<cfelse>
			<cfset SESSION.LoggedIn = TRUE >
			<cfset SESSION.userID = qryUserValidation.user_id >
			<cfset SESSION.userName = qryUserValidation.login_name>


			<cfquery name="qryGetUserLastSeen" datasource="#APPLICATION.dsn#">
				SELECT * 
				FROM efn_online_data_capture.User_Last_Seen 
				WHERE user_id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#qryUserValidation.user_ID#">
				AND last_seen_dtm > date_sub(now(), interval 30 second)
			</cfquery>
			<cfif qryGetUserLastSeen.RecordCount>
				<cfif TRIM(SESSION.userMsg) EQ "">
				    <cfset SESSION.userMsg = "User Already Logged In">
				<cfelse>
				    <cfset SESSION.userMsg = SESSION.userMsg & "<br />User Already Logged In">
				</cfif>
				<cfset SESSION.LoggedIn = FALSE >
				<cfset SESSION.userID = -1 >
				<cfset SESSION.userName = '' >
				<cflocation url="index.cfm" addtoken="false">
			<cfelse>
				<cfquery name="qrySetUserLastSeen" datasource="#APPLICATION.dsn#">
					INSERT INTO efn_online_data_capture.User_Last_Seen
					(user_ID, last_seen_dtm) 
					VALUES (<cfqueryparam cfsqltype="cf_sql_bigint" value="#qryUserValidation.user_ID#">, NOW())
					ON DUPLICATE KEY UPDATE last_seen_dtm = NOW()
				</cfquery>
			</cfif>


			<cfquery name="qryAssociadtedCLID" datasource="#APPLICATION.read_dsn#">
				SELECT DISTINCT EL.client_license_ID
				FROM R_User_Reporting_Group RUPG
				JOIN Reporting_Groups RG ON RUPG.reporting_group_id = RG.reporting_group_ID
				JOIN Event_Locations EL on RG.client_license_ID = EL.client_license_ID
				JOIN R_Event_Location_Activity_Type RELAT on RELAT.event_location_ID = EL.event_location_ID
				WHERE TRUE
				AND RUPG.user_id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#qryUserValidation.user_ID#">
				AND RELAT.activity_type_ID = 67 
			</cfquery>	
			<cfset SESSION.availClientLicenseID = #ValueList(qryAssociadtedCLID.client_license_ID)#>
			<!--- this is being done to route the user to where they should end up, based on values available. --->
			<cfset OnRequestStart('campaign.cfm')>
		</cfif>
	</cfif>
</cfif>


<cfinclude template="includes/inc_header.cfm">

	<div id="content">
       	<p><h1>Welcome to eshots Online Data Capture</h1></p>
		<p>&nbsp;</p>
		<p><h1 id="bad-browser" class="error" style="display: none;">Your browser may not be supported, best viewed in IE7+, Firefox3+ or Google Chrome.</h1></p>
		<cfif IsDefined('SESSION.userMsg') AND TRIM(SESSION.userMsg) NEQ ""><p><h1 class="<cfoutput>#SESSION.msgclass#</cfoutput>"><cfoutput>#SESSION.userMsg#</cfoutput></h1></p></cfif>
		<cfoutput>
		<form action="https://eshots.com#CGI.SCRIPT_NAME#" id="index" method="POST">
			<label for="eshotsUN">Username: </label><input type="input" name="eshotsUN" id="eshotsUN" placeholder="email@domain.com" /><br />
			<label for="eshotsPW">Password: </label><input type="password" name="eshotsPW" id="eshotsPW" placeholder="Secure password" /><br /><br />
			<label for="eshotsSUB">&nbsp; </label><input type="submit" name="eshotsSUB" id="eshotsSUB" value="Login" />
		</form>
		</cfoutput>
	</div><!-- closes content -->

<cfinclude template="includes/inc_footer.cfm">
