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

function addTab(travelDate, fromCode, toCode) {
	var tabs = $( "#tabs" ).tabs({ active: 2 }),
			tabTitle = moment(travelDate).format("MMM Do YY")
			li = '<li><a href="#tabs-' + travelDate + '" data-date="' +
			travelDate + '" data-from="' + fromCode + '" data-to="' + toCode + '">' +
			tabTitle + '</a></li>',
	    id = "tabs-" + travelDate;

  tabs.find( ".ui-tabs-nav" ).append( li );
  tabs.append( "<div id='" + id + "'><ul class='flight-id selectable'></ul></div>" );
  tabs.tabs( "refresh" );
}

function removeTabs(){
	$( "#tabs" ).find("ul").children().each(function(){
		var panelId = $(this).attr( "aria-controls" );
		$( "#tabs" ).find("#" + panelId).remove();

		$( "#tabs" ).find(".ui-tabs-nav li:eq(0)").remove();
		$("#tabs").tabs( "refresh" );
	});
}

function validFields(travelDate, fromDate, toDate) {
	if (travelDate == null || travelDate == "" ||
				fromDate == null || fromDate   == "" ||
				toDate   == null || toDate     == "") {
		alert("There are empty fields.");
		return false;
	}

	if (moment(travelDate).isBefore(moment().subtract(1, 'days'))) {
		alert("Date can't be past.");
		return false;
	}

	return true;
}

function getFlights(travelDate, fromDate, toDate) {
	var request = $.ajax({
		url: "/search",
		method: "GET",
		data: { date: travelDate,
						from: fromDate,
						to: toDate },
		dataType: "html"
	});

	request.done(function( json ) {
		var flights = JSON.parse(json);
		var count = 1;
		$.each(flights, function(key, flight){
					var date = moment(flight.start.dateTime).format(DATE_FORMAT);
					$("#tabs-" + date + " ul").append('<li id=' + count + ' class="item-content">'+
							"<p>Airline: " + flight.airline.name + " </p>" +
							"<p>Start: " + " " +
							flight.start.cityName + ", " +
							flight.start.countryName + " - " +
							flight.start.airportName + "  " +
							"At: " + moment(flight.start.dateTime).format("ddd, MMM Do YY, h:mm a") + " </p>" +
							"<p>Finish: " + " " +
							flight.finish.cityName + ", " +
							flight.finish.countryName + " - " +
							flight.finish.airportName + "  " +
							"At: " + moment(flight.finish.dateTime).format("ddd, MMM Do YY, h:mm a") + " </p>" +
					'</li>');
					count++;
			});
	});

	request.fail(function( jqXHR, textStatus ) {
		alert( "Request failed: " + textStatus );
	});
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
	    ajaxStop: function()  { $body.removeClass("loading"); }
	});

	$("#search").click(function(){
		removeTabs();

		var travelDate = $( "#travel-date" );
		var fromDate   = $( "#autocomplete-from" );
		var toDate     = $( "#autocomplete-to" );

		if (!validFields(travelDate.val(), fromDate.val(), toDate.val())) {
			return;
		}

		try {
			// Extract airport code from the input
			var fromCode = fromDate.val().split("(")[1].substring(0, 3);
			var toCode = toDate.val().split("(")[1].substring(0, 3);
		} catch (e) {
			alert("Please insert a correct location.");
			return;
		}

		// Get Range of dates and create tabs
		$.each(getDates(travelDate.val()), function(key, date){
			addTab(date, fromCode, toCode);
		});

		// Search for flights using ajax
		getFlights(travelDate.val(), fromCode, toCode);
  });

	// Search flights for a specific tab
	$(document).on('click', '.ui-tabs-anchor', function(event){
		var date = $(this).data("date");
		var results = $("#tabs-" + date).find("ul").children().length;
		if (results == 0) {
			getFlights(date, $(this).data("from"), $(this).data("to"));
		}
  });

	// Select a flight from the list
	$(document).on('click', "ul[class*=flight-id] li",function () {
		$('ul.flight-id li').removeClass('item-highlight');
		$(this).addClass('item-highlight');
	});
})
