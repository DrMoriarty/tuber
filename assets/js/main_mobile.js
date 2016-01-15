$(document).ready(function() {

	$('.burger').click(function() {
		$('.burger_nav').slideToggle();
	});

	// time mask
	$.mask.definitions['H'] = '[012]';
	$.mask.definitions['M'] = '[012345]';
	$('.js-time-from, .js-time-to, .time_at, .time_to').mask('H9:M9');
	$('.js-time-from, .js-time-to').on('change keyup blur', function() {
		var val = $(this).parent().find('.js-time-from').val() + ' - ' + $(this).parent().find('.js-time-to').val();
		$(this).parent().siblings('.js-datetime').val(val);
	});

	$('.form-sizes input').mask('9?99');
	
	// payments
	$('#paypal').change(function() {
		if ($(this).prop('checked')) {
			$('#wrap_hide').slideUp('fast');
			$('#pay_form_button').attr('href', 'https://www.paypal.com').attr('target', '_blank');
		}
	});

	$('#card1, #card2, #card3').change(function() {
		if ($(this).prop('checked')) {
			$('#wrap_hide').slideDown('fast');
		}
	});	

	$('.defolt-check').click(function() {
		if ($("#card2").prop('checked')) {
			$('#card2').prop('checked', false);
			$('#wrap_hide').slideUp('fast');
			$('#pay_form_button').attr('href', 'https://www.paypal.com').attr('target', '_blank');
		} else {
			$('#card2').prop('checked', true);
			$('#wrap_hide').slideDown('fast');
		}
		return false;
	});

	$('.paypal_check').click(function() {
		if ($("#paypal").prop('checked')) {
			$('#paypal').prop('checked', false);
			$('#wrap_hide').slideDown('fast');
		} else {
			$('#paypal').prop('checked', true);
			$('#wrap_hide').slideUp('fast');
			$('#pay_form_button').attr('href', 'https://www.paypal.com').attr('target', '_blank');
		}
		return false;
	});

	
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
		clearAfterSubmit: true,
		validateHidden: false
	});

	// accordion
	$('.js-accordion > li > p').hide();
	$('.js-accordion > li > span').click(function(){
		$(this).siblings().slideToggle('slow');
		$(this).find('i').toggleClass('active');
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

	// toggle hidden address
	$('.hidden_address1').hide();
	$('.js-toggle_address1').click(function() {
		$(this).toggleClass('active');
		if ($(this).find('i').text() == '+') {$(this).find('i').text('-'); } else {$(this).find('i').text('+')}
		$('.hidden_address1').slideToggle('slow');
		if($(this).hasClass('active')){
			$('#address').prop('checked', false);
		}
		return false;
	});

	$('.hidden_address2').hide();
	$('.js-toggle_address2').click(function() {
		$(this).toggleClass('active');
		if ($(this).find('i').text() == '+') {$(this).find('i').text('-'); } else {$(this).find('i').text('+')}
		$('.hidden_address2').slideToggle('slow');
		if($(this).hasClass('active')){
			$('#address1').prop('checked', false);
		}
		return false;
	});
	$('#address').change(function() {
		if($(this).prop('checked')) {
			$('.js-toggle_address1').removeClass('active');
			$('.hidden_address1').slideUp('slow');
			$('.js-toggle_address1 i').text('+');
		}

	});
	$('#address1').change(function() {
		if($(this).prop('checked')) {
			$('.js-toggle_address2').removeClass('active');
			$('.hidden_address2').slideUp('slow');
			$('.js-toggle_address2 i').text('+');
		}

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

	// placeholders for DATA inputs
	$('.pl1').focus(function() {
		$('.placeholder1').hide();
	});

	$('.pl2').focus(function() {
		$('.placeholder2').hide();
	});

	// select value from selectboxit
	var selectBox1 = $('.js-select1').selectBoxIt().data('selectBox-selectBoxIt');
	$('.postbox').click(function() {selectBox1.selectOption('Postbox Bremen friedrich missler str.,1');});
	$('.home-adress').click(function() {selectBox1.selectOption('Home Bremen friedrich missler str.,1');});
	$('.post-office').click(function() {selectBox1.selectOption('office Bremen friedrich missler str.,1');});

	var selectBox2 = $('.js-select2').selectBoxIt().data('selectBox-selectBoxIt');
	$('.postboxs').click(function() {selectBox2.selectOption('Postbox Hamburg, Niedergeorgswerder Deich 73, 4');});
	$('.home-adresss').click(function() {selectBox2.selectOption('Home Hamburg, Niedergeorgswerder Deich 73, 4');});
	$('.post-offices').click(function() {selectBox2.selectOption('office Hamburg, Niedergeorgswerder Deich 73, 4');});

});


$(window).load(function() {
	// maps
    /*
	if ($('#map1').length) {
		var mapCanvas1 = document.getElementById('map1');
		var mapOptions1 = {
			center: new google.maps.LatLng(44.5403, -78.5463),
			zoom: 8,
			scrollwheel: false,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			disableDefaultUI: true
		}
		var map1 = new google.maps.Map(mapCanvas1, mapOptions1);

		var mapCanvas2 = document.getElementById('map2');
		var mapOptions2 = {
			center: new google.maps.LatLng(48.5403, -79.5463),
			zoom: 8,
			scrollwheel: false,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			disableDefaultUI: true
		}
		var map2 = new google.maps.Map(mapCanvas2, mapOptions2);

		var mapCanvas3 = document.getElementById('map3');
		var mapOptions3 = {
			center: new google.maps.LatLng(-33.897,150.099),
			scrollwheel: false,
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
	}
	//
	if ($('#map4').length) {
		var mapCanvas4 = document.getElementById('map4');
		var mapOptions4 = {
			center: new google.maps.LatLng(44.5403, -78.5463),
			zoom: 8,
			scrollwheel: false,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		}
		var map4 = new google.maps.Map(mapCanvas4, mapOptions4);
	}	
    */
});
