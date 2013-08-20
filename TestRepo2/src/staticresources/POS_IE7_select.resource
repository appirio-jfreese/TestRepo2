(function ($) {
    function isNotIE7OrEarlier() {
        if (!$.browser.msie) {
            return true;
        }
        if (parseInt(($.browser.version)) > 8) {
            return true;
        }
        return false
    }

    function expand() {
        $(this).css("width", "auto");
        var width = getWidthInt($(this));
        var origWidth = getWidthOrigInt($(this));
        if (width < origWidth) {
            $(this).css("width", origWidth);
        }
    };

    function contract() {
        var origWidth = $(this).data("origWidth");
        $(this).css("width", origWidth);
    };

    function getWidthInt(element) {
        return (parseInt(getWidth(element).replace("px", "")));
    }

    function getWidthOrigInt(element) {
        return (parseInt(element.data("origWidth").replace("px", "")));
    }

    function getWidth(element) {
        return (parseInt(element.css("width").replace("px", "")) + 4) + "px"
    }

    $.fn.fixieselects = function () {
        return this.each(function () {
            if (isNotIE7OrEarlier()) {
                return;
            }
            var width = getWidth($(this));
            var span = "<div style=\"overflow-x:hidden; width:" + width + ";\">";
            $(this).wrap(span);
            $(this)
            .css("width", width)
            .data("origWidth", width)
            .blur(contract)
            .change(contract)
            .mousedown(expand);
        });
    };
})(jQuery); 