<?php

namespace Grav\Plugin\CalendrierDisponibilites;

class PeriodValidator
{
    public static function overlaps(array $existingPeriods, string $debut, string $fin): bool
    {
        foreach ($existingPeriods as $periode) {
            if ($debut <= $periode['fin'] && $fin >= $periode['debut']) {
                return true;
            }
        }

        return false;
    }

    public static function isValidDate(string $date): bool
    {
        $d = \DateTimeImmutable::createFromFormat('Y-m-d', $date);

        return $d instanceof \DateTimeImmutable && $d->format('Y-m-d') === $date;
    }

    public static function isChronological(string $debut, string $fin): bool
    {
        return $fin >= $debut;
    }
}
