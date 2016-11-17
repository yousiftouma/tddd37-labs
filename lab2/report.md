# Lab 1, Viktor Holmgren (vikho394) and Yousif Touma (youto814)

## Question 1

**ADD IMAGE HERE**

## Question 2

**ADD IMAGE HERE**

## Question 3
mysql> create table jbmanager( 
	id integer, 
	bonus integer not null default 0, 

	constraint pk_manager 
		primary key (id), 

	constraint fk_id 
		foreign key (id) references jbemployee(id)
);
Query OK, 0 rows affected (0.04 sec)

mysql> insert into jbmanager (id) 
	(select DISTINCT manager from jbemployee where manager is not null);
Query OK, 8 rows affected (0.00 sec)
Records: 8  Duplicates: 0  Warnings: 0

mysql> alter table jbemployee drop foreign key fk_emp_mgr;
Query OK, 25 rows affected (0.05 sec)
Records: 25  Duplicates: 0  Warnings: 0

mysql> alter table jbemployee 
	add constraint fk_emp_mgr 
		foreign key (manager) references jbmanager(id);
Query OK, 25 rows affected (0.07 sec)
Records: 25  Duplicates: 0  Warnings: 0

mysql> alter table jbdept drop foreign key fk_dept_mgr;
Query OK, 19 rows affected (0.05 sec)
Records: 19  Duplicates: 0  Warnings: 0

mysql> insert into jbmanager (id) 
	(select distinct manager from jbdept where manager not in 
		(select id from jbmanager));
Query OK, 4 rows affected (0.00 sec)
Records: 4  Duplicates: 0  Warnings: 0

mysql> alter table jbdept add constraint fk_dept_mgr 
	foreign key (manager) references jbmanager(id);
Query OK, 19 rows affected (0.03 sec)
Records: 19  Duplicates: 0  Warnings: 0

Regarding the initalization, it should not be needed, however then we would
have to check whether the bonus attribute is null before adding, or subtracting
to it for example.

## Question 4
mysql> update jbmanager set bonus = bonus + 10000 where id in (select distinct manager from jbdept);
Query OK, 11 rows affected (0.00 sec)
Rows matched: 11  Changed: 11  Warnings: 0

## Question 5

mysql> create table customer (
	id integer, street varchar(120),
	name varchar(120), city integer not null,
	constraint pk_customer primary key (id),
	constraint fk_city foreign key (city) references jbcity(id));
Query OK, 0 rows affected (0.02 sec)

mysql> create table account(
	account_number integer,
	balance integer not null default 0,
	owner integer,
	constraint pk_account primary key (account_number),
	constraint fk_owner foreign key (owner) references customer(id));
Query OK, 0 rows affected (0.02 sec)

mysql> create table transaction(
	transaction_number integer,
	timestamp timestamp not null default current_timestamp,
	amount integer not null,
	account integer not null, 
	responsible integer not null, 
	constraint pk_transaction 
		primary key (transaction_number), 
	constraint fk_account 
		foreign key (account) references account(account_number), 
	constraint fk_responsible 
		foreign key (responsible) references jbemployee(id)
	);
Query OK, 0 rows affected (0.02 sec)

mysql> create table withdrawal (
	id integer, 
	constraint pk_withdrawal primary key (id), 
	constraint fk_transaction 
		foreign key (id) references transaction(transaction_number)
	);
Query OK, 0 rows affected (0.01 sec)

mysql> create table deposit(
	id integer, 
	constraint pk_deposit primary key (id), 
	constraint fk_transaction2 foreign key (id) references transaction(transaction_number));
Query OK, 0 rows affected (0.01 sec)

mysql> truncate jbsale;
Query OK, 0 rows affected (0.03 sec)

mysql> alter table jbsale drop foreign key fk_sale_debit;
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> drop table jbdebit;
Query OK, 0 rows affected (0.02 sec)

mysql> create table debit(
	id integer, 
	constraint pk_debit primary key (id), 
	constraint fk_transaction3 foreign key (id) references transaction(transaction_number));
Query OK, 0 rows affected (0.03 sec)

mysql> alter table jbsale add constraint fk_sale_debit foreign key (debit) references debit(id);
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

