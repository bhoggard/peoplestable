$(
  $.getJSON('/twitter', function(data) {
    photos = $('#photos');
    $.each(data, function(index, value) {
      img        = $('<img />', { src: value.thumb_url, alt: value.screen_name });
      link       = $('<a />', { href: value.link_url, html: img });
      bottom     = 53 * Math.floor(index / 5)
      thumb_div  = $('<div />', { class: 'thumb thumb' + (index % 5).toString(), html: link })
        .css("bottom", bottom);
      if (bottom > 200 && bottom < 300) {
        photos.height(bottom)
      }
      photos.prepend(thumb_div);
    });
  })
);




