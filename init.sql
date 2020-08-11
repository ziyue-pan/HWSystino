CREATE SCHEMA IF NOT EXISTS HW
    DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

USE HW;

CREATE TABLE IF NOT EXISTS admin (
    admin_id    CHAR(10) PRIMARY KEY,
    password    CHAR(32)
);

CREATE TABLE IF NOT EXISTS teacher (
    teacher_id  CHAR(10) PRIMARY KEY,
    password    CHAR(32),
    name        VARCHAR(40)
);

CREATE TABLE IF NOT EXISTS student (
    student_id  CHAR(10) PRIMARY KEY,
    password    CHAR(32),
    name        VARCHAR(40)
);

CREATE TABLE IF NOT EXISTS course (
    course_id   CHAR(10),
    name        VARCHAR(40),
    PRIMARY KEY (course_id)
);

CREATE TABLE IF NOT EXISTS binding (
    course_id   CHAR(10),
    teacher_id  CHAR(10)
);

CREATE TABLE IF NOT EXISTS election (
    course_id   CHAR(10),
    student_id  CHAR(10)
);

CREATE TABLE IF NOT EXISTS homework (
    course_id   CHAR(10),
    create_time DATETIME,
    title       VARCHAR(40),
    description TEXT
);

CREATE TABLE IF NOT EXISTS information (
    course_id   CHAR(10),
    create_time DATETIME,
    title       VARCHAR(40),
    description TEXT
);

CREATE TABLE IF NOT EXISTS homework_handin (
    course_id   CHAR(10),
    student_id  CHAR(10),
    create_time DATETIME,
    complete    BOOLEAN,
    content     TEXT
);

INSERT IGNORE INTO admin VALUES('admin', 'admin');