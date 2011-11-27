define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/user_icon'
], function($, _, Backbone, z,z, UserIcon){
	
	// A view for a user icon.
	//
 	return Backbone.View.extend({
		model : UserIcon,
		tagName : "a",
		template : $("#user_icon_template").html(),
	
		render: function(){
			return $(this.el)
				.attr("href", "/users/" + this.model.get("login"))
				.html($.mustache(this.template, this.model.attributes));
	  }
	
	});

});
	
