<cfinclude template='/udf/CreateEventToken.cfm'>

<!--- Production value <cfquery name="qryFlowQuestions" datasource="#APPLICATION.read_dsn#" result="res"> --->
<cfquery name="qryFlowQuestions" datasource="#APPLICATION.read_dsn#" result="res">
	SELECT DISTINCT Flows.name as "Flow"
					, Questions.*
					, RQDE.data_element_id
					, R_Page_Question.required_flag
					, CL.name AS "Campaign"
					, DE.data_element_type_id
					, B.name AS "Brand"
	FROM Event_Locations 
	JOIN R_Event_Location_Activity_Type ON Event_Locations.event_location_ID = R_Event_Location_Activity_Type.event_location_ID 
	JOIN R_ELAT_Flow ON R_Event_Location_Activity_Type.r_elat_ID = R_ELAT_Flow.r_elat_ID
	JOIN Flows ON R_ELAT_Flow.flow_ID = Flows.flow_ID
	JOIN R_Flow_Group ON Flows.flow_ID = R_Flow_Group.flow_ID 
	JOIN R_Group_Page ON R_Flow_Group.group_ID = R_Group_Page.group_ID 
	JOIN R_Page_Question ON R_Page_Question.page_ID = R_Group_Page.page_ID 
	JOIN Questions ON R_Page_Question.question_ID = Questions.question_ID
	JOIN R_Question_Data_Element RQDE ON Questions.question_id = RQDE.question_id
	JOIN Client_Licenses CL ON Event_Locations.client_license_id = CL.client_license_id 
	JOIN Data_Elements DE ON RQDE.data_element_id = DE.data_element_id 
	JOIN Brands B ON Event_Locations.brand_id = B.brand_id
	WHERE	R_Event_Location_Activity_Type.r_elat_id = <cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#SESSION.dataRELAT#">
		AND Event_Locations.client_license_id = <cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#SESSION.clientLicenseID#">
		AND Event_Locations.brand_id = <cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#SESSION.brandID#">
	ORDER BY R_ELAT_Flow.order_number
			,R_Flow_Group.order_number
			,R_Group_Page.order_number
			,R_Page_Question.order_number
</cfquery>


<cfif IsDefined('FORM.frmAction') AND FORM.frmAction NEQ ''>
	<cfset SESSION.userMsg = "">
	<cfset msgClass = "success">

	<cfset atLeastOneDE = FALSE >

	<cfloop query="qryFlowQuestions">
		<cfif StructKeyExists(FORM,#data_element_ID#)>
			<cfset answer = evaluate('FORM.#data_element_ID#')>
		</cfif>
		
		<!--- First, make sure that at least one answer is not empty. --->
		<cfif IsDefined('answer') AND Trim(answer) NEQ "" AND NOT atLeastOneDE>
			<cfset atLeastOneDE = TRUE >
		</cfif>
		<cfif required_flag>
			<!--- Validate the answer based on validation_type_ID --->
		</cfif>
	</cfloop>

	<cfif msgClass EQ "success" AND atLeastOneDE>
		<!--- Create a consumer --->
		<cftransaction>
			<cfquery name="insConsumerID" datasource="#APPLICATION.dsn#">
				INSERT INTO efn.Consumers (create_DTM) 
				VALUES (NOW());
			</cfquery>
			<cfquery name="qryConsumerID_insert" datasource="#APPLICATION.dsn#">
				SELECT LAST_INSERT_ID() id
			</cfquery> 
	
			<cfset newConsID = qryConsumerID_insert.id>
			<cfset newEventToken = CreateEventToken(newConsID, "O") />
	
			<cfquery name="insRCET" datasource="#APPLICATION.dsn#" result="res">
				INSERT INTO efn.R_Consumer_Event_Token (consumer_ID, event_token_ID, create_DTM) 
				VALUES (#newConsID#, '#newEventToken#', NOW());
			</cfquery>
		</cftransaction>
		<!--- End create consumer --->


		<!--- Insert data footprint --->
		<cfinvoke component="#APPLICATION.setComponent#" method="insertFootprint" returnvariable="dataFootprint">
	 		<cfinvokeargument name="event_token_ID" value="#newEventToken#">
	 		<cfinvokeargument name="r_elat_ID" value="#SESSION.dataRELAT#">
	 		<cfinvokeargument name="event_day_ID" value="#SESSION.eventDayID#">
	 		<cfinvokeargument name="client_license_ID" value="#SESSION.clientLicenseID#">
	 		<cfinvokeargument name="system_ID" value="101">
	 		<cfif SESSION.debug>
		 		<cfinvokeargument name="sample_flag" value="1">
	 		<cfelse>
		 		<cfinvokeargument name="sample_flag" value="0">
			</cfif>
	 		<cfinvokeargument name="ip_address" value="#CGI.REMOTE_ADDR#">
	 		<cfinvokeargument name="record_multiple" value="FALSE">
		</cfinvoke>

		<cfloop list="#FORM.fieldNames#" index="oneDE">
			<cfif IsNumeric(oneDE)>
				<cfif StructKeyExists(FORM,#oneDE#)>
					<cfset answer = evaluate('FORM.#oneDE#')>
				</cfif>
	
				<cfquery name="questionType" dbtype="query">
					SELECT data_element_type_id 
					FROM qryFlowQuestions 
					WHERE data_element_id = #oneDE#
				</cfquery>
	
				<cfif TRIM("#evaluate('FORM.#oneDE#')#") NEQ "">
					<cfloop list="#evaluate('FORM.#oneDE#')#" index="oneAns">
						<cfinvoke component="#APPLICATION.setComponent#" method="insertConsumerAnswer" returnvariable="insertSuccess">
					 		<cfinvokeargument name="consumer_ID" value="#newConsID#">
					 		<cfinvokeargument name="data_element_ID" value="#oneDE#">
					 		<cfinvokeargument name="footprint_ID" value="#dataFootprint#">
							<cfif questionType.data_element_type_id EQ 1>
						 		<cfinvokeargument name="answer_ID" value="#oneAns#">
						 	<cfelse>
								<cfinvokeargument name="answer_text" value="#oneAns#">
							</cfif>
					 	</cfinvoke>
					 </cfloop>
			 	</cfif>
			</cfif>
		</cfloop>
		<cfquery name="qryInsertReporting" datasource="#APPLICATION.dsn#">
			INSERT INTO efn_online_data_capture.R_User_Footprint
			(user_ID, footprint_ID) 
			VALUES (#SESSION.userID#, #dataFootprint#)
		</cfquery>

		<cfset SESSION.userMsg = "Consumer Successfully Added">

		<cfif FORM.frmAction EQ "logout">
			<cflocation url="index.cfm?logout">
		</cfif>
	<cfelseif NOT atLeastOneDE>
		<cfset msgClass = "error">
		<cfset SESSION.userMsg = "All fields submitted blank, no consumer added.">
	</cfif>
</cfif>


<cfquery name="qryAllToday" datasource="#APPLICATION.dsn#">
	SELECT COUNT(DISTINCT event_token_id) AS Consumers
	FROM Footprints F 
	JOIN efn_online_data_capture.R_User_Footprint RUF ON RUF.footprint_ID = F.footprint_ID 
	WHERE RUF.user_ID = #SESSION.userID#
	AND F.create_DTM > CURDATE()
</cfquery>
<cfquery name="qryFlowToday" datasource="#APPLICATION.dsn#">
	SELECT COUNT(DISTINCT event_token_id) AS Consumers
	FROM Footprints F 
	JOIN efn_online_data_capture.R_User_Footprint RUF ON RUF.footprint_ID = F.footprint_ID 
	WHERE RUF.user_ID = #SESSION.userID#
	AND F.create_DTM > CURDATE()
	AND F.r_elat_ID = #SESSION.dataRELAT#
</cfquery>
<cfquery name="qryEventInfo" datasource="#APPLICATION.read_dsn#">
	SELECT E.name AS "Event", ED.event_date AS "Event_Date" 
	FROM Events E 
	JOIN Event_Days ED ON E.event_id = ED.event_id 
	WHERE ED.event_day_id = #SESSION.eventDayID#
	LIMIT 1
</cfquery>


<cfinclude template="includes/inc_header.cfm">
	<div id="content">
		<cfif IsDefined('SESSION.userMsg') AND TRIM(SESSION.userMsg) NEQ ""><p><h1 class="<cfoutput>#msgClass#</cfoutput>"><cfoutput>#SESSION.userMsg#</cfoutput></h1></p></cfif>
       	<p><h2><cfoutput>#qryFlowQuestions.Brand# - #qryFlowQuestions.Campaign# - #qryFlowQuestions.Flow# - #qryEventInfo.Event#</h2>
		<h2>For data collected on</i> #DateFormat(qryEventInfo.Event_Date, "Medium" )#</cfoutput></h2></p>
		<p id="reporting"><cfoutput>
			<cfif IsDefined('SESSION.userName')>#SESSION.userName# has<cfelse>You have</cfif> entered:<br />
			<strong>#qryAllToday.Consumers#</strong> Consumers Engaged for this Campaign today<br />
			<strong>#qryFlowToday.Consumers#</strong> consumers for this Survey today
		</cfoutput></p>
		<p>&nbsp;</p>
		<form action="<cfoutput>#CGI.SCRIPT_NAME#</cfoutput>" id="survey" method="POST">
			<div id="contact">
				<cfset inContactForm = true>
				<cfset contactFormCount = 0>
				<cfset lstContactInfo="2,4,5,6,7,8,9,10,11,21,59,161">
				<table id="tblContact">
				<tr>
			<cfloop query="qryFlowQuestions">

			<!--- Required SPAN tag construction --->
			<cfif required_flag GT 0>
				<span class='required'>*&nbsp;</span>
			<cfelse>
				&nbsp;&nbsp;&nbsp;
			</cfif>

			<cfswitch expression="#ANSWER_LAYOUT_ID#">
				<cfcase value="1"> <!--- This case is text questions --->
					<cfif inContactForm EQ true>
						<td>
					</cfif>
					<cfswitch expression="#DATA_ELEMENT_ID#">
						<cfcase value="10">
							<cfinvoke component="includes/QuestionDisplay" method="displayStates">
							<cfinvokeargument name="label" value="#NAME#">
								<cfinvokeargument name="inputName" value="#DATA_ELEMENT_ID#">
							</cfinvoke>
						</cfcase>
						<cfcase value="4">
							<cfinvoke component="includes/QuestionDisplay" method="displayEmail">
								<cfinvokeargument name="label" value="#NAME#">
								<cfinvokeargument name="inputName" value="#DATA_ELEMENT_ID#">
							</cfinvoke>
						</cfcase>
						<cfdefaultcase>
							<cfinvoke component="includes/QuestionDisplay" method="displayInput">
								<cfinvokeargument name="label" value="#NAME#">
								<cfinvokeargument name="inputName" value="#DATA_ELEMENT_ID#">
		<!--- 
								<cfif IsDefined('FORM.#DATA_ELEMENT_ID#')>
									<cfinvokeargument name="value" value="evaluate('FORM.#DATA_ELEMENT_ID#')">
								</cfif>
		--->
							</cfinvoke>
						</cfdefaultcase>
					</cfswitch>
					<cfif inContactForm EQ true>
						</td>
					</cfif>
				</cfcase>
			 	<cfcase value="2"> <!--- This case is radio questions --->
			 		<cfif inContactForm EQ true>
				 		<cfif ListFind(lstContactInfo,#DATA_ELEMENT_ID#) EQ 0>
					 		<cfset inContactForm = false>
					 		</tr>
							</table>
							</div>
					 	</cfif>
						<td>
					</cfif>
					<cfinvoke component="includes/QuestionDisplay" method="displayDropDown">
						<cfinvokeargument name="label" value="#NAME#">
						<cfinvokeargument name="inputName" value="#DATA_ELEMENT_ID#">
						<cfinvokeargument name="questionID" value="#QUESTION_ID#">
					</cfinvoke>
					<cfif inContactForm EQ true>
						</td>
					</cfif>
				</cfcase>
				<cfcase value="10"> <!--- This case is checkbox questions --->
					<cfif inContactForm EQ true>
						</tr>
						</table>
						</div>
					</cfif>
					<cfset inContactForm = false>
					<cfinvoke component="includes/QuestionDisplay" method="displayCheckbox">
						<cfinvokeargument name="label" value="#NAME#">
						<cfinvokeargument name="inputName" value="#DATA_ELEMENT_ID#">
						<cfinvokeargument name="questionID" value="#QUESTION_ID#">
					</cfinvoke>
				</cfcase>
				<cfdefaultcase>
					I don't know what this is...<cfoutput>#ANSWER_LAYOUT_ID#</cfoutput><br /><br />
				</cfdefaultcase>
			</cfswitch>
			<cfif inContactForm EQ true>
				<cfset contactFormCount = contactFormCount + 1 >
				<cfif contactFormCount EQ 3><!--- TODO: If you change this number, you have to update styles.css.  specifically: #tblContact td { width: [1/<<number of columns>>*100]% }--->
					</tr>
					<tr>
					<cfset contactFormCount =  0>
				</cfif>
			</cfif>
			</cfloop>
			<input type="hidden" id="frmAction" name="frmAction" value="">
			<label for="campaignSUB">&nbsp;</label><input type="button" name="campaignSUB" id="campaignSUB" value="Save &amp; Add Another" />
			<label for="saveExit">&nbsp;</label><input type="button" name="saveExit" id="saveExit" value="Save &amp; Exit Web Form Entry" />
		</form>
	</div><!-- closes content -->


<cfinclude template="includes/inc_footer.cfm">