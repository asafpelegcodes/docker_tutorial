#!/bin/bash

if [[ -n $FIRSTNAME ]]
then
  sed -i "s#@FirstName#$FIRSTNAME#g" /usr/share/nginx/html/index.html
fi

if [[ -n $LASTNAME ]]
then
  sed -i "s#@LastName#$LASTNAME#g" /usr/share/nginx/html/index.html
fi

if [[ -n $EMAILHANDLE ]]
then
  sed -i "s#@EmailHandle#$EMAILHANDLE#g" /usr/share/nginx/html/index.html
fi

if [[ -n $EMAILHOST ]]
then
  sed -i "s#@EmailHost#$EMAILHOST#g" /usr/share/nginx/html/index.html
fi

exec nginx -g 'daemon off;'
