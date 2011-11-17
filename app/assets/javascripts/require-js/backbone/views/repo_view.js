define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/repo',
	'backbone/views/repo_tag_collection_view'

], function($, _, Backbone, z,z, Repo, RepoTagCollectionView){
	RepoView = Backbone.View.extend({
		model : Repo,
		events : {
			"click .add_tag" : "showPanel"
		},
		
		initialize : function(){
			this.tagsView = new RepoTagCollectionView({
				collection : this.model.tags, 
				type : "public", 
				el : this.$("ul.tag_box")
			});
		},

		showPanel : function(){
			// showPanel bubbles up to the tagPanelView which is listening
			// for this event through monitoring its collection.
			this.model.trigger("showPanel", this.model);
			return false;
		}
	
	})

	return RepoView;
})
