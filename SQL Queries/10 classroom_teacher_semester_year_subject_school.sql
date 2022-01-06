SELECT c.classroom_id, 
    p.first_name || ' ' || p.last_name AS teacher_full_name,
    c.semester,
    c.year,
    s.subject,
    sc.school_name
FROM classrooms c
JOIN subjects s
ON c.subject_id = s.subject_id
JOIN teachers t
ON c.teacher_id = t.teacher_id
JOIN people p
ON t.person_id = p.person_id
JOIN schools sc
ON p.school_id = sc.school_id
ORDER BY school_name, year, semester, subject;