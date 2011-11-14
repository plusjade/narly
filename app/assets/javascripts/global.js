
$(function(){

// MODELS
// ==================================================================

	User = Backbone.Model.extend({
		
	});

	//  Models a basic repo object
  //
	Repo = Backbone.Model.extend({
		
		initialize : function(){
			this.tags = new RepoTagCollection;
			this.tags.setUrl(this);
			
			this.userTags = new UserRepoTagCollection;
			this.userTags.setUrl(CurrentUser, this);
			
			this.bind("change", function(){
				this.tags.setUrl(this);
				this.userTags.setUrl(CurrentUser, this);
			})
		},

		refresh : function(){
			this.tags.fetch();
			this.userTags.fetch();
		}
	});
	

	Tag = Backbone.Model.extend({
    defaults: {
      name: 'a tag',
			relative_count : "a",
      total: '=)'
    },
		
		// add tag for user on repo
		//
		add : function(repo, user){
			showStatus.submitting();
			$.ajax({
			    dataType: "json",
			    url: "/tag?repo[full_name]="+repo.get("full_name")+"&tag="+this.get("name"),
			    success: function(rsp){
						showStatus.respond(rsp);
						repo.refresh();
					}
			});
		},
		
		// remove a tag from repo with respect to user
		//
		remove : function(repo, user){
			showStatus.submitting();
			$.ajax({
			    dataType: "json",
			    url: "/untag?repo[full_name]="+repo.get("full_name")+"&tag="+this.get("name")+"",
			    success: function(rsp){
						showStatus.respond(rsp);
						repo.refresh();
					}
			});
		}
		
		
  });
	
	
// COLLECTIONS	
// ==================================================================

	// A base collection for a Repo's tags.
	RepoTagCollection = Backbone.Collection.extend({
		model : Tag,
		setUrl : function(repo){
			this.url = "/repos/"+repo.get("full_name")+"/tags";
		}
	});
	
	// A collection for a Repo's tags made by User.
	//
	UserRepoTagCollection = Backbone.Collection.extend({
		model : Tag,
		setUrl : function(user, repo){
			this.url = "/users/"+user.get("login")+"/repos/"+repo.get("full_name")+"/tags";
		}
	});
	

// VIEWS	
// ==================================================================


	// This tag view holds all tag templates.
	//
	TagView = Backbone.View.extend({
		tagName : "li",
		communityTmpl : $("#tagTemplateAdd").html(),
		personalTmpl : $("#tagTemplateRemove").html(),
		
		events : {
			"click .success" : "add",
			"click .danger" : "remove",
		},
		
		add : function(){
			this.model.add(MainTagPanelView.model, CurrentUser);
		},
		remove : function(){
			this.model.remove(MainTagPanelView.model, CurrentUser);
		},
		
		renderCommunity : function(){
			return $(this.el).html($.mustache(this.communityTmpl, this.model.attributes));
		},
		
		renderPersonal: function(){
			return $(this.el).html($.mustache(this.personalTmpl, this.model.attributes));
    }
	});
	
	
	RepoView = Backbone.View.extend({
		model : Repo,
		events : {
			"click .add_tag" : "showPanel"
		},

		// Show this repo in the singular MainTagPanelView window
		showPanel : function(){
			MainTagPanelView.render(this.model);
		}
		
	})
	
	
	// TagPanel has two child views for public and personal tag lists.
	//
	TagPanelView = Backbone.View.extend({
		el : "#tag_panel_container",
		model : Repo,
		events : {
			"submit form" : "saveTags"
		},
		render : function(repo){
			console.log("Render TagPanelView");
			
			// reset the repo
			this.model = repo;
			
			// build the UserTag view
			this.tagsView = new RepoTagCollectionView({
				collection : this.model.tags, 
				type : "public", 
				el : "#add_tag_container"
			});
			this.tagsView.render();

			// build the UserTag view
			this.userTagsView = new RepoTagCollectionView({
				collection : this.model.userTags,
				type : "personal",
				el : "#my_tags_on_repo"
			});
			// only fetch this when the tagPanel opens (which is now).
			this.model.userTags.fetch();
			
			this.$("a.repo_name").text(this.model.get("full_name"))
			this.$("input.full_name").val(this.model.get("full_name"));

			$("#filters_container").hide();
			$("#tag_panel_container").slideDown("fast")
		},
		
		saveTags : function(){
			showStatus.submitting();
			var repo = this.model;
			$.ajax({
			    dataType: "json",
			    url: this.$("form").attr("action"),
					data : this.$("form").serialize(),
			    success: function(rsp){
						showStatus.respond(rsp);
						repo.refresh();
					}
			});
			return false;
		}
		
	});
	
	// View for showing tag lists on repos. This should be present in two places.
	// When the collection changes the views should update right!?
	//
	RepoTagCollectionView = Backbone.View.extend({
		initialize : function(){
			console.log("RepoTagCollectionView initialized");
			this.collection.bind("reset", this.render, this);
		},
		
		render : function(){
			console.log("collection rendered");
			var type = this.options.type;
			var cache = [];
			_(this.collection.models).each(function(tag){
				if(type === "public"){
					cache.push(new TagView({model : tag}).renderCommunity());
				}
				else{
					cache.push(new TagView({model : tag}).renderPersonal());
				}
			})
			
			$.fn.append.apply($(this.el).empty(), cache);
			
			$(this.el).find("li").hover(function(){
						$(this).find("span.options").show();
					}, function(){
						$(this).find("span.options").hide();
					}
				);
		}
		
	})






	MainTagPanelView = new TagPanelView;
	CurrentUser = new User({"login" : "plusjade"});


	$("a.tag_panel_close").click(function(e){
		$("#tag_panel_container").hide();
		$("#filters_container").slideDown("fast");
		e.preventDefault();
		return false;
	})
	

})
