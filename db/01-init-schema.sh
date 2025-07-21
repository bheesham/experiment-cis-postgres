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

    CREATE OR REPLACE VIEW profiles_splat_group_names (connection_username, group_name) AS (
            SELECT profiles.connection_username,
                jsonb_object_keys((profiles.profile #> '{access_information,ldap,values}'::text[])) AS group_name
            FROM profiles
            WHERE (jsonb_typeof((profiles.profile #> '{access_information,ldap,values}'::text[])) = 'object'::text)
        UNION ALL
            SELECT profiles.connection_username,
                 jsonb_object_keys((profiles.profile #> '{access_information,mozilliansorg,values}'::text[])) AS group_name
            FROM profiles
            WHERE (jsonb_typeof((profiles.profile #> '{access_information,mozilliansorg,values}'::text[])) = 'object'::text)
    );
EOSQL
