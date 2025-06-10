 DECLARE
 
    v_delim_list  TEXT_TOKENIZE.DelimiterSet := TEXT_TOKENIZE.DelimiterSet();
    v_test_text CLOB := EMPTY_CLOB();
    v_delim_count NUMBER(6) := 0;
    v_delimset   VARCHAR2(4000) := NULL;

    v_sql VARCHAR2(200) := 'SELECT text FROM test_token_text WHERE id=1';
	
    TYPE SentenceArray IS TABLE OF VARCHAR2(4000);
    TYPE TokenArray IS TABLE OF VARCHAR2(200);
  
	v_arr_sentences SentenceArray := SentenceArray();
	
	v_arr_tokens TokenArray := TokenArray();
	
	v_sentence VARCHAR2(4000) := NULL; 
  v_token    VARCHAR2(200)  := NULL;
	
 BEGIN
 
   EXECUTE IMMEDIATE v_sql INTO v_test_text;
 
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,'. ');
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,'.'||chr(10)||chr(13));
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,'.'||chr(13));
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,'.'||chr(10));
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,': ');
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,':'||chr(10)||chr(13));
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,':'||chr(13));
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,':'||chr(10));
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,'; ');
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,';'||chr(10)||chr(13));
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,';'||chr(13));
   TEXT_TOKENIZE.adddelimitertoset(v_delim_list,';'||chr(10));

   
   v_delimset := TEXT_TOKENIZE.getDelimiterSetString(v_delim_list);
   
   v_test_text   := TEXT_TOKENIZE.consolidateDelimiters(v_test_text,v_delim_list);
   
   v_delim_count := TEXT_TOKENIZE.getElementCount(v_test_text,TEXT_TOKENIZE.DEFAULT_CONSOLIDATION_DELIM);

   FOR x IN 1 .. v_delim_count LOOP   
   
	 v_arr_sentences.EXTEND;
	 v_arr_sentences(v_arr_sentences.COUNT) := TEXT_TOKENIZE.trimDelimiter(TEXT_TOKENIZE.getStringElement(v_test_text,x,TEXT_TOKENIZE.DEFAULT_CONSOLIDATION_DELIM),v_delimset);

   END LOOP;
   
   FOR x IN 1 .. v_arr_sentences.COUNT LOOP
   
      v_sentence := regexp_replace(v_arr_sentences(x),'[(),"'''||chr(10)||chr(13)||']','');
	  

      FOR y IN 1 .. TEXT_TOKENIZE.getElementCount(v_sentence,' ') LOOP
      
	      v_token    := UPPER(TEXT_TOKENIZE.getStringElement(v_sentence,y,' '));

        IF LENGTH(RTRIM(LTRIM(v_token))) > 0 THEN
            v_arr_tokens.EXTEND;
		        v_arr_tokens(v_arr_tokens.COUNT) := v_token;
	      END IF;
   
      END LOOP;
	  
   END LOOP;
   
  --FOR x IN 1 .. v_arr_tokens.COUNT LOOP
   
    -- DBMS_OUTPUT.PUT_LINE('Token '||x||' ='||v_arr_tokens(x));
   
  -- END LOOP;
   
 END;