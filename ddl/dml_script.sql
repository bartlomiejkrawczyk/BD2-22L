spool BD2C049_DML.LIS

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


-----------------------------------------------------------
-- TEST SEQUENCE CAND_ID_SEQ AND TRIGGER CAND_ID_SEQ_TRG --
-----------------------------------------------------------

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
    ,   'Mechatronics of Vehicles and Construction Machinery'
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

---------------------------------------
-- TEST TRIGGER REG_INTERVAL_INS_TRG --
---------------------------------------

-- Overlaping registrations should result in an error
-- Case : {[}]
INSERT INTO registrations
VALUES (
        '99S2'
    ,   TO_DATE('1999-01-01', 'YYYY-MM-DD')
    ,   TO_DATE('1999-02-10', 'YYYY-MM-DD')
);

-- Overlaping registrations should result in an error
-- Case : [{]}
INSERT INTO registrations
VALUES (
        '99S3'
    ,   TO_DATE('1999-02-10', 'YYYY-MM-DD')
    ,   TO_DATE('1999-04-01', 'YYYY-MM-DD')
);

-- Overlaping registrations should result in an error
-- Case : {[]}
INSERT INTO registrations
VALUES (
        '99S3'
    ,   TO_DATE('1999-01-01', 'YYYY-MM-DD')
    ,   TO_DATE('1999-04-01', 'YYYY-MM-DD')
);

-- Overlaping registrations should result in an error
-- Case : [{}]
INSERT INTO registrations
VALUES (
        '99S3'
    ,   TO_DATE('1999-02-10', 'YYYY-MM-DD')
    ,   TO_DATE('1999-02-15', 'YYYY-MM-DD')
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
    ,   100
);

INSERT INTO preferences (registration_code, course_code, candidate_id, sequential_number)
VALUES ('TEST'
    ,   'TEST1'
    ,   99
    ,   1
);

ROLLBACK;
-------------------------------------------
-- TEST UNIQUE PREF_SEQUENTIAL_NUMBER_UK --
-------------------------------------------

-- Two preferences cannot have the same sequencial number
INSERT INTO preferences (registration_code, course_code, candidate_id, sequential_number)
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
INSERT INTO preferences (registration_code, course_code, candidate_id, sequential_number)
VALUES ('TEST'
    ,   'TEST1'
    ,   98
    ,   4
);

-- Number of preference should be in range [1; 3] otherwise error 
-- should occur
INSERT INTO preferences (registration_code, course_code, candidate_id, sequential_number)
VALUES ('TEST'
    ,   'TEST1'
    ,   98
    ,   -1
);


-- Clean after the tests
ROLLBACK;

spool off
