# Experiment: cis-postgres

An experiment to test various strategies for how to store/query CIS data.

There's some prior art from Robert Muller (@Flipez) around exporting and
munching.

## Requirements

```
brew install postgresql@17          # psql.
mise install                        # aws-cli, Python, uv.
```

You're on your own for installing Docker and a docker-compose friendly command.

## Running

To set up your local Postgres, run:

```
cp dev/container.env.sample dev/container.env
cp dev/local.env.sample dev/local.env
# edit to your liking
docker-compose up
```

If something happens, you can reset the state by running:

```
./dev/clean.sh
```

Download all profiles from a DynamoDB S3 snapshot:

```
AWS_PROFILE=iam-admin aws s3 sync s3://some-bucket-in-aws/AWSDynamoDB/some-generated-id/data/ .
```

Import them into Postgres:

```
for f in ~/tmp/cis-data/raw/*.json.gz; do
    gunzip -c "$f" | \
    jq -r '"\(.Item.id.S),\(.Item.profile.S)"' | \
    uv run -- main.py
done
```

## Examples

Get the top-10 largest profiles, their username on PeopleMo, and their email:

```
SELECT
    connection_username,
    profile::json #>> '{primary_username,value}' AS username,
    profile::json #>> '{primary_email,value}' AS email,
    pg_column_size(profile) AS profile_length
FROM profiles
ORDER BY profile_length DESC
LIMIT 10;
```

Run the query that the HRIS sync job is having trouble with:

```
SELECT connection_username, profile
FROM profiles
WHERE
        connection_username ^@ 'ad|'
    AND profile['active']['value']::boolean = true;
```

Get profiles on the People Directory which include a link, excluding LDAP
peeps:

```
SELECT connection_username, profile #>> '{primary_username,value}' AS pmo_username
FROM profiles
WHERE
        (
                profile['description']['value']::text LIKE '%http://%'
            OR profile['description']['value']::text LIKE '%https://%'
        )
    AND NOT (connection_username ^@ 'ad|');
```
