define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/repo',
	'backbone/views/repo_tags_view',
	'backbone/views/repo_tags_view'

], function($, _, Backbone, z,z, Repo, RepoTagsView){

	// A view for a Repo.
	//
 	return Backbone.View.extend({
		model : Repo,
		tagName : "div",
		className : "repo",
		
		template : $("#repoTemplate").html(),
		tagTemplate : $("#tagTemplateAdd").html(),
		
		events : {
			"click .add_tag" : "showPanel",
			"click img" : "filterByUser",
			"click a.repo_name" : "clickRepoName"
		},
		
		initialize : function(){
			// The element.id will be blank for newly created views.
			// However on bootstrapped elements (on page load) the id will be set.
			if(this.el.id === "")
				$(this.el).html($.mustache(this.template, this.model.attributes));

			this.tagsView = new RepoTagsView({collection : this.model.tags, el : this.$("ul.tag_box") });
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
		},
		
		filterByUser : function(e){
			if(this.model.get("login") !== this.model.collection.user.get("login")){
				this.model.collection.user.set({login : this.model.get("login")}, {silent :true})
				this.model.collection.trigger("filterChange");
			}
			
			e.preventDefault;
			return false;
		},
		
		clickRepoName : function(e){
			console.log("clickRepoName");
			this.model.trigger("navigate", e.currentTarget.pathname);

			e.preventDefault()
			return false;
		}
	
	})

})
