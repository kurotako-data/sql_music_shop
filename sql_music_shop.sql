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

CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(100),
    first_name VARCHAR(100),
    title VARCHAR(100),
    reports_to INT NULL,
    birthdate DATE,
    hire_date DATE,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100),
    FOREIGN KEY (reports_to) REFERENCES employee(employee_id)
);

CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company VARCHAR(100) NULL,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50) NULL,
    country VARCHAR(50),
    postal_code VARCHAR(20) NULL,
    phone VARCHAR(50) NULL,
    fax VARCHAR(50) NULL,
    email VARCHAR(100),
    support_rep_id INT,
    FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id)
);

CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE media_type (
    media_type_id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE track (
    track_id INT PRIMARY KEY,
    name VARCHAR(255),
    album_id INT,
    media_type_id INT,
    genre_id INT,
    composer VARCHAR(255) NULL,
    milliseconds INT,
    bytes INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (album_id) REFERENCES album(album_id),
    FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE playlist_track (
    playlist_id INT,
    track_id INT,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);

CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    invoice_date DATETIME,
    billing_address VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(50),
    billing_country VARCHAR(50),
    billing_postal_code VARCHAR(20),
    total DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE invoice_line (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT,
    track_id INT,
    unit_price DECIMAL(10, 2),
    quantity INT,
    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);

#soucis d'importation sur le fichier employee lié à une clé étrangére (reports_to)
#resolution par importation manuelle
INSERT INTO employee (employee_id, last_name, first_name, title, reports_to, birthdate, hire_date, address, city, state, country, postal_code, phone, fax, email)
VALUES (9, 'Madan', 'Mohan', 'Senior General Manager', NULL, '1961-01-26', '2016-01-14', '1008 Vrinda Ave MT', 'Edmonton', 'AB', 'Canada', 'T5K 2N1', '+1 (780) 428-9482', '+1 (780) 428-9482', 'madan.mohan@chinookcorp.com');

#Qui est l'employé le plus jeune, trouver le nom et le titre du poste ?
SELECT first_name, last_name, title
FROM employee
ORDER BY birthdate DESC
LIMIT 1;

#Quels sont les 3 pays qui ont le plus de factures ?
SELECT billing_country, COUNT(*) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC
LIMIT 3;

#Les 3 factures avec les valeurs les plus importantes :
SELECT invoice_id, total
FROM invoice
ORDER BY total DESC
LIMIT 3;

#Les 3 factures avec les valeurs les plus faibles :
SELECT invoice_id, total
FROM invoice
ORDER BY total ASC
LIMIT 3;

#Quelle sont les 3 villes avec les meilleurs clients ?
SELECT billing_city, SUM(total) AS total_spent
FROM invoice
GROUP BY billing_city
ORDER BY total_spent DESC
LIMIT 3;

#Qui est le meilleur client ?
SELECT c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

#Les genres sont triés pour chaque pays en fonction du volume d'achats (les plus élevés en premier).
SELECT 
    c.country,
    g.name AS genre_name,
    COUNT(il.quantity) AS total_purchases
FROM 
    invoice i
JOIN 
    customer c ON i.customer_id = c.customer_id
JOIN 
    invoice_line il ON i.invoice_id = il.invoice_id
JOIN 
    track t ON il.track_id = t.track_id
JOIN 
    genre g ON t.genre_id = g.genre_id
GROUP BY 
    c.country, g.genre_id
ORDER BY 
    c.country, total_purchases DESC;

#Ecrivez une requête pour obtenir le prénom, le nom, l'email et le genre de tous les auditeurs de musique rock. 
#Retournez votre liste classée par ordre alphabétique d'email en commençant par A.
SELECT 
    c.first_name, 
    c.last_name, 
    c.email, 
    g.name AS genre_name
FROM 
    customer c
JOIN 
    invoice i ON c.customer_id = i.customer_id
JOIN 
    invoice_line il ON i.invoice_id = il.invoice_id
JOIN 
    track t ON il.track_id = t.track_id
JOIN 
    genre g ON t.genre_id = g.genre_id
WHERE 
    g.name = 'Jazz'
ORDER BY 
    c.email ASC;

# Invitons les artistes qui ont écrit le plus de musique Metal dans notre ensemble de données. 
# Ecrivez une requête qui renvoie le nom de l'artiste et le nombre total de pistes des 10 premiers groupes de Metal.
SELECT 
    ar.name AS artist_name,
    COUNT(t.track_id) AS total_metal_tracks
FROM 
    artist ar
JOIN 
    album al ON ar.artist_id = al.artist_id
JOIN 
    track t ON al.album_id = t.album_id
JOIN 
    genre g ON t.genre_id = g.genre_id
WHERE 
    g.name = 'Metal'
GROUP BY 
    ar.name
ORDER BY 
    total_metal_tracks DESC
LIMIT 10;

#Renvoyer tous les noms de morceaux dont la durée est inférieure à la durée moyenne des morceaux. 
#Renvoyer le nom et les millisecondes de chaque morceau. Classer par longueur de chanson, les chansons les plus courtes étant listées en premier.
SELECT 
    name, 
    milliseconds
FROM 
    track
WHERE 
    milliseconds < (SELECT AVG(milliseconds) FROM track)
ORDER BY 
    milliseconds ASC;

#Quel est le montant dépensé par chaque client pour des artistes ? 
#Écrivez une requête qui renvoie le nom du client, le nom de l'artiste et le montant total dépensé.
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    ar.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM 
    customer c
JOIN 
    invoice i ON c.customer_id = i.customer_id
JOIN 
    invoice_line il ON i.invoice_id = il.invoice_id
JOIN 
    track t ON il.track_id = t.track_id
JOIN 
    album al ON t.album_id = al.album_id
JOIN 
    artist ar ON al.artist_id = ar.artist_id
GROUP BY 
    c.first_name, c.last_name, ar.name
ORDER BY 
    total_spent DESC;


# Ecrivez une requête qui détermine le client qui a dépensé le plus en musique pour chaque pays. 
# Ecrivez une requête qui renvoie le pays ainsi que le client qui a dépensé le plus et le montant qu'il a dépensé. 
# Pour les pays où le montant le plus élevé est partagé, indiquez tous les clients qui ont dépensé ce montant.
WITH TotalSpentByCustomer AS (
    SELECT 
        c.country,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(il.unit_price * il.quantity) AS total_spent
    FROM 
        customer c
    JOIN 
        invoice i ON c.customer_id = i.customer_id
    JOIN 
        invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY 
        c.country, c.first_name, c.last_name
),
MaxSpentByCountry AS (
    SELECT 
        country,
        MAX(total_spent) AS max_spent
    FROM 
        TotalSpentByCustomer
    GROUP BY 
        country
)
SELECT 
    t.country,
    t.customer_name,
    t.total_spent
FROM 
    TotalSpentByCustomer t
JOIN 
    MaxSpentByCountry m
    ON t.country = m.country 
    AND t.total_spent = m.max_spent
ORDER BY 
    t.country ASC, t.customer_name ASC;






