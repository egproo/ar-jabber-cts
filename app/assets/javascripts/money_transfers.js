$(document).ready(function() {

    var tableContainer = $('#money_transfers');

    tableContainer.dataTable({
        sPaginationType: 'bootstrap',
        bProcessing: true,
        sAjaxSource: '/money_transfers.datatable',
        oLanguage: {
        sUrl: '/i18n/datatable.json'
        },

        aoColumns: [
            {
                mData: "sender",
                mRender: renderers.user
            }, {
                mData: "receiver",
                mRender: renderers.user
            }, {
                mData: "amount"
            }, {
                mData: "created_at",
                mRender: renderers.date
            },
        ]
    });
});
