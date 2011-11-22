define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/collections/user_tag_collection',
], function($, _, Backbone, UserTagCollection){
	
	User = Backbone.Model.extend({
		
		initialize : function(){
			console.log("init User");
			this.tags = new UserTagCollection;
			this.tags.user = this;
		},
		
		url : function(){
			return "/users/" +this.get("login")+ "/profile/json";
		}
	
	});

	return User;
});