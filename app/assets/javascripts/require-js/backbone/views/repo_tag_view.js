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
		template : $("#repo_tag_template").html(),
	
		render : function(){
			return $(this.el).html($.mustache(this.template, this.model.attributes));
		},
	
	});

});
	
