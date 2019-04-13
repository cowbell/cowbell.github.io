---
title: Capistrano deploys from Travis
date: 2014/03/06
description: How to deploy an application from Travis after a successful build using Capistrano
author: Wojciech Wnętrzak
tags: travis, capistrano
hacker_news_id: 7359246
---

Travis is integrated with many services that you can [deploy to](http://docs.travis-ci.com/user/deployment/) after a successful build. You may wonder however, how to do a deploy to your own server. If you are using [Capistrano](http://www.capistranorb.com/), that is a quite easy task.

You need to have a pair of private and public RSA keys that will be used for authentication.
If you need to generate one, you may take a look at [this article](https://help.github.com/articles/generating-ssh-keys) that will guide you through the process. Make sure to add the generated public key to `~/.ssh/authorized_keys` file on your server.

Next thing you want to do is to encrypt the RSA private key, that deploy script will use to authenticate on your server. You may have heard that Travis supports [encryption keys](http://docs.travis-ci.com/user/encryption-keys/), but as for now it is impossible to encode long strings (like private RSA keys). To workaround this issue, you can add an encrypted key file to the repository and decrypt it before deployment, using a password short enough that can be handled by Travis encryption.

~~~ shell
# Install Travis CLI tool
gem install travis
# Authenticate to your account
travis login
# Encrypt password and add it to .travis.yml file
travis encrypt DEPLOY_KEY="encryption-password" --add
# Encrypt deploy_id_rsa private RSA key file, that will be used for deploy
openssl aes-256-cbc -k "encryption-password" -in deploy_id_rsa -out config/deploy_id_rsa_enc_travis -a
~~~

Add a script that will decrypt the RSA key and finally deploy your application to the server after a successful build.

~~~ yaml
# .travis.yml
after_success:
  - "openssl aes-256-cbc -k $DEPLOY_KEY -in config/deploy_id_rsa_enc_travis -d -a -out config/deploy_id_rsa"
  - "bundle exec cap deploy"
~~~

Update Capistrano configuration to use your RSA key.

~~~ ruby
# deploy.rb
set :ssh_options, keys: ["config/deploy_id_rsa"] if File.exist?("config/deploy_id_rsa")
~~~

If you want to deploy only the master branch, you can change the last line from `after_success` callback.

~~~ shell
[[ $TRAVIS_BRANCH = 'master' ]] && bundle exec cap deploy
~~~

Commit all your changes to the repository and push it, so Travis can start a build.
