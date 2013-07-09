<cfcomponent displayname="Application" output="true" hint="Handle the application.">

	<!--- Set up the application. --->
	<cfset THIS.Name = "Online_Data_Capture2" />
	<cfset THIS.ApplicationTimeout = CreateTimeSpan( 0, 12, 0, 0 ) />
	<cfset THIS.SessionManagement = TRUE />
	<cfset THIS.SessionTimeout = CreateTimeSpan( 0, 0, 0, 31 ) />
	<cfset THIS.SetClientCookies = TRUE />
	<cfset THIS.ScriptProtect = TRUE />


	<!--- Define the page request properties. --->
	<cfsetting requesttimeout="30" showdebugoutput="false" enablecfoutputonly="false" />


	<cffunction name="OnApplicationStart" access="public" returntype="boolean" output="false" hint="Fires when the application is first created.">
		<!--- Clear Application struct before each initialization --->
		<cfset StructClear(APPLICATION)>
		<cfif IsDefined('SESSION')>
			<cfset StructClear(SESSION)>
		</cfif>

		<cfset APPLICATION.dsn = "efn">
		<cfset APPLICATION.read_dsn = "efn_readonly">

		<cfset APPLICATION.setComponent = "com.eshots.dbaccess.SaveDataAccess">
		<cfset APPLICATION.getComponent = "com.eshots.dbaccess.GetDataAccess">
		<cfset APPLICATION.activity_type_id = 67>

		<!--- This was used when implementing an AJAX solution. --->
		<cfset APPLICATION.setupHandler = "includes/AjaxHandler.cfm">

		<cfreturn true />
	</cffunction>


	<cffunction name="OnSessionStart" access="public" returntype="void" output="false" hint="Fires when the session is first created.">

		<cfif IsDefined('SESSION.userID') AND SESSION.userID GT 0>
			<cfquery name="qrySetUserLastSeen" datasource="#APPLICATION.dsn#">
				DELETE FROM efn_online_data_capture.User_Last_Seen
				WHERE user_id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#SESSION.userID#">;
			</cfquery>
		</cfif>

		<cfset StructClear(SESSION)>
		<cfset SESSION.debug = FALSE>
		<cfset SESSION.LoggedIn = FALSE>
		<cfset SESSION.userID = -1>
		<cfset SESSION.userName = ''>
		<cfset SESSION.userMsg = ''>
		<cfset SESSION.msgClass = 'error'>
		<cfset SESSION.availClientLicenseID = -1>
		<cfset SESSION.clientLicenseID = -1>
		<cfset SESSION.eventDayID = -1>
		<cfset SESSION.multiFlow = FALSE>
		<cfset SESSION.brandID = -1>
		<cfset SESSION.dataRELAT = -1>

		<!--- COOKIE TEST --->
		<cfcookie name="test" value="Accepts cookies">
		<!--- CHECK FOR COOKIE FOR THE COOKIE TEST--->
		<cfif IsDefined('COOKIE.test')>
			<cfif COOKIE.test EQ "Accepts cookies">
				<cfset COOKIE.cookiesEnabled = TRUE>
			<cfelse>
				<cfset COOKIE.cookiesEnabled = FALSE>
			</cfif>
		<cfelse>
			<cfset COOKIE.cookiesEnabled = FALSE>
		</cfif>

		<cfreturn />
	</cffunction>


	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="false" hint="Fires at first part of page processing.">
		<cfargument name="TargetPage" type="string" required="true" />

		<!--- Keep them in the right place --->
		<cfif NOT FindNoCase("index.cfm", CGI.SCRIPT_NAME)
		  AND NOT FindNoCase("campaign.cfm", CGI.SCRIPT_NAME)
		  AND NOT FindNoCase("error.cfm", CGI.SCRIPT_NAME)
		  AND NOT FindNoCase("event.cfm", CGI.SCRIPT_NAME)
		  AND NOT FindNoCase("flow.cfm", CGI.SCRIPT_NAME)
		  AND NOT FindNoCase("survey.cfm", CGI.SCRIPT_NAME)
		  AND NOT FindNoCase("humans.txt", CGI.SCRIPT_NAME)
		  AND NOT FindNoCase("robots.txt", CGI.SCRIPT_NAME)
		  AND NOT FindNoCase("/includes/", CGI.SCRIPT_NAME) >
			<cfset OnSessionStart() >
			<cflocation url="index.cfm" addtoken="false">
		</cfif>


		<!--- URL Controls --->
		<cfif structKeyExists(URL,'resetApp')>
			<cfset OnApplicationStart() />
			<cfset OnSessionStart() />
			<cfif IsDefined('Cookie')>
				<cfset StructClear(Cookie)>
			</cfif>
		</cfif>
		<!--- Reset Session --->
		<cfif structKeyExists(URL,'resetSession') OR structKeyExists(URL,'logout')>
			<cfset OnSessionStart() />
			<cfset SESSION.userMsg = 'You have successfully been logged out'>
			<cfset SESSION.msgClass = 'success'>
		</cfif>
		<!--- Reset Cookie --->
		<cfif structKeyExists(URL,'resetCookie')>
			<cfif IsDefined('Cookie')>
				<cfset StructClear(Cookie)>
			</cfif>
		</cfif>
		<!--- Debugging Flag --->
		<cfif IsDefined('URL.debug')>
			<cfset SESSION.debug = URL.debug>
		</cfif>
		<cfif FindNoCase("campaign.cfm", CGI.SCRIPT_NAME) AND structKeyExists(URL,'change')>
			<cfset SESSION.clientLicenseID = -1>
			<cfset SESSION.brandID = -1>
			<cfset SESSION.datarelat = -1>
			<cfset SESSION.eventDayID = -1>
		</cfif>
		<cfif FindNoCase("event.cfm", CGI.SCRIPT_NAME) AND structKeyExists(URL,'change')>
			<cfset SESSION.eventDayID = -1>
		</cfif>
		<cfif FindNoCase("flow.cfm", CGI.SCRIPT_NAME) AND structKeyExists(URL,'change')>
			<cfset SESSION.brandID = -1>
			<cfset SESSION.dataRELAT = -1>
		</cfif>
		<cfif structKeyExists(URL,'ajax')>
			<cfset filterUser = FALSE >
		<cfelse>
			<cfset filterUser = TRUE >
		</cfif>


		<!--- Cookie check --->
		<cfif not structKeyExists(COOKIE, "cookiesEnabled")>
			<cfif TRIM(SESSION.userMsg) EQ "">
				<cfset SESSION.userMsg = "This site requires the use of cookies, please enable and <a href='https://eshots.com/webentry/index.cfm?logout'>click here</a> to continue">
			<cfelse>
				<cfset SESSION.userMsg = SESSION.userMsg & "<br />This site requires the use of cookies, please enable and <a href='https://eshots.com/webentry/index.cfm?logout'>click here</a> to continue">
			</cfif>
		</cfif>


		<cfif filterUser>
			<!--- User enforcement --->
			<cfif NOT FindNoCase("index.cfm", CGI.SCRIPT_NAME) AND (NOT IsDefined('SESSION.LoggedIn') OR NOT SESSION.LoggedIn)>
				<cfset OnSessionStart() >
				<cflocation url="index.cfm" addtoken="false">
			</cfif>

			<cfquery name="qryGetUserLastSeen" datasource="#APPLICATION.dsn#">
				SELECT last_seen_dtm > DATE_SUB(NOW(), INTERVAL 30 SECOND) AS "Fresh"
				FROM efn_online_data_capture.User_Last_Seen
				WHERE user_id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#SESSION.userID#">
				LIMIT 1
			</cfquery>

			<cfif NOT FindNoCase("index.cfm", CGI.SCRIPT_NAME)
				  AND (NOT qryGetUserLastSeen.RecordCount
				  OR NOT qryGetUserLastSeen.Fresh) >
				<cfquery name="qryClearUser" datasource="#APPLICATION.dsn#">
					DELETE FROM efn_online_data_capture.User_Last_Seen
					WHERE user_id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#SESSION.userID#">
				</cfquery>
				<cfmail to="jmiller@eshots.com" from="error@eshots.com" subject="ERROR from Online Data Capture" type="HTML">
					The error happened with user = #SESSION.userID#<br />
				</cfmail>
				<cfset OnSessionStart() >
				<cfset SESSION.userMsg = 'Your session has expired'>
				<cflocation url="index.cfm" addtoken="false">
			</cfif>

			<cfif NOT FindNoCase("index.cfm", CGI.SCRIPT_NAME)
				  AND SESSION.userID GT 0 >
				<cfquery name="qryUserValidation" datasource="#APPLICATION.read_dsn#">
					SELECT 	Users.user_ID
							, auths.authorization_ID
					FROM Users
					LEFT JOIN R_User_Authorization auths ON auths.user_ID = Users.user_ID AND auths.authorization_ID = 17
					WHERE Users.user_ID = <cfqueryparam cfsqltype="cf_sql_varchar" list="false" value="#SESSION.userID#">
				</cfquery>
				<cfif NOT FindNoCase("index.cfm", CGI.SCRIPT_NAME)
					  AND qryUserValidation.authorization_ID NEQ 17 >
					<cfif TRIM(SESSION.userMsg) EQ "">
						<cfset OnSessionStart() >
						<cfset SESSION.userMsg = "Unable to grant access.  User not authorized">
					<cfelse>
						<cfset SESSION.userMsg = SESSION.userMsg & "<br />Unable to grant access.  User not authorized">
					</cfif>
					<cflocation url="index.cfm" addtoken="false">
				</cfif>
			</cfif>



			<cfif IsDefined('SESSION.LoggedIn') AND SESSION.LoggedIn AND NOT FindNoCase("AjaxHandler.cfm", CGI.SCRIPT_NAME)>
				<!--- User is logged in, begin to figure out where to send the user --->
				<cfif ListLen(SESSION.availClientLicenseID) EQ 0 OR SESSION.availClientLicenseID EQ -1>
					<!--- Error, no client licenses available --->
					<cfset OnSessionStart() />
					<cfif TRIM(SESSION.userMsg) EQ "">
						<cfset SESSION.userMsg = "Unable to grant access.  User not assigned to any events">
					<cfelse>
						<cfset SESSION.userMsg = SESSION.userMsg & "<br />Unable to grant access.  User not assigned to any events">
					</cfif>
					<cfif NOT FindNoCase("index.cfm", CGI.SCRIPT_NAME)>
						<cflocation url="index.cfm" addtoken="false">
					</cfif>
				<cfelseif ListLen(SESSION.availClientLicenseID) GT 1 AND SESSION.clientLicenseID LTE 0>
					<cfif NOT FindNoCase("campaign.cfm", CGI.SCRIPT_NAME)>
						<cflocation url="campaign.cfm" addtoken="false">
					</cfif>
				<cfelse>
					<cfif SESSION.clientLicenseID LTE 0 AND ListLen(SESSION.availClientLicenseID) EQ 1 >
						<cfset SESSION.clientLicenseID = ListGetAt(SESSION.availClientLicenseID,1)>
					</cfif>

					<cfif SESSION.clientLicenseID LTE 0>
						<!--- Error, no client license --->
					<cfelse>
						<cfif SESSION.eventDayID LTE 0 >
							<cfif NOT FindNoCase("event.cfm", CGI.SCRIPT_NAME)>
								<cflocation url="event.cfm" addtoken="false">
							</cfif>
						<cfelse>
							<cfinvoke component="#APPLICATION.getComponent#" method="GetClientLicenseDetailsWithBrands" returnvariable="qryCampaignDetails">
								<cfinvokeargument name="clientLicenseID" value="#SESSION.clientLicenseID#">
							</cfinvoke>
							<cfif SESSION.dataRELAT GT 0>
								<cfif NOT FindNoCase("survey.cfm", CGI.SCRIPT_NAME)>
									<cflocation url="survey.cfm" addtoken="false">
								</cfif>
							<cfelseif ListLen(qryCampaignDetails.brands) EQ 1 >
								<cfset SESSION.brandID = ListGetAt(qryCampaignDetails.brands,1)>
								<cfquery name="avalableFlows" datasource="efn" result="res">
									SELECT	RELAT.r_elat_ID, Flows.flow_ID, Flows.survey_ID, Flows.name
									FROM	R_Event_Location_Activity_Type RELAT
									JOIN 	Event_Locations EL ON RELAT.event_location_id = EL.event_location_id
									JOIN 	R_ELAT_Flow ON R_ELAT_Flow.r_elat_id = RELAT.r_elat_id
									JOIN 	Flows ON Flows.flow_id = R_ELAT_Flow.flow_id
									WHERE	RELAT.activity_type_ID = <cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#APPLICATION.activity_type_ID#">
										AND EL.client_license_id = <cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#SESSION.clientLicenseID#">
										AND EL.brand_id = <cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#SESSION.brandID#">
								</cfquery>
								<cfif avalableFlows.RecordCount EQ 1>
									<cfset SESSION.dataRELAT = avalableFlows.r_elat_id >
									<cflocation url="survey.cfm" addtoken="false">
								<cfelseif avalableFlows.RecordCount GT 1>
									<cfset SESSION.multiFlow = TRUE>
									<cfif NOT FindNoCase("flow.cfm", CGI.SCRIPT_NAME)>
										<cflocation url="flow.cfm" addtoken="false">
									</cfif>
								<cfelse>
									<cfset SESSION.userMsg = "This Campaign's Brand is Setup Incorrectly, please contact your account manager">
									<cfif NOT FindNoCase("flow.cfm", CGI.SCRIPT_NAME)>
										<cflocation url="flow.cfm" addtoken="false">
									</cfif>
								</cfif>
							<cfelse>
								<cfset SESSION.multiFlow = TRUE>
								<cfif NOT FindNoCase("flow.cfm", CGI.SCRIPT_NAME)>
									<cflocation url="flow.cfm" addtoken="false">
								</cfif>
							</cfif>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfif>


		<cfreturn true />
	</cffunction>


	<cffunction name="OnRequest" access="public" returntype="void" output="true" hint="Fires after pre page processing is complete.">
		<cfargument name="TargetPage" type="string" required="true" />

		<!--- Include the requested page. --->
		<cfinclude template="#ARGUMENTS.TargetPage#" />

		<cfreturn />
	</cffunction>


	<cffunction name="OnRequestEnd" access="public" returntype="void" output="true" hint="Fires after the page processing is complete.">

		<cfset SESSION.userMsg = "">
		<cfset SESSION.msgClass = 'error'>

		<cfreturn />
	</cffunction>


	<cffunction name="OnSessionEnd" access="public" returntype="void" output="false" hint="Fires when the session is terminated.">
		<cfargument name="SessionScope" type="struct" required="true" />
		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />

		<cfif IsDefined('SESSION')>
			<cfset StructClear(SESSION)>
		</cfif>

		<cfset SESSION.userMsg = 'Your session has expired'>

		<cfreturn />
	</cffunction>


	<cffunction name="OnApplicationEnd" access="public" returntype="void" output="false" hint="Fires when the application is terminated.">
		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />

		<cfif IsDefined('SESSION')>
			<cfset StructClear(SESSION)>
		</cfif>
		<cfif IsDefined('APPLICATION')>
			<cfset StructClear(APPLICATION)>
		</cfif>

		<cfreturn />
	</cffunction>


	<cffunction name="OnError" access="public" returntype="void" output="true" hint="Fires when an exception occures that is not caught by a try/catch.">
		<cfargument name="Exception" type="any" required="true" />
		<cfargument name="EventName" type="string" required="false" default="" />

		<cfif IsDefined('ARGUMENTS.Exception.RootCause.Message') AND ARGUMENTS.Exception.RootCause.Message NEQ "">
			<cfmail to="errors@eshots.com" from="error@eshots.com" subject="ERROR from Online Data Capture" type="HTML">
				<cfdump var="#Exception#">
				<cfdump var="#EventName#">
			</cfmail>
		</cfif>


		<cfreturn />
	</cffunction>

</cfcomponent>
