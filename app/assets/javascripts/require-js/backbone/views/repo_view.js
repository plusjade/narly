define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/repo',
	'backbone/views/tag_panel_view'

], function($, _, Backbone, z,z, Repo, TagPanelView){
	RepoView = Backbone.View.extend({
		model : Repo,
		events : {
			"click .add_tag" : "showPanel"
		},

		showPanel : function(){
			var view = new TagPanelView;
			view.render(this.model);
			return false;
		}
	
	})

	return RepoView;
})
