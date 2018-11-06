# setuper
Ansible Playbooks and other scripts for setting up Mac

Open the terminal and type in the following commands:

1) $ ```git clone git@github.com:kodywilson/setuper.git```
2) $ ```cd setuper```
3) $ ```./install.sh```

Enter password when prompted.

The [shell script](https://github.com/tensult/mac-setup-playbooks/blob/master/install.sh) will install [Homebrew](https://brew.sh/), [Git](https://git-scm.com/), [Pip](https://pip.pypa.io/en/stable/), and [Ansible](https://www.ansible.com/).

Next, it installs the required Ansible roles.

Finally, it'll run the Ansible playbook called main.yml which installs a list of applications and packages.

You can reconfigure the code to install other apps based on your needs by editing the following files.
main.yml - Set variable file, tasks to run, roles to include, etc.

List of applications and packages to install. Edit this to customize for your setup.
default.config.yml

The following roles are used:
elliotweiser.osx-command-line-tools and geerlingguy.homebrew from these Github repos:
https://github.com/elliotweiser/ansible-osx-command-line-tools
https://github.com/geerlingguy/ansible-role-homebrew

Normally I use oh-my-zsh, but for fun, I followed this guide: https://medium.freecodecamp.org/jazz-up-your-bash-terminal-a-step-by-step-guide-with-pictures-80267554cb22 and configured my terminal.

I'd say that oh-my-zsh is the much easier way to go, what you get out of the box with minimal fuss is really amazing! In the past I have also often used iTerm2 instead of the default Mac terminal.
