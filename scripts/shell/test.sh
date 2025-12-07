#!/bin/sh

set -e

rojo build dev.project.json --output dist.rbxl
python3 scripts/python/upload_and_run_task.py dist.rbxl tests/TestRunner.luau
rm dist.rbxl