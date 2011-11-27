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
	'backbone/models/user_icon',
	
	'backbone/collections/repos',
	'backbone/collections/tags',
	'backbone/collections/user_icons',
	
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

	'backbone/views/user_icon_view',
	'backbone/views/user_icons_view',

	'backbone/views/side_content_view'
	
], function($, _, Backbone, z,z, 
	Router,
	Repo, Tag, User, UserIcon,
	Repos, Tags, UserIcons,
	FiltersView, 
	TagPanelView, RepoTagPanelView, RepoTagsPanelView, 
	RepoView, RepoViewFull, ReposView, 
	RepoTagView, RepoTagsView,
	UserTagView, UserTagsView,
	UserRepoTagView, UserRepoTagsView,
	UserIconView, UserIconsView,
	SideContentView
	){
		
	var App = {
		router : Router,
		models : {
			repo : Repo,
			user : User,
			userIcon : UserIcon,
			tag : Tag
		},
		collections : {
			tags : Tags,
			repos : Repos,
			userIcons : UserIcons
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
			userIconView : UserIconView,
			userIconsView : UserIconsView,
			sideContentView : SideContentView
		},
		
		initialize : function(boot){
			
		// Setup multiple main repos objects
			App.mainRepos = new Repos;
			App.mainRepos.currentUser = new User;
			App.mainReposView = new ReposView({collection : App.mainRepos});

	  // Setup singular main repo objects
			App.mainRepo = new Repo;
			App.mainRepo.currentUser = new User;
			App.mainRepoView = new RepoViewFull({model : App.mainRepo});
				
		// Setup tagPanelView filterView and sideContentView	
			App.tagPanelView = new TagPanelView({collection : App.mainRepos, mainRepo : App.mainRepo });
			App.filtersView = new FiltersView({collection : App.mainRepos });
			App.sideContentView = new SideContentView({model : App.mainRepos.owner })
		
		// Setup references via binding.
			// Ideally we should be able to reference objects to one another
			// by binding events between them. So here's my attempt at managing that.

			// If the main repo changes it means we are trying to show a single repo page
			// So we need to update the mainRepos to complete the page.
			App.mainRepo.bind("change", function(){
				App.mainRepos.updateFromRepo(this);
			});
		
			
    // Setup Routing.
			App.Router = new Router;
			
			// These Routing bindings are what actually get the data and update the UI.
			// Page change events that happen within the app should ultimately trigger *App.router* 
			// which then trigger one of these functions to handle the request.
			//
			// This is preferred so that the back/forward buttons will work as expected
			// since Back/Forward triggers *App.router*.
			//
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
			App.Router.bind("route:repos", function(repo_login, repo_name) {
				App.mainRepo.clear({silent : true});
				App.mainRepo.set({login : repo_login, name : repo_name}, {silent :true});
				App.mainRepo.fetch();
			})
			
		// Setup "navigate" monitoring.
			// "navigate" events are triggered by native links in the app
			// such as tag hrefs, userIcon hrefs, repo hrefs. 
			// We monitor them through their parent views below and trigger
			// the *App.Router* to handle the href through Backbone.
			//
			App.mainRepos.bind("navigate", function(url){
				App.Router.navigate(url, true);
			});
			App.mainRepoView.bind("navigate", function(url){
				App.Router.navigate(url, true);
			});
			App.sideContentView.bind("navigate", function(url){
				App.Router.navigate(url, true);
			});
			
			// FilterChange events are triggered by the FilterView form
			// based on the filter state. If the state changes this event is
			// triggered which triggers the Router which in turn
			// triggers the routing function for that route.
			//
			App.mainRepos.bind("filterChange", function(){
				App.Router.navigate(this.permalink(), true);
			});
			
			Backbone.history.start({pushState: true, silent: true})
			
			// Call the boot function after everything has been setup.
			boot();
		}, // initialize
		
		// Boots the singular repo page into Backbone.
		// ex: /repos/plusjade/apron
		// 
		bootSingle : function(data){
		  App.mainRepo.set(data);
		},
		
		// Boots any multiple repos page into Backbone.
		// ex:
		//   /users/plusjade
		//   /users/plusjade/repos/tagged/ruby
		//   /repos/tagged/ruby:redis
		//
		bootMulti : function(data, userTags){
			App.mainRepos.reset(data.repos, {silent : true});
			App.mainReposView.render();

		// User Tags shown on the right side panel.
			App.mainRepos.owner.tags.reset(userTags);
		}
		
	} // App
	
	// Return our App object which should require the references we need so our other modules can use them.
	// Remember everything is freaking in a closure so nothing is in the global namespace
	// I.E. you can't use anything without having references.
  return App;
	
});
