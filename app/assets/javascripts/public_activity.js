// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function(){

    var tableContainer = $('#public_activities');

    tableContainer.dataTable({
            sDom: "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
            sPaginationType: 'bootstrap',
            bProcessing: true,
            sAjaxSource: '/public_activity/index.datatable',
            oLanguage: {
                sUrl: '/i18n/datatable.json'
            },
            bAutoWidth: false,
            bDeferRender: true,
            aaSorting: [[4, 'desc']],
            aoColumns: [{
                    mData: 'key',
                    mRender: renderers.operationType,
                    sWidth: "5%"
                }, {
                    mData: 'key',
                    mRender: renderers.modelType,
                    sWidth: "10%"
                }, {
                    mData: null,
                    mRender: renderers.modelText,
                    sWidth: "60%"
                }, {
                    mData: null,
                    mRender: renderers.owner,
                    sWidth: "10%"
                }, {
                    mData: 'created_at',
                    mRender: renderers.dateTime,
                    sWidth: "15%"
                }]
    });
});
