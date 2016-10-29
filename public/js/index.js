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

	$("button").click(function(){

		var request = $.ajax({
		  url: "/search",
		  method: "GET",
		  data: { date : $( "#travel-date" ).val(),
			 				from: $( "#autocomplete-from" ).val().split("(")[1].substring(0, 3),
							to: $( "#autocomplete-to" ).val().split("(")[1].substring(0, 3) },
		  dataType: "html"
		});

		request.done(function( json ) {
			var travelDate = $( "#travel-date" ).val();
			var tabCounter = 1;
			$.each(getDates(travelDate), function(key, date){
				var tabTitle = date,
			      tabTemplate = '<li><a href="#tabs-'+date+'">'+date+'</a></li>';
				var tabs = $( "#tabs" ).tabs();
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
		});

		request.fail(function( jqXHR, textStatus ) {
		  alert( "Request failed: " + textStatus );
		});
  });

})
