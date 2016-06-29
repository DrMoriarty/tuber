$(document).ready(function() {
	// time mask
	$.mask.definitions['H'] = '[012]';
	$.mask.definitions['M'] = '[012345]';
	$('.js-time-from, .js-time-to, .time_at, .time_to').mask('H9:M9');
	$('.js-time-from, .js-time-to').on('change keyup blur', function() {
		var val = $(this).parent().find('.js-time-from').val() + ' - ' + $(this).parent().find('.js-time-to').val();
		$(this).parent().siblings('.js-datetime').val(val);
	});
	
	// payments
	$('#paypal').change(function() {
		if ($(this).prop('checked')) {
			$('#wrap_hide').slideUp('fast');
			//$('#pay_form_button').attr('href', 'https://www.paypal.com').attr('target', '_blank');
		}
	});

	$('#card1, #card2').change(function() {
		if ($(this).prop('checked')) {
			$('#wrap_hide').slideDown('fast');
			//$('#pay_form_button').attr('href', 'Sender_dashboard_4.html').attr('target', '');
		}
        $('#cvv_code').unmask();
        $('#cvv_code').mask('999');
	});	
	$('#card3').change(function() {
		if ($(this).prop('checked')) {
			$('#wrap_hide').slideDown('fast');
			//$('#pay_form_button').attr('href', 'Sender_dashboard_4.html').attr('target', '');
		}
        $('#cvv_code').unmask();
        $('#cvv_code').mask('9999');
	});	
	
	// sticked block
	if ($('.js-tabs').length) {
		var delta = $('.js-tabs').offset().top;
		$(window).scroll(function() {
			if ($(window).scrollTop() >= delta - 30) {
				var newVal = $(window).scrollTop() - delta + 30;
				var maxVal = $('section.section').height() - $('.js-tabs').height() - 30;
				if (newVal > maxVal) {
					newVal = maxVal;
				}
				
				$('.js-tabs').css('margin-top', newVal);
			} else {
				$('.js-tabs').css('margin-top', 0);
			}
		});
	}

	
	// tabs
	$('.js-tabs li a').click(function() {
		$('.js-tabs li').removeClass('active');
		$(this).parent().addClass('active');
		
		var i = $('.js-tabs li a').index($(this));
		$('.js-tab-body').hide();
		$('.js-tab-body').eq(i).show();
		return false;
	});
	

	// form validation
	$('.js-validate').feelform({
		notificationType: 'class',
		validateOnTheFly: true,
		clearAfterSubmit: false
	});

	// accordion
	$('.js-accordion > li > p').hide();
	$('.js-accordion > li > span').click(function(){
		$(this).siblings().slideToggle('slow');
		$(this).find('i').toggleClass('active');
	});

	// date time
    /*
	$('.js-datetime-body').each(function() {
		var el = $(this);
		el.datepicker({
            minDate: 0,
            maxDate: "+1M",
			dateFormat: "dd MM yy",
			onSelect: function(text, e) {
				if (el.find('.time_at').length && el.find('.time_at').val() != '') {
					text += ', ' + el.find('.time_at').val();
					if (el.find('.time_to').length && el.find('.time_to').val() != '') {
						text += ' - ' + el.find('.time_to').val();
					}
				}
				
				el.siblings('.js-datetime').val(text);
				el.hide();
			}
		});
	});
    */

    /* global setting */
    var datepickersOpt = {
        dateFormat: 'dd MM yy',
        minDate   : 0,
        maxDate: "+1M"
    }

    $("#datePicker1").datepicker($.extend({
        onSelect: function(text, e) {
		    var el = $(this);
            var minDate = $(this).datepicker('getDate');
            minDate.setDate(minDate.getDate()+1);
            $("#datePicker2").datepicker( "option", "minDate", minDate);

			if (el.find('.time_at').length && el.find('.time_at').val() != '') {
				text += ', ' + el.find('.time_at').val();
				if (el.find('.time_to').length && el.find('.time_to').val() != '') {
					text += ' - ' + el.find('.time_to').val();
				}
			}
			
			el.siblings('.js-datetime').val(text);
			el.hide();
        }
    },datepickersOpt));
    

    $("#datePicker2").datepicker($.extend({
        onSelect: function(text, e) {
		    var el = $(this);
            var maxDate = $(this).datepicker('getDate');
            maxDate.setDate(maxDate.getDate()-1);
            $("#datePicker1").datepicker( "option", "maxDate", maxDate);

			if (el.find('.time_at').length && el.find('.time_at').val() != '') {
				text += ', ' + el.find('.time_at').val();
				if (el.find('.time_to').length && el.find('.time_to').val() != '') {
					text += ' - ' + el.find('.time_to').val();
				}
			}
			
			el.siblings('.js-datetime').val(text);
			el.hide();
        }
    },datepickersOpt));

	$('.js-datetime').click(function() {
		$('.js-datetime-body, .js-time-body').hide();
		$(this).siblings('.js-datetime-body, .js-time-body').show();
		return false;
	});

	$(document).click(function(e) {
		if ($(e.target).parents('.js-datetime-body, .js-time-body, .ui-datepicker-header').length == 0 
		&& $('.js-datetime-body:visible, .js-time-body:visible').length) {
			$('.js-datetime-body, .js-time-body').hide();
		}
	});

	// counters
	$('.up').click(function() {
		var newVal = (parseInt($(this).siblings('input').val()) || 0) + 1;
		$(this).siblings('input').val(newVal);
	});

	$('.down').click(function() {
		var newVal = (parseInt($(this).siblings('input').val()) || 0) - 1;
		if (newVal < 0) newVal = 0;
		$(this).siblings('input').val(newVal);
	});

    // filter for numbers
    $('input.numbers').keypress(function(event) {
        return /\d/.test(String.fromCharCode(event.keyCode));
    });

	// toggle hidden address
	$('.hidden_address1').hide();
	$('.js-toggle_address1').click(function() {
		$(this).toggleClass('active');
		if ($(this).find('i').text() == '+') {$(this).find('i').text('-'); } else {$(this).find('i').text('+')}
		$('.hidden_address1').slideToggle('slow');
		return false;
	});

	$('.hidden_address2').hide();
	$('.js-toggle_address2').click(function() {
		$(this).toggleClass('active');
		if ($(this).find('i').text() == '+') {$(this).find('i').text('-'); } else {$(this).find('i').text('+')}
		$('.hidden_address2').slideToggle('slow');
		return false;
	});

	// POPUP
	$('.want_popup').click(function() {
		$('#want_popup_box').bPopup({
			easing: 'easeOutBack', //uses jQuery easing plugin
		    speed: 450,
		    transition: 'slideDown'
		});
	    return false;
	});

	$('.cansel_order').click(function() {
		$('#cansel_box').bPopup({
			easing: 'easeOutBack',
			speed: 450,
			transition: 'slideDown'
		});
		return false;
	});

	$('#finished_box').bPopup({
		easing: 'easeOutBack',
		speed: 450,
		transition: 'slideDown'
	});

	// custom select
	if (!$.browser.msie || $.browser.version > 7) {
		$('.js-select').selectBoxIt();
	}
});


$(window).load(function() {
	// maps
	if ($('#map1').length) {
        /*
		var mapCanvas1 = document.getElementById('map1');
		var mapOptions1 = {
			center: new google.maps.LatLng(44.5403, -78.5463),
			zoom: 8,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			disableDefaultUI: true
		}
		var map1 = new google.maps.Map(mapCanvas1, mapOptions1);

		var mapCanvas2 = document.getElementById('map2');
		var mapOptions2 = {
			center: new google.maps.LatLng(48.5403, -79.5463),
			zoom: 8,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			disableDefaultUI: true
		}
		var map2 = new google.maps.Map(mapCanvas2, mapOptions2);

		var mapCanvas3 = document.getElementById('map3');
		var mapOptions3 = {
			center: new google.maps.LatLng(-33.897,150.099),
			zoom: 8,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		}
		var map3 = new google.maps.Map(mapCanvas3, mapOptions3);
		
		var rendererOptions = {map: map3};
		directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
		var point1 = new google.maps.LatLng(-33.8975098545041,151.09962701797485);
		var point2 = new google.maps.LatLng(-33.8584421519279,151.0693073272705);
		var point3 = new google.maps.LatLng(-33.87312358690301,151.99952697753906);
		var point4 = new google.maps.LatLng(-33.84525521656404,151.0421848297119);
		var wps = [{location:point1},{location:point2},{location:point4}];
		var org = new google.maps.LatLng(-33.89192157947345,151.13604068756104);
		var dest = new google.maps.LatLng(-33.69727974097957,150.29047966003418);
		var request = {
			origin: org,
			destination: dest,
			waypoints: wps,
			travelMode:google.maps.DirectionsTravelMode.DRIVING
		};
		directionsService = new google.maps.DirectionsService();
		directionsService.route(request,function(response, status){
			if (status == google.maps.DirectionsStatus.OK) {
				directionsDisplay.setDirections(response);
			}
		});
        */
	}
	//
    /*
	if ($('#map4').length) {
		var mapCanvas4 = document.getElementById('map4');
		var mapOptions4 = {
			center: new google.maps.LatLng(44.5403, -78.5463),
			zoom: 8,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		}
		var map4 = new google.maps.Map(mapCanvas4, mapOptions4);
	}	
    */
});

if (typeof String.prototype.trim !== 'function') {
	String.prototype.trim = function() {
		return this.replace(/^\s+|\s+$/g, ''); 
	}
}

if (!Array.prototype.indexOf) {
	Array.prototype.indexOf = function(obj, start) {
	     for (var i = (start || 0), j = this.length; i < j; i++) {
	         if (this[i] === obj) { return i; }
	     }
	     return -1;
	}
}
