require.config({
	baseUrl: "/assets/require-js",
  paths: {
    Underscore: 'libs/underscore/underscore',
    Backbone: 'libs/backbone/backbone'
  }

});

require([
	'jquery',
  'order!libs/underscore/underscore-min',
  'order!libs/backbone/backbone-0.5.3',
	"jquery/showStatus",
	"jquery/mustache",
	'app'
], function($,_,Backbone,z,z,App){
  App.initialize();
});
