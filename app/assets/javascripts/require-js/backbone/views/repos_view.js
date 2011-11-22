define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/repo',
  'backbone/views/repo_view',
  'backbone/views/repo_tags_view',
  'backbone/views/tag_panel_view'
], function($, _, Backbone, Repo, RepoView, RepoTagsView, TagPanelView){
	
	// A collection for tags made by user
	//
	ReposView = Backbone.View.extend({
		el : "#main_content",
		model : Repo,

		initialize : function(){
			this.tagPanelView = new TagPanelView({collection : this.collection});
			this.collection.bind("reset", this.renderFresh, this);
		},

		render : function(){
			this.collection.each(function(repo){
				new RepoView({model : repo, el : repo.css_id() });
			})
		},
		
		renderFresh : function(){
			console.log("renderFresh");
			var cache = [];
			this.collection.each(function(repo){
				cache.push(new RepoView({model : repo}).render());
			})
			$.fn.append.apply($(this.el).empty(), cache);
		}
	});

	return ReposView;
});
