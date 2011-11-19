define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/tag',
	'backbone/models/user'
], function($, _, Backbone, z,z, Tag, User){
	
	FiltersView = Backbone.View.extend({
		model : Tag,
		user : User,
		el : "#filters",
		
		events : {
			"submit form" : "parseInput",
			"click span" : "remove",
		},
		
		initialize : function(){
			console.log("filter init");
			this.user = new User({login : this.getUser()});
			// set the user on the repo collection since the collection
			// is bootstrapped into place via serverside objects. 
			this.collection.repos.user = this.user;
			
			this.user.bind("change", this.query, this);
			this.collection.bind("add", this.update, this);
			this.collection.bind("remove", this.update, this);
		},

		parseInput : function(){
			this.user.set({login : this.getUser()});
			
			var name = this.$("input.tag").val().toLowerCase();
			var exists = false;
			this.collection.each(function(tag){
				if(tag.get("name") === name) exists = true;
			})
			if(!exists)
				this.collection.add({name : name});

			return false;
		},
		
		// Remove a tag from the collection.
		remove : function(e){
			var name = $(e.currentTarget).text();
			var tagToRemove = null;
			this.collection.each(function(tag){
				if(tag.get("name").match(name)){
					tagToRemove = tag;
				}
			})
			this.collection.remove(tagToRemove);
		},
		
		// Update the UI to reflect the tag collection.
		//
		update : function(){
			var data = "";
			this.collection.each(function(tag){
				data += "<span>" + tag.get("name") + "</span> + ";
			})
			this.$("p").html(data);
			this.$("input.tag").val("");

			this.query();
		},
		
		getUser : function(){
			return this.$("input.login").val().replace(/[^\w\-]+/g, "");
		},
		
		// Call the query.
		//
		query : function(e){
			console.log("fetching:");
			this.collection.repos.user.set({login : this.getUser()})
			this.collection.repos.tags = this.collection;
			this.collection.repos.fetch();
			return false;
		}
		
		
	});

	return FiltersView;
});
	


