define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
], function($, _, Backbone, z,z){
	
	// This tag view holds all tag templates.
	//
	TagView = Backbone.View.extend({
		tagName : "li",
		communityTmpl : $("#tagTemplateAdd").html(),
		personalTmpl : $("#tagTemplateRemove").html(),
	
		events : {
			"click .success" : "add",
			"click .danger" : "remove",
		},
	
		add : function(e){
			this.model.add();
			
			e.preventDefault();
			return false;
		},
		remove : function(e){
			this.model.remove();
			
			e.preventDefault();
			return false;
		},
	
		renderCommunity : function(){
			return $(this.el).html($.mustache(this.communityTmpl, this.model.attributes));
		},
	
		renderPersonal: function(){
			return $(this.el).html($.mustache(this.personalTmpl, this.model.attributes));
	   }
	});

	return TagView;
});
	
	