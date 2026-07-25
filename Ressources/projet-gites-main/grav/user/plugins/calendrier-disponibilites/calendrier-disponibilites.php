<?php

namespace Grav\Plugin;

use Grav\Common\Plugin;
use Grav\Common\Utils;
use Grav\Plugin\CalendrierDisponibilites\Availability;
use Grav\Plugin\CalendrierDisponibilites\PeriodValidator;

class CalendrierDisponibilitesPlugin extends Plugin
{
    public static function getSubscribedEvents(): array
    {
        return [
            'onPluginsInitialized' => ['onPluginsInitialized', 0],
        ];
    }

    public function onPluginsInitialized(): void
    {
        require_once __DIR__ . '/classes/Availability.php';
        require_once __DIR__ . '/classes/Permissions.php';
        require_once __DIR__ . '/classes/PeriodValidator.php';

        $this->enable([
            'onPageInitialized' => ['onPageInitialized', 0],
            'onTwigInitialized' => ['onTwigInitialized', 0],
        ]);
    }

    public function onTwigInitialized(): void
    {
        $this->grav['twig']->twig()->addFunction(
            new \Twig\TwigFunction('disponibilites_periodes', function ($page) {
                return Availability::getUnavailablePeriods($page);
            })
        );
    }

    public function onPageInitialized(): void
    {
        $page = $this->grav['page'];
        if (!$page || $page->template() !== 'gerer-disponibilites') {
            return;
        }

        $uri = $this->grav['uri'];
        if ($uri->method() !== 'POST') {
            return;
        }

        $task = $uri->post('task');
        if (!in_array($task, ['calendrier.add_period', 'calendrier.remove_period'], true)) {
            return;
        }

        $messages = $this->grav['messages'];
        $nonce = $uri->post('nonce');

        if (!Utils::verifyNonce($nonce, 'calendrier-form')) {
            $messages->add('Requête invalide (nonce).', 'error');
            $this->grav->redirect($uri->route());
            return;
        }

        $user = $this->grav['user'];

        $monGite = null;
        foreach ($this->grav['pages']->find('/gites')->children() as $gite) {
            $header = (array) $gite->header();
            if (($header['proprietaire'] ?? null) === $user->username) {
                $monGite = $gite;
                break;
            }
        }

        if (!$monGite) {
            $messages->add('Aucun gîte associé à votre compte.', 'error');
            $this->grav->redirect($uri->route());
            return;
        }

        try {
            if ($task === 'calendrier.add_period') {
                $this->addPeriod($monGite, $user, $uri, $messages);
            } else {
                $this->removePeriod($monGite, $user, $uri, $messages);
            }
        } catch (\RuntimeException $e) {
            $messages->add($e->getMessage(), 'error');
        }

        $this->grav->redirect($uri->route());
    }

    private function addPeriod($gite, $user, $uri, $messages): void
    {
        $debut = $uri->post('debut');
        $fin = $uri->post('fin');

        if (!$debut || !$fin) {
            $messages->add('Données de formulaire invalides.', 'error');
            return;
        }

        if (!PeriodValidator::isValidDate($debut) || !PeriodValidator::isValidDate($fin)) {
            $messages->add('Format de date invalide.', 'error');
            return;
        }

        if (!PeriodValidator::isChronological($debut, $fin)) {
            $messages->add('La date de fin doit être postérieure ou égale à la date de début.', 'error');
            return;
        }

        $periods = Availability::getUnavailablePeriods($gite);

        if (PeriodValidator::overlaps($periods, $debut, $fin)) {
            $messages->add('Cette période chevauche une période déjà déclarée.', 'error');
            return;
        }

        $periods[] = ['debut' => $debut, 'fin' => $fin];
        Availability::setUnavailablePeriods($gite, $periods, $user);
        $messages->add('Période ajoutée.', 'info');
    }

    private function removePeriod($gite, $user, $uri, $messages): void
    {
        $index = $uri->post('index');

        if ($index === null || !is_numeric($index)) {
            $messages->add('Index de période invalide.', 'error');
            return;
        }

        $index = (int) $index;
        $periods = Availability::getUnavailablePeriods($gite);

        if (!isset($periods[$index])) {
            $messages->add('Période introuvable.', 'error');
            return;
        }

        unset($periods[$index]);
        Availability::setUnavailablePeriods($gite, array_values($periods), $user);
        $messages->add('Période supprimée.', 'info');
    }
}
