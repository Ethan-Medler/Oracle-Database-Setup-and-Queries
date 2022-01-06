SELECT sc.school_name, COUNT(*) as num_people
FROM people p
JOIN schools sc
ON p.school_id = sc.school_id
GROUP BY sc.school_name
ORDER BY num_people DESC;