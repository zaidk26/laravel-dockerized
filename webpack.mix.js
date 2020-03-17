let mix = require('laravel-mix');
require('laravel-mix-purgecss');

mix
   .js('resources/assets/js/app.js', 'public/js/app.js')
   .sass('resources/assets/sass/app.scss', 'public/css/app.css')

   .purgeCss()

   .webpackConfig({
      resolve: {
         alias: {
            '@': path.resolve('resources/assets/sass')
         }
      }
   })

   .version()

   .browserSync({
      proxy: 'https://webserver-hr',
      port: 9056
   });
