source "https://rubygems.org"

def darwin_only(require_as)
  RbConfig::CONFIG["host_os"] =~ /darwin/ && require_as
end

def linux_only(require_as)
  RbConfig::CONFIG["host_os"] =~ /linux/ && require_as
end

gem "builder"
gem "kramdown"
gem "middleman"
gem "middleman-blog", ">= 4.0.0"
gem "middleman-deploy", ">= 2.0.0.pre.alpha"
gem "middleman-sprockets", ">= 4.0.0"
gem "middleman-syntax"
gem "sass"

gem "rb-inotify", "~> 0.9", require: linux_only("rb-inotify")
gem "rb-fsevent", require: darwin_only("rb-fsevent")
