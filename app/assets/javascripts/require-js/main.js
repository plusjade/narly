require.config({
	baseUrl: "/assets/require-js",
  paths: {
    Underscore: 'libs/underscore/underscore',
    Backbone: 'libs/backbone/backbone'
  }

});

require([

  // Load our app module and pass it to our definition function
  'app',

  // Some plugins have to be loaded in order due to there non AMD compliance
  // Because these scripts are not "modules" they do not pass any values to the definition function below
	'order!jquery',
  'order!libs/underscore/underscore-min',
  'order!libs/backbone/backbone-0.5.3',
	"jquery/showStatus",
	"jquery/mustache",

], function(App){
  App.initialize();
});
