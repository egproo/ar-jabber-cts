$(document).ready(function() {
  $('.room-name').input_field_addons({ postfix: '@conference.syriatalk.biz' });

  var tableContainer = $('#contracts');

  var cnr = function(data, format, row) {
      return "<a href='/contracts/" + row[9] + "'>" + data + "</a>";
  }

  tableContainer.dataTable({
    sPaginationType: 'bootstrap',
    bProcessing: true,
    sAjaxSource: '/contracts.datatable',
    oLanguage: {
        sUrl: '/i18n/datatable.json'
    },
    aoColumnDefs: [
      {
          mRender: cnr,
          aTargets: [0]
      }, {
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
