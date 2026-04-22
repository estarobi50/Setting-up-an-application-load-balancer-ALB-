#!/bin/bash  

# Allowing YUM updates and installations from cloud_user  
echo '%password%' | passwd cloud_user --stdin  
yum update -y  
yum install -y httpd  

# Starting and enabling HTTPD service  
systemctl start httpd.service  
systemctl enable httpd.service  

# Adding HTTPD group and adding cloud_user  
groupadd www  
usermod -a -G www cloud_user  

# Get the IMDSv2 token  
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`  

# Setting homepage index.html file.
cat <<EOF > /var/www/html/index.html
<html>
    <title>DigitalCulture Prep</title>
    <body>
        <p>Success Instance B</p>
    </body>
<html>
EOF

mkdir -p /var/www/html/b/

# Setting the app index.html file.
cat <<EOF > /var/www/html/b/index.html
<html>
    <style>
    
    .center {
        display: block;
        margin-left: auto;
        margin-right: auto;
        width: 50%;
    }
    </style>
    <title>DigitalCulture Prep</title>
    <body>
        <span style="padding-top: 200px;"></span>
        <img src="https://d31xik8pupf3da.cloudfront.net/public-assets/ps-logo.png" style="max-width: 400px; display: block; margin-left: auto; margin-right: auto; width: 50%;"/>
        <span style="padding-top: 100px;"></span>
        <p></p>
        <p></p>
    </body>
<html>
EOF

# Creating simple index.html file for HTTPD base page  
echo '<html><h1>Hello! <strong>I am hosting application B!</strong></h1><h2>I live in this Availability Zone: ' >> /var/www/html/b/index.html 
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone >> /var/www/html/b/index.html
echo '</h2> <h2>I go by this Instance Id: ' >> /var/www/html/b/index.html
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id >> /var/www/html/b/index.html  
echo '</2></html> ' >> /var/www/html/b/index.html

# Restarting HTTPD service to enforce new index.html just to be safe.  
systemctl restart httpd.service
