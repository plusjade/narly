define([
  'jquery',
  'Underscore',
  'Backbone',
	'jquery/showStatus',
], function($, _, Backbone){

	return Backbone.Model.extend({
		
		// Add validations so empty tags cannot be added to collections.
		//
		validate: function(attrs) {
	    if ($.trim(attrs.name) === "") {
	      return "name can't be blank";
	    }
		},
		
		// add tag for user on repo
		//
		add : function(){
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

});