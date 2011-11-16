define([
  'jquery',
  'Underscore',
  'Backbone',
	'backbone/models/user',
	'jquery/showStatus',
	'backbone/collections/repo_tag_collection',
	'backbone/collections/user_repo_tag_collection',
	'app'
], function($, _, Backbone, User, z, RepTagCollection, UserRepoTagCollection, App){
	Repo = Backbone.Model.extend({
		initialize : function(){
			this.tags = new RepoTagCollection;
			this.tags.setUrl(this);
		
			this.userTags = new UserRepoTagCollection;
			this.userTags.setUrl(App.currentUser, this);
		
			this.bind("change", function(){
				this.tags.setUrl(this);
				this.userTags.setUrl(App.currentUser, this);
			})
		},

		refresh : function(){
			this.tags.fetch();
			this.userTags.fetch();
		}
	});

	return Repo;
});