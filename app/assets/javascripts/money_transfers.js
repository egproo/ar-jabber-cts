$(document).ready(function() {
    setupDataTable({
        sAjaxSource: '/money_transfers.datatable',
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
                mRender: renderers.mtAmount,
                sWidth: "10%"
            }, {
                mData: "received_at",
                mRender: renderers.date,
                sWidth: "30%"
            },
        ]
    });
});
