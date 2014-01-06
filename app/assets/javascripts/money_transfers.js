$(document).ready(function() {

  var tableContainer = $('#money_transfers');



  tableContainer.dataTable({
    sPaginationType: 'bootstrap',
    bProcessing: true,
    sAjaxSource: '/money_transfers.datatable',
    oLanguage: {
      sLengthMenu: '_MENU_ records per page'
    },

    aoColumns: [
      {
        mData: "sender",
        mRender: userRenderer,
        aTargets: [1]
      }, {
        mData: "receiver",
        mRender: userRenderer,
        aTargets: [2]
      }, {
        mData: "amount"
      }, {
        mData: "created_at",
        mRender: dateRenderer
      },
    ]
  });
});
