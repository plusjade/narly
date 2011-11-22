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
	'backbone/views/repo_view',
	'backbone/views/repo_tags_view',
	'backbone/views/repos_view',
	'backbone/views/tag_panel_view',
	'backbone/views/tag_view',
	'backbone/views/user_tags_view'
	
], function($, _, Backbone, z,z, 
	Router,
	Repo, Tag, User,
	Repos, Tags,
	FiltersView, RepoView, RepoTagsView, ReposView, TagPanelView, TagView, UserTagsView
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
			reposView : ReposView,
			repoTagsView : RepoTagsView,
			repoView : RepoView,
			tagPanelView : TagPanelView,
			tagView : TagView,
			filtersView : FiltersView,
			userTagsView : UserTagsView
		},
		
		initialize : function(boot){
			Backbone.history.start({pushState: true, silent: true})
			console.log("app.js initialized");
			console.log(App);
			
			boot();
			
			$(function(){
				console.log("DOM ready");
			})
		}
	}
	
	// Return our App object which should require the references we need so our other modules can use them.
	// Remember everything is freaking in a closure so nothing is in the global namespace
	// I.E. you can't use anything without having references.
  return App;
	
});
