# AWS Application Load Balancer (ALB) Path-Based Routing 

Demo – digitalculture---## OVERVIEWThis project demonstrates the setup of an **AWS Application Load Balancer (ALB)** with **path-based routing** to distribute traffic across multiple backend EC2 instances.The architecture includes multiple EC2 instances, separate target groups, and an ALB configured with HTTP (port 80) to route traffic based on URL paths. The goal is to validate that requests to different paths are correctly forwarded to the appropriate backend applications.We will build:- EC2 instances for two applications (A and B)- Target groups for each application- An internet-facing Application Load Balancer- Path-based routing rules 

Routing Table
PathTargetBehavior/aTarget Group ARoutes to Application A (load balanced across instances)/bTarget Group BRoutes to Application BDefaultFixed ResponseReturns HTTP 503 error

STEP-BY-STEP DEPLOYMENT

1. CREATE SECURITY GROUPS
We begin by creating security groups for both the load balancer and backend resources.
Load Balancer Security Group


Name: PublicLoadBalancer


Inbound Rule:


HTTP (80)


Source: 0.0.0.0/0


This allows public HTTP traffic into the ALB.

Application Security Groups
App A Security Group


Inbound Rule:


HTTP (80)


Source: PublicLoadBalancer



App B Security Group


Inbound Rule:


HTTP (80)


Source: PublicLoadBalancer




This ensures backend instances only accept traffic from the ALB.

2. LAUNCH EC2 INSTANCES

Application A
We launch 2 EC2 instances:


VPC: Custom VPC


Subnet: Private Subnet A


Public IP: Disabled


Security Group: App A SG


User Data (Apache setup + path /a)
#!/bin/bashyum update -yyum install -y httpdsystemctl start httpdsystemctl enable httpdecho "Hello from Application A" > /var/www/html/index.htmlmkdir /var/www/html/aecho "Application A Path" > /var/www/html/a/index.html

Application B
We launch 1 EC2 instance:


Subnet: Private Subnet C


Security Group: App B SG


User Data (Apache setup + path /b)
#!/bin/bashyum update -yyum install -y httpdsystemctl start httpdsystemctl enable httpdecho "Hello from Application B" > /var/www/html/index.htmlmkdir /var/www/html/becho "Application B Path" > /var/www/html/b/index.html

3. CREATE TARGET GROUPS

Target Group A


Target Type: Instances


Protocol: HTTP


Port: 80


VPC: Custom VPC


Health Checks:


Path: /


Healthy Threshold: 2


Unhealthy Threshold: 2


Timeout: 2 seconds


Interval: 5 seconds


Targets:


Both Application A instances



Target Group B


Same configuration as A


Targets:


Application B instance





4. CREATE APPLICATION LOAD BALANCER


Name: (your ALB name)


Scheme: Internet-facing


IP Type: IPv4


Network: Custom VPC


Subnets: Public Subnet A + Public Subnet C


Security Group: PublicLoadBalancer



Listener Configuration


Protocol: HTTP


Port: 80


Default Action
Return fixed response:
Whoops, looks like you hit a dead end, this is not a valid page (503)

5. CREATE PATH-BASED ROUTING RULES

Rule A


Condition: Path = /a


Action: Forward to Target Group A


Priority: 1



Rule B


Condition: Path = /b


Action: Forward to Target Group B


Priority: 2



6. TESTING
After deployment, retrieve the ALB DNS name and test:
Test URLExpected Result/503 fixed response/abc503 fixed response/aRoutes to Application A/bRoutes to Application B

KEY LEARNINGS

Path-Based Routing
ALB evaluates request URLs and forwards traffic based on defined rules at Layer 7.

Security Group Design
Backend EC2 instances are not publicly exposed and only accept traffic from the ALB security group.

Health Checks
Target groups continuously validate instance health before routing traffic.

Default Rule Behavior
Any unmatched request is handled by a fixed response (503), preventing unintended routing.

Load Balancing Behavior
Application A demonstrates round-robin distribution across multiple instances.

TOOLS & SERVICES USED
AWS EC2, Application Load Balancer (ALB), Target Groups, Security Groups, VPC, Subnets, Apache HTTP Server

SUMMARY
This project successfully demonstrates how to:


Deploy an Application Load Balancer


Configure path-based routing


Secure backend EC2 instances


Validate routing behavior using real traffic tests



