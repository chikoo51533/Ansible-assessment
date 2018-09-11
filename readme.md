# Simple Web Application
I've made use of AWS's ec2 instances and ELB to host the application to serve the static

# Tech stack
  - AWS IAM User (To create EC2 instances, ELB)
  - Ansible (To configure the EC2 instances with httpd )
  - Ansible EC2 Module ( To Interact with AWS using Ansible)
  - github to pull the repository to workbench

# Project Structure
Project Folder
├── ansible.cfg
├── group_vars
│   └── all
├── httpd
│   ├── handlers
│   │   └── main.yml
│   ├── static_files
│   │   ├── httpd.conf
│   │   ├── index.html
│   │   ├── my-aws-private.key
│   │   ├── my-aws-public.crt
│   │   └── ssl_script.sh
│   └── tasks
│       └── main.yml
├── create_stack.yml 


### Files:
  - **ansible.cfg**
    This file holds the configuration related to connection parameters such as, host_key_checking set to False, and private_key_file is set to absolute path of the pem file to connect to AWS Instance for configuration changes.
  - **group_vars/all**
    This File holds the information about the parameters or variables required to run ansible playbook
    ###### Parameters:
    - region: us-east-1
    - instance_type: t2.micro
    - vpc_id: vpc-f83d2f9a
    - public_subnet_id: subnet-4c102138
    - private_ip_cidr: 0.0.0.0/0
    - private_subnet_id: subnet-4c102138
    - instance_count: 1
    - ami: ami-0ff8a91507f77f867  # Amazon Linux AMI 2018.03.0
    - tag: web_server
    - pem_key: mywebserver # keypair name
 - **httpd (Directory)**
    - **handler/main.yml** is the handler function to make sure the services are up and running
    This is anisble role, which has the information about configuring the newly created ec2 instances
    - **static_files/httpd.conf** to replace the httpd config in servers, which has server side re-routing enabled for 80 to 443
    - static_files/index.html, static index.html page to be served by httpd server
    - **static_files/my-aws-private.key**, **static_files/my-aws-public.crt** are private and public keys needed to create ACM certificate to use on ELB for https configuration
    - ssl_script.sh to create self signed certficate for 80 to 443 re-direction
 - **tasks/main.yml** is role related configuration, such as making sure httpd, mod_ssl, openssl modules
 - **create_stack.yml** is main playbook file which will creates the security groups related to EC2 instances, making sure the ports are open only for Internal IP ranges and creates a security group related to ELB to make sure port 80, 443 are exposed to world. runs the httpd role on newly created EC2 instances, creates IAM certificates pre defined self singed url, creates ELB in Public subnet and attaches the relavant security group, when the instaces are ready to serve the index.html, it add those instaces to ELB along with 80 --> 80, 443 --> 443 port mapping.

# Description

By usign the Ansible play-book we are creating required number of ec2 instances [**for scalability**] and configuring them with httpd along with 80 --> 443 redirection using self singed certficates. Once the instances are upto they will be added to ELB as nodes, and ELB will only forward the traffic if the basic health check is passed [**Testing**]. 

# Steps to run the ansible playbook

#### Prepare Ansible Work Bench ####
1. Create an EC2 instance with public login enables
2. Set up the AWS Configuration
    1.  Run `aws configure` and provide "__AWS Access Key ID__" "__AWS Secret Access Key__"  
    2.  verify configuration by running `aws sts get-caller-identity`. Will provide the IAM user information
    3. Install boto3 using `pip install boto3`, Needed for ec2 management
3. Install Ansible using `pip install ansible`
4. Verify Ansible installation using `ansible --version`
5. Install GIT using `yum install git`
6. Clone repository using `git clone <https://linktothis repository>`
  
#### Run Ansible Playbook ####
- Edit [ansible.cfg] with appropriate location of PEM to gain the log in access
    - private_key_file=<AbsolutePath>/<FileName>.pem  
    - Example: private_key_file=/Users/dir/mykeys/key.pem
- Edit [group_vars/all] file with appropriate information such as region, instance_type, private_ip_cidr etc
- Run play book as `ansible-playbook create_stack.yml` 

### Alternative Approches 1
**using s3 bucket for hosting**
- If the applicaiton is only about serving the static contect, we can levarage s3 buckets for hosting, which are higly available and scalable to meet the demand.
- for redirecting from 80 t0 443, and to reduce the latency we can use CloudFront Destributions

### Alternative Approches 2
**By using cloudformation template with ansible**

- Launch an EC2, and install httpd, generate self signed certficate, configure httpd.conf file with re-direction from 80 to 443 in VirtualHost configuration section of httpd.conf, servers a default index.html page with static contect
- Create an AMI from the previously launched EC2 
- Create ELB in public subnet, and map the port 80-->80, attach security group with only port acces to 80 and 443
- Create self-signed certification, with CN name as ELB DNS name, and create an ACM server certification with the help of newly created certificates
- Update the previously launced ELB, to allow port mappring 443 to 443, and map newly created ACM certificate
- Use newly created AMI to create a Launch configuration, and set AutoScaling policies based on the cpu utilization considering the ELB as the loadbalancer.


