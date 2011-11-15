define([
  'jquery',
  'Underscore',
  'Backbone',
], function($, _, Backbone){
	
	// A collection for a Repo's tags made by User.
	//
	UserRepoTagCollection = Backbone.Collection.extend({
		model : Tag,
		setUrl : function(user, repo){
			this.url = "/users/"+user.get("login")+"/repos/"+repo.get("full_name")+"/tags";
		}
	});

	return UserRepoTagCollection;
});
