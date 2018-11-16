# Tryton Provision

Ansible project to provision and deploy a server of [Tryton](http://www.tryton.org/) 3.8.

## Requeriments

This project has been thinked to run in Debian 9.0 (Stretch

* Ansible 2.5.2 or last

You can find more information about Ansible [here](http://docs.ansible.com/)

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
* Install VirtualenvWrapper
* Create virtualenv and install Python dependencies
* Install NodeJS
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

## Configurable Variables

This examples are from `./inventory/host_vars/local.tryton.coop/config.yml`. You can create new `host_vars` folder with your domain as name and modify this vars.
We recommend encrypting the variables with sensitive information with [Ansible Vualt](https://docs.ansible.com/ansible/2.4/vault.html) and use `--ask-vault-pass` in the command line.

* Sysadmins
```YAML
system_administrators_group: "sysadmins"
system_administrators:
  - name: tryton
    ssh_key: "~/.ssh/id_rsa.pub"
    state: present
  - name: "my-sysadmins-user"
    ssh_key: "~/.ssh/id_rsa.pub"
    state: present
```

* VirtualEnv vars:
```YAML
venv_path: "/home/tryton/.virtualenvs/tryton"
```

* Tryton users
```YAML
tryton_user: "tryton"
# Users with access to Tryton user via SSH. The name ins only for document who the key is.
tryton_user_keys:
  - name: daniel
    ssh_key: '~/.ssh/id_rsa.pub'
    state: present
```

* Tryton vars:
```YAML
venv_name: 'tryton'
venv_path: '/home/{{ tryton_user }}/.virtualenvs/{{ venv_name }}'
tryton_repositories:
  - url: 'ssh://hg@bitbucket.org/nantic/root-eticom'
    path: '/home/{{ tryton_user }}/eticom'
    revision: 'default'
  - url: 'ssh://hg@bitbucket.org/nantic/flask-eticom'
    path: '/home/{{ tryton_user }}/eticom/wwweticom'
    revision: 'default'
```

* Postgresql vars
```YAML
db_name: tryton
db_user: tryton
db_user_password: 1234
db_port: 5432
db_locales: 'ca_ES.UTF-8'
db_options:
  - option: lc_messages
    value: '{{ db_locales }}'
db_hba_entries:
  - { type: local, database: all, user: postgres, auth_method: peer }
  - { type: local, database: all, user: all, auth_method: peer }
  - { type: host, database: all, user: all, address: '127.0.0.1/32', auth_method: md5 }
  - { type: host, database: all, user: all, address: '::1/128', auth_method: md5 }
```

* Tryton Configuration files
```YAML
configuration_files:
  - file_name: "trytond.conf"
    listen_port: "8000"
    db_uri: "postgresql:///tryton"
    db_copy: "/opt/eticom/backups"
    pidfile: "/var/run/trytond/trytond.pid"
    logconf: "/etc/trytond/trytond.logconf"
    super_pwd: ""
    cron: "True"
    smtp_max_connections: 4
    dev: "True"
    verbose: "True"
  - file_name: "trytond1.conf"
    listen_port: "8001"
    db_uri: "postgresql:///tryton"
    db_copy: "/opt/eticom/backups"
    pidfile: "/var/run/trytond/trytond1.pid"
    logconf: "/etc/trytond/trytond1.logconf"
    super_pwd: ""
    cron: "False"
    smtp_max_connections: 4
    dev: "True"
    verbose: "True"
```

* Log Tryton Configuration files
```YAML
log_configuration_files:
  - file_name: "trytond.logconf"
    log_path: "/var/log/trytond/trytond.log"
    logger_level: "INFO"
    handler_level: "INFO"
  - file_name: "trytond1.logconf"
    log_path: "/var/log/trytond/trytond1.log"
    logger_level: "INFO"
    handler_level: "INFO"
```

* Tryton Environment Variables to OTRS integration
```YAML
otrs_salt: "1234"
otrs_rpc_url: "www.test.coop"
otrs_rpc_user: "rpc_user"
otrs_rpc_passw: "rpc_passw"
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
