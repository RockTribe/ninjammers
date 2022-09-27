#!/bin/bash


set -e
root=$PWD
mkdir -p ng
cd ng

require() {
    if [ ! $1 $2 ]; then
        echo $3
        echo "Running download..."
        download
    fi
}
require_file() { require -f $1 "File $1 required but not found"; }
require_dir()  { require -d $1 "Directory $1 required but not found"; }
require_env()  {
    var=`python3 -c "import os;print(os.getenv('$1',''))"`
    if [ -z "${var}" ]; then
        echo "Environment variable $1 not set. "
        echo "In your .env file, add a line with:"
        echo "$1="
        echo "and then right after the = add $2"
        exit
    fi
    eval "$1=$var"
}
require_executable() {
    require_file "$1"
    chmod +x "$1"
}

require_executable "ngrok"

# environment variables
require_env "ngrok_token" "your ngrok authtoken from https://dashboard.ngrok.com"
require_env "ngrok_region" "your region, one of:
us - United States (Ohio)
eu - Europe (Frankfurt)
ap - Asia/Pacific (Singapore)
au - Australia (Sydney)
sa - South America (Sao Paulo)
jp - Japan (Tokyo)
in - India (Mumbai)" 

# start tunnel
mkdir -p ./logs
touch ./logs/temp # avoid "no such file or directory"
rm ./logs/*
echo "Starting ngrok tunnel in region $ngrok_region"
./ngrok authtoken $ngrok_token
./ngrok tcp --log=stdout 2049 > $root/status.log &
echo "server Up!"
echo "server is now running!" > $root/status.log
echo
echo "================================================================================"

echo
echo "NINJAM Server IP is: $server_ip"
echo "<p>$server_ip</p>" > $root/ip.html
echo

# start ninjamsrv
../ninjamsrv ../example.cfg
