define(['jquery'], function($){

	/* UI responses */
	var methods = {
 		init : function(){

		},
		
	  submitting : function(){
	    $('#status-bar div.responding.active').remove();
	    $('#submitting').show();
	  },
 
	  respond : function(rsp){
	    var blah = { status: "bad", message: "There was a problem!"};
	    if (rsp && rsp.status) blah.status = rsp.status;
	    if (rsp && rsp.message) blah.message = rsp.message;

	    $('#submitting').hide();
	    $('div.responding.active').remove();
	    $('div.responding').hide().clone().addClass('active ' + blah.status).html(blah.message).show().insertAfter('div.responding');
			$("div.responding.active").fadeOut(4000);
	  },
 
	  fadeFlash : function(){
	    if ($("#flash_message").length > 0){
	      setTimeout( function() {
	        $("#flash_message").animate({'opacity': '-=1.0'}, 1000, function() {
	          $("#flash_message").hide();
	        });
	      }, 5000);
	    }
	  }
	}

  $.showStatus = function(method) {
    if ( methods[method] ) {
      return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      return methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.tooltip' );
    }    
  };

});