MUMPSRV ; ; 4/15/25 2:09pm
 quit
 
GETORIGINS() ;
 S (O,RET)=""
 F  S O=$O(^ICONFIG("ORIGIN",O)) Q:O=""  DO
 .S RET=RET_O_","
 .QUIT
 Q $E(RET,1,$L(RET)-1)
 
CHKAUTH(PATH,HOST) ;
 SET PH="",QF=0
 F  S PH=$O(^ICONFIG("PH",PH)) Q:PH=""  DO  Q:QF
 .I PATH=PH SET QF=1 QUIT
 .I HOST=PH SET QF=1 QUIT
 .QUIT
 quit QF
 
 ; USE THE HOSTNAME TO FIGURE OUT IF THE WEB SITE NEEDS TO
 ; SUPPORT BASIC AUTHENTICATION
 ; USE THE PATH FOR ONE OFF API CALLS
REQUIRESAUTH(PATH,HOST) ;
 S ^P($O(^P(""),-1)+1)=PATH_"~"_HOST
 S RET=$$CHKAUTH(PATH,HOST)
 quit RET
 
SHA256(STR) ;
 SET CMD="echo -n '"_STR_"' | openssl dgst -sha256 | awk '{print $2}'"
 SET RET=$$EXEC^OSCAR(CMD)
 quit RET
 
VALIDATEUSER(USER,P) 
 set ^V($O(^V(""),-1)+1)=USER_"~"_P
 QUIT:$DATA(^USERS(USER))=0 0  ; User doesn't exist
 SET SALT=$GET(^USERS(USER,"salt"))
 SET STORED=$GET(^USERS(USER,"password"))
 SET INPUTHASH=SALT_P
 ;SET CMD="python3 -c 'import hashlib; print(hashlib.sha256("""_INPUTHASH_""".encode()).hexdigest())'"
 ;SET RET=$$EXEC^OSCAR(CMD)
 SET RET=$$SHA256(INPUTHASH)
 quit (RET=STORED)
 
CREATEUSER(USER,PASS) ;
 ;NEW SALT,HASH
 SET SALT=$$GENSALT()
 SET HASH=$$SHA256(SALT_PASS)
 IF HASH="" QUIT 0  ; Hashing failed
 SET ^USERS(USER,"salt")=SALT
 SET ^USERS(USER,"password")=HASH
 quit
 
GENSALT() ; 
 NEW SALT,I,RND
 SET SALT=""
 FOR I=1:1:32 DO
 . SET RND=$RANDOM(62)
 . SET SALT=SALT_$SELECT(RND<10:RND+48,RND<36:RND+55,1:RND+61)
 quit SALT
 
HOME(ARG) ;
 S ^A($O(^A(""),-1)+1)=ARG
 S HP=$GET(^ICONFIG("HP",ARG))
 QUIT HP ; "oscars-paw-club/index_7b.html"
 
TEST(ARG) ;
 ;CRASH
 quit "Processed TEST with argument: "_ARG
 
FILECON(F) ;
 K ^C
 S F=$P(F,"FILE:",2,999)
 O F:(READONLY)
 S J=""
 F  U F R STR Q:$ZEOF  S ^R($O(^R(""),-1)+1)=STR,J=J_STR
 CLOSE F
 S ^C=J
 D DECODE^VPRJSON($name(J),$name(b),$name(ERR))
 m ^C=b
 set name=$get(b("name"))
 set email=$get(b("email"))
 set m=$get(b("message"))
 set message="name: "_name_" email: "_email_" message: "_m
 set ok=$$SLACK^OSCAR(message)
 
 quit 1
 
FILEREV(F) ;
 ;S ^R(F)=""
 S F=$P(F,"FILE:",2,999)
 O F:(READONLY)
 S J=""
 F  U F R STR Q:$ZEOF  S ^R($O(^R(""),-1)+1)=STR,J=J_STR
 CLOSE F
 D DECODE^VPRJSON($name(J),$name(b),$name(ERR))
 set name=$get(b("name"))
 set content=$get(b("content"))
 SET IDX=$O(^OSCAR("R",""),-1)+1
 S ^OSCAR("R",IDX,"name")=name
 set ^OSCAR("R",IDX,"content")=content
 set ^OSCAR("R",IDX,"date")=$Horolog
 QUIT 1
 
PROCESS(DATA) ;
 SET LEN=$LENGTH(DATA)
 quit "Processed "_LEN_" bytes"
 
GALL(ARG1,ARG2,ARG3,ARG4) ;
 K A,B
 set ^GALL=$GET(ARG1)_"^"_$GET(ARG2)_"^"_$GET(ARG3)_"^"_$GET(ARG4)
 D GALL^OSCAR(.A,.B)
 ;S ^G($O(^G(""),-1)+1)=^TMP($J,1)
 S (L,OUT)=""
 F  S L=$O(^TMP($J,L)) Q:L=""  S OUT=OUT_^(L)
 QUIT OUT
 
REVIEWS(ARG1,ARG2,ARG3,ARG4) ;
 D REVS^OSCAR(.A,.B)
 set ret=""
 s a="" f  s a=$o(^TMP($J,a)) q:a=""  s ret=ret_^(a)
 QUIT ret
