// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap/bootstrap-tooltip
//= require twitter/bootstrap/bootstrap-popover
//= require twitter/typeahead
//= require bootstrap
//= require renderers
//= require bootstrap-datepicker
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap
//= require jquery.bootstrap-input-addon.js

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
        var datum = null;
        var search_value = $(this).val();
        for (var i = 0; available[i]; ++i) {
            if (available[i].value == search_value) {
                datum = available[i];
                break;
            }
        }
        if (datum) {
            $input.trigger('typeahead:selected', datum);
        } else {
            $input.trigger('typeahead:uservalue', search_value);
        }
    });

    $('input[name*=amount]').input_field_addons({ prefix: '$' });

    $('input.date').datepicker({ 
      autoclose: true,
      format: 'yyyy-mm-dd',
      update: new Date()
    });
});

$(function() {
    $(document).trigger('decorate');
});

function rowsPerPage(table_selector) {
    // FIXME: Magic numbers
    var table = $(table_selector);
    var bottom = table.position().top + table.outerHeight();
    var height = $(window).height() - bottom - 60 /* Showing X to Y of N entries + Copyright */;
    height -= 40; /* Two rows per header after column resizing */
    var rows = Math.floor(height / 30 /* Estimated row height */);
    return rows > 0 ? rows : 1;
}
