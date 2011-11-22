define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/views/tag_view'
], function($, _, Backbone, z,z, TagView){
	
	// A view for the inline tags on a RepoView.
	//
	return Backbone.View.extend({
		initialize : function(){
			this.collection.bind("reset", this.render, this);
		},
	
		render : function(){
			var cache = [];
			$.each(this.collection.models, function(){
				cache.push(new TagView({model : this}).renderRepoTag());
			})
		
			$.fn.append.apply($(this.el).empty(), cache);
		}
	
	})

})
	
