SELECT sc.school_name, COUNT(*) as num_students
FROM students s
JOIN people p
ON s.person_id = p.person_id
JOIN schools sc
ON p.school_id = sc.school_id
GROUP BY sc.school_name
ORDER BY num_students DESC;