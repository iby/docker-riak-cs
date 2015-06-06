# Docker Riak CS

[![Circle CI](https://circleci.com/gh/ianbytchek/docker-riak-cs.svg?style=svg)](https://circleci.com/gh/ianbytchek/docker-riak-cs)

[Riak CS](http://docs.basho.com/riakcs/latest/) is an object storage software [compatible](http://docs.basho.com/riakcs/latest/references/apis/storage/s3/) with [AWS S3](http://aws.amazon.com/s3/) API. It's a perfect S3 alternative for local development and testing, which is the exact purpose of this image. It works as a single node to keep the resources to the minimum, something that [Riak guys wouldn't recommend](http://basho.com/why-your-riak-cluster-should-have-at-least-five-nodes/) and certainly not suitable for production. There is [hectcastro/docker-riak-cs](https://github.com/hectcastro/docker-riak-cs) project that allows to bring up a multi-node cluster, which might suite you better.

## Running

Pull or build the image yourself and run it. When the container gets started it will setup the Riak admin and show you the credentials. Will also create optionally provided buckets.

```
# Build
docker build -t ianbytchek/riak-cs .

# Or pull
docker pull ianbytchek/riak-cs
 
# Run and create three buckets
docker run -d -P --name riak-cs -e "RIAK_CS_BUCKETS=foo,bar,baz" ianbytchek/riak-cs
```

## Proxy

Riak CS should also be run behind a proxy, this is recommended by Basho and gives certain advantages, such as detailed DNS configuration and url rewriting. Besides Riak doesn't play well with [SHA-256](https://github.com/basho/riak_cs/issues/1019) and [SSL overall](https://github.com/basho/riak_cs/issues/1025#issuecomment-64447329), which will eventually be fixed, but until then you are better off with SSL termination. Below is a HAProxy config that you can use along with [ianbytchek/docker-haproxy](https://github.com/ianbytchek/docker-haproxy) to get everything working.

```
# Make sure to replace <PRIVATE_KEY> with the actual path to relevant ssl key
# and <RIAK_CS_IP_PORT> with the IP and port of the container.

defaults
    mode                    http
    timeout connect         10s
    timeout client          1m
    timeout server          1m

frontend http
    bind *:80
    redirect scheme https code 301 if !{ ssl_fc }

frontend https
    bind *:443 ssl crt <PRIVATE_KEY>
    use_backend riak_cs

backend riak_cs
    balance leastconn
    option httpclose
    reqirep ^Host:\ (.+)?(s3).*(\.amazonaws\.dev)$ Host:\ \1\2\3
    server node01 <RIAK_CS_IP_PORT>
```

## Issues

### AWS Access Key Id does not exist

There is a known [issue](https://github.com/basho/riak_cs/issues/1048) when the Docker host gets powered off in a non-graceful way. This might be due to the fact that Riak shouldn't be run as a one-node cluster or it doesn't get a chance to properly shut down. Starting a fresh container normally works, but there were many times when only rebuilding the container and restarting the host would work. This doesn't happen now as often as it used to, though.

## Bonus

```
# Connect to an existing container.
docker exec -i -t riak-cs bash

# Remove exited containers.
docker ps -a | grep 'Exited' | awk '{print $1}' | xargs docker rm

# Remove intermediary and unused images.
docker rmi $(docker images -aq -f "dangling=true")
```