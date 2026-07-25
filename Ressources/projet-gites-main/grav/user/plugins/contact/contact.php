<?php

namespace Grav\Plugin;

use Grav\Common\Data\ValidationException;
use Grav\Common\Plugin;
use RocketTheme\Toolbox\Event\Event;

class ContactPlugin extends Plugin
{
    public static function getSubscribedEvents(): array
    {
        return [
            'onPluginsInitialized' => ['onPluginsInitialized', 0],
        ];
    }

    public function onPluginsInitialized(): void
    {
        $this->loadEmailPrivateConfig();

        $this->enable([
            'onTwigInitialized' => ['onTwigInitialized', 0],
            'onFormValidationProcessed' => ['onFormValidationProcessed', 0],
        ]);
    }

    public function onFormValidationProcessed(Event $event): void
    {
        $form = $event['form'];
        if ($form->getName() !== 'contact-form') {
            return;
        }

        if ($form->value('honeypot')) {
            throw new ValidationException('Votre demande n\'a pas pu être traitée.');
        }

        $debut = $form->value('date_arrivee');
        $fin = $form->value('date_depart');

        if ($debut && $fin && $fin < $debut) {
            throw new ValidationException("La date de départ doit être postérieure ou égale à la date d'arrivée.");
        }
    }

    private function loadEmailPrivateConfig(): void
    {
        $path = $this->grav['locator']->findResource('user://config/plugins/email-private.php');
        if (!$path || !file_exists($path)) {
            return;
        }

        $credentials = require $path;
        if (!is_array($credentials)) {
            return;
        }

        $config = $this->grav['config'];
        foreach ($credentials as $key => $value) {
            $config->set("plugins.email.mailer.smtp.{$key}", $value);
        }
    }

    public function onTwigInitialized(): void
    {
        $this->grav['twig']->twig()->addFunction(
            new \Twig\TwigFunction('proprietaire_email', [$this, 'resolveProprietaireEmail'])
        );
    }

    public function resolveProprietaireEmail(?string $giteRoute): ?string
    {
        $fallback = $this->grav['config']->get('plugins.email.to');

        if (!$giteRoute) {
            return $fallback;
        }

        $page = $this->grav['pages']->find($giteRoute);
        if (!$page) {
            return $fallback;
        }

        $header = (array) $page->header();
        $username = $header['proprietaire'] ?? null;
        if (!$username) {
            return $fallback;
        }

        $user = $this->grav['accounts']->load($username);
        if (!$user->exists()) {
            return $fallback;
        }

        return $user['email'] ?? $fallback;
    }
}
