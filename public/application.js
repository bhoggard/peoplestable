$(
  $.getJSON('/twitter', function(data) {
    photos = $('#photos');
    $.each(data, function(index, value) {
      img_id = "image_" + index
      img    = $('<img />', { id: img_id, src: value.thumb_url, alt: value.screen_name }).rotate(Math.floor(15 - Math.random() * 30));
      link   = $('<a />', { href: value.link_url, html: img });
      bottom = 53 * Math.floor(index / 5);

      // if we're full, randomly place it
      if (index > 44) {
        bottom = 53 * (Math.floor(1 + Math.random() * 8))
      }

      thumb_div = $('<div />', { class: 'thumb', html: link })
        .css("bottom", bottom + Math.floor(1 + Math.random() * 8))
        .css("right", Math.floor(1 + Math.random() * 8) + (index % 5) * 53)
        .css("z-index", Math.floor(1 + Math.random() * 20));
      photos.prepend(thumb_div);
    });
  })
);




