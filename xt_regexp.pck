create or replace package xt_regexp is
  -- Author  : Sayan Malakshinov aka XTender
  -- Created : 27.10.2010 16:02:37
  CANON_EQ          constant number := 128;
  CASE_INSENSITIVE  constant number := 2;
  COMMENTS          constant number := 4;
  DOTALL            constant number := 32;
	MULTILINE         constant number := 8;
	UNICODE_CAS       constant number := 64;
	UNIX_LINES        constant number := 1;

  function split_simple(p_str in varchar2,p_delim in varchar2)
    return varchar2_table pipelined;
/**
 * function split. Split string by regexp and returns 
 */
  function split_j(pStr varchar2, pDelimRegexp varchar2, pMaxCount number)
    return varchar2_table
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.split(java.lang.String,java.lang.String,int) return oracle.sql.ARRAY';

  function split(pStr varchar2,pDelimRegexp varchar2,pMaxCount number default 0)
    return varchar2_table;
/**
 * Matches
 */
  function matches_j(pStr varchar2,pPattern varchar2,pFlags number)
    return boolean
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.matches(java.lang.String,java.lang.String,int) return boolean';

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
  function matches_count_j(pStr varchar2,pPattern varchar2,pFlags number)
    return number
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.matches_count(java.lang.String,java.lang.String,int) return int';

  function matches_count(pStr varchar2,pPattern varchar2,
    pCANON_EQ number default 0,
    pCASE_INSENSITIVE number default 0,
    pCOMMENTS         number default 0,
    pDOTALL           number default 0,
    pMULTILINE        number default 0,
    pUNICODE_CAS      number default 0,
    pUNIX_LINES       number default 0
    )
    return number;
/**
 * get_matches
 */
  function get_matches_j(pStr varchar2,pPattern varchar2,pFlags number,pMaxCount number)
    return varchar2_table
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.getMatches(java.lang.String,java.lang.String,int,int) return oracle.sql.ARRAY';

  function get_matches(
    pStr varchar2,
    pPattern varchar2,
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
  function join_matches_j(pStr varchar2,pPattern varchar2,pFlags number, pDelim varchar2)
    return varchar2
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.joinMatches(java.lang.String,java.lang.String,int,java.lang.String) return java.lang.String';

  function join_matches(pStr varchar2,pPattern varchar2,pDelim varchar2 default ';',
        pCANON_EQ number default 0,
        pCASE_INSENSITIVE number default 0,
        pCOMMENTS         number default 0,
        pDOTALL           number default 0,
        pMULTILINE        number default 0,
        pUNICODE_CAS      number default 0,
        pUNIX_LINES       number default 0)
    return varchar2;

  function replace_first(pStr varchar2,pPattern varchar2,pReplacement varchar2)
    return varchar2
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.replaceFirst(java.lang.String,java.lang.String,java.lang.String) return java.lang.String';

  function replace_all(pStr varchar2,pPattern varchar2,pReplacement varchar2)
    return varchar2
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.replaceAll(java.lang.String,java.lang.String,java.lang.String) return java.lang.String';

  function replace_char(pStr varchar2,pPattern varchar2,pReplacement varchar2)
    return varchar2
    IS LANGUAGE JAVA
    name 'com.xt_r.XT_REGEXP.replaceChar(java.lang.String,java.lang.String,java.lang.String) return java.lang.String';

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
 * function split
 */
  function split(pStr varchar2,pDelimRegexp varchar2,pMaxCount number default 0)
    return varchar2_table is
    begin
      return split_j(pStr, pDelimRegexp, pMaxCount);
    end split;
/**
 * function matches
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
    return boolean is
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
  function matches_count(pStr varchar2,pPattern varchar2,
    pCANON_EQ number default 0,
    pCASE_INSENSITIVE number default 0,
    pCOMMENTS         number default 0,
    pDOTALL           number default 0,
    pMULTILINE        number default 0,
    pUNICODE_CAS      number default 0,
    pUNIX_LINES       number default 0
    )
    return number is
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
   
  function get_matches(
    pStr varchar2,
    pPattern varchar2,
    pMaxCount number default 0,
        pCANON_EQ number default 0,
        pCASE_INSENSITIVE number default 0,
        pCOMMENTS         number default 0,
        pDOTALL           number default 0,
        pMULTILINE        number default 0,
        pUNICODE_CAS      number default 0,
        pUNIX_LINES       number default 0)
    return varchar2_table is
    lFlags number;
    begin
      lFlags:=case when pCANON_EQ        >0 then CANON_EQ          else 0 end+
               case when pCASE_INSENSITIVE>0 then CASE_INSENSITIVE else 0 end+
               case when pCOMMENTS        >0 then COMMENTS         else 0 end+
               case when pDOTALL          >0 then DOTALL           else 0 end+
               case when pMULTILINE       >0 then MULTILINE        else 0 end+
               case when pUNICODE_CAS     >0 then UNICODE_CAS      else 0 end+
               case when pUNIX_LINES      >0 then UNIX_LINES       else 0 end;
      dbms_output.put_line(lFlags);
      return get_matches_j(pStr,pPattern,lFlags,pMaxCount);
--        return varchar2_table(cast(pMaxCount as varchar2));
    end get_matches; 
/**
 * function join_matches
 */
  function join_matches(pStr varchar2,pPattern varchar2,pDelim varchar2 default ';',
        pCANON_EQ number default 0,
        pCASE_INSENSITIVE number default 0,
        pCOMMENTS         number default 0,
        pDOTALL           number default 0,
        pMULTILINE        number default 0,
        pUNICODE_CAS      number default 0,
        pUNIX_LINES       number default 0)
    return varchar2 is 
    begin
      return join_matches_j(pStr,pPattern,
           case when pCANON_EQ        >0 then CANON_EQ             else 0 end+
               case when pCASE_INSENSITIVE>0 then CASE_INSENSITIVE else 0 end+
               case when pCOMMENTS        >0 then COMMENTS         else 0 end+
               case when pDOTALL          >0 then DOTALL           else 0 end+
               case when pMULTILINE       >0 then MULTILINE        else 0 end+
               case when pUNICODE_CAS     >0 then UNICODE_CAS      else 0 end+
               case when pUNIX_LINES      >0 then UNIX_LINES       else 0 end,
               pDelim);
    end;

end xt_regexp;
/