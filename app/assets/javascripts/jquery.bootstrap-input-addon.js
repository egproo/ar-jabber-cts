(function($){
    $.fn.input_field_addons = function(options) {
        var defaults = {
            width: null,
            prefix: null,
            postfix: null,
        };
        var options = $.extend(defaults, options);

        return this.each(function() {
            obj = $(this);
            if (options.width) {
                obj.css('width', options.width + 'px');
            }
            if (options.prefix) {
                obj.wrap("<div class='input-prepend'>");
                obj.before("<span class='add-on'>" + options.prefix + "</span>");
            }
            if (options.postfix) {
                obj.wrap("<div class='input-append'>");
                obj.after("<span class='add-on'>" + options.postfix + "</span>");
            }
        });
    };
})(jQuery);
