CREATE SCHEMA IF NOT EXISTS HW
    DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

USE HW;

CREATE TABLE IF NOT EXISTS admin (
    admin_id    CHAR(10),
    password    CHAR(32),
    PRIMARY KEY (admin_id)
);

CREATE TABLE IF NOT EXISTS teacher (
    teacher_id  CHAR(10),
    password    CHAR(32),
    name        VARCHAR(40),
    PRIMARY KEY (teacher_id)
);

CREATE TABLE IF NOT EXISTS student (
    student_id  CHAR(10),
    password    CHAR(32),
    name        VARCHAR(40),
    PRIMARY KEY (student_id)
);

CREATE TABLE IF NOT EXISTS course (
    course_id   CHAR(10),
    name        VARCHAR(40),
    teacher_id  CHAR(10),
    PRIMARY KEY (course_id)
);

CREATE TABLE IF NOT EXISTS election (
    course_id   CHAR(10),
    student_id  CHAR(10)
);
