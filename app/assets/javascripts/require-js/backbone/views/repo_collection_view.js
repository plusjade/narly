define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/repo',
  'backbone/views/repo_view',
  'backbone/views/repo_tag_collection_view',
  'backbone/views/tag_panel_view'
], function($, _, Backbone, Repo, RepoView, RepoTagCollectionView, TagPanelView){
	
	// A collection for tags made by user
	//
	RepoCollectionView = Backbone.View.extend({
		model : Repo,
		user : null,

		initialize : function(){
			this.tagPanelView = new TagPanelView({collection : this.collection});
		},

		render : function(){
			$.each(this.collection.models, function(){
				new RepoView({model : this, el : this.css_id() });
			})
		}
	});

	return RepoCollectionView;
});
