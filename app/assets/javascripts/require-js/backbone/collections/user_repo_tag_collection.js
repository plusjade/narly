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
		repo : null,
		url : function(){
			return "/users/"+this.repo.collection.currentUser.get("login")+"/repos/"+this.repo.get("full_name")+"/tags";
		},
		setRepo : function(repo){
			this.repo = repo;
		}
	});

	return UserRepoTagCollection;
});
