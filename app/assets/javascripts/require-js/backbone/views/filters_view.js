define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/repo',
	'backbone/models/user'
], function($, _, Backbone, z,z, Repo, User){
	
	FiltersView = Backbone.View.extend({
		model : Repo,
		user : User,
		el : "#filters",
		
		events : {
			"submit form" : "parseForm",
			"click span" : "remove",
		},
		
		initialize : function(){
			// Manually set the user on the repo collection since the collection
			// is bootstrapped into place via serverside objects. 
			this.collection.user.set({login : this.getUser()}, {silent:true});
			this.collection.user.bind("change", this.updateUser, this);
			
			// tags
			this.collection.tags.bind("add", this.updateTags, this);
			this.collection.tags.bind("remove", this.updateTags, this);
		},
		
		getUser : function(){
			return this.$("input.login").val().replace(/[^\w\-]+/g, "");
		},
		
		parseForm : function(e){
			this.collection.user.set({login : this.getUser()});
			this.parseTags();

			e.preventDefault();
			return false;
		},
		
		parseTags : function(){
			var name = this.$("input.tag").val().toLowerCase();
			var exists = false;
			this.collection.tags.each(function(tag){
				if(tag.get("name") === name) exists = true;
			})
			if(!exists)
				this.collection.tags.add({name : name});
		},
		
		// Remove a tag from the collection.
		remove : function(e){
			var name = $(e.currentTarget).text();
			var tagToRemove = null;
			this.collection.tags.each(function(tag){
				if(tag.get("name").match(name)) tagToRemove = tag;
			})
			this.collection.tags.remove(tagToRemove);
		},
		
		updateUser : function(){
			if(this.collection.user.get("login") === "")
				this.$("a").first().hide();
			else{
				this.$("a").first().show().attr("href", "/users/"+this.collection.user.get("login"))
					.find("img").attr("src", this.collection.user.get("avatar_url"));
			}
		},
		
		// Update the UI to reflect the tag collection.
		// Should only be called if the user or tags have changed.
		//
		updateTags : function(){
			var data = "";
			this.collection.tags.each(function(tag){
				data += "<span>" + tag.get("name") + "</span> + ";
			})
			this.$("p").html(data);
			this.$("input.tag").val("");
		}
		
	});

	return FiltersView;
});
	