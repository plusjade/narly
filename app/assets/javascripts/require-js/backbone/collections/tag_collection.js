define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/models/tag'
], function($, _, Backbone, Tag){
	
	return Backbone.Collection.extend({
		model : Tag,
		initialize : function(){
			console.log("tag collection");
		},
		url : function(){
			return "blah";
		}
		
	})

});
