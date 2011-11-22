define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag',
  'backbone/models/user'
], function($, _, Backbone, Tag, User){
	
	// A collection for tags made by user
	//
	UserTagCollection = Backbone.Collection.extend({
		model : Tag,
		user : User,
		
		url : function(){
			return "/users/"+this.user.get("login")+"/tags";
		}, 
		
		parse : function(response){
			console.log("parse user tags");
			return response;
		}
	
	});

	return UserTagCollection;
});
