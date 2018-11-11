#!/bin/bash
if [[ $OS == "Windows_NT" ]] ; then
  echo "Windows support will be provided by a Powershell script."
  exit
fi
which -s brew
if [[ $? != 0 ]] ; then
  echo "Installing Homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Homebrew already installed, updating..."
  brew update
fi
which -s git
if [[ $? != 0 ]] ; then
  echo "Installing git..."
  brew install git
else
  echo "Git is already installed."
fi
# Apparently I could have installed Ansible with brew install ansible
# I may update this later to do it that way
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
  ansible-galaxy install -r requirements.yml
  sudo pwd # This gets around a permissions error with Homebrew
  ansible-playbook main.yml
fi
