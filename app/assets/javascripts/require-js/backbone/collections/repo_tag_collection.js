define([
  'jquery',
  'Underscore',
  'Backbone',
	'backbone/models/tag'
], function($, _, Backbone, Tag){
	
	// A base collection for a Repo's tags.
	RepoTagCollection = Backbone.Collection.extend({
		model : Tag,
		setUrl : function(repo){
			this.url = "/repos/"+repo.get("full_name")+"/tags";
		}
	});

 	return RepoTagCollection;
});
