#!/usr/bin/env python
# -*- coding:utf-8 -*-
# import sys
import re
import uuid
import sys
import argparse
import psycopg2
import hashlib
from pypinyin import pinyin, Style

ejabberd_config_location = '/startalk/ejabberd/etc/ejabberd/ejabberd.yml'
DEFAULT_host = 1
DEFAULT_USER = 'testuser'
DEFAULT_NAME = 'testuser'
DEFAULT_PWD = 'testpassword'
PWD_SALT_PREFIX = 'qtalkadmin_pwd_salt_'
PS_DEPTID = 'startalk'
AVATAR_URL_SUFFIX = '/file/v2/download/avatar/new/daa8a007ae74eb307856a175a392b5e1.png?name=daa8a007ae74eb307856a175a392b5e1.png&file=file/daa8a007ae74eb307856a175a392b5e1.png&fileName=file/daa8a007ae74eb307856a175a392b5e1.png'


class PinyinUtil:
    """
    只保留中文， 返回拼音或者首字母， 不考虑多音字
    可通过修改回调函数errors来选择保留非中文字符
    """

    def __init__(self):
        pass

    def get_all(self, text):
        a = self.get_pinyin(text)
        b = self.get_first_letter(text)
        return [a, b]

    @staticmethod
    def get_pinyin(text):
        if not isinstance(text, str):
            text = str(text)
        res = pinyin(text, style=Style.NORMAL, errors=lambda x: x)  # 拼音
        res = ''.join([x[0] for x in res])
        return res

    @staticmethod
    def get_first_letter(text):
        if not isinstance(text, str):
            text = str(text)
        res = pinyin(text, style=Style.FIRST_LETTER, errors=lambda x: x)  # 首字母
        res = ''.join([x[0] for x in res])
        return res


class UserLib:
    def __init__(self, config=None):
        if config:
            ejab_conf = config
        else:
            ejab_conf = ejabberd_config_location
        try:
            with open(ejab_conf, 'r') as f:
                ejabberd_cfg = f.read()
                pg_config = self.get_pg_config(ejabberd_cfg)
        except PermissionError:
            print("Permission error, please switch to user Startalk.")
        except FileNotFoundError:
            print("Config file not found in {}, please input setting ... ".format(ejab_conf))
            # pg_host = str(input("请输入PG地址,默认为 127.0.0.1:") or "127.0.0.1")
            # pg_database = str(input("请输入PG数据库名称, 默认为 ejabberd: ") or "ejabberd")
            # pg_user = str(input("请输入PG用户, 默认为 ejabberd: ") or "ejabberd")
            # pg_pwd = str(input("请输入PG密码, 默认为 123456: ") or "123456")
            # pg_port = str(input("请输入PG端口, 默认为 5432: ") or "5432")
            pg_host = str(input("Please input Postgres host, deafult is 127.0.0.1:") or "127.0.0.1")
            pg_database = str(input("Please input Postgres database name, deafult is ejabberd: ") or "ejabberd")
            pg_user = str(input("Please input Postgres user, default is ejabberd: ") or "ejabberd")
            pg_pwd = str(input("Please input {user}'s password, default is 123456: ".format(user=pg_user)) or "123456")
            pg_port = str(input("Please input Postgres port, default is 5432: ") or "5432")

            pg_config = dict(host=pg_host, database=pg_database, user=pg_user, password=pg_pwd, port=pg_port)
        self.conn = psycopg2.connect(host=pg_config['host'], database=pg_config['database'], user=pg_config['user'],
                                     password=pg_config['password'], port=pg_config['port'])

    def get_pg_config(self, ejabberd_cfg: str):
        host_pattern = re.compile('\nsql_server:\s*\"(.*)\"')
        database_pattern = re.compile('\nsql_database:\s*\"(.*)\"')
        user_pattern = re.compile('\nsql_username:\s*\"(.*)\"')
        password_pattern = re.compile('\nsql_password:\s*\"(.*)\"')
        port_pattern = re.compile('\nsql_port:\s*\"(.*)\"$')

        p_host = host_pattern.findall(ejabberd_cfg)
        p_db = database_pattern.findall(ejabberd_cfg)
        p_u = user_pattern.findall(ejabberd_cfg)
        p_passwd = password_pattern.findall(ejabberd_cfg)
        p_port = port_pattern.findall(ejabberd_cfg)

        host = p_host[0] if p_host else None
        database = p_db[0] if p_db else None
        user = p_u[0] if p_u else None
        passwd = p_passwd[0] if p_passwd else None
        port = p_port[0] if p_port else '5432'
        return dict(host=host, database=database, user=user, password=passwd, port=port)

    def close(self):
        if not self.conn.closed:
            self.conn.close()


def md5(string):
    m = hashlib.md5()
    m.update(string.encode("utf8"))
    return m.hexdigest()


if __name__ == '__main__':
    cargs = sys.argv
    cargs.pop(0)
    config = None
    if len(cargs):
        if '-d' in cargs or '--d' in cargs:
            host_id = DEFAULT_host
            user_id = DEFAULT_USER
            user_name = DEFAULT_NAME
            password = DEFAULT_PWD
        else:
            parse = argparse.ArgumentParser()
            parse.add_argument('-e', '--virtualenv', help='use an existed python enviroment')
            parse.add_argument('-d', '--default',
                               help="create a new user with\n"
                                    "userid: {id}\n"
                                    "username:{name}\n"
                                    "password:{pwd}\n".format(id=DEFAULT_USER, name=DEFAULT_NAME, pwd=DEFAULT_PWD))
            parse.add_argument('-c', '--config',
                               help='specify ejabberd config file for getting postgres config, otherwise you need to input setting Interactively')
            parse.add_argument('hostid')
            parse.add_argument('userid')
            parse.add_argument('name')
            parse.add_argument('pwd')
            cargs = parse.parse_args(cargs)
            if cargs.config:
                config = cargs.config
            if cargs.hostid:
                host_id = cargs.hostid
            if cargs.userid:
                user_id = cargs.userid
            if cargs.name:
                user_name = cargs.name
            if cargs.pwd:
                password = cargs.pwd

    else:  # 交互
        # host_id = int(input("这是您的第几个域(host_id)？默认为 1:") or DEFAULT_host)
        # user_id = str(input("请输入新用户的id, 默认为 testuser: ") or DEFAULT_USER)
        # user_name = str(input("请输入新用户的名称, 默认为 testuser: ") or DEFAULT_NAME)
        # password = str(input("请输入新用户的密码, 默认为 testpassword: ") or DEFAULT_PWD)
        host_id = int(input("Which domain your new user is in(host_id)？ Default is 1:") or DEFAULT_host)
        user_id = str(input("What is your new user's account, default is testuser: ") or DEFAULT_USER)
        user_name = str(input("What is your new user's name, default is testuser: ") or DEFAULT_NAME)
        password = str(input("What is your new user's password, default is testpassword: ") or DEFAULT_PWD)

    salt_uuid = uuid.uuid4().hex

    custom_params = {
        'host_id': host_id,
        'user_id': user_id,
        'user_name': user_name,
        'password': password,
        'dep': '/智能服务助手',
        'department': '智能服务助手',
        'gender': 1,
    }
    if not config:
        config = ejabberd_config_location
    user_lib = UserLib(config)
    pinyin_util = PinyinUtil()
    constant_params = {
        'frozen_flag': 0,
        'version': 1,
        'user_type': 'U',
        'hire_flag': 1,
        'ps_deptid': PS_DEPTID,
        'pinyin': '|'.join(pinyin_util.get_all(custom_params.get('user_name'))),
        'pwd_salt': PWD_SALT_PREFIX + salt_uuid,
        'password': 'CRY:' + md5(md5(md5(custom_params.get('password')) + PWD_SALT_PREFIX + salt_uuid)),
        'initialpwd': 1
    }
    with user_lib.conn as conn:
        with conn.cursor() as cursor:
            params = {**custom_params, **constant_params}
            sql1 = """insert into host_users (host_id, user_id, user_name, department, dep1, pinyin, frozen_flag, version, user_type, hire_flag, gender, password, initialpwd, pwd_salt, ps_deptid)
             values (%(host_id)s, %(user_id)s, %(user_name)s, %(dep)s, %(department)s, %(pinyin)s, %(frozen_flag)s, %(version)s, %(user_type)s, %(hire_flag)s, %(gender)s, %(password)s, %(initialpwd)s, %(pwd_salt)s, %(ps_deptid)s);"""
            cursor.execute(sql1, params)
            vcard_params = {**custom_params, **{
                "version": 1,
                "profile_version": 1,
                "host": "startalk",
                "url": AVATAR_URL_SUFFIX
            }
                            }
            sql2 = """insert into vcard_version (username, version, profile_version, gender, host, url) 
            values (%(user_id)s, %(version)s, %(profile_version)s, %(gender)s, %(host)s, %(url)s);"""
            cursor.execute(sql2, vcard_params)
    user_lib.close()
    print("User {} added! ".format(user_id))
