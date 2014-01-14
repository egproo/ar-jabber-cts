$(document).ready(function() {
    $('.room-name').input_field_addons({ postfix: '@conference.syriatalk.biz' });

    var seller_typeahead_selector = '.typeahead-user[name="room[buyer_attributes][name]"]';
    var seller_info_div = function(seller_input) {
        return seller_input.parent().parent().parent().next();
    }

    $(seller_typeahead_selector).on('typeahead:uservalue', function(e, value) {
        if (value) {
            seller_info_div($(e.target)).slideDown();
        }
    });

    $(seller_typeahead_selector).on('typeahead:selected', function(e, datum) {
        seller_info_div($(e.target)).slideUp();
    });

    var tableContainer = $('#rooms');

    tableContainer.dataTable({
            sPaginationType: 'bootstrap',
            bProcessing: true,
            sAjaxSource: '/rooms.datatable',
            oLanguage: {
                sUrl: '/i18n/datatable.json'
            },
            bAutoWidth: false,
            aaSorting: [[7, 'asc']],
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
                    mData: 'created_at',
                    mRender: renderers.date,
                    sWidth: "10%"
                }, {
                    mData: 'duration_months',
                    sWidth: "5%",
                }, {
                    mData: 'last_payment.amount',
                    mRender: renderers.amount,
                    sWidth: "5%"
                }, {
                    mData: 'last_payment.created_at',
                    mRender: renderers.date,
                    sWidth: "10%"
                }, {
                    mData: 'next_payment_date',
                    mRender: renderers.nextPaymentDate,
                    sWidth: "10%"
                }, {
                    mData: 'next_amount_estimate',
                    mRender: renderers.amount,
                    sWidth: "10%"
            }]
    });
});
