###Data Cleaning

Data cleaning involves

- checking that character variables contain only valid values
- checking that numeric values are within predetermined ranges
- checking for missing values for variables where complete data is necessary
- checking for deuplicate data entries of certain values such as patient IDs
- checking for invalid date values

Main `PROC SQL` terminology:
```
PROC SQL options; 
    SELECT   column(s)
    FROM     table-name
    WHERE    expression 
    GROUP BY column(s) 
    HAVING   expression
    ORDER BY column(s);
QUIT;

```

This is how you produce frequency counts:
```
PROC SQL;
    SELECT   column_name, count(*)
    FROM     table_name
    GROUP BY column_name;
QUIT;
```

Use the `IN` operator to make sure that values are in the expected list:

```
NUM IN (3,4,5);
NUM IN (3 4 5);
NAME IN ('John', 'Mary');
NAME IN ('John' 'Mary');
```



