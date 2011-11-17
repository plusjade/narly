define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag'
], function($, _, Backbone, Tag){
	
	// A collection for a Repo's tags made by User.
	//
	UserRepoTagCollection = Backbone.Collection.extend({
		model : Tag,
		user : null,
		repo : null,
		url : function(){
			return "/users/"+this.user.get("login")+"/repos/"+this.repo.get("full_name")+"/tags";
		},
		setUser : function(user){
			this.user = user;
		},
		setRepo : function(repo){
			this.repo = repo;
		}
	});

	return UserRepoTagCollection;
});
