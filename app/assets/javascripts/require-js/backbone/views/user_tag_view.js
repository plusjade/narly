define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
], function($, _, Backbone, z,z){
	
	// A singular tag view for the user tag list (usually on the right side column)
	//
 	return Backbone.View.extend({
		tagName : "li",
		template : $("#user_tag_template").html(),
	
		render: function(){
			return $(this.el).html($.mustache(this.template, this.model.attributes));
	  }
	
	});

});
	
