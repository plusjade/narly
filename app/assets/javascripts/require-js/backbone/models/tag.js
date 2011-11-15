define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
], function($, _, Backbone){

	Tag = Backbone.Model.extend({
	   defaults: {
	     name: 'a tag',
			relative_count : "a",
	     total: '=)'
	   },
	
		// add tag for user on repo
		//
		add : function(repo, user){
			$.showStatus('submitting');
			$.ajax({
			    dataType: "json",
			    url: "/tag?repo[full_name]="+repo.get("full_name")+"&tag="+this.get("name"),
			    success: function(rsp){
						$.showStatus('respond', rsp);
						repo.refresh();
					}
			});
		},
	
		// remove a tag from repo with respect to user
		//
		remove : function(repo, user){
			$.showStatus('submitting');
			$.ajax({
			    dataType: "json",
			    url: "/untag?repo[full_name]="+repo.get("full_name")+"&tag="+this.get("name")+"",
			    success: function(rsp){
						$.showStatus('respond', rsp);
						repo.refresh();
					}
			});
		}
	
	});

	return Tag;
});