define([
	'app',
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/repo'

], function(App, $, _, Backbone, z,z, Repo){
	RepoView = Backbone.View.extend({
		model : Repo,
		events : {
			"click .add_tag" : "showPanel"
		},

		// Show this repo in the singular mainTagPanelView window
		showPanel : function(){
			App.mainTagPanelView.render(this.model);
			return false;
		}
	
	})

	return RepoView;
})