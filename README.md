# Tryton Provision

Ansible project to provision and deploy a [Tryton](http://www.tryton.org/) 3.8 server.

This is intended to be used with Som Connexió's own Tryton repository: https://gitlab.com/coopdevs/somconnexio-tryton-root-project.

<!-- vim-markdown-toc GitLab -->

* [Requirements](#requirements)
* [Development](#development)
   * [Fix mount directory](#fix-mount-directory)
* [Giving access to the server](#giving-access-to-the-server)
   * [App access](#app-access)
   * [Admin access](#admin-access)
* [Production](#production)
* [Ansible playbooks](#ansible-playbooks)
   * [Create System Administrators users - `playbooks/sys_admins.yml`](#create-system-administrators-users-playbookssys_adminsyml)
   * [Provision - `playbooks/provision.yml`](#provision-playbooksprovisionyml)
   * [Installing and configuring a FTP server - `playbooks/ftp.yml`](#installing-and-configuring-a-ftp-server-playbooksftpyml)
   * [Further development requirements](#further-development-requirements)
   * [Manual: Create the database](#manual-create-the-database)

<!-- vim-markdown-toc -->

## Requirements

This project has been thought to be run against a Debian 9.0 (Stretch) machine.

* Ansible > 2.7

> We are using the Ansible 2.8.5 version.

You can find more information about Ansible [here](http://docs.ansible.com/)

We use [Pyenv](https://gitlab.com/coopdevs/ansible-development-environment) to consistently run specific Python and Ansible versions across all machines.

Please check the installation instructions at [Pyenv's](https://gitlab.com/coopdevs/ansible-development-environment) repository and then run the next commands to generate the `virtualenv`:

```
$ pyenv install 3.7.4
$ pyenv virtualenv 3.7.4 trytond_provision
$ pyenv local trytond_provision
```

Before running the next command, make sure that you are in the virtualenv. You can run `python --version` and check if the Python version is `trytond_provision`.

```
$ pip install -r requirements.txt
```

After installing Ansible, we need to download and install the project dependencies:

```commandline
$ pyenv exec ansible-galaxy install -r requirements.yml
```
## Development

You can use `devenv` to create an LXC container that you can use to provision a Tryton server. See https://github.com/coopdevs/devenv.

Once `devenv` is installed, change dir to the directory where you cloned the repository and run:

```commandline
devenv
```

This will create an LXC container based on Debian Stretch. Now, read [#ansible-playbooks] to provision your newly created container.

### Fix mount directory

Fix problem with #14

Before continue with the documentation, please fix the mount directory in the LXC Configuration file (`/var/lib/lxc/somconnexio/config`). Run:

```commandline
sudo vim /var/lib/lxc/somconnexio/config
```

From vim, run the command `:%s/opt/home\/administrator/g` and save.

Note that if you need to develop web forms, you'll also need to add an extra mount entry like

```
lxc.mount.entry = <path_to_your_webforms_repo> /var/lib/lxc/somconnexio/rootfs/home/administrator/eticom/wwweticom none bind,create=dir 1.0
```

Now, restart the container and continue with the documentation.

## Giving access to the server

There are two access levels to the server: app or admin access. The former can deploy, modify or start/stop/restart the app while the latter has full access to server's configuration.

### App access

In order to access the server your SSH key should be listed in `tryton_user_keys`. You should open a pull request. You can use [#79](https://github.com/coopdevs/trytond_provision/pull/79) as example.

### Admin access

Admin access is controled with [playbooks/sys_admins.yml](https://github.com/coopdevs/trytond_provision/blob/master/playbooks/sys_admins.yml). For that playbook to take you into account your SSH key should be listed in `system_administrators`. Check out [Create System Administrators users - `playbooks/sys_admins.yml`](#Create-System-Administrators-users---`playbooks/sys_admins.yml`) for more details.

## Production

To have access to the production environment with your own user you need to be added to the `ssh-users` group. That's the only group allowed to access via SSH.

You can do that by running the following:

```
$ sudo usermod -a -G ssh-users <user-name>
```

## Ansible playbooks

### Create System Administrators users - `playbooks/sys_admins.yml`

This playbook uses Coopdevs' [`sys-admins` role](https://github.com/coopdevs/sys-admins-role) to manage the system administrators users.

By default a user is created in the target machine, with the public key of your current user assigned.

You can create new `host_vars` folder with your domain as name, or you can use the existing one (local.tryton.coop).
Modify these vars, which you can find in file `config.yml`:

```YAML
system_administrators_group:      # System administrators group
system_administrators:            # List of system administrators added to the group
  - name:                         # User name
    ssh_key:                      # User SSH public key file path
    state:                        # User state (present/absent)
```

The first time you run it against a brand new host you need to run it as root user. You'll also need passwordless SSH access to the root user.

```commandline
pyenv exec ansible-playbook playbooks/sys_admins.yml --limit dev -u root
```

Run the sysadmin playbook:
```commandline
pyenv exec ansible-playbook playbooks/sys_admins.yml --limit dev -u USER
```

For the following executions, the script will assume that your user is included in the system administrators list for the given host.
To run the playbook as a system administrator just use the following command:

```commandline
pyenv exec ansible-playbook playbooks/sys_admins.yml --limit dev
```

Ansible will try to connect to the host using the system user. If your user as a system administrator is different than your local system user please run this playbook with the correct user using the -u flag.

```commandline
$ pyenv exec ansible-playbook playbooks/sys_admins.yml --limit dev -u <username>
```

Once this is done, you can check if it works with:
```commandline
$ ssh admin@local.tryton.coop
```

Change the host and user for the ones of your choice if you don't use these default ones.

Now, before following the provision instructions, read the [Configuration variables]() section.

### Provision - `playbooks/provision.yml`
This playbook does:

* Create Tryton user and add SSH keys
* Create Tryton configuration files
* Create Tryton log configuration files
* Install the system packages
* Install PostgreSQL
* Create PostgreSQL users and databases
* Install Python development tools
* Create virtualenv and install Python dependencies
* Install NodeJS
* Create Tryton configuration files

To use, run:
```commandline
$ pyenv exec ansible-playbook playbooks/provision.yml -u USER -l HOSTGROUP --ask-vault-pass
```

### Installing and configuring a FTP server - `playbooks/ftp.yml`

This playbook uses the [`vsftpd` role](https://github.com/weareinteractive/vsftpd) to manage the FTP server.

### Further development requirements

You can install some development goodies like ipython, ipdb or tryton_shell by setting var `dev_mode` to `true` in host's vars.
(./inventory/hosts_vars/loca.tryton.coop/config.yml).

### Manual: Create the database

After provisioning and deploying the application, we need to create a development database.

We use a dump to recreate a DB for development purposes. You need to get a backup and fill the `eticom` database with it:

```commandline
psql -h 127.0.0.1 -U eticom -W eticom < <YOUR-DUMP>
```

With this done, you can manage the app with the following scripts.

```commandline
./up                        - Start the Tryton server
./up-web                    - Start the web forms
./update <module_name>      - Update Tryton modules
```
