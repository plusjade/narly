define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/tag'
], function($, _, Backbone, z,z, Tag){
	
	FiltersView = Backbone.View.extend({
		model : Tag,
		el : "#filters",
		
		events : {
			"submit form" : "parseInput",
			"click span" : "remove",
			"click button.query" : "query"
		},
		
		initialize : function(){
			this.collection.bind("add", this.update, this);
			this.collection.bind("remove", this.update, this);
		},

		parseInput : function(){
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
				data += " + <span>" + tag.get("name") + "</span>";
			})
			this.$("p").html(data);
			this.$("input.tag").val("");

			//this.query();
		},
		
		// build the correct query Url based on the current filters.
		//
		url : function(){
			var url = "/";
			var login = this.$("input.login").val();
			var tagNames = this.collection.pluck("name");
			var userPath = "/users/" + login;
			var tagsPath = "/repos/tagged/" + tagNames.join(":");
			
			if(tagNames.length > 0)
				if(login === "") url = tagsPath;
				else url = userPath + tagsPath;
			else
				if(login === "") url = "/repos";
				else  url = userPath;
			
			console.log("url");	
			console.log(url);	
			return url;	
		},
		
		// Call the query.
		//
		query : function(e){
			window.location.href = this.url();
			e.preventDefault();
			return false
		}
		
		
	});

	return FiltersView;
});
	


