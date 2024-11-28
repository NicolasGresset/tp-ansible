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


