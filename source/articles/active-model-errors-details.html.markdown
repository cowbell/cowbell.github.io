---
title: How to use ActiveModel errors details
date: 2015/01/22
description: How to use ActiveModel::Errors#details to return type of used validator in Rails
author: Wojciech Wnętrzak
tags: rails
hacker_news_id: 8928939
---

Rails just got a [new feature](https://github.com/rails/rails/commit/cb74473db68900d336844d840dda6e10dc03fde1) that allows for returning the type of a validator used on an invalid attribute.

~~~ ruby
class User < ActiveRecord::Base
  validates :name, presence: true
end

user = User.new
user.valid?
user.errors.details
# => {name: [{error: :blank}]}
~~~

It will be useful in API applications, where you don't want to return translated error messages, but rather symbols that are then used by API clients to construct proper user notifications.

You can also pass additional options to provide a context for an error object:

~~~ ruby
class User < ActiveRecord::Base
  validate :adulthood

  def adulthood
    errors.add(:age, :too_young, years_limit: 18) if age < 18
  end
end

user = User.new(age: 15)
user.valid?
user.errors.details
# => {age: [{error: :too_young, years_limit: 18}]}
~~~

All built in validators populate details hash by default.

This feature will be available in Rails 5.0, but you don't have to wait for the release to start using it in your Rails 4.x application. All you have to do is install the [active_model-errors_details](https://github.com/cowbell/active_model-errors_details) gem which backports the feature.
