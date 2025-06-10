DECLARE

   v_delim_list  TEXT_TOKENIZE.DelimiterSet := TEXT_TOKENIZE.DelimiterSet();
   
   v_test_string VARCHAR2(4000) := 'This is a test! Is it really a test? Yes it is!';

BEGIN

  text_tokenize.adddelimitertoset(v_delim_list,'. ');
  text_tokenize.adddelimitertoset(v_delim_list,'? ');
  text_tokenize.adddelimitertoset(v_delim_list,'! ');

  DBMS_OUTPUT.PUT_LINE(text_tokenize.getStringElementMD(v_test_string,1,v_delim_list));
  DBMS_OUTPUT.PUT_LINE(text_tokenize.getStringElementMD(v_test_string,2,v_delim_list));
  DBMS_OUTPUT.PUT_LINE(text_tokenize.getStringElementMD(v_test_string,3,v_delim_list));

END;