define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'backbone/collections/tags'
], function($, _, Backbone, z, Tags){

	return Backbone.Model.extend({
		initialize : function(){
			
			this.tags = new Tags(this.get("tags"));
			this.tags.type = "repo";
			this.tags.owner = this;
			
			this.userTags = new Tags;
			this.userTags.type = "userRepo";
			this.userTags.owner = this;


			this.bind("change", this.updateTags, this);

			this.bind("change", function(){
				this.tags.owner = this;
			})

		},
		
		parse : function(response){
			console.log("parse repo:");
			console.log(response);
			return response;
		},
		
		url : function(){
			return "/repos/"+this.get("login")+"/"+this.get("name")+"/json";
		},
		
		// Called by the router to fetch the results but also
		// make sure the URL and the UI is in sync with the call.
		// The UI will be updated as a callback to fetch
		route : function(login, tagString){
			console.log("routing singular repo");
			this.fetch();
		},
		
		refresh : function(){
			this.tags.fetch();
			this.userTags.fetch();
		},
		
		updateTags : function(){
			this.tags.reset(this.get("tags"));
		},
		
		css_id : function(){
			return "#repo-" + this.get("full_name").replace(/[^\w]/g, "-");
		}
	});

});