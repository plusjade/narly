define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/repo',
	'backbone/collections/repos',
	'backbone/collections/user_icons',
	'backbone/views/repos_view',
	'backbone/views/repo_tags_view',
	'backbone/views/user_icons_view'

], function($, _, Backbone, z,z, 
	Repo, 
	Repos, UserIcons, 
	ReposView, RepoTagsView, UserIconsView
){

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
			// we need RepoTagsView even though we don't use it 
			// because TagPanel View expects it when we click on "ShowPanel"
			this.tagsView = new RepoTagsView({collection : this.model.tags });
			this.userIcons = new UserIcons;

			this.model.bind("change", this.render, this);
			this.model.bind("wipe", this.wipe, this);
			this.userIcons.bind("navigate", this.navigate, this);
		},
		
		render : function(){
			var data = this.model.attributes;
			data.fork = data.fork ? "yes" : "no";
			$(this.el).html($.mustache(this.template, data));
			
			this.userIconsView = new UserIconsView({collection : this.userIcons, el : this.$("div.tagged_by_container") })
			this.userIcons.reset(this.model.get("users"));
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
		},
		
		// App.js is monitoring the mainRepoView for navigate events.
		navigate : function(url){
			this.trigger("navigate", url);
		}
	
	})

})
