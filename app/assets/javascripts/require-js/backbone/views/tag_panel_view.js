define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache'
], function($, _, Backbone){
	
	// TagPanel has two child views for public and personal tag lists.
	//
	TagPanelView = Backbone.View.extend({
		el : "#tag_panel_container",
		model : Repo,
		events : {
			"submit form" : "saveTags"
		},
		render : function(repo){
			console.log("Render TagPanelView");
		
			// reset the repo
			this.model = repo;

			// build the UserTag view
			this.tagsView = new RepoTagCollectionView({
				collection : this.model.tags, 
				type : "public", 
				el : "#add_tag_container"
			});
			this.tagsView.render();


			// build the UserTag view
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
		}
	
	});

	return TagPanelView;
});