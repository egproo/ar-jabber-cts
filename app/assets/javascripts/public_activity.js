// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function(){
    setupDataTable({
            aaData: activityData,
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
