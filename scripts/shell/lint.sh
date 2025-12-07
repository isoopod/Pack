#!/bin/sh

set -e

selene generate-roblox-std
selene src
selene tests/shared/__tests__