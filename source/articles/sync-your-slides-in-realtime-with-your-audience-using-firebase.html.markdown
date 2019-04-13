---
title: Sync your HTML slide deck in real-time with your audience using Firebase
date: 2013/11/07
tags: firebase
author: Szymon Nowak
hacker_news_id: 6720320
---

Recently I gave a [talk about Firebase](http://szimek.github.io/presentation-firebase-intro/) and to show what can be done with it, I added real-time slide syncing in 24 lines of code including GitHub authentication for the presenter. I used [Google IO 2012](https://code.google.com/p/io-2012-slides/) slide template, but it's really easy to make it work with any other HTML slide template library.

To broadcast slide changes you need to add `?broadcast=true` parameter to the URL and authenticate with GitHub. To follow slide changes just add `?follow=true`.

Here's the code:

~~~ javascript
(function () {
  var database = 'presentations',
      presentation = 'firebase-intro',
      url = 'https://' + database + '.firebaseio.com/' + presentation,
      ref = new Firebase(url),
      params, auth, i, param;

  params = window.location.search.substring(1).split('&').map(function (el) {
    return el.split('=');
  });

  for (i = 0; param = params[i]; ++i) {
    if (param[0].toLowerCase() === 'broadcast') {
      // Authenticate using GitHub unless already authenticated
      auth = new FirebaseSimpleLogin(ref, function(error, user) {
        if (!user) { auth.login('github', { rememberMe: true }); }
      });

      // Listen to slide change event and save slide number to Firebase
      document.addEventListener('slideenter', function (event) {
        ref.set(event.slideNumber);
      });
    } else if (param[0].toLowerCase() === 'follow') {
      // Fetch slide number from Firebase and update the current slide
      ref.on('value', function (snapshot) {
        window.slidedeck.loadSlide(snapshot.val());
      });
    }
  }
})();
~~~

Save it as `js/firebase-sync.js` and add it together with Firebase libraries to your HTML file:

~~~ html
<script src='https://cdn.firebase.com/v0/firebase.js'></script>
<script src='https://cdn.firebase.com/v0/firebase-simple-login.js'></script>
<script src='js/firebase-sync.js'></script>
~~~

and that's it.

Well, almost. When you set it up for the first time, you'll need to do 2 more things.

1. Create a GitHub application.
* Go to [Register a new OAuth application](https://github.com/settings/applications/new) page and fill out the form. Enter `https://auth.firebase.com/auth/github/callback` as __Authorization callback URL__.

2. Setup your Firebase database.
* Register to Firebase - it will automatically create your first database for you.
* Go to "Auth" tab and in __Authorized Request Origins__ section add the domain where your presentation will be hosted - e.g. `<your GitHub username>.github.io` if you'll be hosting it using GitHub Pages.
* In __Authentication Providers__ click "GitHub". Check "Enabled" checkbox and copy GitHub Client ID and Secret from the application you created in the first step.
* Go to "Security" tab and paste the following rules:

~~~ json
{
  "rules": {
    ".read": true,
    ".write": "auth.provider == 'github' && auth.username == '<your GitHub username>'"
  }
}
~~~

This will grant read access to everyone, but only you'll have write access.

When you open your slides for the first time with `?broadcast=true` parameter, remember to allow pop-ups from the domain you're running it on to allow pop-up from GitHub and you're all set.


#### A few notes

* If you'd like to avoid creating a GitHub app, Firebase gives you 4 other authentication providers - email and password, Persona, Facebook and Twitter. You could simply use Persona (requires an additional JS library) or email and password provider. In the latter case just remember not to add your email and password to the repository.

* This will of course require you and your audience to have internet access, which may not be available at a conference, especially at larger ones. On the other hand it does not require you to be in the same network, so you can use your mobile phone network, if WiFi is not available.

* The free 'Development' plan allows up to 50 connections, so it might not be enough at larger conferences.
