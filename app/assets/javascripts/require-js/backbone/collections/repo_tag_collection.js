define([
  'jquery',
  'Underscore',
  'Backbone',
], function($, _, Backbone){
	
	// A base collection for a Repo's tags.
	RepoTagCollection = Backbone.Collection.extend({
		model : Tag,
		setUrl : function(repo){
			this.url = "/repos/"+repo.get("full_name")+"/tags";
		}
	});

 	return RepoTagCollection;
});
