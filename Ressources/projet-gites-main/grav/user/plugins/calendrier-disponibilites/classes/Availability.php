<?php

namespace Grav\Plugin\CalendrierDisponibilites;

use Grav\Common\Page\Interfaces\PageInterface;
use Grav\Common\User\Interfaces\UserInterface;
use Symfony\Component\Yaml\Yaml;

class Availability
{
    public static function getUnavailablePeriods(PageInterface $page): array
    {
        $header = self::readHeaderFromDisk($page);
        return $header['disponibilites']['periodes_indisponibles'] ?? [];
    }

    public static function setUnavailablePeriods(PageInterface $page, array $periods, UserInterface $user): void
    {
        if (!Permissions::canManage($user, $page)) {
            throw new \RuntimeException('Vous n\'êtes pas autorisé à modifier les disponibilités de ce gîte.');
        }

        $header = (array) $page->header();
        $header['disponibilites']['periodes_indisponibles'] = $periods;
        $page->header($header);
        $page->save();
    }

    /**
     * Lit l'en-tête YAML directement depuis le fichier source, sans passer par
     * le cache compilé de Grav (Page::header() / CompiledMarkdownFile).
     *
     * Constaté (TASK-003-03-03) : deux écritures rapprochées via Page::save()
     * peuvent ne pas être visibles l'une pour l'autre à travers Page::header()
     * sous PHP-FPM — plusieurs tentatives d'invalidation du cache Grav
     * (clearstatcache(), Cache::invalidateCache(), Cache::deleteAll()) n'ont
     * pas résolu le problème de façon fiable (deleteAll() casse même la
     * validation des nonces de formulaire). Contourner le cache pour cette
     * lecture précise garantit une donnée exacte, condition nécessaire avant
     * tout ajout/suppression d'une période.
     */
    private static function readHeaderFromDisk(PageInterface $page): array
    {
        $raw = @file_get_contents($page->filePath());
        if ($raw === false) {
            return [];
        }

        if (!preg_match('/^---\r?\n(.*?)\r?\n---\r?\n?/s', $raw, $matches)) {
            return [];
        }

        return (array) Yaml::parse($matches[1]);
    }
}
