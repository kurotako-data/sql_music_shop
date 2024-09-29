CREATE DATABASE sql_music_shop;
USE sql_music_shop;
SHOW DATABASES;

CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title VARCHAR(255),
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

