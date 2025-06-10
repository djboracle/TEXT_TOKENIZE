# **User Guide for TEXT\_TOKENIZE PL/SQL Package**

## **1\. Introduction**

The TEXT\_TOKENIZE PL/SQL package is a robust and comprehensive utility for advanced string manipulation, specifically designed for **splitting (tokenizing) complex text strings based on various delimiters, and critically, handling nested groups like parentheses**. It provides functions to parse, consolidate, and retrieve individual elements (tokens) from structured or semi-structured text.  
This package is highly valuable for scenarios where you need to extract specific pieces of information from text that might use inconsistent separators or contain logical blocks (e.g., function calls, expressions) that should be treated as single units despite containing delimiters.

## **2\. Dependencies**

For the TEXT\_TOKENIZE package to function correctly, the following custom SQL types must be created in your Oracle schema **before** compiling the package body:

* **PIPELINE\_VARCHAR2\_TYPE (SQL Object Type):**  
  SQL  
  CREATE OR REPLACE TYPE PIPELINE\_VARCHAR2\_TYPE AS OBJECT(  
      data VARCHAR2(4000)  
  );  
  /

* **PIPELINE\_VARCHAR2\_SET (SQL Collection Type):**  
  SQL  
  CREATE OR REPLACE TYPE PIPELINE\_VARCHAR2\_SET AS TABLE OF PIPELINE\_VARCHAR2\_TYPE;  
  /

These types are specifically required for the pipeLineTokenSet function, which allows you to query the results of string tokenization directly from SQL using a TABLE() expression.

## **3\. Key Concepts**

### **3.1. DelimiterSet**

* **Type:** TYPE DelimiterSet IS TABLE OF VARCHAR2(100);  
* **Purpose:** This is a PL/SQL collection type used to define a set of multiple possible delimiters that the tokenization functions should recognize. Instead of being limited to a single character (like in SUBSTR), you can specify an array of various delimiters.

### **3.2. TokenSet**

* **Type:** TYPE TokenSet IS TABLE OF VARCHAR2(4000);  
* **Purpose:** This is a PL/SQL collection type used to store the results of a tokenization operation. Each element in the TokenSet represents a parsed "token" or "element" from the input string.

### **3.3. Group-Aware Parsing**

This is a key differentiator of TEXT\_TOKENIZE. Functions with GrpMD in their name (e.g., getTokenSetGrpMD) can intelligently parse strings while respecting nested grouping characters (like parentheses (), brackets \[\], or curly braces {}).

* **How it works:** When the parser encounters an opening group character, it starts ignoring delimiters until the corresponding closing group character is found. This ensures that content within groups is treated as a single token, even if it contains characters that would normally act as delimiters.  
* **Default Grouping:** The default open/close group characters are ( and ). These can be overridden in the function calls.

### **3.4. Default Consolidation Delimiter**

* **Constant:** DEFAULT\_CONSOLIDATION\_DELIM CONSTANT VARCHAR2(2) := NCHR(254);  
* **Purpose:** This is a special, rarely used ASCII character (record separator) that the consolidateDelimiters function uses to replace multiple delimiters. This simplifies the string into a single-delimiter format, making it easier to parse further.

## **4\. Core Procedures and Functions**

This section details the primary procedures and functions within the TEXT\_TOKENIZE package, categorized by their functionality.

### **4.1. Delimiter Management**

* **PROCEDURE addDelimiterToSet(p\_delim\_set IN OUT DelimiterSet, p\_delimiter VARCHAR2)**  
  * **Purpose:** Adds a single delimiter string to an existing DelimiterSet collection.  
  * **Parameters:**  
    * p\_delim\_set: The DelimiterSet to modify (IN OUT).  
    * p\_delimiter: The delimiter string to add.  
* **FUNCTION getDelimiterSetString(p\_delim\_set DelimiterSet) RETURN VARCHAR2**  
  * **Purpose:** Returns a concatenated string of all delimiters contained within a DelimiterSet, useful for debugging or display.

### **4.2. String Trimming and Consolidation**

* **FUNCTION trimDelimiter(p\_string VARCHAR2/CLOB, p\_delim\_string VARCHAR2) RETURN VARCHAR2/CLOB** (Overloaded for VARCHAR2 and CLOB)  
  * **Purpose:** Removes specified delimiter characters from the beginning and end of a string.  
  * **Parameters:**  
    * p\_string: The input string (VARCHAR2 or CLOB).  
    * p\_delim\_string: A string containing characters to trim (e.g., ', ' to trim commas and spaces).  
* **FUNCTION consolidateDelimiters(p\_string VARCHAR2/CLOB, p\_delim\_set DelimiterSet, p\_common\_delimiter VARCHAR2 := DEFAULT\_CONSOLIDATION\_DELIM) RETURN VARCHAR2/CLOB** (Overloaded for VARCHAR2 and CLOB)  
  * **Purpose:** Replaces all occurrences of any delimiter from p\_delim\_set with a single p\_common\_delimiter. This is useful for normalizing strings with multiple delimiters into a consistent format.  
  * **Parameters:**  
    * p\_string: The input string.  
    * p\_delim\_set: The set of delimiters to consolidate.  
    * p\_common\_delimiter: The single character/string to use for consolidation (defaults to NCHR(254)).

### **4.3. Basic String Element Retrieval (Single Delimiter)**

These functions work by splitting a string based on a single specified delimiter.

* **FUNCTION getElementCount(p\_string VARCHAR2/CLOB, p\_delimiter VARCHAR2) RETURN NUMBER** (Overloaded for VARCHAR2 and CLOB)  
  * **Purpose:** Counts the number of elements in a string separated by p\_delimiter.  
* **FUNCTION getStringElement(p\_string VARCHAR2/CLOB, p\_element\_pos NUMBER, p\_delimiter VARCHAR2) RETURN VARCHAR2** (Overloaded for VARCHAR2 and CLOB)  
  * **Purpose:** Retrieves the element at a specific p\_element\_pos from a string, using p\_delimiter.  
* **FUNCTION getTokenSet(p\_string VARCHAR2/CLOB, p\_delimiter VARCHAR2) RETURN TokenSet** (Overloaded for VARCHAR2 and CLOB)  
  * **Purpose:** Splits the string by p\_delimiter and returns all elements as a TokenSet collection.

### **4.4. Advanced String Element Retrieval (Multi-Delimiter & Group-Aware)**

These functions are more powerful, supporting multiple delimiters via DelimiterSet and/or handling nested groups.

* **FUNCTION getElementCountMD(p\_string VARCHAR2/CLOB, p\_delim\_set DelimiterSet) RETURN NUMBER** (Overloaded for VARCHAR2 and CLOB)  
  * **Purpose:** Counts elements using any delimiter from p\_delim\_set.  
* **FUNCTION getStringElementMD(p\_string VARCHAR2/CLOB, p\_element\_pos NUMBER, p\_delim\_set DelimiterSet) RETURN VARCHAR2** (Overloaded for VARCHAR2 and CLOB)  
  * **Purpose:** Retrieves a specific element using p\_delim\_set.  
* **FUNCTION getTokenSetMD(p\_string VARCHAR2/CLOB, p\_delim\_set DelimiterSet) RETURN TokenSet** (Overloaded for VARCHAR2 and CLOB)  
  * **Purpose:** Splits the string by any delimiter from p\_delim\_set and returns all elements as a TokenSet.  
* **FUNCTION getElementCountGrpMD(p\_string CLOB, p\_delim\_set DelimiterSet, p\_open\_grp VARCHAR2 := '(', p\_close\_grp VARCHAR2 := ')') RETURN NUMBER**  
  * **Purpose:** Counts elements in a CLOB, respecting p\_open\_grp and p\_close\_grp characters. Delimiters inside groups are ignored.  
* **FUNCTION getStringElementGrpMD(p\_string CLOB, p\_element\_pos NUMBER, p\_delim\_set DelimiterSet, p\_open\_grp VARCHAR2 := '(', p\_close\_grp VARCHAR2 := ')') RETURN VARCHAR2**  
  * **Purpose:** Retrieves a specific element from a CLOB, respecting groups.  
* **FUNCTION getTokenSetGrpMD(p\_string CLOB, p\_delim\_set DelimiterSet, p\_open\_grp VARCHAR2 := '(', p\_close\_grp VARCHAR2 := ')') RETURN TokenSet**  
  * **Purpose:** Splits a CLOB by delimiters, respecting groups, and returns all elements as a TokenSet.

### **4.5. Pipelined Function**

* **FUNCTION pipeLineTokenSet(p\_set TokenSet) RETURN PIPELINE\_VARCHAR2\_SET PIPELINED**  
  * **Purpose:** Converts a TokenSet (PL/SQL collection) into a format that can be directly queried as a table in SQL.  
  * **Parameters:**  
    * p\_set: The TokenSet collection containing the elements to be pipelined.  
  * **Usage in SQL:** SELECT data FROM TABLE(TEXT\_TOKENIZE.pipeLineTokenSet(my\_token\_set\_variable))

## **5\. Example Usage**

This section provides practical examples of how to use the TEXT\_TOKENIZE package.

### **Example 1: Basic Tokenization**

SQL

DECLARE  
    l\_input\_string VARCHAR2(200) := 'apple,banana;orange,grape';  
    l\_tokens\_by\_comma TEXT\_TOKENIZE.TokenSet;  
    l\_tokens\_by\_semicolon TEXT\_TOKENIZE.TokenSet;  
BEGIN  
    DBMS\_OUTPUT.PUT\_LINE('--- Basic Tokenization \---');

    \-- Get elements separated by comma  
    l\_tokens\_by\_comma := TEXT\_TOKENIZE.getTokenSet(l\_input\_string, ',');  
    DBMS\_OUTPUT.PUT\_LINE('Tokens by comma:');  
    FOR i IN 1..l\_tokens\_by\_comma.COUNT LOOP  
        DBMS\_OUTPUT.PUT\_LINE('  ' || i || ': ' || l\_tokens\_by\_comma(i));  
    END LOOP;

    \-- Get the second element separated by semicolon  
    DBMS\_OUTPUT.PUT\_LINE('Second element by semicolon: ' || TEXT\_TOKENIZE.getStringElement(l\_input\_string, 2, ';'));

END;  
/

### **Example 2: Multi-Delimiter Tokenization**

SQL

DECLARE  
    l\_input\_string VARCHAR2(200) := 'item1|item2,item3;item4';  
    l\_delim\_set TEXT\_TOKENIZE.DelimiterSet := TEXT\_TOKENIZE.DelimiterSet();  
    l\_tokens TEXT\_TOKENIZE.TokenSet;  
BEGIN  
    DBMS\_OUTPUT.PUT\_LINE('--- Multi-Delimiter Tokenization \---');

    \-- Add multiple delimiters to the set  
    TEXT\_TOKENIZE.addDelimiterToSet(l\_delim\_set, '|');  
    TEXT\_TOKENIZE.addDelimiterToSet(l\_delim\_set, ',');  
    TEXT\_TOKENIZE.addDelimiterToSet(l\_delim\_set, ';');

    \-- Get elements using the multi-delimiter set  
    l\_tokens := TEXT\_TOKENIZE.getTokenSetMD(l\_input\_string, l\_delim\_set);  
    DBMS\_OUTPUT.PUT\_LINE('Tokens by multiple delimiters:');  
    FOR i IN 1..l\_tokens.COUNT LOOP  
        DBMS\_OUTPUT.PUT\_LINE('  ' || i || ': ' || l\_tokens(i));  
    END LOOP;

END;  
/

### **Example 3: Group-Aware Tokenization (ignoring delimiters in parentheses)**

SQL

DECLARE  
    l\_input\_string CLOB := 'function1(arg1, arg2), function2(arg3; arg4)';  
    l\_delim\_set TEXT\_TOKENIZE.DelimiterSet := TEXT\_TOKENIZE.DelimiterSet();  
    l\_tokens TEXT\_TOKENIZE.TokenSet;  
BEGIN  
    DBMS\_OUTPUT.PUT\_LINE('--- Group-Aware Tokenization \---');

    \-- Delimiters are comma and semicolon  
    TEXT\_TOKENIZE.addDelimiterToSet(l\_delim\_set, ',');  
    TEXT\_TOKENIZE.addDelimiterToSet(l\_delim\_set, ';');

    \-- Tokenize, ignoring delimiters inside parentheses  
    l\_tokens := TEXT\_TOKENIZE.getTokenSetGrpMD(  
        p\_string    \=\> l\_input\_string,  
        p\_delim\_set \=\> l\_delim\_set,  
        p\_open\_grp  \=\> '(',  
        p\_close\_grp \=\> ')'  
    );

    DBMS\_OUTPUT.PUT\_LINE('Tokens with group awareness (ignoring delimiters in parens):');  
    FOR i IN 1..l\_tokens.COUNT LOOP  
        DBMS\_OUTPUT.PUT\_LINE('  ' || i || ': ' || l\_tokens(i));  
    END LOOP;  
    \-- Expected output for this example would be:  
    \--   1: function1(arg1, arg2)  
    \--   2: function2(arg3; arg4)

END;  
/

### **Example 4: Using Pipelined Function in SQL**

SQL

\-- First, define the PL/SQL token set (e.g., in an anonymous block or function)  
DECLARE  
    l\_input\_string CLOB := 'alpha,beta,gamma';  
    l\_tokens TEXT\_TOKENIZE.TokenSet;  
BEGIN  
    l\_tokens := TEXT\_TOKENIZE.getTokenSet(l\_input\_string, ',');

    \-- Now, you can query this collection directly in SQL  
    \-- Note: This part cannot be run directly within the anonymous block.  
    \-- It assumes 'l\_tokens' is accessible, for instance, if it were a package global or returned by a function.  
    \-- For demonstration, imagine 'l\_tokens' is made available for SQL context.  
    DBMS\_OUTPUT.PUT\_LINE('--- Pipelined Function Usage \---');  
    \-- SELECT data FROM TABLE(TEXT\_TOKENIZE.pipeLineTokenSet(:my\_plsql\_token\_set\_variable));  
    \-- Or if a function returns the TokenSet:  
    \-- SELECT data FROM TABLE(TEXT\_TOKENIZE.pipeLineTokenSet(your\_function\_returning\_tokens('some string')));

    \-- To simulate a callable example:  
    DBMS\_OUTPUT.PUT\_LINE('Pipelined results (conceptual SQL usage):');  
    FOR rec IN (  
        SELECT \*  
        FROM TABLE(TEXT\_TOKENIZE.pipeLineTokenSet(l\_tokens))  
    ) LOOP  
        DBMS\_OUTPUT.PUT\_LINE('  Pipelined Token: ' || rec.data);  
    END LOOP;  
END;  
/  
