
## Description
This script help manipulate the services including:
1. Redis
1. Postgres 
1. im_http_service
1. qfproxy
1. push_service
1. Search
1. Ejabberd
1. Openresty

> The script only support the deployment of our [offcial guide](https://github.com/startalkIM/Startalk/blob/master/source-build.md). If you have customized Startalk, please modify the script yourself .

## Usage
``` sudo ./stctl.sh start ```

Start all services in the order listed in description.

``` sudo ./stctl.sh stop ```

Shut down all services in the **reverse** order listed in description.

``` sudo ./stctl.sh restart ```

Restart all services.
