BEGIN
  EXECUTE IMMEDIATE ('DROP USER C##schooladmin CASCADE');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -01918 THEN
      RAISE;
    END IF;
END;
/

CREATE USER C##schooladmin IDENTIFIED BY school
DEFAULT TABLESPACE users TEMPORARY TABLESPACE
temp ACCOUNT UNLOCK;

ALTER USER C##schooladmin ACCOUNT UNLOCK;
ALTER USER C##schooladmin QUOTA UNLIMITED ON users;

GRANT CONNECT, RESOURCE TO C##schooladmin;
GRANT CREATE VIEW TO C##schooladmin;

CONN C##schooladmin/school
/

-- Create procedure to drop constraints and tables
CREATE OR REPLACE PROCEDURE drop_school_tables
IS
  CURSOR constraint_cursor IS
    SELECT uc.constraint_name, uc.constraint_type, ucc.column_name, ucc.table_name
    FROM user_cons_columns ucc
    JOIN user_constraints uc ON uc.constraint_name = ucc.constraint_name
    WHERE upper(ucc.table_name) IN ('SCHOOLS',
                          'PEOPLE',
                          'TEACHERS',
                          'PRINCIPALS',
                          'STUDENTS',
                          'CLASSROOMS',
                          'SUBJECTS',
                          'CLASSROOM_STUDENTS')
        AND uc.constraint_type = 'R';
  sql_stmt varchar2(400) ;
BEGIN
  FOR constraint_record IN constraint_cursor LOOP
    sql_stmt := ' ALTER TABLE ' ||  constraint_record.table_name ||
                ' DROP CONSTRAINT ' || constraint_record.constraint_name;
    dbms_output.put_line(sql_stmt);
    EXECUTE IMMEDIATE sql_stmt;
  END LOOP;
  COMMIT;
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE schools';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE people';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE principals';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE students';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE teachers';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE classrooms';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE subjects';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE classroom_students';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
        RAISE;
      END IF;
  END;
  COMMIT;
END drop_school_tables;
/
BEGIN
  drop_school_tables();
END;
/

CREATE TABLE schools (
  school_id     NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  school_name   VARCHAR2(35) NOT NULL,
  address       VARCHAR2(60),
  city          VARCHAR2(15),
  region        VARCHAR2(15),
  postal_code   VARCHAR2(10),
  country       VARCHAR2(15),
  principal_id  NUMBER
);

CREATE TABLE subjects (
  subject_id    NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  subject       VARCHAR2(60)
);

CREATE TABLE people (
  person_id     NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  school_id     NUMBER REFERENCES schools(school_id),
  first_name    VARCHAR2(10) NOT NULL,
  last_name     VARCHAR2(20) NOT NULL,
  birth_date    DATE,
  address       VARCHAR2(60),
  city          VARCHAR2(15),
  region        VARCHAR2(15),
  postal_code   VARCHAR2(10),
  country       VARCHAR2(15)
);

CREATE TABLE teachers (
  teacher_id    NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  person_id     NUMBER REFERENCES people(person_id),
  subject_id    NUMBER REFERENCES subjects(subject_id),
  salary        NUMBER
);

CREATE TABLE students (
  student_id    NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  person_id     NUMBER REFERENCES people(person_id),
  grade_level   NUMBER
);

CREATE TABLE principals (
  principal_id  NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  person_id     NUMBER REFERENCES people(person_id),
  salary        NUMBER
);

CREATE TABLE classrooms (
  classroom_id  NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  teacher_id    NUMBER REFERENCES teachers(teacher_id),
  subject_id    NUMBER REFERENCES subjects(subject_id),
  semester      VARCHAR2(6),
  year          NUMBER(4,0)
);

CREATE TABLE classroom_students (
  classroom_id          NUMBER REFERENCES classrooms(classroom_id),
  student_id            NUMBER REFERENCES students(student_id),
  grade                 NUMBER,
  PRIMARY KEY (classroom_id, student_id)
);

ALTER TABLE schools
ADD CONSTRAINT school_principal_fk
FOREIGN KEY (principal_id)
REFERENCES principals(principal_id);

/
INSERT INTO schools (school_name,address,city,region,postal_code,country) VALUES ('Clinton Central School', '75 Chenango Avenue', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO schools (school_name,address,city,region,postal_code,country) VALUES ('New Hartford Central School', '33 Oxford Rd.', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO schools (school_name,address,city,region,postal_code,country) VALUES ('Fayetteville-Manlius School', '8201 East Seneca Turnpike', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO subjects (subject) VALUES ('Math');
INSERT INTO subjects (subject) VALUES ('History');
INSERT INTO subjects (subject) VALUES ('French');
INSERT INTO subjects (subject) VALUES ('English');
INSERT INTO subjects (subject) VALUES ('Science');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Jessica', 'Martin', TO_DATE('1966-11-25','yyyy-mm-dd'), '591 Memorial Dr', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Thomas', 'Thompson', TO_DATE('1971-5-14','yyyy-mm-dd'), '55 Brooksby Village Way', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Sarah', 'Garcia', TO_DATE('1975-9-7','yyyy-mm-dd'), '137 Teaticket Hwy', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Daniel', 'Lewis', TO_DATE('1979-5-19','yyyy-mm-dd'), '677 Timpany Blvd', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Lisa', 'Hall', TO_DATE('1982-4-23','yyyy-mm-dd'), '337 Russell St', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Paul', 'Hill', TO_DATE('1990-4-29','yyyy-mm-dd'), '1775 Washington St', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Steven', 'Green', TO_DATE('2007-1-23','yyyy-mm-dd'), '280 Washington Street', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Deborah', 'Collins', TO_DATE('2005-10-31','yyyy-mm-dd'), '742 Main Street', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Timothy', 'Morris', TO_DATE('2005-12-2','yyyy-mm-dd'), '200 Otis Street', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Laura', 'Cook', TO_DATE('2005-12-3','yyyy-mm-dd'), '180 North King Street', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Helen', 'Cox', TO_DATE('2007-5-16','yyyy-mm-dd'), '300 Colony Place', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Nicholas', 'Howard', TO_DATE('2006-2-14','yyyy-mm-dd'), '301 Falls Blvd', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Emma', 'Hughes', TO_DATE('2005-10-4','yyyy-mm-dd'), '262 Swansea Mall Dr', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Raymond', 'Flores', TO_DATE('2006-2-27','yyyy-mm-dd'), '333 Main Street', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Carolyn', 'Griffin ', TO_DATE('2006-1-13','yyyy-mm-dd'), '2055 Niagara Falls Blvd', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Tyler', 'Patterson', TO_DATE('2006-2-28','yyyy-mm-dd'), '101 Sanford Farm Shpg Center', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Diane', 'King', TO_DATE('2006-12-17','yyyy-mm-dd'), '297 Grant Avenue', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Zachary', 'Foster', TO_DATE('2007-1-1','yyyy-mm-dd'), '30 Catskill', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Jeremy', 'Gonzales', TO_DATE('2006-10-14','yyyy-mm-dd'), '161 Centereach Mall', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Frances', 'Lee', TO_DATE('2007-4-11','yyyy-mm-dd'), '3018 East Ave', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Cheryl', 'White', TO_DATE('2006-7-15','yyyy-mm-dd'), '5033 Transit Road', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Jesse', 'Cooper', TO_DATE('2006-6-14','yyyy-mm-dd'), '25737 US Rt 11', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Billy', 'Jones', TO_DATE('2005-11-4','yyyy-mm-dd'), '2400 Route 9', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Julia', 'Carter', TO_DATE('2006-11-13','yyyy-mm-dd'), '10401 Bennett Road', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Gabriel', 'Williams', TO_DATE('2006-12-9','yyyy-mm-dd'), '1549 Rt 9', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Denise', 'Baker', TO_DATE('2007-2-20','yyyy-mm-dd'), '5360 Southwestern Blvd', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Abigail', 'Lopez', TO_DATE('2006-4-20','yyyy-mm-dd'), '135 Fairgrounds Memorial Pkwy', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Sophia', 'Washington', TO_DATE('2005-10-8','yyyy-mm-dd'), '579 Troy-Schenectady Road', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Johnny', 'Foster', TO_DATE('2005-11-25','yyyy-mm-dd'), '7155 State Rt 12 S', 'Clinton', 'NY', '13323', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Joseph', 'Harris', TO_DATE('2007-6-1','yyyy-mm-dd'), '66-4 Parkhurst Rd', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Karen', 'Robinson', TO_DATE('2006-5-12','yyyy-mm-dd'), '374 William S Canning Blvd', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Nancy', 'Rodriguez', TO_DATE('2006-7-10','yyyy-mm-dd'), '121 Worcester Rd', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Kenneth', 'Nelson', TO_DATE('2006-3-21','yyyy-mm-dd'), '11 Jungle Road', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Joshua', 'Mitchell', TO_DATE('2005-10-11','yyyy-mm-dd'), '301 Massachusetts Ave', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Michelle', 'Perez', TO_DATE('2006-6-14','yyyy-mm-dd'), '780 Lynnway', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Carol', 'Turner', TO_DATE('2005-12-8','yyyy-mm-dd'), '70 Pleasant Valley Street', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Cynthia', 'Bailey', TO_DATE('2007-6-17','yyyy-mm-dd'), '555 East Main St', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Larry', 'Brooks', TO_DATE('2005-12-4','yyyy-mm-dd'), '450 Highland Ave', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Justin', 'Sanders', TO_DATE('2006-4-29','yyyy-mm-dd'), '1105 Boston Road', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Patrick', 'Butler', TO_DATE('2006-7-17','yyyy-mm-dd'), '550 Providence Hwy', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (1, 'Virginia', 'Gonzales', TO_DATE('2006-11-13','yyyy-mm-dd'), '3005 Cranberry Hwy Rt 6 28', 'Clinton', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Jack', 'Bryant ', TO_DATE('1967-2-12','yyyy-mm-dd'), '250 Rt 59', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Douglas', 'Martinez', TO_DATE('1976-8-17','yyyy-mm-dd'), '4133 Veterans Memorial Drive', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Adam', 'Thomas', TO_DATE('1981-3-11','yyyy-mm-dd'), '6265 Brockport Spencerport Rd', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Nathan', 'Carter', TO_DATE('1983-4-4','yyyy-mm-dd'), '3191 County rd 10', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Hannah', 'Davis', TO_DATE('1969-12-28','yyyy-mm-dd'), '85 Crooked Hill Road', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Jacqueline', 'Cook', TO_DATE('1994-2-26','yyyy-mm-dd'), '872 Route 13', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Austin', 'Lopez', TO_DATE('2006-7-29','yyyy-mm-dd'), '2465 Hempstead Turnpike', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Sara', 'Turner', TO_DATE('2007-6-23','yyyy-mm-dd'), '901 Route 110', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Grace', 'Richardson', TO_DATE('2005-11-20','yyyy-mm-dd'), '311 RT 9W', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Judy', 'Anderson', TO_DATE('2007-5-4','yyyy-mm-dd'), '100 Elm Ridge Center Dr', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Marilyn', 'Johnson', TO_DATE('2007-9-17','yyyy-mm-dd'), '103 North Caroline St', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Rose', 'Smith', TO_DATE('2007-7-29','yyyy-mm-dd'), '2 Gannett Dr', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Natalie', 'Garcia', TO_DATE('2006-10-2','yyyy-mm-dd'), '350 E Fairmount Ave', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Vincent', 'Harris', TO_DATE('2006-4-5','yyyy-mm-dd'), '4975 Transit Rd', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Jane', 'White', TO_DATE('2006-9-22','yyyy-mm-dd'), '425 Route 31', 'New Hartford', 'NY', '13413', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'James', 'Smith', TO_DATE('2005-9-23','yyyy-mm-dd'), '777 Brockton Avenue', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Patricia', 'Jones', TO_DATE('2006-2-11','yyyy-mm-dd'), '30 Memorial Drive', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Elizabeth', 'Taylor', TO_DATE('2006-9-15','yyyy-mm-dd'), '250 Hartford Avenue', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'David', 'Anderson', TO_DATE('2006-11-12','yyyy-mm-dd'), '700 Oak Street', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Charles', 'Martinez', TO_DATE('2006-6-11','yyyy-mm-dd'), '42 Fairhaven Commons Way', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Sandra', 'Lopez', TO_DATE('2006-2-10','yyyy-mm-dd'), '295 Plymouth Street', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Donna', 'Gonzalez', TO_DATE('2006-8-7','yyyy-mm-dd'), '20 Soojian Dr', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Brian', 'Parker', TO_DATE('2006-12-15','yyyy-mm-dd'), '830 Curran Memorial Hwy', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Melissa', 'Evans', TO_DATE('2006-2-2','yyyy-mm-dd'), '1470 S Washington St', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Edward', 'Edwards', TO_DATE('2005-12-30','yyyy-mm-dd'), '506 State Road', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Ronald', 'Stewart', TO_DATE('2006-8-27','yyyy-mm-dd'), '72 Main St', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Kathleen', 'Cooper', TO_DATE('2007-7-16','yyyy-mm-dd'), '555 Hubbard Ave-Suite 12', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Jonathan', 'James', TO_DATE('2007-5-12','yyyy-mm-dd'), '36 Paramount Drive', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Brenda', 'Kelly', TO_DATE('2006-9-22','yyyy-mm-dd'), '1180 Fall River Avenue', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Frank', 'Henderson', TO_DATE('2007-5-9','yyyy-mm-dd'), '100 Charlton Road', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (2, 'Debra', 'Simmons', TO_DATE('2005-11-7','yyyy-mm-dd'), '352 Palmer Road', 'New Hartford', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Rachel', 'Alexander', TO_DATE('1976-5-5','yyyy-mm-dd'), '141 Washington Ave Extension', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Dennis', 'Russell', TO_DATE('1969-2-1','yyyy-mm-dd'), '13858 Rt 31 W', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Kelly', 'Thomas', TO_DATE('1984-1-15','yyyy-mm-dd'), '5399 W Genesse St', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Martha', 'Thomas', TO_DATE('1978-11-27','yyyy-mm-dd'), '100 Thruway Plaza', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Roger', 'Long', TO_DATE('1992-1-10','yyyy-mm-dd'), '8064 Brewerton Rd', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Megan', 'Gray', TO_DATE('1995-9-24','yyyy-mm-dd'), '3949 Route 31', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Andrea', 'Richardson', TO_DATE('2006-8-6','yyyy-mm-dd'), '139 Merchant Place', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Christian', 'Smith', TO_DATE('2007-7-25','yyyy-mm-dd'), '279 Troy Road', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Teresa', 'Foster', TO_DATE('2005-12-22','yyyy-mm-dd'), '6438 Basile Rowe', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Willie', 'Hayes', TO_DATE('2007-8-4','yyyy-mm-dd'), '1818 State Route 3', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Madison', 'Price', TO_DATE('2006-9-9','yyyy-mm-dd'), '4300 Lakeville Road', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Jordan', 'Gray', TO_DATE('2006-4-3','yyyy-mm-dd'), '990 Route 5 20', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Dylan', 'Smith', TO_DATE('2005-12-14','yyyy-mm-dd'), '200 Dutch Meadows Ln', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Juan', 'Rivera', TO_DATE('2007-1-5','yyyy-mm-dd'), '1000 State Route 36', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Wayne', 'Davis', TO_DATE('2006-12-10','yyyy-mm-dd'), '1400 County Rd 64', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Louis', 'Bell', TO_DATE('2006-10-22','yyyy-mm-dd'), '233 5th Ave Ext', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Diana', 'Williams', TO_DATE('2006-6-15','yyyy-mm-dd'), '601 Frank Stottile Blvd', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO people (school_id,first_name,last_name,birth_date,address,city,region,postal_code,country) VALUES (3, 'Lori', 'White', TO_DATE('2007-1-11','yyyy-mm-dd'), '5783 So Transit Road', 'Manlius', 'NY', '13104', 'USA');
INSERT INTO teachers (person_id,subject_id,salary) VALUES (2, 1, 61068);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (3, 2, 53175);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (4, 3, 33885);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (5, 4, 48084);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (6, 5, 42117);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (43, 1, 55957);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (44, 2, 37390);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (45, 3, 42683);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (46, 4, 43583);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (47, 5, 53242);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (74, 1, 39913);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (75, 2, 48486);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (76, 3, 40720);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (77, 4, 46083);
INSERT INTO teachers (person_id,subject_id,salary) VALUES (78, 5, 49197);
INSERT INTO students (person_id,grade_level) VALUES (7, 6);
INSERT INTO students (person_id,grade_level) VALUES (8, 8);
INSERT INTO students (person_id,grade_level) VALUES (9, 8);
INSERT INTO students (person_id,grade_level) VALUES (10, 8);
INSERT INTO students (person_id,grade_level) VALUES (11, 6);
INSERT INTO students (person_id,grade_level) VALUES (12, 7);
INSERT INTO students (person_id,grade_level) VALUES (13, 8);
INSERT INTO students (person_id,grade_level) VALUES (14, 7);
INSERT INTO students (person_id,grade_level) VALUES (15, 7);
INSERT INTO students (person_id,grade_level) VALUES (16, 7);
INSERT INTO students (person_id,grade_level) VALUES (17, 7);
INSERT INTO students (person_id,grade_level) VALUES (18, 6);
INSERT INTO students (person_id,grade_level) VALUES (19, 7);
INSERT INTO students (person_id,grade_level) VALUES (20, 6);
INSERT INTO students (person_id,grade_level) VALUES (21, 7);
INSERT INTO students (person_id,grade_level) VALUES (22, 7);
INSERT INTO students (person_id,grade_level) VALUES (23, 8);
INSERT INTO students (person_id,grade_level) VALUES (24, 7);
INSERT INTO students (person_id,grade_level) VALUES (25, 7);
INSERT INTO students (person_id,grade_level) VALUES (26, 6);
INSERT INTO students (person_id,grade_level) VALUES (27, 7);
INSERT INTO students (person_id,grade_level) VALUES (28, 8);
INSERT INTO students (person_id,grade_level) VALUES (29, 8);
INSERT INTO students (person_id,grade_level) VALUES (30, 6);
INSERT INTO students (person_id,grade_level) VALUES (31, 7);
INSERT INTO students (person_id,grade_level) VALUES (32, 7);
INSERT INTO students (person_id,grade_level) VALUES (33, 7);
INSERT INTO students (person_id,grade_level) VALUES (34, 8);
INSERT INTO students (person_id,grade_level) VALUES (35, 7);
INSERT INTO students (person_id,grade_level) VALUES (36, 8);
INSERT INTO students (person_id,grade_level) VALUES (37, 6);
INSERT INTO students (person_id,grade_level) VALUES (38, 8);
INSERT INTO students (person_id,grade_level) VALUES (39, 7);
INSERT INTO students (person_id,grade_level) VALUES (40, 7);
INSERT INTO students (person_id,grade_level) VALUES (41, 7);
INSERT INTO students (person_id,grade_level) VALUES (48, 6);
INSERT INTO students (person_id,grade_level) VALUES (49, 7);
INSERT INTO students (person_id,grade_level) VALUES (50, 6);
INSERT INTO students (person_id,grade_level) VALUES (51, 8);
INSERT INTO students (person_id,grade_level) VALUES (52, 6);
INSERT INTO students (person_id,grade_level) VALUES (53, 6);
INSERT INTO students (person_id,grade_level) VALUES (54, 6);
INSERT INTO students (person_id,grade_level) VALUES (55, 7);
INSERT INTO students (person_id,grade_level) VALUES (56, 7);
INSERT INTO students (person_id,grade_level) VALUES (57, 7);
INSERT INTO students (person_id,grade_level) VALUES (58, 8);
INSERT INTO students (person_id,grade_level) VALUES (59, 7);
INSERT INTO students (person_id,grade_level) VALUES (60, 7);
INSERT INTO students (person_id,grade_level) VALUES (61, 7);
INSERT INTO students (person_id,grade_level) VALUES (62, 7);
INSERT INTO students (person_id,grade_level) VALUES (63, 7);
INSERT INTO students (person_id,grade_level) VALUES (64, 7);
INSERT INTO students (person_id,grade_level) VALUES (65, 7);
INSERT INTO students (person_id,grade_level) VALUES (66, 7);
INSERT INTO students (person_id,grade_level) VALUES (67, 8);
INSERT INTO students (person_id,grade_level) VALUES (68, 7);
INSERT INTO students (person_id,grade_level) VALUES (69, 6);
INSERT INTO students (person_id,grade_level) VALUES (70, 6);
INSERT INTO students (person_id,grade_level) VALUES (71, 7);
INSERT INTO students (person_id,grade_level) VALUES (72, 6);
INSERT INTO students (person_id,grade_level) VALUES (79, 8);
INSERT INTO students (person_id,grade_level) VALUES (80, 7);
INSERT INTO students (person_id,grade_level) VALUES (81, 7);
INSERT INTO students (person_id,grade_level) VALUES (82, 6);
INSERT INTO students (person_id,grade_level) VALUES (83, 8);
INSERT INTO students (person_id,grade_level) VALUES (84, 6);
INSERT INTO students (person_id,grade_level) VALUES (85, 7);
INSERT INTO students (person_id,grade_level) VALUES (86, 7);
INSERT INTO students (person_id,grade_level) VALUES (87, 8);
INSERT INTO students (person_id,grade_level) VALUES (88, 6);
INSERT INTO students (person_id,grade_level) VALUES (89, 7);
INSERT INTO students (person_id,grade_level) VALUES (90, 7);
INSERT INTO principals (person_id,salary) VALUES (1, 77237);
INSERT INTO principals (person_id,salary) VALUES (42, 78455);
INSERT INTO principals (person_id,salary) VALUES (73, 87537);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (1, 1, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (1, 1, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (2, 2, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (2, 2, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (3, 3, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (3, 3, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (4, 4, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (4, 4, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (5, 5, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (5, 5, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (6, 1, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (6, 1, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (7, 2, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (7, 2, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (8, 3, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (8, 3, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (9, 4, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (9, 4, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (10, 5, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (10, 5, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (11, 1, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (11, 1, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (12, 2, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (12, 2, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (13, 3, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (13, 3, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (14, 4, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (14, 4, 'spring', 2021);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (15, 5, 'fall', 2020);
INSERT INTO classrooms (teacher_id,subject_id,semester,year) VALUES (15, 5, 'spring', 2021);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (2, 1, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (3, 1, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (4, 1, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (5, 1, 65);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (7, 1, 98);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (8, 1, 98);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (9, 1, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (11, 1, 84);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (12, 1, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (16, 1, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (17, 1, 70);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (18, 1, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (19, 1, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (21, 1, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (27, 1, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (29, 1, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (30, 1, 63);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (33, 1, 67);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (1, 2, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (2, 2, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (3, 2, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (4, 2, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (6, 2, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (7, 2, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (8, 2, 95);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (9, 2, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (13, 2, 94);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (14, 2, 67);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (16, 2, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (17, 2, 94);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (18, 2, 65);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (20, 2, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (21, 2, 92);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (22, 2, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (25, 2, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (27, 2, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (28, 2, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (29, 2, 75);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (30, 2, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (31, 2, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (34, 2, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (2, 3, 67);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (3, 3, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (4, 3, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (5, 3, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (6, 3, 69);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (9, 3, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (10, 3, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (11, 3, 66);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (15, 3, 65);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (16, 3, 62);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (18, 3, 78);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (19, 3, 91);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (20, 3, 66);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (21, 3, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (22, 3, 84);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (23, 3, 78);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (24, 3, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (25, 3, 74);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (26, 3, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (27, 3, 92);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (28, 3, 91);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (31, 3, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (32, 3, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (2, 4, 70);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (5, 4, 95);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (7, 4, 73);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (9, 4, 83);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (10, 4, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (11, 4, 95);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (13, 4, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (14, 4, 80);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (15, 4, 82);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (20, 4, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (21, 4, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (22, 4, 74);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (23, 4, 67);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (24, 4, 75);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (28, 4, 85);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (30, 4, 91);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (31, 4, 82);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (32, 4, 82);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (33, 4, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (35, 4, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (2, 5, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (3, 5, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (6, 5, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (7, 5, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (9, 5, 83);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (12, 5, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (15, 5, 94);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (17, 5, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (18, 5, 80);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (19, 5, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (20, 5, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (21, 5, 74);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (22, 5, 80);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (23, 5, 83);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (24, 5, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (25, 5, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (29, 5, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (30, 5, 80);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (32, 5, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (33, 5, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (34, 5, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (35, 5, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (2, 6, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (3, 6, 98);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (7, 6, 78);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (9, 6, 62);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (11, 6, 66);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (12, 6, 78);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (13, 6, 66);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (17, 6, 78);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (18, 6, 62);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (20, 6, 83);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (21, 6, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (22, 6, 63);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (24, 6, 85);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (25, 6, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (29, 6, 70);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (30, 6, 73);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (31, 6, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (32, 6, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (33, 6, 71);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (5, 7, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (6, 7, 73);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (7, 7, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (8, 7, 67);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (9, 7, 91);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (10, 7, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (12, 7, 69);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (15, 7, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (16, 7, 73);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (17, 7, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (19, 7, 63);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (20, 7, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (21, 7, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (26, 7, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (29, 7, 60);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (30, 7, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (31, 7, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (32, 7, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (33, 7, 66);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (34, 7, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (35, 7, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (2, 8, 66);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (3, 8, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (5, 8, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (6, 8, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (7, 8, 71);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (10, 8, 75);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (11, 8, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (12, 8, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (13, 8, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (14, 8, 60);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (17, 8, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (19, 8, 63);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (20, 8, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (22, 8, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (24, 8, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (25, 8, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (26, 8, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (28, 8, 85);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (29, 8, 80);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (30, 8, 60);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (31, 8, 75);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (32, 8, 91);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (33, 8, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (35, 8, 94);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (1, 9, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (2, 9, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (3, 9, 69);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (6, 9, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (10, 9, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (12, 9, 69);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (14, 9, 95);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (15, 9, 67);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (18, 9, 73);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (19, 9, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (20, 9, 95);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (21, 9, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (22, 9, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (23, 9, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (25, 9, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (27, 9, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (28, 9, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (31, 9, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (32, 9, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (35, 9, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (1, 10, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (4, 10, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (6, 10, 84);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (8, 10, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (9, 10, 75);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (13, 10, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (20, 10, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (21, 10, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (22, 10, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (23, 10, 91);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (24, 10, 71);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (25, 10, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (27, 10, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (28, 10, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (29, 10, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (30, 10, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (31, 10, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (35, 10, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (37, 11, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (38, 11, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (39, 11, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (41, 11, 84);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (42, 11, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (43, 11, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (45, 11, 95);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (48, 11, 78);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (51, 11, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (52, 11, 71);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (54, 11, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (56, 11, 71);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (57, 11, 65);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (60, 11, 85);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (36, 12, 62);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (37, 12, 80);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (38, 12, 95);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (39, 12, 60);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (40, 12, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (41, 12, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (42, 12, 82);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (43, 12, 69);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (45, 12, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (46, 12, 92);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (47, 12, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (48, 12, 84);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (49, 12, 94);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (53, 12, 71);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (54, 12, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (55, 12, 71);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (56, 12, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (58, 12, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (36, 13, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (37, 13, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (40, 13, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (41, 13, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (42, 13, 74);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (43, 13, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (44, 13, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (46, 13, 73);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (47, 13, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (48, 13, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (49, 13, 84);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (52, 13, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (54, 13, 71);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (56, 13, 60);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (57, 13, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (58, 13, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (59, 13, 63);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (60, 13, 63);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (38, 14, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (41, 14, 84);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (44, 14, 63);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (45, 14, 82);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (47, 14, 60);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (48, 14, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (49, 14, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (50, 14, 75);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (54, 14, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (57, 14, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (58, 14, 82);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (36, 15, 71);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (38, 15, 75);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (39, 15, 80);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (40, 15, 78);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (41, 15, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (42, 15, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (44, 15, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (45, 15, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (47, 15, 63);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (48, 15, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (50, 15, 69);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (52, 15, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (53, 15, 60);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (55, 15, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (57, 15, 71);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (58, 15, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (59, 15, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (60, 15, 62);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (36, 16, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (38, 16, 78);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (39, 16, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (40, 16, 74);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (41, 16, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (43, 16, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (47, 16, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (50, 16, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (52, 16, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (53, 16, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (57, 16, 82);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (58, 16, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (60, 16, 62);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (36, 17, 62);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (37, 17, 91);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (39, 17, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (40, 17, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (41, 17, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (42, 17, 65);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (46, 17, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (47, 17, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (48, 17, 92);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (49, 17, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (50, 17, 73);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (51, 17, 69);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (54, 17, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (56, 17, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (57, 17, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (58, 17, 60);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (59, 17, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (60, 17, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (37, 18, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (38, 18, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (40, 18, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (41, 18, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (43, 18, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (44, 18, 70);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (45, 18, 91);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (47, 18, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (48, 18, 73);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (49, 18, 82);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (52, 18, 74);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (53, 18, 82);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (55, 18, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (56, 18, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (57, 18, 74);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (59, 18, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (60, 18, 98);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (36, 19, 73);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (37, 19, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (38, 19, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (39, 19, 75);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (42, 19, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (43, 19, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (44, 19, 67);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (45, 19, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (46, 19, 62);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (48, 19, 65);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (49, 19, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (50, 19, 67);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (54, 19, 84);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (55, 19, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (58, 19, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (60, 19, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (36, 20, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (37, 20, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (41, 20, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (42, 20, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (43, 20, 60);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (45, 20, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (47, 20, 67);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (48, 20, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (49, 20, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (51, 20, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (53, 20, 60);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (55, 20, 80);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (56, 20, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (57, 20, 90);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (58, 20, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (59, 20, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (63, 21, 92);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (64, 21, 99);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (65, 21, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (66, 21, 92);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (67, 21, 66);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (69, 21, 74);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (70, 21, 100);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (61, 22, 98);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (63, 22, 89);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (64, 22, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (65, 22, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (67, 22, 84);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (69, 22, 73);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (70, 22, 83);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (72, 22, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (61, 23, 97);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (65, 23, 66);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (68, 23, 67);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (71, 23, 61);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (72, 23, 94);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (63, 24, 74);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (64, 24, 91);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (65, 24, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (68, 24, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (69, 24, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (70, 24, 83);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (71, 24, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (61, 25, 86);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (64, 25, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (65, 25, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (67, 25, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (68, 25, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (70, 25, 62);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (71, 25, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (61, 26, 78);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (62, 26, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (64, 26, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (66, 26, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (67, 26, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (68, 26, 69);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (70, 26, 93);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (72, 26, 83);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (61, 27, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (63, 27, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (65, 27, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (66, 27, 77);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (67, 27, 88);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (69, 27, 64);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (70, 27, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (71, 27, 74);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (63, 28, 82);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (64, 28, 62);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (66, 28, 75);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (67, 28, 70);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (68, 28, 70);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (69, 28, 94);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (70, 28, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (71, 28, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (62, 29, 69);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (63, 29, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (66, 29, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (67, 29, 96);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (69, 29, 66);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (70, 29, 84);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (61, 30, 81);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (63, 30, 68);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (64, 30, 95);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (65, 30, 72);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (67, 30, 87);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (68, 30, 69);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (69, 30, 79);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (70, 30, 76);
INSERT INTO classroom_students (student_id, classroom_id, grade) VALUES (72, 30, 64);
