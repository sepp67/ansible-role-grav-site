---
title: Contact
visible: false
template: contact
form:
  name: contact-form
  fields:
    nom:
      type: text
      label: Nom
      validate:
        required: true
    email:
      type: email
      label: E-mail
      validate:
        required: true
    telephone:
      type: text
      label: Téléphone
    date_arrivee:
      type: date
      label: Date d'arrivée souhaitée
    date_depart:
      type: date
      label: Date de départ souhaitée
    message:
      type: textarea
      label: Message
      validate:
        required: true
    gite:
      type: hidden
    honeypot:
      type: honeypot
  buttons:
    submit:
      type: submit
      value: Envoyer
  process:
    - email:
        to: "{{ proprietaire_email(form.value('gite')) }}"
        reply_to: "{{ form.value('email') }}"
        subject: "[Contact] Nouvelle demande de {{ form.value.nom }}"
        body: "{% include 'forms/contact-email.html.twig' %}"
    - redirect: /contact/confirmation
---

Formulaire de contact (définition partagée, incluse sur les fiches de gîtes — TASK-004-01-03).
