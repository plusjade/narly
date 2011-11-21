define([
  'jquery',
  'Underscore',
  'Backbone',
], function($, _, Backbone){
	
	return Backbone.Router.extend({

	  routes: {
	   	"users/:login/repos/tagged/:tags": "users_repos_tagged",
	 	  "users/:login": "users",
	  },
	
		users_repos_tagged : function(){
			console.log("users_repos_tagged route");
		},
		
		users : function(){
			console.log("users route");
		}

	});

});