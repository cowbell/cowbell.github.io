---
title: Cleanup bugtracker from frequently erroring background jobs
date: 2015/01/11
description: To avoid noise in bugtracker, filter frequently raised errors and don't loose background processing library flexibility to handle exception in the best possible way
author: Wojciech Wnętrzak
tags: bugtracker, background-job
hacker_news_id: 8871568
---

If you are using a background job for processing some third party service requests, you have probably noticed it happens quite often that a given service is not available 100% of the time. In such a case background job will fail with an error, reschedule itself, and finally process when the service is up again.

You probably also use some bugtracker service to keep an eye on status of your application. Every time when a background job fails, you are notified about the issue. You look at the error and think _"Again, cannot reach their servers, this error can be ignored"_.

This is bad -- mainly because it creates a lot of noise in the bugtracker, distracting you from errors that are mission critical in your business.
You might want to catch frequent errors in your worker and reschedule the job when an error appeared, but what is the best time of retry to use? 1 minute, 5 minutes, 30 minutes? It would be great to calculate it based on a failed attempts number. Also when rescheduling you don't know what exactly went wrong, you only see that the worker is processing something again after a period of time.

All of these are already handled by the background processing library, but they need to raise an error to do that, so they need to be sent to the bugtracker, so you will be distracted again. Maybe filter out these specific errors in a global notification configuration? But what about other places in your application, where a similar error might not be frequent and when it appears you want to know that?

There is a quite easy solution. Let's use [ActiveJob](http://guides.rubyonrails.org/active_job_basics.html), available in Rails 4.2 by default.

~~~ ruby
class GetFacebookPictureJob < ActiveJob::Base
  def perform(user)
    user.picture = Facebook::API.picture_url(user.facebook_id)
    user.save
  end
end
~~~

When Facebook servers are down, you might see errors like `OpenURI::HTTPError` or `Errno::ENETUNREACH`.
To be able to not submit them to the bugtracker but still have failures handled by the background library, catch them and raise a custom error that you can filter out in a global configuration.

~~~ ruby
class JobFrequentFailureError < Exception; end

class GetFacebookPictureJob < ActiveJob::Base
  def perform(user)
    user.picture = Facebook::Api.picture_url(user.facebook_id)
    user.save

  rescue Errno::ENETUNREACH, OpenURI::HTTPError
    raise JobFrequentFailureError.new
  end
end
~~~

This way, you decide which error is safe to catch in each worker.

There is one thing left to improve. When you look at the failure error, you will notice that its backtrace is not from the original exception.
All you need is to update your proxy error class by using `Exception#cause` method, available since Ruby 2.1.

~~~ ruby
class JobFrequentFailureError < Exception
  def message
    "#{self.class}(#{cause.class}) - #{cause.message}"
  end

  def backtrace
    cause.backtrace
  end
end
~~~

That's it! You have a clean bugtracker and you have handled job exceptions in the best possible way.
