define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/repo',
	'backbone/collections/repos',
	'backbone/views/repos_view',
	'backbone/views/repo_tags_view',
	'backbone/views/repo_tags_view'

], function($, _, Backbone, z,z, Repo, Repos, ReposView, RepoTagsView){

	// A Full view for a Repo.
	//
 	return Backbone.View.extend({
		model : Repo,
		el : "#singular_repo",
		
		template : $("#repo_view_full").html(),
		
		events : {
			"click .add_tag" : "showPanel"
		},
		
		initialize : function(){
			console.log("Repo full view!");
		},

		// Return the HTML template
		render : function(){
			// The element.id will be blank for newly created views.
			// However on bootstrapped elements (on page load) the id will be set.
			//if(this.el.id === "")
			$(this.el).html($.mustache(this.template, this.model.attributes));
		},
		
		showPanel : function(e){
			console.log("showPanel");
			// showPanel bubbles up to the tagPanelView which is listening
			// for this event through monitoring its collection.
			this.model.trigger("showPanel", this.model);
			
			e.preventDefault();
			return false;
		}
	
	})

})
