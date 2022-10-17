#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
MYIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<h2>Built by Power of Terraform Version v0.0.4</h2>

<h3>Edited with Elastic IP</h3>

Server Owner is ${f_name} ${l_name}
%{ for x in wanted_countries ~}
I want to visit: ${x} with ${l_name} <br>
%{ endfor ~}
</html>
EOF

sudo service httpd start
sudo chkconfig httpd on