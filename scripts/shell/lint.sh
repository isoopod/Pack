#!/bin/sh

set -e

$HOME/.aftman/bin/selene generate-roblox-std
$HOME/.aftman/bin/selene src
$HOME/.aftman/bin/selene tests