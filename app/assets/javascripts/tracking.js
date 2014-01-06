$(document).ready(function() {

    var tableContainer = $('#contracts');

    var userRenderer = function(data, type, row) {
        var displayName = data.role > 0 ? data.name : data.jid;
        return "<a href='/users/" + data.id + "'>" + displayName + "</a>";
    };
    var dateRenderer = function(data, type, row) {
        return new Date(Date.parse(data)).toLocaleDateString();
    };
    var paymentRenderer = function(data, type, row) {
        var nextDate = new Date(Date.parse(data));
        var tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        if (nextDate <= tomorrow) {
            return '<span class="highlight_date">' + nextDate.toLocaleDateString() + '</span>';
        } else {
            return nextDate.toLocaleDateString();
        }
    };

    tableContainer.dataTable({
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
                aTargets: [3, 6]
            }, 
            {
                mRender: paymentRenderer,
                aTargets: [7]
            }
        ],
    });
});
