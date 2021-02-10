#!/bin/bash
set -e
venv="/startalk/search/venv/bin/activate"
setenv(){
echo "Using python virtualenv: "  ${venv}
source $venv
echo $venv
}
adduser()
{
parent_dir=$(dirname "$0")
py_dir="$parent_dir/add_user.py"
pip3 -q install psycopg2-binary pypinyin
python3 $py_dir "$@"
}


while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--virtualenv) venv="$2";setenv; shift; shift ;;
        *) break;;
    esac
done
adduser "$@"
