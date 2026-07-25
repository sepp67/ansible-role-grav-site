# Modèle de données — Formulaire de contact

Document de référence sur les champs du formulaire de contact destiné aux vacanciers (EPIC-004, FEAT-004-01) :

- **TASK-004-01-01** — définition des champs du formulaire (ce document) ;
- **TASK-004-01-02** — configuration du formulaire avec le plugin Form de Grav ;
- **TASK-004-01-03** — rendu du formulaire dans le template de fiche de gîte ;
- **TASK-004-01-04** — association du formulaire à la page du gîte (identification du destinataire).

Conforme à DR-013 (gestion des demandes de contact via le plugin Form de Grav) et à `docs/context/constraints.md` : les demandes sont transmises directement au propriétaire par courrier électronique, aucun système interne de réservation n'est conservé, aucun paiement n'est intégré.

## Modèle sémantique (TASK-004-01-01)

Le vacancier (`docs/context/terminology.md` — pas de compte utilisateur dans le MVP) transmet une demande de contact via un formulaire présent sur la fiche de chaque gîte. La demande est envoyée par e-mail directement au propriétaire du gîte concerné (FEAT-004-01-04). Aucune donnée saisie n'est stockée côté plateforme : le formulaire ne fait que déclencher un envoi (DR-013, constraints.md).

Les champs de date (« dates souhaitées ») sont purement informatifs : ils ne sont comparés à aucune disponibilité du calendrier (`docs/model/disponibilites.md`), conformément à l'absence de système de réservation interne.

## Schéma des champs

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `nom` | texte | Oui | Nom du vacancier, pour permettre au propriétaire de l'identifier dans sa réponse. |
| `email` | e-mail | Oui | Seule voie de réponse du propriétaire au vacancier (aucun compte vacancier). |
| `telephone` | texte | Non | Coordonnée complémentaire, facultative. |
| `date_arrivee` | date | Non | Date d'arrivée souhaitée, purement informative. |
| `date_depart` | date | Non | Date de départ souhaitée, purement informative. |
| `message` | texte long | Oui | Contenu de la demande adressée au propriétaire. |
| `gite` | caché (technique) | — | Route de la fiche de gîte d'origine (ex. `/gites/gite-un`), injectée automatiquement via `Form::setData()` au rendu (TASK-004-01-04). Permet d'identifier le gîte concerné, exploité par FEAT-004-02-03 pour déterminer le destinataire. Non visible ni saisi par le vacancier. |

Nommage en `snake_case`, conforme à `docs/conventions/yaml.md` (champs métier du projet).

## Explicitement hors périmètre de cette Task

- Configuration du plugin Form de Grav (blueprint, actions, envoi d'e-mail) — TASK-004-01-02.
- Rendu du formulaire dans le template Twig de la fiche de gîte — TASK-004-01-03.
- Association du formulaire au gîte pour déterminer le destinataire — TASK-004-01-04.
- Validation côté serveur des champs — FEAT-004-05.
- Protection anti-spam (honeypot/CAPTCHA) — FEAT-004-06.
- Configuration SMTP, SPF/DKIM, délivrabilité — FEAT-004-02/003.
