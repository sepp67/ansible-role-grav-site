# Modèle de données — Disponibilités

Document de référence sur le format de stockage des disponibilités d'un gîte, construit progressivement (EPIC-003, FEAT-003-01) :

- **TASK-003-01-01** — définition du format de stockage (ce document) ;
- **TASK-003-01-02** — application concrète : extension de la structure YAML des pages de gîtes ;
- **TASK-003-01-03** — fonctions de lecture et d'écriture (section ci-dessous).

Conforme à DR-012 (gestion des disponibilités via un plugin Grav dédié) et à DT-009 (le plugin Calendrier doit rester limité à la gestion des disponibilités, sans mélange de responsabilités) — ce document est volontairement séparé de `docs/model/gite.md`, bien que les données soient techniquement stockées dans le même fichier de page.

## Modèle sémantique (TASK-003-01-01)

La plateforme ne gère ni réservation ni système de disponibilité positive (`docs/context/constraints.md` — « aucun système interne de réservation »). Le calendrier suit donc un **modèle de liste noire** :

- Un gîte est considéré **disponible par défaut**.
- Seules les **périodes explicitement marquées indisponibles** sont stockées (ex. déjà loué via un autre canal, usage personnel du propriétaire, travaux).
- Aucune période « disponible » n'est stockée : son absence dans la liste des indisponibilités suffit à l'impliquer.

Ce choix minimise la donnée à saisir par le propriétaire (il ne déclare que les exceptions) et reste cohérent avec FEAT-003-03 (« Permettre l'ajout de périodes indisponibles », « Permettre la suppression de périodes »).

## Emplacement de stockage

Extension du frontmatter YAML de la page du gîte concerné (`grav/user/pages/03.gites/<gite>/default.md`), et non un fichier ou une source de données séparée. Cohérent avec le stockage Flat File (DR-010) et avec la formulation de TASK-003-01-02 (« étendre la structure YAML des gîtes »).

## Format des dates

ISO 8601 (`AAAA-MM-JJ`), conformément à `docs/conventions/yaml.md`.

## Schéma proposé

```yaml
disponibilites:
  periodes_indisponibles:
    - debut: "2026-08-01"
      fin: "2026-08-15"
    - debut: "2026-09-10"
      fin: "2026-09-12"
```

| Clé | Type | Description |
|---|---|---|
| `disponibilites` | objet | Regroupe les données de calendrier du gîte. |
| `disponibilites.periodes_indisponibles` | liste d'objets | Liste des périodes où le gîte n'est pas disponible. Liste vide ou absente = entièrement disponible. |
| `disponibilites.periodes_indisponibles[].debut` | string (date ISO 8601) | Premier jour de la période indisponible. |
| `disponibilites.periodes_indisponibles[].fin` | string (date ISO 8601) | Dernier jour de la période indisponible. |

Regroupement sous une clé unique `disponibilites` (cohérent avec le style déjà utilisé pour `informations_pratiques`/`coordonnees` dans `docs/model/gite.md`), pour rester extensible sans casser la compatibilité si un futur besoin calendrier apparaît.

## Fonctions de lecture et d'écriture (TASK-003-01-03, mise à jour FEAT-005-05)

Implémentées dans `grav/user/plugins/calendrier-disponibilites/classes/Availability.php` — premier fichier du futur plugin Calendrier (structure complète du plugin réservée à FEAT-003-04-01).

- `Availability::getUnavailablePeriods(PageInterface $page): array` — lit `disponibilites.periodes_indisponibles` **directement depuis le fichier source sur disque** (pas via `Page::header()`, voir incident TASK-003-03-03 ci-dessous). Aucune vérification d'autorisation (lecture publique, cohérente avec l'affichage FEAT-003-02).
- `Availability::setUnavailablePeriods(PageInterface $page, array $periods, UserInterface $user): void` — **vérifie `Permissions::canManage($user, $page)` avant toute écriture** (FEAT-005-05), lève une `RuntimeException` en cas de refus, sinon remplace la liste et persiste la page sur disque (`Page::header()` + `Page::save()`, API Grav native).

Fonctions volontairement génériques (lecture/écriture de la liste complète) : la logique d'ajout/suppression d'une période individuelle relève de FEAT-003-03, pas de cette Task. La vérification d'autorisation est intégrée à la fonction d'écriture elle-même (pas laissée à la charge de chaque futur appelant), voir `grav/user/plugins/calendrier-disponibilites/classes/Permissions.php` (FEAT-005-02).

## Incident résolu — cache de pages Grav (TASK-003-03-03)

Deux écritures rapprochées (ajout de deux périodes en quelques secondes) provoquaient une **perte silencieuse de données** : la seconde écriture ne « voyait » pas la première et l'écrasait. Diagnostic complet :

1. `clearstatcache()` seul après l'écriture — insuffisant.
2. `Cache::invalidateCache()` (mécanisme officiel Grav : touche `system.yaml`, vide `stat()`/OPcache) — insuffisant.
3. `Cache::deleteAll()` — corrige la perte de données mais **casse la validation des nonces** de formulaire (effet de bord inacceptable).
4. **Cause racine identifiée** : `Page::header()` s'appuie sur `CompiledMarkdownFile` (`system/src/Grav/Common/File/CompiledFile.php`), qui maintient son propre cache compilé (`cache/compiled/files/`), distinct du cache de pages. Ce cache ne s'est pas invalidé de façon fiable entre deux requêtes rapprochées sous PHP-FPM, y compris après les tentatives 1 à 3.
5. **Correction retenue** : `getUnavailablePeriods()` lit désormais le fichier source directement (lecture de fichier + `Symfony\Component\Yaml\Yaml::parse()`), contournant entièrement cette couche de cache pour cette lecture précise. `setUnavailablePeriods()` continue d'utiliser `Page::header()` + `Page::save()` (API Grav native) pour l'écriture.

**Limite résolue (TASK-003-06-02)** : les lectures via Twig (`page.header.disponibilites...`) souffraient du même problème de cache — un test délibéré (ajout puis lecture immédiate de l'affichage public) a reproduit un affichage non à jour malgré un disque déjà correct. Corrigé en exposant `Availability::getUnavailablePeriods()` à Twig via une fonction dédiée (`disponibilites_periodes(page)`, enregistrée par le plugin via `onTwigInitialized`), utilisée à la place de `page.header.disponibilites.periodes_indisponibles` dans `gite-item.html.twig` (affichage public) et `gerer-disponibilites.html.twig` (calendrier et liste des périodes du propriétaire). Aucune lecture Twig ne passe plus par le cache compilé de Grav.

## Explicitement hors périmètre de cette Task

- Application aux pages réelles des deux gîtes — TASK-003-01-02.
- Logique d'ajout/suppression d'une période individuelle — FEAT-003-03.
- Validation du chevauchement des périodes et cohérence des dates — FEAT-003-05.
- Affichage (public ou d'édition) — FEAT-003-02/003-03.
- Structure complète du plugin Grav (blueprint, classe principale, hooks) — FEAT-003-04-01.
