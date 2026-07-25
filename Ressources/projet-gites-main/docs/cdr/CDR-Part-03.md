Consolidated Decision Records (CDR) — Partie 03
Authentification, sécurité, administration et infrastructure

Conforme au Template 09B – Consolider les Consolidated Decision Records (CDR). Cette partie transforme les DCL-014 à DCL-020 en décisions officielles du projet.

Consolidated Decision Records
Métadonnées
Champ	Valeur
Projet	Plateforme de location saisonnière de gîtes
Auteur	ChatGPT
Date	2026-07-16
Version	2.0
CDR-014
Sujet

Authentification des propriétaires

Sources
DCE-CLAUDE-011
DCE-DEEPSEEK-021
DCE-DEEPSEEK-022
Décision consolidée

L'authentification des propriétaires est assurée par le plugin Login de Grav. Chaque propriétaire dispose d'un compte individuel lui permettant d'accéder exclusivement aux fonctions de gestion qui lui sont destinées.

Justification

Claude définit la solution technique tandis que DeepSeek structure son implémentation dans le plan de développement. Les deux approches sont parfaitement complémentaires.

Contraintes retenues
Plugin Login officiel.
Un compte par propriétaire.
Authentification obligatoire pour les fonctions d'administration.
Dépendances
CDR-007
CDR-012
Niveau de consensus

Total

Niveau de confiance

Très élevé

Impact
Sécurité
Backend
UX
Statut

Validé

Futur ADR

ADR associé

ADR-014

Titre proposé

Authentification des propriétaires

Statut ADR

À rédiger

CDR-015
Sujet

Gestion des autorisations

Sources
DCE-CLAUDE-012
DCE-CLAUDE-034
DCE-DEEPSEEK-023
DCE-DEEPSEEK-024
Décision consolidée

Le système applique un contrôle d'accès basé sur les rôles. Chaque propriétaire est limité à la gestion de son propre hébergement et de ses disponibilités. Les autorisations sont définies selon le principe du moindre privilège.

Justification

Toutes les IA convergent vers une isolation stricte des données et des droits d'administration.

Contraintes retenues
Isolation des propriétaires.
Permissions granulaires.
Aucun accès croisé.
Dépendances
CDR-014
Niveau de consensus

Total

Niveau de confiance

Très élevé

Impact
Sécurité
Administration
Backend
Statut

Validé

Futur ADR

ADR associé

ADR-015

Titre proposé

Gestion des autorisations des propriétaires

Statut ADR

À rédiger

CDR-016
Sujet

Administration de la plateforme

Sources
DCE-DEEPSEEK-031
DCE-DEEPSEEK-032
DCE-DEEPSEEK-033
Décision consolidée

Une interface d'administration centralisée permet la gestion des propriétaires, des hébergements et du processus de validation des nouveaux gîtes.

Justification

DeepSeek est la seule IA à détailler cette partie. Les décisions sont cohérentes avec les contraintes d'administration définies par Claude.

Contraintes retenues
Administration centralisée.
Gestion des propriétaires.
Validation avant publication.
Dépendances
CDR-014
CDR-015
Niveau de consensus

Fort

Niveau de confiance

Élevé

Impact
Administration
Produit
Backend
Statut

Validé

Futur ADR

ADR associé

ADR-016

Titre proposé

Architecture de l'administration

Statut ADR

À rédiger

CDR-017
Sujet

Déploiement automatisé

Sources
DCE-CLAUDE-016
DCE-CLAUDE-017
DCE-CLAUDE-032
DCE-DEEPSEEK-015
Décision consolidée

Le déploiement officiel du projet est entièrement automatisé avec Ansible. Les playbooks existants sont réutilisés et étendus afin de conserver une chaîne de déploiement unique, reproductible et maintenable.

Justification

Claude fournit la stratégie d'infrastructure et DeepSeek confirme son intégration dans le plan de développement. Cette solution minimise la dette opérationnelle et garantit la reproductibilité des déploiements.

Contraintes retenues
Déploiement automatisé.
Réutilisation des playbooks existants.
Infrastructure déclarative.
Dépendances
CDR-007
Niveau de consensus

Total

Niveau de confiance

Très élevé

Impact
Infrastructure
Déploiement
DevOps
Statut

Validé

Futur ADR

ADR associé

ADR-017

Titre proposé

Déploiement automatisé avec Ansible

Statut ADR

À rédiger

CDR-018
Sujet

Infrastructure d'hébergement

Sources
DCE-CLAUDE-031
Décision consolidée

L'application est déployée sur une infrastructure Linux utilisant Nginx et PHP-FPM, conformément aux recommandations officielles de Grav.

Justification

Cette décision est explicitement formulée par Claude et reste cohérente avec l'ensemble de l'architecture retenue.

Contraintes retenues
Linux.
Nginx.
PHP-FPM.
Dépendances
CDR-007
CDR-017
Niveau de consensus

Fort

Niveau de confiance

Élevé

Impact
Infrastructure
Exploitation
Statut

Validé

Futur ADR

ADR associé

ADR-018

Titre proposé

Infrastructure d'hébergement Grav

Statut ADR

À rédiger

CDR-019
Sujet

Sauvegarde et continuité d'exploitation

Sources
DCE-CLAUDE-027
DCE-CLAUDE-039
Décision consolidée

Le contenu du site fait l'objet d'une stratégie de sauvegarde automatisée et d'un versionnement permettant la restauration rapide du système et le suivi des modifications.

Justification

Les deux décisions sont complémentaires et répondent au même objectif de continuité d'exploitation.

Contraintes retenues
Sauvegardes automatiques.
Versionnement du contenu.
Procédures de restauration documentées.
Dépendances
CDR-017
Niveau de consensus

Fort

Niveau de confiance

Élevé

Impact
Exploitation
Maintenance
Documentation
Statut

Validé

Futur ADR

ADR associé

ADR-019

Titre proposé

Sauvegarde et continuité d'exploitation

Statut ADR

À rédiger

CDR-020
Sujet

Exploitation du MVP

Sources
DCE-CLAUDE-036
DCE-CLAUDE-040
Décision consolidée

Le MVP privilégie une exploitation simple. Les propriétaires gèrent eux-mêmes leurs disponibilités et l'infrastructure ne met pas en œuvre de mécanisme de haute disponibilité. La simplicité opérationnelle est prioritaire sur la résilience avancée.

Justification

Les décisions de Claude convergent vers un même principe : adapter le niveau de complexité technique aux besoins réels du MVP afin de réduire les coûts de développement et d'exploitation.

Contraintes retenues
Administration autonome des disponibilités.
Pas de haute disponibilité dans le MVP.
Simplicité opérationnelle.
Dépendances
CDR-012
CDR-017
CDR-019
Niveau de consensus

Fort

Niveau de confiance

Élevé

Impact
Infrastructure
Exploitation
Maintenance
Produit
Statut

Validé

Futur ADR

ADR associé

ADR-020

Titre proposé

Principes d'exploitation du MVP

Statut ADR

À rédiger

Mapping automatique des ADR
Cluster	Décision consolidée	Documentation
DCL-014	CDR-014	ADR-014
DCL-015	CDR-015	ADR-015
DCL-016	CDR-016	ADR-016
DCL-017	CDR-017	ADR-017
DCL-018	CDR-018	ADR-018
DCL-019	CDR-019	ADR-019
DCL-020	CDR-020	ADR-020
Vérification finale
Cluster	CDR produit	ADR associé
DCL-014	CDR-014	ADR-014
DCL-015	CDR-015	ADR-015
DCL-016	CDR-016	ADR-016
DCL-017	CDR-017	ADR-017
DCL-018	CDR-018	ADR-018
DCL-019	CDR-019	ADR-019
DCL-020	CDR-020	ADR-020
Résultat
Clusters traités : 20 / 26
CDR produits : 20
ADR préparés : 20
Traçabilité : complète
Statut : Partie 3 validée

Cette troisième partie constitue désormais le registre officiel des décisions relatives à l'authentification, à la sécurité, à l'administration, au déploiement et à l'exploitation. Elle servira directement de base à la rédaction des ADR-014 à ADR-020, conformément au Workflow Kit.
