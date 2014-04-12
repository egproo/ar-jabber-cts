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
//= require twitter/bootstrap/bootstrap-transition
//= require twitter/bootstrap/bootstrap-alert
//= require twitter/bootstrap/bootstrap-collapse
//= require twitter/typeahead
//= require bootstrap
//= require renderers
//= require bootstrap-datepicker
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap
//= require jquery.bootstrap-input-addon

$(document).on('decorate', function(e, updated) {
    $('.typeahead-user').typeahead({
        name: 'user',
        prefetch: '/users.json?map=jid'
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
        var search_value = $(this).val();
        for (var i = 0; available[i]; ++i) {
            if (available[i].value === search_value) {
                return $input.trigger('typeahead:selected', search_value);
            }
        }
        $input.trigger('typeahead:uservalue', search_value);
    });

    $('input[name*=amount]').input_field_addons({ before: '$', width: 180 });

    $('input.date').datepicker({ 
        autoclose: true,
        format: 'yyyy-mm-dd',
        update: new Date()
    });
});

function updateDataTableRowsPerPage() {
    var $table = $('table.dataTable');
    if (!$table.length || $table.data('fixed-rows-per-page')) {
        return;
    }

    var dataTable = $table.dataTable();

    var currentTableHeight = $table.children('tbody').outerHeight();
    var newTableHeight = $(window).height() - $('body').height() + currentTableHeight;

    var rows = Math.floor(newTableHeight / $table.children('tbody').children('tr').height());
    if (rows <= 0) {
        rows = 1;
    }

    var settings = dataTable.fnSettings();
    if (settings._iDisplayLength != rows) {
        settings._iDisplayLength = rows;
        dataTable.fnDraw();
    }
}

function setupDataTable(options, selector) {
    var container = $(selector || 'table');

    var baseConfig = {
        sDom: "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
        sPaginationType: 'full_numbers',
        bProcessing: true,
        bDestroy: true,
        oLanguage: {
            sUrl: '/i18n/datatable.json'
        },
        bAutoWidth: false,
        bDeferRender: true,
        bStateSave: true,
        bLengthChange: false
    };

    if (options.iDisplayLength) {
        baseConfig.fnDrawCallback = function() {
            $(this).data('fixed-rows-per-page', true);
        };
    } else {
        baseConfig.fnDrawCallback = function() {
            var $this = $(this);
            if (!$this.data('first-draw-done')) {
                $this.data('first-draw-done', true);
                updateDataTableRowsPerPage();
                // Add button
                if (options.buttonHtml) {
                    container.parent().find('.row-fluid:first-child .span6:first-child').
                        append(options.buttonHtml);
                }
            }
        };
    }

    return container.dataTable($.extend(baseConfig, options));
}

$(function() {
    $(document).trigger('decorate');
    $(window).resize(updateDataTableRowsPerPage);
});
