#!/bin/bash
# Detect OS and set up server. Uses Ansible for configuration management.
# On Ubuntu, it also tries to start a Jellyfin container.
# Pass --upgrade to attempt to upgrade brew casks and packages on Mac.
#        This can take a while if you have many packages/casks.
up2date=$1
if [[ "$OSTYPE" == "linux-gnu" ]]; then
 echo "Linux detected, now checking specific distro..."
  distro="$(awk -F= '/^NAME/{print $2}' /etc/os-release)"
  if [[ "$distro" == *"Ubuntu"* ]]; then
    echo "Found Ubuntu, proceeding with setup..."
    echo "Using sudo, please respond to prompts."
    echo "apt-get update..."
    sudo apt-get update
    for i in {1..3}; do echo; done
    echo "install prerequisites for ansible..."
    sudo apt-get install -y software-properties-common vim git
    for i in {1..3}; do echo; done
    echo "add ansible repository..."
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    for i in {1..3}; do echo; done
    echo "install ansible and python..."
    sudo apt-get install -y ansible python-apt
    for i in {1..3}; do echo; done
    echo "run the docker install playbook..."
    sudo ansible-playbook docker_ubuntu.yml
    for i in {1..3}; do echo; done
    echo "Docker should be installed and swarm mode enabled."
    for i in {1..3}; do echo; done
    # The stuff below will be moved to an Ansible playbook
    if grep "vagrant" /etc/passwd >/dev/null 2>&1; then
      # Vagrant specific configuration
      echo "Adding vagrant to docker group..."
      sudo usermod -aG docker "vagrant"
      docker_base='/home/vagrant/code/docker/'
      media_base='/home/vagrant/code/docker/media/'
    else
      # Configure directories
      docker_base='/docker/'
      media_base='/tank/'
    fi
    echo "Now creating directories for docker image to access..."
    sudo mkdir -p "${docker_base}jellyfin/config"  # Jellyfin Config
    sudo mkdir -p "${docker_base}kodi"   # kodi persistent directory
    sudo mkdir -p "${media_base}Movies"            # Media Directory
    echo "Set ownership and permissions for docker user..."
    sudo chown -R "crane:docker" "${docker_base}"
    sudo chown -R "crane:docker" "${media_base}Movies"
    sudo chmod -R 774 "${docker_base}"
    sudo chmod -R 774 "${media_base}Movies"
    for i in {1..3}; do echo; done
    if [ ! "$(docker ps -q -f name=jellyfin)" ]; then
      if [ "$(docker ps -aq -f status=exited -f name=jellyfin)" ]; then
        docker rm jellyfin # cleanup
      fi
      echo "Trying to start up a Jellyfin container..."
      sudo docker run -d --name=jellyfin --net=host -v ${docker_base}jellyfin/config:/config -v ${media_base}:/media --user "$(id -u crane):$(id -g crane)" jellyfin/jellyfin:latest
    else
      echo "Jellyfin is already running..."
    fi
    for i in {1..3}; do echo; done
    echo "Now install xdocker11 and prepare for kodi on docker..."
    sudo sed -i 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config
    curl -fsSL https://raw.githubusercontent.com/mviereck/x11docker/master/x11docker | sudo bash -s -- --update
    for i in {1..3}; do echo; done
    echo "<-------<<  End of installer script  >>------->"
  else
    echo "I know you are running Linux, but I can not tell what distro..."
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # Mac OSX
  echo "Mac OSX Detected, proceeding with setup."
  which -s brew
  if [[ $? != 0 ]] ; then
    echo "Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    echo "Homebrew already installed, updating..."
    brew update
    if [[ $up2date = "--upgrade" ]] ; then
      echo "Brew will upgrade installed casks and packages. This could take a while!"
      echo "First packages..."
      brew upgrade
      echo "Then casks..."
      brew cask upgrade
      echo "Now cleanup and run brew doctor."
      brew cleanup
      brew doctor
    fi
  fi
  which -s git
  if [[ $? != 0 ]] ; then
    echo "Installing git..."
    brew install git
  else
    echo "Git is already installed."
  fi
  # You could install Ansible with Brew too, just an FYI...
  which -s pip
  if [[ $? != 0 ]] ; then
    echo "Installing pip..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    sudo -H python get-pip.py
  else
    echo "Pip is already installed."
  fi
  which -s ansible
  if [[ $? != 0 ]] ; then
    echo "Installing ansible..."
    sudo -H pip install ansible
  else
    echo "Ansible is already installed. Running playbook..."
    ansible-galaxy install -r mac_requirements.yml
    sudo pwd # This gets around a permissions error with Homebrew
    ansible-playbook mac.yml
  fi
elif [[ "$OSTYPE" == "cygwin" ]]; then
  # POSIX compatibility layer and Linux environment emulation for Windows
  echo "Windows detected..."
elif [[ "$OSTYPE" == "msys" ]]; then
  # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
  echo "Windows detected..."
elif [[ "$OSTYPE" == "freebsd"* ]]; then
  # ...
  echo "FreeBSD detected..."
else
  echo "OS not detected, not sure what to do here so exiting..."
fi
echo "All done here, so long and thanks for all the fish!"
exit