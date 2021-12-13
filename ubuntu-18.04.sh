#!/bin/bash

# 安装docker # ref: https://blog.csdn.net/boonya/article/details/83011074  
function docker_install()
{
	echo "检查Docker......"
	docker -v
    if [ $? -eq  0 ]; then
        echo "检查到Docker已安装!"
    else
    	echo "安装docker环境..."
        curl -sSL https://get.daocloud.io/docker | sh
        echo "安装docker环境...安装完成!"
    fi
    # 创建公用网络==bridge模式
    #docker network create share_network
}
 
# 执行函数
docker_install

# 开发者环境
apt update
apt install -y build-essential git cmake 

echo "" >> /etc/ssh/sshd_config # 给sshd_config配置文件的末尾增加一个换行，以防发生格式错误
echo "ClientAliveInterval 30" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 6" >> /etc/ssh/sshd_config
systemctl restart sshd

# zsh & oh-my-zsh
apt install -y zsh
sed -in '/ubuntu/{s/bash/zsh/}' /etc/passwd
su - ubuntu -c 'curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh'

# use zsh theme https://github.com/LI-Mingyu/lmy.zsh-theme/blob/master/lmy.zsh-theme
curl -Lo /home/ubuntu/.oh-my-zsh/themes/lmy.zsh-theme https://raw.githubusercontent.com/LI-Mingyu/lmy.zsh-theme/master/lmy.zsh-theme
chown ubuntu /home/ubuntu/.oh-my-zsh/themes/lmy.zsh-theme
sed -i 's/^ZSH_THEME.*/ZSH_THEME=\"lmy\"/g' /home/ubuntu/.zshrc
# enable autocompletion for docker cmd
sed -in '/^plugins.*/{s/)/ docker)/}' /home/ubuntu/.zshrc

# kubectl & minkube
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
su -c 'install minikube-linux-amd64 /usr/local/bin/minikube'
apt install -y conntrack # Kubernetes 1.22.3 requires conntrack to be installed in root's path
su -c 'minikube start --driver=none'
sed -in '/^plugins.*/{s/)/ kubectl)/}' /home/ubuntu/.zshrc # enable autocompletion for kubectl cmd

sleep 30 #等待k8s就绪

# 让ubuntu（ubuntu云主机默认用户）有通过kubectl命令行操作本地k8s单节点集群的权限
cp -r /root/.kube /home/ubuntu/
chown -hR ubuntu /home/ubuntu/.kube
cp -r /root/.minikube /home/ubuntu/
chown -hR ubuntu /home/ubuntu/.minikube
sed -i 's/root/home\/ubuntu/g' /home/ubuntu/.kube/config

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
su -c 'helm repo add bitnami https://charts.bitnami.com/bitnami'
su -c 'helm repo update'
sed -in '/^plugins.*/{s/)/ helm)/}' /home/ubuntu/.zshrc # enable autocompletion for helm cmd

# for cndev/k8s-training
su - ubuntu -c 'git clone https://github.com/LI-Mingyu/cndev-tutorial.git'
