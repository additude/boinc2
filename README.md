# boinc

This container will run the boinc_client.  It is built so that you can host all the project data external to the container, allowing you run the client on a host and have persistant data.

I forked this from https://github.com/bcleonard/boinc and have added a bunch of things to make the container more flexible.

### Preperation
Before running the container, you'll need to have the following directories predefined on the container host:
```sh
boinc
```
It will also need to be owned or read/writable by the user/group root as the boinc_client runs as root in the container.  The boinc directory will hold all of your boinc data and make persistant.  I used:
```sh
/data/boinc
```
for the instructions below.  Just make sure you create it prior to starting the container.
### Running:
To run without any customizations and accept defaults use the below
```sh
docker run --name=boinc -h HOSTNAME -p 31416:31416 -v /data/boinc:/var/lib/boinc-client boinc 
```
To add some customizion options to the boinc-client cc_config.xml and/or global_prefs_override.xml files variable can be set via docker:
```sh
docker run --name=boinc -h HOSTNAME -e PROXYHOST=X.X.X.X -e PROXYPORT=YYYY -e PROXYEXCL=10.0.0.0/8 -e ALLOWREM=1 -e MAXNUMCPU=75.000000 -p 31416:31416 -v /data/boinc:/var/lib/boinc-client boinc
```
See below for a full list of currently available variables.

Please see the Notes/Caveats/Issues below for more information.
### Configuration:
As I said before, /data/boinc will hold all of your project data.  You can prepopulate any files you need or let the client initialize it for you.
You will need to configure the boinc_client before it can do any actual work.  I recommend running the following:
```sh
docker exec boinc boinccmd --join_acct_mgr URL name passwd
```
which will attach the client to an account manager.  This should initialize the client so it starts doing work.

I started using BOINCTasks to manage my boinc clients instead of an account manager, check it out

https://efmer.com/

### Additional Configuration:
Since docker now has the exec command, you can now run commands inside the container.  For this container, you can run the boinccmd and use it to configure the boinc_client.  The following syntax works:
```sh
decker exec boinc boinccmd <boinccmd arguements>
```
Running the above command without any boinccmd arguements will show you what arguments you can use.  For example, to get the state of the boinc client:
```sh
docker exec boinc boinccmd --get_state
```
cc_config.xml options -- the CAPWORD is the variable/value passed to docker via -e VAR=VALUE
```sh
    <http_server_name>PROXYHOST</http_server_name>
    <http_server_port>PROXYPORT</http_server_port>
    <no_proxy>PROXYEXCL</no_proxy>
<allow_remote_gui_rpc>ALLOWREM</allow_remote_gui_rpc>
<lower_client_priority>LOWPRIOR</lower_client_priority>
```
global_prefs_override.xml
```sh
   <suspend_cpu_usage>IFUSECPU</suspend_cpu_usage>
   <max_ncpus_pct>MAXNUMCPU</max_ncpus_pct>
   <cpu_usage_limit>MAXUSECPU</cpu_usage_limit>
```

Couple other variables:

REMHOST is the host allowed to remotely communicate with boinc client (-e REMHOST=Z.Z.Z.Z)

LOWPRIOR is to change the `nice` value of the process (default is on [which is 19] -e LOWPRIOR=1)


Information about parameters can be found here:

https://boinc.berkeley.edu/wiki/Global_prefs_override.xml

https://boinc.berkeley.edu/wiki/Client_configuration


### Notes/Caveats/Issues:
1.	-h HOSTNAME - I recommend that you use this option (choose your own hostname) so that your host id for boinc is not the container id.
2.	I have installed the 32 bit binaries so that projects such as climateprediction will run.  However, for some reason, the boinc_client doesn't see them, so 32 bit projects won't run.  The same libraries work outside of a container, so I'm not sure whats going on.  Its low on my list, but if somebody can point me in the right direction, I'd be grateful.
3.	No GUI password.  By default, I set a blank password.  You can change this by prepopulating /data/boinc/gui_rpc_auth.cfg.  If somebody asks, I update the script to generate a randon password on initial startup.
4.	After starting, I had to manually tell the client to start downloading work.  I'm not sure why I had to do that, but I waited almost 8 hours and it still hadn't downloaded any work.  After doing that, the work downloaded and it started doing work.
