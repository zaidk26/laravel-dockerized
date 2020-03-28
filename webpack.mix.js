let mix = require('laravel-mix');

mix
   .js('resources/js/app.js', 'public/js/app.js')
   .sass('resources/sass/app.scss', 'public/css/app.css')

   .browserSync({
      proxy: 'https://webserver-hr',
      port: 9056
   });
