# Filtre de censure des diagnostics T21 (GNU sed -E -f).
#
# Masque la VALEUR (jamais le nom) de toute clé sensible, et toute valeur
# ressemblant à un mot de passe fictif généré (molpw-a-… / molpw-b-…).
# Appliqué à docker logs / docker inspect / docker compose config / logs Grav
# avant tout affichage. Objectif : aucune valeur sensible dans les logs CI.

# GRAV_ADMIN_USER / _PASSWORD / _EMAIL / _FULLNAME / _TITLE / _LANGUAGE / _TYPE
s/(GRAV_ADMIN_[A-Z]+"?[[:space:]]*[=:][[:space:]]*"?)[^",[:space:]}\)]*/\1***REDACTED***/g

# Toute clé contenant PASSWORD / SECRET / TOKEN (insensible à la casse)
s/([A-Za-z0-9_.-]*PASSWORD[A-Za-z0-9_.-]*"?[[:space:]]*[=:][[:space:]]*"?)[^",[:space:]}\)]*/\1***REDACTED***/Ig
s/([A-Za-z0-9_.-]*SECRET[A-Za-z0-9_.-]*"?[[:space:]]*[=:][[:space:]]*"?)[^",[:space:]}\)]*/\1***REDACTED***/Ig
s/([A-Za-z0-9_.-]*TOKEN[A-Za-z0-9_.-]*"?[[:space:]]*[=:][[:space:]]*"?)[^",[:space:]}\)]*/\1***REDACTED***/Ig

# En-têtes HTTP Authorization / Cookie
s/((Authorization|Cookie)"?[[:space:]]*:[[:space:]]*).*/\1***REDACTED***/Ig

# Mots de passe fictifs générés (forme : molpw-<a|b>-<>=1 alphanum>)
s/molpw-[ab]-[A-Za-z0-9]+/molpw-***REDACTED***/g
