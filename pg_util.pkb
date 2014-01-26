CREATE OR REPLACE PACKAGE BODY PG_UTIL IS

FUNCTION f_delimited_to_table (
	av_list VARCHAR2,
	av_delimiter VARCHAR2
  )
RETURN t_varchar20_table PIPELINED
IS
  li_start INTEGER := 1;
  li_end INTEGER;
  lv_str VARCHAR2(2000);
  ac_separator CHAR := av_delimiter;
BEGIN
	IF av_list IS NULL THEN
		RETURN;
	END IF;
  LOOP
  	li_end := INSTR( av_list, ac_separator, li_start);
  	EXIT WHEN li_end = 0;
  	-- get the substring to be inserted as new row in table collection
  	lv_str := SUBSTR(av_list, li_start, li_end - li_start );
  	--dbms_output.put_line(av_list||':   '||lv_str||'    '||length(lv_str));
  	PIPE ROW(lv_str);
  	-- set next start position
  	li_start := li_end + 1;
  END LOOP;
 	lv_str := SUBSTR(av_list, li_start, LENGTH(av_list) - li_start + 1 );
 	PIPE ROW(lv_str);
  RETURN;
END;

Function f_get_nth_occurrence(
	av_list VARCHAR2,
	av_delimiter varchar2,
	av_occurrence integer
  )
RETURN varchar2
IS
	lv_retval VARCHAR2(500):='';
BEGIN
	Select column_value into lv_retval from (select rownum as the_row_num, column_value from table(f_delimited_to_table(av_list ,av_delimiter))) where the_row_num = av_occurrence;
	return lv_retval;
END;

FUNCTION f_eliminate_dupes_and_sort (
	av_list VARCHAR2,
	av_delimiter varchar2
  )
RETURN varchar2
IS
	lv_formatted VARCHAR2(2000):='';
BEGIN
	if av_list is NULL then
		RETURN null;
	END IF;
	FOR lc_ValueList IN
		(select distinct column_value from table(f_delimited_to_table(av_list,av_delimiter)) order by 1)
	LOOP
	lv_formatted := lv_formatted || lc_ValueList.column_value || av_delimiter;
	END LOOP;
	lv_formatted := replace(lv_formatted,av_delimiter || av_delimiter,av_delimiter);
	lv_formatted := substr(lv_formatted,1,length(lv_formatted)-1);
	return lv_formatted;
END;

FUNCTION f_to_decimal (
	av_value VARCHAR2
  )
RETURN NUMBER
IS
BEGIN
	RETURN TO_NUMBER(av_value, gv_decimal_format);
EXCEPTION
	WHEN OTHERS THEN
		RETURN NULL;
END;

Function replace_non_nums_and_chars(av_value VARCHAR2)
return varchar2
IS
	retval varchar2(2000):=av_value;
Begin
	select
	    replace(stragg(let),',','') into retval
	from
	    (select
		Candidate.stringval,
		c.counter,
		substr(candidate.stringval,c.counter,1) let,
		ascii(upper(substr(candidate.stringval,c.counter,1))) as ascval
	    from
		(select av_value as stringval from dual) Candidate
	    cross join (select counter from counter where counter>0) c
	    where c.counter<=length(Candidate.stringval)
	    order by counter
	    )
	where ((ascval >=48 and ascval<=57) or (ascval>=65 and ascval<=90))
	order by counter;

	return retval;

end;


FUNCTION f_sort (
	av_list VARCHAR2,
	av_delimiter varchar2
  )
RETURN varchar2
IS
	lv_formatted VARCHAR2(32767):='';
BEGIN
	if av_list is NULL then
		RETURN null;
	END IF;
	FOR lc_ValueList IN
		(select column_value from table(f_delimited_to_table(av_list,av_delimiter)) order by 1)
	LOOP
	lv_formatted := lv_formatted || lc_ValueList.column_value || av_delimiter;
	END LOOP;
	lv_formatted := replace(lv_formatted,av_delimiter || av_delimiter,av_delimiter);
	lv_formatted := substr(lv_formatted,1,length(lv_formatted)-1);
	return lv_formatted;
END;

FUNCTION f_sort_numeric (
	av_list VARCHAR2,
	av_delimiter varchar2
  )
RETURN varchar2
IS
	lv_formatted VARCHAR2(32767):='';
BEGIN
	if av_list is NULL then
		RETURN null;
	END IF;
	FOR lc_ValueList IN
		(select cast(column_value as decimal(26,10)) as column_value1 from table(f_delimited_to_table(av_list,av_delimiter)) order by 1 desc)
	LOOP
	lv_formatted := lv_formatted || lc_ValueList.column_value1 || av_delimiter;
	END LOOP;
	lv_formatted := replace(lv_formatted,av_delimiter || av_delimiter,av_delimiter);
	lv_formatted := substr(lv_formatted,1,length(lv_formatted)-1);
	return lv_formatted;
END;

FUNCTION f_eliminate_ones_with (
	av_list VARCHAR2,
	av_delimiter varchar2,
	av_eliminate varchar2
  )
RETURN varchar2
IS
	lv_formatted VARCHAR2(32767):='';
BEGIN
	if av_list is NULL then
		RETURN null;
	END IF;
	FOR lc_ValueList IN
		(select distinct column_value from table(f_delimited_to_table(av_list,av_delimiter)) order by 1)
	LOOP
		if instr(lc_ValueList.column_value, av_eliminate) = 0 then
			lv_formatted := lv_formatted || lc_ValueList.column_value || av_delimiter;
		end if;
	END LOOP;
	lv_formatted := replace(lv_formatted,av_delimiter || av_delimiter,av_delimiter);
	lv_formatted := substr(lv_formatted,1,length(lv_formatted)-1);
	return lv_formatted;
END;

Function get_LOV(sourcestr VARCHAR2,toget VARCHAR2)
return varchar2
IS
	retval varchar2(32767);
	s varchar2(32767);
	candidate varchar2(200);
Begin

	if sourcestr is NULL then
		RETURN null;
	END IF;
	retval:='';
	FOR lc_ValueList IN
		(select distinct column_value from table(f_delimited_to_table(replace(sourcestr,' ',''),',')))
	LOOP
		select max(specused) into candidate from pivotparts where partnum = rtrim(ltrim(lc_ValueList.column_value)) and accepted = 'Y';
		if candidate is not null then
			retval:=retval ||',' || candidate;
		end if;
	END LOOP;
	return f_eliminate_dupes_and_sort(retval,',');
end;

-- Return: gets number by eliminating all non-numeric characters
FUNCTION f_get_number(
	av_value VARCHAR2
	)
RETURN NUMBER
IS
BEGIN
	RETURN TO_NUMBER(REGEXP_REPLACE(av_value, '\D*', ''));
END;

FUNCTION f_get_number_string(
	av_value VARCHAR2
	)
RETURN varchar2
IS
BEGIN
	RETURN REGEXP_REPLACE(av_value, '\D*', '');
END;

function isNumber(p in varchar2)
return varchar2
is
test number;
begin
	test := to_number(p);
	return 'Y';
exception
	when VALUE_ERROR then return 'N';
end;
END;
/
