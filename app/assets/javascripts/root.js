// $(document).ready(function() {
//     $('#products').dataTable();
// } );

$(document).ready(function() {

  var responsiveHelper;
  var breakpointDefinition = {
    tablet: 1024,
    phone : 480
  };
  var tableContainer = $('#products');

  tableContainer.dataTable({
    // Setup for Bootstrap support.
    sDom: "<'row'<'col-12'f><'col-12'l>r>t<'row'<'col-12'i><'col-12'p>>",
    sPaginationType: 'bootstrap',
    oLanguage      : {
        sLengthMenu: '_MENU_ records per page'
    },

    // Setup for responsive datatables helper.
    bAutoWidth     : false,
    fnPreDrawCallback: function () {
        // Initialize the responsive datatables helper once.
        if (!responsiveHelper) {
            responsiveHelper = new ResponsiveDatatablesHelper(tableContainer, breakpointDefinition);
        }
    },
    fnRowCallback  : function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
        responsiveHelper.createExpandIcon(nRow);
    },
    fnDrawCallback : function (oSettings) {
        responsiveHelper.respond();
    }
  });

});
