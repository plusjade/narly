define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/views/tag_view'
], function($, _, Backbone, z,z, TagView){
	
	// View for showing tag lists on repos. This should be present in two places.
	//
	return Backbone.View.extend({
		initialize : function(){
			this.collection.bind("reset", this.render, this);
		},
	
		render : function(){
			var cache = [];
			$.each(this.collection.models, function(){
				cache.push(new TagView({model : this}).renderUserTag());
			})
		
			$.fn.append.apply($(this.el).empty(), cache);
		}
	
	})

})
	
