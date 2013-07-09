$(function(){


	<!--- Browser check --->
	var badBrowser=false;
	// Check browser: webkit, safari, opera, msie, mozilla
	if ((!jQuery.browser.webkit) && (!jQuery.browser.chrome) && (!jQuery.browser.safari) && (!jQuery.browser.opera) && (!jQuery.browser.msie) && (!jQuery.browser.mozilla)) {
		badBrowser=true;
	} else { // check version
		if (jQuery.browser.msie && jQuery.browser.version<'7.0') {
			badBrowser=true;
		} else if (jQuery.browser.mozilla && jQuery.browser.version<'1.9') {
			badBrowser=true;
		}
	}

	if (badBrowser) {
		$('#bad-browser').show();
	}


	$('#campaign input').click(function(){
		$('#campaign').submit();
	});

	$('#event select').change(function(){
		$('#event').submit();
	});

	$('#eventDay select').change(function(){
		$('#eventDay').submit();
	});

	$('#brand select').change(function(){
		$('#brand').submit();
	});

	$('#campaignSUB').click(function(){
		$('#frmAction').val('save');
		$('#campaignSUB').attr("disabled", "disabled");
		$('#saveExit').attr("disabled", "disabled");
		$('#survey').submit();
	});

	$('#saveExit').click(function(){
		$('#frmAction').val('logout');
		$('#campaignSUB').attr("disabled", "disabled");
		$('#saveExit').attr("disabled", "disabled");
		$('#survey').submit();
	});


	<cfif IsDefined('SESSION.userID') AND SESSION.userID GT 0>

	var interval='';

	function stop_ping() {
		if (interval!="") {
			window.clearInterval(interval);
			interval="";
		}
	}


	function start_ping() {
		if (interval=="") {
			interval=window.setInterval(pingDTM,5000);
		} else {
			stop_ping();
		}
	}


	function pingDTM() {
		$.ajax({
			cache: false,
			type: 'POST',
			url: 'https://eshots.com/webentry/includes/AjaxHandler.cfm',
			timeout: 4000,
			data: ({ method: 'pingUser',
				 	 userID: '<cfoutput>#SESSION.userID#</cfoutput>',
				 	 ajax:   'TRUE' }),
			success: function(response) {
//				alert(response);
			}
		});
	}

	start_ping();

	var session_timeout = 30 * 60 * 1000; // In milliseconds;

	setTimeout(function () {
		alert("Your session will expire in 30 seconds.");
	}, session_timeout - 30000);

	setTimeout(function () {
		window.location = "/webentry/?logout";
	}, session_timeout);

	</cfif>
});
