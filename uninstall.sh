#!/bin/bash
set +e
rm -r /etc/code-server-hub
rm /etc/nginx/sites-available/code
rm /etc/nginx/sites-available/code-hub-docker
rm /etc/nginx/sites-enabled/code
rm /etc/nginx/sites-enabled/code-hub-docker