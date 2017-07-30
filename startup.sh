#!/bin/sh

if [ ! -f /var/lib/boinc-client/gui_rpc_auth.cfg ]
then
  touch /var/lib/boinc-client/gui_rpc_auth.cfg
fi

CFG=/etc/boinc-client/cc_config.xml
PREFS=/etc/boinc-client/global_prefs_override.xml

# allow this remote host to talk to us
if [ ! -z  ${REMHOST} ]; then
  echo ${REMHOST} > /etc/boinc-client/remote_hosts.cfg
  > /etc/boinc-client/gui_rpc_auth.cfg
else
  > /etc/boinc-client/remote_hosts.cfg
fi

# add stuffs to cc_config http://boinc.berkeley.edu/wiki/Client_configuration
# add a proxy server
if [ ! -z ${PROXYHOST} ]; then
  sed -i "s/PROXYHOST/${PROXYHOST}/g" ${CFG}
  sed -i "s/PROXYPORT/${PROXYPORT}/g" ${CFG}
  export http_proxy=http://${PROXYHOST}:${PROXYPORT}
  export https_proxy=http://${PROXYHOST}:${PROXYPORT}
  export ftp_proxy=http://${PROXYHOST}:${PROXYPORT}
  export HTTP_PROXY=http://${PROXYHOST}:${PROXYPORT}
else
  sed -i "s/PROXYHOST//g" ${CFG}
  sed -i "s/PROXYPORT//g" ${CFG}
fi
# tell it to ignore proxy hosts for
if [ ! -z ${PROXYEXCL} ]; then
  sed -i "s_PROXYEXCL_${PROXYEXCL}_g" ${CFG}
else
  sed -i "s_PROXYEXCL__g" ${CFG}
fi

# enable remote access
if [ ! -z ${ALLOWREM} ]; then
  sed -i 's/ALLOWREM/1/g' ${CFG}
else
  sed -i 's/ALLOWREM/0/g' ${CFG}
fi

# set prior lower priority than other tasks
if [ ! -z ${LOWPRIOR} ]; then
  sed -i 's/LOWPRIOR/1/g' ${CFG}
else
  sed -i 's/LOWPRIOR/0/g' ${CFG}
fi

# add stuffs to the global prefs https://boinc.berkeley.edu/wiki/Global_prefs_override.xml

# suspend boinc if machine is using > than 
if [ ! -z ${IFUSECPU} ]; then
  sed -i "s/IFUSECPU/${IFUSECPU}/g" ${PREFS}
else
  sed -i "s/IFUSECPU/0.000000/g" ${PREFS}
fi

# only use this many cpus (based on percentage)
if [ ! -z ${MAXNUMCPU} ] ; then
  sed -i "s/MAXNUMCPU/${MAXNUMCPU}/g" ${PREFS}
else
  sed -i "s/MAXNUMCPU/100.000000/g" ${PREFS}
fi

# only use this much cpu time
if [ ! -z ${MAXUSECPU} ]; then
  sed -i "s/MAXUSECPU/${MAXUSECPU}/g" ${PREFS}
else
  sed -i "s/MAXUSECPU/100.000000/g" ${PREFS}
fi

# let's make sure we use the configs dynamically all the time
test -f /var/lib/boinc-client/cc_config.xml && rm /var/lib/boinc-client/cc_config.xml
test -f /var/lib/boinc-client/global_prefs_override.xml && rm /var/lib/boinc-client/global_prefs_override.xml
test -f /var/lib/boinc-client/gui_rpc_auth.cfg && rm /var/lib/boinc-client/gui_rpc_auth.cfg
test -f /var/lib/boinc-client/remote_hosts.cfg && rm /var/lib/boinc-client/remote_hosts.cfg

ln -sf /etc/boinc-client/cc_config.xml /var/lib/boinc-client/cc_config.xml
ln -sf /etc/boinc-client/global_prefs_override.xml /var/lib/boinc-client/global_prefs_override.xml
ln -sf /etc/boinc-client/gui_rpc_auth.cfg /var/lib/boinc-client/gui_rpc_auth.cfg
ln -sf /etc/boinc-client/remote_hosts.cfg /var/lib/boinc-client/remote_hosts.cfg
ln -sf /etc/ssl/certs/ca-certificates.crt /var/lib/boinc-client/ca-bundle.crt

#/usr/bin/boinc --dir /var/lib/boinc-client
/usr/bin/boinc --dir /var/lib/boinc-client --allow_remote_gui_rpc
