create or replace package xt_regexp is
  -- Author  : Sayan Malakshinov aka XTender
  -- Created : 27.10.2010 16:02:37
  -- 2017-1019: +pragma UDF +deterministic 
  CANON_EQ          constant number := 128;
  CASE_INSENSITIVE  constant number := 2;
  COMMENTS          constant number := 4;
  DOTALL            constant number := 32;
	MULTILINE         constant number := 8;
	UNICODE_CAS       constant number := 64;
	UNIX_LINES        constant number := 1;

  function split_simple(p_str in varchar2,p_delim in varchar2)
    return varchar2_table pipelined;
    
  function clob_split_simple(p_clob in clob,p_delim in varchar2) 
    return clob_table pipelined;
/**
 * function split. Split string by regexp and returns 
 */
  function split(pStr varchar2,pDelimRegexp varchar2,pMaxCount number default 0)
    return varchar2_table;
/**
 * Matches
 */
  function matches(pStr varchar2,pPattern varchar2,
    pCANON_EQ number default 0,
    pCASE_INSENSITIVE number default 0,
    pCOMMENTS         number default 0,
    pDOTALL           number default 0,
    pMULTILINE        number default 0,
    pUNICODE_CAS      number default 0,
    pUNIX_LINES       number default 0
    )
    return boolean;
/**
 * Matches count
 */
  function matches_count(pStr varchar2,pPattern varchar2,
    pCANON_EQ number default 0,
    pCASE_INSENSITIVE number default 0,
    pCOMMENTS         number default 0,
    pDOTALL           number default 0,
    pMULTILINE        number default 0,
    pUNICODE_CAS      number default 0,
    pUNIX_LINES       number default 0
    )
    return number deterministic;
/**
 * get_matches
 */
  function get_matches(
    pStr varchar2,
    pPattern varchar2,
    pGroup number default 0,
    pMaxCount number default 0,
        pCANON_EQ number default 0,
        pCASE_INSENSITIVE number default 0,
        pCOMMENTS         number default 0,
        pDOTALL           number default 0,
        pMULTILINE        number default 0,
        pUNICODE_CAS      number default 0,
        pUNIX_LINES       number default 0)
    return varchar2_table;
/**
 * join_matches
 */
  function join_matches(pStr varchar2,pPattern varchar2,pGroup number default 0,pDelim varchar2 default ';',
        pCANON_EQ number default 0,
        pCASE_INSENSITIVE number default 0,
        pCOMMENTS         number default 0,
        pDOTALL           number default 0,
        pMULTILINE        number default 0,
        pUNICODE_CAS      number default 0,
        pUNIX_LINES       number default 0)
    return varchar2 deterministic;

  function replace_first(pStr varchar2,pPattern varchar2,pReplacement varchar2)
    return varchar2 deterministic
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.replaceFirst(java.lang.String,java.lang.String,java.lang.String) return java.lang.String';

  function replace_all(pStr varchar2,pPattern varchar2,pReplacement varchar2)
    return varchar2 deterministic
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.replaceAll(java.lang.String,java.lang.String,java.lang.String) return java.lang.String';

  function replace_char(pStr varchar2,pPattern varchar2,pReplacement varchar2)
    return varchar2 deterministic
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.replaceChar(java.lang.String,java.lang.String,java.lang.String) return java.lang.String';
/**
 * Function returning longest identical substring
 */
  function longest_overlap(str1 varchar2,str2 varchar2,modifier varchar2 default 'i') return varchar2 deterministic;
/**
 * Function replace matches with result of your function(number_match,match_string)
 */
  function replace_by_func(p_str in varchar2, p_pattern in varchar2, p_func in varchar2) return varchar2 deterministic;
end xt_regexp;
/
create or replace package body xt_regexp is
/**
 * function split_simple
 */
  function split_simple(p_str in varchar2,p_delim in varchar2)
  return varchar2_table pipelined is
    l_b number:=1;
    l_e number:=1;
    $IF DBMS_DB_VERSION.ver_le_11 $THEN
    $ELSE
    pragma UDF;
    $END
  begin
    while l_e>0
      loop
        l_e:=instr(p_str,p_delim,l_b);
        if l_e>0 then
          pipe row(substr(p_str,l_b,l_e-l_b));
          l_b:=l_e+1;
        else
          pipe row(substr(p_str,l_b));
        end if;
      end loop;
  end split_simple;
  
/**
 * Clob simple split
 */
  function clob_split_simple(p_clob in clob,p_delim in varchar2) 
  return clob_table pipelined is
    row clob;
    l_b number:=1;
    l_e number:=1;
    $IF DBMS_DB_VERSION.ver_le_11 $THEN
    $ELSE
    pragma UDF;
    $END
  begin
      while l_e>0
        loop
          l_e:=dbms_lob.instr(p_clob,p_delim,l_b);
          if l_e>0 then
            pipe row(substr(p_clob,l_b,l_e-l_b));
            l_b:=l_e+1;
          else
            pipe row(substr(p_clob,l_b,dbms_lob.getlength(p_clob)+1-l_b));
          end if;
        end loop;
  end clob_split_simple;
/**
 * function split
 */
  function split_j(pStr varchar2, pDelimRegexp varchar2, pMaxCount number)
    return varchar2_table
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.split(java.lang.String,java.lang.String,int) return oracle.sql.ARRAY';

  function split(pStr varchar2,pDelimRegexp varchar2,pMaxCount number default 0)
    return varchar2_table is
    $IF DBMS_DB_VERSION.ver_le_11 $THEN
    $ELSE
    pragma UDF;
    $END
    begin
      return split_j(pStr, pDelimRegexp, pMaxCount);
    end split;
/**
 * function matches
 */
  function matches_j(pStr varchar2,pPattern varchar2,pFlags number)
    return boolean
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.matches(java.lang.String,java.lang.String,int) return boolean';

  function matches(pStr varchar2,pPattern varchar2,
    pCANON_EQ         number default 0,
    pCASE_INSENSITIVE number default 0,
    pCOMMENTS         number default 0,
    pDOTALL           number default 0,
    pMULTILINE        number default 0,
    pUNICODE_CAS      number default 0,
    pUNIX_LINES       number default 0
    )
    return boolean is
    $IF DBMS_DB_VERSION.ver_le_11 $THEN
    $ELSE
    pragma UDF;
    $END
    begin
      return matches_j(pStr,pPattern,
               case when pCANON_EQ        >0 then CANON_EQ         else 0 end+
               case when pCASE_INSENSITIVE>0 then CASE_INSENSITIVE else 0 end+
               case when pCOMMENTS        >0 then COMMENTS         else 0 end+
               case when pDOTALL          >0 then DOTALL           else 0 end+
               case when pMULTILINE       >0 then MULTILINE        else 0 end+
               case when pUNICODE_CAS     >0 then UNICODE_CAS      else 0 end+
               case when pUNIX_LINES      >0 then UNIX_LINES       else 0 end
             );
    end matches;
    
/**
 * function matches_count
 */
  function matches_count_j(pStr varchar2,pPattern varchar2,pFlags number)
    return number
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.matches_count(java.lang.String,java.lang.String,int) return int';

  function matches_count(pStr varchar2,pPattern varchar2,
    pCANON_EQ         number default 0,
    pCASE_INSENSITIVE number default 0,
    pCOMMENTS         number default 0,
    pDOTALL           number default 0,
    pMULTILINE        number default 0,
    pUNICODE_CAS      number default 0,
    pUNIX_LINES       number default 0
    )
    return number is
    $IF DBMS_DB_VERSION.ver_le_11 $THEN
    $ELSE
    pragma UDF;
    $END
    begin
      return matches_count_j(pStr,pPattern,
               case when pCANON_EQ        >0 then CANON_EQ         else 0 end+
               case when pCASE_INSENSITIVE>0 then CASE_INSENSITIVE else 0 end+
               case when pCOMMENTS        >0 then COMMENTS         else 0 end+
               case when pDOTALL          >0 then DOTALL           else 0 end+
               case when pMULTILINE       >0 then MULTILINE        else 0 end+
               case when pUNICODE_CAS     >0 then UNICODE_CAS      else 0 end+
               case when pUNIX_LINES      >0 then UNIX_LINES       else 0 end
             );
    end matches_count;
/**
 * function  get_matches
 */
  function get_matches_j(pStr varchar2,pPattern varchar2,pGroup number, pFlags number,pMaxCount number)
    return varchar2_table
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.getMatches(java.lang.String,java.lang.String,int,int,int) return oracle.sql.ARRAY';

  function get_matches(
    pStr varchar2,
    pPattern varchar2,
    pGroup number default 0,
    pMaxCount number default 0,
        pCANON_EQ         number default 0,
        pCASE_INSENSITIVE number default 0,
        pCOMMENTS         number default 0,
        pDOTALL           number default 0,
        pMULTILINE        number default 0,
        pUNICODE_CAS      number default 0,
        pUNIX_LINES       number default 0)
    return varchar2_table is
    lFlags number;
    $IF DBMS_DB_VERSION.ver_le_11 $THEN
    $ELSE
    pragma UDF;
    $END
    begin
      lFlags:=case when pCANON_EQ         >0 then CANON_EQ          else 0 end+
               case when pCASE_INSENSITIVE>0 then CASE_INSENSITIVE else 0 end+
               case when pCOMMENTS        >0 then COMMENTS         else 0 end+
               case when pDOTALL          >0 then DOTALL           else 0 end+
               case when pMULTILINE       >0 then MULTILINE        else 0 end+
               case when pUNICODE_CAS     >0 then UNICODE_CAS      else 0 end+
               case when pUNIX_LINES      >0 then UNIX_LINES       else 0 end;
      dbms_output.put_line(lFlags);
      return get_matches_j(pStr,pPattern,pGroup,lFlags,pMaxCount);
--        return varchar2_table(cast(pMaxCount as varchar2));
    end get_matches; 
/**
 * function join_matches
 */
  function join_matches_j(pStr varchar2,pPattern varchar2,pGroup number,pFlags number, pDelim varchar2)
    return varchar2
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.joinMatches(java.lang.String,java.lang.String,int,java.lang.String) return java.lang.String';

  function join_matches(pStr varchar2,pPattern varchar2, pGroup number default 0, pDelim varchar2 default ';',
        pCANON_EQ         number default 0,
        pCASE_INSENSITIVE number default 0,
        pCOMMENTS         number default 0,
        pDOTALL           number default 0,
        pMULTILINE        number default 0,
        pUNICODE_CAS      number default 0,
        pUNIX_LINES       number default 0)
    return varchar2 deterministic is 
    $IF DBMS_DB_VERSION.ver_le_11 $THEN
    $ELSE
    pragma UDF;
    $END
    begin
      return join_matches_j(pStr,pPattern,pGroup,
               case when pCANON_EQ        >0 then CANON_EQ         else 0 end+
               case when pCASE_INSENSITIVE>0 then CASE_INSENSITIVE else 0 end+
               case when pCOMMENTS        >0 then COMMENTS         else 0 end+
               case when pDOTALL          >0 then DOTALL           else 0 end+
               case when pMULTILINE       >0 then MULTILINE        else 0 end+
               case when pUNICODE_CAS     >0 then UNICODE_CAS      else 0 end+
               case when pUNIX_LINES      >0 then UNIX_LINES       else 0 end,
               pDelim);
    end;
/**
 * Function returning longest identical substring
 */
  function longest_overlap(str1 varchar2,str2 varchar2,modifier varchar2 default 'i') return varchar2 deterministic
  is
   i       pls_integer;
   j       pls_integer;
   l       pls_integer:=0;
   max_str varchar2(4000):='';
   l_str1  varchar2(4000);
   l_str2  varchar2(4000);
    $IF DBMS_DB_VERSION.ver_le_11 $THEN
    $ELSE
    pragma UDF;
    $END
  begin
    l_str1:=case lower(modifier) when 'i' then upper(str1) else str1 end;
    l_str2:=case lower(modifier) when 'i' then upper(str2) else str2 end;
    for i in 1..length(l_str1) loop
      j:=l+1;
      loop
        exit when instr(l_str2,substr(l_str1,i,j))=0 or i+j-1>length(l_str2);
        l:=j;
        max_str:=substr(str1,i,j);
        j:=j+1;
      end loop;
    end loop;
    return max_str;
  end longest_overlap;
/**
 * Function replace matches with result of your function(number_match,match_string)
 */
  function replace_by_func(p_str in varchar2, p_pattern in varchar2, p_func in varchar2) return varchar2 is
    l_str varchar2(4000):=p_str;
    match varchar2(4000);
    rep_str varchar2(4000);
    c number:=0;
    p number:=1;
    l number;
  begin
    loop
      match:=regexp_substr(l_str,p_pattern,p,1);
      exit when length(match) is null;
      c:=c+1;
      p:=p+instr(substr(l_str,p),match)-1;
      l:=length(match);
      execute immediate 'select '||p_func||'(:1,:2) from dual' into rep_str using c,match;
      l_str:=regexp_replace(
                           l_str,
                           p_pattern,
                           rep_str
                          ,p,1);
      p:=p+length(rep_str);
    end loop;

    execute immediate
    'select '''
           ||l_str
           ||''' from dual'
     into l_str;

    return(l_str);
  end replace_by_func;
end xt_regexp;
/
