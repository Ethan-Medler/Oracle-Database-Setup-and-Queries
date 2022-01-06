SELECT first_name || ' ' || last_name AS full_name,
    CASE WHEN s.student_id IS NOT NULL THEN 'student'
    WHEN t.teacher_id IS NOT NULL THEN 'teacher'
    WHEN ps.principal_id IS NOT NULL THEN 'principal' END AS role,
    CASE WHEN s.student_id IS NOT NULL THEN 'N/A'
    WHEN t.teacher_id IS NOT NULL THEN TO_CHAR(t.salary, '$999,999.99')
    ELSE TO_CHAR(ps.salary, '$999,999.99') END AS salary,
    school_name
FROM people p
LEFT JOIN students s
ON p.person_id = s.person_id
LEFT JOIN teachers t
ON p.person_id = t.person_id
LEFT JOIN principals ps
ON p.person_id = ps.person_id
JOIN schools sc
ON p.school_id = sc.school_id;