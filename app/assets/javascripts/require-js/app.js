define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',

	'backbone/models/repo',
	'backbone/models/user',
	'backbone/models/tag',

	'backbone/collections/repo_collection',
	'backbone/collections/repo_tag_collection',
	'backbone/collections/user_repo_tag_collection',
	
	'backbone/views/repo_collection_view',
	'backbone/views/repo_tag_collection_view',
	'backbone/views/repo_view',
	'backbone/views/tag_panel_view',
	'backbone/views/tag_view'
], function($, _, Backbone, z,z, 
	Repo, User, Tag,
	RepoCollection, RepoTagCollection, UserRepoTagCollection, 
	RepoCollectionView, RepoTagCollectionView, RepoView, TagPanelView, TagView
	){
		
	var App = {
		models : {
			repo : Repo,
			user : User,
			tag : Tag
		},
		collections : {
			repoCollection : RepoCollection,
			repoTagCollection : RepoTagCollection,
			userRepoTagCollection : UserRepoTagCollection
		},
		views : {
			repoCollectionView : RepoCollectionView,
			repoTagCollectionView : RepoTagCollectionView,
			repoView : RepoView,
			tagPanelView : TagPanelView,
			tagView : TagView
		},
		
		initialize : function(boot){
			console.log("app.js initialized");
			App.currentUser = new User({login : $("head").attr("rel")});
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
