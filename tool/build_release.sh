#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"
environment_file="$project_root/.env"
keystore_path="$HOME/queveo-release.jks"
keychain_service="QueVeo Android release signing"
keychain_account="DavidAG"
flutter_sdk="$(sed -n 's#^flutter.sdk=##p' "$project_root/android/local.properties" | head -1)"
flutter_command="$flutter_sdk/bin/flutter"

if [[ ! -f "$environment_file" ]]; then
  print -u2 "Missing .env. Add THE_MOVIE_DB_KEY and THE_MOVIE_DB_ACCESS_TOKEN locally."
  exit 1
fi

if [[ ! -f "$keystore_path" ]]; then
  print -u2 "Missing release keystore at $keystore_path."
  exit 1
fi

if [[ ! -x "$flutter_command" ]]; then
  print -u2 "Flutter SDK is unavailable. Check android/local.properties."
  exit 1
fi

set -a
source <(tr -d '\r' < "$environment_file")
set +a

if [[ -z "${THE_MOVIE_DB_KEY:-}" || -z "${THE_MOVIE_DB_ACCESS_TOKEN:-}" ]]; then
  print -u2 "TMDB credentials are missing from .env."
  exit 1
fi

signing_password="$(security find-generic-password -a "$keychain_account" -s "$keychain_service" -w)"

export QUEVEO_STORE_FILE="$keystore_path"
export QUEVEO_STORE_PASSWORD="$signing_password"
export QUEVEO_KEY_ALIAS="queveo-release"
export QUEVEO_KEY_PASSWORD="$signing_password"

cd "$project_root"
"$flutter_command" build appbundle --release \
  --dart-define="THE_MOVIE_DB_KEY=$THE_MOVIE_DB_KEY" \
  --dart-define="THE_MOVIE_DB_ACCESS_TOKEN=$THE_MOVIE_DB_ACCESS_TOKEN"
