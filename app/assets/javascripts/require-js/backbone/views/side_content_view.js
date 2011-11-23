define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/repo',
	'backbone/models/user',
	'backbone/views/user_tags_view'
], function($, _, Backbone, z,z, Repo, User, UserTagsView){
	
  // The FiltersView is the main query interface in the UI.
	// The collection on this view is the Repo Collection we are displaying.
	// Here we monitor changes to the attached user model and tag collection.
	// When a change occurs we trigger events that update the Repo Collection
	// to reflect the user/tag-collection state.
	//
	return Backbone.View.extend({
		model : Repo,
		user : User,
		el : "#side_content",
		
		events : {

		},
		
		initialize : function(){
			this.collection.bind("reset", this.render, this);
	
			new UserTagsView({ el: this.$(".tag_box"), collection : this.collection });
		},
		
		render : function(){
			if(_.isEmpty(this.collection.user.get("login")))
				this.$("strong").html("Top Tags");
			else
				this.$("strong").html(this.collection.user.get("login"));
			
			return this;	
		}
		
	});

});