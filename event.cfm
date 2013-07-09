<cfif IsDefined('FORM.eventDayID') AND eventDayID GT 0>
	<cfset SESSION.eventDayID = FORM.eventDayID>
	<!--- this is being done to route the user to where they should end up, based on values available. --->
	<cfset OnRequestStart('flow.cfm')>
</cfif>


<cfinvoke component="#APPLICATION.getComponent#" method="GetEvents" returnvariable="qryEvents">
	<cfinvokeargument name="clientLicenseID" value="#SESSION.clientLicenseID#">
</cfinvoke>
<cfif IsDefined('FORM.eventID') AND FORM.eventID GT 0>
	<cfinvoke component="#APPLICATION.getComponent#" method="GetEventDaysByEventID" returnvariable="qryEventDays" >
		<cfinvokeargument name="eventID" value="#FORM.eventID#">
		<cfinvokeargument name="includeCancelled" value="FALSE">
	</cfinvoke>
</cfif>


<cfinclude template="includes/inc_header.cfm">

	<div id="content">
       	<p><h2>Please select your event and date:</h2></p>
		<p>&nbsp;</p>
		<cfoutput>
		<form action="#CGI.SCRIPT_NAME#" id="event" method="POST">
			<select name="eventID" id="eventID">
				<option value="-1">--- Please select your event ---</option>
				<cfloop query="qryEvents">
					<cfquery name="hasEventDays" datasource="#APPLICATION.read_dsn#">
						SELECT * 
						FROM Event_Days 
						WHERE TRUE 
						  AND event_cancellation_ID IS NULL 
						  AND event_id = #event_id# 
						  AND event_date <= NOW()
						  LIMIT 1
					</cfquery>
					<cfif hasEventDays.RecordCount AND (SESSION.debug OR (NOT FindNoCase("Default",TRIM(name)) AND NOT FindNoCase("TEST EVENT",TRIM(name)) AND NOT FindNoCase("DO NOT USE",TRIM(name))))>
						<option value="#event_id#" <cfif IsDefined('FORM.eventID') AND FORM.eventID EQ event_id>selected</cfif> >#name#</option>
					</cfif>						
				</cfloop>
			</select><br />
			<!--- <label for="eshotsSUB">&nbsp; </label><input type="submit" name="campaignSUB" id="eshotsSUB" value="Continue" /> --->
		</form>


		<cfif IsDefined('FORM.eventID') AND FORM.eventID GT 0>
		<form action="#CGI.SCRIPT_NAME#" id="eventDay" method="POST">
			<select name="eventDayID" id="eventDayID">
				<option value="-1">--- Please select your event date ---</option>
				<cfloop query="qryEventDays">
					<cfif DateCompare('#event_date#', NOW()) LTE 0 >
					<option value="#event_day_id#" <cfif IsDefined('FORM.eventDayID') AND FORM.eventDayID EQ event_day_id>selected</cfif> >#DateFormat(event_date, "Medium" )#</option>
					</cfif>
				</cfloop>
			</select><br />
			<!--- <label for="eshotsSUB">&nbsp; </label><input type="submit" name="campaignSUB" id="eshotsSUB" value="Continue" /> --->
		</form>
		</cfif>

		</cfoutput>
	</div><!-- closes content -->

<cfinclude template="includes/inc_footer.cfm">