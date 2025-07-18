import sys
import psycopg


def main():
    with psycopg.connect() as conn:
        with conn.cursor() as cur:
            for line in sys.stdin:
                username, _, profile = line.partition(",")
                cur.execute(
                    """
                    INSERT INTO profiles (connection_username, profile)
                    VALUES (%s, %s)
                    ON CONFLICT (connection_username) DO NOTHING
                    """,
                    (
                        username,
                        profile.strip(),
                    ),
                )
        conn.commit()


if __name__ == "__main__":
    main()
