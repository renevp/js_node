$(document).ready(function(){

	$('ul.tabs li').click(function(){
		var tab_id = $(this).attr('data-tab');

		$('ul.tabs li').removeClass('current');
		$('.tab-content').removeClass('current');

		$(this).addClass('current');
		$("#"+tab_id).addClass('current');
	})

  $( "#autocomplete-from" ).autocomplete({
    source: function( request, response ) {
			$.get("/locations", {
            q: request.term
        }, function (data) {
            response(data);
        });
    },
    minLength: 3
  } );

	$( "#autocomplete-to" ).autocomplete({
    source: function( request, response ) {
			$.get("/locations", {
            q: request.term
        }, function (data) {
            response(data);
        });
    },
    minLength: 3
  } );

	$( "#travel-date" ).datepicker({ dateFormat: 'yy-mm-dd' });

	$("ul[class*=myid] li").click(function () {
	    $('ul.myid li').removeClass('item-highlight');
	    $(this).addClass('item-highlight');
	});

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
			var flights = JSON.parse(json);
			$(".container ul li").text($( "#travel-date" ).val());
			$.each(flights, function(key, flight){
            $("#tab-1 ul").append('<li class="item-content">'+
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
