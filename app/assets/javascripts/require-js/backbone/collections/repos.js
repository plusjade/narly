define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/repo',
  'backbone/models/tag',
  'backbone/models/user',
  'backbone/collections/tags',
  'backbone/views/repo_view',
  'backbone/views/repo_tags_view'
], function($, _, Backbone, Repo, Tag, User, Tags, RepoView, RepoTagsView){
	
	// A collection of Repos.
	//
	return Backbone.Collection.extend({
		model : Repo,
		
		// This User|Repo should be the whatever this collection is scoped to if any.
		owner : User,

		// currentUser is the logged in user if any.
		currentUser : User,

		initialize : function(){
			this.tagFilters = new Tags;
			this.owner = new User;
			
			// Monitor the avatar_url because this will be set when
			// the collection returns. We don't want this to trigger
			// when we set the :login because we do this throughout the app.
			//
			this.owner.bind("change:avatar_url", this.renewUserTags, this);
		},
		
		renewUserTags : function(){
			this.owner.tags.fetch();
		},
		
		parse : function(response){
			this.owner.set({login : response.login, avatar_url : response.avatar_url})
			return response.repos;
		},
		
		// Update this repo collection with respect to a repo object.
		// This is needed when showing a singular repo page.
		// Mainly to show the repos tags in the side_content panel
		// and to update this repo collection with the repo's similar repos array.
		//
		updateFromRepo : function(repo){
			this.owner.clear();
			// silent so this does not trigger a .fetch();
			this.owner.set(repo.attributes, {silent: true});
			this.owner.tags.reset(repo.get("tags"));
			this.reset(repo.get("similar_repos"));
		},
		
		// Called by the router to fetch the results but also
		// make sure the URL and the UI is in sync with the call.
		// The UI will be updated as a callback to fetch
		route : function(login, tagFilters){
			this.owner.clear({silent : true})
			this.owner.set({login : login}, {silent : true})
			
			this.tagFilters.resetFromTagString(tagFilters);
			this.fetch();
		},
		
		// set this to be dynamic based on user/repo/tag filters.
		url : function(){
			var url = "/";
			var tagNames = this.tagFilters.pluck("name");
			var userPath = "/users/" + this.owner.get("login");
			var tagsPath = "/repos/tagged/" + tagNames.join(":");
			
			if(tagNames.length > 0)
				if(this.owner.get("login") === "") url = tagsPath;
				else url = userPath + tagsPath;
			else
				if(this.owner.get("login") === "") url = "/repos";
				else  url = userPath;

			return url+"/json";	
		},
		
		permalink : function(){
			return this.url().replace(/(\/json)$/, "");
		}
		
	});

});
