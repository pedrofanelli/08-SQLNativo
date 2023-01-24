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

/* JUEGO DEL NOMBRE DE LA FAMA 
    ¿Cúales son los 10 nombres más populares? ¿Cúales son los 10 apellidos más populares? ¿Cuales son los full_names más populares?
*/

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

/* PROLIFICO:
    Listá el top 100 de actores más activos y el número de roles en los que participó.
 */

SELECT first_name, last_name, COUNT(actor_id) AS role_count
FROM actors
INNER JOIN roles
ON id = actor_id
GROUP BY first_name, last_name
ORDER BY role_count DESC, last_name
LIMIT 100;

/* FONDO DEL BARRIL */
/* 
    ¿Cuántas películas tiene IMBD de cada género ordenado por el más popular?
*/
SELECT movies_genres.genre, COUNT(movies_genres.genre) AS genre_count
FROM movies_genres
INNER JOIN movies
ON movies_genres.movie_id = movies.id
GROUP BY movies_genres.genre
ORDER BY genre_count;

/* BRAVEHEART */
/* 
    Lista el nombre y apellido de todos los actores que actuaron en la película 'Braveheart' de 1995, ordenados alfabéticamente por sus apellidos.
*/
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
/* 
    Listá todos los directores que dirigieron una película de género 'Film-Noir' en un año bisiesto (hagamos de cuenta que todos los años divisibles por 4 son años bisiestos, aunque no sea verdad en la vida real).
    Tu query deberá retornar el nombre del director, el nombre de la película y el año, ordenado por el nombre de la película.
*/
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
/* 
    Listá todos los actores que hayan trabajado con Kevin Bacon en una película de Drama (incluí el nombre de la película) 
    y excluí al Sr. Bacon de los resultados.
*/

-- Mi versión (también anda!)
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
ORDER BY movies.name ASC;

-- Solución
SELECT m.name, a.first_name || " " || a.last_name AS full_name
    FROM actors AS a
    INNER JOIN roles AS r 
        ON r.actor_id = a.id
    INNER JOIN movies AS m 
        ON r.movie_id = m.id
    INNER JOIN movies_genres AS mg 
        ON mg.movie_id = m.id
        AND mg.genre = 'Drama'
    WHERE m.id IN (
        SELECT bacon_m.id
        FROM movies AS bacon_m
        INNER JOIN roles AS bacon_r 
            ON bacon_r.movie_id = bacon_m.id
        INNER JOIN actors AS bacon_a 
            ON bacon_r.actor_id = bacon_a.id
            WHERE bacon_a.first_name = 'Kevin'
            AND bacon_a.last_name = 'Bacon'
        )
    AND full_name != 'Kevin Bacon'
    ORDER BY m.name ASC;

/*  
    Real es el tiempo desde que empieza hasta que termina el llamado.
    User es la cantidad de tiempo que usa la CPU en el modo usuario (fuera del kernel) dentro del proceso.
    Sys es el tiempo que usa la CPU en el kernel dentro del proceso.
*/

/* IMMORTAL ACTORS */
/* 
    ¿Cúales son los actores que actuaron en un film antes de 1900 y también en un film después del 2000?
    NOTA: no estamos pidiendo todos los actores pre-1900 y post-2000, sino aquellos que hayan trabajado en ambas eras.
*/

SELECT a.first_name, a.last_name, a.id 
    FROM actors AS a
    INNER JOIN roles AS r
        ON a.id = r.actor_id
    INNER JOIN movies AS m 
        ON r.movie_id = m.id
    WHERE m.year < 1900
INTERSECT    -- usamos INTERSECT para unir dos resultados, como dos condicionales true
SELECT a.first_name, a.last_name, a.id 
    FROM actors AS a
    INNER JOIN roles AS r
        ON a.id = r.actor_id
    INNER JOIN movies AS m 
        ON r.movie_id = m.id
    WHERE m.year > 2000
ORDER BY a.id;


/* BUSY FILMING */

/*  Buscá actores que hayan tenido cinco, o más, roles distintos en la misma película luego del año 1990.
    Escribí un query que retorne el nombre del actor, el nombre de la película y el número de roles distintos que hicieron en esa película (que va a ser ≥5). */

SELECT a.first_name, a.last_name, m.name, m.year, COUNT(DISTINCT r.role) AS num_roles
    FROM actors AS a
    INNER JOIN roles AS r
        ON a.id = r.actor_id
    INNER JOIN movies AS m 
        ON r.movie_id = m.id
        WHERE m.year > 1990
        GROUP BY r.actor_id, r.movie_id
        HAVING num_roles >= 5   -- usamos HAVING porque WHERE no puede ser usada con funciones del tipo COUNT()
        ORDER BY m.name DESC;

/* ♀ */
/* Para cada año, contá los números de películas en ese año que tuvieron 
# sólo actrices. Podés empezar por incluir películas sin reparto, 
# pero tu objetivo es estrechar tu búsqueda a sólo películas que tuvieron reparto. */

-- PRIMERA FORMA

SELECT movies.year, count(movies.id) FROM movies
WHERE movies.id IN
(
    SELECT movie_id FROM roles
    WHERE actor_id IN
        ( 
        SELECT actors.id FROM actors -- Tomo todos los actores mujeres
        WHERE actors.gender="F"
        GROUP BY actors.id
        )
    EXCEPT                        -- el EXCEPT es para excluir a los hombres (como un NOT pero más grande)
    SELECT movie_id FROM roles
        WHERE actor_id IN
        ( 
            SELECT actors.id FROM actors -- Tomo actores hombres
            WHERE actors.gender = "M"
            GROUP BY actors.id
        )

    GROUP BY movie_id        -- agrupo por película (todas las peliculas donde solo trabajaron mujeres)
)
GROUP BY movies.year
ORDER BY movies.year;

-- OTRA FORMA (pero MUY lenta)

SELECT movies.year, COUNT(DISTINCT movie_id) as num_movies FROM movies
    INNER JOIN roles ON roles.movie_id = movies.id
    WHERE movies.id NOT IN (
                            SELECT DISTINCT movie_id from roles
                            INNER JOIN actors ON roles.actor_id = actors.id
                            WHERE actors.gender = 'M'
                        )
    GROUP BY year;

/* Acá estamos usando el NOT, excluyendo las peliculas que tienen actores hombre */