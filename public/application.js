$(
  $.getJSON('/twitter', function(data) {
    photos = $('#photos');
    $.each(data, function(index, value) {
      img        = $('<img />', { src: value.thumb_url, alt: value.screen_name });
      link       = $('<a />', { href: value.link_url, html: img });
      bottom     = 53 * Math.floor(index / 5);

      // if we're full, randomly place it
      if (index > 49) {
        bottom = 53 * (Math.floor(1 + Math.random() * 8))
      }
      thumb_div  = $('<div />', { class: 'thumb thumb' + (index % 5).toString(), html: link })
        .css("bottom", bottom);
      photos.prepend(thumb_div);
    });
  })
);




