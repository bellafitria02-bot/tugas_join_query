-- Active: 1758854656872@@127.0.0.1@3306@tugas

#Bella Fitria Mukhlis 

-- Departemen / Prodi
CREATE TABLE departments (
    dept_id INT PRIMARY KEY, 
    dept_name VARCHAR(100)
);

-- Mahasiswa
CREATE TABLE students (
    student_id INT PRIMARY KEY, 
    student_name VARCHAR(100), 
    entry_year INT, 
    dept_id INT, 
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Dosen
CREATE TABLE lecturers (
    lect_id INT PRIMARY KEY, 
    lect_name VARCHAR(100), 
    dept_id INT, 
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Mata kuliah
CREATE TABLE courses (
    course_id INT PRIMARY KEY, 
    course_code VARCHAR(20) UNIQUE, 
    course_title VARCHAR(150), 
    credits INT, 
    dept_id INT, 
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Kelas (penyelenggaraan MK per semester & dosen)
CREATE TABLE classes (
    class_id INT PRIMARY KEY, 
    course_id INT, 
    lect_id INT, 
    semester VARCHAR(10), -- misal: '2025-1'
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (lect_id) REFERENCES lecturers(lect_id)
);  

-- Ruang
CREATE TABLE rooms (
    room_id INT PRIMARY KEY, 
    room_name VARCHAR(50), 
    capacity INT
);

-- Jadwal kelas di ruang
CREATE TABLE schedules (
    schedule_id INT PRIMARY KEY, 
    class_id INT, 
    room_id INT, 
    day_of_week VARCHAR(10), -- Mon..Sun (silakan sesuaikan)
    start_time TIME, 
    end_time TIME, 
    FOREIGN KEY (class_id) REFERENCES classes(class_id), 
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

-- KRS (relasi many-to-many mhs <-> kelas)
CREATE TABLE enrollments (
    student_id INT,
    class_id INT, 
    grade VARCHAR(2), -- contoh: 'A','B','C', NULL bila belum nilai
    PRIMARY KEY (student_id, class_id), 
    FOREIGN KEY (student_id) REFERENCES students(student_id), 
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
);

-- Prasyarat MK (self-join pada courses)
CREATE TABLE prerequisites (
    course_id INT, 
    prereq_id INT, 
    PRIMARY KEY (course_id, prereq_id), 
    FOREIGN KEY (course_id) REFERENCES courses(course_id), 
    FOREIGN KEY (prereq_id) REFERENCES courses(course_id)
);

-- Hierarki dosen (self-join lecturers: atasan/pembina)
CREATE TABLE lecturer_supervisions (
    lect_id INT, 
    supervisor_id INT, 
    PRIMARY KEY (lect_id, supervisor_id), 
    FOREIGN KEY (lect_id) REFERENCES lecturers(lect_id), 
    FOREIGN KEY (supervisor_id) REFERENCES lecturers(lect_id)
);

INSERT INTO departments VALUES
(10,'Sistem Informasi Kelautan'), 
(20,'Ilmu Komputer'), 
(30,'Biologi Kelautan');

INSERT INTO students VALUES
(2103118,'Roni Antonius Sinabutar',2021,10), 
(2103120,'Salsa Aurelia',2021,10),
(2204101,'Rakhil Syakira Yusuf',2022,10), 
(2205205,'Adit Pratama',2022,20), 
(2306102,'Nadia Putri',2023,20), 
(2307107,'Bima Mahesa',2023,30);

INSERT INTO lecturers VALUES
(501, 'Willdan',10), 
(502,'Supriadi',10), 
(503,'Ayang',20), 
(504,'Alam',30), 
(505,'Luthfi',10);

INSERT INTO courses VALUES
(1001,'KL202','Algoritma & Pemrograman',3,10), 
(1002,'KL218','Sistem Basis Data',3,10),
(1003,'CS101','Pengantar Ilmu Komputer',2,20), 
(1004,'CS205','Basis Data Lanjut',3,20),
(1005,'MB110','Biologi Laut Dasar',2,30), 
(1006,'KL305','SIG Kelautan',3,10);

INSERT INTO classes VALUES
(9001,1002,501,'2025-1'), -- SBD oleh Willdan
(9002,1001,502,'2025-1'), -- Algo oleh Supriadi
(9003,1003,503,'2025-1'), -- Pengantar IK oleh Ayang
(9004,1005,504,'2025-1'), -- Biologi Laut Dasar oleh Alam
(9005,1004,503,'2025-1'), -- Basis Data Lanjut oleh Ayang
(9006,1006,505,'2025-1'); -- SIG Kelautan oleh Luthfi

INSERT INTO rooms VALUES
(1,'Lab Big Data',30), 
(2,'Ruang Kuliah 201',40), 
(3,'Lab Komputasi 1',25), 
(4,'Aula 3',100);

INSERT INTO schedules VALUES
(7001,9001,3,'Monday','08:00','10:30'), 
(7002,9002,2,'Tuesday','10:00','12:00'), 
(7003,9003,2,'Wednesday','08:00','10:00'), 
(7004,9004,4,'Thursday','13:00','15:00'), 
(7005,9005,3,'Friday','09:00','11:30'), 
(7006,9006,1,'Monday','13:00','15:30');

INSERT INTO enrollments VALUES
(2103118,9001,'A'), 
(2103118,9002,'B'), 
(2103120,9001,'B'), 
(2103120,9006,'A'), 
(2204101,9001,NULL), 
(2204101,9005,NULL), 
(2205205,9003,'A'), 
(2306102,9003,'B'), 
(2306102,9005,NULL), 
(2307107,9004,'A');

INSERT INTO prerequisites VALUES
(1004,1002), -- Basis Data Lanjut mensyaratkan Sistem Basis Data
(1006,1001); -- SIG Kelautan mensyaratkan Algoritma & Pemrograman

INSERT INTO lecturer_supervisions VALUES
(501,505), -- Willdan dibina oleh Luthfi
(502,501), -- Supriadi dibina oleh Willdan
(503,501), -- Ayang dibina oleh Willdan
(504,505); -- Alam dibina oleh Luthfi


#INNER JOIN 1. Nama mahasiswa dan nama departemennya.
SELECT s.student_name, d.dept_name
FROM students s
INNER JOIN departments d ON s.dept_id = d.dept_id;

#INNER JOIN 2. Daftar kelas beserta mata kuliah dan dosen pengajarnya.
SELECT c.class_id, cr.course_title, l.lect_name
FROM classes c
INNER JOIN courses cr ON c.course_id = cr.course_id
INNER JOIN lecturers l ON c.lect_id = l.lect_id;

#INNER JOIN 3. Mahasiswa yang mengambil kelas ‘Sistem Basis Data’ (1002).
SELECT s.student_name, cr.course_title
FROM enrollments e
INNER JOIN classes c ON e.class_id = c.class_id
INNER JOIN courses cr ON c.course_id = cr.course_id
INNER JOIN students s ON e.student_id = s.student_id
WHERE cr.course_id = 1002;

#INNER JOIN 4. Jadwal lengkap kelas (hari, jam, ruang) untuk tiap mata kuliah.
SELECT cr.course_title, sch.day_of_week, sch.start_time, sch.end_time, r.room_name
FROM schedules sch
INNER JOIN classes c ON sch.class_id = c.class_id
INNER JOIN courses cr ON c.course_id = cr.course_id
INNER JOIN rooms r ON sch.room_id = r.room_id;

#INNER JOIN+GROUP 5. Jumlah mahasiswa per departemen yang terdaftar di semester ‘2025-1’.
SELECT d.dept_name, COUNT(DISTINCT e.student_id) AS total_mahasiswa
FROM enrollments e
INNER JOIN classes c ON e.class_id = c.class_id
INNER JOIN students s ON e.student_id = s.student_id
INNER JOIN departments d ON s.dept_id = d.dept_id
WHERE c.semester = '2025-1'
GROUP BY d.dept_name;

#INNER JOIN 6. Kelas yang diajar oleh dosen satu departemen dengan mata kuliah yang diajarkan.
SELECT c.class_id, l.lect_name, cr.course_title
FROM classes c
INNER JOIN lecturers l ON c.lect_id = l.lect_id
INNER JOIN courses cr ON c.course_id = cr.course_id
WHERE l.dept_id = cr.dept_id;

#INNER JOIN 7. Mahasiswa SIK (dept 10) yang mengambil kelas di luar dept-nya. 
SELECT DISTINCT s.student_name, cr.course_title
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN classes c ON e.class_id = c.class_id
INNER JOIN courses cr ON c.course_id = cr.course_id
WHERE s.dept_id = 10 AND cr.dept_id <> 10;

#LEFT JOIN 8. Mata kuliah beserta prasyaratnya.
SELECT c1.course_title AS mata_kuliah, c2.course_title AS prasyarat
FROM courses c1
LEFT JOIN prerequisites p ON c1.course_id = p.course_id
LEFT JOIN courses c2 ON p.prereq_id = c2.course_id;

#LEFT JOIN 9. Daftar dosen dan dosen pembinanya. 
SELECT l.lect_name AS dosen, s.lect_name AS pembina
FROM lecturers l
LEFT JOIN lecturer_supervisions ls ON l.lect_id = ls.lect_id
LEFT JOIN lecturers s ON ls.supervisor_id = s.lect_id;

#INNER JOIN 10. Kelas yang belum memiliki nilai (grade NULL).
SELECT DISTINCT c.class_id, cr.course_title
FROM enrollments e
INNER JOIN classes c ON e.class_id = c.class_id
INNER JOIN courses cr ON c.course_id = cr.course_id
WHERE e.grade IS NULL;

#LEFT JOIN 11. Mahasiswa yang tidak mengambil kelas ‘SIG Kelautan’ (1006). 
SELECT s.student_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN classes c ON e.class_id = c.class_id AND c.course_id = 1006
WHERE s.dept_id = (SELECT dept_id FROM courses WHERE course_id = 1006)
AND c.class_id IS NULL;

#INNER JOIN 12. Jumlah kelas per hari dan total kapasitas ruang.
SELECT sch.day_of_week, COUNT(DISTINCT sch.class_id) AS jumlah_kelas,
       SUM(r.capacity) AS total_kapasitas
FROM schedules sch
INNER JOIN rooms r ON sch.room_id = r.room_id
GROUP BY sch.day_of_week;

#INNER JOIN 13. Daftar mahasiswa dan total SKS yang sedang ditempuh.
SELECT s.student_name, SUM(cr.credits) AS total_sks
FROM enrollments e
INNER JOIN classes c ON e.class_id = c.class_id
INNER JOIN courses cr ON c.course_id = cr.course_id
INNER JOIN students s ON e.student_id = s.student_id
GROUP BY s.student_name;

#INNER JOIN 14. Mata kuliah lintas prodi.
SELECT c.class_id, cr.course_title, l.lect_name
FROM classes c
INNER JOIN courses cr ON c.course_id = cr.course_id
INNER JOIN lecturers l ON c.lect_id = l.lect_id
WHERE cr.dept_id <> l.dept_id;

#INNER JOIN 15. Kelas + jumlah peserta & status “PENUH”.
SELECT c.class_id, cr.course_title, COUNT(e.student_id) AS peserta,
       r.capacity,
       CASE WHEN COUNT(e.student_id) >= r.capacity THEN 'PENUH' ELSE 'TERSEDIA' END AS status_kelas
FROM enrollments e
INNER JOIN classes c ON e.class_id = c.class_id
INNER JOIN schedules sch ON sch.class_id = c.class_id
INNER JOIN rooms r ON sch.room_id = r.room_id
INNER JOIN courses cr ON c.course_id = cr.course_id
GROUP BY c.class_id, cr.course_title, r.capacity;

#INNER JOIN 16. Riwayat KRS semester ‘2025-1’.
SELECT s.student_name, cr.course_code, cr.course_title
FROM enrollments e
INNER JOIN classes c ON e.class_id = c.class_id
INNER JOIN courses cr ON c.course_id = cr.course_id
INNER JOIN students s ON e.student_id = s.student_id
WHERE c.semester = '2025-1'
ORDER BY s.student_name, cr.course_code;

#INNER JOIN 17. Mata kuliah yang menjadi prasyarat untuk mata kuliah lain. 
SELECT DISTINCT c2.course_title AS mata_kuliah
FROM prerequisites p
INNER JOIN courses c2 ON p.prereq_id = c2.course_id;

#INNER JOIN 18. Dosen pembina beserta jumlah dosen yang dibinanya. 
SELECT s.lect_name AS pembina, COUNT(ls.lect_id) AS jumlah_binaan
FROM lecturer_supervisions ls
INNER JOIN lecturers s ON ls.supervisor_id = s.lect_id
GROUP BY s.lect_name;

#INNER JOIN 19. Mahasiswa + kelas + ruang jika kelasnya hari ‘Monday’. 
SELECT s.student_name, cr.course_title, r.room_name
FROM enrollments e
INNER JOIN classes c ON e.class_id = c.class_id
INNER JOIN schedules sch ON sch.class_id = c.class_id
INNER JOIN courses cr ON c.course_id = cr.course_id
INNER JOIN rooms r ON sch.room_id = r.room_id
INNER JOIN students s ON e.student_id = s.student_id
WHERE sch.day_of_week = 'Monday';

#INNER JOIN 20. Mata kuliah yang diambil mahasiswa dari departemen berbeda. 
SELECT DISTINCT s.student_name, cr.course_title
FROM enrollments e
INNER JOIN classes c ON e.class_id = c.class_id
INNER JOIN courses cr ON c.course_id = cr.course_id
INNER JOIN students s ON e.student_id = s.student_id
WHERE s.dept_id <> cr.dept_id;

#LEFT JOIN 21. Semua dosen beserta kelas yang diajar. 
SELECT l.lect_name, c.class_id, cr.course_title
FROM lecturers l
LEFT JOIN classes c ON l.lect_id = c.lect_id
LEFT JOIN courses cr ON c.course_id = cr.course_id;

#LEFT JOIN 22. Semua mata kuliah beserta kelasnya pada semester ‘2025-1’. 
SELECT cr.course_title, c.class_id, c.semester
FROM courses cr
LEFT JOIN classes c ON cr.course_id = c.course_id AND c.semester = '2025-1';

#LEFT JOIN 23. Pasangan mata kuliah & prasyaratnya (termasuk yang tidak punya). 
SELECT c1.course_title AS mata_kuliah, c2.course_title AS prasyarat
FROM courses c1
LEFT JOIN prerequisites p ON c1.course_id = p.course_id
LEFT JOIN courses c2 ON p.prereq_id = c2.course_id;

#INNER JOIN 24. Mahasiswa yang mengambil kelas dosen pembinanya. 
SELECT DISTINCT s.student_name, l.lect_name AS dosen, sup.lect_name AS pembina
FROM enrollments e
INNER JOIN classes c ON e.class_id = c.class_id
INNER JOIN lecturers l ON c.lect_id = l.lect_id
INNER JOIN lecturer_supervisions ls ON l.lect_id = ls.lect_id
INNER JOIN lecturers sup ON ls.supervisor_id = sup.lect_id
INNER JOIN students s ON e.student_id = s.student_id;

#INNER JOIN 25. Cek bentrok ruang: ruang sama, hari sama, waktu tumpang tindih. 
SELECT s1.class_id AS kelas1, s2.class_id AS kelas2, s1.day_of_week, r.room_name
FROM schedules s1
INNER JOIN schedules s2 ON s1.room_id = s2.room_id
  AND s1.day_of_week = s2.day_of_week
  AND s1.class_id < s2.class_id
  AND (
    (s1.start_time BETWEEN s2.start_time AND s2.end_time)
    OR (s2.start_time BETWEEN s1.start_time AND s1.end_time)
  )
INNER JOIN rooms r ON s1.room_id = r.room_id;