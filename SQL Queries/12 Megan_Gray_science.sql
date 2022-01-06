SELECT student, grade
FROM classroom_students_view
WHERE teacher = 'Megan Gray' 
AND subject = 'Science' 
AND year = 2021
ORDER BY grade DESC;