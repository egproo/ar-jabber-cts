(function($){
    $.fn.input_field_addons = function(options) {
        return this.each(function() {
            obj = $(this);
            if (options.width) {
                obj.css('width', options.width + 'px');
            }
            if (options.before || options.after) {
                var div_classes = [];
                var obj_decorators = [];
                if (options.before) {
                    div_classes.push('input-prepend');
                    obj_decorators.push('before');
                }
                if (options.after) {
                    div_classes.push('input-append');
                    obj_decorators.push('after');
                }
                obj.wrap("<div class='" + div_classes.join(' ') + "'>");
                $.each(obj_decorators, function(index, decorator) {
                    obj[decorator]("<span class='add-on'>" + options[decorator] + "</span>");
                });
            }
        });
    };
})(jQuery);
