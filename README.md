# sql_music_shop
test project on SQL for a music shop with the help of SQL

Objectif:
Dans ce projet, je me suis entrainé sur SQL (MySQL en local) avec l'ensemble des données d'un magasin de disques 
L'objectif est d'analyser et comprendre son activité.

Opérations:

Introduction
Ce projet SQL consiste à analyser et manipuler une base de données représentant un magasin de musique fictif. La base de données contient des informations sur des albums, des artistes, des clients, des employés, des factures et bien plus encore. Notre objectif était d'importer des données dans la base de données MySQL et d'exécuter diverses requêtes pour obtenir des insights utiles, ainsi que de corriger certains problèmes rencontrés lors de l'importation des fichiers CSV.

Structure des Tables
La base de données est composée des tables suivantes, qui sont interconnectées par des clés étrangères :

employee : Détails des employés.
customer : Informations sur les clients, y compris leur représentant de support.
invoice : Factures émises aux clients.
invoice_line : Détails des lignes de factures, incluant les articles vendus.
track : Informations sur les morceaux de musique, y compris l'album, le genre et le type de média.
playlist_track : Association entre les playlists et les morceaux.
playlist : Détails des playlists créées par les utilisateurs.
album : Albums de musique associés aux artistes.
artist : Détails des artistes de musique.
media_type : Types de médias (ex : fichier MP3, fichier vidéo).
genre : Genres de musique (rock, pop, etc.).

Opérations Effectuées
1. Importation des fichiers CSV dans MySQL

Fichiers importés : Importation des fichiers CSV suivants : employee.csv, customer.csv, track.csv, playlist_track.csv, invoice.csv, invoice_line.csv.

Problèmes d'importation : Certains fichiers CSV ont rencontré des problèmes, tels que des erreurs de clés étrangères ou des lignes manquantes. Donc correction manuelle pour les formats de dates, les références de clés étrangères et d'autres erreurs afin de réussir l'importation complète.

3. Vérification des Incohérences
Après l'importation, vérifications pour s'assurer que toutes les clés étrangères faisaient référence à des valeurs valides dans leurs tables respectives.

Exemple de requête utilisée pour vérifier l'intégrité des relations entre les tables :

SELECT customer_id 
FROM invoice 
WHERE customer_id 
NOT IN (SELECT customer_id 
FROM customer);


4. Requêtes d'Analyse
Plusieurs requêtes ont été exécutées pour répondre à des questions analytiques sur les données :

#Employé le plus jeune :
#Cette requête classe les employés en fonction de leur date de naissance (du plus récent au plus ancien)
#et sélectionne le premier résultat qui correspond à l'employé le plus jeune. 
#le but : obtenir son prénom, son nom et son titre.

SELECT first_name, last_name, title
FROM employee
ORDER BY birthdate DESC
LIMIT 1;


#Top 3 des pays avec le plus de factures :
#Cette requête regroupe les factures par pays, 
#compte le nombre total de factures par pays, 
#puis trie les résultats en ordre décroissant et limite le résultat aux trois premiers pays.

SELECT billing_country, COUNT(*) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC
LIMIT 3;


#Top 3 des plus grandes et plus petites factures :
#Ces requêtes trient les factures par montant total dans un ordre décroissant pour les valeurs les plus importantes
#et dans un ordre croissant pour les valeurs les plus faibles.

(Les plus grandes)
SELECT invoice_id, total
FROM invoice
ORDER BY total DESC
LIMIT 3;


(Les plus petites)
SELECT invoice_id, total
FROM invoice
ORDER BY total ASC
LIMIT 3;


#Meilleures villes avec les meilleurs clients :
#Cette requête regroupe les factures par billing_city, 
#calcule la somme totale des montants de factures pour chaque ville (SUM(total))
#et renvoie les 3 villes où le total des factures est le plus élevé.

SELECT billing_city, SUM(total) AS total_spent
FROM invoice
GROUP BY billing_city
ORDER BY total_spent DESC
LIMIT 3;


#Meilleur client en termes de dépenses totales :
#Cette requête effectue une jointure entre les tables customer et invoice pour calculer le total des dépenses de chaque client (SUM(i.total))
#puis elle renvoie le client ayant le total dépensé le plus élevé.

SELECT c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;



#Genre de musique le plus populaire par pays :
#Cette requête effectue les étapes suivantes :

#Jointure des tables : Elle relie les tables invoice, customer, invoice_line, track, et genre.
#Agrégation : Elle calcule le nombre total d'achats pour chaque genre dans chaque pays via COUNT(il.quantity).
#Classement : Les genres sont triés pour chaque pays en fonction du volume d'achats (les plus élevés en premier).
#(Pour obtenir uniquement le genre le plus populaire par pays, j'aurais pu ajouter une sous-requête )

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



#Auditeurs de Rock :
#Explication :

#Jointure des tables :
#La table customer est jointe avec invoice pour lier les clients à leurs factures.
#La table invoice est jointe avec invoice_line pour obtenir les détails des articles achetés dans chaque facture.

#La table invoice_line est ensuite jointe avec track pour lier chaque ligne de facture à une piste de musique spécifique.
#Enfin, la table track est jointe avec genre pour obtenir le genre de musique associé à chaque piste.

#Filtrage par genre :

#La clause WHERE g.name = 'Rock' filtre les résultats pour ne retourner que les auditeurs qui ont acheté des pistes du genre "Rock".

#Classement :

#La clause ORDER BY c.email ASC classe les résultats par adresse email dans l'ordre alphabétique croissant (de A à Z).
#Cela donne une liste des auditeurs de musique rock avec leur prénom, nom, email et le genre de musique (dans ce cas "Rock").

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
    g.name = 'Rock'
ORDER BY 
    c.email ASC;



#Artistes de Metal les plus prolifiques :
#Explication :

#Jointure des tables :

#La table artist est jointe avec album pour lier chaque artiste à ses albums.
#La table album est jointe avec track pour relier les albums aux pistes de musique.
#La table track est jointe avec genre pour associer chaque piste à son genre.

#Filtrage par genre :

#La clause WHERE g.name = 'Metal' filtre les résultats pour ne retourner que les pistes du genre "Metal".

#Comptage et classement :

#La clause COUNT(t.track_id) compte le nombre total de pistes de Metal pour chaque artiste.
#La clause ORDER BY total_metal_tracks DESC trie les artistes par le nombre de pistes dans l'ordre décroissant.
#Enfin, la clause LIMIT 10 limite les résultats aux 10 premiers artistes.

#Cette requête donne la liste des 10 artistes ayant écrit le plus de pistes de musique Metal avec leur nom et le nombre total de pistes.

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



#Chansons plus courtes que la durée moyenne :
#Explication :

#Sous-requête pour la durée moyenne :

#La sous-requête (SELECT AVG(milliseconds) FROM track) calcule la durée moyenne de toutes les pistes en millisecondes.

#Filtrage des morceaux :

La condition milliseconds < (SELECT AVG(milliseconds) FROM track) permet de sélectionner uniquement les morceaux dont la durée est inférieure à la durée moyenne.

#Tri des résultats :

#La clause ORDER BY milliseconds ASC classe les morceaux par leur durée en millisecondes, des plus courtes aux plus longues.
#Cette requête renvoie tous les morceaux dont la durée est inférieure à la moyenne triés en fonction de leur longueur.

SELECT 
    name, 
    milliseconds
FROM 
    track
WHERE 
    milliseconds < (SELECT AVG(milliseconds) FROM track)
ORDER BY 
    milliseconds ASC;



#Dépenses des clients par artiste :
#Explication :

#Jointures :

#La table customer (alias c) est jointe à invoice (alias i) pour relier les clients et leurs factures.
#La table invoice_line (alias il) est jointe à invoice pour récupérer les détails de chaque achat (piste, prix, quantité).
#La table track (alias t) est jointe à invoice_line pour obtenir les informations sur la piste achetée.
#La table album (alias al) est jointe à track pour relier chaque piste à son album.
#La table artist (alias ar) est jointe à album pour obtenir l'artiste qui a créé chaque album.

#Calcul du total dépensé :

#La somme est calculée avec SUM(il.unit_price * il.quantity) qui multiplie le prix unitaire d'une piste par la quantité achetée (au cas où plusieurs exemplaires sont #achetés).

#Groupement et ordre :

#La clause GROUP BY c.first_name, c.last_name, ar.name permet d'agréger les données par client et artiste.

#Le résultat est trié par le montant total dépensé en ordre décroissant (ORDER BY total_spent DESC), pour afficher d'abord les clients qui ont le plus dépensé pour un #artiste.
#Cette requête renvoie une liste du montant total dépensé par chaque client pour chaque artiste.

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



#Meilleur client par pays :
#Explication :

#Sous-requête TotalSpentByCustomer :

#Cette partie calcule le total dépensé par chaque client dans chaque pays. 
#Elle utilise une jointure entre les tables customer, invoice et invoice_line pour obtenir les achats des clients puis fait un GROUP BY par client 
#et pays pour agréger le montant total dépensé par chaque client.
#Pour la concaténation de first_name et last_name : Utilisation de la fonction MySQL standard CONCAT()qui permet d'afficher correctement le nom des clients.

#Sous-requête MaxSpentByCountry :

#Cette sous-requête calcule le montant maximum dépensé pour chaque pays. Elle sélectionne simplement le montant maximum dépensé par n'importe quel client dans chaque pays #en utilisant la fonction d'agrégation MAX().

#Requête principale :

#La requête principale relie les résultats de TotalSpentByCustomer à ceux de MaxSpentByCountry pour ne récupérer que les clients ayant dépensé le montant maximal dans #chaque pays. Cela permet d'afficher tous les clients qui ont dépensé le montant maximal pour leur pays, même s'ils sont plusieurs.

#Ordre de tri :

#Le résultat est trié par country puis par customer_name en ordre alphabétique pour une meilleure lisibilité.

#Résultat :

#country : Le pays du client.
#customer_name : Le nom complet du client.
#total_spent : Le montant total dépensé par le client dans ce pays qui correspond au montant le plus élevé pour ce pays.

#Cette requête permet de retourner, pour chaque pays, le(s) client(s) ayant dépensé le plus avec une gestion des ex aequo en cas de montants identiques.

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





Conclusion
Ce projet SQL a permis de manipuler efficacement des données complexes, de résoudre des problèmes liés à l'importation de fichiers CSV et de générer des insights précieux via des requêtes SQL optimisées. Ces analyses peuvent aider à mieux comprendre le comportement des clients et la popularité des genres musicaux.
