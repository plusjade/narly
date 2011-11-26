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
	
	// The model should be either a user or repo with a collection of tags
	//
	// 
	// 
	//
	return Backbone.View.extend({
		model : User,

		el : "#side_content",
		
		initialize : function(){
			this.model.tags.bind("reset", this.render, this);
			this.model.tags.bind("navigate", this.navigate, this);

			new UserTagsView({ el: this.$(".tag_box"), collection : this.model.tags });
		},
		
		
		render : function(){
			console.log("sidepanelView render:");
			console.log(this.model);
			if(_.isEmpty(this.model.get("login")))
				this.$("strong").html("Top Tags");
			else if(_.isEmpty(this.model.get("full_name")))
				this.$("strong").html(this.model.get("login"));
			else
				this.$("strong").html("Tags on " + this.model.get("full_name"));
			
			return this;	
		},
		
		// App.js is Monitoring the side_content view for navigate events.
		navigate : function(url){
			console.log("navigate trigger in side_content_view.js");
			this.trigger("navigate", url);
		}
		
	});

});