define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache',
	'backbone/views/tag_view'
], function($, _, Backbone, z,z, TagView){
	
	// View for showing tag lists on repos. This should be present in two places.
	// When the collection changes the views should update right!?
	//
	return Backbone.View.extend({
		initialize : function(){
			this.collection.bind("reset", this.render, this);
		},
	
		render : function(){
			var type = this.options.type;
			var cache = [];
			$.each(this.collection.models, function(){
				if(type === "personal"){
					cache.push(new TagView({model : this}).renderPersonal());
				}
				else{
					cache.push(new TagView({model : this}).renderCommunity());
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

})
	
