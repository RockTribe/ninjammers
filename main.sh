#!/bin/bash

chmod +x nj.sh
./nj.sh &
python3 -m http.server
