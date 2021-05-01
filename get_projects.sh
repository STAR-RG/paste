#!/bin/bash

wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1TU3cW8S30RwOoDKtpzeI9SO8E3FxmJFa' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1TU3cW8S30RwOoDKtpzeI9SO8E3FxmJFa" -O projects.tar.gz && rm -rf /tmp/cookies.txt

tar -xvzf projects.tar.gz
rm -f projects.tar.gz
