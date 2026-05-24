-- init.sql

-- Several controls issue cluster-level queries via postgres_session without an
-- explicit database, so psql defaults the dbname to the connecting user
-- (testuser). Create that database so those queries connect instead of failing
-- with: database "testuser" does not exist.
CREATE DATABASE testuser OWNER testuser;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL
);

INSERT INTO users (username, password) VALUES
('testuser1', 'password1'),
('testuser2', 'password2');