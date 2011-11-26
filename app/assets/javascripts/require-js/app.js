define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',

	'backbone/router',

	'backbone/models/repo',
	'backbone/models/tag',
	'backbone/models/user',
	
	'backbone/collections/repos',
	'backbone/collections/tags',
	
	'backbone/views/filters_view',
	
	'backbone/views/tag_panel_view',
	'backbone/views/repo_tag_panel_view',
	'backbone/views/repo_tags_panel_view',
	
	'backbone/views/repo_view',
	'backbone/views/repo_view_full',
	'backbone/views/repos_view',

	'backbone/views/repo_tag_view',
	'backbone/views/repo_tags_view',
	
	'backbone/views/user_tag_view',
	'backbone/views/user_tags_view',

	'backbone/views/user_repo_tag_view',
	'backbone/views/user_repo_tags_view',

	'backbone/views/side_content_view'
	
], function($, _, Backbone, z,z, 
	Router,
	Repo, Tag, User,
	Repos, Tags,
	FiltersView, 
	TagPanelView, RepoTagPanelView, RepoTagsPanelView, 
	RepoView, RepoViewFull, ReposView, 
	RepoTagView, RepoTagsView,
	UserTagView, UserTagsView,
	UserRepoTagView, UserRepoTagsView,
	SideContentView
	){
		
	var App = {
		router : Router,
		models : {
			repo : Repo,
			user : User,
			tag : Tag
		},
		collections : {
			tags : Tags,
			repos : Repos
		},
		views : {
			filtersView:FiltersView , 
			tagPanelView: TagPanelView, 
			repoTagPanelView: RepoTagPanelView, 
			repoTagsPanelView: RepoTagsPanelView, 
			repoView: RepoView, 
			repoViewFull: RepoViewFull, 
			reposView: ReposView, 
			repoTagView: RepoTagView, 
			repoTagsView: RepoTagsView,
			userTagView: UserTagView, 
			userTagsView: UserTagsView,
			userRepoTagView: UserRepoTagView, 
			userRepoTagsView: UserRepoTagsView,
			
			sideContentView : SideContentView
		},
		
		initialize : function(boot){
	  // Setup singular main repo objects
			App.mainRepo = new Repo;
			App.mainRepo.currentUser = new User;
			App.mainRepoView = new RepoViewFull({model : App.mainRepo});
			
		// Setup multiple main repos objects
			App.mainRepos = new Repos;
			App.mainRepos.currentUser = new User;
			App.mainReposView = new ReposView({collection : App.mainRepos});
		
		// Setup tagPanelView filterView and sideContentView	
			App.tagPanelView = new TagPanelView({collection : App.mainRepos, mainRepo : App.mainRepo });
			App.filtersView = new FiltersView({collection : App.mainRepos });
			App.sideContentView = new SideContentView({model : App.mainRepos.owner })
			
			App.mainRepo.bind("change", function(){
				console.log("getting Repo");
				console.log(this);
				
			// update side panel	
				App.mainRepos.owner.clear({silent : true})
				App.mainRepos.owner.set(this.attributes)
				App.mainRepos.owner.tags.reset(this.get("tags"));
				
			// show similar repos in the mainRepos collection.
				App.mainRepos.reset(this.get("similar_repos"));
			});
			
		// Setup Routing.
			App.Router = new Router;

			App.sideContentView.bind("navigate", function(url){
				console.log("side content routing: " + url);
				App.Router.navigate(url, true);
			});
			App.mainRepos.bind("navigate", function(url){
				console.log("routing: " + url);
				App.Router.navigate(url, true);
			});
			App.mainRepos.bind("filterChange", function(){
				console.log("routing: " + this.permalink());
				App.Router.navigate(this.permalink(), true);
			});
			
			
			App.Router.bind("route:users", function(login) {
				App.mainRepo.trigger("wipe");
				App.mainRepos.route(login, "");
			})
			App.Router.bind("route:repos_tagged", function(tags) {
				App.mainRepo.trigger("wipe");
				App.mainRepos.route("", tags);
			});
			App.Router.bind("route:users_repos_tagged", function(login, tags) {
				App.mainRepo.trigger("wipe");
				App.mainRepos.route(login, tags);
			});
			// repo show
			App.Router.bind("route:repos", function(repo_login, repo_name) {
				console.log("repo show");
				App.mainRepo.clear({silent : true});
				App.mainRepo.set({login : repo_login, name : repo_name}, {silent :true});
				App.mainRepo.fetch();
			})
			
			
			Backbone.history.start({pushState: true, silent: true})
			
			console.log("app.js initialized");
			console.log(App);
			
			boot();
			
		}, // initialize
		
		bootSingle : function(data, repoTags){
			console.log("bootSingle");
			console.log(data);
		// populate and render the mainRepo	
		  App.mainRepo.set(data, {silent : true});
			App.mainRepoView.render();

		// show similar repos in the mainRepos collection.
			App.mainRepos.reset(data.similar_repos, {silent : true});
			App.mainReposView.render();

		// Repo Tags shown on the right side panel.
			App.mainRepos.owner.clear({silent : true});
			App.mainRepos.owner.set(data);
			App.mainRepos.owner.tags.reset(repoTags);			
		},
		
		bootMulti : function(data, userTags){
			console.log("bootmulti");

			App.mainRepos.reset(data.repos, {silent : true});
			App.mainReposView.render();

		// User Tags shown on the right side panel.
			App.mainRepos.owner.tags.reset(userTags);
		}
		
	} // App
	
	//_.extend(App, Backbone.Events);
	
	// Return our App object which should require the references we need so our other modules can use them.
	// Remember everything is freaking in a closure so nothing is in the global namespace
	// I.E. you can't use anything without having references.
  return App;
	
});
