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
	
	// The collection on this view is the Repo Collection we are displaying.
	//
	return Backbone.View.extend({
		model : Repo,
		user : User,
		el : "#side_content",
		
		initialize : function(){
			this.collection.user.tags.bind("reset", this.render, this);
			this.collection.user.tags.bind("addToFilter", this.addToFilter, this);
			
			new UserTagsView({ el: this.$(".tag_box"), collection : this.collection.user.tags });
			
		},
		
		render : function(){
			if(_.isEmpty(this.collection.user.get("login")))
				this.$("strong").html("Top Tags");
			else
				this.$("strong").html(this.collection.user.get("login"));
			
			return this;	
		},
		
		addToFilter : function(tag){
			if(_.isUndefined(this.collection.tags.get(tag.id)))
				this.collection.tags.add(tag);
		}
		
	});

});