
%   DEPTNO DNAME        LOC       (department number, department name, location)
dept(10, 'ACCOUNTING', 'NEW YORK').
dept(20, 'RESEARCH',   'DALLAS').
dept(30, 'SALES',      'CHICAGO').
dept(40, 'OPERATIONS', 'BOSTON').

%   EMPNO ENAME     JOB          MGR   SAL   DEPTNO (employee number, name, job, manager, salary, department number)
emp(7839, 'KING',   'PRESIDENT', null, 5000, 10).
emp(7698, 'BLAKE',  'MANAGER',   7839, 2850, 30).
emp(7782, 'CLARK',  'MANAGER',   7839, 2450, 10).
emp(7566, 'JONES',  'MANAGER',   7839, 2975, 20).
emp(7654, 'MARTIN', 'SALESMAN',  7698, 1250, 30).
emp(7499, 'ALLEN',  'SALESMAN',  7698, 1600, 30).
emp(7844, 'TURNER', 'SALESMAN',  7698, 1500, 30).
emp(7900, 'JAMES',  'CLERK',     7698,  950, 30).
emp(7521, 'WARD',   'SALESMAN',  7698, 1250, 30).
emp(7902, 'FORD',   'ANALYST',   7566, 3000, 20).
emp(7369, 'SMITH',  'CLERK',     7902,  800, 20).
emp(7788, 'SCOTT',  'ANALYST',   7566, 3000, 20).
emp(7876, 'ADAMS',  'CLERK',     7788, 1100, 20).
emp(7934, 'MILLER', 'CLERK',     7782, 1300, 10).

%     GRADE LOSAL HISAL  (paygrade, low salary, high salary)
salgrade(1,  700, 1200).
salgrade(2, 1201, 1400).
salgrade(3, 1401, 2000).
salgrade(4, 2001, 3000).
salgrade(5, 3001, 9999).

%--------------------------------------------------------------------------------------------
%Exercise 1: Print number and name of the department in boston
dept_in_city(City) :-
    dept(DeptNo, DName, City),
        write("Number: "), write(DeptNo), write('\n'), write("Name: "), write(DName), nl,
        fail.
    dept_in_city(_).

%run dept_in_city('BOSTON').

%--------------------------------------------------------------------------------------------
%Exercise 2: List number and name of all employees in the research department.
emp_in_dept_list(DeptName) :-
    dept(DeptNo, DeptName, _),
    emp(EmpNo, EName, _, _, _, DeptNo),
        write("Number: "), write(EmpNo), write('\n'), write("Name: "), write(EName), write('\n'), nl,
        fail.
    emp_in_dept(_).
%run emp_in_dept_list('RESEARCH').

%--------------------------------------------------------------------------------------------
%Exercise 3: List the names of all employees who are manager or president of the company.
list_manager_pres() :-
    emp(_, EName, Job, _, _, _),
    (Job = 'MANAGER'; Job = 'PRESIDENT'),
        write("Name: "), write(EName), write(" Job: "), write(Job), nl,
        fail.
    list_manager_pres().
%run list_manager_pres().

%--------------------------------------------------------------------------------------------
%Exercise 4: List all employees who earn more than their direct supervisor. One can use a condition like X > Y. The requirement is that X and Y must occur in a body literal to the left of X > Y, so that they are “bound” to a number when this condition is evaluated.
emp_inflated_salary() :-
    emp(_, EName, _, Mgr, Sal, _),
    emp(Mgr, _, _, _, MgrSal, _),
    Sal > MgrSal,
        write("Name: "), write(EName), nl,
        fail.
    emp_inflated_salary().
%run emp_inflated_salary().

%--------------------------------------------------------------------------------------------
%Exercise 5: List all employees who are directly or indirectly managed by “JONES”

%Employees directly managed
directly_managed(Manager, Employee) :-
    emp(MgrNo, Manager, _, _, _, _),
    emp(_, Employee, _, MgrNo, _, _).

%Employees directly or indirectly managed
managed_by(Manager, Employee) :-
    directly_managed(Manager, Employee).

managed_by(Manager, Employee) :-
    directly_managed(Manager, MiddleManager),
    managed_by(MiddleManager, Employee).

%Print all employees of manager
managed_by(Manager) :-
    forall(
        managed_by(Manager, Employee),
        (write('Name: '), write(Employee), nl)
    ).

%run managed_by('JONES').


%-------------------------------------------
% Run all at once:
run_all() :-
    write("\nExercise 1: Print the number and name of the department in boston"), nl,
    ignore(dept_in_city('BOSTON')),

    write("\nExercise 2: List number and name of all employees in the research department"), nl,
    ignore(emp_in_dept_list('RESEARCH')),

    write("\nExercise 3: List the names of all employees who are manager or president of the company"), nl,
    ignore(list_manager_pres()),

    write("\nExercise 4: List all employees who earn more than their direct supervisor"), nl,
    ignore(emp_inflated_salary()),

    write("\nExercise 5: List all employees who are directly or indirectly managed by JONES"), nl,
    ignore(managed_by('JONES')).
%ignore() used so subsequent queries will run even if one fails (either normally or due to fail-driven loop)
%run run_all().
/*





Full instructions:
terminal -> run swipl empdept.pl
(run "halt." at any time to exit)

Exercise 1 (Print number and name of the department in boston):
run dept_in_city('BOSTON').
Exercise 2 (List number and name of all employees in the research department):
run emp_in_dept_list('RESEARCH').
Exercise 3 (List the names of all employees who are manager or president of the company):
run list_manager_pres().
Exercise 4 (List all employees who earn more than their direct supervisor):
run emp_inflated_salary().
Exercise 5 (List all employees who are directly or indirectly managed by “JONES”):
run managed_by('JONES').

*/














%SQL statements for reference

%CREATE TABLE EMP (
% EMPNO               NUMBER(4) NOT NULL,
% ENAME               VARCHAR2(10),
% JOB                 VARCHAR2(9),
% MGR                 NUMBER(4) CONSTRAINT EMP_MGR_FK REFERENCES EMP (EMPNO),
% HIREDATE            DATE,  -- REMOVED IN PROLOG VERSION
% SAL                 NUMBER(7,2),
% COMM                NUMBER(7,2), -- REMOVED IN PROLOG VERSION
% DEPTNO              NUMBER(2) NOT NULL,
% CONSTRAINT EMP_DEPTNO_FK FOREIGN KEY (DEPTNO) REFERENCES DEPT (DEPTNO),
% CONSTRAINT EMP_EMPNO_PK PRIMARY KEY (EMPNO));

% CREATE TABLE BONUS (
% ENAME               VARCHAR2(10),
% JOB                 VARCHAR2(9),
% SAL                 NUMBER,
% COMM                NUMBER);

% CREATE TABLE SALGRADE (
% GRADE               NUMBER,
% LOSAL               NUMBER,
% HISAL               NUMBER);



% CREATE TABLE DEPT (
%  DEPTNO              NUMBER(2) NOT NULL,
%  DNAME               VARCHAR2(14),
%  LOC                 VARCHAR2(13),
%  CONSTRAINT DEPT_PRIMARY_KEY PRIMARY KEY (DEPTNO));
