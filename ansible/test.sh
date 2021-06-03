#!/bin/sh

ansible-playbook -i inventory/web.yml playbook2.yml --ask-become-pass

# ansible-playbook -i inventory/web.yml playbook.yml --ask-become-pass