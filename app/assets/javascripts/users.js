$(document).ready(function() {

    var tableContainer = $('#users');

    tableContainer.dataTable({
        sPaginationType: 'bootstrap',
        bProcessing: true,
        sAjaxSource: '/users.datatable',
        oLanguage: {
            sUrl: '/i18n/datatable.json'
        },

        aoColumns: [
            {
                mData: null,
                mRender: function(data, type, row) { return renderers.user(row, type, row); }
            }, {
                mData: "jid"
            }, {
                mData: "phone"
            }, {
                mData: "role",
                mRender: function(data, type, row) { return user_role_names[data]; }
            }, {
                mData: "created_at",
                mRender: renderers.date
            }
        ]
    });
});
