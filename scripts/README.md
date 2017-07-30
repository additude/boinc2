# control-boinc

I wrote this script to easily manage my cluster of boinc docker containers.  I use `parallel-ssh`to execute the commands, but `ansible` or a bash for loop would do just fine.  

### Running
```sh
./control-boinc 
usage: ./control-boinc <start|stop|status|rm|update|bash|restart|destroy>
```
start/stop/status -- self explanatory

rm -- removes the container

update -- does a docker pull from the hub/repo

bash -- drops you into a shell within the container

restart -- execs destroy then start

destroy -- execs stop then rm

### Prerequisite
You'll need a docker repo host in order to run the `update`.  If you don't use a repo you'll need to replace the following in the start function:
```sh
  docker run --name=boinc -h ${getname} -d \
  -e ALLOWREM=${ALLOWREM} \
  -e REMHOST=${REMHOST} \
  -e PROXYHOST=${PROXYHOST} \
  -e PROXYPORT=${PROXYPORT} \
  -e PROXYEXCL=${PROXYEXCL} \
  -e LOWPRIOR=${LOWPRIOR} \
  -e MAXUSECPU=${MAXUSECPU} \
  -e IFUSECPU=${IFUSECPU} \
  -e MAXNUMCPU=${MAXNUMCPU} \
  -p 31416:31416 -v ${srcdir}:${dstdir} ${repo}/${cname}
```
with
```sh
  docker run --name=boinc -h ${getname} -d \
  -e ALLOWREM=${ALLOWREM} \
  -e REMHOST=${REMHOST} \
  -e PROXYHOST=${PROXYHOST} \
  -e PROXYPORT=${PROXYPORT} \
  -e PROXYEXCL=${PROXYEXCL} \
  -e LOWPRIOR=${LOWPRIOR} \
  -e MAXUSECPU=${MAXUSECPU} \
  -e IFUSECPU=${IFUSECPU} \
  -e MAXNUMCPU=${MAXNUMCPU} \
  -p 31416:31416 -v ${srcdir}:${dstdir} ${cname}
```


### Configuration:
There are a bunch of configuration params stored in the script.  If I feel like this is limiting my workflow I may externalize these into a config file which is `source`d in the script

The params:

```sh
# create dummy hostnames that will be consistent based on the last
# 2 octets of the main host's ip address
getname=$(host `hostname`|awk '{print $NF}'|awk -F. '{print "hostname-" $3 "-" $4}')
# where do i put stuff
srcdir="/data/boinc-client"
# where does the app inside the container look for my stuff
dstdir="/var/lib/boinc-client"
# whats my container name
cname="boinc"
# where do i find this magical container
repo="my-docker-repo-host:port"
  # set some defaults
  ALLOWREM=1
  REMHOST=changeme-or-dontsetme
  PROXYHOST=changeme-or-dontsetme
  PROXYPORT=changeme-or-dontsetme
  PROXYEXCL=changeme-or-dontsetme
  LOWPRIOR=1
  MAXUSECPU=66.666666
  IFUSECPU=66.000000
  MAXNUMCPU=100.00000

  # overrides for some hosts we dont want to kill. this method can be used for all vars
  # if you'd prefer you could create a separate file with these falues and source it here
  # source myconfig.sh
  [ "${getname}" == "hostname-12-57" ] && MAXNUMCPU=50.00000
  [ "${getname}" == "hostname-12-58" ] && MAXNUMCPU=50.00000

```

### Bulk Run Example
Here's how I run it
```sh
parallel-ssh -h /path/to/hostlist -O LogLevel=QUIET -i "/home/myuser/control-boinc $1"
 ```
