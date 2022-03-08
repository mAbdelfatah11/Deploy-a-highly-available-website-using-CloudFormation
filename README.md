# Deploy a high-availability web app using CloudFormation
Mahmoud AbdelFatah / DEvOps engineer - WideBot


##Problem:
========

Our company is creating a new Website clone called WideBot,

	1. Developers pushed the latest version of their code in a zip file located in a public S3 Bucket.

	2. I have been tasked with deploying the application, by retrieving the last version code from s3 and deploy it in server.

 
##Server specs:


1. You'll need to create a Launch Configuration for your application servers in order to deploy four servers, two located in each of your private subnets. The launch configuration will be used by an auto-scaling group.

2. You'll need two vCPUs and at least 4GB of RAM. The Operating System to be used is Ubuntu 18. So, choose an Instance size and Machine Image (AMI) that best fits this spec.

3. Be sure to allocate at least 10GB of disk space so that you don't run into issues. 


##Security Groups and Roles:


1. Since you will be downloading the application archive from an S3 Bucket, you'll need to create an IAM Role that allows your instances to use the S3 Service.

2. ActiveMood communicates on the default HTTP Port: 80, so your servers will need this inbound port open since you will use it with the Load Balancer and the Load Balancer Health Check. As for outbound, the servers will need unrestricted internet access to be able to download and update their software.

3. The load balancer should allow all public traffic (0.0.0.0/0) on port 80 inbound, which is the default HTTP port. Outbound, it will only be using port 80 to reach the internal servers.

4. The application needs to be deployed into private subnets with a Load Balancer located in a public subnet.

5. One of the output exports of the CloudFormation script should be the public URL of the LoadBalancer. Bonus points if you add http:// in front of the load balancer DNS Name in the output, for convenience.



## Solution

> ### Diagram

![Diagram](/Architecture-Diagram.png)

> ### Description

The solution consisted in split the whole infrastructure in differents stack template files this allow that the project has modularity.

> ### Files structure
1. The `network` folder has the files to deploy a stack with the whole network to the will using in the project.
2. The `bastion` folder has the files to deploy a stack with a bastion host to connect the hosts with the website of a secure way.
3. The `bucket` folder has the files to deploy a stack with the `AWS::S3` bucket that stores the website files, that is, `Udacity.zip`
4. The `iam` folder has the files to deploy a stack with the role that will use to upload/download files from the bucket
5. The `server` folder has the files to deploy a stack with the website hosts. Also deploy these hosts using `LoadBalancer`, `AutoScaling`, and `ClouWatch` alarms.
6. The `src` folder has the website files to deploy.
7. The `utils` folder has the code files using to help such as utilities.

> ### Instructions

This is a project that anyone could uses to learn about CloudFormation, if you want to deploy this project follow the instructions are below:

1. You need to create a Secure KeyPair that will use to connect to Bastion Host, in a terminal using the file `utils/create-secure-key.sh`
    > `utils/create-secure-key.sh`

2. You need to create the website files to upload to S3 Bucket, in a terminal using the command zip, 
    > `zip udacity.zip src/*`

3. You need to create the s3 and iam stacks, in a terminal using the file `utils/create-stack-key.sh` 
    > `utils/create-stack.sh iam-stack iam/iam-stack-template.yml iam/iam-parameters.json`
    
    > `utils/create-stack.sh s3-stack bucket/s3-bucket-stack-template.yml bucket/s3-bucket-parameters.json`

4. You need to upload the website files created previously to s3 bucket, in a terminal using aws cli
    > `aws s3 cp udacity.zip s3://udagram-s3-store`

5. You need to create the other stacks described above, in a terminal

    > `utils/create-stack.sh network-stack network/network-stack-template.yml network/network-parameters.json`
    
    > `utils/create-stack.sh bastion-stack bastion/bastion-stack-template.yml bastion/bastion-parameters.json`

    > `utils/create-stack.sh server-stack server/server-stack-template.yml server/server-parameters.json`

You should be able to access the final website using the LoadBalancer DNS name
