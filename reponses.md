# Réponses

Ce fichier contient les réponses aux questions du TP3 d'admin sys de Nicolas Gresset-Bourgeois.

## LDAP

On utilise Ansible pour télécharger et déployer de manière automatique une instance OpenLdap sur une machine (en l'occurence ma machine locale). On utilise le moteur de templating jinja2 pour remplir avec des variables le contenu du fichier docker compose.

On utilise des volumes pour stocker de manière persistante la configuration du serveur ldap et les données associées à l'instance elle-même.

Il est pertinent d'attacher des conteneurs à plusieurs réseaux pour leur permettre de communiquer entre eux dans des groupes séparés en fonction des besoins, ce qui favorise l'isolation et donc la sécurité.

### Environnement virtuel

Par ailleurs, j'utilise un environnement virtuel pour isoler les dépendances python nécessaires au déroulement de ce TP du reste de mon installation Python. L'environnement virtuel peut être recrée en faisant : 

```bash
python -m venv venv
source venv/bin/activate
PIP_CONSTRAINT=cython_constraint.txt pip install -r requirements.txt
```

L'interpréteur python est donc modifié dans l'inventaire Ansible pour utiliser l'interpréteur de l'environnement virtuel.


## Import des utilisateurs

Je réutilise le script `script/script.sh` réalisé pour un TP précédent qui permet simplement de convertir le fichier csv d'entrée en fichier LDIF interprétable par LDAP.

## Traefik

On met en place la solution populaire Traefik qui permet de faire l'interconnexion entre des requêtes extérieures à une machine et les services qui correspondent à ces requêtes dans la machine. On réutilise les mêmes technologies pour déployer avec Ansible une instance docker de Traefik, en utilisant notamment : 
- un rôle dédié
- un fichier docker compose templatisé dédié

On peut ensuite visiter [localhost:8080](http://localhost:8080) pour accéder au dashboard de contrôle de Traefik.


## Application Web

### Compréhension générale
Traefik agit principalement sur la couche 4 du modèle OSI (transport) en ce qu'il reroute des paquets TCP. Sa fonction d'équilibreur de charge le fait également agir sur la couche 7 (couche applicative).

Détaillons quelques termes de la terminologie Traefik :

- Ingress : Dans le contexte de Traefik et Kubernetes, une ingress est une ressource qui définit comment le trafic externe doit être routé vers les services internes. Traefik utilise des objets Ingress pour configurer le routage.
- Middleware : Ce sont des composants intermédiaires qui modifient ou manipulent les requêtes et les réponses HTTP, par exemple pour l'authentification, le redémarrage de connexion, etc.
- Plugin : Des extensions que l'on peut ajouter à Traefik pour étendre ses fonctionnalités (ex : ajout de sécurité, de monitoring, etc.).

Puis, voici les expressions correspondantes :

- Pour capter mondomaine.com/api/* et mondomaine2.fr/api/*, l'expression serait : `Host(mondomaine.com) || Host(mondomaine2.fr) && PathPrefix(/api/)`.
- Pour capter tondomaine.com/api/*, l'expression serait : `Host(tondomaine.com) && PathPrefix(/api/)`.


Puis, utiliser une passerelle HTTP/HTTPS comme Traefik permet de centraliser la gestion du trafic entrant, d'appliquer des règles de routage et de sécuriser la communication via TLS/SSL. Cela simplifie la configuration de manière significative.


### Fonctionnement technique

Dans le fichier docker-compose, on paramètre le service `whoami` pour répondre au nom de domaine `whoami.localhost`. Traefik va ensuite pouvoir router les requêtes HTTP à destination de ce nom de domaine vers le service correspondant, ici `whoami`.

```bash
❯ curl -H Host:whoami.localhost http://127.0.0.1:8000
Hostname: 36f08144fbd9
IP: 127.0.0.1
IP: ::1
IP: 172.26.0.2
RemoteAddr: 172.26.0.3:38888
GET / HTTP/1.1
Host: whoami.docker.localhost
User-Agent: curl/8.11.0
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 172.26.0.1
X-Forwarded-Host: whoami.docker.localhost
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: a211a3072154
X-Real-Ip: 172.26.0.1
```

Il faut bien faire attention à utiliser un réseau docker commun aux différents services pour permettre à traefik de router correctement les services. C'est notamment le cas lorsque plusieurs fichiers docker compose sont utilisés. 

## Utilisation des groupes

On utilise des groupes pour exécuter plusieurs instances de whoami. On va spécifier une instance de groupe comme paramètre ansible directement dans l'invocation du play dans le playbook afin de différencier chacun des groupes.

