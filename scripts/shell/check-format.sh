#!/bin/sh

set -e

$HOME/.aftman/bin/stylua src
$HOME/.aftman/bin/stylua tests