#!/usr/bin/env bash
# Shows that adding one unrelated new file re-analyses every file that has a
# (baselined) error in the result cache.
# Usage: PHPSTAN=/path/to/phpstan ./run.sh [number-of-files]
set -euo pipefail
cd "$(dirname "$0")"
PHPSTAN="${PHPSTAN:-../vendor/bin/phpstan}"
COUNT="${1:-2000}"

rm -rf tmp src phpstan-baseline.neon
echo 'parameters: []' > phpstan-baseline.neon
php generate.php "$COUNT"

run() {
	local label="$1"
	local start end out
	start=$(date +%s.%N)
	out=$(php "$PHPSTAN" analyse --memory-limit=1G -vv --no-progress --error-format raw 2>&1 || true)
	end=$(date +%s.%N)
	printf '%-40s %6.2fs  %s\n' "$label" "$(awk "BEGIN { print $end - $start }")" \
		"$(echo "$out" | grep -E 'Result cache|errors?' | grep -vE '^\s*$' | head -1)"
}

php "$PHPSTAN" analyse --memory-limit=1G --no-progress --generate-baseline phpstan-baseline.neon > /dev/null 2>&1 || true
php "$PHPSTAN" clear-result-cache > /dev/null 2>&1 || true
run 'cold run (empty result cache)'
run 'warm run (nothing changed)'

mkdir -p src/New
cat > src/New/BrandNew.php <<'PHP'
<?php declare(strict_types = 1);

namespace ResultCacheRepro\New;

final class BrandNew
{

}
PHP
run 'after adding one unrelated new file'
run 'warm run again'

