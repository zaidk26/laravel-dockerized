# Laravel Docker Setup

- copy files in laravel folder 
- delete vendor and node_modules if exist
- in docker-compose edit container names [replace your container names in below snippets]
- in docker/conf.d/app.conf on line 12 edit to match your php container name you set in previous step
- in your webpackmix.mix.js add the following

````
.browserSync({
  proxy: 'https://webserver-my-app',
    port: 9056
  });
````

# Build 

````docker-compose build````

# Running

Starts Containers and runs compose install

````docker-compose up -d````

Start Terminal

````docker exec -it node-my-app bash````

````docker exec -it php-my-app bash````



On first run to install node modules

if no terminal
````docker exec node-my-app npm install````

or in terminal
````docker exec node-my-app npm install````

Once done and subsequent runs
*Start a terminal first and run this command so you get color output*

````npm run watch````

Production  Compile Assets
Run all Mix tasks and minify output...
````npm run production````

PHP artisan commands can be run in the same manner against your php app container




