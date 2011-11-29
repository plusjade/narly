define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/collections/tags'
], function($, _, Backbone, Tags){
	
	return Backbone.Model.extend({
		tags : null,
		
		get : function(attribute) {
			var value = Backbone.Model.prototype.get.call(this, attribute);
			return _.isUndefined(value) ? "" : value;
		},
		
		initialize : function(){
			console.log("init User");
			this.tags = new Tags();
			this.tags.owner = this;
		},
		
		url : function(){
			return "/users/" +this.get("login")+ "/profile/json";
		}
	
	});

});