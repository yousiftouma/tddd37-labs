# Lab 1, Viktor Holmgren (vikho394) and Yousif Touma (youto814)

## Question 1
mysql> select * from jbemployee;
+------+--------------------+--------+---------+-----------+-----------+
| id   | name               | salary | manager | birthyear | startyear |
+------+--------------------+--------+---------+-----------+-----------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |
+------+--------------------+--------+---------+-----------+-----------+
25 rows in set (0.00 sec)

## Question 2
mysql> select name from jbdept order by name;
+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
| Women's          |
| Women's          |
+------------------+
19 rows in set (0.00 sec)

## Question 3
mysql> select * from jbparts where qoh = 0;
+----+-------------------+-------+--------+------+
| id | name              | color | weight | qoh  |
+----+-------------------+-------+--------+------+
| 11 | card reader       | gray  |    327 |    0 |
| 12 | card punch        | gray  |    427 |    0 |
| 13 | paper tape reader | black |    107 |    0 |
| 14 | paper tape punch  | black |    147 |    0 |
+----+-------------------+-------+--------+------+
4 rows in set (0.00 sec)

## Question 4
mysql> select * from jbemployee where salary >= 9000 and salary <= 10000;
+-----+----------------+--------+---------+-----------+-----------+
| id  | name           | salary | manager | birthyear | startyear |
+-----+----------------+--------+---------+-----------+-----------+
|  13 | Edwards, Peter |   9000 |     199 |      1928 |      1958 |
|  32 | Smythe, Carol  |   9050 |     199 |      1929 |      1967 |
|  98 | Williams, Judy |   9000 |     199 |      1935 |      1969 |
| 129 | Thomas, Tom    |  10000 |     199 |      1941 |      1962 |
+-----+----------------+--------+---------+-----------+-----------+
4 rows in set (0.00 sec)

## Question 5
mysql> select name, startyear-birthyear as age from jbemployee;
+--------------------+------+
| name               | age  |
+--------------------+------+
| Ross, Stanley      |   18 |
| Ross, Stuart       |    1 |
| Edwards, Peter     |   30 |
| Thompson, Bob      |   40 |
| Smythe, Carol      |   38 |
| Hayes, Evelyn      |   32 |
| Evans, Michael     |   22 |
| Raveen, Lemont     |   24 |
| James, Mary        |   49 |
| Williams, Judy     |   34 |
| Thomas, Tom        |   21 |
| Jones, Tim         |   20 |
| Bullock, J.D.      |    0 |
| Collins, Joanne    |   21 |
| Brunet, Paul C.    |   21 |
| Schmidt, Herman    |   20 |
| Iwano, Masahiro    |   26 |
| Smith, Paul        |   21 |
| Onstad, Richard    |   19 |
| Zugnoni, Arthur A. |   21 |
| Choy, Wanda        |   23 |
| Wallace, Maggie J. |   19 |
| Bailey, Chas M.    |   19 |
| Bono, Sonny        |   24 |
| Schwarz, Jason B.  |   15 |
+--------------------+------+
25 rows in set (0.00 sec)

## Question 6
mysql> select * from jbemployee where name like "%son,%";
+----+---------------+--------+---------+-----------+-----------+
| id | name          | salary | manager | birthyear | startyear |
+----+---------------+--------+---------+-----------+-----------+
| 26 | Thompson, Bob |  13000 |     199 |      1930 |      1970 |
+----+---------------+--------+---------+-----------+-----------+
1 row in set (0.00 sec)

## Question 7
mysql> select * from jbitem where supplier = (select id from jbsupplier where name = "Fisher-Price");
+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
+-----+-----------------+------+-------+------+----------+
3 rows in set (0.00 sec)

## Question 8
mysql> select i.* from jbitem as i, jbsupplier as s where s.name = "Fisher-price" and i.supplier = s.id;
+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
+-----+-----------------+------+-------+------+----------+
3 rows in set (0.00 sec)

## Question 9
mysql> select * from jbcity where id in (select city from jbsupplier);
+-----+----------------+-------+
| id  | name           | state |
+-----+----------------+-------+
|  10 | Amherst        | Mass  |
|  21 | Boston         | Mass  |
| 100 | New York       | NY    |
| 106 | White Plains   | Neb   |
| 118 | Hickville      | Okla  |
| 303 | Atlanta        | Ga    |
| 537 | Madison        | Wisc  |
| 609 | Paxton         | Ill   |
| 752 | Dallas         | Tex   |
| 802 | Denver         | Colo  |
| 841 | Salt Lake City | Utah  |
| 900 | Los Angeles    | Calif |
| 921 | San Diego      | Calif |
| 941 | San Francisco  | Calif |
| 981 | Seattle        | Wash  |
+-----+----------------+-------+
15 rows in set (0.00 sec)

## Question 10
mysql> select name, color from jbparts where weight > (select weight from jbparts where name = "card reader");
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.00 sec)

## Question 11
mysql> select p.name, p.color from jbparts as p, jbparts as p2 where p.weight > p2.weight and p2.name = "card reader";
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.00 sec)

## Question 12
mysql> select avg(weight) from jbparts where color = "black";
+-------------+
| avg(weight) |
+-------------+
|    347.2500 |
+-------------+
1 row in set (0.00 sec)

## Question 13
mysql> 
	select 
		jbsupplier.name, sum(weight * quan) 
	from 
		jbsupplier, jbsupply, jbparts 
	where 
		city in (select id from jbcity where state = "Mass") 
		and supplier = jbsupplier.id 
		and jbsupply.part = jbparts.id 
	group by jbsupplier.name;
+--------------+--------------------+
| name         | sum(weight * quan) |
+--------------+--------------------+
| DEC          |               3120 |
| Fisher-Price |            1135000 |
+--------------+--------------------+
2 rows in set (0.00 sec)

## Question 14
mysql> create table items(
    -> id integer,
    -> name varchar(120),
    -> dept integer,
    -> price integer,
    -> qof integer,
    -> supplier integer,
    -> constraint pk_items
    -> primary key (id),
    -> constraint fk_dept
    -> foreign key (dept) references jbdept(id),
    -> constraint fk_supplier
    -> foreign key (supplier) references jbsupplier(id)
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql> 
	insert into items 
		(select * from jbitem where price < (select avg(price) from jbitem));
Query OK, 14 rows affected (0.01 sec)
Records: 14  Duplicates: 0  Warnings: 0

## Question 15
mysql> 
	create view item_view as 
		select * from jbitem where price < (select avg(price) from jbitem);
Query OK, 0 rows affected (0.00 sec)

## Question 16
A table needs to be updated continuously (it is static) where as a view is a virtual table that gets updated when the corresponding values gets updated in the backing table(s) (it is dynamic).
So a table is static where as a view is dynamic.

## Question 17
mysql> 
	create view debits as 
		select 
			jbdebit.id, sum(quantity*price) 
		from 
			jbdebit, jbsale, jbitem 
		where 
			jbdebit.id = debit and jbitem.id = item 
		group by jbdebit.id;
Query OK, 0 rows affected (0.00 sec)

## Question 18
mysql> 
	create view debits2 as 
		select 
			jbdebit.id, sum(quantity*price) 
		from 
			jbsale 
				inner join jbdebit on debit = jbdebit.id 
				inner join jbitem on item = jbitem.id 
		group by jbdebit.id;
Query OK, 0 rows affected (0.00 sec)

In this case it should not matter which join you use since we don't have any rows containing null values for the values we check for equivalence. In the general case inner join is what you want for this problem because you might have null values and you only want to keep rows where the checked values are exactly matched.

## Question 19
**a**

mysql> 
	delete 
		from jbsale 
		where item in 
			(select id from jbitem where supplier = 
				(select id from jbsupplier where city = 
					(select id from jbcity where name = "Los Angeles")
				)
			);
Query OK, 1 row affected (0.01 sec)

mysql> 
	delete 
		from jbitem 
		where 
			supplier = 
				(select id from jbsupplier where city = 
					(select id from jbcity where name = "Los Angeles")
				);
Query OK, 2 rows affected (0.01 sec)

mysql> 
	delete 
		from jbsupplier 
		where 
			city = (select id from jbcity where name = "Los Angeles"); 
Query OK, 1 row affected (0.00 sec)

**b**

What happened here is that there was foreign key constraints from sale -> item -> supplier so we needed to delete all tuples in sale that in the end had Los Angeles as the city where their supplier was located.

The same was done with all items that in the end has Los Angeles as the city where their supplier was located.

Finally we could delete the suppliers that were located in Los Angeles.

## Question 20
mysql> 
	create view jbsale_supply(supplier, item, quantity) as 
		select 
			jbsupplier.name as supplier, jbitem.name as item, jbsale.quantity 
		from 
			jbsupplier 
				inner join jbitem on jbsupplier.id = jbitem.supplier 
				left join jbsale on jbsale.item = jbitem.id;
Query OK, 0 rows affected (0.01 sec)



