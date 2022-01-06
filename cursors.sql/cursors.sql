DECLARE
    CURSOR teacher_cursor IS
        SELECT first_name, last_name, salary
        FROM teachers t
        JOIN people p
        ON t.person_id = p.person_id
        ORDER BY last_name, first_name;
        
    l_first_name people.first_name%TYPE;
    l_last_name people.last_name%TYPE;
    l_salary teachers.salary%TYPE;
BEGIN
    OPEN teacher_cursor;
    
    LOOP
        FETCH teacher_cursor INTO l_first_name, l_last_name, l_salary;
        EXIT WHEN teacher_cursor%NOTFOUND;
        dbms_output.put_line(l_first_name || ' ' || l_last_name || ' earns' || TO_CHAR(l_salary, '$999,999') || ' per year.');
    END LOOP;
    
    CLOSE teacher_cursor;
END;

DECLARE
    CURSOR teacher_cursor(teacher_school_name schools.school_name%TYPE) IS
        SELECT first_name, last_name, salary
        FROM teachers t
        JOIN people p
        ON t.person_id = p.person_id
        JOIN schools sc
        ON p.school_id = sc.school_id
        WHERE school_name = teacher_school_name
        ORDER BY last_name, first_name;
        
    l_teacher teacher_cursor%ROWTYPE;
BEGIN
    
    FOR l_teacher IN teacher_cursor('Clinton Central School') LOOP
        dbms_output.put_line(l_teacher.first_name || ' ' || l_teacher.last_name || ' earns' || TO_CHAR(l_teacher.salary, '$999,999') || ' per year.');
    END LOOP;
    
END;