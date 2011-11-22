define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
	'backbone/collections/tag_collection'
], function($, _, Backbone, z, TagCollection){
	Repo = Backbone.Model.extend({
		initialize : function(){
			this.tags = new TagCollection(this.get("tags"));
			this.tags.type = "repo";
			this.tags.setRepo(this);
			this.userTags = new TagCollection;
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