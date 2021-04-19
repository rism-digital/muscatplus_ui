## Muscat Plus User Interface

The primary UI for the MuscatPlus interface. 

### Building and running locally (built-in server)

The only JavaScript dependency is "elm-live", a live-reloading server for Elm development. Dependency management
happens with `yarn`, so:

    $ yarn install

will install all of the necessary packages, then:

    $ yarn run develop

This will start up a local development server and watch for changes.

The elm dependencies are installed automatically when the application is first compiled. You should 
probably check the `src/Config.elm` file to verify the remote API server URL.

### Building and running locally (local web server)

One limitation of building and running locally with the built-in server is that your UI and your data service
will be on separate domains. This means that when the UI renders URLs that it receives from the server it will
not match, and you will be redirected to the external server. In this case, you may want to run a local instance
of nginx and replicate a full stack setup.

Add a host entry in your `/etc/hosts` file:

    127.0.0.1 dev.rism.offline

On a Mac, you will need to refresh your DNS cache:

    $ sudo killall -HUP mDNSResponder

You can install nginx on a Mac with [Homebrew](https://formulae.brew.sh/formula/nginx). This creates the configuration
files in `/usr/local/etc/nginx`. 

You should replace `/usr/local/etc/nginx/nginx.conf` with the one that is [hosted in the Ansible repo](https://github.com/rism-digital/ansible.rism-online/blob/develop/roles/nginx/files/conf/nginx.conf).
If the `/usr/local/etc/nginx/sites-enabled` directory does not exist, you should create it.

In the `server-setup` directory in this repo you will find an example configuration. You will need to comment
out one of the `upstream app` sections, depending on how you want to run it. You will also need to configure
the path to where you have this repo stored on your server, and you will also need to make sure that the user
that runs `nginx` has permissions to view this folder. (This might be tricky if, for example, you have fairly
restrictive permissions on your home directory.)

Since we will be changing nginx to run on a privileged port 80, it needs to be run as `root`. Homebrew doesn't
really like this, but we can manage nginx with `sudo brew services start nginx`. It's always good to check the
error log when running this the first time, since the Homebrew services command is not the best at notifying you
whether there was a problem starting the service.

    $ tail -f /usr/local/var/log/nginx/error.log

When all of this setup is successful you should be able to visit `http://dev.rism.offline` and then use the app as normal.

To update the results as you develop, you should run the development builds. This watches the source for changes and then
recompiles, installing the output in the `dist` directory. `yarn install` installs the `chokidar` tool which will
watch the tree for any changes and re-run the compiler.

    $ yarn run develop:build

### Building and running for production

TODO
