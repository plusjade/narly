define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',

	//'backbone/models/repo',
	'backbone/models/user',
	//'backbone/models/tag',

	//'backbone/collections/repo_tag_collection',
	//'backbone/collections/user_repo_tag_collection',
	
	//'backbone/views/repo_tag_collection_view',
	//'backbone/views/repo_view',
	'backbone/views/tag_panel_view'
	//'backbone/views/tag_view'
], function($, _, Backbone, z,z, 
	User, TagPanelView
	){
		
	var App = {
		initialize : function(){
			App.currentUser = new User({"login" : $("head").attr("rel")});
			App.mainTagPanelView = new TagPanelView;
			
			$(function(){
				console.log("DOM ready");
				$("a.tag_panel_close").click(function(e){
					$("#tag_panel_container").hide();
					$("#filters_container").slideDown("fast");
					e.preventDefault();
					return false;
				})
			})
		}
	}
	
	// Return our App object which should require the references we need so our other modules can use them.
	// Remember everything is freaking in a closure so nothing is in the global namespace
	// I.E. you can't use anything without having references.
  return App;
	
});
