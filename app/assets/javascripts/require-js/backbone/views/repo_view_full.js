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
			this.tagsView = new RepoTagsView({collection : this.model.tags, el : this.$("ul.tag_box") });
			//this.tagsView.render();
			this.model.bind("change", this.render, this);
			this.model.bind("wipe", this.wipe, this);
		},
		
		// Return the HTML template
		render : function(){
			// The element.id will be blank for newly created views.
			// However on bootstrapped elements (on page load) the id will be set.
			//if(this.el.id === "")
			var data = this.model.attributes;
			data.fork = data.fork ? "yes" : "no";
			$(this.el).html($.mustache(this.template, data));
		},
		
		wipe : function(){
			this.model.clear({silent : true});
			$(this.el).empty();
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
