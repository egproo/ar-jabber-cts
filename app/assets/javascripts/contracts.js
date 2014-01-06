$(document).ready(function() {

  var tableContainer = $('#contracts');

  tableContainer.dataTable({
    sPaginationType: 'bootstrap',
    bProcessing: true,
    sAjaxSource: '/contracts.datatable',
    oLanguage: {
        sUrl: '/i18n/datatable.json'
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
