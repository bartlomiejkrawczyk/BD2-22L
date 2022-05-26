-- Generated by Oracle SQL Developer Data Modeler 21.4.2.059.0838
--   at:        2022-05-25 22:02:56 CEST
--   site:      Oracle Database 21c
--   type:      Oracle Database 21c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE OR REPLACE PROCEDURE BD2C049.PREF_SEQUENCE_SWAP(
        p_candidate_id NUMBER
    ,   p_registration_code VARCHAR2
    ,   p_first_course_code VARCHAR2
    ,   p_first_new_number NUMBER
    ,   p_second_course_code VARCHAR2
    ,   p_second_new_number NUMBER
) AS
    v_preference preferences%ROWTYPE;
BEGIN
    EXECUTE IMMEDIATE 'SET CONSTRAINT pref_sequential_number_uk DEFERRED';

    UPDATE  preferences
    SET     sequential_number = p_first_new_number
    WHERE   candidate_id = p_candidate_id
        AND registration_code = p_registration_code
        AND course_code = p_first_course_code
        AND sequential_number = p_second_new_number;
    
    UPDATE  preferences
    SET     sequential_number = p_second_new_number
    WHERE   candidate_id = p_candidate_id
        AND registration_code = p_registration_code
        AND course_code = p_second_course_code
        AND sequential_number = p_first_new_number;

    EXECUTE IMMEDIATE 'SET CONSTRAINT pref_sequential_number_uk IMMEDIATE';
END;
/


GRANT EXECUTE
ON BD2C049.PREF_SEQUENCE_SWAP TO BD2C049_APP 
;



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                             0
-- CREATE INDEX                             0
-- ALTER TABLE                              0
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         1
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
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
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
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
