# Add User 

This is a python3 based bash script for adding a new user to Postgres.  

```
usage: -h [-h] [-e VIRTUALENV] [-d DEFAULT] [-c CONFIG] hostid userid name pwd

positional arguments:
  hostid
  userid
  name
  pwd

optional arguments:
  -h, --help            show this help message and exit
  -e VIRTUALENV, --virtualenv VIRTUALENV
                        use an existed python enviroment
  -d DEFAULT, --default DEFAULT
                        create a new user with userid: testuser
                        username:testuser password:testpassword
  -c CONFIG, --config CONFIG
                        specify ejabberd config file for getting postgres
                        config, otherwise you need to input setting
                        Interactively
```
## Examples
+ Create a user in default config  
```./adduser.sh -d```    

>| hostid  | userid | name | pwd |
>| ------- |:-------------:| :-----:| :---:|
>| 1       | testuser | testuser | testpassword|  

+ Create a user Bob  
```./adduser.sh 1 bob2021 Bob bobpassword```

+ Create a user *Bob* with specified python virtualenv  
```./adduser.sh -e /some/path/bin/activate 1 bob2021 Bob bobpassword ```  
>Without ```-e ENV```, the python dependencies ```psycopg2``` and ```pypinyinn``` will be installed in current python environment.
+ Create a user *Bob* with specified ejabberd config file.  
```./adduser.sh -c /path/to/ejabberd/etc/ejabberd/ejabberd.yml  1 bob2021 Bob bobpassword```  
> The ejabberd config file is used for getting the setting of Postgres connection.  
Without ```-c PATH```, the script will try to find config in ```/startalk/ejabberd/etc/ejabberd/ejabberd.yml```. If the config still cannot be found, it will ask for Postgres Setting interactively.  
+ Show help mannual  
```./adduser.sh -h```


## Positional arguments explanation

**hostid** :  
+ It's the ```host_id``` field in table ```host_users```, it's the serial number of the domain of your new user.  
If you want to know the id of your domain, check table ```host_info``` .   

**userid** :  
+ It's the ```user_id``` field in table ```host_users```, it's the user id of your new user.  
Please keep the name in **lower case English** and without symbols other than  ```_-.``` .  

**name** :  
+ It's the ```user_name``` field in table ```host_users```, the name shown by your new user.  
You can use **any language contained in Postgres** for this.  

**pwd** :
+ It's the password of new user. After encryption, it will be stored in ```password``` filed in table ```host_users``` .  
The rule of generating the password is in [This wiki](https://github.com/startalkIM/ejabberd/wiki/%E5%AF%86%E7%A0%81%E7%94%9F%E6%88%90%E8%A7%84%E5%88%99) .  
In this script, an uuid is generated and then join the prefix string ```"qtalkadmin_pwd_salt_" + uuid.uuid4().hex``` as ```pwd_salt``` .  


## Q&A
+ Errors occured during install python dependencies:  
Install dependencies mannually ```pip install psycopg2-binary pypinyin```

+ Change user avatar:  
After uploading the .png to Startalk by [qfproxy](https://github.com/startalkIM/qfproxy), an url will be received:  

|file_url|uuid_suffix|
|:---:|:---:|
| The file url is setting in your navigation|unique uuid generated by qfproxy|
|https://i.startalk.im|/file/v2/download/1c849f885b333d37d74f1b84e3d8e4edd.png|

And then replace ```AVATAR_URL_SUFFIX``` in ```add_user.py``` to your ```uuid_suffix```. 

+ Other info about new user could be changed in ```custom_params``` and ```constant_params``` in ```add_user.py```.  
+ Contact us by Email: app(AT)startalk.im




