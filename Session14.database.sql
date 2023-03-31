use master

if exists (select * from sys.databases where name ='Session14')
drop database Session14

create database Session14

use Session14

--PART 2
	
create table Classes (
  className char(6),
  teacher varchar(30),
  timeShot varchar(30),
  class int,
  lab int
)

--1: tạo 1 unique, clustered index trên trường clasName với thuộc tính:
-- pad_index = on ,  fillFactor = 70, ignore_dup_key = on

create  unique clustered index MyClusteredIndex 
on Classes(className)
with ( pad_index = on,
       fillfactor = 70,
	   ignore_dup_key = on)

 
--2: tạo 1 nonClustered index trên teacher

create nonclustered index TeacherIndex
on Classes(teacher)

--3: xóa chỉ mục Teacher Index

drop index if exists TeacherIndex
on Classes

--4: tạo lại MyClusteredIndex vói các thuộc tính: DROP_	EXISTING,
--ALLOW_ROW_LOCKS, ALLOW_PAGE_LOCKS = ON, MAXDOP = 2

CREATE UNIQUE CLUSTERED index MyClusteredIndex
on Classes(className)
with (DROP_EXISTING = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, 
MAXDOP = 2)
go

--5: tạo một composite index là ClassLabIndex trên Class và Lab
create index ClassLabIndex on Classes (class, lab)
go
--6: Viết câu lệnh xem toàn bộ các chỉ mục - index của cơ sở dữ liệu 

select * from 
sys.indexes 


-- PART 3:

create table Student (
  StudentNo int primary key,
  StudentName varchar(50) not null,
  StudentAddress varchar(100) ,
  PhoneNo int not null
)


create table Department (
   DeptNo int primary key,
   DeptName varchar(50) not null,
   ManagerName char(30) not null
)


create table Assignment (
   AssignmentNo int primary key,
   Description varchar(100) not null
)


create table Works_Assign (
  JobId int primary key,
  StudentNo int foreign key references Student(StudentNo),
  AssignmentNo int foreign key references Assignment(AssignmentNo),
  TotalHours int ,
  JobDetails XML

)

--1: hiển thị tên sv và mã số sv: tạo một clustered index là IX_Student
-- trên cột StudentNo 
--trong khi chỉ mục được tạo, các bảng và các chỉ mục có thể được 
--truy vấn và thay đổi dữ liệu

SELECT TOP 1 [Current LSN]
 FROM fn_dblog(null,null)
 ORDER BY [Current LSN] DESC
 GO
 -- Online index operations can only be performed in Enterprise edition of SQL Server or Azure SQL Edge.
create index StudentIndex
on  Student (StudentNo)
With (ONLINE = ON ) -- khong tao dc

--2: rebuild lại IX_Student trong đó các bảng và chỉ mục không được phép
--sủ dụng để truy vấn và thay đổi dữ liệu


--online:Chỉ định liệu các bảng bên dưới có thể truy cập được để truy vấn và sửa đổi dữ liệu trong quá trình thao tác chỉ mục hay không.  
create index StudentIndex
on Student(StudentNo)
with (online = off)


--3: tạo NotClustered index IX_Dept 

create  NONCLUSTERED INDEX IX_DEPT
ON Department(DeptNo, DeptName, ManagerName )