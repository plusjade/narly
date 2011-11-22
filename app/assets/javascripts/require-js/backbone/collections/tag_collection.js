define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag'
], function($, _, Backbone, Tag){
	
	return Backbone.Collection.extend({
		model : Tag,

		url : function(){
			return "blah";
		},
		
		resetFromTagString : function(str){
			var cache = [];
			
			$.each(str.split(":"), function(){
				cache.push({name : this});
			});
			
			this.reset(cache);
		}
	})

});
