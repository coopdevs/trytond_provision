# Tryton Provision

Ansible project to provision and deploy a server of [Tryton](http://www.tryton.org/) 3.8.

## Requeriments

This project has been thinked to run in Debian 9.0 (Stretch

* Ansible 2.5.2 or last

You can find more information about Ansible [here](http://docs.ansible.com/)

> :warning: This repository assumes that your Tryton repository is in [Mercurial](https://www.mercurial-scm.org/). Please take care of that :warning:

## Playbooks

### Create System Administrators users - `playbooks/sys_admins.yml`

This playybook use the [`sys-admins` role](https://github.com/coopdevs/sys-admins-role) of Coopdevs to manage the system administrators users.

### Provision - `playbooks/provision.yml`
This playbook do:

* Create Tryton user and add SSH keys
* Create Tryton configuration files
* Create Tryton log configuration files
* Install the system packages
* Install PostgreSQL
* Create PostgreSQL users and databases
* [...]
* Install Python development tools
* Create virtualenv and install Python dependencies
* Install NodeJS
* Clone Tryton repository using **Mercurial**
* Create a `systemd` unit to run Tryton instances
* Enable the Tryton services

To use, run:
```
ansible-playbook playbooks/provision.yml -u USER --limit HOSTGROUP <--tags TAGS>
```

### Use Systemd services - `playbooks/use_systemd.yml`

This playbook do:

* Create Tryton configuration files
* Create Tryton log configuration files
* Create a `systemd` unit to run Tryton instances
* Enable the Tryton services

To use, run:
```
ansible-playbook playbooks/use_systemd.yml -u USER --limit HOSTGROUP
```

### Install and configure a FTP server - `playbooks/ftp.yml`

This playbook use the [`vsftpd` role](https://github.com/weareinteractive/vsftpd) to manage the FTP server.

## Configurable Variables

This examples are from `./inventory/host_vars/local.tryton.coop/config.yml`. You can create new `host_vars` folder with your domain as name and modify this vars.
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
```

* FTP management variables
```YAML
ftp_user:                        # FTP user. Use a specific user to connect the FTP
ftp_password:                    # FTP password
ftp_password_salt:               # FTP password SALT to excrypt it
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
