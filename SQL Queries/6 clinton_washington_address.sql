SELECT first_name || ' ' || last_name AS full_name, 
    address, 
    city
FROM people
WHERE city = 'Clinton' AND 
    address LIKE '%Washington%';