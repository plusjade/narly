define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'backbone/collections/repo_tag_collection',
	'backbone/collections/user_repo_tag_collection'
], function($, _, Backbone, z, RepTagCollection, UserRepoTagCollection){
	Repo = Backbone.Model.extend({
		initialize : function(){
			this.tags = new RepoTagCollection;
			this.tags.setRepo(this);
			
			this.userTags = new UserRepoTagCollection;
			this.userTags.setRepo(this);

			this.bind("change", function(){
				this.tags.setRepo(this);
			})
		},
		setUser : function(user){
			this.user = user;
			this.userTags.setUser(user);
		},
		refresh : function(){
			this.tags.fetch();
			this.userTags.fetch();
		}
	});

	return Repo;
});