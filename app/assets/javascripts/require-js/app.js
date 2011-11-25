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
		// Setup initial models and views.
			App.mainRepo = new Repo;
			App.mainRepos = new Repos;
			App.mainRepos.currentUser = new User;

			App.mainRepoView = new RepoViewFull({model : App.mainRepo});
			App.mainReposView = new ReposView({collection : App.mainRepos});
			App.filtersView = new FiltersView({collection : App.mainRepos });
			App.sideContentView = new SideContentView({collection : App.mainRepos})
			

		// Setup Routing.
			App.Router = new Router;

			App.mainRepos.bind("navigate", function(url){
				console.log("routing: " + url);
				App.Router.navigate(url, true);
			});
			
			App.mainRepos.bind("filterChange", function(){
				console.log("routing: " + this.permalink());
				App.Router.navigate(this.permalink(), true);
			});
			
			App.Router.bind("route:users", function(login) {
				App.mainRepos.route(login, "");
			})
			App.Router.bind("route:repos_tagged", function(tags) {
				App.mainRepos.route("", tags);
			});
			App.Router.bind("route:users_repos_tagged", function(login, tags) {
				App.mainRepos.route(login, tags);
			});
			
			// repo show
			App.Router.bind("route:repos", function(login) {
				console.log("repo show");
				//App.mainRepos.route(login, "");
			})
			
			Backbone.history.start({pushState: true, silent: true})
			
			console.log("app.js initialized");
			console.log(App);
			
			boot();
			
		} // initialize

	} // App
	
	//_.extend(App, Backbone.Events);
	
	// Return our App object which should require the references we need so our other modules can use them.
	// Remember everything is freaking in a closure so nothing is in the global namespace
	// I.E. you can't use anything without having references.
  return App;
	
});
