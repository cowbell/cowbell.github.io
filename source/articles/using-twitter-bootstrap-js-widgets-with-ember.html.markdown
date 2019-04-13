---
title: Using Twitter Bootstrap js widgets with Ember
date: 2013/10/20
description: How to make Twitter Bootstrap JavaScript widgets work with Ember
author: Wojciech Wnętrzak
tags: ember, bootstrap
---

When starting Ember application, you may wonder where to put code that will initialize [Twitter Bootstrap javascript widgets](http://getbootstrap.com/javascript/).
Let's say that you want to add simple [popover](http://getbootstrap.com/javascript/#popovers) to your page.

If you put popover element into static HTML file, the best place to initialize its functionality is in your application definition on `ready` event.

~~~ javascript
Ember.Application.create({
    ready: function () {
        Ember.$(".my-popover-element").popover();
    }
});
~~~

However, it won't work in Handlebars templates, because Ember renders dynamic HTML after `ready` event is triggered.

To fix this, you may create Ember view dedicated to display popovers, where Bootstrap function is called whenever this element is inserted into the DOM on `didInsertElement` event.

~~~ javascript
PopoverView = Ember.View.extend({
    didInsertElement: function () {
        this.$("button").popover();
    }
});
~~~

You can see it in use [here](https://github.com/cowbell/bridge-points/blob/89a85d061f1ea6bb1c927ff3e5cace0aae0325bb/app/views/popover-view.coffee#L5-L6).
