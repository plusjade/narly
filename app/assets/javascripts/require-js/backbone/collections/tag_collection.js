define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag'
], function($, _, Backbone, Tag){
	
	return Backbone.Collection.extend({
		model : Tag,

		url : function(){
			console.log("try URL");
			var url = "";
			
			switch(this.type){
			case "userRepo":
				url = "/users/"+this.repo.collection.currentUser.get("login")+"/repos/"+this.repo.get("full_name")+"/tags/json";
			  break;
			case "repo":
				url = "/repos/"+this.repo.get("full_name")+"/tags/json";
			  break;
			case "user":
				url = "/users/"+this.user.get("login")+"/tags/json";
			}
			
			return url;
		},

		setRepo : function(repo){
			this.repo = repo;
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
