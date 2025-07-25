#!/usr/bin/env bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER $CIS_USER PASSWORD '$CIS_PASSWORD';
	CREATE DATABASE $CIS_DB;
	GRANT ALL PRIVILEGES ON DATABASE $CIS_DB TO $CIS_USER;
    GRANT ALL ON SCHEMA public TO $CIS_USER;
    ALTER DATABASE $CIS_DB OWNER TO $CIS_USER;
EOSQL
