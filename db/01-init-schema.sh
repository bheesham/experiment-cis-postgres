#!/usr/bin/env bash
set -e

psql -v ON_ERROR_STOP=1 --username "$CIS_USER" --dbname "$CIS_DB" <<-EOSQL
    CREATE TABLE IF NOT EXISTS profiles(
        connection_username TEXT PRIMARY KEY,
        profile JSONB,
        hris_generation INTEGER DEFAULT 0,
        ldap_generation INTEGER DEFAULT 0,
        source TEXT NULL
    );
EOSQL
