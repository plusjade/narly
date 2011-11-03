/* UI responses */
;var showStatus = {
  
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
    setTimeout('$("div.responding.active").fadeOut(4000)', 1900);    
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