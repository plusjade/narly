
$(function(){
	var currentUserLogin = $("#current_user_data").text();

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
	
	$("a.add_tag").click(function(e){
		var ghid = $(this).attr("rel");

		$("#filters_container").hide();
		$("#tag_panel_container").slideDown("fast")
			.find("a.repo_name").text($(this).attr("title"));
		$("#tag_panel_container")
			.find("input.ghid").val(ghid);
		
		if (currentUserLogin !== ""){
			$.ajax({
				dataType: "json",
			  url: "/users/"+currentUserLogin+"/repos/"+ ghid +"/tags",
			  success: addMyTags
			});
			$.ajax({
			  dataType: "json",
			  url: "/repos/"+ ghid +"/tags",
			  success: addTopTags
			});
		}
			
		e.preventDefault();
		return false;
	});


	$("a.tag_panel_close").click(function(e){
		$("#tag_panel_container").hide();
		$("#filters_container").slideDown("fast");
		e.preventDefault();
		return false;
	})
	
	/* Remove tag from a repo */
	$("#my_tags_on_repo").find("a").live("click", function(e){
		var $tag = $(this);
		var tag = $tag.attr("title");
		if(confirm("Remove tag:'" +tag+ "' from this repo?")){
			showStatus.submitting();
			var ghid = $("#tag_panel").find("input.ghid").val();
			$.ajax({
			    dataType: "json",
			    url: "/untag?repo[ghid]="+ghid+"&tag="+tag+"",
			    success: function(rsp){
						showStatus.respond(rsp);
						$tag.remove();
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

	function addTopTags( data ) {
	  $("#tagTemplate").tmpl(data).appendTo($("#add_tag_container").empty());
	}
	
	function addMyTags( data ) {
		
	  $("#tagTemplate").tmpl(data).appendTo($("#my_tags_on_repo").empty());
	}
	
})