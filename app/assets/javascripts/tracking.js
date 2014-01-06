// $(document).ready(function() {
//     $('#products').dataTable();
// } );

$(document).ready(function() {

    var responsiveHelper;
    var breakpointDefinition = {
        tablet: 1024,
        phone : 480
    };
    var tableContainer = $('#contracts');

    var userRenderer = function(data, type, row) {
        var displayName = data.role > 0 ? data.name : data.jid;
        return "<a href='/users/" + data.id + "'>" + displayName + "</a>";
    }
    var dateRenderer = function(data, type, row) {
        return new Date(Date.parse(data)).toLocaleDateString();
    }

    tableContainer.dataTable({
        // Setup for Bootstrap support.
        sDom: "<'row'<'col-12'f><'col-12'l>r>t<'row'<'col-12'i><'col-12'p>>",
        sPaginationType: 'bootstrap',
        bProcessing: true,
        sAjaxSource: '/tracking.json',
        oLanguage      : {
            sLengthMenu: '_MENU_ records per page'
        },
        aoColumnDefs: [
            {
                mRender: userRenderer,
                aTargets: [1, 2]
            }, {
                mRender: dateRenderer,
                aTargets: [3, 6, 7]
            }
        ]
    });

});
