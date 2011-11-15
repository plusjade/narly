define([
  'jquery',
  'Underscore',
  'Backbone',
	
	'backbone/models/user',

	'jquery/showStatus',
	'backbone/collections/repo_tag_collection',
	'backbone/collections/user_repo_tag_collection'
], function($, _, Backbone, User){
	CurrentUser = new User({"login" : "plusjade"});
	
	Repo = Backbone.Model.extend({
		initialize : function(){
			this.tags = new RepoTagCollection;
			this.tags.setUrl(this);
		
			this.userTags = new UserRepoTagCollection;
			this.userTags.setUrl(CurrentUser, this);
		
			this.bind("change", function(){
				this.tags.setUrl(this);
				this.userTags.setUrl(CurrentUser, this);
			})
		},

		refresh : function(){
			this.tags.fetch();
			this.userTags.fetch();
		}
	});

	return Repo;
});