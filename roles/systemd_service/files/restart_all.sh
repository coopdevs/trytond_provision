#!/bin/bash

sudo systemctl restart trytond@eticom1
sudo systemctl restart trytond@eticom2
sudo systemctl restart trytond@eticom3
sudo systemctl restart trytond@eticom4

sudo systemctl restart trytond-cron
sudo systemctl restart eticom-celery
sudo systemctl restart opencell-celery
