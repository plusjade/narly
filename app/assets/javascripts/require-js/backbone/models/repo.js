define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'backbone/collections/tags'
], function($, _, Backbone, z, Tags){
	Repo = Backbone.Model.extend({
		initialize : function(){
			this.tags = new Tags(this.get("tags"));
			this.tags.type = "repo";
			this.tags.setRepo(this);
			this.userTags = new Tags;
			this.userTags.type = "userRepo";
			this.userTags.setRepo(this);

			this.bind("change", function(){
				this.tags.setRepo(this);
			})
		},
		refresh : function(){
			this.tags.fetch();
			this.userTags.fetch();
		},
		css_id : function(){
			return "#repo-" + this.get("full_name").replace(/[^\w]/g, "-");
		}
	});

	return Repo;
});