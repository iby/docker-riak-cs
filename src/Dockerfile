FROM debian
MAINTAINER Ian Bytchek

COPY . /docker
RUN /docker/script/build.sh

VOLUME /var/lib/riak
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["riak"]