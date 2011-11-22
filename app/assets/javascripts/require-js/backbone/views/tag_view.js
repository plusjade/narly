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
		repoTagTmpl : $("#tagTemplateAdd").html(),
		userRepoTagTmpl : $("#tagTemplateRemove").html(),
		userTagTmpl : $("#tagTemplateRemove").html(),
	
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
	
		renderRepoTag : function(){
			return $(this.el).html($.mustache(this.repoTagTmpl, this.model.attributes));
		},
	
		renderUserRepoTag: function(){
			return $(this.el).html($.mustache(this.userRepoTagTmpl, this.model.attributes));
	  },
	
		renderUserTag: function(){
			return $(this.el).html($.mustache(this.userTagTmpl, this.model.attributes));
	  }
	
	});

});
	
	