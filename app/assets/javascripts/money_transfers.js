$(document).ready(function() {

  var tableContainer = $('#money_transfers');

  tableContainer.dataTable({
    sPaginationType: 'bootstrap',
    bProcessing: true,
    sAjaxSource: '/money_transfers.json',

    // var userRenderer = function(data, type, row) {
    //     var displayName = data.role > 0 ? data.name : data.jid;
    //     return "<a href='/users/" + data.id + "'>" + displayName + "</a>";
    // };
    // var dateRenderer = function(data, type, row) {
    //     return new Date(Date.parse(data)).toLocaleDateString();
    // };

    // aoColumnDefs: [
    //   {
    //       mRender: userRenderer,
    //       aTargets: [0]
    //   }, {
    //       mRender: dateRenderer,
    //       aTargets: [3]
    //   }
    // ]
  });
});
