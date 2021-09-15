#!/bin/bash

start() {
## redis	
redis_pres=`sudo netstat -antpu|grep 6379|grep -v TIME_WAIT`
redis_res=`ps -ef|grep redis-server|grep -v grep`
if [[ -z $redis_pres && -z $redis_res ]];
then
	echo "starting up redis-server ... "
	# sudo systemctl start redis-server 
	sudo redis-server /etc/redis.conf
else
	true
fi

## pg
pg_pres=`sudo netstat -antpu|grep 5432|grep -v TIME_WAIT`
# pg_res=`pg_isready`
if [[ -z $pg_pres && "$?" -ne "0" ]];
then
	echo "starting up postgres ... "
	PG12CTL=/usr/pgsql-12/bin/pg_ctl
	PG11CTL=/usr/pgsql-11/bin/pg_ctl
	if [ -f "$PG12CTL" ]; then
        	sudo su - postgres -s /bin/bash -c '/usr/pgsql-12/bin/pg_ctl -D /startalk/database start'
        elif [ -f "$PG11CTL" ]; then
        	sudo su - postgres -s /bin/bash -c '/usr/pgsql-11/bin/pg_ctl -D /startalk/database start'
        fi
else
        true
fi
sleep 5
  
## tomcat
# im_http_service
ihs_pres=`sudo netstat -antpu|grep 8081|grep -v TIME_WAIT`
ihs_res=`ps -ef|grep im_http_service|grep -v grep`
if [[ -z $ihs_res && -z $ihs_pres ]];
then
	echo "starting up im_http ... "
	sudo  su - startalk -s /bin/bash -c '/startalk/tomcat/im_http_service/bin/startup.sh'
else
	true
fi

# qfproxy
qfp_pres=`sudo netstat -antpu|grep 8082|grep -v TIME_WAIT`
qfp_res=`ps -ef|grep qfproxy|grep -v grep`
if [[ -z $qfp_pres && -z $qfp_res ]];
then
	echo "starting up qfproxy ... "
	sudo  su - startalk -s /bin/bash -c '/startalk/tomcat/qfproxy/bin/startup.sh'
else
	true
fi

# push_service
ps_pres=`sudo netstat -antpu|grep 8083|grep -v TIME_WAIT`
ps_res=`ps -ef|grep push_service|grep -v grep`
if [[ -z $ps_pres && -z $ps_res ]];
then
	echo "starting up push_service ... "
	sudo  su - startalk -s /bin/bash -c '/startalk/tomcat/push_service/bin/startup.sh'
else
	true
fi

## python
# supervisord
py_pres=`sudo netstat -antpu|grep 8884`
py_res=`ps -ef|grep supervisord|grep -v grep`
if [[ -z $py_pres && -z $py_res ]];
	echo "starting up supervisord services ... "	
then
        SUPERVISORSOCK=/startalk/search/supervisor.sock

        if [ -f "$SUPERVISORSOCK" ]; then
		unlink $SUPERVISORSOCK
        fi
	sudo su - startalk -s /bin/bash -c 'source /startalk/search/venv/bin/activate && /startalk/search/venv/bin/supervisord -c /startalk/search/conf/supervisor.conf'
else
	sudo su - startalk -s /bin/bash -c '/startalk/search/venv/bin/supervisorctl -c /startalk/search/conf/supervisor.conf restart all'
fi

## ejabberd
ejb_pres=`sudo netstat -antpu|grep 5202`
ejb_res=`ps -ef|grep ejabberd|grep -v grep`
if [[ -z $ejb_pres && -z $ejb_res ]];
then
	echo "starting up ejabberd ... "
	sudo  su - startalk -s /bin/bash -c  'cd /startalk/ejabberd && ./sbin/ejabberdctl start'
else
	true
fi

## or
or_pres=`sudo netstat -antpu|grep 8080`
or_res=`ps -ef|grep openresty|grep -v grep`
if [[ -z $or_pres && -z $or_res ]];
then
	echo "starting up openresty ... "
	sudo /usr/local/openresty/nginx/sbin/nginx -p /usr/local/openresty/nginx
else
	true
fi
}

stop() {

## tomcat
# im_http_service
ihs_pres=`sudo netstat -antpu|grep 8081|grep -v TIME_WAIT`
ihs_res=`ps -ef|grep im_http_service|grep -v grep`
if [[ -z $ihs_res && -z $ihs_pres ]];
then
	true
else
	echo "shutting down im_http ... "
	sudo  su - startalk -s /bin/bash -c  '/startalk/tomcat/im_http_service/bin/shutdown.sh'
	sleep 1
fi

# qfproxy
qfp_pres=`sudo netstat -antpu|grep 8082|grep -v TIME_WAIT`
qfp_res=`ps -ef|grep qfproxy|grep -v grep`
if [[ -z $qfp_pres && -z $qfp_res ]];
then
	true
else
	echo "shutting down qfproxy ... "
	sudo  su - startalk -s /bin/bash -c  '/startalk/tomcat/qfproxy/bin/shutdown.sh'
	sleep 1

fi

# push_service
ps_pres=`sudo netstat -antpu|grep 8083|grep -v TIME_WAIT`
ps_res=`ps -ef|grep push_service|grep -v grep`
if [[ -z $ps_pres && -z $ps_res ]];
then
	true
else
	echo "shutting down push_service ... "
	sudo  su - startalk -s /bin/bash -c  '/startalk/tomcat/push_service/bin/shutdown.sh'
	sleep 1
fi

## python
# supervisord
py_pres=`sudo netstat -antpu|grep 8884`
py_res=`ps -ef|grep supervisord|grep -v grep`
if [[ -z $py_pres && -z $py_res ]];
then
	true
else
	echo "shutting down supervisord services ... "
	SUPERVISORPID=`ps -ef|grep supervisord|grep startalk|grep -v grep|awk -F ' '  '{print $2}'`
	sudo su - startalk -s /bin/bash -c 'source /startalk/search/venv/bin/activate && /startalk/search/venv/bin/supervisorctl -c /startalk/search/conf/supervisor.conf stop all' && sudo kill $SUPERVISORPID
	sleep 1
fi


## ejabberd
ejb_pres=`sudo netstat -antpu|grep 5202`
ejb_res=`ps -ef|grep ejabberd|grep -v grep`
if [[ -z $ejb_pres && -z $ejb_res ]];
then
	true
else
	echo "shutting down ejabberd ... "
	sudo  su - startalk -s /bin/bash -c 'cd /startalk/ejabberd && ./sbin/ejabberdctl stop'
	sleep 1
fi

## or
or_pres=`sudo netstat -antpu|grep 8080`
or_res=`ps -ef|grep openresty|grep -v grep`
if [[ -z $or_pres && -z $or_res ]];
then
	true
else
	echo "shutting down openresty ... "
        # 这一步会需要startalk的密码
	sudo /usr/local/openresty/nginx/sbin/nginx -p /usr/local/openresty/nginx -s stop
        sleep 1
fi

## redis	
redis_pres=`sudo netstat -antpu|grep 6379`
redis_res=`ps -ef|grep redis-server|grep -v grep`
if [[ -z $redis_pres && -z $redis_res ]];
then
	true
else
	echo "shutting down redis ... "
	# sudo systemctl stop redis-server 
	sudo redis-cli -a 123456 shutdown
	sleep 1
fi

## pg
pg_pres=`sudo netstat -antpu|grep 5432`
# pg_res=`pg_isready`
if [[ -z $pg_pres && "$?" -ne "0" ]];
then
        true
else
	echo "shutting down postgres ... "
	PG12CTL=/usr/pgsql-12/bin/pg_ctl
	PG11CTL=/usr/pgsql-11/bin/pg_ctl
	if [ -f "$PG12CTL" ]; then
        	sudo su - postgres -s /bin/bash -c '/usr/pgsql-12/bin/pg_ctl -D /startalk/database stop'
        elif [ -f "$PG11CTL" ]; then
        	sudo su - postgres -s /bin/bash -c '/usr/pgsql-11/bin/pg_ctl -D /startalk/database stop'
        fi
        # sudo systemctl stop postgresql
fi

}


case $1 in
  start|stop) "$1" ;;
  restart) stop; start ;; 
esac

