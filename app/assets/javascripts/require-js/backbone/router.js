define([
  'jquery',
  'Underscore',
  'Backbone',
], function($, _, Backbone){
	
	return Backbone.Router.extend({

	  routes: {
	   	"users/:login/repos/tagged/*tags": "users_repos_tagged",
	 	  "users/:login": "users",
	  }
			
	});

});