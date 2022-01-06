SELECT 'people' AS TABLE_NAME, count(*) AS NUM_RECORDS FROM people
UNION 
SELECT 'principals' AS TABLE_NAME, count(*) AS NUM_RECORDS FROM principals
UNION 
SELECT 'students' AS TABLE_NAME, count(*) AS NUM_RECORDS FROM students
UNION
SELECT 'teachers' AS TABLE_NAME, count(*) AS NUM_RECORDS FROM teachers;