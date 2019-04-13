---
title: Testing apps with Grunt and PhantomJS using Semaphore CI
date: 2013/10/18
description: How to set up Semaphore build steps to test apps with Grunt and PhantomJS
author: Szymon Nowak
tags: testing, grunt, semaphore
---

We've been using [Semaphore](https://semaphoreapp.com) for continuous integration and deployment of the Ruby on Rails based API that we're currently working on and recently we've decided to use it for the frontend app as well.

The frontend app uses [Yeoman](http://yeoman.io) workflow, so it uses [Bower](http://bower.io) to install its dependencies and [Grunt](http://gruntjs.com) for running tests. We've had some issues with permissions when installing dependencies on Semaphore and finally came up with these build steps:

1. `mkdir /home/runner/tmp`
2. `sudo chown -R runner:runner /home/runner/tmp`
3. `sudo chown -R runner:runner /home/runner/.local`
4. `sudo npm install -g grunt-cli bower`
5. `bundle install --without deployment`
6. `npm install`
7. `bower install`
8. `grunt test`

The fifth step is of course optional - we're using Bundler to install compass framework, but you can simply skip it if you're not using any Ruby libraries.
