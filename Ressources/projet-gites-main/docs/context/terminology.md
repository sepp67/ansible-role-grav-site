terminology.md — Partie 1

Généré conformément au Template 10 – Génération des documents de contexte du projet à partir des Consolidated Decision Records (CDR) uniquement. Ce document constitue le début du glossaire officiel du projet. Aucune définition n'introduit de nouvelle décision.

# Terminology

## Plateforme de location saisonnière

### Définition

Application permettant de mettre directement en relation des propriétaires de gîtes et des vacanciers.

La plateforme ne gère ni les paiements ni les réservations.

### Contexte d'utilisation

Terme désignant le produit développé par le projet.

---

## Gîte

### Définition

Hébergement proposé à la location saisonnière.

Chaque gîte est représenté par une page Grav.

### Contexte d'utilisation

Élément principal du modèle métier.

---

## Propriétaire

### Définition

Personne responsable d'un ou plusieurs gîtes.

Chaque propriétaire dispose d'un compte individuel et gère uniquement ses propres hébergements.

### Contexte d'utilisation

Utilisateur authentifié de la plateforme.

---

## Vacancier

### Définition

Personne consultant les gîtes et prenant directement contact avec un propriétaire.

Le vacancier ne possède pas de compte utilisateur dans le MVP.

### Contexte d'utilisation

Utilisateur public de la plateforme.

---

## MVP

### Définition

Minimum Viable Product.

Première version fonctionnelle du produit, volontairement limitée aux fonctionnalités essentielles.

### Contexte d'utilisation

Périmètre de la première livraison.

---

## Grav CMS

### Définition

Système de gestion de contenu retenu comme socle applicatif officiel du projet.

### Contexte d'utilisation

Base technique de toute l'application.

---

## Architecture monolithique

### Définition

Architecture dans laquelle toutes les fonctionnalités sont regroupées dans une application unique basée sur Grav.

### Contexte d'utilisation

Architecture officielle du MVP.

---

## Flat File

### Définition

Mode de stockage utilisé par Grav reposant sur des fichiers Markdown et des métadonnées YAML.

### Contexte d'utilisation

Stockage officiel des contenus du projet.

---

## Markdown

### Définition

Format texte utilisé pour stocker le contenu des pages Grav.

### Contexte d'utilisation

Contenu principal des hébergements.

---

## YAML

### Définition

Format utilisé pour stocker les métadonnées structurées associées aux pages Grav.

### Contexte d'utilisation

Configuration et données métier.

---

## Plugin Calendrier

### Définition

Plugin Grav développé spécifiquement pour gérer les disponibilités des gîtes.

### Contexte d'utilisation

Fonctionnalité centrale du projet.

---

## Plugin Form

### Définition

Plugin officiel de Grav utilisé pour le formulaire de contact.

### Contexte d'utilisation

Transmission des demandes des vacanciers vers les propriétaires.

---

## Plugin Login

### Définition

Plugin officiel de Grav utilisé pour authentifier les propriétaires.

### Contexte d'utilisation

Gestion des accès à l'administration.

---

## Twig

### Définition

Moteur de templates utilisé par Grav pour générer les pages HTML.

### Contexte d'utilisation

Technologie officielle du frontend.

---

## OpenStreetMap

### Définition

Solution cartographique libre utilisée pour afficher la localisation des gîtes.

### Contexte d'utilisation

Cartographie intégrée aux fiches des hébergements.

---

## Ansible

### Définition

Outil d'automatisation utilisé pour déployer et configurer l'infrastructure du projet.

### Contexte d'utilisation

Déploiement officiel de la plateforme.

---

## Feature

### Définition

Plus petite unité fonctionnelle planifiable du projet.

Chaque Feature possède ses propres critères de validation.

### Contexte d'utilisation

Planification du développement.

---

## Epic

### Définition

Ensemble cohérent de Features représentant une fonctionnalité majeure.

### Contexte d'utilisation

Organisation du développement.

---

## Phase

### Définition

Grande étape du développement regroupant plusieurs Epics.

Chaque Phase se termine par un jalon de validation.

### Contexte d'utilisation

Pilotage du projet.

---

## Release

### Définition

Version livrable de la plateforme.

Les Releases sont utilisées pour organiser l'évolution progressive du produit.

### Contexte d'utilisation

Planification des livraisons.

La Partie 2 complétera le glossaire avec les termes liés à la gouvernance, à la qualité et au Workflow Kit, notamment :

ADR
CDR
DCE
DCL
Architecture Decision Record
Consolidated Decision Record
Decision Candidate Extraction
Decision Clustering
Backend
Frontend
SEO
Dette technique
Jalon
Critères de validation
Risque
Consensus
Niveau de confiance

afin de finaliser le document terminology.md conformément au Template 10.

terminology.md — Partie 2

    Généré conformément au Template 10 – Génération des documents de contexte du projet à partir des Consolidated Decision Records (CDR) uniquement. Cette partie complète le glossaire officiel du projet avec les concepts liés à la gouvernance, à la qualité et au Workflow Kit. Aucune définition n'introduit de nouvelle décision.

---

## Architecture Decision Record (ADR)

### Définition

Document décrivant une décision architecturale officielle du projet, son contexte, sa justification, ses conséquences et les alternatives étudiées.

### Contexte d'utilisation

Les ADR constituent la documentation d'architecture de référence du projet.

---

## Consolidated Decision Record (CDR)

### Définition

Décision consolidée produite à partir du regroupement et de l'arbitrage des Decision Candidate Extractions (DCE).

Le CDR constitue la source officielle de vérité décisionnelle avant la rédaction des ADR.

### Contexte d'utilisation

Registre officiel des décisions du projet.

---

## Decision Candidate Extraction (DCE)

### Définition

Extraction normalisée d'une décision candidate issue d'une réponse d'IA.

Chaque DCE représente une décision indépendante sans interprétation ni arbitrage.

### Contexte d'utilisation

Première étape de consolidation des décisions.

---

## Decision Clustering (DCL)

### Définition

Regroupement des DCE traitant d'un même sujet afin de préparer leur consolidation en CDR.

Le clustering ne crée pas de nouvelles décisions.

### Contexte d'utilisation

Étape intermédiaire entre les DCE et les CDR.

---

## Workflow Kit

### Définition

Méthodologie de travail permettant de faire collaborer plusieurs IA au sein d'un processus reproductible allant de l'analyse initiale jusqu'aux décisions architecturales consolidées.

### Contexte d'utilisation

Processus officiel de conception du projet.

---

## Backend

### Définition

Ensemble des traitements exécutés côté serveur.

Dans ce projet, le backend est directement intégré à Grav CMS.

### Contexte d'utilisation

Architecture technique.

---

## Frontend

### Définition

Interface utilisateur exécutée dans le navigateur.

Elle est générée côté serveur par Grav à l'aide de Twig, CSS et JavaScript.

### Contexte d'utilisation

Interface de consultation et d'administration.

---

## SEO

### Définition

Search Engine Optimization (référencement naturel).

Ensemble des techniques permettant d'améliorer la visibilité du site dans les moteurs de recherche.

### Contexte d'utilisation

Objectif stratégique du projet.

---

## Dette technique

### Définition

Compromis technique accepté temporairement afin d'accélérer le développement, tout en restant documenté, maîtrisé et planifié.

### Contexte d'utilisation

Pilotage du développement.

---

## Jalon

### Définition

Point de contrôle marquant la fin d'une phase importante du projet.

Le franchissement d'un jalon valide les livrables de la phase précédente.

### Contexte d'utilisation

Suivi de l'avancement.

---

## Critères de validation

### Définition

Ensemble des conditions devant être satisfaites avant qu'une Feature ou un Epic soit considéré comme terminé.

### Contexte d'utilisation

Assurance qualité.

---

## Test d'intégration

### Définition

Test vérifiant le bon fonctionnement conjoint de plusieurs composants du système.

Les tests d'intégration conditionnent la validation des Epics.

### Contexte d'utilisation

Validation technique.

---

## Risque

### Définition

Événement susceptible d'affecter le coût, le délai, la qualité ou le fonctionnement du projet.

Les risques sont identifiés, documentés, suivis et réévalués tout au long du développement.

### Contexte d'utilisation

Gestion de projet.

---

## Consensus

### Définition

Niveau d'accord observé entre les différentes IA sur une décision donnée.

Le consensus constitue un indicateur utilisé lors de la consolidation des décisions en CDR.

### Contexte d'utilisation

Consolidation des décisions.

---

## Niveau de confiance

### Définition

Indicateur évaluant la solidité d'une décision consolidée en fonction de la convergence des sources et de la qualité des justifications.

### Contexte d'utilisation

Évaluation des CDR.

---

## Source de vérité (Source of Truth)

### Définition

Document faisant autorité pour un type d'information donné.

Dans le Workflow Kit :

- les CDR constituent la source officielle des décisions consolidées ;
- les ADR documentent ces décisions ;
- les documents de contexte (project-context.md, constraints.md et terminology.md) fournissent le contexte partagé du projet.

### Contexte d'utilisation

Gouvernance documentaire.

---

## Traçabilité

### Définition

Capacité à relier une décision finale à l'ensemble des éléments ayant conduit à son adoption.

La chaîne de traçabilité officielle est :

Réponse IA → Réponse normalisée → DCE → DCL → CDR → ADR

### Contexte d'utilisation

Audit et gouvernance du projet.

---

## Knowledge Base

### Définition

Ensemble des documents de référence utilisés pour fournir un contexte stable et partagé aux futures IA intervenant sur le projet.

Elle est composée de :

- project-context.md ;
- constraints.md ;
- terminology.md.

### Contexte d'utilisation

Recontextualisation des nouvelles sessions de travail.

---

## Utilisation de ce document

Le présent glossaire constitue le vocabulaire officiel du projet.

Il doit être utilisé par :

- les contributeurs humains ;
- les IA ;
- les relecteurs techniques ;
- les auteurs des ADR ;
- les futurs développements.

Lorsqu'un terme défini dans ce document est utilisé, il doit conserver le sens décrit ici afin d'assurer une compréhension commune et une cohérence documentaire sur l'ensemble du projet.

Cette deuxième partie clôt le document terminology.md. Avec project-context.md et constraints.md, il complète la Knowledge Base officielle du projet prévue par le Template 10. Cette base fournit désormais un contexte stable, cohérent et directement exploitable pour les futures sessions de travail et pour les différentes IA intervenant sur le projet.
