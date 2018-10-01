############################## Create Demo VM To Be Ansible Host

az group create -l eastus -n afaustin
az vm create -g afaustin -n afaustin --image OpenLogic:CentOS-LVM:7-LVM:7.5.20180823 --authentication-type password --storage-sku Standard_LRS --accelerated-networking true --size Standard_D2_v2 --admin-username afaustin

############################## NSG rule for alternate SSH port

az network nsg rule create -g afaustin --nsg-name afaustinNSG --name allow-ssh2112 --description "Allow SSH Port 2112" --access Allow --protocol Tcp --direction Inbound --priority 110 --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range "2112"

############################## Provision Demo VM

ssh afaustin@YOUR.IP.ADDRESS.OF.AZURE.VM
sudo su - root

<password>

yum -y install epel-release deltarpm
yum -y install policycoreutils-python libsemanage-devel gcc gcc-c++ kernel-devel python-devel libxslt-devel libffi-devel openssl-devel python2-pip iptables-services git
sed -i "s/dport 22/dport 2112/g" /etc/sysconfig/iptables
semanage port -a -t ssh_port_t -p tcp 2112
sed -i "s/#Port 22/Port 2112/g" /etc/ssh/sshd_config
systemctl restart sshd
systemctl stop firewalld 
systemctl disable firewalld
systemctl mask firewalld
systemctl enable iptables
systemctl start iptables
wget https://wolverine.itscloudy.af/config/tuneazure.sh
chmod 755 tuneazure.sh                      
./tuneazure.sh

############################## Full Update

yum -y update

############################## Reboot host if you wish

#reboot 

############################## Create SP for Ansible

az account list
az ad sp create-for-rbac --name="Ansiblefest2018-Azure" --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID_FROM_PREVIOUS_COMMAND"

##################################################################################################################### Install Ansible Bits

ssh afaustin@YOUR.IP.ADDRESS.OF.AZURE.VM -p 2112
sudo su - root

<password>

pip install --upgrade pip
pip install ansible==2.7.0rc2
pip install ansible[azure]
exit

############################## Provision Ansible account

git clone https://github.com/stuartatmicrosoft/Ansiblefest2018
ssh-keygen -t rsa -q -P "" -f $HOME/.ssh/id_rsa
echo "export AZURE_CLIENT_ID=" >> $HOME/.bashrc
echo "export AZURE_SECRET=" >> $HOME/.bashrc
echo "export AZURE_SUBSCRIPTION_ID=" >> $HOME/.bashrc
echo "export AZURE_TENANT=" >> $HOME/.bashrc

############################## Populate Credentials File

vi $HOME/.bashrc

############################## Source .bashrc to set new variables

source $HOME/.bashrc

############################## Generate random number and set variables

cd $HOME/Ansiblefest2018

RANDNUM=`shuf -i 20000-50000 -n 1`
sed -i "s/mmmysqlansiblefestxxxx/mmmysqlansiblefest$RANDNUM/g" vars.yml
sed -i "s/mmvmpublicipxx/mmvmpublicip$RANDNUM/g" vars.yml
sed -i "s/vmsspublicipxxy/vmsspublicip$RANDNUM/g" vars.yml
sed -i "s/appgwpublicipxx/appgwpublicip$RANDNUM/g" vars.yml

############################## Run Playbooks 0-3

ansible-playbook 00-prerequisites.yml --extra-vars "@vars.yml"
ansible-playbook 01-mm-vm-deploy.yml --extra-vars "@vars.yml"
ansible-playbook 02-create-mysql.yml --extra-vars "@vars.yml"
ansible-playbook 03-mm-setup.yml --extra-vars "@vars.yml"

############################## Test Mattermost App

echo It will take a minute for the server to start
echo View in web browser - visit http://ip.address.of.mm.server:8065

############################## Run Playbooks 4-6

ansible-playbook 04-create-vm-image.yml --extra-vars "@vars.yml"
ansible-playbook 05-vmss-create.yml --extra-vars "@vars.yml"
ansible-playbook 06-appgateway-attach.yml --extra-vars "@vars.yml"

############################## Test Mattermost App

echo It will take roughly 4 min 30 sec for the server to start
echo View in web browser - visit http://ip.address.of.ag

############################## RESET
az group delete -n ansiblefestrg -y ; az group delete -n afaustin -y 
sed -i "/afaustin/d" ~/.ssh/known_hosts
