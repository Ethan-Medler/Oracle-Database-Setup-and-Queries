SELECT first_name, last_name, city, region, birth_date
FROM students s
JOIN people p
ON s.person_id = p.person_id
ORDER BY birth_date ASC
FETCH FIRST 1 ROW ONLY;