define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'jquery/mustache'
], function($, _, Backbone){
	
	// View for showing tag lists on repos. This should be present in two places.
	// When the collection changes the views should update right!?
	//
	RepoTagCollectionView = Backbone.View.extend({
		initialize : function(){
			console.log("RepoTagCollectionView initialized");
			this.collection.bind("reset", this.render, this);
		},
	
		render : function(){
			console.log("collection rendered");
			var type = this.options.type;
			var cache = [];
			_(this.collection.models).each(function(tag){
				if(type === "personal"){
					cache.push(new TagView({model : tag}).renderPersonal());
				}
				else{
					cache.push(new TagView({model : tag}).renderCommunity());
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

	return RepoTagCollectionView;
})
	
