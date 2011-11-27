define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/models/user_icon',
	'backbone/views/user_icon_view'
], function($, _, Backbone, z,z, UserIcon, UserIconView){
	
	// A view for a collection of user icons.
	//
 	return Backbone.View.extend({
		model : UserIcon,
	
		events : {
			"click a" : "clickIcon"
		},
		
		initialize : function(){
			this.collection.bind("reset", this.render, this);
		},
		
		render: function(){
			var cache = [];
			this.collection.each(function(user){
				cache.push(new UserIconView({model : user}).render());
			})
		
			$.fn.append.apply($(this.el).empty(), cache);
		},
			
		clickIcon : function(e){
			this.collection.trigger("navigate", e.currentTarget.pathname);
			e.preventDefault();
			return false;
		}
	
	});

});
	
