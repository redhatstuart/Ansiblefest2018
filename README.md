# Ansiblefest2018
Content for Ansible Fest 2018

## Demo Steps

Service principal description - generate
Populate credentials file       
Deploy two VMs from playbooks for Mattermost - azure_rm_virtualmachine          Deploy Ansible Role to configure first server as MySQL
Deploy Mattermost application to second server
Deploy VM from ARM template
Install Tomcat (or othe application) on VM
Store VM image deployed from ARM template
Create 2 node Scale Set from stored ARM template image
Scale Out VMSS to 3 nodes
Application Gateway?


## vars.yml

This file contains all the variables shared by demo tasks:

|Variable      |Description                                    |
|--------------|-----------------------------------------------|
|resource_group|This is the resource group name used by demos  |
|location      |Region where resources should be created       |
|vm_name       |Virtual machine name that contains application |
|vm_image_name |Name of target image used in the demo          |
|admin_username|VMSS admin user name                           |
|admin_password|VMSS admin password                            |
|vmss_name     |VMSS name                                      |


## Playbooks

### 00-prerequisites.yml

Should be run before the event.

It will create all required prerequisites:
- create empty resource group

TODO: decide what prerequisites we actually need

### 01-mm-vm-deploy.yml

- deploys VM for Mattermost Application

### 02-mm-vm-deploy.yml

- creates MySQL Server
- creates **mattermost** database
- creates appropriate firewall rule for Mattermost VM

### 03-mm-setup.yml

- sets up Mattermost on VM server

### 04-create-vm-image.yml

- stops VM with Mattermost
- generalizes it (using REST API)
- creates image

TODO: remove Mattermost VM??

### 05-vmss-create.yml

This task creates:
- load balancer
- virtual machine scaleset

and currently also a few prerequisites:
- virtual network
- subnet
- public ip address
- network security group

TODO: Reuse networking infrastructure from previous tasks

### 06-appgateway-create.yml

This task creates application gateway, but us still not connected to the scaleset.
