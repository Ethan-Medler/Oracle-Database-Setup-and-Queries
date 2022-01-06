SELECT first_name, last_name 
FROM teachers
JOIN people
ON teachers.person_id = people.person_id
ORDER BY last_name, first_name;