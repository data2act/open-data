CREATE OR REPLACE FUNCTION formatsql(p_statement text)
  RETURNS text AS
$BODY$ 
declare 
  v_statement   text;
  v_rest    text;
  v_line    text;
  v_word    text;
  v_result  text := '';
  v_i       integer := 1;
  v_tab     integer := 12; -- minimum 10 
  v_indent  integer := 0;
  v_function    integer := 0;
begin
  v_statement := replace(trim(p_statement, ' ;' || chr(10)), chr(13), '') || ';' || chr(10); -- remove Carriage Returns
  while v_i <= length(v_statement) loop
    v_rest := substr(v_statement, v_i);

-- in-line comment; write until end of line
    if v_rest like '--%' then
      v_line := split_part(v_rest, chr(10), 1);
      raise debug 'in line comment %', v_line;
      v_result := v_result || case when v_result like '% ' or v_result like '%' || chr(10) then '' else ' ' end || v_line || chr(10);
      v_i := v_i + length(v_line) + 1;

-- comment block; write until end of block
    elseif v_rest like '/*%' then
      v_line := substr(v_rest, 1, strpos(v_rest, '*/') + 1);
      raise debug 'comment block %', v_line;
      v_result := v_result || case when v_result like '% ' or v_result like '%' || chr(10) then '' else ' ' end || v_line;
      v_i := v_i + length(v_line);

-- quoted string; write until end of string
    elseif v_rest like 'vcm_get%' then
      v_line := split_part(v_rest, ''')', 1) || ''')'||chr(10);
      raise debug 'vcm-functie %', v_line;
      v_result := v_result || v_line;
      v_i := v_i + length(v_line) - 1;
      
-- quoted string; write until end of string
    elseif v_rest like '''%' then
      v_line := '''' || split_part(v_rest, '''', 2) || '''';
      raise debug 'quoted string %', v_line;
      v_result := v_result || v_line;
      v_i := v_i + length(v_line);

    else
      v_word := substr(v_rest, 1, 
    least   (
        case when strpos(v_rest, ' ') = 0 then null else strpos(v_rest, ' ') end
    ,   case when strpos(v_rest, chr(9)) = 0 then null else strpos(v_rest, chr(9)) end
    ,   case when strpos(v_rest, chr(10)) = 0 then null else strpos(v_rest, chr(10)) end
    ,   case when strpos(v_rest, ',') = 0 then null else strpos(v_rest, ',') end
    ,   case when strpos(v_rest, ';') = 0 then null else strpos(v_rest, ';') end
    ,   case when strpos(v_rest, ')') = 0 then null else strpos(v_rest, ')') end
    ,   case when strpos(v_rest, '(') = 0 then null else strpos(v_rest, '(') end
        ) - 1);
      raise debug 'word % -', v_word;

-- keyword; uppercase and on new line
      if right(v_result,1) in ('', ' ', chr(10)) and
         upper(v_word) in ('SELECT','DELETE','INSERT','INTO','FROM','WHERE','UPDATE','SET','CREATE','DROP','ALTER','UNION','ANALYSE','LEFT','RIGHT','FULL','OUTER','INNER','JOIN','GROUP','HAVING','ORDER','BY','ON','AND','OR','WHEN','THEN','ELSE','ADD') then
        raise debug 'keyword newline %', v_word;
        v_result := v_result || case when v_result like '%' || chr(10) then '' else chr(10) end || repeat(' ', v_tab * v_indent) || upper(v_word) || repeat(' ', v_tab - length(v_word));
        v_i := v_i + length(v_word);

-- keyword; uppercase
      elseif right(v_result,1) in ('', ' ', chr(10)) and
         upper(v_word) in ('BETWEEN','DISTINCT','AS','TABLE','SEQUENCE','TEMPORARY','IN','TRUE','FALSE','PRIMARY','KEY') then
        raise debug 'keyword %', v_word;
        v_result := v_result || upper(v_word) || ' ';
        v_i := v_i + length(v_word);

-- function; uppercase
      elseif upper(v_word) in ('SUBSTR','TRIM','LTRIM','RTRIM','EXTRACT','GREATEST','LEAST','COUNT','SUM','MAX','COALESCE','CAST','STRPOS','SUBSTRING','REPLACE','UPPER','LOWER','DATE_PART','SPLIT_PART','REGEXP_SPLIT_TO_TABLE','CONCAT','TO_DATE','GENERATE_SERIES') then
        raise debug 'function %', v_word;
        v_result := v_result || upper(v_word);
        v_i := v_i + length(v_word);
        v_function := v_function + 1;

-- case
      elseif right(v_result,1) in ('', ' ', chr(10)) and
         upper(v_word) in ('CASE') then
        raise debug 'case %', v_word;
        v_result := v_result || case when v_result like '%' || chr(10) then repeat(' ', v_tab * (v_indent + 1)) else '' end || upper(v_word) || repeat(' ', v_tab - length(v_word));
        v_i := v_i + length(v_word);
        v_indent := v_indent + 2;

-- end
      elseif right(v_result,1) in ('', ' ', chr(10)) and
         upper(v_word) in ('END') then
        raise debug 'end %', v_word;
        v_indent := v_indent - 1;
        v_result := v_result || case when v_result like '%' || chr(10) then '' else chr(10) end || repeat(' ', v_tab * v_indent) || upper(v_word);
        v_i := v_i + length(v_word);
        v_indent := v_indent - 1;

-- comma; on new line
      elseif substr(v_rest, 1, 1) = ',' then
        raise debug 'comma';
        if v_function > 0 then 
          v_result := v_result || ',';
        else v_result := v_result || 
          case 
            when v_result like '%' || chr(10) then '' 
            else chr(10) 
          end || repeat(' ', v_tab * v_indent) || ',' || repeat(' ', v_tab - 1);
        end if;
        v_i := v_i + 1;

-- semicolon; on new line
      elseif substr(v_rest, 1, 1) = ';' then
        raise debug 'semicolon';
        v_result := v_result || case when v_result like '%' || chr(10) then '' else chr(10) end || ';' || chr(10) || chr(10);
        v_i := v_i + 1;

-- open bracket; on new line
      elseif substr(v_rest, 1, 1) = '(' then
        raise debug 'open bracket';
        if v_function > 0 then 
          v_result := v_result || '(';
        else 
          v_indent := v_indent + 1;
          v_result := v_result || case when v_result like '%' || chr(10) then '' else chr(10) end || repeat(' ', v_tab * v_indent) || '(' || repeat(' ', v_tab - 1);
        end if;
        v_i := v_i + 1;

-- close bracket; on new line
      elseif substr(v_rest, 1, 1) = ')' then
        raise debug 'close bracket';
        if v_function > 0 then 
          v_result := v_result || ')';
          v_function := v_function - 1;
        else 
          v_result := v_result || case when v_result like '%' || chr(10) then '' else chr(10) end || repeat(' ', v_tab * v_indent) || ')' || repeat(' ', v_tab - 1);
          v_indent := v_indent - 1;
        end if;
        v_i := v_i + 1;

      else
-- ignore space, tab and newline
        if v_function > 0 then 
          v_result := v_result || substr(v_rest, 1, 1);
        else
          if substr(v_rest, 1, 1) in (' ', chr(9), chr(10)) and right(v_result, 1) in (' ', chr(10)) then
        null;
          else
            v_result := v_result || replace(substr(v_rest, 1, 1), chr(9), ' ');
          end if;
        end if;
        v_i := v_i + 1;
      end if;
    end if;

  end loop;

-- post processing (be carefull not to mess with quotes strings)
  v_result := regexp_replace(v_result, E'GROUP[ \\n]+BY[ ]+', 'GROUP BY ' || repeat(' ', v_tab - 9),'g');
  v_result := regexp_replace(v_result, E'ORDER[ \\n]+BY[ ]+', 'ORDER BY ' || repeat(' ', v_tab - 9),'g');
  v_result := regexp_replace(v_result, E'LEFT[ \\n]+JOIN[ ]+', 'LEFT JOIN ' || repeat(' ', v_tab - 10),'g');
  v_result := regexp_replace(v_result, E'LEFT[ \\n]+OUTER[ \\n]+JOIN[ ]+', 'LEFT OUTER JOIN ' || repeat(' ', v_tab - least(v_tab, 16)),'g');
  v_result := regexp_replace(v_result, E'BETWEEN ([\\x020-\\x0ff]*)[ \\n]+AND[ ]+', E'BETWEEN \\1 AND ', 'g');
  v_result := regexp_replace(v_result, E'EXTRACT ([\\x020-\\x0ff]*)[ \\n]+FROM[ ]+', E'EXTRACT \\1 FROM ', 'g');

  return ltrim(v_result, ' ' || chr(10));
end;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
--ALTER FUNCTION formatsql(text)
--  OWNER TO vcs;



