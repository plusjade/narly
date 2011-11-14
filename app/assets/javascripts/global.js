
$(function(){
	var currentUserLogin = $("#current_user_data").text();
	
// MODELS
	var User = Backbone.Model.extend({
		
	})

	var Repo = Backbone.Model.extend({
		defaults : {
			"full_name" : "plusjade/plusjade",
			"name" : "name",
			"login" : "login",
		},
		initialize : function(){
			console.log("repo initialized");
			
			this.tags = new RepoTagCollection;
			this.userTags = new UserRepoTagCollection;

			this.bind("change", function(){
				this.tags.setUrl(this);
				this.userTags.setUrl("plusjade", this);
				this.refresh();
			})
		},
		refresh : function(){
			this.tags.fetch();
			this.userTags.fetch();
		}
		
	})
	
  var Tag = Backbone.Model.extend({
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

	var RepoTagCollection = Backbone.Collection.extend({
		model : Tag,
		initialize : function(){

		},
		
		setUrl : function(repo){
			this.url = "/repos/"+repo.get("full_name")+"/tags";
		}
	});
	
	var UserRepoTagCollection = Backbone.Collection.extend({
		model : Tag,
		initialize : function(){
	
		},

		setUrl : function(user, repo){
			this.url = "/users/"+user+"/repos/"+repo.get("full_name")+"/tags";
		}
	});
	
	
	
// VIEWS	

	// This tag view holds all tag templates.
	//
	var TagView = Backbone.View.extend({
		tagName : "li",
		communityTmpl : $("#tagTemplateAdd").html(),
		personalTmpl : $("#tagTemplateRemove").html(),
		
		events : {
			"click .success" : "add",
			"click .danger" : "remove",
		},
		
		add : function(){
			this.model.add(tagPanelRepo, currentUser);
		},
		remove : function(){
			this.model.remove(tagPanelRepo, currentUser);
		},
		
		renderCommunity : function(){
			return $(this.el).html($.mustache(this.communityTmpl, this.model.attributes));
		},
		
		renderPersonal: function(){
			return $(this.el).html($.mustache(this.personalTmpl, this.model.attributes));
    }
	});
	
	
	// TagPanelRepoView has two child views for public and personal tag lists.
	//
	RepoView = Backbone.View.extend({
		el : "#tag_panel_container",
		model : Repo,
		tagsView : "",
		usertagsView : "",
		
		events : {
			"submit form" : "saveTags"
		},
		
		initialize : function(){
			this.tagsView = new RepoTagCollectionView({
				collection : this.model.tags, 
				type : "public", 
				el : "#add_tag_container"
			});
			this.usertagsView = new RepoTagCollectionView({
				collection : this.model.userTags,
				type : "personal",
				el : "#my_tags_on_repo"
			});
			
			this.model.bind("change", function(){
				this.$("a.repo_name").text(this.model.get("full_name"))
				this.$("input.full_name").val(this.model.get("full_name"));
			}, this)
			
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
	
	// View for showing tag lists on repos
	var RepoTagCollectionView = Backbone.View.extend({
		initialize : function(){
			this.collection.bind("reset", this.render, this);
		},
		
		render : function(){
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






	var currentUser = new User({"login" : currentUserLogin})

	// set the common tag panel repo and tagpanelrepo tags collection variables and just keep rewriting them.
	tagPanelRepo = new Repo();
	// ok show the repo View which is the tagPanel (one view);
	var repoView = new RepoView({model : tagPanelRepo});

	/* open tag panel to add a tag */
	$("a.add_tag").click(function(e){
		tagPanelRepo.set({"full_name" : $(this).attr("title")});

		$("#filters_container").hide();
		$("#tag_panel_container").slideDown("fast")	
		e.preventDefault();
		return false;
	});


	$("a.tag_panel_close").click(function(e){
		$("#tag_panel_container").hide();
		$("#filters_container").slideDown("fast");
		e.preventDefault();
		return false;
	})
	

})
