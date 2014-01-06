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
