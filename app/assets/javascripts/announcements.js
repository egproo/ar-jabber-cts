$(document).on('decorate', function(e, updated) {
    var seller_typeahead = $('.typeahead-user[name="announcement[buyer_attributes][jid]"]');
    var seller_info_div = function(seller_input) {
        return seller_input.parent().parent().parent().next();
    };

    seller_typeahead.on('typeahead:uservalue', function(e, value) {
        if (value) {
            seller_info_div($(e.target)).slideDown();
        }
    });

    seller_typeahead.on('typeahead:selected', function(e, value) {
        seller_info_div($(e.target)).slideUp();
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
