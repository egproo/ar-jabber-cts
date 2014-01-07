$(document).ready(function() {
    $('.room-name').input_field_addons({ postfix: '@conference.syriatalk.biz' });

    var tableContainer = $('#contracts');

    tableContainer.dataTable({
            sPaginationType: 'bootstrap',
            bProcessing: true,
            sAjaxSource: '/contracts.datatable',
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
