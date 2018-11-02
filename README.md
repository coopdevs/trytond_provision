# Tryton Provision

Ansible project to provision and deploy a server of [Tryton](http://www.tryton.org/) 3.8.

## Requeriments

This project has been thinked to run in Debian 9.0 (Stretch

* Ansible 2.3 or last

You can find more information about Ansible [here](http://docs.ansible.com/)

## Playbooks

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

### Configurable Variables

This examples are from `./inventory/host_vars/local.tryton.coop/config.yml`. You can create new `host_vars` folder with your domain as name and modify this vars.
We recommend encrypting the variables with sensitive information with [Ansible Vualt](https://docs.ansible.com/ansible/2.4/vault.html) and use `--ask-vault-pass` in the command line.

* Sysadmins
```YAML
sys_admins:
  - name: tryton
    ssh_key: "~/.ssh/id_rsa.pub"
    state: present
  - name: "{{ development_user }}"
    ssh_key: "~/.ssh/id_rsa.pub"
    state: present
```

* Tryton vars
```YAML
venv_path: "/home/tryton/.virtualenvs/tryton"
tryton_user: "tryton"
tryton_path: "/opt/eticom"
```

* Postgresql vars
```YAML
database_name: "tryton"
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

### Ansible Community Roles
## Devenv

We use [`devenv`](https://github.com/coopdevs/devenv) tool to manage the development environment. Check the `.devenv` configuration file.

Install and run `devenv` to start a development environment.

## Contributing

1. Fork it (<https://github.com/coopdevs/tryton_provision>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request
