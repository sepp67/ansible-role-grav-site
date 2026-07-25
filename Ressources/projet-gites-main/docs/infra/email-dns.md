# DNS — SPF et DKIM pour l'envoi d'e-mails (TASK-004-03-02)

Document de référence pour l'ajout des enregistrements SPF et DKIM du domaine `lavallee.tech` dans la zone DNS gérée sur l'espace client OVH. Ces enregistrements ne se configurent pas dans ce dépôt (Grav n'y a aucun accès) : ils doivent être ajoutés manuellement dans le manager OVH.

Conforme à DR-013 (« configuration garantissant la délivrabilité des courriels »). Fait suite à FEAT-004-02 (envoi réel opérationnel via le compte SMTP `admin@lavallee.tech`, OVH) et TASK-004-03-01 (adresse expéditrice).

## Pourquoi ces deux enregistrements

- **SPF** (Sender Policy Framework) : indique aux serveurs de messagerie destinataires quels serveurs sont autorisés à envoyer des e-mails « au nom » de `lavallee.tech`. Sans SPF, les e-mails envoyés par la plateforme (formulaire de contact) risquent d'être classés en spam ou rejetés.
- **DKIM** (DomainKeys Identified Mail) : signe cryptographiquement chaque e-mail envoyé, permettant au destinataire de vérifier qu'il n'a pas été altéré et qu'il provient bien d'un serveur autorisé par le domaine.

Les deux sont complémentaires et recommandés ensemble par OVH pour tout domaine utilisant leur infrastructure d'envoi (SMTP `ssl0.ovh.net`, déjà en usage depuis FEAT-004-02).

## SPF — valeur à ajouter

Dans la zone DNS OVH du domaine `lavallee.tech`, ajouter (ou compléter si un enregistrement SPF existe déjà — un domaine ne doit avoir qu'un seul enregistrement TXT SPF) :

| Type | Nom (sous-domaine) | Valeur |
|---|---|---|
| TXT | `@` (apex du domaine) | `v=spf1 include:mx.ovh.com ~all` |

- `~all` (échec souple) est recommandé dans un premier temps, le temps de vérifier que les e-mails de la plateforme sont bien délivrés. Il pourra être resserré en `-all` (échec strict) une fois la configuration validée (TASK-004-03-03).
- Si un enregistrement SPF existe déjà pour `lavallee.tech` (utilisé par d'autres services), **ne pas créer un second enregistrement TXT SPF** : ajouter `include:mx.ovh.com` à l'intérieur de l'enregistrement existant.

## DKIM — procédure (valeur propre au compte, non générique)

Contrairement au SPF, la valeur DKIM est **spécifique à ton compte OVH** et ne peut pas être fournie de façon générique — elle doit être récupérée directement dans le manager OVH :

1. Se connecter au [manager OVH](https://www.ovh.com/manager/), section **Emails** (MX Plan ou l'offre associée à `lavallee.tech`).
2. Sélectionner le domaine `lavallee.tech`, puis la section **DKIM** (ou **Sécurité des e-mails**).
3. Activer DKIM si ce n'est pas déjà fait — OVH génère alors un enregistrement **CNAME** à ajouter, au format :

   | Type | Nom | Valeur (cible) |
   |---|---|---|
   | CNAME | `<identifiant>-selector1._domainkey` | `<identifiant>-selector1._domainkey.<région>.dkim.mail.ovh.net` |

   `<identifiant>` (souvent de la forme `ovhexXXXXXX`) et `<région>` sont propres à ton compte — copier exactement la valeur affichée par OVH, ne pas la reconstituer manuellement.
4. Ajouter ce CNAME dans la zone DNS OVH du domaine (même écran que pour le SPF).

## Après ajout

- La propagation DNS peut prendre jusqu'à 24 h.
- Une fois propagés, la vérification effective (SPF/DKIM bien reconnus, e-mails non filtrés) fait l'objet de **TASK-004-03-03 — Tester la délivrabilité**.

## Sources

- [How to improve email security with an SPF record — OVHcloud Documentation](https://help.ovhcloud.com/csm/en-dns-spf-record?id=kb_article_view&sysparm_article=KB0051705)
- [How to improve email security with a DKIM record — OVHcloud Documentation](https://docs.ovhcloud.com/en/guides/web-cloud/domains/dns-zone-dkim)
- [OVHCloud SPF and DKIM configuration: Step By Step Guideline — EasyDMARC](https://easydmarc.com/blog/ovhcloud-spf-and-dkim-configuration/)
- [How to Set Up SPF for OVH? — PowerDMARC](https://support.powerdmarc.com/support/solutions/articles/60000709935-how-to-set-up-spf-for-ovh-)
