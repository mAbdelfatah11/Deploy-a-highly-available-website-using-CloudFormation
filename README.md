# Deploy a high-availability web app using CloudFormation
Mahmoud AbdelFatah / DevOps Engineer


## Problem

Our company is creating a new Website clone,

1. Developers pushed the latest version of their code in a zip file located in a public S3 Bucket.

2. I have been tasked with deploying the application, by retrieving the last version code from s3 and deploy it in server.

 
> ### Server Spec.:

1. You'll need to create a Launch Configuration for your application servers in order to deploy four servers, two located in each of your private subnets. The launch configuration will be used by an auto-scaling group.

2. You'll need two vCPUs and at least 4GB of RAM. The Operating System to be used is Ubuntu 18. So, choose an Instance size and Machine Image (AMI) that best fits this spec.

3. Be sure to allocate at least 10GB of disk space so that you don't run into issues. 


> ### Security Groups and Roles:


1. Since you will be downloading the application archive from an S3 Bucket, you'll need to create an IAM Role that allows your instances to use the S3 Service.

2. ActiveMood communicates on the default HTTP Port: 80, so your servers will need this inbound port open since you will use it with the Load Balancer and the Load Balancer Health Check. As for outbound, the servers will need unrestricted internet access to be able to download and update their software.

3. The load balancer should allow all public traffic (0.0.0.0/0) on port 80 inbound, which is the default HTTP port. Outbound, it will only be using port 80 to reach the internal servers.

4. The application needs to be deployed into private subnets with a Load Balancer located in a public subnet.

5. One of the output exports of the CloudFormation script should be the public URL of the LoadBalancer. Bonus points if you add http:// in front of the load balancer DNS Name in the output, for convenience.



## Solution

> ### Diagram

![Diagram](/docs/Architecture-Diagram.png)

> ### Description

The solution consists of dividing the entire infrastructure into different stacked template files, allowing the project to have modularity.

> ### Files structure
1. The `utils` folder contains all the required scripts which will help to deploy the stacks in an automated manner.
2. The `network` folder has the files to deploy a stack with the whole network infrastructure.
3. The `bastion` folder has the files to deploy a stack with a bastion host in order to connect to website hosts in a secure way.
4. The `bucket` folder has the files to deploy a stack with the `AWS::S3` bucket that stores the website files, that is, `WebsiteFiles.zip`
5. The `iam` folder has the files to deploy a stack with the InstanceProfile that will be used by hosts to upload/download files from the bucket.
6. The `server` folder has the files to deploy a stack with the website hosts, in addition to `LoadBalancer`, `AutoScaling`, and `ClouWatch` alarms.
7. The `src` folder has the website files to deploy.



> ### Instructions

1. You need to create a Secure KeyPair that will be used later to connect to the Bastion Host,then to the web servers, so in the terminal use the file `utils/create-secure-key.sh` to create the key pair.
  
  > `utils/create-secure-key.sh`
	
	     File content discription:

		ssh-keygen -t rsa -b 4096 -f ~/.ssh/WideBotBastionKey -C "WideBot bastion key" -N '' -q
			# ssh-keygen is a third party tool to create key-pairs  using cli
			# the output will be the two keys "puplic and private" like the lock and key
			# these two keys are stored in "/home/user/.ssh/" folder

		aws ec2 import-key-pair --key-name "WideBotBastionKey" --public-key-material fileb://~/.ssh/WideBotBastionKey.pub

			# the above command will import the puplic key from my computer to aws, 
			# in order to be associated directly to any instance or launch config. resource code.

		aws ssm put-parameter --name 'WideBotBastionKeyPrivate' --value "$(cat ~/.ssh/WideBotBastionKey)" --type SecureString --overwrite
		aws ssm put-parameter --name 'WideBotBastionKey' --value "$(cat ~/.ssh/WideBotBastionKey.pub)" --type SecureString --overwrite

			# we use parameter store which is one of the SSM-system manager services, we use it to store our config. data in aws, so 
			# you can import them in cloudformation scripts

2. You need to create the website files to upload to S3 Bucket, in a terminal using the command zip, 
    > `zip WebsiteFiles.zip src/*`

3. You need to create the s3 and iam stacks, in a terminal using the file `utils/create-stack-key.sh` 
    > `utils/create-stack.sh iam-stack iam/iam-stack-template.yml iam/iam-parameters.json`
    
    > `utils/create-stack.sh s3-stack bucket/s3-bucket-stack-template.yml bucket/s3-bucket-parameters.json`

4. You need to upload the website files created previously to s3 bucket, in a terminal using aws cli
    > `aws s3 cp WebsiteFiles.zip s3://WideBot-s3-store`

5. You need to create the other stacks described above, in a terminal

    > `utils/create-stack.sh network-stack network/network-stack-template.yml network/network-parameters.json`
    
    > `utils/create-stack.sh bastion-stack bastion/bastion-stack-template.yml bastion/bastion-parameters.json`

    > `utils/create-stack.sh server-stack server/server-stack-template.yml server/server-parameters.json`

You should be able to access the final website using the LoadBalancer DNS name
