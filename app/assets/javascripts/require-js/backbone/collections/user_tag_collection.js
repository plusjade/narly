define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag'
], function($, _, Backbone, Tag){
	
	// A collection for tags made by user
	//
	UserTagCollection = Backbone.Collection.extend({
		model : Tag,
		user : null,
		url : function(){
			return "/users/"+this.user.get("login")+"/tags";
		}
	});

	return UserTagCollection;
});
