let mix = require('laravel-mix');

mix
   .js('resources/assets/js/app.js', 'public/js/app.js')
   .sass('resources/assets/sass/app.scss', 'public/css/app.css')

   .browserSync({
      proxy: 'https://webserver-hr',
      port: 9056
   });
