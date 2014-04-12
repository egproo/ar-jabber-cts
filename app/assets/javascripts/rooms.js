$(document).on('decorate', function(e, updated) {
    $('.room-name').input_field_addons({ after: '@...' });

    var buyer_typeahead = $('.typeahead-user[name="room[buyer_attributes][jid]"]');
    var buyer_info_div = function(buyer_input) {
        return buyer_input.parent().parent().parent().next();
    };

    var payment_fs = $('#payment_fs');

    var buyer_changed = function(value) {
        if (original_buyer && value === original_buyer) {
            payment_fs.slideUp();
        } else {
            payment_fs.slideDown();
        }
    };

    buyer_typeahead.on('typeahead:uservalue', function(e, value) {
        if (value) {
            buyer_info_div($(e.target)).slideDown();
        }
        buyer_changed(value);
    });

    buyer_typeahead.on('typeahead:selected', function(e, value) {
        buyer_info_div($(e.target)).slideUp();
        buyer_changed(value);
    });
});

$(document).ready(function() {
    $('form').on('ajax:success', function(e, data, status, xhr) {
        window.location.href = data.location;
    });

    $('form').on('ajax:error', function(e, xhr, status, error) {
        $(this).html(xhr.responseText);
        $(document).trigger('decorate', this);
    });
});
