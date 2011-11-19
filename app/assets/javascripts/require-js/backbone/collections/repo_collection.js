define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag',
  'backbone/models/user',
  'backbone/views/repo_view',
  'backbone/views/repo_tag_collection_view'
], function($, _, Backbone, Tag, User, RepoView, RepoTagCollectionView){
	
	// A collection of Repos.
	//
	RepoCollection = Backbone.Collection.extend({
		model : Repo,
		
		// This User should be the whatever this collection is scoped to if any.
		//
		user : User,
		// currentUser is the logged in user if any.
		//
		currentUser : User,

		// set this to be dynamic based on user/repo/tag filters.
		url : function(){
			var url = "/";
			var tagNames = this.tags.pluck("name");
			var userPath = "/users/" + this.user.get("login");
			var tagsPath = "/repos/tagged/" + tagNames.join(":");
			
			if(tagNames.length > 0)
				if(this.user.get("login") === "") url = tagsPath;
				else url = userPath + tagsPath;
			else
				if(this.user.get("login") === "") url = "/repos";
				else  url = userPath;

			return url+"/json";	
		},
		
		
		
	});

	return RepoCollection;
});
