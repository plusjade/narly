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
		template : $("#repo_tag_panel_template").html(),
	
		events : {
			"click .success" : "add",
		},
	
		add : function(e){
			this.model.add();
			
			e.preventDefault();
			return false;
		},
	
		render : function(){
			return $(this.el).html($.mustache(this.template, this.model.attributes));
		},
	
	});

});
	
