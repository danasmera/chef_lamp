# chef_lamp
A full LAMP stack setup using Chef

# Install and upload cookbooks
berks install
berks upload lamp

# List cookbooks uploaded to Chef server
knife cookbook list

# Converge node
sudo chef-client
