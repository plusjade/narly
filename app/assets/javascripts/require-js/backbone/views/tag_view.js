define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'app'
], function($, _, Backbone, z,z, App){
	
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
			this.model.add(App.mainTagPanelView.model);
		},
		remove : function(){
			this.model.remove(App.mainTagPanelView.model);
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
	
	