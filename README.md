# Tryton Provision

Ansible project to provision and deploy a server of [Tryton](http://www.tryton.org/) 3.8.

This is intended to be used with this tryton repository: https://bitbucket.org/danypr92/root-eticom/src/default/

## Requeriments

This project has been thinked to run in Debian 9.0 (Stretch) mahcine.

* Ansible 2.7

You can find more information about Ansible [here](http://docs.ansible.com/)

Install ansible requirements:

```commandline
ansible-galaxy install -r requirements.yml
```

## Setup development machine

You can use `devenv` to create an LXC container that you can use to provision a tryton machine. See https://github.com/coopdevs/devenv

If you want to use, once `devenv` is installed, you just change dir to the root directory of this projects, where a `.devenv` configuration files can be found, and run:

```commandline
devenv
```

That should create an LXC container based in Debian Stretch.

### Fix mount directory:
Fix problem with #14

Before continue with the documentation, please fix the mount directory in the LXC Configuration file (`/var/lxc/somconnexio/config`). Run:

```commandline
sudo vim /var/lxc/somconnexio/config
```

In vim run the next command `:%s/opt/home\/administrator/g` and save.

Restart the container and continue with the documentation.

## Playbooks

### Create System Administrators users - `playbooks/sys_admins.yml`

This playbook use the [`sys-admins` role](https://github.com/coopdevs/sys-admins-role) of Coopdevs to manage the system administrators users.

By default an user is created in the target machine, with your current user pubkey assigned.

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
ansible-playbook playbooks/sys_admins.yml --limit dev -u root
```

Run the sysadmin playbook:
```commandline
ansible-playbook playbooks/sys_admins.yml --limit dev -u USER
```

For the following executions, the script will assume that your user is included in the system administrators list for the given host.
To run the playbook as a system administrator just use the following command:

```commandline
ansible-playbook playbooks/sys_admins.yml --limit dev
```

Ansible will try to connect to the host using the system user. If your user as a system administrator is different than your local system user please run this playbook with the correct user using the -u flag.

```commandline
ansible-playbook playbooks/sys_admins.yml --limit dev -u <username>
```

Once this is done, you can check if it works with:
```commandline
ssh admin@local.tryton.coop
```

Change the host and user for the ones of your choice if you don't use these default ones.

Now, before following provision instructions, read the [Configuration variables]() section.

### Provision - `playbooks/provision.yml`
This playbook do:

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
```
ansible-playbook playbooks/provision.yml -u USER --limit HOSTGROUP
```

### Manual: Clone and bootstrap the tryton repository

Assuming you use `administrator` user, use your mercurial to clone the repository in `~/eticom`:

```commandline
ssh administrator@local.somconnexio.coop -A
```
> The `-A` argument is to keep with you your ssh-agent in the ssh connection.

Once inside container, run:

```commandline
hg clone ssh://hg@bitbucket.org/danypr92/root-eticom eticom
```

When the repository was clonned, active the virtualenv and execute the `boostrap` script

```commandline
source ~/.virtualenvs/eticom/bin/activate
cd ~/eticom
./bootstrap.sh
```

During bootstrap, you probably can get some errors due to having incorrect version for some repositories.
Go to the repository folder indicated on the error (for instance, `config` or `tasks`) and run:

```commandline
hg up 3.8
```

If you are using some virtual machine or containers technology, such as docker, be sure that you clone this
into a directory shared between the container machine and the host machine, so you can easily modify the code.

Also you can get some error and the process can be freeze, but you can click `enter` and the process continue. When the process ends, you need to check that the `opencell_somconnexio` and the `contract_changes_wizards_somconnexio` are cloned, if does not, please clone the repos manually:

```commandline
git clone -b master -q git@gitlab.com:coopdevs/opencell_somconnexio_tryton.git /home/administrator/eticom/modules/opencell_somconnexio
git clone -b master -q git@gitlab.com:coopdevs/contract_changes_wizards_somconnexio.git /home/administrator/eticom/modules/contract_changes_wizards_somconnexio
```

### Manual: Clone and bootstrap the galatea repository

Assuming you use `administrator` user, use your mercurial to clone the repository in `~/eticom/wwweticom`:

```commandline
cd ~/eticom
hg clone ssh://hg@bitbucket.org/nantic/flask-eticom wwweticom
cd ~/eticom/wwweticom
./bootstrap.sh
```

When the repository was clonned, active the virtualenv and execute the `boostrap` script

```commandline
source ~/.virtualenvs/eticom/bin/activate
cd ~/eticom/wwweticom
./bootstrap.sh
```

### Further development requirements

You can install some development gooodies like ipython, ipdb or tryton_shell by setting var `dev_mode` to `true` in host's vars.
(./inventory/hosts_vars/loca.tryton.coop/config.yml).

### Post deploy - `playbooks/post_deploy.yml`

You maybe don't want to run this playbook if you want to run tryton in your machine for development purposes.
But if you want to setup a production or staging machine, you should use systemd to keep tryton up and ready.

This playbook does:

* Fix the Python packages version
* Create Tryton log configuration files
* [Configure RabbitMQ to work with Celery](https://docs.celeryproject.org/en/latest/getting-started/brokers/rabbitmq.html?highlight=rabbit#setting-up-rabbitmq):
  - Create user
  - Create vhost
  - Enable [RabbitMQ Management Plugin](https://www.rabbitmq.com/management.html)
* Create a `systemd` unit to run Tryton instances
* Enable the Tryton services
* Copy the scripts to run in development mode
* Copy the data needed to run the web forms

To use, run:
```
ansible-playbook playbooks/post_deploy.yml -u USER --limit HOSTGROUP
```

### Manual: Create the database

After provision and deploy our application and after run the `post_deploy` tasks, we need create a usable database.
We use a dump to recreate a db un local environment. You need get some db backup and fill the `eticom` datebase with it:

```commandline
psql -h 127.0.0.1 -U eticom -W eticom < <YOUR-DUMP>
```

After run this migration, you can use the scripts at home to execute the forms, Tryton server or update the list of modules:

```commandline
./up                        - Start the Tryton server to debug
./up-web                    - Start the web forms to debug
./update <module_name>      - Update the Tryton module
```

### Install and configure a FTP server - `playbooks/ftp.yml`

This playbook use the [`vsftpd` role](https://github.com/weareinteractive/vsftpd) to manage the FTP server.

## Configuration variables

This examples are from `./inventory/host_vars/local.somconnexio.coop/config.yml` and `secrets.yml` and from the group vars `./inventory/group_vars/all.yml`. You can create new `host_vars` folder with your domain as name and modify this vars.
We recommend encrypting the variables with sensitive information with [Ansible Vualt](https://docs.ansible.com/ansible/2.4/vault.html) and use `--ask-vault-pass` in the command line.

* Sysadmins
```YAML
system_administrators_group:      # System administrators group
system_administrators:            # List of system administrators added to the group
  - name:                         # User name
    ssh_key:                      # User SSH public key file path
    state:                        # User state (present/absent)
```

* Tryton users
```YAML
tryton_user:                      # User to run Tryton application
tryton_group:                     # Group to run Tryton systemd services
tryton_user_keys:                 # List of users with access to Tryton user via SSH
  - name:                         # User name
    ssh_key:                      # User SSH public key file path
    state:                        # User state (present/absent)
```

* VirtualEnv vars:
```YAML
venv_name:                        # Virtualenv name
# Default virtualenv path is created with tryton_user and venv_name var
# You can override set another directory in the venv_path. Feel free!
venv_path: "/home/{{ tryton_user }}/.virtualenvs/{{ venv_name }}"
```

* Tryton vars:
```YAML
tryton_path:                      # Tryton repository path
# You can clone more that one Tryton repository using Mercurial
tryton_repositories:              # List of repositories to clone the Tryton project and addons
  - url:                          # Repository URL
    path:                         # Repository destination. You can use the tryton_path var
    revision:                     # Repository revision to clone
```

* Postgresql vars
```YAML
# Postgresql vars
db_name:                          # Database name
db_user:                          # Database user name
db_user_password:                 # Database user password
db_port:                          # Database server port
db_locales:                       # Database server locale
db_options:                       # postgresql_global_config_options variable of geerlingguy.postgresql role
db_hba_entries:                   # postgresql_hba_entries variable of geerlingguy.postgresql role
```

* Tryton Configuration files
```YAML
configuration_files:              # List of Trytond configuration files
  - file_name:
    listen_port:
    db_uri:
    db_copy:
    pidfile:
    logconf:
    super_pwd:
    cron:
    smtp_max_connections:
    dev:
    verbose:
```

* Log Tryton Configuration files
```YAML
log_configuration_files:         # List of Trytond log configuration files
  - file_name:
    log_path:
    logger_level:
    handler_level:
```

* Galatea Config
```YAML
galatea_path:
galatea_debug:
galatea_debug_log:
galatea_error_log:
galatea_admins:
galatea_title:
galatea_session_cookie_name:
galatea_cache_dir:
galatea_media_folder:
galatea_media_cache_folder:
galatea_redirect_after_login:
galatea_tryton_database:
galatea_tryton_user:
galatea_tryton_config:
```

* uWSGI Config
```YAML
# %k is a magic var translated to the number of cpu cores
uwsgi_min_workers: '%(%k * 1/2)'
uwsgi_init_workers: 1
uwsgi_max_workers: '%k'
uwsgi_listen_queue: 100
```

* Tryton Environment Variables to OTRS integration
```YAML
otrs_salt:
otrs_rpc_url:
otrs_rpc_user:
otrs_rpc_passw:
otrs_url:
otrs_user:
otrs_passw:
```

* Tryton Environment Variables to OpenCell integration
```YAML
opencell_url:                   # Opencell URL
opencell_user:                  # Opencell User
opencell_password:              # Opencell Password
```

* Tryton Celery variables
```YAML
celery_tryton_database:         # Database name to use in Celery process
celery_user:                    # User to talk with RabbitMQ
celery_password:                # Password to the user to talk with RabbitMQ
celery_host:                    # Host of RabbitMQ server
celery_port:                    # RabbitMQ port
celery_vhost:                   # VHost RabbitMQ
```

* Flower variables
```YAML
flower_user:                    # User password to access to the Flower UI
flower_password:                # Password to access to the Flower UI
```

* FTP management variables
```YAML
ftp_user:                       # FTP user. Use a specific user to connect the FTP
ftp_password:                   # FTP password
ftp_password_salt:              # FTP password SALT to excrypt it
```

## Ansible Community Roles

To download the community roles, you can run:
```
ansible-galaxy install -r requirements.yml
```

### List of Galaxy roles:

* [SysAdmins Role](https://galaxy.ansible.com/coopdevs/sys-admins-role)
* [PostgreSQL Role](https://galaxy.ansible.com/geerlingguy.postgresql)
* [NodeJS Role](https://galaxy.ansible.com/geerlingguy.nodejs)

## Devenv

We use [`devenv`](https://github.com/coopdevs/devenv) tool to manage the development environment. Check the `.devenv` configuration file.

Install and run `devenv` to start a development environment.

## Contributing

1. Fork it (<https://github.com/coopdevs/tryton_provision>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request
