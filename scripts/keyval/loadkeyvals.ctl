OPTIONS (SKIP=1,ERRORS = 0)
load data
infile '.csv'
APPEND into table keyvals
TRAILING NULLCOLS
(
        file        CHAR TERMINATED BY ',',
        thekey      CHAR TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"',
        theval      CHAR TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
)

