#!/usr/bin/env bash
set -e

docker rm -fv cis-postgres-adminer-1 cis-postgres-postgres-1
docker volume rm -f cis-postgres_pgdata
