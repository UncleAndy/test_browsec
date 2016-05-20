$(document).ready(function(){
    var search_reset = $('.btn.search_reset');

    search_reset.click(do_search_reset);
});

function do_search_reset() {
    var search_field = $('#search_field');

    search_field.val('');

    $('#search_form').submit();
}