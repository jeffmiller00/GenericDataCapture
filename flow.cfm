<cfquery name="avalableFlows" datasource="#APPLICATION.read_dsn#" result="res">
	SELECT	relat.r_elat_ID, EL.brand_id, Flows.*
	FROM	R_Event_Location_Activity_Type relat
	JOIN 	Event_Locations EL ON relat.event_location_id = EL.event_location_id
	JOIN 	R_ELAT_Flow ON R_ELAT_Flow.r_elat_id = relat.r_elat_id 
	JOIN 	Flows ON Flows.flow_id = R_ELAT_Flow.flow_id 
	WHERE	relat.activity_type_ID = <cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#APPLICATION.activity_type_ID#">
		AND EL.client_license_id = <cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#SESSION.clientLicenseID#">
</cfquery>


<cfif IsDefined('FORM.relat') AND FORM.relat GT 0>
	<cfquery name="getBrand" datasource="#APPLICATION.read_dsn#">
		SELECT brand_id 
		FROM Event_Locations EL 
		JOIN R_Event_Location_Activity_Type RELAT ON EL.event_location_id = RELAT.event_location_id
		WHERE RELAT.r_elat_id = <cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#FORM.relat#">
	</cfquery>
	<cfset SESSION.brandID = getBrand.brand_id >
	<cfset SESSION.dataRELAT = FORM.relat >
	<cfset OnRequestStart('survey.cfm')>
</cfif>


<cfinclude template="includes/inc_header.cfm">

	<div id="content">
		<cfif IsDefined('SESSION.userMsg') AND TRIM(SESSION.userMsg) NEQ ""><p><h1 class="error"><cfoutput>#SESSION.userMsg#</cfoutput></h1></p></cfif>
       	<p><h2>Please select your brand and survey:</h2></p>
		<p>&nbsp;</p>
		<cfoutput>
		<form action="#CGI.SCRIPT_NAME#" id="brand" method="POST">
			<select name="relat" id="relat">
				<option value="-1">--- Please select your brand and survey ---</option>
				<cfloop query="avalableFlows">
					<cfinvoke component="#APPLICATION.getComponent#" method="GetBrandDetails" returnvariable="qryBrandDetails">
						<cfinvokeargument name="brandID" value="#brand_id#">
					</cfinvoke>
					<option value="#r_elat_ID#" <cfif IsDefined('FORM.relat') AND FORM.relat EQ r_elat_ID>selected</cfif> >#qryBrandDetails.name# | #name#</option>
				</cfloop>
			</select><br />
			<!--- <label for="eshotsSUB">&nbsp; </label><input type="submit" name="campaignSUB" id="eshotsSUB" value="Continue" /> --->
		</form>

		</cfoutput>
	</div><!-- closes content -->

<cfinclude template="includes/inc_footer.cfm">