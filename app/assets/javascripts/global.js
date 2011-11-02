
$(function(){
	$("a.add_tag").click(function(e){
		$("#filters_container").hide();
		$("#tag_panel_container").slideDown("fast")
			.find("a.repo_name").text($(this).attr("title"));
		$("#tag_panel_container")
			.find("input.ghid").val($(this).attr("rel"));
			
		e.preventDefault();
		return false;
	});

	$("a.tag_panel_close").click(function(e){
		$("#tag_panel_container").hide();
		$("#filters_container").slideDown("fast");
		e.preventDefault();
		return false;
	})
	
	$("#add_tag_container").find("a").click(function(e){
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