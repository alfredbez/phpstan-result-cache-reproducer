# PHPStan result cache: a new file re-analyses every file with errors

Synthetic reproducer, no third-party code.

```sh
composer install
python3 verify.py         # asserts the reported behaviour on pinned PHPStan 2.3.1
perf/run.sh 2000          # cost: one new file re-analyses all 2000 baselined files
counterexample/run.sh     # soundness: errors that only go away if files without *.notFound errors are re-analysed
```

Requires PHP 8.2+, Composer, Python 3 and GNU/Linux for the timing script.
The GitHub Actions workflow passes when it confirms the reported behaviour;
green does not mean the performance problem is fixed. `verify.py` fails if
the expected reanalysis counts change or the correctness case keeps stale errors.

Set `PHPSTAN=/path/to/phpstan-src/bin/phpstan` to run a source checkout instead.

## perf/

2000 classes, each with one `return.type` error kept in a generated baseline. Adding one
empty, unrelated class makes the next run re-analyse 2001 files:

```
cold run (empty result cache)              4.42s  Result cache not used because the cache file does not exist.
warm run (nothing changed)                 0.81s  Result cache restored. 0 files will be reanalysed.
after adding one unrelated new file        3.79s  Result cache restored. 2001 files will be reanalysed.
warm run again                             0.87s  Result cache restored. 0 files will be reanalysed.
```

(PHPStan 2.3.1, PHP 8.2, 4 workers.)

## counterexample/

Why the sweep cannot simply be limited to files with `class.notFound`-style identifiers:

- `src/Consumer.php` calls methods that `Service` gets from a missing trait and `Child` from a
  missing parent. Its errors are `method.notFound`; the `*.notFound` symbol errors are in
  `Service.php` and `Child.php`.
- `src/ImportOrderCommand.php` gets `app.commandWithoutHandler` from a project rule
  (`rules/CommandHasHandlerRule.php`) that asks `ReflectionProvider::hasClass()` for a class
  no file names.

`run.sh` copies `new-files/*.php` into `src/` and compares the cached run with a cold run.
The correct result after adding the files is no errors at all.
