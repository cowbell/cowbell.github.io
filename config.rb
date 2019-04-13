activate :automatic_image_sizes

set :css_dir, "stylesheets"
set :js_dir, "javascripts"
set :images_dir, "images"
set :images_dir, "assets"
set :markdown_engine, :kramdown
set :sass_assets_paths, ["#{root}/bower_components/bootstrap-sass/assets/stylesheets"]

activate :sprockets
sprockets.append_path "#{root}/bower_components"
sprockets.append_path "#{root}/bower_components/bootstrap-sass/assets/stylesheets"

configure :build do
  activate :minify_css
  activate :minify_javascript
end

activate :syntax

activate :deploy do |deploy|
  deploy.deploy_method = :git
  deploy.branch = "master"
end

activate :blog do |blog|
  blog.permalink = ":year-:month-:day-:title.html"
  blog.sources = "articles/:title.html"
  blog.layout = "article_layout"
end

activate :asset_hash do |f|
  f.ignore = ["stylesheets/wufoo.css"]
end
