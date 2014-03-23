$(document).on('decorate', function(e, updated) {
    $('.room-name').input_field_addons({ after: '@...' });

    var seller_typeahead = $('.typeahead-user[name="room[buyer_attributes][name]"]');
    var seller_info_div = function(seller_input) {
        return seller_input.parent().parent().parent().next();
    };

    var payment_fs = $('#payment_fs');

    seller_typeahead.on('typeahead:uservalue', function(e, value) {
        if (value) {
            seller_info_div($(e.target)).slideDown();
        }
        if (value === original_buyer) {
            payment_fs.slideUp();
        } else {
            payment_fs.slideDown();
        }
    });

    seller_typeahead.on('typeahead:selected', function(e, value) {
        seller_info_div($(e.target)).slideUp();
        if (value === original_buyer) {
            payment_fs.slideUp();
        } else {
            payment_fs.slideDown();
        }
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

    setupDataTable({
            aaData: roomsData,
            aaSorting: [[7, 'asc']],
            fnRowCallback: function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {
                var cls = renderers.roomClass(aData.next_payment_date, aData.active);

                if (cls) {
                    $(nRow).addClass(cls + '_row');
                }
            },
            aoColumns: [{
                    mData: null,
                    mRender: function(data, type, row) { return renderers.contract(row, type, row); },
                    sWidth: "15%"
                }, {
                    mData: 'buyer',
                    mRender: renderers.user,
                    sWidth: "25%"
                }, {
                    mData: 'seller',
                    mRender: renderers.user,
                    sWidth: "10%"
                }, {
                    mData: 'last_payment.effective_months',
                    sWidth: "5%",
                }, {
                    mData: null,
                    mRender: renderers.lastPaymentAmount,
                    sWidth: "5%"
                }, {
                    mData: null,
                    mRender: renderers.lastPaymentDate,
                    sType: "date",
                    sWidth: "10%"
                }, {
                    mData: 'next_payment_date',
                    mRender: renderers.nextPaymentDate,
                    sWidth: "10%"
                }, {
                    mData: 'occupants_number',
                    sWidth: "5%"
                }, {
                    mData: 'last_message_at',
                    mRender: renderers.dateTimeFromUNIX,
                    sWidth: "15%"
            }]
    });
});
