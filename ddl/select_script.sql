set echo on
set linesize 300
set pagesize 500
spool BD2C049_TEST.LIS

--------------------------------------------------------------------------------
-- Every candidate registers giving their personal information.
--------------------------------------------------------------------------------

-- Number of all the candidates accross every registration

SELECT  COUNT(*) NUMBER_OF_CANDIDATES
FROM    candidates;

-- Personal Information

SELECT  candidate_id
    ,   first_name
    ,   second_name
    ,   family_name
    ,   birth_date
    ,   pesel
FROM    candidates
FETCH FIRST 20 ROWS ONLY;

-- Contact Information

SELECT  candidate_id
    ,   phone_number
    ,   email
FROM    candidates
FETCH FIRST 20 ROWS ONLY;

-- Registered Address

SELECT  candidate_id
    ,   country
    ,   voivodeship
    ,   city
    ,   postal_code
    ,   street
    ,   home_number
    ,   apartment_number
FROM    candidates
FETCH FIRST 20 ROWS ONLY;

-- Optional Information Given

SELECT  candidate_id
    ,   pesel
    ,   phone_number
    ,   second_name
    ,   voivodeship
    ,   street
    ,   apartment_number
FROM    candidates
WHERE   pesel IS NOT NULL
    AND phone_number IS NOT NULL
    AND second_name IS NOT NULL
    AND voivodeship IS NOT NULL
    AND street IS NOT NULL
    AND apartment_number IS NOT NULL
    ;

-- Optional Information NOT Given

SELECT  candidate_id
    ,   pesel
    ,   phone_number
    ,   second_name
    ,   voivodeship
    ,   street
    ,   apartment_number
FROM    candidates
WHERE   pesel IS NULL
    AND phone_number IS NULL
    AND second_name IS NULL
    AND voivodeship IS NULL
    AND street IS NULL
    AND apartment_number IS NULL
    ;
    
--------------------------------------------------------------------------------
-- Every candidate registers specifying up to 3 choosen courses of study from 
-- university offer.
--------------------------------------------------------------------------------

-- Number of placed preferences in a given registration

SELECT  first_name
    ,   second_name
    ,   family_name
    ,   registration_code
    ,   COUNT(*) PREFERENCES_IN_REGISTRATION
FROM    candidates
JOIN    preferences 
    USING (candidate_id)
GROUP BY candidate_id
    ,   registration_code
    ,   first_name
    ,   second_name
    ,   family_name
ORDER BY candidate_id ASC
    ,   registration_code DESC
FETCH FIRST 20 ROWS ONLY;

-- Check if number of chosen courses does not exceed 3 courses per registration

SELECT  candidate_id
    ,   registration_code
    ,   COUNT(*) PREFERENCES_IN_REGISTRATION
FROM    preferences
GROUP BY candidate_id
    ,   registration_code
HAVING  COUNT(*) > 3;

--------------------------------------------------------------------------------
-- The order determines the preferences.
--------------------------------------------------------------------------------

SELECT  cand.first_name
    ,   cand.second_name
    ,   cand.family_name
    ,   registration_code
    ,   course_code
    ,   crs.name
    ,   pref.sequential_number
FROM    candidates cand
JOIN    preferences pref
    USING(candidate_id)
JOIN    courses crs
    USING(course_code)
WHERE   candidate_id = 101
ORDER BY registration_code
    ,   pref.sequential_number
    ;

--------------------------------------------------------------------------------
-- Recruitment takes place twice a year.
--------------------------------------------------------------------------------

-- All the registrations

SELECT  registration_code
    ,   start_date
    ,   end_date
FROM    registrations;

-- Registrations from year 2022

SELECT  registration_code
    ,   start_date
    ,   end_date
FROM    registrations
WHERE   EXTRACT(YEAR FROM start_date) = 2022;

-- Count all the registrations per year

SELECT  EXTRACT(YEAR FROM start_date) YEAR
    ,   COUNT(*) REGISTRATIONS_IN_A_YEAR
FROM    registrations
GROUP BY EXTRACT(YEAR FROM start_date)
ORDER BY YEAR;

--------------------------------------------------------------------------------
-- The university course offer changes with time.
--------------------------------------------------------------------------------

-- List of 20 courses
SELECT  course_code
    ,   name
    ,   degree
    ,   CAST(
            CASE WHEN description IS NOT NULL THEN
                SUBSTR(description, 0, 100) || '...'
            ELSE 
                NULL
            END 
            AS VARCHAR2(103)
        ) DESCRIPTION
FROM courses
FETCH FIRST 20 ROWS ONLY;

-- Courses and their number of occurences in all the registrations

SELECT  course_code
    ,   crs.name
    ,   COUNT(*) OCCURRENCES
FROM    courses crs
JOIN    offers ofr
    USING(course_code)
GROUP BY course_code, crs.name
FETCH FIRST 20 ROWS ONLY;

-- Occurrence of a course throughout all the registrations

SELECT  crs.course_code
    ,   crs.name
    ,   reg.registration_code
    ,   start_date
    ,   end_date
FROM    registrations reg
LEFT JOIN offers ofr
    ON  reg.registration_code = ofr.registration_code 
    AND ofr.course_code = (
        SELECT  course_code 
        FROM    courses 
        ORDER BY course_code DESC 
        FETCH FIRST 1 ROW ONLY
    )
LEFT JOIN courses crs
    ON ofr.course_code = crs.course_code
ORDER BY start_date;


--------------------------------------------------------------------------------
-- Candidate who has not been admitted to study in a registration may start
-- in the next registrations.
--------------------------------------------------------------------------------

-- Candidates and their number of tries in registrations

SELECT  first_name
    ,   second_name
    ,   family_name
    ,   COUNT(DISTINCT registration_code) ATTENDED_REGISTRATIONS
FROM    candidates
JOIN    preferences 
    USING (candidate_id)
GROUP BY candidate_id
    ,   first_name
    ,   second_name
    ,   family_name
ORDER BY candidate_id ASC
FETCH FIRST 20 ROWS ONLY;

-- Candidates and registrations they attended

SELECT  first_name
    ,   second_name
    ,   family_name
    ,   registration_code
FROM    candidates
JOIN    preferences 
    USING (candidate_id)
GROUP BY candidate_id
    ,   registration_code
    ,   first_name
    ,   second_name
    ,   family_name
ORDER BY candidate_id ASC
    ,   registration_code
FETCH FIRST 20 ROWS ONLY;



spool off
