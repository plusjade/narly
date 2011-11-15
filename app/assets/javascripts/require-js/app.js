define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	
	'backbone/models/repo',
	'backbone/models/user',
	'backbone/models/tag',

	'backbone/collections/repo_tag_collection',
	'backbone/collections/user_repo_tag_collection',
	
	'backbone/views/repo_tag_collection_view',
	'backbone/views/repo_view',
	'backbone/views/tag_panel_view',
	'backbone/views/tag_view',
	
], function(
		$, _, Backbone, z,z,
		Repo, User, Tag, 
		RepoTagCollection, UserRepoTagCollection,
		RepoTagCollectionView, RepoView, TagPanelView, TagView
	){
	var initialize = function(){
		
		$(function() {
				console.log("ready to go!!!");

				$("a.tag_panel_close").click(function(e){
					$("#tag_panel_container").hide();
					$("#filters_container").slideDown("fast");
					e.preventDefault();
					return false;
				})

				// Singular TagPanelView reference.
				MainTagPanelView = new TagPanelView;
				// Singular logged in CurrentUser reference.
				CurrentUser = new User({"login" : "plusjade"});
	  });
	
	}

  return { 
    initialize: initialize
  };
	
});