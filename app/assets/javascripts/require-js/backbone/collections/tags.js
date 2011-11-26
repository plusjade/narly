define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag'
], function($, _, Backbone, Tag){
	
	return Backbone.Collection.extend({
		model : Tag,
		// All tag collections should have an owner (User|Repo) even if its blank
		owner : null,
		initalize : function(){

		},
		
		url : function(){
			console.log("try tag collection URL");
			var url = "";

			switch(this.type){
			// "userRepo" only displays on the TagPanel.
			// they are tags created by user on repo.
			case "userRepo":
				if(_.isUndefined(this.owner.collection))
					url = "/users/"+this.owner.currentUser.get("login")+"/repos/"+this.owner.get("full_name")+"/tags/json";
				else
					url = "/users/"+this.owner.collection.currentUser.get("login")+"/repos/"+this.owner.get("full_name")+"/tags/json";
			  break;
			// "repo" is a repo's tags.
			case "repo":
				url = "/repos/"+this.owner.get("full_name")+"/tags/json";
			  break;
			// "user" is a user's tags.
			case "user":
			
				if(_.isEmpty(this.owner.get("login")))
					url = "/tags/json";
				else
					url = "/users/"+this.owner.get("login")+"/tags/json";
			}
			
			return url;
		},

		resetFromTagString : function(str){
			var cache = [];
			
			$.each(str.split(":"), function(){
				cache.push({name : this});
			});
			
			this.reset(cache);
		}
	})

});
