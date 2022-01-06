CREATE OR REPLACE FUNCTION get_classroom_teacher(
    subject_in IN subjects.subject%TYPE,
    school_name_in IN schools.school_name%TYPE,
    year_in IN classrooms.year%TYPE,
    semester_in IN classrooms.semester%TYPE)
    RETURN people.first_name%TYPE
IS
    l_teacher_name people.first_name%TYPE;
    
BEGIN

    SELECT first_name || ' ' || last_name
    INTO l_teacher_name
    FROM people p
    JOIN schools sc
    ON p.school_id = sc.school_id
    JOIN teachers t
    ON p.person_id = t.person_id
    WHERE sc.school_name = school_name_in AND
    t.teacher_id IN (SELECT t.teacher_id FROM teachers t
                    JOIN classrooms c
                    ON t.teacher_id = c.teacher_id
                    JOIN subjects s
                    ON c.subject_id = s.subject_id
                    WHERE s.subject = subject_in
                    AND c.year = year_in
                    AND c.semester = semester_in);
    
    IF SQL%NOTFOUND THEN
        RAISE no_data_found;
    ELSE
        RETURN l_teacher_name;
    END IF;
    
EXCEPTION
    WHEN no_data_found THEN
        RETURN NULL;
END get_classroom_teacher;


DECLARE
    l_subject  VARCHAR(20)  :='Science';
    l_school  VARCHAR(40)   :='Fayetteville-Manlius School';
    l_year   NUMBER    := 2021;
    l_semester VARCHAR(20)  :='spring';
    l_teacher_name VARCHAR(30);
BEGIN
    l_teacher_name := get_classroom_teacher(
        subject_in => l_subject,
        school_name_in => l_school,
        year_in => l_year,
        semester_in => l_semester);
        
    dbms_output.put_line(l_teacher_name);
END;

DECLARE
    l_subject  VARCHAR(20)  :='Science';
    l_school  VARCHAR(40)   :='Fayetteville-Manlius School';
    l_year   NUMBER    := 2023;
    l_semester VARCHAR(20)  :='spring';
    l_teacher_name VARCHAR(30);
BEGIN
    l_teacher_name := get_classroom_teacher(
        subject_in => l_subject,
        school_name_in => l_school,
        year_in => l_year,
        semester_in => l_semester);
    
    IF l_teacher_name IS NOT NULL THEN
        dbms_output.put_line(l_teacher_name);
    ELSE
        dbms_output.put_line('No Teacher Found');
    END IF;
END;