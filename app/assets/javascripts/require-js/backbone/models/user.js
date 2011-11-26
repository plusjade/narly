define([
  'jquery',
  'Underscore',
  'Backbone',
  'backbone/collections/tags'
], function($, _, Backbone, Tags){
	
	return Backbone.Model.extend({
		tags : null,
		
		initialize : function(){
			console.log("init User");
			this.tags = new Tags();
			this.tags.type = "user";
			this.tags.owner = this;
		},
		
		url : function(){
			return "/users/" +this.get("login")+ "/profile/json";
		}
	
	});

});