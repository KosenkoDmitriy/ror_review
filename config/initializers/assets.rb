# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w(  application.css
button.css
border-reviews.css
bootstrap.min.css
bootstrap-responsive.min.css
bootstrap-wysihtml5.css
box-model.css
clients.css
colorpicker.css
datepicker.css
example.css
filter-button.css
font-awesome.css
fullcalendar.css
home.scss
home.css
jquery.easy-pie-chart.css
jquery.gritter.css
material-charts.css
matrix-login.css
matrix-media.css
matrix-style.css
review-maiden.css
reviews-page.css
select2.css
setting_user.css
registrations.css
total-reviews-graph.css
twitter-facebook-button.css
uniform.css 
user-thumb.css
font-awesome.css)
Rails.application.config.assets.precompile += %w( application.js
bootstrap.js
bootstrap.min.js
colorpicker.js
bootstrap-datepicker.js
bootstrap-wysihtml5.js
cable.js
example.js
excanvas.min.js
fullcalendar.min.js
home.coffee
jquery.dataTables.min.js
jquery.easy-pie-chart.js
jquery.flot.crosshair.js
jquery.flot.min.js
jquery.flot.pie.js
jquery.flot.pie.min.js
jquery.flot.resize.min.js
jquery.gritter.min.js
jquery.js
jquery.min.js
jquery.peity.min.js
jquery.ui.custom.js
jquery.uniform.js
jquery.validate.js
jquery.wizard.js
masked.js
material-charts.js
matrix.calendar.js
matrix.charts.js
matrix.chat.js
matrix.dashboard.js
matrix.form_common.js
matrix.form_validation.js
matrix.interface.js
matrix.js
matrix.login.js
matrix.popover.js
matrix.tables.js
matrix.wizard.js
select2.min.js
users.css
wysihtml5-0.3.0.js )
#Rails.application.config.assets.precompile += %w( jquery.min.js matrix.login.js matrix.tables.js jquery.dataTables.min.js matrix.popover.js matrix.form_validation.js jquery.validate.js jquery.wizard.js matrix.dashboard.js)
#Rails.application.config.assets.precompile += %w( bootstrap.min.css bootstrap-responsive.min.css matrix-login.css font-awesome.css )