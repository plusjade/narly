define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/views/user_tag_view'
], function($, _, Backbone, z,z, UserTagView){
	
	// A view for a Tag Collection for a User.
	// This view is shown on the sidebar.
	//
	return Backbone.View.extend({
		initialize : function(){
			this.collection.bind("reset", this.render, this);
		},
	
		render : function(){
			var cache = [];
			$.each(this.collection.models, function(){
				cache.push(new UserTagView({model : this}).render());
			})
		
			$.fn.append.apply($(this.el).empty(), cache);
		}
	
	})

})
	
