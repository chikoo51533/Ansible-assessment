#!/bin/sh
openssl genrsa 2048 > /etc/ssl/certs/my-aws-private.key
openssl req -new -x509 -nodes -sha1 -days 3650 -extensions v3_ca -key /etc/ssl/certs/my-aws-private.key -subj "/C=UA/ST=FirstName/L=LastName/O=JustCompany/OU=IT Department/CN=${HOSTNAME}" > /etc/ssl/certs/my-aws-public.crt
openssl pkcs12 -inkey /etc/ssl/certs/my-aws-private.key -in /etc/ssl/certs/my-aws-public.crt -certfile /etc/ssl/certs/my-aws-public.crt
exit 0  