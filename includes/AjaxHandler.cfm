<cffunction name="QueryToStruct" access="public" returntype="any" output="FALSE"
	hint="Converts an entire query or the given record to a struct. This might return a structure (single record) or an array of structures.">

<!--- 
	Link:
	http://www.bennadel.com/index.cfm?event=blog.view&id=149
 --->

	<!--- Define arguments. --->
	<cfargument name="Query" type="query" required="true" />
	<cfargument name="Row" type="numeric" required="false" default="0" />

	<cfscript>

		// Define the local scope.
		var LOCAL = StructNew();

		// Determine the indexes that we will need to loop over.
		// To do so, check to see if we are working with a given row,
		// or the whole record set.
		if (ARGUMENTS.Row){

			// We are only looping over one row.
			LOCAL.FromIndex = ARGUMENTS.Row;
			LOCAL.ToIndex = ARGUMENTS.Row;

		} else {

			// We are looping over the entire query.
			LOCAL.FromIndex = 1;
			LOCAL.ToIndex = ARGUMENTS.Query.RecordCount;

		}

		// Get the list of columns as an array and the column count.
		LOCAL.Columns = ListToArray( ARGUMENTS.Query.ColumnList );
		LOCAL.ColumnCount = ArrayLen( LOCAL.Columns );

		// Create an array to keep all the objects.
		LOCAL.DataArray = ArrayNew( 1 );

		// Loop over the rows to create a structure for each row.
		for (LOCAL.RowIndex = LOCAL.FromIndex ; LOCAL.RowIndex LTE LOCAL.ToIndex ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){

			// Create a new structure for this row.
			ArrayAppend( LOCAL.DataArray, StructNew() );

			// Get the index of the current data array object.
			LOCAL.DataArrayIndex = ArrayLen( LOCAL.DataArray );

			// Loop over the columns to set the structure values.
			for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE LOCAL.ColumnCount ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){

				// Get the column value.
				LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];

				// Set column value into the structure.
				LOCAL.DataArray[ LOCAL.DataArrayIndex ][ LOCAL.ColumnName ] = ARGUMENTS.Query[ LOCAL.ColumnName ][ LOCAL.RowIndex ];

			}

		}


		// At this point, we have an array of structure objects that
		// represent the rows in the query over the indexes that we
		// wanted to convert. If we did not want to convert a specific
		// record, return the array. If we wanted to convert a single
		// row, then return the just that STRUCTURE, not the array.
		if (ARGUMENTS.Row){

			// Return the first array item.
			return( LOCAL.DataArray[ 1 ] );

		} else {

			// Return the entire array.
			return( LOCAL.DataArray );

		}

	</cfscript>
</cffunction>



<cfparam name="FORM.method">
<cfset getComponent = "com.eshots.dbaccess.GetDataAccess">
<cfset setComponent = "com.eshots.dbaccess.SaveDataAccess">
<cfset json = createObject("component", "com.eshots.json") />


<cffunction name="pingUser" output="FALSE" returnformat="string">
	<cfargument name="userID" required="false" default="-1">

	<cfif userID GT 0 >
		<cfquery name="qryPingUser" datasource="efn" result="testRes">
			UPDATE efn_online_data_capture.User_Last_Seen
			SET last_seen_dtm = NOW()
			WHERE user_id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#ARGUMENTS.userID#">;
		</cfquery>
		<cfdump var="#testRes#">
	</cfif>

	<cfreturn TRUE />
</cffunction>



<cfset result = "">
<cfif structKeyExists(variables,FORM.method)>
	<cfinvoke method="#FORM.method#" returnvariable="result">
		<cfinvokeargument name="userID" value="#FORM.userID#">
	</cfinvoke>
<cfelse>
	<cfscript>
	userMsg = StructNew();
	StructInsert(userMsg, "error", 'Invalid method.');
	</cfscript>
	<cfset result = json.encode(userMsg)>
</cfif>

 <!--- Clear any previously generated output and output the result. --->
<cfsetting showdebugoutput="false">
<cfcontent reset="true"><cfoutput>#result#</cfoutput><cfabort>