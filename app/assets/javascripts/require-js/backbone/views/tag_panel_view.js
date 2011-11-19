define([
  'jquery',
  'Underscore',
  'Backbone',
	'backbone/models/repo',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/views/repo_tag_collection_view'
], function($, _, Backbone, Repo, z,z, RepoTagCollectionView){

	// TagPanel has two child views for public and personal tag lists.
	//
	TagPanelView = Backbone.View.extend({
		el : "#tag_panel_container",
		model : Repo,
		events : {
			"submit form" : "saveTags",
			"click a.tag_panel_close" : "close"
		},
		initialize : function(){
			// listen to the show panel event which fires from individual
			// repos but bubbles up to their parent collections.
			this.collection.bind("showPanel", this.render, this);
		},
		
		render : function(repo){
			this.model = repo;

			// build a fresh repoTagcollection view
			this.tagsView = new RepoTagCollectionView({
				collection : this.model.tags, 
				type : "public", 
				el : "#add_tag_container"
			});
			this.tagsView.render();

			// build a fresh userRepoTagCollection view
			this.userTagsView = new RepoTagCollectionView({
				collection : this.model.userTags,
				type : "personal",
				el : "#my_tags_on_repo"
			});
			// only fetch this when the tagPanel opens (which is now).
			this.model.userTags.fetch();

			this.$("a.repo_name").text(this.model.get("full_name"))
			this.$("input.full_name").val(this.model.get("full_name"));

			$("#filters_container").hide();
			$("#tag_panel_container").slideDown("fast")
		},
	
		saveTags : function(){
			console.log("savetags");
			$.showStatus('submitting');
			var repo = this.model;
			$.ajax({
			    dataType: "json",
			    url: this.$("form").attr("action"),
					data : this.$("form").serialize(),
			    success: function(rsp){
						$.showStatus('respond', rsp);
						repo.refresh();
					}
			});
			return false;
		},
		
		close : function(){
			$("#tag_panel_container").hide();
			$("#filters_container").slideDown("fast");
			return false;
		}
	
	});

	return TagPanelView;
});