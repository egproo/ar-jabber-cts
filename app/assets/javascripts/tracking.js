$(document).ready(function() {

  var tableContainer = $('#contracts');

  tableContainer.dataTable({
    sPaginationType: 'bootstrap',
    bProcessing: true,
    sAjaxSource: '/tracking.datatable',
    oLanguage      : {
        sLengthMenu: '_MENU_ records per page'
    },
    aoColumnDefs: [
      {
        mRender: userRenderer,
        aTargets: [1, 2]
      }, {
        mRender: dateRenderer,
        aTargets: [3, 6]
      }, {
        mRender: paymentRenderer,
        aTargets: [7]
      }
    ]
  });
});
