// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function(){
    setupDataTable({
            aaData: activityData,
            aaSorting: [[4, 'desc']],
            aoColumns: [{
                    mData: 'action',
                    sWidth: "5%"
                }, {
                    mData: 'model_link',
                    sWidth: "10%"
                }, {
                    mData: 'model_text',
                    sWidth: "60%"
                }, {
                    mData: 'user',
                    sWidth: "10%"
                }, {
                    mData: 'created_at',
                    mRender: renderers.dateTime,
                    sWidth: "15%"
                }]
    });
});
