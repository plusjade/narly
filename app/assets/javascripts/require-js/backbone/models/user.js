define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/collections/tag_collection'
], function($, _, Backbone, TagCollection){
	
	User = Backbone.Model.extend({
		tags : null,
		
		initialize : function(){
			console.log("init User");
			this.tags = new TagCollection();
			this.tags.type = "user";
			this.tags.user = this;
		},
		
		url : function(){
			return "/users/" +this.get("login")+ "/profile/json";
		}
	
	});

	return User;
});