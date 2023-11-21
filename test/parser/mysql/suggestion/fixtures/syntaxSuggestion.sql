INSERT INTO db.tb ;

SELECT * FROM db.;

CREATE TABLE db. VALUES;

DROP TABLE IF EXISTS db.a;

CREATE OR REPLACE VIEW db.v;

DROP VIEW db.v;

CREATE FUNCTION fn1;

SELECT name, calculate_age(birthday) AS age FROM students;

CREATE DATABASE db;

DROP SCHEMA IF EXISTS sch;

SELECT name, age FROM students;

ALTER TABLE t1 ADD c2 INT GENERATED ALWAYS AS (c1 + 1) STORED;

ANALYZE TABLE t UPDATE HISTOGRAM ON c1, c2, c3 WITH 10 BUCKETS;
