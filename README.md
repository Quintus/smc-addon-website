SMC Add-On Website
==================

This is a working draft for the website that allows users to upload
levels which can then later be downloaded by SMC. It is really simple
and does nothing more than exactly that, by definition.

The website is a [Sinatra](http://www.sinatrarb.com) application,
i.e. it runs on Ruby via the standard Rack framework. In order to run
it, you will need:

1. [Ruby](https://www.ruby-lang.org) 1.9 or greater
2. [Bundler](http://bundler.io/)
3. A database engine, SQLite3 will work fine. MySQL/MariaDB and
   PostgreSQL are supported.

When you have satisfied these dependencies, check out the repository
and execute the initialization commands as follows:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ git clone git://github.com/Quintus/smc-addon-website.git
$ cd smc-addon-website
$ bundle install --path .gems --without mysql postgres
$ export DB_URI=sqlite://test.db
$ bundle exec rake db:setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bundler will install a small number of dependencies, mainly Sinatra’s
own dependencies, database dependencies, and authentication stuff. The
`DB_URI` environment variable is used by the application for
connecting to the database; it can be used to provide a host + user +
password information for a more complex setup, if required. This way
it is not necessary to store possibly sensitive information in the
public Git repository. Finally, `rake` takes care of setting up the
database tables needed for the application.

Note that if you don’t want to use SQLite3, you will need to adapt the
`--without` option accordingly and modify the `DB_URI` environment
variable. If you wanted to connect to a PostgreSQL database on a
different host, this would look like this:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ bundle install --path .gems --without sqlite mysql
$ export DB_URI=postgres://user:password@host:port/databasename
$ bundle exec rake db:setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is recommended to install [MailCatcher](http://mailcatcher.me/), as
the application will send out emails in the `development` environment
(`RACK_ENV=development`) to `localhost:1025` by default. In the
`production` environment it uses your local `sendmail` instead.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ gem install mailcatcher
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Note mailcatcher is not a hard dependency of this application. It is
merely meant to ease development. Edit `app.rb` if you want it to use
your own SMTP server or `sendmail`.

With all setup in place, you can now first start mailcatcher, and then
the application itself.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ mailcatcher
$ bundle exec rackup -p 3000
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Browse to http://localhost:3000 and start by registering a new user,
then explore the (quite minimalistic) possibilities. Any emails send
by the application (i.e. registration confirmation emails) are visible
on mailcatcher’s interface at http://localhost:1080.

License
-------

The SMC add-on website.
Copyright (C) 2014  The SMC team.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with this program.  If not, see
<http://www.gnu.org/licenses/>.

_"The SMC Team" refers to the [authors.txt file of SMC itself](https://github.com/Quintus/SMC/blob/devel/smc/docs/authors.txt)._
