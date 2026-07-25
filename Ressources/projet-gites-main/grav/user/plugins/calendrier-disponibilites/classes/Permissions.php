<?php

namespace Grav\Plugin\CalendrierDisponibilites;

use Grav\Common\Page\Interfaces\PageInterface;
use Grav\Common\User\Interfaces\UserInterface;

class Permissions
{
    public static function canManage(UserInterface $user, PageInterface $page): bool
    {
        if (!$user->authenticated) {
            return false;
        }

        $header = (array) $page->header();
        return $user->username === ($header['proprietaire'] ?? null);
    }
}
