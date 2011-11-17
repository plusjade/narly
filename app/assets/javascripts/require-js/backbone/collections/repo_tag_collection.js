define([
  'jquery',
  'Underscore',
  'Backbone',
	'backbone/models/tag'
], function($, _, Backbone, Tag){
	
	// A base collection for a Repo's tags.
	RepoTagCollection = Backbone.Collection.extend({
		model : Tag,
		repo : null,
		url : function(){
			return "/repos/"+this.repo.get("full_name")+"/tags";
		},
		setRepo : function(repo){
			this.repo = repo;
		}
	});

 	return RepoTagCollection;
});
