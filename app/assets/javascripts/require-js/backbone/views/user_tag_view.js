define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
], function($, _, Backbone, z,z){
	
	// A singular tag view a tag list (usually on the right side column)
	// A tag collection can be long to either a repo or a user but it has to belong to something
	// even if that something is empty.
	//
 	return Backbone.View.extend({
		tagName : "li",
		template : $("#user_tag_template").html(),
	
		events : {
			"click a" : "clickTag"
		},
		
		render: function(){
			var data = this.model.attributes;
			data.url = "";
			
			// needs to be a user tag and not be a blank user.
			if( _.isEmpty( this.model.collection.owner.get("full_name") ) 
				&& !_.isEmpty( this.model.collection.owner.get("login") ) )
					data.url += "/users/" + this.model.collection.owner.get("login");
			
			data.url += "/repos/tagged/" + this.model.get("name");
			return $(this.el).html($.mustache(this.template, data));
	  },
	
		clickTag : function(e){
			console.log("clicky");
			this.model.trigger("navigate", e.currentTarget.pathname);

			e.preventDefault()
			return false;
		}
	
	});

});
	
