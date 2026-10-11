<?php declare(strict_types = 1);

// Generates N classes that each contain one ordinary (non-symbol) error,
// e.g. the kind of error a project keeps in its baseline.
$count = (int) ($argv[1] ?? 2000);
$dir = __DIR__ . '/src/Generated';
if (!is_dir($dir)) {
	mkdir($dir, 0777, true);
}

for ($i = 1; $i <= $count; $i++) {
	file_put_contents($dir . "/C{$i}.php", <<<PHP
<?php declare(strict_types = 1);

namespace ResultCacheRepro\\Generated;

class C{$i}
{

	public function value(): int
	{
		return 'not an int';
	}

}

PHP);
}

echo "Generated {$count} files in {$dir}\n";
