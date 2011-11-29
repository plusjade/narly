define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag'
], function($, _, Backbone, Tag){
	
	// A collection of Tags.
	// All tag collections should have an owner (User|Repo) even if its blank.
	//
	return Backbone.Collection.extend({
		model : Tag,
		owner : null,
		initalize : function(){

		},

		url : function(){
			console.log("try tag collection URL");
			var url = "";

		  // "userRepo" only displays on the TagPanel.
		  // they are tags created by user on repo.
			if(this.type === "userRepo")
				if(_.isUndefined(this.owner.collection))
					url = "/users/"+this.owner.currentUser.get("login")+"/repos/"+this.owner.get("full_name")+"/tags/json";
				else
					url = "/users/"+this.owner.collection.currentUser.get("login")+"/repos/"+this.owner.get("full_name")+"/tags/json";
		  // This means this is a user Object's tags.			
			else if( _.isEmpty(this.owner.get("full_name")) )
				if( _.isEmpty(this.owner.get("login")) )
					url = "/tags/json";
				else
					url = "/users/"+this.owner.get("login")+"/tags/json";
			// this means this is a repo object's tags.			
			else 
				url = "/repos/"+this.owner.get("full_name")+"/tags/json";

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
