define([
  'jquery',
  'Underscore',
  'Backbone',
], function($, _, Backbone){
	
	return Backbone.Router.extend({

	  routes: {
	   	"repos/tagged/*tags": "repos_tagged",
	   	"users/:login/repos/tagged/*tags": "users_repos_tagged",
	 	  "users/:login": "users",
	  }
			
	});

});