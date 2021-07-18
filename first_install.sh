#!/bin/bash

#upgrade yum, make sure wget is installed
sudo yum upgrade -y && sudo yum update -y
sudo yum install -y yum-utils
sudo dnf install wget -y
sudo dnf groupinstall "Development Tools" -y
sudo yum install git -y
sudo dnf install bzip2-devel expat-devel gdbm-devel ntfs-3g p7zip \
    ncurses-devel openssl-devel readline-devel wget \
    sqlite-devel tk-devel xz-devel zlib-devel libffi-devel epel-release -y


#set up .bash_prompt
PROMPT=~/.bash_prompt
if [ -f "$PROMPT" ];then
	echo "sourcing bash prompt"
	source ~/.bash_prompt
else
	echo "getting bash prompt"
	curl "https://gist.githubusercontent.com/cassioscabral/6798728/raw/1620b6f31550d4d4705a4832ecd2a6364bf0f653/bash_prompt" >> ~/.bash_prompt
	source ~/.bash_prompt
fi
echo 'source ~/.bash_prompt' >> ~/.bashrc
echo 'bash prompt'

#download and install chrome ===========================================
CHROMEREPO=/etc/yum.repos.d/google-chrome.repo
if test "$CHROMEREPO" != true; then
	echo "[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub" | sudo tee "$CHROMEREPO"

sudo yum install google-chrome-stable -y
fi
echo 'Chrome installation successful'

wget "http://mirror.centos.org/centos/7/os/x86_64/Packages/chrome-gnome-shell-10.1-4.el7.x86_64.rpm"
sudo ln -s /usr/bin/python3 /usr/bin/python
sudo rpm -i --nodeps chrome-gnome-shell-10.1-4.el7.x86_64.rpm

#install vscode ========================================================
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
VSCODEREPO=/etc/yum.repos.d/vscode.repo
if test "$VSCODEREPO" != true; then
	 echo "[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee "$VSCODEREPO"

sudo dnf install code -y
fi
echo 'vscode installed'

# install openjdk11 ====================================================
JDK11="java-11-openjdk-devel.x86_64"
JAVA="/usr/lib/jvm/java-11-openjdk-11.0.9.11-3.el8_3.x86_64"
sudo dnf install $JDK11 -y
sudo alternatives --set java ${JAVA}/bin/java
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.9.11-3.el8_3.x86_64' >> ~/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
echo 'openjdk 11 installed'

#install Maven =========================================================
MVN='apache-maven-3.6.3-bin.tar.gz'
cd ~/Downloads
wget https://downloads.apache.org/maven/maven-3/3.6.3/binaries/$MVN
sudo tar -xf ~/Downloads/$MVN -C /opt
sudo ln -s /opt/apache-maven-3.6.3 /opt/maven
rm ~/Downloads/$MVN
M2_HOME="/opt/maven"
MAVEN_HOME="/opt/maven"
echo 'export M2_HOME=/opt/maven' >> ~/.bashrc
echo 'export MAVEN_HOME=/opt/maven' >> ~/.bashrc
echo 'export PATH=$PATH:$M2_HOME/bin' >> ~/.bashrc
echo 'maven installed'

#install NVM for node ===================================================
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
source ~/.bash_profile
nvm install 12
nvm use 12
echo 'export PATH=$PATH:/$HOME/.nvm' >> ~/.bashrc
echo 'nvm and node installed'

#install Docker(latest) and docker-compose ==============================
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
if [ $(getent group docker) ]; then
        echo 'docker group exists already'
else
        echo 'creating docker group'
		sudo groupadd docker
		sudo usermod -aG docker $USER
		newgrp docker
fi
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo 'docker finished'

#install GoLang ===========================================================
cd ~/Downloads
GO="go1.16.3.linux-amd64.tar.gz"
wget https://golang.org/dl/${GO}
sudo tar -xf ~/Downloads/${GO} -C /usr/local
rm ~/Downloads/${GO}
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'golang installed'

#install Python3.8 ========================================================
#VERSION=3.8.9
#cd ~/Downloads
#wget https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz
#if test ~/Downloads/Python-${VERSION}.tgz; then
#	echo 'Expanding python tarball for install'
#	sudo tar -xvzf ~/Downloads/Python-${VERSION}.tgz
#	rm ~/Downloads/Python-${VERSION}.tgz
#	cd Python-${VERSION}
#	./configure --enable-optimizations
#	make -j 8
#	sudo make altinstall
#	sudo rm -rf ~/Downloads/Python-${VERSION}
#fi
#echo 'python installed'


#install kubectl(latest) and helm(latest) ==================================
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'
sudo yum install -y kubectl
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
echo 'kube and helm installed'

#install AWS cli ===========================================================
cd ~/Downloads
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.1.21.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm ~/Downloads/awscliv2.zip
rm -rf ~/Downloads/aws
echo 'aws cli installed'

#install Postman ===========================================================
POSTMAN=Postman-linux-x64-8.1.0.tar.gz
cd ~/Downloads
if test ${POSTMAN} == true; then
	rm ~/Downloads/${POSTMAN}
fi
if [ ! -d /opt/Postman ]; then
	wget -c https://dl.pstmn.io/download/latest/linux64 -O ${POSTMAN}
	sudo tar -xf ${POSTMAN} -C /opt/
	sudo ln -s /opt/Postman/Postman /usr/local/bin/postman
fi
rm ~/Downloads/${POSTMAN}
echo 'postman installed'

#generate ssh key, make project directories for code ========================
if test ~/.ssh/id_rsa.pub; then
	rm -rf ~/.ssh
	ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null
else
	ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null
fi

if [ ! -d ~/Projects ]; then
	mkdir ~/Projects
fi
echo 'ssh key generated'

#install IntelliJ (latest)
INTELLIJ=ideaIU-2021.1.tar.gz
cd ~/Downloads
wget https://download.jetbrains.com/idea/$INTELLIJ
if [ -f $INTELLIJ ]; then
	sudo mkdir /opt/intellij
	sudo tar -xf $INTELLIJ -C /opt/intellij --strip-components=1
	rm ~/Downloads/$INTELLIJ
	sudo ln -s /opt/intellij/bin/idea.sh /usr/local/bin/intellij
	echo "[Desktop Entry]
Version=13.0
Type=Application
Terminal=false
Icon[en_US]=/opt/intellij/bin/idea.png
Name[en_US]=IntelliJ
Exec=/opt/intellij/bin/idea.sh
Name=IntelliJ
Icon=/opt/intellij/bin/idea.png" | sudo tee /usr/share/applications/intellij.desktop
	sudo chmod 644 /usr/share/applications/intellij.desktop
fi
echo 'intellij installed'

#install Angular CLI
npm i -g @angular/cli


#source .bashrc and be done ==================================================
source ~/.bashrc