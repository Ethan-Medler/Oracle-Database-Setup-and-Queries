SELECT first_name || ' ' || last_name AS full_name
FROM teachers t
JOIN people p 
ON t.person_id = p.person_id
JOIN schools sc
ON p.school_id = sc.school_id
WHERE school_name LIKE 'Fayetteville%'
AND teacher_id IN (
    SELECT t.teacher_id
    FROM teachers t
    JOIN classrooms c
    ON t.teacher_id = c.teacher_id
    JOIN subjects s
    ON c.subject_id = s.subject_id
    WHERE year = 2021 AND semester = 'spring' AND subject = 'Science');