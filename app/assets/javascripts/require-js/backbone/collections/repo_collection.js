define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag',
  'backbone/models/user',
  'backbone/collections/tags',
  'backbone/views/repo_view',
  'backbone/views/repo_tags_view'
], function($, _, Backbone, Tag, User, Tags, RepoView, RepoTagsView){
	
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

		initialize : function(){
			this.tags = new Tags;
			this.user = new User;
			
			this.user.bind("change:avatar_url", this.renewUserTags, this);
		},
		
		renewUserTags : function(){
			console.log("===renewUserTags====");
			this.user.tags.fetch();
		},
		
		parse : function(response){
			this.user.set({login : response.login, avatar_url : response.avatar_url})
			return response.repos;
		},
		
		// Called by the router to fetch the results but also
		// make sure the URL and the UI is in sync with the call.
		// The UI will be updated as a callback to fetch
		route : function(login, tagString){
			this.user.set({login : login}, {silent : true})
			this.tags.resetFromTagString(tagString);
			this.fetch();
		},
		
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
		
		permalink : function(){
			return this.url().replace(/(\/json)$/, "");
		}
		
	});

	return RepoCollection;
});
