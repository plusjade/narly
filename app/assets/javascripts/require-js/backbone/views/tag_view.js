define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache'
], function($, _, Backbone){
	
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
	
		add : function(){
			this.model.add(MainTagPanelView.model, CurrentUser);
		},
		remove : function(){
			this.model.remove(MainTagPanelView.model, CurrentUser);
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
	
	