define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',

	'backbone/router',

	'backbone/models/repo',
	'backbone/models/user',
	'backbone/models/tag',

	'backbone/collections/tag_collection',
	'backbone/collections/repo_collection',
	'backbone/collections/repo_tag_collection',
	'backbone/collections/user_repo_tag_collection',
	
	'backbone/views/repo_collection_view',
	'backbone/views/repo_tag_collection_view',
	'backbone/views/repo_view',
	'backbone/views/tag_panel_view',
	'backbone/views/tag_view',
	'backbone/views/filters_view'
], function($, _, Backbone, z,z, 
	Router,
	Repo, User, Tag,
	TagCollection, RepoCollection, RepoTagCollection, UserRepoTagCollection, 
	RepoCollectionView, RepoTagCollectionView, RepoView, TagPanelView, TagView, FiltersView
	){
		
	var App = {
		router : Router,
		models : {
			repo : Repo,
			user : User,
			tag : Tag
		},
		collections : {
			tagCollection : TagCollection,
			repoCollection : RepoCollection,
			repoTagCollection : RepoTagCollection,
			userRepoTagCollection : UserRepoTagCollection
		},
		views : {
			repoCollectionView : RepoCollectionView,
			repoTagCollectionView : RepoTagCollectionView,
			repoView : RepoView,
			tagPanelView : TagPanelView,
			tagView : TagView,
			filtersView : FiltersView
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
