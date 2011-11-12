
$(function(){
	var currentUserLogin = $("#current_user_data").text();
// MODELS
	var Repo = Backbone.Model.extend({
		defaults : {
			"full_name" : "plusjade/plusjade",
			"name" : "name",
			"login" : "login",
		},
		initialize : function(){
			console.log("repo initialized");
			
			this.tags = new TagCollection;
	    this.tags.url = '/repos/' + this.get("full_name") + '/tags';

			this.userTags = new TagCollection;
			this.userTags.url = "/users/"+currentUserLogin+"/repos/"+ this.get("full_name") +"/tags";

			this.bind("change", function(){
				this.tags.setUrl(this);
				this.tags.fetch();
				
				this.userTags.setUrl(this);
				this.userTags.fetch();
			})
		}
		
	})
	
  var Tag = Backbone.Model.extend({
    defaults: {
      name: 'a tag',
			relative_count : "a",
      total: '=)'
    }
  });
	
// COLLECTIONS	
	var TagCollection = Backbone.Collection.extend({
		model : Tag,
		initialize : function(){
			console.log("tagcollection initialized");
		},

		setUrl : function(repo){
			this.url = "/repos/"+repo.get("full_name")+"/tags";
		}
		
	});
	
// VIEWS	
	RepoView = Backbone.View.extend({
		model : Repo,
		
		initialize : function(){
			
			this.model.bind("change", function(){
				$("#tag_panel_container")
					.find("a.repo_name")
					.text(this.get("full_name"))
					.find("input.full_name")
					.val(this.get("full_name"));
			})
		}
	});
	
	var TagView = Backbone.View.extend({
		el : "li",
		communityTmpl : $("#tagTemplateAdd").html(),
		personalTmpl : $("#tagTemplateRemove").html(),

		initialize : function(){
			console.log("new tagview");
		},
		
		renderCommunity : function(){
			return $.mustache(this.communityTmpl, this.model.attributes);
		},
		
		renderPersonal: function(){
			return $.mustache(this.personalTmpl, this.model.attributes);
    }
	});


	var TagCollectionView = Backbone.View.extend({
		el: '#add_tag_container', 
		initialize : function(){
			this.collection.bind("reset", this.render)
		},
		render : function(){
			console.log("re-render tag collection");
			var cache = "";
			_(this.models).each(function(tag){
				cache += new TagView({model : tag}).renderCommunity();
			})
			
			$("#add_tag_container")
				.html(cache)
				.find("li").hover(function(){
						$(this).find("span.options").show();
					}, function(){
						$(this).find("span.options").hide();
					}
				);
				
		},
	})


	
	// set the common tag panel repo and tagpanelrepo tags collection variables and just keep rewriting them.
	tagPanelRepo = new Repo();
	// ok show the repo View which is the tagPanel (one view);
	var repoView = new RepoView({model : tagPanelRepo});
	var tagsView = new TagCollectionView({collection :tagPanelRepo.tags});


	/* open tag panel to add a tag */
	$("a.add_tag").click(function(e){
		var full_name = $(this).attr("title");

		// event listeniers on "change" 
		tagPanelRepo.set({"full_name" : full_name});

		$("#filters_container").hide();
		$("#tag_panel_container").slideDown("fast")
		
		/*
		if (currentUserLogin !== ""){
			$.ajax({
				dataType: "json",
			  url: "/users/"+currentUserLogin+"/repos/"+ full_name +"/tags",
			  success: function ( data ) {
					var $container = $("#my_tags_on_repo").empty();
					$("#tagTemplateRemove").tmpl(data).appendTo($container);
					$container.find("li").hover(function(){
							$(this).find("span.options").show();
						}, function(){
							$(this).find("span.options").hide();
						}
					)
				}
			});
		}
		*/	
		e.preventDefault();
		return false;
	});


	$("#tag_panel").submit(function(e){
		var $form = $(this);
		showStatus.submitting();
		$.ajax({
		    dataType: "json",
		    url: $form.attr("action"),
				data : $form.serialize(),
		    success: function(rsp){
					showStatus.respond(rsp);
				}
		});
		e.preventDefault();
		return false;
	})

	$("a.tag_panel_close").click(function(e){
		$("#tag_panel_container").hide();
		$("#filters_container").slideDown("fast");
		e.preventDefault();
		return false;
	})
	
	/* Remove tag from a repo */
	$("#my_tags_on_repo").find("span.options").find("a.danger").live("click", function(e){
		var $tag = $(this);
		var tag = $tag.attr("title");
		if(confirm("Remove tag:'" +tag+ "' from this repo?")){
			showStatus.submitting();
			var full_name = $("#tag_panel").find("input.full_name").val();
			$.ajax({
			    dataType: "json",
			    url: "/untag?repo[full_name]="+full_name+"&tag="+tag+"",
			    success: function(rsp){
						showStatus.respond(rsp);
					}
			});
		}

		e.preventDefault();
		return false;
	})
	
	$("#add_tag_container").find("a").live("click", function(e){
		$(this).toggleClass("active");
		formatTags();
		e.preventDefault();
		return false;
	})
	
	
	function formatTags(){
		var activeTags = [];
		
		$("#add_tag_container").find("a.active").each(function(){
			activeTags.push($(this).attr("title"));
		});

		$("#tagging_input").val(activeTags.join(":"));
	}

})
