             /* 1. Запити by SK 
2026-01-02 */

-- 1. Покажіть для кожного року найбільший відділ цього року та його середню зарплату.
WITH dept_year AS (
    SELECT 
        dep.dept_name,
        EXTRACT(YEAR FROM deptemp.from_date) AS only_year,
        deptemp.emp_no
    FROM employees.dept_emp deptemp
    INNER JOIN employees.departments dep 
        ON deptemp.dept_no = dep.dept_no
),

salary_year AS (
    SELECT 
        sal.emp_no,
        EXTRACT(YEAR FROM sal.from_date) AS only_year,
        sal.salary
    FROM employees.salaries sal 
),

dept_sum AS (
    SELECT 
        dy.only_year,
        dy.dept_name,
        COUNT(DISTINCT dy.emp_no) AS CountOfEmp,
        AVG(sy.salary) AS AvgSal
    FROM dept_year dy
    INNER JOIN salary_year sy
        ON dy.emp_no = sy.emp_no 
       AND dy.only_year = sy.only_year
    GROUP BY dy.only_year, dy.dept_name
),

ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY only_year ORDER BY CountOfEmp DESC) AS rankbyemp
    FROM dept_sum
)

SELECT 
    only_year,
    dept_name,
    CountOfEmp,
    ROUND(AvgSal, 2) AS AvarageSalary
FROM ranked 
WHERE rankbyemp = 1
ORDER BY only_year;

-- 2.  Покажіть детальну інформацію про поточного менеджера, який найдовше виконує свої обов'язки.
SELECT emp.emp_no,
       dep.dept_name,
       deptman.dept_no,
       CONCAT(emp.first_name, " ", emp.last_name) AS full_name,
       emp.gender,
       emp.birth_date,
       emp.hire_date,
       deptman.from_date,
       deptman.to_date,
       TIMESTAMPDIFF(YEAR, deptman.from_date, CURRENT_DATE) AS work_as_manager
FROM employees.employees emp
INNER JOIN employees.dept_manager deptman
ON emp.emp_no = deptman.emp_no
INNER JOIN employees.departments dep
  ON deptman.dept_no = dep.dept_no
WHERE CURRENT_DATE BETWEEN deptman.from_date AND deptman.to_date
ORDER BY work_as_manager DESC 
LIMIT 1;

-- 3. Покажіть середню зарплату співробітників за кожен рік, до 2005 року. 
SELECT YEAR(sal.from_date) AS YearOfSal,
       ROUND(AVG(sal.salary), 2) AS AvgSal
FROM employees.salaries sal
WHERE sal.from_date < '2005-01-01'
GROUP BY YEAR(sal.from_date)
ORDER BY YEAR(sal.from_date) DESC;

/* 4. Покажіть середню зарплату співробітників по кожному відділу. 
Примітка: потрібно розрахувати по поточній зарплаті, та поточному відділу співробітників */
SELECT dept.dept_no,
       dept.dept_name,
       ROUND(AVG(sal.salary), 2) AS AvgSal
FROM employees.dept_emp deptemp
INNER JOIN employees.departments dept
  ON deptemp.dept_no = dept.dept_no
INNER JOIN employees.salaries sal
  ON deptemp.emp_no = sal.emp_no
  AND CURRENT_DATE() BETWEEN sal.from_date AND sal.to_date
WHERE CURRENT_DATE() BETWEEN deptemp.from_date AND deptemp.to_date
GROUP BY dept.dept_no,
		 dept.dept_name
ORDER BY dept.dept_no ASC;

-- 5. Покажіть середню зарплату співробітників по кожному відділу за кожний рік.
SELECT deptemp.dept_no,
       YEAR(sal.from_date) AS YearOfSal,
       ROUND(AVG(sal.salary), 2) AS AvgSal
FROM employees.dept_emp deptemp
INNER JOIN employees.salaries sal
  ON deptemp.emp_no = sal.emp_no
GROUP BY deptemp.dept_no,
         YEAR(sal.from_date)
ORDER BY deptemp.dept_no ASC;

-- 6. Покажіть відділи в яких зараз працює більше 15000 співробітників.
SELECT deptemp.dept_no,
	   dep.dept_name,
       COUNT(deptemp.emp_no) AS CountOfEmp
FROM employees.departments dep
INNER JOIN employees.dept_emp deptemp
  ON dep.dept_no = deptemp.dept_no
  AND CURRENT_DATE BETWEEN deptemp.from_date AND deptemp.to_date
GROUP BY deptemp.dept_no
HAVING COUNT(deptemp.emp_no) > 15000
ORDER BY deptemp.dept_no ASC;

-- 7. Для менеджера який працює найдовше покажіть його номер, відділ, дату прийому на роботу, прізвище.
SELECT emp.emp_no,
       deptman.dept_no,
       dep.dept_name,
       emp.hire_date,
       emp.last_name
FROM employees.employees emp
INNER JOIN employees.dept_manager deptman
  ON emp.emp_no = deptman.emp_no
INNER JOIN employees.departments dep
  ON deptman.dept_no = dep.dept_no
WHERE CURRENT_DATE BETWEEN deptman.from_date AND deptman.to_date
ORDER BY emp.hire_date ASC
LIMIT 1;

-- 8. Покажіть топ-10 діючих співробітників компанії з найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі.
WITH DeptAvgSalary AS (
     SELECT deptemp.dept_no,
            AVG(sal.salary) AS AvgSalary
     FROM employees.dept_emp deptemp
     INNER JOIN employees.salaries sal
       ON deptemp.emp_no = sal.emp_no
       AND CURRENT_DATE BETWEEN deptemp.from_date AND deptemp.to_date
       AND CURRENT_DATE BETWEEN sal.from_date AND sal.to_date
     GROUP BY deptemp.dept_no
)
SELECT emp.emp_no,
       CONCAT(emp.first_name, " ", emp.last_name) AS full_name,
       dep.dept_no,
       dep.dept_name,
       sal.salary,
       ROUND(ABS(sal.salary - depavgsal.AvgSalary),2) AS SalaryDiff
FROM employees.employees emp
INNER JOIN employees.dept_emp deptemp
  ON emp.emp_no = deptemp.emp_no
INNER JOIN employees.departments dep
  ON deptemp.dept_no = dep.dept_no
INNER JOIN employees.salaries sal
  ON emp.emp_no = sal.emp_no
INNER JOIN DeptAvgSalary depavgsal
  ON deptemp.dept_no = depavgsal.dept_no
  AND CURRENT_DATE BETWEEN deptemp.from_date AND deptemp.to_date
  AND CURRENT_DATE BETWEEN sal.from_date AND sal.to_date
ORDER BY ABS(sal.salary - depavgsal.AvgSalary) DESC
LIMIT 10;  
  
/* 9. Для кожного відділу покажіть другого по порядку менеджера. 
Необхідно вивести відділ, прізвище ім’я менеджера, дату прийому на роботу менеджера і дату коли він став менеджером відділу. */
CREATE TEMPORARY TABLE IF NOT EXISTS employees.temp_manager
AS 
SELECT dep.dept_no,
       dep.dept_name,
       CONCAT(emp.first_name, " ", emp.last_name) AS full_name,
       emp.hire_date AS EmployeeHireDate,
       deptman.from_date AS ManagerStartDate,
       ROW_NUMBER() OVER (PARTITION BY dep.dept_no ORDER BY deptman.from_date) AS RowNumber
FROM employees.employees emp
INNER JOIN employees.dept_manager deptman
  ON emp.emp_no = deptman.emp_no
INNER JOIN employees.departments dep
  ON deptman.dept_no = dep.dept_no;

SELECT *
FROM employees.temp_manager
WHERE RowNumber = 2;

           /* 2. Дизайн бази даних by SK:
 
1. Створіть базу даних для управління курсами. База має включати наступні таблиці:
- students: student_no, teacher_no, course_no, student_name, email, birth_date.
- teachers: teacher_no, teacher_name, phone_no
- courses: course_no, course_name, start_date, end_date
 
2. Додайте будь-які данні (7-10 рядків) в кожну таблицю.
3. По кожному викладачу покажіть кількість студентів з якими він працював.
4. Спеціально зробіть 3 дубляжі в таблиці students (додайте ще 3 однакові рядки) 5. Напишіть запит який виведе дублюючі рядки в таблиці students. */

CREATE DATABASE IF NOT EXISTS course_system;

USE course_system;

CREATE TABLE IF NOT EXISTS teachers (
teacher_no INT AUTO_INCREMENT PRIMARY KEY,
teacher_name VARCHAR(100) NOT NULL,
phone_no VARCHAR(50) 
);

CREATE TABLE IF NOT EXISTS courses (
course_no INT AUTO_INCREMENT PRIMARY KEY,
course_name VARCHAR(100) NOT NULL,
start_date DATE,
end_date DATE
);

CREATE TABLE IF NOT EXISTS students (
student_no INT AUTO_INCREMENT,
teacher_no INT,
course_no INT,
student_name VARCHAR(100),
email VARCHAR(255),
birth_date DATE,
PRIMARY KEY (student_no),

FOREIGN KEY (teacher_no)                              
    REFERENCES teachers (teacher_no)
    ON UPDATE RESTRICT 
    ON DELETE CASCADE,
FOREIGN KEY (course_no)           
    REFERENCES courses (course_no) 
    ON UPDATE RESTRICT 
    ON DELETE CASCADE
);

START TRANSACTION;

INSERT INTO teachers (teacher_name, phone_no)
VALUES ('Vlad Reznikov', '0501192223'),
      ('Maria Naumova', '0502876567'),
      ('Sofia Velur', '0502877659'),
      ('Maksym Teshenko', '0504462387'),
	  ('Karina Lisenko', '0501192223'),
      ('Kamila Mylina', '0502876567'),
      ('Gleb Sitnichenko', '0501192223');
      
INSERT INTO courses (course_name, start_date, end_date)
VALUES ('SQL for beginners', '2024-10-01', '2025-04-20'),
      ('Python', '2024-01-02', '2025-01-05'),
      ('Data Analytics for beginners', '2024-08-15', '2024-12-30'),
      ('English B1+', '2024-03-12', '2024-05-02'),
	  ('Data Management Systems', '2024-11-26', '2025-02-25'),
      ('Advanced SQL', '2024-05-04', '2024-10-17'),
      ('Power BI, Tableau', '2025-01-04', '2025-03-19');
      
INSERT INTO students (teacher_no, course_no, student_name, email, birth_date)
VALUES ('1', '3', 'Kira Lublin', 'kiralub@gmail.com', '1999-05-12'),
      ('3', '1', 'Ilya Rikman', 'ilyakrutoi@gmail.com', '2001-10-06'),
      ('1', '2', 'Olesya Zheleznyak', 'olesyakotik1994@gmail.com', '1994-02-13'),
      ('2', '2', 'Daria Komarova', 'komardarsis228@gmail.com', '1998-06-23'),
	  ('3', '4', 'Danya Bely', 'danbel0404@gmail.com', '2004-04-04'),
      ('3', '5', 'Ruslan Kivan', 'ruslankiv@gmail.com', '1995-09-30'),
      ('4', '6', 'Olga Radzimovskaya', 'radzim0lga@gmail.com', '2002-05-11'),
      ('5', '7', 'Dima Savelyev', 'dimonsav05@gmail.com', '2005-12-29'),
      ('5', '7', 'Nastya Belka', 'belkanastasia@gmail.com', '2002-07-07'),
      ('6', '5', 'Sergey Novikov', 'novikserg1999@gmail.com', '1999-01-29'),
      ('7', '1', 'Sofia Kisnitskya', 'sofiakis203@gmail.com', '2003-10-09');
      
COMMIT;

SELECT teach.teacher_no,
	   teach.teacher_name,
       COUNT(stud.student_name)
FROM course_system.teachers teach
INNER JOIN course_system.students stud
  ON teach.teacher_no = stud.teacher_no
GROUP BY teach.teacher_no,
	     teach.teacher_name
ORDER BY teach.teacher_no;

INSERT INTO students (teacher_no, course_no, student_name, email, birth_date)
SELECT teacher_no, course_no, student_name, email, birth_date
FROM course_system.students
LIMIT 3;

SELECT *
FROM course_system.students;

SELECT teacher_no, 
	   course_no, 
       student_name, 
       email, 
       birth_date,
       COUNT(*) AS CountOfDuplicates
FROM course_system.students
GROUP BY teacher_no, 
	     course_no, 
         student_name, 
         email, 
         birth_date
HAVING COUNT(*) > 1;