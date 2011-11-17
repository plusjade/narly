define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
], function($, _, Backbone){

	Tag = Backbone.Model.extend({
		// add tag for user on repo
		//
		add : function(){
			console.log("tag add: "+this.get("name"));
			var repo = this.collection.repo;
			
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
		remove : function(){
			console.log("tag remove: "+this.get("name"));
			var repo = this.collection.repo;
			
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