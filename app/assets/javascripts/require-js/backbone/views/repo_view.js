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
		tagName : "div",
		className : "repo",
		
		template : $("#repoTemplate").html(),
		tagTemplate : $("#tagTemplateAdd").html(),
		
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

		// Return the HTML template
		render : function(){
			return $(this.el).html($.mustache(this.template, this.model.attributes));
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
