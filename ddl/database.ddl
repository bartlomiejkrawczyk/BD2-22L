-- Generated by Oracle SQL Developer Data Modeler 21.4.2.059.0838
--   at:        2022-05-19 16:22:54 CEST
--   site:      Oracle Database 21c
--   type:      Oracle Database 21c



CREATE USER bd2c049 IDENTIFIED BY ACCOUNT UNLOCK ;

CREATE USER bd2c049_app IDENTIFIED BY ACCOUNT UNLOCK ;


CREATE SEQUENCE CAND_ID_SEQ 
START WITH 10000  MAXVALUE 9999999;

GRANT SELECT ON cand_id_seq TO bd2c049_app;

-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE candidates (
    candidate_id     NUMBER(7) DEFAULT ON NULL cand_id_seq.NEXTVAL NOT NULL,
    email            VARCHAR2(100 BYTE) NOT NULL,
    birth_date       DATE NOT NULL,
    first_name       VARCHAR2(20 BYTE) NOT NULL,
    family_name      VARCHAR2(25 BYTE) NOT NULL,
    country          VARCHAR2(50 BYTE) NOT NULL,
    city             VARCHAR2(50 BYTE) NOT NULL,
    postal_code      VARCHAR2(10 BYTE) NOT NULL,
    home_number      VARCHAR2(6 BYTE) NOT NULL,
    pesel            CHAR(11),
    phone_number     VARCHAR2(13 BYTE),
    second_name      VARCHAR2(20 BYTE),
    voivodeship      VARCHAR2(50 BYTE),
    street           VARCHAR2(80 BYTE),
    apartment_number VARCHAR2(5 BYTE)
)
LOGGING;

COMMENT ON TABLE candidates IS
    'Contains registered candidates, who can apply for up to three university courses every registration.
Stores personal information about candidates.';

GRANT DELETE, INSERT, SELECT, UPDATE ON candidates TO bd2c049_app;

ALTER TABLE candidates ADD CONSTRAINT cand_pk PRIMARY KEY ( candidate_id );

ALTER TABLE candidates ADD CONSTRAINT cand_email_uk UNIQUE ( email );

ALTER TABLE candidates ADD CONSTRAINT cand_pesel_uk UNIQUE ( pesel );

CREATE TABLE courses (
    course_code VARCHAR2(6 BYTE) NOT NULL,
    name        VARCHAR2(100 BYTE) NOT NULL,
    degree      CHAR(1) NOT NULL,
    description VARCHAR2(4000 BYTE)
)
LOGGING;

ALTER TABLE courses
    ADD CONSTRAINT crs_chk_code_upper CHECK ( course_code = upper(course_code) );

ALTER TABLE courses
    ADD CONSTRAINT crs_chk_degree CHECK ( degree IN ( 'B', 'E', 'M', 'D' ) );

COMMENT ON TABLE courses IS
    'Serves as a dictionary of available courses.
Stores basic information about the course for candidates wondering which course to choose.';

COMMENT ON COLUMN courses.course_code IS
    'Code that can distinguish a given course e.g.
CS - short name for Computer Science 

Course code must be in uppercase.';

COMMENT ON COLUMN courses.degree IS
    'Academic degree achieved after passing the course:
B - Bachelor''s degree
E - Engineer''s degree
M - Master''s degree
D - Doctoral degree';

COMMENT ON COLUMN courses.description IS
    'Description of what students can expect from selected course.';

GRANT DELETE, INSERT, SELECT, UPDATE ON courses TO bd2c049_app;

ALTER TABLE courses ADD CONSTRAINT crs_pk PRIMARY KEY ( course_code );

ALTER TABLE courses ADD CONSTRAINT crs_name_uk UNIQUE ( name );

CREATE TABLE offers (
    registration_code VARCHAR2(5 BYTE) NOT NULL,
    course_code       VARCHAR2(6 BYTE) NOT NULL,
    available_slots   NUMBER(4) NOT NULL
)
LOGGING;

ALTER TABLE offers ADD CONSTRAINT ofr_chk_available_slots CHECK ( available_slots >= 0 );

COMMENT ON TABLE offers IS
    'Links courses with registration.
It allows to determine the availability of the selected course in a given registration.
Furthermore it specifies the number of available slots for a given course.';

COMMENT ON COLUMN offers.available_slots IS
    'The maximum number of people university can register on the course.';

CREATE INDEX ofr_crs_idx ON
    offers (
        course_code
    ASC )
        LOGGING;

GRANT DELETE, INSERT, SELECT, UPDATE ON offers TO bd2c049_app;

ALTER TABLE offers ADD CONSTRAINT ofr_pk PRIMARY KEY ( registration_code,
                                                       course_code );

CREATE TABLE preferences (
    registration_code VARCHAR2(5 BYTE) NOT NULL,
    course_code       VARCHAR2(6 BYTE) NOT NULL,
    candidate_id      NUMBER(7) NOT NULL,
    sequential_number NUMBER(1) NOT NULL,
    result            CHAR(1 BYTE),
    points            NUMBER(5, 2)
)
LOGGING;

ALTER TABLE preferences
    ADD CONSTRAINT pref_chk_sequential_number CHECK ( sequential_number BETWEEN 1 AND 3 );

ALTER TABLE preferences
    ADD CONSTRAINT pref_chk_result CHECK ( result IN ( 'Y', 'N', 'R' )
                                           OR result IS NULL );

COMMENT ON TABLE preferences IS
    'Stores candidate''s preferences.
Every candidate can apply for up to 3 distinct courses every registration.
Candidate can order his preferences from best to worst (from the chosen set).

To change the choosen offer candidate must delete unwanted choice and replace it with another one.

When registration starts candidates can start applying for courses available during registration.
After registration ends preferences for offers included in the registration cannot be changed by the candidate.
Based on the final implementation results will be generated autmoatically or by administration.
After registration ends only the administration should be able to update the preferences.';

COMMENT ON COLUMN preferences.sequential_number IS
    'Number representing sequence of candidate''s preferences.
The selections with the lowest value are considered first.
Sequential number must be an integer from range [1;3].';

COMMENT ON COLUMN preferences.result IS
    'Result of registration on that course.
NULL- no results available yet
Y - candidate got in
R - candidate is on the reserve list
N - candidate didn''t get in';

COMMENT ON COLUMN preferences.points IS
    'The number of points scored by candidate for a given course.';

GRANT DELETE, INSERT, SELECT, UPDATE ON preferences TO bd2c049_app;

ALTER TABLE preferences
    ADD CONSTRAINT pref_pk PRIMARY KEY ( registration_code,
                                         course_code,
                                         candidate_id );

ALTER TABLE preferences
    ADD CONSTRAINT pref_sequential_number_uk UNIQUE ( candidate_id,
                                                      registration_code,
                                                      sequential_number ) 
                                                      DEFERRABLE
                                                      INITIALLY IMMEDIATE;

CREATE TABLE registrations (
    registration_code VARCHAR2(5 BYTE) NOT NULL,
    start_date        DATE NOT NULL,
    end_date          DATE NOT NULL
)
LOGGING;

ALTER TABLE registrations
    ADD CONSTRAINT reg_chk_code_upper CHECK ( registration_code = upper(registration_code) );

COMMENT ON TABLE registrations IS
    'Serves as a dictionary of available registrations.
There can be multiple registrations a year.
The interval between start and end indicates when the registration is open and when the candidates can apply for offers.';

COMMENT ON COLUMN registrations.registration_code IS
    'Code that can distinguish a given registration e.g. 
22S - last two digits of the year (2022) + first letter of the season (Summer)

Registration Code must be in uppercase.';

COMMENT ON COLUMN registrations.start_date IS
    'Date when registration opens.';

COMMENT ON COLUMN registrations.end_date IS
    'Date when registration closes.';

GRANT DELETE, INSERT, SELECT, UPDATE ON registrations TO bd2c049_app;

ALTER TABLE registrations ADD CONSTRAINT reg_chk_start_before_end CHECK ( start_date < end_date );

ALTER TABLE registrations ADD CONSTRAINT reg_pk PRIMARY KEY ( registration_code );

ALTER TABLE offers
    ADD CONSTRAINT ofr_crs_fk FOREIGN KEY ( course_code )
        REFERENCES courses ( course_code )
    DEFERRABLE;

ALTER TABLE offers
    ADD CONSTRAINT ofr_reg_fk FOREIGN KEY ( registration_code )
        REFERENCES registrations ( registration_code )
    DEFERRABLE;

ALTER TABLE preferences
    ADD CONSTRAINT pref_cand_fk FOREIGN KEY ( candidate_id )
        REFERENCES candidates ( candidate_id )
            ON DELETE CASCADE
    DEFERRABLE;

ALTER TABLE preferences
    ADD CONSTRAINT pref_ofr_fk FOREIGN KEY ( registration_code,
                                             course_code )
        REFERENCES offers ( registration_code,
                            course_code )
    DEFERRABLE;

CREATE OR REPLACE TRIGGER fkntm_offers BEFORE
    UPDATE OF registration_code, course_code ON offers
    FOR EACH ROW
    WHEN (NEW.registration_code != OLD.registration_code OR NEW.course_code != OLD.course_code)
BEGIN
    raise_application_error(-20225, 'Non Transferable FK constraint  on table OFFERS is violated');
END;
/

CREATE OR REPLACE TRIGGER fkntm_preferences BEFORE
    UPDATE OF candidate_id, registration_code, course_code ON preferences
    FOR EACH ROW
    WHEN(NEW.candidate_id != OLD.candidate_id OR NEW.registration_code != OLD.registration_code OR NEW.course_code != old.course_code)
BEGIN
    raise_application_error(-20225, 'Non Transferable FK constraint  on table PREFERENCES is violated');
END;
/




-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                             5
-- CREATE INDEX                             1
-- ALTER TABLE                             20
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           2
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          1
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              2
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
