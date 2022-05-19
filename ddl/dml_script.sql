set echo on
set linesize 300
set pagesize 500
spool BD2C049_DML.LIS

SAVEPOINT before_tests;

--------------------------------------------------------------------------------
--                          TEST INSERT ON CANDIDATES                         --
--------------------------------------------------------------------------------

INSERT INTO candidates 
VALUES (99
    ,   'Johny.Test.1@example.com'
    ,   TO_DATE('2001-04-08', 'YYYY-MM-DD')
    ,   'Johny'
    ,   'Test'
    ,   'Poland'
    ,   'Warsaw'
    ,   '97-500'
    ,   '28'
    ,   '42439284872'
    ,   '+35874747711'
    ,   'Jacob'
    ,   'Mazowieckie'
    ,   'Lemon Street East'
    ,   '52'
);

-- Optional values do not have to be set
INSERT INTO candidates (
        candidate_id
    ,   email
    ,   birth_date
    ,   first_name
    ,   family_name
    ,   country
    ,   city
    ,   postal_code
    ,   home_number
)
VALUES (98
    ,   'Jacob.Tested.2@example.com'
    ,   TO_DATE('2001-04-09', 'YYYY-MM-DD')
    ,   'Jacob'
    ,   'Tested'
    ,   'Poland'
    ,   'Warsaw'
    ,   '96-101'
    ,   '29'
);


-------------------------------
-- TEST UNIQUE CAND_EMAIL_UK --
-------------------------------

-- Inserting same email twice should result in an error
INSERT INTO candidates (
        candidate_id
    ,   email
    ,   birth_date
    ,   first_name
    ,   family_name
    ,   country
    ,   city
    ,   postal_code
    ,   home_number
)
VALUES (97
    ,   'Jacob.Tested.2@example.com'
    ,   TO_DATE('2001-04-09', 'YYYY-MM-DD')
    ,   'Jacob'
    ,   'Tested'
    ,   'Poland'
    ,   'Warsaw'
    ,   '96-101'
    ,   '29'
);

-------------------------------
-- TEST UNIQUE CAND_PESEL_UK --
-------------------------------

-- Inserting same pesel twice should result in an error
INSERT INTO candidates (
        candidate_id
    ,   email
    ,   birth_date
    ,   first_name
    ,   family_name
    ,   country
    ,   city
    ,   postal_code
    ,   home_number
    ,   pesel
)
VALUES (96
    ,   'Johny.Test.2@example.com'
    ,   TO_DATE('2001-04-10', 'YYYY-MM-DD')
    ,   'Johny'
    ,   'Test'
    ,   'Poland'
    ,   'Warsaw'
    ,   '96-102'
    ,   '30'
    ,   '42439284872'
);


-------------------------------
-- TEST SEQUENCE CAND_ID_SEQ --
-------------------------------

DECLARE
    v_id NUMBER;
    v_seq NUMBER;
BEGIN
    -- When id isn't specified candidate should acquire a id from sequence
    INSERT INTO candidates (
            email
        ,   birth_date
        ,   first_name
        ,   family_name
        ,   country
        ,   city
        ,   postal_code
        ,   home_number
    )
    VALUES ('Jack.TestED.3@example.com'
        ,   TO_DATE('2001-04-10', 'YYYY-MM-DD')
        ,   'Jack'
        ,   'TestED'
        ,   'Poland'
        ,   'Warsaw'
        ,   '96-101'
        ,   '31'
    ) RETURNING candidate_id INTO v_id;
    
    SELECT CAND_ID_SEQ.CURRVAL INTO v_seq FROM DUAL;
    
    IF v_id != v_seq THEN
        raise_application_error(-20010, 'Id: '|| v_id
            || ' is not equal last value from sequence: '|| v_seq);
    END IF;
    
    IF v_id < 10000 OR v_id > 9999999 THEN
        raise_application_error(-20011, 'ID out of specified bounds!');
    END IF;
END;
/

--------------------------------------------------------------------------------
--                          TEST INSERT ON COURSES                            --
--------------------------------------------------------------------------------

INSERT INTO courses
VALUES ('TEST1'
    ,   'Science of Testing, Finding Buggs and Debugging'
    ,   'D'
    ,   'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
);

INSERT INTO courses
VALUES ('TEST2'
    ,   'Mechatronics of Vehicles, Construction Machinery and Computer Science'
    ,   'E'
    ,   NULL
);

-----------------------------
-- TEST UNIQUE CRS_NAME_UK --
-----------------------------

-- Inserting same name twice should result in an error
INSERT INTO courses
VALUES ('TEST3'
    ,   'Science of Testing, Finding Buggs and Debugging'
    ,   'B'
    ,   NULL
);

-------------------------------
-- TEST CHECK CRS_CHK_DEGREE --
-------------------------------

-- Check if all possible degrees are inserted correctly
INSERT INTO courses VALUES ('1', 'Bachelor', 'B',   NULL);
INSERT INTO courses VALUES ('2', 'Doctorate', 'D',   NULL);
INSERT INTO courses VALUES ('3', 'Engineer', 'E',   NULL);
INSERT INTO courses VALUES ('4', 'Master', 'M',   NULL);

-- Degree set to values other than BDEM should result in an error
INSERT INTO courses VALUES ('5', 'Degree Error', 'R',   NULL);
INSERT INTO courses VALUES ('5', 'Degree Error', 'b',   NULL);

-----------------------------------
-- TEST CHECK CRS_CHK_CODE_UPPER --
-----------------------------------

-- Course code not in uppercase should result in an error
INSERT INTO courses VALUES ('TeST', 'Code Error', 'B',   NULL);

--------------------------------------------------------------------------------
--                         TEST INSERT ON REGISTRATIONS                       --
--------------------------------------------------------------------------------

INSERT INTO registrations
VALUES (
        '99S'
    ,   TO_DATE('1999-02-01', 'YYYY-MM-DD')
    ,   TO_DATE('1999-03-01', 'YYYY-MM-DD')
);

-----------------------------------------
-- TEST CHECK REG_CHK_START_BEFORE_END --
-----------------------------------------

-- When trying to insert start date after the end date program should 
-- signal an error
INSERT INTO registrations
VALUES (
        '99W'
    ,   TO_DATE('1999-03-01', 'YYYY-MM-DD')
    ,   TO_DATE('1999-01-01', 'YYYY-MM-DD')
);

-----------------------------------
-- TEST CHECK REG_CHK_CODE_UPPER --
-----------------------------------

-- Registration code not in uppercase should result in an error
INSERT INTO registrations
VALUES (
        '98s'
    ,   TO_DATE('1998-01-01', 'YYYY-MM-DD')
    ,   TO_DATE('1998-02-01', 'YYYY-MM-DD')
);

--------------------------------------------------------------------------------
--                           TEST INSERT ON OFFERS                            --
--------------------------------------------------------------------------------

INSERT INTO offers
VALUES (
        '99S'
    ,   'TEST1'
    ,   100
);

-- Trying to insert second instance of the same course in a registration 
-- should result in an error
INSERT INTO offers
VALUES (
        '99S'
    ,   'TEST1'
    ,   120
);

----------------------------------------
-- TEST CHECK OFR_CHK_AVAILABLE_SLOTS --
----------------------------------------

-- Trying insert negative available slots should result in an error
INSERT INTO offers
VALUES (
        '99S'
    ,   'TEST2'
    ,   -100
);

--------------------------------------------------------------------------------
--                        TEST INSERT ON PREFERENCES                          --
--------------------------------------------------------------------------------

INSERT INTO registrations
VALUES (
        'TEST'
    ,   ADD_MONTHS(SYSDATE, -1)
    ,   ADD_MONTHS(SYSDATE, 1)
);

INSERT INTO offers
VALUES (
        'TEST'
    ,   'TEST1'
    ,   100
);

INSERT INTO offers
VALUES (
        'TEST'
    ,   'TEST2'
    ,   1
);

INSERT INTO preferences (
        registration_code
    ,   course_code
    ,   candidate_id
    ,   sequential_number
)
VALUES ('TEST'
    ,   'TEST1'
    ,   99
    ,   1
);

-------------------------------------------
-- TEST UNIQUE PREF_SEQUENTIAL_NUMBER_UK --
-------------------------------------------

-- Two preferences cannot have the same sequencial number
INSERT INTO preferences (
        registration_code
    ,   course_code
    ,   candidate_id
    ,   sequential_number
)
VALUES ('TEST'
    ,   'TEST2'
    ,   99
    ,   1
);

-------------------------------------------
-- TEST CHECK PREF_CHK_SEQUENTIAL_NUMBER --
-------------------------------------------

-- Number of preference should be in range [1; 3] otherwise error 
-- should occur
INSERT INTO preferences (
        registration_code
    ,   course_code
    ,   candidate_id
    ,   sequential_number
)
VALUES ('TEST'
    ,   'TEST1'
    ,   98
    ,   4
);

-- Number of preference should be in range [1; 3] otherwise error 
-- should occur
INSERT INTO preferences (
        registration_code
    ,   course_code
    ,   candidate_id
    ,   sequential_number
)
VALUES ('TEST'
    ,   'TEST1'
    ,   98
    ,   -1
);

-------------------------------
-- TEST TRIGGER PREF_REG_TRG --
-------------------------------

-- Trying to enroll in previous registrations should result in an error
INSERT INTO preferences (
        registration_code
    ,   course_code
    ,   candidate_id
    ,   sequential_number
)
VALUES ('99S'
    ,   'TEST1'
    ,   99
    ,   1
);

INSERT INTO registrations
VALUES (
        'TESTF'
    ,   ADD_MONTHS(SYSDATE, 12 * 100)
    ,   ADD_MONTHS(SYSDATE, 13 * 100)
);

INSERT INTO offers
VALUES (
        'TESTF'
    ,   'TEST1'
    ,   100
);

-- Trying to enroll in future registrations should result in an error
INSERT INTO preferences (
        registration_code
    ,   course_code
    ,   candidate_id
    ,   sequential_number
)
VALUES ('TESTF'
    ,   'TEST1'
    ,   99
    ,   1
);


--------------------------------------------------------------------------------
--                          TEST UPDATE ON CANDIDATES                         --
--------------------------------------------------------------------------------


SELECT  candidate_id
    ,   email
    ,   pesel
FROM candidates
WHERE candidate_id IN (99, 98);

-------------------------------
-- TEST UNIQUE CAND_EMAIL_UK --
-------------------------------

UPDATE  candidates
SET     email = 'Jacob.Tested.2@example.com'
WHERE   candidate_id = 99;

-------------------------------
-- TEST UNIQUE CAND_PESEL_UK --
-------------------------------

UPDATE  candidates
SET     pesel = '42439284872'
WHERE   candidate_id = 98;
    
--------------------------------------------------------------------------------
--                          TEST UPDATE ON COURSES                            --
--------------------------------------------------------------------------------

SELECT  course_code
    ,   name
FROM    courses
WHERE   SUBSTR(course_code, 1, 4) = 'TEST';

-----------------------------
-- TEST UNIQUE CRS_NAME_UK --
-----------------------------

-- Updating names so that a name appears twice should result in an error
UPDATE  courses
SET     name = 'Science of Testing, Finding Buggs and Debugging'
WHERE   course_code = 'TEST2';

-------------------------------
-- TEST CHECK CRS_CHK_DEGREE --
-------------------------------

-- Check if all possible degrees are updated correctly
UPDATE  courses
SET     degree = 'D'
WHERE   course_code = '1';

UPDATE  courses
SET     degree = 'E'
WHERE   course_code = '1';

UPDATE  courses
SET     degree = 'M'
WHERE   course_code = '1';

UPDATE  courses
SET     degree = 'B'
WHERE   course_code = '1';

-- Degree set to values other than BDEM should result in an error
UPDATE  courses
SET     degree = 'b'
WHERE   course_code = '1';
    
--------------------------------------------------------------------------------
--                         TEST UPDATE ON REGISTRATIONS                       --
--------------------------------------------------------------------------------

INSERT INTO registrations
VALUES (
        '1901S'
    ,   TO_DATE('1901-02-01', 'YYYY-MM-DD')
    ,   TO_DATE('1901-03-01', 'YYYY-MM-DD')
);

-----------------------------------------
-- TEST CHECK REG_CHK_START_BEFORE_END --
-----------------------------------------

-- When trying to update start date after the end date program should 
-- signal an error
UPDATE registrations
SET start_date = TO_DATE('1901-04-01', 'YYYY-MM-DD')
WHERE registration_code = '1901S';

-- When trying to update end date before the start date program should 
-- signal an error
UPDATE registrations
SET end_date = TO_DATE('1900-12-01', 'YYYY-MM-DD')
WHERE registration_code = '1901S';

--------------------------------------------------------------------------------
--                           TEST UPDATE ON OFFERS                            --
--------------------------------------------------------------------------------

SELECT  *
FROM    offers
WHERE   registration_code = '99S'
    AND course_code = 'TEST1';

UPDATE  offers
SET     available_slots = 101
WHERE   registration_code = '99S'
    AND course_code = 'TEST1';

----------------------------------------
-- TEST CHECK OFR_CHK_AVAILABLE_SLOTS --
----------------------------------------

-- Trying update available slots to negative value should result in an error
UPDATE  offers
SET     available_slots = -100
WHERE   registration_code = '99S'
    AND course_code = 'TEST1';

-------------------------------
-- TEST TRIGGER FKNTM_OFFERS --
-------------------------------

-- Test for non-transferability
-- Updating to previous value is OK
-- Setting different value should result in an error
UPDATE  offers
SET     registration_code = '99S' 
WHERE   registration_code = '99S'
    AND course_code = 'TEST1';

UPDATE  offers
SET     registration_code = '99A' 
WHERE   registration_code = '99S'
    AND course_code = 'TEST1';

UPDATE  offers
SET     course_code = 'TEST1'
WHERE   registration_code = '99S'
    AND course_code = 'TEST1';

UPDATE  offers
SET     course_code = 'TEST2'
WHERE   registration_code = '99S'
    AND course_code = 'TEST1';


--------------------------------------------------------------------------------
--                        TEST UPDATE ON PREFERENCES                          --
--------------------------------------------------------------------------------

INSERT INTO preferences (
        registration_code
    ,   course_code
    ,   candidate_id
    ,   sequential_number
)
VALUES ('TEST'
    ,   'TEST1'
    ,   98
    ,   1
);

INSERT INTO preferences (
        registration_code
    ,   course_code
    ,   candidate_id
    ,   sequential_number
)
VALUES ('TEST'
    ,   'TEST2'
    ,   98
    ,   2
);

-------------------------------------------
-- TEST UNIQUE PREF_SEQUENTIAL_NUMBER_UK --
-------------------------------------------

-- Two preferences cannot have the same sequencial number
UPDATE  preferences
SET     sequential_number = 2
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98;

-------------------------------------------
-- TEST CHECK PREF_CHK_SEQUENTIAL_NUMBER --
-------------------------------------------

-- Number of preference should be in range [1; 3] otherwise error 
-- should occur
UPDATE  preferences
SET     sequential_number = 4
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98;

-- Number of preference should be in range [1; 3] otherwise error 
-- should occur
UPDATE  preferences
SET     sequential_number = -1
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98;

--------------------------------
-- TEST TRIGGER PREF_REG_TRG --
--------------------------------

UPDATE  registrations
SET     start_date = TO_DATE('1997-01-01', 'YYYY-MM-DD')
    ,   end_date = TO_DATE('1997-04-01', 'YYYY-MM-DD')
WHERE registration_code = 'TEST';


-- Trying to change order of preferences should not be possible
-- after the registration ends
UPDATE  preferences
SET     sequential_number = 3
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98
    ;

-- Updating result should be possible even after registration is closed
UPDATE  preferences
SET     result = 'Y'
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98
    ;

-- Updating points should be possible even after registration is closed
UPDATE  preferences
SET     points = 100
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98
    ;
    
------------------------------------
-- TEST TRIGGER FKNTM_PREFERENCES --
------------------------------------

-- Test for non-transferability
-- Updating to previous value is OK
-- Setting different value should result in an error

UPDATE  preferences
SET     registration_code = 'TEST' 
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98
    ;

UPDATE  preferences
SET     registration_code = 'TESTF' 
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98
    ;

UPDATE  preferences
SET     course_code = 'TEST1' 
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98
    ;

UPDATE  preferences
SET     course_code = 'TEST2' 
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98
    ;

UPDATE  preferences
SET     candidate_id = 98
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98
    ;

UPDATE  preferences
SET     candidate_id = 99
WHERE   registration_code = 'TEST' 
    AND course_code = 'TEST1' 
    AND candidate_id = 98
    ;

--------------------------------------------------------------------------------
--                          TEST DELETE ON CANDIDATES                         --
--------------------------------------------------------------------------------

SELECT  candidate_id
    ,   first_name
    ,   family_name
    ,   registration_code
    ,   course_code
    ,   sequential_number
    ,   start_date
    ,   end_date
FROM    candidates
JOIN    preferences
    USING(candidate_id)
JOIN    registrations
    USING(registration_code)
WHERE   candidate_id < 100;

INSERT INTO candidates (
        candidate_id
    ,   email
    ,   birth_date
    ,   first_name
    ,   family_name
    ,   country
    ,   city
    ,   postal_code
    ,   home_number
)
VALUES  (97
    ,   'Test.Test.987@example.com'
    ,   TO_DATE('2001-04-11', 'YYYY-MM-DD')
    ,   'Test'
    ,   'Test'
    ,   'Poland'
    ,   'Warsaw'
    ,   '96-102'
    ,   '27'
);

DELETE FROM candidates 
WHERE   candidate_id = 97;

-------------------------------
-- TEST TRIGGER PREF_REG_TRG --
-------------------------------

-- Cannot delete candidate that has placed his preferences for offers 
-- in registrations that are closed
DELETE FROM candidates 
WHERE   candidate_id = 99;

UPDATE  registrations
SET     start_date = ADD_MONTHS(SYSDATE, -1)
    ,   end_date = ADD_MONTHS(SYSDATE, 1)
WHERE   registration_code = 'TEST';

-- Deletion of candidate and his preferences for open registration
-- is allowed
DELETE FROM candidates 
WHERE   candidate_id = 99;

-- Clean after the tests
ROLLBACK TO SAVEPOINT before_tests;

spool off
