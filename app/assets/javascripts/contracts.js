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
                    mRender: function(data, type, row) { return renderers.contract(row, type, row); }
                }, {
                    mData: 'buyer',
                    mRender: renderers.user
                }, {
                    mData: 'seller',
                    mRender: renderers.user
                }, {
                    mData: 'created_at',
                    mRender: renderers.date
                }, {
                    mData: 'duration_months'
                }, {
                    mData: 'last_payment.amount',
                    mRender: renderers.amount
                }, {
                    mData: 'last_payment.created_at',
                    mRender: renderers.date
                }, {
                    mData: 'next_payment_date',
                    mRender: renderers.nextPaymentDate
                }, {
                    mData: 'next_amount_estimate',
                    mRender: renderers.amount
            }]
    });
});
