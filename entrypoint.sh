#!/bin/bash

echo "[info] Starting hostex..."

set -e

mix run --no-halt

echo "[$(date)] [info] Application stopped"
