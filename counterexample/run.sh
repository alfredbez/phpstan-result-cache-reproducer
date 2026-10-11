#!/usr/bin/env bash
# Compares a result-cache run against a cold run after new files declare
# symbols that existing code was missing.
# Usage: PHPSTAN=/path/to/phpstan ./run.sh
set -euo pipefail
cd "$(dirname "$0")/.."
PHPSTAN="${PHPSTAN:-vendor/bin/phpstan}"
DIR=counterexample

analyse() {
	php "$PHPSTAN" analyse -c "$DIR/phpstan.neon" --memory-limit=1G -vv --no-progress --error-format raw "$@" 2>&1 \
		| grep -E 'Result cache|\.php:[0-9]+:' | sed "s#$PWD/##" || true
}

rm -rf "$DIR/tmp" "$DIR"/src/{MissingTrait,MissingParent,ImportOrderCommandHandler}.php

echo '== 1. cold run before adding the files =='
analyse

cp "$DIR"/new-files/*.php "$DIR/src/"

echo '== 2. run with the result cache after adding the files =='
analyse

echo '== 3. cold run after adding the files (result cache cleared) =='
php "$PHPSTAN" clear-result-cache -c "$DIR/phpstan.neon" > /dev/null 2>&1
analyse

rm -rf "$DIR/tmp" "$DIR"/src/{MissingTrait,MissingParent,ImportOrderCommandHandler}.php
