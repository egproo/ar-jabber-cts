// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require lodash
//= require twitter/bootstrap
//= require twitter/typeahead
//= require bootstrap-datetimepicker.min
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap
//= require jquery.bootstrap-input-addon.js
//= require_tree .

$(document).on('decorate', function(e, updated) {
    $('.typeahead-user').typeahead({
        name: 'user',
        prefetch: '/users.json?map=name'
    });

    $('.typeahead-user').on('typeahead:opened', function() {
        $(this).data('ttOpened', true);
    });
    $('.typeahead-user').on('typeahead:closed', function() {
        $(this).data('ttOpened', false);
    });

    $('.typeahead-user').on('blur', function() {
        var $input = $(this);
        if ($input.data('ttOpened')) { return; }
        var available = $input.data('ttView').datasets[0].itemHash;
        var datum = _.findWhere(available, {value: $(this).val()});
        if (datum) {
            $input.trigger('typeahead:selected', datum);
        } else {
            $input.trigger('typeahead:uservalue', $(this).val());
        }
    });

    $('.amount-usd').input_field_addons({ prefix: '$' });
    $('.date-picker').datetimepicker({ pickTime: false });
});

$(document).ready(function() {
    $(document).trigger('decorate');
})
