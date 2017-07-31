# boinc

This container will run the boinc_client.

I forked this from https://github.com/bcleonard/boinc and have added a bunch of things to make the container more flexible.

### Preperation
I recommend exposing a directory from your host to the container in order to persist the boinc-client data.  I used:
```sh
mkdir -p /data/boinc
```
### Running:
This container has been modified from the original to provide the ability to customize the boinc-client config.


To run without any customizations and accept defaults use the below
```sh
docker run --name=boinc -h HOSTNAME -p 31416:31416 -v /data/boinc:/var/lib/boinc-client boinc 
```
To run with customizations variables can be passed to docker for configuring the boinc-client:
```sh
docker run --name=boinc -h HOSTNAME -e PROXYHOST=X.X.X.X -e PROXYPORT=YYYY -e PROXYEXCL=10.0.0.0/8 -e ALLOWREM=1 -e MAXNUMCPU=75.000000 -p 31416:31416 -v /data/boinc:/var/lib/boinc-client boinc
```
See below for a full list of currently available variables.

You can also pass commands to boinc using the docker exec command.  For example, to get the state of the boinc client:
```sh
docker exec boinc boinccmd --get_state
```
Or you can just drop into the container:
```sh
docker exec -it boinc bash
```

### Configuration:
This is how/where the customizations are added


`cc_config.xml` options -- the CAPWORD is the variable/value passed to docker via -e VAR=VALUE
```sh
    <http_server_name>PROXYHOST</http_server_name>
    <http_server_port>PROXYPORT</http_server_port>
    <no_proxy>PROXYEXCL</no_proxy>
<allow_remote_gui_rpc>ALLOWREM</allow_remote_gui_rpc>
<lower_client_priority>LOWPRIOR</lower_client_priority>
```
`global_prefs_override.xml`
```sh
   <suspend_cpu_usage>IFUSECPU</suspend_cpu_usage>
   <max_ncpus_pct>MAXNUMCPU</max_ncpus_pct>
   <cpu_usage_limit>MAXUSECPU</cpu_usage_limit>
```

Couple other variables:

`REMHOST` is the host allowed to remotely communicate with boinc client (`-e REMHOST=Z.Z.Z.Z`)

`LOWPRIOR` is to change the `nice` value of the process (default is on [which is 19] `-e LOWPRIOR=1`)


Information about parameters can be found here:

https://boinc.berkeley.edu/wiki/Global_prefs_override.xml

https://boinc.berkeley.edu/wiki/Client_configuration


### Additional Configuration:
I use BOINCTasks to manage my boinc clients instead of an account manager, check it out

https://efmer.com/

If you use an account manager you'll need to modify the template files as well as the startup.sh script to include these (or hard code them in the template files if you like.


### Notes/Caveats/Issues:
1.	-h HOSTNAME - I recommend that you use this option (choose your own hostname) so that your host id for boinc is not the container id.
2.	Check out the scripts/control-boinc script for an easy way to manage the containers.
