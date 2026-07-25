Consolidated Decision Records (CDR) — Partie 02
Architecture logicielle

Conforme au Template 09B – Consolider les Consolidated Decision Records (CDR). Cette partie transforme les DCL-007 à DCL-013 en décisions officielles du projet.
Consolidated Decision Records
Métadonnées
Champ	Valeur
Projet	Plateforme de location saisonnière de gîtes
Auteur	ChatGPT
Date	2026-07-16
Version	2.0
CDR-007
Sujet

Choix du socle applicatif
Sources

    DCE-CLAUDE-001

    DCE-DEEPSEEK-004

    DCE-DEEPSEEK-009

    DCE-DEEPSEEK-012

Décision consolidée

Le projet est développé sur Grav CMS, qui constitue le socle applicatif officiel. Les fonctionnalités natives de Grav sont privilégiées afin de limiter le développement spécifique et de simplifier la maintenance.
Justification

Claude fournit la décision architecturale. DeepSeek confirme cette décision en organisant tout le plan de développement autour de Grav.
Contraintes retenues

    Grav est imposé comme CMS.

    Priorité aux fonctionnalités natives.

    Développements spécifiques limités aux besoins métier.

Dépendances

    CDR-001

    CDR-004

Niveau de consensus

Total
Niveau de confiance

Très élevé
Impact

    Architecture

    Backend

    Maintenance

Statut

Validé
Futur ADR

ADR associé

ADR-007

Titre proposé

Choix de Grav CMS comme socle applicatif

Statut ADR

À rédiger
CDR-008
Sujet

Architecture logicielle
Sources

    DCE-CLAUDE-002

    DCE-CLAUDE-025

    DCE-CLAUDE-033

    DCE-DEEPSEEK-044

Décision consolidée

L'application adopte une architecture monolithique basée sur Grav. Les microservices sont explicitement exclus du périmètre du MVP.
Justification

Toutes les décisions convergent vers une architecture simple, cohérente avec le périmètre fonctionnel du projet.
Contraintes retenues

    Monolithe.

    Pas de microservices.

    Simplicité architecturale.

Dépendances

    CDR-007

Niveau de consensus

Total
Niveau de confiance

Très élevé
Impact

    Architecture

    Développement

Statut

Validé
Futur ADR

ADR-008

Titre proposé

Architecture monolithique du système

Statut ADR

À rédiger
CDR-009
Sujet

Architecture backend
Sources

    DCE-CLAUDE-003

    DCE-CLAUDE-038

Décision consolidée

Aucun backend indépendant ni API publique dédiée ne sera développé. Toute la logique métier est intégrée au CMS Grav.
Justification

Cette approche réduit la complexité, améliore la maintenabilité et reste adaptée au périmètre du MVP.
Contraintes retenues

    Pas d'API REST spécifique.

    Backend intégré à Grav.

Dépendances

    CDR-007

    CDR-008

Niveau de consensus

Fort
Niveau de confiance

Très élevé
Impact

    Backend

    Architecture

Statut

Validé
Futur ADR

ADR-009

Titre proposé

Architecture backend intégrée à Grav

Statut ADR

À rédiger
CDR-010
Sujet

Stockage des données
Sources

    DCE-CLAUDE-004

    DCE-CLAUDE-006

Décision consolidée

Le stockage du contenu repose sur le modèle Flat File de Grav, utilisant des fichiers Markdown et des métadonnées YAML. Aucune base de données relationnelle n'est introduite dans le MVP.
Justification

Cette solution est adaptée au faible volume de données, simplifie le déploiement et facilite la maintenance.
Contraintes retenues

    Markdown.

    YAML.

    Absence de SGBD relationnel.

Dépendances

    CDR-007

Niveau de consensus

Total
Niveau de confiance

Très élevé
Impact

    Architecture

    Stockage

    Exploitation

Statut

Validé
Futur ADR

ADR-010

Titre proposé

Modèle de stockage Flat File

Statut ADR

À rédiger
CDR-011
Sujet

Modèle de contenu
Sources

    DCE-GRK-012

    DCE-CLAUDE-005

    DCE-CLAUDE-028

    DCE-DEEPSEEK-010

Décision consolidée

Chaque gîte est représenté par une page Grav structurée. Le modèle de contenu est conçu dès le MVP pour permettre l'ajout de nouveaux hébergements sans refonte de l'architecture.
Justification

Les trois IA convergent sur un modèle simple, extensible et parfaitement compatible avec Grav.
Contraintes retenues

    Une page = un gîte.

    Métadonnées structurées.

    Modèle extensible.

Dépendances

    CDR-007

    CDR-010

Niveau de consensus

Total
Niveau de confiance

Très élevé
Impact

    Architecture

    CMS

    Produit

Statut

Validé
Futur ADR

ADR-011

Titre proposé

Modèle de contenu des hébergements

Statut ADR

À rédiger
CDR-012
Sujet

Gestion des disponibilités
Sources

    DCE-GRK-010

    DCE-GRK-011

    DCE-CLAUDE-007

    DCE-CLAUDE-008

    DCE-CLAUDE-024

    DCE-DEEPSEEK-011

Décision consolidée

Les disponibilités sont gérées par un plugin Grav dédié, offrant une interface simple destinée aux propriétaires. Cette fonctionnalité constitue le cœur fonctionnel de la plateforme.
Justification

Toutes les IA convergent vers une solution spécifique intégrée à Grav, centrée sur la simplicité d'utilisation.
Contraintes retenues

    Plugin dédié.

    Interface simplifiée.

    Gestion autonome par le propriétaire.

Dépendances

    CDR-007

    CDR-011

Niveau de consensus

Total
Niveau de confiance

Très élevé
Impact

    Produit

    Backend

    Frontend

    UX

Statut

Validé
Futur ADR

ADR-012

Titre proposé

Gestion des disponibilités via un plugin Grav

Statut ADR

À rédiger
CDR-013
Sujet

Formulaire de contact
Sources

    DCE-CLAUDE-009

    DCE-DEEPSEEK-016

    DCE-DEEPSEEK-017

    DCE-DEEPSEEK-019

    DCE-DEEPSEEK-020

Décision consolidée

Les demandes de contact sont gérées par le plugin Form de Grav, complété par une configuration SMTP sécurisée, des mécanismes de protection contre le spam et une configuration garantissant la délivrabilité des courriels.
Justification

Claude définit l'implémentation technique tandis que DeepSeek complète la décision par les exigences de qualité, de sécurité et de planification.
Contraintes retenues

    Plugin Form officiel.

    SMTP.

    SPF/DKIM.

    Protection anti-spam.

Dépendances

    CDR-003

    CDR-007

Niveau de consensus

Fort
Niveau de confiance

Très élevé
Impact

    Backend

    Produit

    Sécurité

    Exploitation

Statut

Validé
Futur ADR

ADR-013

Titre proposé

Gestion des demandes de contact

Statut ADR

À rédiger
Mapping automatique des ADR
Cluster	Décision consolidée	Documentation
DCL-007	CDR-007	ADR-007
DCL-008	CDR-008	ADR-008
DCL-009	CDR-009	ADR-009
DCL-010	CDR-010	ADR-010
DCL-011	CDR-011	ADR-011
DCL-012	CDR-012	ADR-012
DCL-013	CDR-013	ADR-013
Vérification finale
Cluster	CDR produit	ADR associé
DCL-007	CDR-007	ADR-007
DCL-008	CDR-008	ADR-008
DCL-009	CDR-009	ADR-009
DCL-010	CDR-010	ADR-010
DCL-011	CDR-011	ADR-011
DCL-012	CDR-012	ADR-012
DCL-013	CDR-013	ADR-013
Résultat

    Clusters traités : 13 / 26

    CDR produits : 13

    ADR préparés : 13

    Traçabilité : complète

    Statut : Partie 2 validée

Cette deuxième partie constitue désormais le registre officiel des décisions d'architecture logicielle. Elle servira directement de fondation pour les ADR-007 à ADR-013, conformément au Workflow Kit. 
