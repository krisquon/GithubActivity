#/bin/bash
# This shell is to swap from web1 to web2
cd /etc/nginx
sed -e s?web1:8080/GithubActivity_war/?web2:8080/GithubActivity_war/? <nginx.conf > /tmp/xxx
cp /tmp/xxx nginx.conf
service nginx reload 
