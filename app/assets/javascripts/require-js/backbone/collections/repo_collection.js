define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag',
  'backbone/views/repo_view',
  'backbone/views/repo_tag_collection_view'
], function($, _, Backbone, Tag, RepoView, RepoTagCollectionView){
	
	// A collection for tags made by user
	//
	RepoCollection = Backbone.Collection.extend({
		model : Repo,
		user : null,
		setUser : function(user){
			this.user = user;
		},

		url : function(){
			return "/users/"+this.user.get("login")+"/tags";
		}
	});

	return RepoCollection;
});
