# Ansiblefest2018
Content for Ansible Fest 2018

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

### prerequisites.yml

Should be run before the event.

It will create all required prerequisites:
- create empty resource group

### create-vm-image.yml

This task will take existing VM and:
- stop it
- generalize it (using REST API)
- create image

### vmss-create.yml

This task creates:
- load balancer
- virtual machine scaleset

and currently also a few prerequisites:
- virtual network
- subnet
- public ip address
- network security group

I think these can be moved to prerequisites, as they could be reused by all the other tasks before.
