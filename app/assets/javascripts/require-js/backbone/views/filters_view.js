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
			"submit form" : "parseForm",
			"click span" : "remove",
		},
		
		initialize : function(){
			this.user = new User({login : this.getUser()});

			// Manually set the user on the repo collection since the collection
			// is bootstrapped into place via serverside objects. 
			this.collection.repos.user = this.user;
			
			this.user.bind("change:login", this.query, this);
			this.user.bind("change:login", this.fetchUser, this);
			this.user.bind("change", this.updateUser, this);
			
			this.collection.bind("add", this.query, this);
			this.collection.bind("add", this.updateTags, this);

			this.collection.bind("remove", this.query, this);
			this.collection.bind("remove", this.updateTags, this);
		},
		
		getUser : function(){
			return this.$("input.login").val().replace(/[^\w\-]+/g, "");
		},
		
		parseForm : function(e){
			this.user.set({login : this.getUser()});
			this.parseTags();

			e.preventDefault();
			return false;
		},
				
		fetchUser : function(){
			if(this.user.get("login") !== "") this.user.fetch();
		},
		
		parseTags : function(){
			var name = this.$("input.tag").val().toLowerCase();
			var exists = false;
			this.collection.each(function(tag){
				if(tag.get("name") === name) exists = true;
			})
			if(!exists)
				this.collection.add({name : name});
		},
		
		// Remove a tag from the collection.
		remove : function(e){
			var name = $(e.currentTarget).text();
			var tagToRemove = null;
			this.collection.each(function(tag){
				if(tag.get("name").match(name)) tagToRemove = tag;
			})
			this.collection.remove(tagToRemove);
		},
		
		updateUser : function(){
			if(this.user.get("login") === "")
				this.$("a").first().hide();
			else{
				this.$("a").first().show().attr("href", "/users/"+this.user.get("login"))
					.find("img").attr("src", this.user.get("avatar_url"));
			}
		},
		
		// Update the UI to reflect the tag collection.
		// Should only be called if the user or tags have changed.
		//
		updateTags : function(){
			var data = "";
			this.collection.each(function(tag){
				data += "<span>" + tag.get("name") + "</span> + ";
			})
			this.$("p").html(data);
			this.$("input.tag").val("");
		},
		
		// Call the query.
		//
		query : function(){
			this.collection.repos.user = this.user;
			this.collection.repos.tags = this.collection;
			this.collection.repos.fetch();
			return false;
		}
		
		
	});

	return FiltersView;
});
	