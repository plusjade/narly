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
	
		events : {
			"click a" : "clickTag"
		},
		
		render: function(){
			var data = this.model.attributes;
			data.url = "/users/" + this.model.collection.user.get("login") + "/repos/tagged/" + this.model.get("name");
			return $(this.el).html($.mustache(this.template, data));
	  },
	
		clickTag : function(e){
			// This event is being monitored on this tags parent collection.
			this.model.trigger("addToFilter", this.model);
			e.preventDefault()
			return false;
		}
	
	});

});
	
