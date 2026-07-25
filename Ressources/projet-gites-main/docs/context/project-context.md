project-context.md — Partie 1

Généré conformément au Template 10 – Génération des documents de contexte du projet à partir des Consolidated Decision Records (CDR) uniquement. Aucune décision nouvelle n'est introduite.

# Project Context

## Vision du projet

Le projet consiste à développer une plateforme de location saisonnière de gîtes permettant de mettre directement en relation les propriétaires et les vacanciers.

La plateforme agit exclusivement comme un intermédiaire de mise en relation.

Elle ne prend aucune commission sur les réservations et ne participe pas aux transactions financières.

Le modèle économique repose sur une cotisation annuelle versée par les propriétaires.

L'objectif principal est de proposer une plateforme simple, légère, facilement maintenable et évolutive.

---

## Objectif du MVP

Le MVP (Minimum Viable Product) a pour objectif de démontrer rapidement la valeur du produit avec un périmètre volontairement limité.

Le MVP comprend :

- deux premiers gîtes ;
- une fiche descriptive par gîte ;
- une galerie de photographies ;
- une carte de localisation ;
- un calendrier des disponibilités ;
- un formulaire de contact ;
- une authentification des propriétaires ;
- une interface de gestion des disponibilités ;
- un site disponible en français et en allemand.

Toutes les autres fonctionnalités sont reportées après validation du MVP.

---

## Architecture générale

Le projet repose sur les principes suivants :

- Grav CMS constitue le socle applicatif officiel.
- L'application adopte une architecture monolithique.
- Les fonctionnalités natives de Grav sont privilégiées.
- Les développements spécifiques sont limités aux besoins métier.
- Les données sont stockées au format Flat File (Markdown + YAML).
- Chaque gîte est représenté par une page Grav.
- Le calendrier est implémenté sous la forme d'un plugin Grav dédié.
- Les demandes de contact utilisent le plugin Form.
- L'authentification repose sur le plugin Login.
- Le déploiement est entièrement automatisé avec Ansible.

Cette architecture privilégie la simplicité, la maintenabilité et l'évolutivité.

---

## Fonctionnalités principales

### Présentation des gîtes

La plateforme permet de consulter les fiches détaillées des hébergements.

Chaque fiche comprend notamment :

- description ;
- galerie photographique ;
- équipements ;
- informations pratiques ;
- carte de localisation.

---

### Calendrier des disponibilités

Chaque propriétaire gère directement les disponibilités de son hébergement.

Le calendrier constitue la fonctionnalité centrale du produit.

---

### Contact direct

Les vacanciers utilisent un formulaire de contact afin d'envoyer une demande directement au propriétaire.

La plateforme ne gère ni réservation ni paiement.

---

### Gestion des propriétaires

Chaque propriétaire possède :

- un compte individuel ;
- des droits limités à ses propres hébergements ;
- une interface de gestion simplifiée.

---

### Multilinguisme

Le MVP est disponible en :

- français ;
- allemand.

Le changement de langue est intégré directement dans l'interface.

---

### Cartographie

Chaque fiche de gîte intègre une carte basée sur OpenStreetMap.

La Partie 2 contiendra :

Hors périmètre
Stratégie de développement
Documents de référence (ADR principaux)

afin de compléter le project-context.md conformément au Template 10


project-context.md — Partie 2

Généré conformément au Template 10 – Génération des documents de contexte du projet à partir des Consolidated Decision Records (CDR) uniquement. Aucune décision nouvelle n'est introduite.

---

## Hors périmètre

Les éléments suivants sont explicitement exclus du périmètre du MVP :

### Réservation en ligne

La plateforme ne gère pas les réservations.

Les échanges entre vacanciers et propriétaires se poursuivent en dehors de la plateforme.

---

### Paiement en ligne

Aucun paiement n'est traité par la plateforme.

Les transactions financières restent entièrement sous la responsabilité des propriétaires et des vacanciers.

---

### Gestion des comptes vacanciers

Le MVP ne prévoit aucun compte utilisateur destiné aux vacanciers.

La consultation du site est publique.

---

### Moteur de recherche multicritère

La recherche avancée est reportée après validation du MVP.

Le faible nombre initial de gîtes ne justifie pas cette fonctionnalité.

---

### Fonctionnalités communautaires

Les fonctionnalités suivantes sont hors périmètre :

- avis des utilisateurs ;
- statistiques de fréquentation ;
- fonctionnalités avancées de recherche ;
- autres enrichissements fonctionnels post-MVP.

---

### Haute disponibilité

Le MVP ne met pas en œuvre :

- cluster applicatif ;
- réplication ;
- bascule automatique ;
- infrastructure haute disponibilité.

L'objectif est de conserver une architecture simple et facilement maintenable.

---

## Stratégie de développement

Le développement du projet repose sur une approche incrémentale.

Chaque incrément doit produire un résultat :

- cohérent ;
- testable ;
- validable ;
- directement exploitable.

Les principes retenus sont les suivants :

- développement en plusieurs phases successives ;
- validation des fondations techniques avant les fonctionnalités métier ;
- validation de chaque Feature avant clôture ;
- validation de chaque Epic après les tests d'intégration ;
- utilisation de jalons de validation entre les phases ;
- dette technique limitée, documentée et maîtrisée ;
- gestion continue des risques techniques.

Le MVP constitue la première version livrable.

Les fonctionnalités non essentielles sont développées uniquement après validation du MVP.

---

## Documents de référence

Les décisions officielles du projet sont documentées dans les Architecture Decision Records (ADR).

Les principaux ADR de référence sont :

### Vision produit

- ADR-001 — Positionnement stratégique de la plateforme
- ADR-002 — Modèle économique sans commission
- ADR-003 — Gestion des demandes de réservation
- ADR-004 — Définition du périmètre du MVP
- ADR-005 — Stratégie d'évolution progressive du produit
- ADR-006 — Référencement naturel comme exigence architecturale

---

### Architecture

- ADR-007 — Choix de Grav CMS
- ADR-008 — Architecture monolithique
- ADR-009 — Backend intégré à Grav
- ADR-010 — Stockage Flat File
- ADR-011 — Modèle de contenu des hébergements
- ADR-012 — Plugin de gestion des disponibilités
- ADR-013 — Gestion des demandes de contact

---

### Sécurité et exploitation

- ADR-014 — Authentification des propriétaires
- ADR-015 — Gestion des autorisations
- ADR-016 — Architecture de l'administration
- ADR-017 — Déploiement automatisé avec Ansible
- ADR-018 — Infrastructure d'hébergement
- ADR-019 — Sauvegarde et continuité d'exploitation
- ADR-020 — Principes d'exploitation du MVP

---

### Gouvernance

- ADR-021 — Internationalisation
- ADR-022 — Cartographie OpenStreetMap
- ADR-023 — Politique de validation qualité
- ADR-024 — Développement incrémental
- ADR-025 — Gestion de la dette technique
- ADR-026 — Gestion des risques

---

## Utilisation de ce document

Ce document constitue le contexte général officiel du projet.

Il est destiné à être utilisé par toutes les futures IA intervenant sur le projet afin de comprendre :

- les objectifs du produit ;
- le périmètre fonctionnel ;
- les grandes orientations techniques ;
- les limites du MVP ;
- la stratégie de développement.

Les décisions détaillées restent exclusivement documentées dans les ADR correspondants.

Cette deuxième partie clôt le document project-context.md, qui devient le premier des trois documents constituant la Knowledge Base officielle du projet, conformément au Template 10.
