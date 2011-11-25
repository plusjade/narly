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
   
    events : {
			"click a" : "clickTag"
		},
			
		render : function(){
			var data = this.model.attributes;
			data.url = "/repos/tagged/" + this.model.get("name");
			return $(this.el).html($.mustache(this.template, data));
		},
	
		clickTag : function(e){
			this.model.collection.repo.trigger("navigate", e.currentTarget.pathname);
			
			e.preventDefault()
			return false;
		}
		
	});

});
	
