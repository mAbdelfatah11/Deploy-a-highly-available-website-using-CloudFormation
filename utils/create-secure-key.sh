ssh-keygen -t rsa -b 4096 -f ~/.ssh/WideBotBastionKey -C "WideBot bastion key" -N '' -q

aws ec2 import-key-pair --key-name "WideBotBastionKey" --public-key-material fileb://~/.ssh/udagramBastionKey.pub

aws ssm put-parameter --name 'WideBotBastionKeyPrivate' --value "$(cat ~/.ssh/WideBotBastionKey)" --type SecureString --overwrite	
aws ssm put-parameter --name 'WideBotBastionKey' --value "$(cat ~/.ssh/WideBotBastionKey.pub)" --type SecureString --overwrite	
