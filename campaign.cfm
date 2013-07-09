<cfparam name="userMsg" default="">

<cfif IsDefined('FORM.campaignID') AND userMsg EQ "">
	<cfset SESSION.clientLicenseID = FORM.campaignID>
	<cflocation url="event.cfm" addtoken="false">
</cfif>


<cfinclude template="includes/inc_header.cfm">

	<div id="content">
       	<p><h2>Please select your campaign:</h2></p>
		<p>&nbsp;</p>
		<cfoutput>
		<form action="#CGI.SCRIPT_NAME#" id="campaign" method="POST">
			<cfloop list="#SESSION.availClientLicenseID#" index="clID">
				<cfinvoke component="#APPLICATION.getComponent#" method="GetClientLicenseDetails" returnvariable="campaignDetails">
					<cfinvokeargument name="clientLicenseID" value="#clID#">
				</cfinvoke>
				<input type="radio" name="campaignID" value="#campaignDetails.client_license_id#" /><label for="campaignID">#campaignDetails.name#</label><br />
			</cfloop><br />
			<!--- <label for="eshotsSUB">&nbsp; </label><input type="submit" name="campaignSUB" id="eshotsSUB" value="Continue" /> --->
		</form>
		</cfoutput>
	</div><!-- closes content -->

<cfinclude template="includes/inc_footer.cfm">