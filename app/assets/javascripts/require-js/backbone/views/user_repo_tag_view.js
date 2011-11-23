define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
], function($, _, Backbone, z,z){
	
	// This tag view holds all tag templates.
	//
 	return Backbone.View.extend({
		tagName : "li",
		template : $("#user_repo_tag_template").html(),
	
		events : {
			"click .danger" : "remove",
		},

		remove : function(e){
			this.model.remove();
			
			e.preventDefault();
			return false;
		},
	
		render: function(){
			return $(this.el).html($.mustache(this.template, this.model.attributes));
	  },

	});

});
	
