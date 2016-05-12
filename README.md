[![Build Status](https://travis-ci.org/cu12/dokku-fake_sns.svg?branch=master)](https://travis-ci.org/cu12/dokku-fake_sns)

# dokku fake_sns (beta)

fake_sns plugin for dokku. Currently defaults to installing [seayou/fake-sns](https://hub.docker.com/r/seayou/fake-sns/)

## requirements

- dokku 0.4.0+
- docker 1.8.x

## installation

```shell
# on 0.3.x
cd /var/lib/dokku/plugins
git clone https://github.com/cu12/dokku-fake_sns.git fake_sns
dokku plugins-install

# on 0.4.x
dokku plugin:install https://github.com/cu12/dokku-fake_sns.git fake_sns
```

## commands

```
sns:create <name>               Create a sns service with environment variables
sns:destroy <name>              Delete the service and stop its container if there are no links left
sns:expose <name> [port]        Expose an sns service on custom port if provided (random port otherwise)
sns:info <name>                 Print the connection information
sns:link <name> <app>           Link the sns service to the app
sns:list                        List all sns services
sns:logs <name> [-t]            Print the most recent log(s) for this service
sns:promote <name> <app>        Promote service <name> as SNS_URL in <app>
sns:restart <name>              Graceful shutdown and restart of the sns service container
sns:start <name>                Start a previously stopped sns service
sns:stop <name>                 Stop a running sns service
sns:topic:add <name> <topic>    Creates an sns topic
sns:topic:remove <name> <topic> Removes an sns topic
sns:topics <name>               List all sns topics for this service
sns:unexpose <name>             Unexpose a previously exposed sns service
sns:unlink <name> <app>         Unlink the sns service from the app

```

## usage

```shell
# create a sns service named lolipop
dokku sns:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# official sns image
# In fact you could any other software that is working with `aws sns` commands
export FAKESNS_IMAGE="seayou/fake-sns"
export FAKESNS_IMAGE_VERSION="latest"

# create a sns service
dokku sns:create lolipop

# get connection information as follows
dokku sns:info lolipop

# a sns service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku sns:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_SNS_LOLIPOP_NAME=/lolipop/dokku-sns-lolipop
#   DOKKU_SNS_LOLIPOP_PORT=tcp://172.17.0.1:9292
#   DOKKU_SNS_LOLIPOP_PORT_9292_TCP=tcp://172.17.0.1:9292
#   DOKKU_SNS_LOLIPOP_PORT_9292_TCP_PROTO=tcp
#   DOKKU_SNS_LOLIPOP_PORT_9292_TCP_PORT=9292
#   DOKKU_SNS_LOLIPOP_PORT_9292_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   SNS_URL=http://dokku-sns-lolipop:9292
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku sns:link other_service playground

# since SNS_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_SNS_BLUE_URL=http://dokku-sns-other-service:9292

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku sns:promote other_service playground

# this will replace SNS_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   SNS_URL=http://dokku-sns-other-service:9292
#   DOKKU_SNS_BLUE_URL=http://dokku-sns-other-service:9292
#   DOKKU_SNS_SILVER_URL=http://dokku-sns-lolipop:9292

# you can create SNS topics
dokku sns:topic:add lolipop topic

# also list them
dokku sns:topics lolipop

# and of course remove them
dokku sns:topic:remove lolipop topic

# you can also unlink an sns service
# NOTE: this will restart your app and unset related environment variables
dokku sns:unlink lolipop playground

# you can tail logs for a particular service
dokku sns:logs lolipop
dokku sns:logs lolipop -t # to tail

# finally, you can destroy the container
dokku sns:destroy lolipop
```
