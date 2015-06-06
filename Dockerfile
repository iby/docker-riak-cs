FROM debian
MAINTAINER Ian Bytchek

COPY . /docker
RUN /docker/script/build.sh
EXPOSE 8080

ENTRYPOINT ["/docker/script/entrypoint.sh"]
CMD ["riak"]