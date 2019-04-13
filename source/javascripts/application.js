//= require "jquery/dist/jquery"
//= require "bootstrap-sass/assets/javascripts/bootstrap/collapse"
//= require "bootstrap-sass/assets/javascripts/bootstrap/transition"

jQuery(function ($) {
    $("[data-target='#hire']").click(function () {
        ga("send", "event", "button", "click", "hire");
    });

    $("a.smooth").on("click", function (event) {
        var href = $(event.currentTarget).attr("href"),
            hash = href.substr(1);

        if (href.indexOf(window.location.pathname) == 0 && $(hash).length > 0) {
            event.preventDefault();
            $("html,body").animate({ scrollTop: $(hash).offset().top }, 1000, function () {
                window.location.hash = hash;
            });
        }
    });
});
