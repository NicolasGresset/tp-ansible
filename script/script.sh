#!/bin/bash

# © [2024] Nicolas Gresset-Bourgeois. Tous droits réservés.

# Ce programme et tous ses composants sont protégés par le droit d'auteur. Toute reproduction, distribution ou modification non autorisée est interdite sans le consentement écrit de l'auteur.

# ce script prend le fichier passé en argument comme entrée
# et génère un fichier ldif correspondant exploitable par ldap

# le format attendu du fichier d'entrée est un fichier csv avec les champs suivants :

# "Name;Firstname;Login;Password"

input=$1
uid_start=1000
gid_start=1000

>users.ldif
while IFS=';' read -r login first_name last_name password; do
    cat <<EOL >>users.ldif
dn: uid=$login,ou=People,dc=mondomaine,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
cn: $first_name $last_name
sn: $last_name
uid: $login
uidNumber: $uid_start
gidNumber: $gid_start
homeDirectory: /home/$login
loginShell: /bin/bash
userPassword: $(slappasswd -s $password)
EOL

    cat <<EOL >>groups.ldif
dn: cn=$login,ou=Group,dc=mondomaine,dc=local
objectClass: posixGroup
cn: $login
gidNumber: $gid_start
memberUid: $login
EOL

    uid_start=$((uid_start + 1))
    gid_start=$((gid_start + 1))
done <"$input"
