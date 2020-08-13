USE HW;

DELETE FROM course;
INSERT INTO course VALUES('001', 'Linux');
INSERT INTO course VALUES('002', 'Database');
INSERT INTO course VALUES('003', 'Algorithm');
INSERT INTO course VALUES('004', 'Python');

DELETE FROM teacher;
INSERT INTO teacher VALUES('001', '001', 'Pan Ziyue');
INSERT INTO teacher VALUES('002', '002', 'Ji Jiangmin');
INSERT INTO teacher VALUES('003', '003', 'Chen Yue');
INSERT INTO teacher VALUES('004', '004', 'Wu Zhaohui');
INSERT INTO teacher VALUES('005', '005', 'SHi Qingsong');

DELETE FROM binding;
INSERT INTO binding VALUES('001', '002');   # Linux     -   Ji Jiangmin
INSERT INTO binding VALUES('003', '003');   # Algorithm -   Chen Yue
INSERT INTO binding VALUES('002', '001');   # Database  -   Pan Ziyue

DELETE FROM student;
INSERT INTO student VALUES('stu001', 'stu001', 'A');
INSERT INTO student VALUES('stu002', 'stu002', 'B');
INSERT INTO student VALUES('stu003', 'stu003', 'C');
INSERT INTO student VALUES('stu004', 'stu004', 'D');
INSERT INTO student VALUES('stu005', 'stu005', 'E');
INSERT INTO student VALUES('stu006', 'stu006', 'F');
INSERT INTO student VALUES('stu007', 'stu007', 'G');

DELETE FROM election;
INSERT INTO election VALUES('001', 'stu001');
INSERT INTO election VALUES('001', 'stu002');
INSERT INTO election VALUES('001', 'stu003');
INSERT INTO election VALUES('001', 'stu004');
INSERT INTO election VALUES('002', 'stu005');
INSERT INTO election VALUES('002', 'stu006');
INSERT INTO election VALUES('002', 'stu007');

DELETE FROM information;
INSERT INTO information VALUES('001', NOW(), 'Hello Linux', 'This is a piece of information about Linux course');
INSERT INTO information VALUES('002', NOW(), 'Using MySQL', 'This project is completed with MySQL');
INSERT INTO information VALUES('002', NOW(), 'How to use', 'Please follow your heart');

DELETE FROM homework;