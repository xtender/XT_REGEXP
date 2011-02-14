create or replace and compile java source named xt_regexp as
package com.xt_r;
/* Imports */
import java.sql.*;
import java.util.*;
import java.util.regex.*;
import oracle.sql.*;
import oracle.jdbc.driver.OracleDriver;
/* Main class */
public class XT_REGEXP
{

/**
 * Simple regexp split with count - java.lang.String.split
 */ 
  public static oracle.sql.ARRAY split(
                                  java.lang.String pStr,
                                  java.lang.String pDelim,
                                  int pMaxCount)
  throws SQLException 
  {
         java.lang.String[] retArray = new java.lang.String[0];
         if (pDelim==null) pDelim="";
         if (pStr!=null)
           retArray = pStr.split(pDelim,pMaxCount);

         Connection conn = new OracleDriver().defaultConnection();         
         ArrayDescriptor descriptor =
            ArrayDescriptor.createDescriptor("VARCHAR2_TABLE", conn );
         oracle.sql.ARRAY outArray = new oracle.sql.ARRAY(descriptor,conn,retArray);
         
         return outArray;
  }

/**
 * Function matches regexp
 */ 
  public static boolean matches(java.lang.String pStr,java.lang.String pPattern,int pFlags)
  throws SQLException 
  {
         if(pPattern==null) pPattern="";
         if(pStr==null) pStr="";
         Pattern p = Pattern.compile(pPattern,pFlags);
         Matcher m = p.matcher(pStr);
         boolean b=m.find();
         return b;
  }

/**
 * Function count matches regexp
 */ 
  public static int matches_count(java.lang.String pStr,java.lang.String pPattern,int pFlags)
  throws SQLException 
  {
         if(pPattern==null) pPattern="";
         if(pStr==null) pStr="";
         Pattern p = Pattern.compile(pPattern,pFlags);
         Matcher m = p.matcher(pStr);
         int i = 0;
         while(m.find())
             i++;
         return i;
  }

/**
 * Function returns regexp matches with limit
 */ 
  public static oracle.sql.ARRAY getMatches(java.lang.String pStr,java.lang.String pPattern, int pGroup, int pFlags,int pMaxCount)
  throws SQLException 
  {
         List list = new ArrayList();
         if(pPattern==null) pPattern="";
         if(pStr==null) pStr="";
         Pattern p = Pattern.compile(pPattern,pFlags);
         Matcher m = p.matcher(pStr);
         StringBuffer sb = new StringBuffer();
         int i=0;
         while(m.find() && (pMaxCount==0 || i++<pMaxCount)){
             list.add(m.group(pGroup));
         }

         Connection conn = new OracleDriver().defaultConnection();         
         ArrayDescriptor descriptor =
            ArrayDescriptor.createDescriptor("VARCHAR2_TABLE", conn );
         oracle.sql.ARRAY outArray = new oracle.sql.ARRAY(descriptor,conn,list.toArray());
         
         return outArray;
  }

/**
 * Function returns joined regexp matches
 */ 
  public static java.lang.String joinMatches(java.lang.String pStr,java.lang.String pPattern, int pGroup, int pFlags, java.lang.String pDelim)
  throws SQLException 
  {
         if(pPattern==null) pPattern="";
         if(pStr==null) pStr="";
         Pattern p = Pattern.compile(pPattern,pFlags);
         Matcher m = p.matcher(pStr);
         StringBuffer sb = new StringBuffer();

         boolean b=m.find();
         while(b){
             sb.append(m.group(pGroup));
             b=m.find();
             if (b) sb.append(pDelim);
         }
         return sb.toString();
  }

/**
 * ReplaceFirst occurence by regexp
 */
  public static java.lang.String replaceFirst(java.lang.String pStr,java.lang.String pPattern,java.lang.String pReplacement)
  throws SQLException 
  {
         if(pPattern==null) pPattern="";
         if(pStr==null) pStr="";
         if(pReplacement==null) pReplacement="";
         return pStr.replaceFirst(pPattern,pReplacement);
  }

/**
 * ReplaceAll by regexp
 */
  public static java.lang.String replaceAll(java.lang.String pStr,java.lang.String pPattern,java.lang.String pReplacement)
  throws SQLException 
  {
         if(pPattern==null) pPattern="";
         if(pStr==null) pStr="";
         if(pReplacement==null) pReplacement="";
         return pStr.replaceAll(pPattern,pReplacement);
  }

/**
 * ReplaceChar by regexp
 */
  public static java.lang.String replaceChar(java.lang.String pStr,java.lang.String pOldChar,java.lang.String pReplaceChar)
  throws SQLException 
  {
         if(pOldChar==null) pOldChar="";
         if(pStr==null) pStr="";
         if(pReplaceChar==null) pReplaceChar="";
         return pStr.replace(pOldChar.charAt(0),pReplaceChar.charAt(0));
  }

}
/
