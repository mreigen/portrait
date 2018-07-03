/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

window.setUpPusher = function(key) {
  Pusher.logToConsole = true;
  var pusher = new Pusher(key, {
    cluster: 'us2',
    encrypted: true
  });
  var channel = pusher.subscribe('survey-monkey-test-channel');
  channel.bind('image-processing-finished', function(data) {
    console.log(data.site); // debug
    // {site: {id: 17, image_url: 'asdf', status: 'succeeded'}
    $('#' + data.site.id + ' .status').html(data.site.status)
    $('#' + data.site.id + ' .image').html("<a href='" + data.site.image_url + "'>" + data.site.image_name + "</a>")
  });
}