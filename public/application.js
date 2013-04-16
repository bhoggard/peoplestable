var Image = Backbone.Model.extend({});

var ImageStore = Backbone.Collection.extend({
  model: Image,
  url: '/twitter'
});

var images = new ImageStore;
