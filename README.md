== xt_regexp is the Oracle DB package for  extended regular expressions and string functions ==

----
== Function list: ==

{{{
	function split_simple(p_str in varchar2,p_delim in varchar2)
		return varchar2_table pipelined;

}}}
Simple split string by delimiter as substring without regular expression.
----
{{{

	function split(pStr varchar2,pDelimRegexp varchar2,pMaxCount number default 0)
		return varchar2_table;
Function splits string by substrings matched for regular explression.


}}}
Example:
{{{

	select * from table(
		xt_regexp.split('Please, make me happy!','(?<=,)\s')
		);

}}}
Another example:
{{{

	select * from table(
		xt_regexp.split('Please, make me happy!','\s',3)
		);
}}}

----
{{{
	function matches(pStr varchar2,pPattern varchar2,
		pCANON_EQ number default 0,
		pCASE_INSENSITIVE number default 0,
		pCOMMENTS         number default 0,
		pDOTALL          number default 0,
		pMULTILINE        number default 0,
		pUNICODE_CAS     number default 0,
		pUNIX_LINES      number default 0
	)
	return boolean;

}}}

Function return true, if input string matches regular explression. First parameter-string for testing, second - regular expression, others - modifiers for regular expression:

*	CANON_EQ - canonical equal;
*	CASE_INSENSITIVE - case insensitive;
*	COMMENTS - ignore comments starts with #;
*	DOTALL - dot symbol in regexp includes string delimiter(/n,/r/n) (default-not);
*	LITERAL - template is not regular expression;
*	MULTILINE - multiline mode;
*	UNICODE_CASE - case for unicode;
*	UNIX_LINES - string deliniter is /n

----
{{{
	function get_matches(
		pStr varchar2,
		pPattern varchar2,
		pMaxCount number default 0,
			pCANON_EQ number default 0,
			pCASE_INSENSITIVE number default 0,
			pCOMMENTS         number default 0,
			pDOTALL          number default 0,
			pMULTILINE        number default 0,
			pUNICODE_CAS     number default 0,
			pUNIX_LINES      number default 0)
		return varchar2_table;

}}}
Function returns collection of matched strings. Params like previous function, excepts pMaxCount - max count strings, if not set or equal 0 returns all.

Example:
{{{
	select * 
	from 
		table(
			xt_regexp.get_matches('Please, make me happy!','\S*m\S*')
		);

}}}
----
{{{
	function join_matches(pStr varchar2,pPattern varchar2,pDelim varchar2 default ';',
			pCANON_EQ number default 0,
			pCASE_INSENSITIVE number default 0,
			pCOMMENTS         number default 0,
			pDOTALL          number default 0,
			pMULTILINE        number default 0,
			pUNICODE_CAS     number default 0,
			pUNIX_LINES      number default 0)
		return varchar2;

}}}
Function like get_matches, but returns joined collection with delimiter.
----
{{{
	function replace_all(pStr varchar2,pPattern varchar2,pReplacement varchar2)
		return varchar2
}}}
Function replaces matched substring with third param.

Example - add "Scott!!!!" after comma with "Please":
{{{
select xt_regexp.replace_all('Please, make me happy!','(?<=Please)(,)','$1 Scott!!!!') from dual;
}}}

Result:
**Please, Scott!!!! make me happy!**
----
{{{
	function replace_first(pStr varchar2,pPattern varchar2,pReplacement varchar2)
		return varchar2
}}}
Function line previous but replaces just first occurence.