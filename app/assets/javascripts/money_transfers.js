$(document).ready(function() {

    var tableContainer = $('#money_transfers');

    tableContainer.dataTable({
        sPaginationType: 'bootstrap',
        bProcessing: true,
        sAjaxSource: '/money_transfers.datatable',
        oLanguage: {
            sUrl: '/i18n/datatable.json'
        },
        aaSorting: [[3, 'desc']],

        aoColumns: [
            {
                mData: "sender",
                mRender: renderers.user,
                sWidth: "40%"
            }, {
                mData: "receiver",
                mRender: renderers.user,
                sWidth: "20%"
            }, {
                mData: "amount",
                mRender: renderers.amount,
                sWidth: "10%"
            }, {
                mData: "created_at",
                mRender: renderers.date,
                sWidth: "30%"
            },
        ]
    });
});
