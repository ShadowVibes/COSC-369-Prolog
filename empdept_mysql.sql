-- MySQL 8.0+ conversion of empdept.pl
-- Execute this script in MySQL Workbench.
-- WARNING: Re-running resets the three tables in the empdept database.
CREATE DATABASE IF NOT EXISTS empdept;
USE empdept;

DROP TABLE IF EXISTS emp;
DROP TABLE IF EXISTS salgrade;
DROP TABLE IF EXISTS dept;

CREATE TABLE dept (
    deptno INT PRIMARY KEY,
    dname VARCHAR(14),
    loc VARCHAR(13)
);

CREATE TABLE emp (
    empno INT PRIMARY KEY,
    ename VARCHAR(10),
    job VARCHAR(9),
    mgr INT NULL,
    sal DECIMAL(7,2),
    deptno INT NOT NULL,
    CONSTRAINT emp_dept_fk FOREIGN KEY (deptno) REFERENCES dept(deptno),
    CONSTRAINT emp_mgr_fk FOREIGN KEY (mgr) REFERENCES emp(empno)
);

CREATE TABLE salgrade (
    grade INT PRIMARY KEY,
    losal DECIMAL(7,2),
    hisal DECIMAL(7,2)
);

INSERT INTO dept VALUES
    (10, 'ACCOUNTING', 'NEW YORK'),
    (20, 'RESEARCH',   'DALLAS'),
    (30, 'SALES',      'CHICAGO'),
    (40, 'OPERATIONS', 'BOSTON');

INSERT INTO emp VALUES
    (7839, 'KING',   'PRESIDENT', NULL, 5000, 10),
    (7698, 'BLAKE',  'MANAGER',   7839, 2850, 30),
    (7782, 'CLARK',  'MANAGER',   7839, 2450, 10),
    (7566, 'JONES',  'MANAGER',   7839, 2975, 20),
    (7654, 'MARTIN', 'SALESMAN',  7698, 1250, 30),
    (7499, 'ALLEN',  'SALESMAN',  7698, 1600, 30),
    (7844, 'TURNER', 'SALESMAN',  7698, 1500, 30),
    (7900, 'JAMES',  'CLERK',     7698,  950, 30),
    (7521, 'WARD',   'SALESMAN',  7698, 1250, 30),
    (7902, 'FORD',   'ANALYST',   7566, 3000, 20),
    (7369, 'SMITH',  'CLERK',     7902,  800, 20),
    (7788, 'SCOTT',  'ANALYST',   7566, 3000, 20),
    (7876, 'ADAMS',  'CLERK',     7788, 1100, 20),
    (7934, 'MILLER', 'CLERK',     7782, 1300, 10);

INSERT INTO salgrade VALUES
    (1,  700, 1200),
    (2, 1201, 1400),
    (3, 1401, 2000),
    (4, 2001, 3000),
    (5, 3001, 9999);


-- Exercise 1: Department number and name in Boston
SELECT deptno, dname
FROM dept
WHERE loc = 'BOSTON';

-- Exercise 2: Employee numbers and names in the research department
SELECT e.empno, e.ename
FROM emp AS e
JOIN dept AS d ON e.deptno = d.deptno
WHERE d.dname = 'RESEARCH';

-- Exercise 3: Employees who are managers or president
SELECT ename, job
FROM emp
WHERE job IN ('MANAGER', 'PRESIDENT');

-- Exercise 4: Employees earning more than their direct supervisor
SELECT e.ename
FROM emp AS e
JOIN emp AS supervisor ON e.mgr = supervisor.empno
WHERE e.sal > supervisor.sal;

-- Exercise 5: Everyone directly or indirectly managed by JONES
WITH RECURSIVE reports AS (
    SELECT e.empno, e.ename, e.mgr
    FROM emp AS e
    JOIN emp AS manager ON e.mgr = manager.empno
    WHERE manager.ename = 'JONES'

    UNION ALL

    SELECT e.empno, e.ename, e.mgr
    FROM emp AS e
    JOIN reports AS r ON e.mgr = r.empno
)
SELECT ename
FROM reports;
