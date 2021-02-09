#!/bin/bash
set -e
venv="/startalk/search/venv/bin/activate"
setenv(){
echo "使用python 环境: "  ${venv}
source $venv
echo $venv
}
adduser()
{
pip3 -q install psycopg2-binary pypinyin
python3 ./add_user.py "$@"
}


while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--virtualenv) venv="$2";setenv; shift; shift ;;
        *) break;;
    esac
done
adduser "$@"
