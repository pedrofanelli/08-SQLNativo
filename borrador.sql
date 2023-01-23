CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    name TEXT DEFAULT NULL,
    year INTEGER DEFAULT NULL,
    rank REAL DEFAULT NULL
);

CREATE TABLE actors (
    id INTEGER PRIMARY KEY,
    first_name TEXT DEFAULT NULL,
    last_name TEXT DEFAULT NULL,
    gender TEXT DEFAULT NULL
);

CREATE TABLE roles (
    actor_id INTEGER,
    movie_id INTEGER,
    role_name TEXT DEFAULT NULL
);


SELECT name, year FROM movies
WHERE year = 1902
AND rank > 5;

SELECT directors.first_name, directors.last_name, movies.name
FROM directors
INNER JOIN movies_directors
ON directors.id = movies_directors.director_id
INNER JOIN movies
ON movies.id = movies_directors.movie_id
WHERE directors.last_name = "Nolan"
AND directors.first_name = "Christopher";

/* STACKTORS */

SELECT * FROM actors
WHERE last_name LIKE '%stack%';

/* JUEGO DEL NOMBRE DE LA FAMA */

SELECT first_name, COUNT(first_name) AS occurrences
FROM actors
GROUP BY first_name
ORDER BY occurrences DESC
LIMIT 10;

SELECT last_name, COUNT(last_name) AS occurrences
FROM actors
GROUP BY last_name
ORDER BY occurrences DESC
LIMIT 10;

SELECT (first_name || ' ' || last_name) AS fullName, COUNT(first_name || ' ' || last_name) AS occurrences
FROM actors
GROUP BY fullName
ORDER BY occurrences DESC, fullName 
LIMIT 10;

/* PROLIFICO */

SELECT first_name, last_name, COUNT(actor_id) AS role_count
FROM actors
INNER JOIN roles
ON id = actor_id
GROUP BY first_name, last_name
ORDER BY role_count DESC, last_name
LIMIT 100;

/* FONDO DEL BARRIL */

SELECT movies_genres.genre, COUNT(movies_genres.genre) AS genre_count
FROM movies_genres
INNER JOIN movies
ON movies_genres.movie_id = movies.id
GROUP BY movies_genres.genre
ORDER BY genre_count;

/* BRAVEHEART */

SELECT first_name, last_name
FROM actors
INNER JOIN roles
ON actors.id = roles.actor_id
INNER JOIN movies
ON roles.movie_id = movies.id
WHERE movies.name = 'Braveheart'
AND movies.year = 1995
ORDER BY last_name;

/* NOIR BISIESTO */

SELECT directors.first_name, directors.last_name, movies.name, movies.year
FROM directors
INNER JOIN movies_directors
ON directors.id = movies_directors.director_id
INNER JOIN movies
ON movies_directors.movie_id = movies.id
INNER JOIN movies_genres
ON movies.id = movies_genres.movie_id
WHERE movies_genres.genre = 'Film-Noir'
AND movies.year % 4 = 0
ORDER BY movies.name;

/* KEVIN BACON */

SELECT movies.name, actors.first_name, actors.last_name FROM actors
INNER JOIN roles
ON actors.id = roles.actor_id
INNER JOIN movies
ON roles.movie_id = movies.id
WHERE movies.id IN (SELECT movies.id FROM movies
INNER JOIN movies_genres
ON movies.id = movies_genres.movie_id
WHERE movies_genres.genre = 'Drama')
AND movies.id IN (SELECT roles.movie_id FROM roles
INNER JOIN actors
ON roles.actor_id = actors.id
WHERE actors.first_name = 'Kevin' AND actors.last_name = 'Bacon')
AND (actors.first_name != 'Kevin' AND actors.last_name != 'Bacon')
GROUP BY actors.first_name, actors.last_name
ORDER BY movies.name, actors.last_name;


