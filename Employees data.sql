-- exploration of data and NULL values

SELECT dept_no FROM departments;
SELECT * FROM departments;
SELECT
    *
FROM
    employees
WHERE
    emp_no NOT BETWEEN '10004' AND '10012' ;
SELECT
    dept_name
FROM
    departments
WHERE
    dept_no BETWEEN 'd003' AND 'd006';
    
SELECT dept_name from departments WHERE dept_no IS NOT NULL;
SELECT DISTINCT hire_date FROM employees;
SELECT
    COUNT(*)
FROM
    salaries
WHERE
    salary >= 100000;
SELECT
    COUNT(*)
FROM
    dept_manager;
SELECT * FROM employees ORDER BY first_name, last_name DESC;

SELECT
    emp_no, AVG(salary)
FROM
    salaries
GROUP BY emp_no
HAVING AVG(salary) > 120000
ORDER BY emp_no;

SELECT emp_no FROM dept_emp WHERE from_date>'2000-01-01'
GROUP BY emp_no
HAVING COUNT(from_date)>1 ORDER BY emp_no;

SELECT
    dept_no,
    dept_name,
    COALESCE(dept_no, dept_name) AS dept_info
FROM
    departments
ORDER BY dept_no ASC;



-- Duplicate tables to manipulate and analyse
-- Departments table duplicated
CREATE TABLE departments_dup
(
    dept_no CHAR(4) NULL,
    dept_name VARCHAR(40) NULL
);

INSERT INTO departments_dup
(
    dept_no,
    dept_name
)SELECT
    *
FROM
    departments;
    
INSERT INTO departments_dup (dept_name)
VALUES      ('Public Relations');


INSERT INTO departments_dup(dept_no) VALUES ('d010'), ('d011');

-- Department managers table Duplicated
CREATE TABLE dept_manager_dup
(
    emp_no INT(11) NOT NULL,
    dept_no CHAR(4) NULL,
    from_date DATE NOT NULL,
    to_date DATE NULL
);

INSERT INTO dept_manager_dup
SELECT * FROM dept_manager;

INSERT INTO dept_manager_dup(emp_no, from_date)
VALUES  (999904, '2017-01-01'),
        (999905, '2017-01-01'),
        (999906, '2017-01-01'),
        (999907, '2017-01-01');


-- Exploration**
SELECT 
    e.emp_no,
    e.first_name,
    e.last_name,
    dm.dept_no,
    e.hire_date
FROM
    employees e
JOIN
    dept_manager dm ON e.emp_no = dm.emp_no;

-- Join employees and manager 
SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    dm.dept_no,
    dm.from_date
FROM
    employees e
LEFT JOIN
    dept_manager dm ON e.emp_no = dm.emp_no
WHERE
    e.last_name = 'Markovitch'
ORDER BY dm.dept_no DESC, e.emp_no;

-- mode alter
set @@global.sql_mode := replace(@@global.sql_mode, 'ONLY_FULL_GROUP_BY', '');



SELECT dm.*, d.*
FROM
    departments d
CROSS JOIN
    dept_manager dm
WHERE
    d.dept_no = 'd009'
ORDER BY d.dept_no;



SELECT 
    e.*, d.*
FROM
    employees e
CROSS JOIN
    departments d
WHERE
    e.emp_no<10011
ORDER BY e.emp_no, d.dept_name;


-- Identification managers
SELECT
    e.first_name,
    e.last_name,
    e.hire_date,
    t.title,
    m.from_date,
    d.dept_name
FROM
    employees e
    JOIN
    dept_manager m ON e.emp_no = m.emp_no
    JOIN
    departments d ON m.dept_no = d.dept_no
    JOIN
    titles t ON e.emp_no = t.emp_no
WHERE t.title = 'Manager'
ORDER BY e.emp_no;

SELECT
    e.first_name, e.last_name
FROM
    employees e
WHERE 
    e.emp_no IN (SELECT
                    dm.emp_no
                FROM
                    dept_manager dm);
SELECT
    dm.emp_no
FROM
    dept_manager dm
;

-- Department Avg Salary
SELECT
    d.dept_name, AVG(salary) as Avg_salary
FROM
    departments d
    JOIN
    dept_manager m ON d.dept_no = m.dept_no
    JOIN
    salaries s ON m.emp_no = s.emp_no
GROUP BY d.dept_name
ORDER BY Avg_salary DESC
;


-- Assistant Engineer
SELECT
    *
FROM
    employees e
WHERE
    EXISTS(SELECT
            *
        FROM
            titles t 
        WHERE
            t.emp_no=e.emp_no
            AND title='Assistant Engineer');

-- Def manager 
-- Group manager A emplooyers <= 10020
-- Group manager B employees > 10020
SELECT
    A.*
FROM
    (SELECT
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS department_code,
            (SELECT
                emp_no
            FROM
                dept_manager
            WHERE
                emp_no = 110022) AS manager_ID
    FROM
        employees e 
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no <= 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS A;
UNION SELECT
    B.*
FROM
    (SELECT
        e.emp_no AS employee_ID,
            MIN(de.dept_no) AS department_code,
            (SELECT
                emp_no
            FROM
                dept_manager
            WHERE
                emp_no = 110039) AS manager_ID
    FROM
        employees e 
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no > 10020
    GROUP BY e.emp_no
    ORDER BY e.emp_no) AS B;


-- Highest salary achieve
SELECT s1.emp_no, s.salary, s.from_date, s.to_date
FROM
    salaries s 
    JOIN
    (SELECT 
        emp_no, MIN(from_date) AS from_date
    FROM
        salaries
    GROUP BY emp_no) s1 ON s.emp_no=s1.emp_no
WHERE
    s.from_date=s1.from_date;


-- AVG salary per department
SELECT
    de2.emp_no, d.dept_name, s2.salary, AVG(s2.salary) OVER w AS average_salary_per_dept
FROM
    (SELECT
        de.emp_no, de.dept_no, de.from_date, de.to_date
    FROM
        dept_emp de
        JOIN
        (SELECT
            emp_no, MAX(from_date)AS from_date
        FROM
            dept_emp
        GROUP BY emp_no) de1 ON de1.emp_no=de.emp_no
        WHERE
            de.to_date<'2002-01-01'
        AND de.from_date>'2000-01-01'
        AND de.from_date = de1.from_date) de2
        JOIN
            (SELECT
                s1.emp_no, s.salary, s.from_date, s.to_date
            FROM
                salaries s
                JOIN
                (SELECT
                    emp_no, MAX(from_date) AS from_date
                FROM
                    salaries
                GROUP BY emp_no) s1 ON s.emp_no=s1.emp_no
                WHERE
                    S.TO_DATE<'2002-01-01'
                AND s.from_date>'2000-01-01'
                AND s.from_date = s1.from_date) s2 ON s2.emp_no = de2.emp_no
                JOIN
                    departments d ON d.dept_no=de2.dept_no
                GROUP BY de2.emp_no, d.dept_name
                WINDOW w AS (PARTITION BY de2.dept_no)
                ORDER BY de2.emp_no, salary;

-- Tableau dashboard**

-- Breakdown male and female employees
SELECT
    YEAR(d.from_date) as calendar_year,
    gender,
    COUNT(e.emp_no) as num_of_employees
FROM
    employees e 
    JOIN
    dept_emp d ON d.emp_no=e.emp_no
GROUP BY calendar_year, e.gender
HAVING calendar_year >= 1990;


-- Breakdown male female managers differ from departments
SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year 
        THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        employees
    GROUP BY calendar_year) e
        CROSS JOIN
    dept_manager dm
        JOIN
    departments d ON dm.dept_no = d.dept_no
        JOIN 
    employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;


-- AVG salary of Male and Female employees filter departments
SELECT
    e.gender, d.dept_name, ROUND(AVG(s.salary), 2) AS salary, 
    YEAR(s.from_date) AS calendar_year
FROM
    salaries s 
    JOIN
    employees e ON s.emp_no=e.emp_no
    JOIN
    dept_emp de ON de.emp_no=e.emp_no
    JOIN
    departments d ON d.dept_no=de.dept_no
GROUP BY d.dept_no, e.gender, calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;


-- AVG salary based on gender and departments
 
DROP PROCEDURE IF EXISTS filter_salary;

DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
SELECT 
    e.gender, d.dept_name, AVG(s.salary) as avg_salary
FROM
    salaries s
        JOIN
    employees e ON s.emp_no = e.emp_no
        JOIN
    dept_emp de ON de.emp_no = e.emp_no
        JOIN
    departments d ON d.dept_no = de.dept_no
    WHERE s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_no, e.gender;
END$$

DELIMITER ;

CALL filter_salary(50000, 90000);






