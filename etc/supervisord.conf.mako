[include]
files = ../adhocracy3/parts/supervisor/supervisord.conf

[supervisord]
childlogdir =  %(here)s/../var/log
logfile =  %(here)s/../var/log/supervisord.log
logfile_maxbytes = 50MB
logfile_backups = 10
loglevel = info
pidfile =  %(here)s/../var/supervisord.pid
umask = 022
nodaemon = false
nocleanup = false

[inet_http_server]
port = 127.0.0.1:8006
username =
password =

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl = http://127.0.0.1:8006
username =
password =

[program:nginx]
command = nginx -c %(here)s/nginx.conf -p %(here)s/.. -g "error_log stderr;"
priotity = 5
redirect_stderr = true
stdout_logfile = %(here)s/../var/log/nginx.log
stderr_logfile = NONE

[program:policycompass-services]
% if config_type=="dev":
command = ./bin/python manage.py runserver --noreload
% else:
command = ./bin/gunicorn -n policycompass-services -w 4 policycompass_services.wsgi
% endif
directory = %(here)s/../policycompass-services
priority = 10
redirect_stderr = true
stdout_logfile = %(here)s/../var/log/policycompass-services.log
stderr_logfile = NONE

[program:policycompass-frontend]
command = node server.js
directory = %(here)s/../policycompass-frontend
priority = 20
redirect_stderr = true
stdout_logfile = %(here)s/../var/log/policycompass-frontend.log
stderr_logfile = NONE

[program:elasticsearch]
command = %(here)s/../bin/elasticsearch
                -Des.default.config=%(here)s/elasticsearch/elasticsearch.yml
                -Des.default.path.conf=%(here)s/elasticsearch
                -Des.default.path.home=%(here)s/../var/lib/elasticsearch
                -Des.default.path.logs=%(here)s/../var/log
                -Des.default.path.data=%(here)s/../var/lib/elasticsearch/data
directory = %(here)s/../var/lib/elasticsearch
environment = ES_INCLUDE=%(here)s/../bin/elasticsearch.in.sh
priority = 5
redirect_stderr = true
stdout_logfile = %(here)s/../var/log/elasticsearch.log
stderr_logfile = NONE

[program:postgres]
command = %(here)s/../bin/postgres -D %(here)s/../var/lib/postgres  -c config_file=%(here)s/postgres/postgresql.conf -c hba_file=%(here)s/postgres/pg_hba.conf -c unix_socket_directories=''
priority = 5
redirect_stderr = true
stdout_logfile = %(here)s/../var/log/postgres.log
stderr_logfile = NONE
directory = %(here)s/..

[program:tomcat]
command = ./bin/catalina.sh run
environment = JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64, CATALINA_BASE=%(here)s/../var/lib/tomcat, CATALINA_TMPDIR=/tmp, CATALINA_OPTS="-Dcarneades.configuration=%(here)s/../.carneades.clj"
priority = 10
redirect_stderr = true
stdout_logfile = %(here)s/../var/log/tomcat.log
stderr_logfile = NONE

[program:eventminer]
command = ./bin/python flask_file.py run
priority = 15
redirect_stderr = true
stdout_logfile = %(here)s/../var/log/eventminer.log
stderr_logfile = NONE
directory = %(here)s/../eventminer

[group:policycompass]
programs = policycompass-frontend, policycompass-services, elasticsearch, tomcat, postgres, eventminer
