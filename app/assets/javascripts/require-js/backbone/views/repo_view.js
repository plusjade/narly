define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/repo',
	'backbone/views/repo_tags_view'

], function($, _, Backbone, z,z, Repo, RepoTagsView){
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
			// The element.id will be blank for newly created views.
			// However on bootstrapped elements (on page load) the id will be set.
			if(this.el.id === "")
				$(this.el).html($.mustache(this.template, this.model.attributes));

			this.tagsView = new RepoTagsView({
				collection : this.model.tags, 
				type : "public", 
				el : this.$("ul.tag_box")
			});
			
			if(this.el.id === "")
				this.tagsView.render();
		},

		// Return the HTML template
		render : function(){
			return $(this.el);
		},
		
		showPanel : function(e){
			// showPanel bubbles up to the tagPanelView which is listening
			// for this event through monitoring its collection.
			this.model.trigger("showPanel", this.model);
			
			e.preventDefault();
			return false;
		}
	
	})

	return RepoView;
})
