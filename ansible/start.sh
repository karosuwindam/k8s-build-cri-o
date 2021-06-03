#!/bin/sh
ansible-playbook -i inventory/web.yml playbook.yml --ask-become-pass
kubectl apply -f docker-registry/namespace/
kubectl apply -f docker-registry/pod/