CREATE VIEW classroom_students_view AS
SELECT ps.first_name || ' ' || ps.last_name AS student, cs.grade,
      pt.first_name || ' ' || pt.last_name AS teacher,
      s.subject, c.semester, c.year
FROM people ps
  JOIN students s ON ps.person_id = s.person_id
  JOIN classroom_students cs ON s.student_id = cs.student_id
  JOIN classrooms c ON c.classroom_id = cs.classroom_id
  JOIN subjects s ON s.subject_id = c.subject_id
  JOIN teachers t ON t.teacher_id = c.teacher_id
  JOIN people pt ON pt.person_id = t.person_id;
