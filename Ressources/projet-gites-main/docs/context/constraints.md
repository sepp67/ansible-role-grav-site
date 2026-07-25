constraints.md — Partie 1

Généré conformément au Template 10 – Génération des documents de contexte du projet à partir des Consolidated Decision Records (CDR) uniquement. Ce document synthétise exclusivement les contraintes permanentes du projet. Aucune nouvelle décision n'est introduite.

# Constraints

## Contraintes métier

### Positionnement du produit

- La plateforme est exclusivement dédiée à la location saisonnière de gîtes.
- La plateforme agit comme un intermédiaire de mise en relation.
- La plateforme ne prélève aucune commission sur les réservations.
- Le modèle économique repose sur une cotisation annuelle versée par les propriétaires.

---

### Relation propriétaire / vacancier

- Les échanges s'effectuent directement entre propriétaires et vacanciers.
- Les paiements sont réalisés en dehors de la plateforme.
- Les réservations ne sont pas gérées par la plateforme.

---

## Contraintes fonctionnelles

### MVP

Le MVP est volontairement limité aux fonctionnalités essentielles.

Le MVP comprend uniquement :

- présentation des gîtes ;
- galerie photographique ;
- calendrier des disponibilités ;
- formulaire de contact ;
- authentification des propriétaires ;
- interface de gestion des disponibilités ;
- multilinguisme français / allemand ;
- cartographie.

---

### Gestion des disponibilités

- Le calendrier constitue la fonctionnalité principale du produit.
- Chaque propriétaire gère uniquement les disponibilités de ses propres hébergements.

---

### Formulaire de contact

- Les demandes sont transmises directement au propriétaire.
- Aucun système interne de réservation n'est conservé.
- Aucun paiement n'est intégré.

---

### Gestion des comptes

- Un compte est créé pour chaque propriétaire.
- Aucun compte vacancier n'est prévu dans le MVP.

---

### Internationalisation

Le MVP doit être disponible en :

- français ;
- allemand.

Le néerlandais est hors périmètre du MVP.

---

## Contraintes techniques

### CMS

Le projet repose exclusivement sur Grav CMS.

---

### Architecture logicielle

- Architecture monolithique.
- Aucun backend indépendant.
- Aucune API publique spécifique.

---

### Stockage

Le stockage repose sur le modèle Flat File de Grav :

- fichiers Markdown ;
- métadonnées YAML.

Aucune base de données relationnelle n'est utilisée dans le MVP.

---

### Frontend

Le frontend repose sur :

- Twig ;
- CSS ;
- JavaScript léger.

Le rendu côté serveur est privilégié.

---

### Plugins

Les plugins officiels de Grav sont privilégiés.

Le projet utilise notamment :

- Login ;
- Form ;
- plugin Calendrier spécifique.

Les développements spécifiques doivent rester limités aux besoins métier.

---

## Contraintes d'architecture

### Simplicité

L'architecture doit rester :

- simple ;
- cohérente ;
- facilement maintenable.

Toute complexité injustifiée doit être évitée.

---

### Évolutivité

Le modèle de contenu doit permettre :

- l'ajout de nouveaux gîtes ;
- l'ajout de nouveaux propriétaires ;
- l'ajout de nouvelles fonctionnalités.

Cette évolutivité ne doit pas remettre en cause les fondations du projet.

---

### Découplage fonctionnel

Les responsabilités sont clairement séparées :

- présentation ;
- calendrier ;
- contact ;
- administration.

Chaque composant doit conserver un périmètre fonctionnel clairement identifié.

La Partie 2 couvrira les sections restantes du template :

Contraintes de sécurité
Contraintes d'infrastructure
Contraintes de développement
Hors périmètre

afin de finaliser le document constraints.md

constraints.md — Partie 2

Généré conformément au Template 10 – Génération des documents de contexte du projet à partir des Consolidated Decision Records (CDR) uniquement. Ce document synthétise exclusivement les contraintes permanentes du projet. Aucune nouvelle décision n'est introduite.

---

## Contraintes de sécurité

### Authentification

- L'authentification des propriétaires est obligatoire pour accéder aux fonctions d'administration.
- Le plugin Login de Grav constitue le mécanisme officiel d'authentification.

---

### Autorisations

- Chaque propriétaire est limité à la gestion de ses propres hébergements.
- Les autorisations suivent le principe du moindre privilège.
- Aucun propriétaire ne peut modifier les données d'un autre propriétaire.

---

### Formulaire de contact

- Les demandes sont envoyées via le plugin Form.
- La délivrabilité des e-mails doit être garantie.
- Une protection contre le spam est obligatoire.
- La configuration SPF/DKIM doit être mise en œuvre.

---

## Contraintes d'infrastructure

### Déploiement

- Le déploiement officiel est entièrement automatisé avec Ansible.
- Les playbooks existants doivent être réutilisés et étendus.
- Les déploiements doivent être reproductibles.

---

### Hébergement

L'infrastructure repose sur :

- Linux ;
- Nginx ;
- PHP-FPM.

---

### Sauvegardes

Le projet doit prévoir :

- des sauvegardes automatiques ;
- le versionnement du contenu ;
- des procédures de restauration documentées.

---

### Exploitation

Le MVP privilégie une exploitation simple.

Aucune infrastructure de haute disponibilité n'est prévue dans cette première version.

---

## Contraintes de développement

### Méthodologie

Le développement suit une approche incrémentale.

Le projet est structuré en :

- Phases ;
- Epics ;
- Features.

---

### Validation

Chaque :

- Feature doit satisfaire ses critères d'acceptation ;
- Epic doit être validé après les tests d'intégration.

Le passage à une phase suivante nécessite la validation de la phase précédente.

---

### Dette technique

Une dette technique limitée est autorisée uniquement lorsqu'elle :

- est documentée ;
- est maîtrisée ;
- accélère la réalisation du MVP.

La dette technique ne doit jamais compromettre la stabilité de l'architecture.

---

### Gestion des risques

Les risques doivent être :

- identifiés ;
- documentés ;
- suivis ;
- réévalués pendant toute la durée du projet.

Toute décision présentant un risque significatif doit faire l'objet d'une analyse préalable.

---

## Hors périmètre

Les éléments suivants sont explicitement exclus du MVP :

### Fonctionnalités métier

- réservation en ligne ;
- paiement en ligne ;
- comptes vacanciers ;
- moteur de recherche multicritère ;
- système d'avis ;
- statistiques de fréquentation ;
- enrichissements fonctionnels post-MVP.

---

### Architecture

- microservices ;
- backend indépendant ;
- API publique spécifique ;
- architecture distribuée.

---

### Infrastructure

- haute disponibilité ;
- cluster applicatif ;
- réplication ;
- bascule automatique.

---

### Internationalisation

Le néerlandais est hors périmètre du MVP.

---

## Utilisation de ce document

Ce document rassemble les contraintes permanentes du projet.

Il constitue une référence commune pour :

- les futures sessions de développement ;
- la rédaction des ADR ;
- les revues d'architecture ;
- les revues de code ;
- la planification des évolutions.

Aucune contrainte présente dans ce document ne peut être modifiée sans mise à jour préalable des Consolidated Decision Records (CDR).

Cette deuxième partie clôt le document constraints.md, qui devient le deuxième document de la Knowledge Base officielle du projet. Il centralise l'ensemble des contraintes permanentes issues des 26 CDR et servira de référence à toutes les futures IA intervenant sur le projet.
