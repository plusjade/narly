define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/repo',
	'backbone/models/user'
], function($, _, Backbone, z,z, Repo, User){
	
  // The FiltersView is the main query interface in the UI.
	// The collection on this view is the Repo Collection we are displaying.
	// Here we monitor changes to the attached user model and tag collection.
	// When a change occurs we trigger events that update the Repo Collection
	// to reflect the user/tag-collection state.
	//
	return Backbone.View.extend({
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
			this.collection.tags.bind("reset", this.updateTags, this);
			
			this.collection.tags.bind("add", function(){
				this.collection.trigger("filterChange");
			}, this)
			
			this.collection.tags.bind("remove", function(){
				this.collection.trigger("filterChange");
			}, this)
			
		},
		
		getUser : function(){
			return this.$("input.login").val().replace(/[^\w\-]+/g, "");
		},
		
		getTag : function(){
			return this.$("input.tag").val().replace(/[^\w\-\.]+/g, "").toLowerCase();
		},
		
		// Parse the user submitted form for data.
		// Only trigger a router update if something has changed.
		parseForm : function(e){
			if(this.parseUser() || this.parseTags())
				this.collection.trigger("filterChange");
			
			e.preventDefault();
			return false;
		},
		
		parseUser : function(){
			var changed = false;
			if(this.collection.user.get("login") !== this.getUser()){
				this.collection.user.set({login : this.getUser()}, {silent : true});
				changed = true;
			}

			return changed;
		},
		
		parseTags : function(){
			var changed = false;
			var name = this.getTag();
			
			if(name !== ""){
				var tags = this.collection.tags.pluck("name");
				if($.inArray(name, tags) === -1){
					// silently add the tag since parseTags is called by
					// the form submit and we want only one trigger on change.
					this.collection.tags.add({name : name}, {silent : true});
					changed = true;
				}
			}	
			
			return changed;
		},
		
		// Remove a tag from the collection.
		remove : function(e){
			var name = $(e.currentTarget).text();
			var tagToRemove = null;
			this.collection.tags.each(function(tag){
				if(tag.get("name") == name) tagToRemove = tag;
			})
			this.collection.tags.remove(tagToRemove);
		},
		
		updateUser : function(){
			console.log("updateUser:"+ this.collection.user.get("login"));

			if(_.isEmpty(this.collection.user.get("login"))){
				this.$("a").first().hide();
				this.$("input.login").val("*");
			}
			else{
				this.$("input.login").val(this.collection.user.get("login"));
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

});
	