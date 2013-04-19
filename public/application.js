var PeoplesTable = {}
PeoplesTable.counter = 0
PeoplesTable.delay_time = 0

PeoplesTable.image_div = function(image_data) {
  img    = $('<img />', { src: image_data.thumb_url, alt: image_data.screen_name })
    .slideDown('slow').hide().delay(PeoplesTable.delay_time).fadeIn('slow').rotate(Math.floor(15 - Math.random() * 30));
  link   = $('<a />', { target: '_blank', href: image_data.link_url, html: img });
  bottom = 53 * Math.floor(PeoplesTable.counter / 5);
  // if we're full, randomly place it
  if (PeoplesTable.counter > 54) {
    bottom = 53 * (Math.floor(1 + Math.random() * 8))
  }
  PeoplesTable.counter += 1;
  PeoplesTable.delay_time += 50;

  return $('<div />', { class: 'thumb', html: link })
    .css("bottom", bottom + Math.floor(1 + Math.random() * 8))
    .css("right", Math.floor(1 + Math.random() * 8) + (PeoplesTable.counter % 5) * 53)
    .css("z-index", Math.floor(1 + Math.random() * 20));
}

// load all photos in DB the first time, then only new ones
PeoplesTable.update_photos = function(firstTime) {
  if (firstTime) {
    url = '/all_photos';
  } else {
    url = '/photos';
  }
  $.getJSON(url, function(data) {
    photos_div = $('#photos');
    $.each(data, function(index, value) {
      photos_div.prepend(PeoplesTable.image_div(value));
    });
  })
}

$(function() {
  PeoplesTable.update_photos(true);
  setInterval(PeoplesTable.update_photos, 60 * 1000);
});

