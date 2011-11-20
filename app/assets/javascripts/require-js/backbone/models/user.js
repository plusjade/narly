define([
  'jquery',
  'Underscore',
  'Backbone',
], function($, _, Backbone){
	
	User = Backbone.Model.extend({
		
		url : function(){
			return "/users/" +this.get("login")+ "/profile/json";
		}
	
	});

	return User;
});