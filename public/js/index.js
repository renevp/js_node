const RANGE_TYPE = 'days';
const RANGE_NUMBER = 2;
const DATE_FORMAT = 'Y-M-DD';

function getDates(travelDate){
	var dates = [];
	if (RANGE_NUMBER == 0) {
		dates.push(travelDate);
		return dates;
	}

	var start = moment(travelDate).subtract(RANGE_NUMBER, RANGE_TYPE);
  var finish = moment(travelDate).add(RANGE_NUMBER + 1, RANGE_TYPE);

	while (moment(start).isBefore(finish)) {
		dates.push(start.format(DATE_FORMAT));
		start = moment(start).add(1, 'days');
	}

  return dates;

}

function addTab(tabTitle, tabTemplate, tabCounter, tabs) {
  var label = tabTitle || "Tab " + tabCounter,
    id = "tabs-" + tabCounter,
    li = tabTemplate;

  tabs.find( ".ui-tabs-nav" ).append( li );
  tabs.append( "<div id='" + id + "'><ul></ul></div>" );
  tabs.tabs( "refresh" );
}

function validInputs(travelDate, fromDate, toDate) {
	if (travelDate == null || travelDate == "" ||
				fromDate == null || fromDate == "" ||
				toDate == null || toDate == "") {
		alert("Can't be empty fields.");
		return false;
	}

	if (moment(travelDate).isBefore(moment().subtract(1, 'days'))) {
		alert("Date can't be past.");
		return false;
	}

	return true;
}

$(document).ready(function(){

  $( "#autocomplete-from" ).autocomplete({
    source: function( request, response ) {
			$.get("/locations", {
            q: request.term
        }, function (data) {
            response(data);
        });
    },
    minLength: 2
  } );

	$( "#autocomplete-to" ).autocomplete({
    source: function( request, response ) {
			$.get("/locations", {
            q: request.term
        }, function (data) {
            response(data);
        });
    },
    minLength: 2
  } );

	$( "#travel-date" ).datepicker({ dateFormat: 'yy-mm-dd' });

	var $body = $("body");

	$(document).on({
	    ajaxStart: function() { $body.addClass("loading");    },
	     ajaxStop: function() { $body.removeClass("loading"); }
	});


	$("button").click(function(){
		var flag = false;
		$( "#tabs" ).find("ul").children().each(function(){
			var panelId = $(this).attr( "aria-controls" );
			$( "#tabs" ).find("#"+ panelId).remove();

			var tabIndex = $(this).attr( "tabindex" );
			$( "#tabs" ).find(".ui-tabs-nav li:eq(" + tabIndex + ")").remove();

			$("#tabs").tabs( "refresh" );
			flag = true;
		});

		// if (flag) {
		// 	return;
		// }

		var tabs = $( "#tabs" ).tabs();

		var travelDate = $( "#travel-date" );
		var fromDate = $( "#autocomplete-from" );
		var toDate = $( "#autocomplete-to" );

		if (!validInputs(travelDate.val(), fromDate.val(), toDate.val())) {
			return;
		}

		var request = $.ajax({
		  url: "/search_test",
		  method: "GET",
		  data: { date : travelDate.val(),
			 				from: fromDate.val().split("(")[1].substring(0, 3),
							to: toDate.val().split("(")[1].substring(0, 3) },
		  dataType: "html"
		});

		request.done(function( json ) {
			var tabCounter = 1;
			$.each(getDates(travelDate), function(key, date){
				var tabTitle = date,
			      tabTemplate = '<li><a href="#tabs-'+date+'">'+date+'</a></li>';

				addTab(tabTitle, tabTemplate, date, tabs);
				tabCounter++;
			});

			var flights = JSON.parse(json);
			$.each(flights, function(key, flight){
						var date = moment(flight.start.dateTime).format(DATE_FORMAT);
            $("#tabs-"+date+" ul").append('<li class="item-content">'+
																			"Airline: " + flight.airline.name + " " +
																			"Start: " + " " +
																			flight.start.cityName + ", " +
																			flight.start.countryName + " - " +
																			flight.start.airportName + "  " +
																			"At: " + moment(flight.start.dateTime).format("dddd, MMMM Do YYYY, h:mm:ss a") + " " +
																			"Finish: " + " " +
																			flight.finish.cityName + ", " +
																			flight.finish.countryName + " - " +
																			flight.finish.airportName + "  " +
																			"At: " + moment(flight.finish.dateTime).format("dddd, MMMM Do YYYY, h:mm:ss a") + " " +
																	'</li>');
        });
			travelDate.val("");
			fromDate.val("");
			toDate.val("");
		});

		request.fail(function( jqXHR, textStatus ) {
		  alert( "Request failed: " + textStatus );
		});
  });

})
