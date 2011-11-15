define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',

	'backbone/models/repo'
], function($, _, Backbone, z,z, Repo){
	
	RepoView = Backbone.View.extend({
		model : Repo,
		events : {
			"click .add_tag" : "showPanel"
		},

		// Show this repo in the singular MainTagPanelView window
		showPanel : function(){
			MainTagPanelView.render(this.model);
			return false;
		}
	
	})

	return RepoView;
})