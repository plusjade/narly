define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/views/user_repo_tag_view'
], function($, _, Backbone, z,z, UserRepoTagView){
	
	// A view for the Tag Collection on a Repo relative to a given User.
	// This view is shown in the TagPanelView.
	//
	return Backbone.View.extend({
		initialize : function(){
			this.collection.bind("reset", this.render, this);
		},
	
		render : function(){
			var cache = [];
			$.each(this.collection.models, function(){
					cache.push(new UserRepoTagView({model : this}).render());
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

})
	
