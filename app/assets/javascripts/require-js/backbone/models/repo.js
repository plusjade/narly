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
			this.tags.owner = this;
			
			this.userTags = new Tags;
			this.userTags.owner = this;
			this.userTags.type = "userRepo";

			this.bind("change", this.updateTags, this);

			this.bind("change", function(){
				this.tags.owner = this;
			})

		},
		
		parse : function(response){
			return response;
		},
		
		url : function(){
			return "/repos/"+this.get("login")+"/"+this.get("name")+"/json";
		},
		
		refresh : function(){
			this.tags.fetch();
			this.userTags.fetch();
		},
		
		updateTags : function(){
			this.tags.reset(this.get("tags"));
		},
		
		// This is the css id for the RepoView div when it's being bootstrapped.
		// Meaning on pageload the div is already in the DOM.
		//
		css_id : function(){
			return "#repo-" + this.get("full_name").replace(/[^\w]/g, "-");
		}
	});

});