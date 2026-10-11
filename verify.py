#!/usr/bin/env python3
"""Confirm the performance symptom and reject stale cached diagnostics."""
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parent


def run(script, *args):
    result = subprocess.run(
        ["bash", script, *args], cwd=ROOT, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=True,
    )
    print(result.stdout, end="")
    return result.stdout


perf = run("perf/run.sh", "20")
for label, expected in [
    ("cold run (empty result cache)", "cache file does not exist"),
    ("warm run (nothing changed)", "0 files will be reanalysed"),
    ("after adding one unrelated new file", "21 files will be reanalysed"),
    ("warm run again", "0 files will be reanalysed"),
]:
    line = next(line for line in perf.splitlines() if line.startswith(label))
    assert expected in line, line

output = run("counterexample/run.sh")
before, after = output.split("== 2. run with the result cache after adding the files ==")
warm, cold = after.split("== 3. cold run after adding the files (result cache cleared) ==")
for identifier in ["class.notFound", "trait.notFound", "method.notFound", "app.commandWithoutHandler"]:
    assert f"[identifier={identifier}]" in before, before
assert "7 files will be reanalysed" in warm, warm
assert "cache file does not exist" in cold, cold
for result in [warm, cold]:
    assert "Result cache is saved." in result, result
    assert "[identifier=" not in result, result
print("Confirmed: unrelated additions reanalyse baselined files; cached results remain correct.")
