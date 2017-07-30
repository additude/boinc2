FROM ubuntu:xenial
LABEL MAINTAINER Kyle ODonnell <kyleo[at]0b10[dot]mx>
#LABEL MAINTAINER Bradley Leonard <bradley@stygianresearch.com>
LABEL description="This container will run the boinc-client. I forked this from Bradley Leonard <bradley@stygianresearch.com>"

# install boinc
RUN apt-get update &&                           \
    apt-get -q install -y boinc-client &&       \
    apt-get clean &&                            \
    rm -rf /var/lib/apt/lists/*


#EXPOSE 31416

#WORKDIR /var/lib/boinc

#USER boinc

#ENTRYPOINT ["boinc"]

# create directories
RUN mkdir /scripts

# add the startup.sh
ADD startup.sh /scripts/startup.sh
RUN chmod 755 /scripts/startup.sh

# add boinc config file
ADD cc_config.xml /etc/boinc-client/
ADD global_prefs_override.xml /etc/boinc-client/

ENTRYPOINT ["/scripts/startup.sh"]
#CMD ["/scripts/startup.sh"]
#CMD ["/bin/bash"]
