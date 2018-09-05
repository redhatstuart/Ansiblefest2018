# Ansiblefest2018
Content for Ansible Fest 2018

## vars.yml

This file contains all the variables shared by demo tasks:

|Variable      |Description                                  |
|--------------|---------------------------------------------|
|resource_group|This is the resource group name used by demos|

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





