<cfcomponent hint="This CFC will display questions" output="true">

	<cffunction name="displayInput" access="public" output="true" returntype="void">
		<cfargument name="label" type="string" required="true" />
		<cfargument name="inputName" type="string" required="true" />
		<cfargument name="value" type="string" required="false" default="" />

		<cfoutput>
		<label for="#ARGUMENTS.inputName#">#ARGUMENTS.label#
			<cfif ARGUMENTS.inputName EQ 11> (i.e. 555-555-5555)</cfif>
		</label><input type="input" name="#ARGUMENTS.inputName#" id="#ARGUMENTS.inputName#" placeholder="" value="#ARGUMENTS.value#"/><br />
		</cfoutput>

		<cfreturn />
	</cffunction>

	<cffunction name="displayRadio" access="public" output="true" returntype="void">
		<cfargument name="label" type="string" required="true" />
		<cfargument name="inputName" type="string" required="true" />
		<cfargument name="questionID" type="numeric" required="true" />

 		<cfquery name="getAnswers" datasource="#APPLICATION.read_dsn#">
			SELECT a.name, a.answer_id
			FROM R_Data_Element_Answer rdea
			JOIN Answers a USING (answer_id)
			WHERE question_id=#ARGUMENTS.questionID# 
			AND a.answer_id <> 417 
			ORDER BY order_number
		</cfquery>

		<cfoutput>
		<label for="#ARGUMENTS.inputName#">#ARGUMENTS.label#</label>
		<ul>
		<cfloop query="getAnswers">
			<li>
				<input type='radio' id='#ARGUMENTS.inputName##CurrentRow#' name='#ARGUMENTS.inputName#'  value='#getAnswers.answer_id#' />
				#getAnswers.name#
		</cfloop>
		</ul><br />
		</cfoutput>

		<cfreturn />
	</cffunction>
	
	<cffunction name="displayDropDown" access="public" output="true" returntype="void">
		<cfargument name="label" type="string" required="true" />
		<cfargument name="inputName" type="string" required="true" />
		<cfargument name="questionID" type="numeric" required="true" />

 		<cfquery name="getAnswers" datasource="#APPLICATION.read_dsn#">
			SELECT a.name, a.answer_id
			FROM R_Data_Element_Answer rdea
			JOIN Answers a USING (answer_id)
			WHERE question_id=#ARGUMENTS.questionID# 
			AND a.answer_id <> 417 
			ORDER BY order_number
		</cfquery>

		<cfoutput>
		<label for="#ARGUMENTS.inputName#">#ARGUMENTS.label#</label>
		<select name="#ARGUMENTS.inputName#" id="#ARGUMENTS.inputName#">
			<option id="#ARGUMENTS.inputName#NoSelection" name='NoSelection' value=''>- Select One -</option>
		<cfloop query="getAnswers">
			<option id='#ARGUMENTS.inputName##CurrentRow#' name='#ARGUMENTS.inputName#'  value='#getAnswers.answer_id#' >#getAnswers.name#</option>
		</cfloop>
		</select><br />
		</cfoutput>

		<cfreturn />
	</cffunction>

	<cffunction name="displayCheckbox" access="public" output="true" returntype="void">
		<cfargument name="label" type="string" required="true" />
		<cfargument name="inputName" type="string" required="true" />
		<cfargument name="questionID" type="numeric" required="true" />

 		<cfquery name="getAnswers" datasource="#APPLICATION.read_dsn#">
			SELECT a.name, a.answer_id
			FROM R_Data_Element_Answer rdea
			JOIN Answers a USING (answer_id)
			WHERE question_id=#ARGUMENTS.questionID# 
			AND a.answer_id <> 417 
			ORDER BY order_number
		</cfquery>

		<cfoutput>
		<label for="#ARGUMENTS.inputName#">#ARGUMENTS.label#</label>
		<ul>
		<cfloop query="getAnswers">
			<li>
				<input type='checkbox' id='#ARGUMENTS.inputName##CurrentRow#' name='#ARGUMENTS.inputName#'  value='#getAnswers.answer_id#' />
				#getAnswers.name#
		</cfloop>
		</ul><br />
		</cfoutput>

		<cfreturn />
	</cffunction>
	
	<cffunction name="displayStates" access="public" output="true" returntype="void">
		<cfargument name="label" type="string" required="true" />
		<cfargument name="inputName" type="string" required="true">
		<cfoutput>
			<label for="#ARGUMENTS.inputName#">#ARGUMENTS.label#</label>
			<select name="#ARGUMENTS.inputName#" size="1">
				<option value=""></option>
				<optgroup label="US">
				<option value="AK">AK</option>
				<option value="AL">AL</option>
				<option value="AR">AR</option>
				<option value="AZ">AZ</option>
				<option value="CA">CA</option>
				<option value="CO">CO</option>
				<option value="CT">CT</option>
				<option value="DC">DC</option>
				<option value="DE">DE</option>
				<option value="FL">FL</option>
				<option value="GA">GA</option>
				<option value="HI">HI</option>
				<option value="IA">IA</option>
				<option value="ID">ID</option>
				<option value="IL">IL</option>
				<option value="IN">IN</option>
				<option value="KS">KS</option>
				<option value="KY">KY</option>
				<option value="LA">LA</option>
				<option value="MA">MA</option>
				<option value="MD">MD</option>
				<option value="ME">ME</option>
				<option value="MI">MI</option>
				<option value="MN">MN</option>
				<option value="MO">MO</option>
				<option value="MS">MS</option>
				<option value="MT">MT</option>
				<option value="NC">NC</option>
				<option value="ND">ND</option>
				<option value="NE">NE</option>
				<option value="NH">NH</option>
				<option value="NJ">NJ</option>
				<option value="NM">NM</option>
				<option value="NV">NV</option>
				<option value="NY">NY</option>
				<option value="OH">OH</option>
				<option value="OK">OK</option>
				<option value="OR">OR</option>
				<option value="PA">PA</option>
				<option value="RI">RI</option>
				<option value="SC">SC</option>
				<option value="SD">SD</option>
				<option value="TN">TN</option>
				<option value="TX">TX</option>
				<option value="UT">UT</option>
				<option value="VA">VA</option>
				<option value="VT">VT</option>
				<option value="WA">WA</option>
				<option value="WI">WI</option>
				<option value="WV">WV</option>
				<option value="WY">WY</option>
				</optgroup>
<!--- 
				<optgroup label="Canada">
				<option value="AB">AB</option>
				<option value="BC">BC</option>
				<option value="MB">MB</option>
				<option value="NB">NB</option>
				<option value="NL">NL</option>
				<option value="NT">NT</option>
				<option value="NS">NS</option>
				<option value="NU">NU</option>
				<option value="ON">ON</option>
				<option value="PE">PE</option>
				<option value="QC">QC</option>
				<option value="SK">SK</option>
				<option value="YT">YT</option>
				</optgroup>
--->
			</select><br />
		</cfoutput>
	</cffunction>

	<cffunction name="displayEmail" access="public" output="true" returntype="void">
		<cfargument name="label" type="string" required="true" />
		<cfargument name="inputName" type="string" required="true" />
		<cfargument name="value" type="string" required="false" default="" />

		<cfoutput>
			<label for="#ARGUMENTS.inputName#">#ARGUMENTS.label#</label>
			<input type="input" name="#ARGUMENTS.inputName#" id="#ARGUMENTS.inputName#" placeholder="" value="#ARGUMENTS.value#"/><br />
	
			<script type="text/javascript">
				$("###ARGUMENTS.inputName#").change(function(){
					if ($("###ARGUMENTS.inputName#").val().length > 0){
						if (!validateEmail($("###ARGUMENTS.inputName#").val())){
							alert("Invalid email address format.  Please try again.");
							$("###ARGUMENTS.inputName#").focus();
						}
					}
				});
				function validateEmail($email) {
					var emailReg = /^[a-zA-Z0-9-_'\+~]+(\.[a-zA-Z0-9-'\+~]+)*@([a-zA-Z_0-9-]+\.)+[a-zA-Z]{2,7}$/;
					if( !emailReg.test( $email ) ) {
						return false;
					} else {
						return true;
					}
				}
			</script>
		</cfoutput>
	</cffunction>
	
</cfcomponent>