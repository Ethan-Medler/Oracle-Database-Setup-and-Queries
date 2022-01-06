CREATE OR REPLACE TRIGGER classroom_update_trigger
    BEFORE
        INSERT 
        OR UPDATE OF teacher_id, subject_id
    ON classrooms
    FOR EACH ROW
    
DECLARE
    l_subject_id subjects.subject_id%TYPE;
    l_teacher_name VARCHAR(30);
    l_subject_name subjects.subject%TYPE;
    invalid_teacher_subject EXCEPTION;
BEGIN

    SELECT first_name || ' ' || last_name AS full_name, s.subject, t.subject_id
    INTO l_teacher_name, l_subject_name, l_subject_id
    FROM people p
    JOIN teachers t
    ON p.person_id = t.person_id
    JOIN subjects s
    ON t.subject_id = s.subject_id
    WHERE t.teacher_id = :NEW.teacher_id;

    IF :NEW.subject_id != l_subject_id THEN
        RAISE invalid_teacher_subject;
    END IF;

EXCEPTION
    WHEN invalid_teacher_subject THEN
        RAISE_APPLICATION_ERROR(-20010, 
            l_teacher_name || ' does not teach ' || l_subject_name);
END classroom_update_trigger;

INSERT INTO classrooms
(teacher_id, subject_id, semester, year)
VALUES (1, 1, 'spring', 2022);

INSERT INTO classrooms
(teacher_id, subject_id, semester, year)
VALUES (2, 1, 'spring', 2022);