student_name,
    email,
    birth_date,
    COUNT(*) AS CountOfDuplicates
FROM course_system.students
GROUP BY 
    teacher_no,
    course_no,
    student_name,
    email,
    birth_date
HAVING COUNT(*) > 1;
Result:


⸻


🛠️ SQL Skills Demonstrated
SELECT
WHERE
ORDER BY
GROUP BY
HAVING
INNER JOIN
COUNT()
AVG()
YEAR()
EXTRACT()
TIMESTAMPDIFF()
CONCAT()
ROUND()
ABS()
Common Table Expressions (CTEs)
Window Functions
ROW_NUMBER()
Temporary Tables
Transactions
Database & Table Creation
Primary Keys
Foreign Keys
Referential Integrity
Duplicate Detection


⸻


📂 Project Structure
sql-data-analysis-project/
│
├── SQL Step Project Kucheruk Sofia.sql
├── README.md
│
└── images/
    ├── Q1.png
    ├── Q2.png
    ├── Q3.png
    ├── Q4.png
    ├── Q5.png
    ├── Q6.png
    ├── Q7.png
    ├── Q8.png
    ├── Q9.png
    ├── Q10.png
    └── Q11.png


⸻


🎯 Project Goal
The goal of this project was to strengthen practical SQL skills through data analysis and relational database design.
The project demonstrates how SQL can be used to:
analyze employee and salary data;
work with multiple related tables;
calculate business metrics;
use advanced SQL techniques;
create relational databases;
establish relationships between tables;
identify duplicate records.
This project is part of my Data Analyst portfolio.
