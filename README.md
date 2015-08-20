# Email Sleuth

Email Sleuth is a small server for tracking email recipients.

## Usage

GET requests at the root return a 1x1 transparent gif. It expects an `id` parameter to be provided as a key to identify the user. For example, an image could be placed in an email like this:

``` html
<img src='https://my-sleuth-server.com/?id=28394' />
```

All other parameters given will also be stored, as well as the ip of the request and a country and city derived from the ip address using [geoip](https://github.com/cjheath/geoip) and [Maxmind](https://www.maxmind.com/en/home).

To get at the collected data, go to the `/csv` route, log in with the admin credentials supplied as environment variables and a .csv file will be downloaded.

To clear all the previously collected data, go to the `/clear` route, log in with the admin credentials and all the data will be deleted.

## Deployment

The easiest way to deploy is to use this "deploy to heroku" button:

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

For other platforms, Email Sleuth is a [sinatra](http://www.sinatrarb.com/) app, so instructions for deploying a sinatra app on your chosen platform should work. It also requires a [mongodb](https://www.mongodb.org/) database, with the environment variable `MONGOLAB_URI` set to the database's url.

## Configuration

Email Sleuth relies on three environment variables:

* SLEUTH_USER - Admin username
* SLEUTH_PASSWORD - Admin password
* MONGOLAB_URI - Mongo database's url (automatically provided on Heroku)

## Contributing

1. [Fork it](https://github.com/mushishi78/email-sleuth/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
