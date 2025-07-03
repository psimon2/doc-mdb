TERMS ; ; 6/13/25 10:14am
 quit
 
V ; vectors
 k ^PHRASEIDX,^VEC
 s f="/tmp/vectors.txt"
 c f
 o f:(readonly)
 f  u f r str quit:$zeof  do
 .u 0 w !,str
 .S str=$$TR^LIB(str,"\""","""""")
 .S str="S "_str
 .x str
 .quit
 close f
 quit
 
ZP(xpath) ;
 quit $get(^idxpath(xpath))
 
TR(str) ;
 ;s str=$$TR^LIB(str,"/\"," ")
 s str=$$TR^LIB(str,"\/"," ")
 s str=$$TR^LIB(str,"-"," ")
 s str=$$TR^LIB(str,"(","")
 s str=$$TR^LIB(str,")","")
 s str=$$TR^LIB(str,",","")
 s str=$$TR^LIB(str,"&","")
 ;if $extract(str,1)="[",str[" ]" s str=$p(str,"] ",2,99)
 if $extract(str,1)="[",str["]" s str=$p(str,"]",2,99)
 s str=$$LT^LIB(str)
 ;f i=1:1:$L(str) i $e(str,i)="]"
 quit str
 
KEYS ;
 k ^KEYS
 set (key,rubric,ite)=""
 f  s key=$o(^CLSYN(key)) quit:key=""  do
 .f  s rubric=$o(^CLSYN(key,rubric)) q:rubric=""  do
 ..f  s ite=$o(^CLSYN(key,rubric,ite)) q:ite=""  do
 ...;w !,rubric," ",key r *y
 ...set ^KEYS(rubric,key,ite)=""
 quit
 
KEY(rubric) ;
 set (key,ite)=""
 s j="[",c=1
 f  s key=$o(^KEYS(rubric,key)) q:key=""  do
 .f  s ite=$o(^KEYS(rubric,key,ite)) q:ite=""  do
 ..s j=j_"{""rubric"":"""_$$ESC^VPRJSON(rubric)_""",""key"":"""_$$ESC^VPRJSON(key)_""",""code"":"""_ite_"""},"
 ..set c=c+1
 ..quit
 .quit
 S j=$e(j,1,$l(j)-1)
 s j=j_"]"
 ;w !,j
 quit j
 
CHOP(str) ;
 ;Returns key in 3/3/3 format
 s str=$$LC^LIB(str)
 s st2="",pce=1
 f i=1:1:$l(str," ") d
 .if $data(^CSYNNO($p(str," ",i))) quit
 .s $p(st2," ",pce)=$e($P(str," ",i),1,3)
 .s pce=pce+1
 .quit
 s str=$P(st2," ",1,3)
 quit str
 
SWAP(wstr) ; Swaps piece 2 for piece 1 of string etc.
 s wstr=$p(wstr," ",$l(wstr," "))_" "_$p(wstr," ",1,$l(wstr," ")-1)
 quit wstr
 
SEARCH(str,page) ; $$COLSYN^STDCODE3
 
 ;set json=""
 
 K ^T($J),^TDONE($J)
 
 new bands
 F I=0:1:4 S bands(I)=1
 F I=5:1:16 S bands(I)=2
 F I=17:1:24 S bands(I)=3
 F I=25:1:34 S bands(I)=4
 F I=35:1:44 S bands(I)=5
 F I=45:1:54 S bands(I)=6
 F I=55:1:64 S bands(I)=7
 F I=65:1:74 S bands(I)=8
 F I=75:1:84 S bands(I)=9
 F I=85:1:89 S bands(I)=10
 F I=90:1:170 S bands(I)=11
 
 s st1=$$CHOP(str)
 s (st2,st3,st4)=""
 ;Set keys match input string
 s st2=st1
 i st1'[" " S st1=$E(st1,1,10)
 ;Swap the key words around to match up
 i $l(st2," ")>1 s st3=$$SWAP(st2)
 i $l(st2," ")>2 s st4=$$SWAP(st3)
 set count=0
 f st=st1,st2,st3,st4 d  q:count>1000
 .Q:st=""
 .s wstr=st
 .;W !,wstr r *y
 .i $D(^CLSYN(wstr)) D CODE
 .f  s wstr=$order(^CLSYN(wstr)) q:wstr=""  Q:wstr'[st  do CODE q:count>1000
 .quit
 
 s (count,row)=""
 set j="["
 
 kill words
 set str=$$LC^LIB(str)
 
 ;w !,str r *y
 
 f i=1:1:$L(str," ") if $l($p(str," "))>2 set words($p(str," ",i))=""
 ;s ^str=str
 k ^str
 m ^str=words
 
 f  s count=$o(^T($J,count)) q:count=""  do
 .s rec=^T($J,count)
 .S rubric=$p(rec,"~",1)
 .set key=^T($J,count,1)
 .s q=1
 .;F i=1:1:$length(rubric," ") s wstr=$p(rubric," ",i) i $d(words(wstr)) s q=0 quit
 .f i=1:1:$l(str," ") i rubric[$piece(str," ",i) set q=0
 .quit:q
 .s j=j_"{""row"":"""_rec_""",""key"":"""_key_"""},"
 .quit
 S:j'="[" j=$e(j,1,$l(j)-1)_"]"
 if j="[" s j="[]"
 quit j
 
CODE ;
 s rub=""
 f  s rub=$o(^CLSYN(wstr,rub)) q:rub=""  do
 .;w !,rub r *y
 .i $data(^TDONE($J,rub)) quit
 .set (age,csv)="",tot=0
 .f  s age=$o(^TERMS(rub,age)) q:age=""  do
 ..quit:age'?1n.n
 ..;w !,rub," ",age r *y
 ..S total=$get(^(age))
 ..quit:total=""
 ..set pce=bands(age)
 ..set $p(csv,"~",pce)=$p(csv,"~",pce)+total
 ..s tot=tot+total
 ..;set count=count+1
 ..quit
 .S $piece(csv,"~",12)=tot
 .;
 .set count=count+1
 .s ^T($J,count)=$$ESC^VPRJSON($$STRIP^UPRNUI2(rub))_"~"_csv
 .s ^T($j,count,1)=$$ESC^VPRJSON(wstr)
 .set ^TDONE($J,rub)=""
 .quit
 quit
 
SYNER ;
 K ^CLSYN
 set (nor,docid)=""
 f  s nor=$o(^asum("obs",nor)) q:nor=""   do
 .f  s docid=$o(^asum("obs",nor,docid)) q:docid=""  do
 ..do SYNADD(docid)
 ..quit
 .quit
 quit
 
SETS ;
 K ^CSYNNO
 s ^CSYNNO("and")=""
 s ^CSYNNO("in")=""
 s ^CSYNNO("of")=""
 s ^CSYNNO("on")=""
 s ^CSYNNO("or")=""
 s ^CSYNNO("to")=""
 
 K ^CSYNABB
 s ^CSYNABB("acute")=""
 s ^CSYNABB("adverse")=""
 s ^CSYNABB("c/o")=""
 s ^CSYNABB("chronic")=""
 s ^CSYNABB("female")=""
 S ^CSYNABB("left")=""
 S ^CSYNABB("lesser")=""
 S ^CSYNABB("lower")=""
 S ^CSYNABB("male")=""
 S ^CSYNABB("malignant")="CA"
 S ^CSYNABB("neoplasm")=""
 S ^CSYNABB("o/e")=""
 ;S ^CSYNABB("OSTEOARTHRITIS")="OA"
 S ^CSYNABB("osteoarthritis")="OA"
 S ^CSYNABB("reaction")=""
 S ^CSYNABB("right")=""
 S ^CSYNABB("the")=""
 ;S ^CSYNABB("TUBERCULOSIS")="TB"
 s ^CSYNABB("tuberculosis")="TB"
 quit
 
SYNADD(docid) ;
 set (group,order,xpath)=""
 K a
 W !,docid
 f  s group=$o(^doc(docid,group)) q:group=""  do
 .;kill a
 .f  s order=$o(^doc(docid,group,order)) q:order=""  do
 ..s system=$get(^doc(docid,group,order,47))
 ..;w !,docid ; ," ",group," ",order," sys ",system ; r *y
 ..i system'="" s a(1)=system
 ..s rub=$get(^doc(docid,group,order,46))
 ..i rub'="" s a(2)=rub
 ..s ite=$get(^doc(docid,group,order,45))
 ..i ite'="" s a(3)=ite
 ..;w !,system," ",rub," ",ite r *y
 ..quit
 .i $d(a) do ;w !,a(1)," ",a(2)," ",a(3) r *y do
 ..set rub=a(2),ite=a(3)
 ..;I $DATA(^TERMS(rub)) w !,rub r *y
 ..I $E(rub,$L(rub))'="-" S rub=$TR(rub,"-.()","")
 ..I $E(rub)="[" S rub=$P(rub,"]",2,5)
 ..Q:rub=""
 ..S new="",new2="",i=0
 ..F x=1:1:$L(rub," ") do
 ...S i=i+1
 ...S q=$P(rub," ",i)
 ...I q["-",$E(q,$L(q))'="-" S q=$TR(q,"-","")
 ...quit:q=""
 ...I $D(^CSYNNO(q)) S x=x-1 quit
 ...S q2=$G(^CSYNABB(q),q)
 ...D SN(q,ite,rub)
 ...S new=new_$E(q,1,3)_" "
 ...I q2'="" S new2=new2_$E(q2,1,3)_" "
 ...quit
 ..S new=$E(new,1,$L(new)-1)
 ..S new=$P(new," ",1,3)
 ..S new2=$E(new2,1,$L(new2)-1)
 ..S new2=$P(new2," ",1,3)
 ..q:new=""
 ..I new[" " D SET(new,ite,rub) ; S ^CLSYN(new,ite)=""
 ..I new2'=new,new2[" " d SET(new2,ite,rub) ; S ^CLSYN(new2,ite)=""
 ..I $L(new," ")>2 D SET($P(new," ",2,3)_" "_$P(new," "),ite,rub) ; S ^CLSYN($P(new," ",2,3)_" "_$P(new," "),ite)=""
 ..I new2'=new,$L(new2," ")>2  D SET($P(new2," ",2,3)_$P(new2," ",2,3)_$P(new2," "),ite,rub) ; S ^CLSYN($P(new2," ",2,3)_$P(new2," "),ite)=""
 ..quit
 .k a
 quit
 
SN(syn,ite,rub) ;
 Q:$L(syn)<2
 Q:$E(syn)=""""
 Q:syn?1N.N.E
 S syn=$E(syn,1,10)
 ;S ^CLSYN(syn,ite)=""
 D SET(syn,ite,rub)
 quit
 
SET(syn,ite,rub) ;
 if '$data(^TERMS(a(2))) quit
 set ^CLSYN(syn,a(2),ite)=""
 ;w !,"set" r *y
 quit
 
CLSYN ;
 K ^CLSYN
 s (a,b)=""
 f  s a=$o(^J(a)) q:a=""  do
 .f  s b=$o(^J(a,b)) q:b=""  do
 ..s term=$p(^(b),"~",1)
 ..s tt=$$TR(term)
 ..s n=$p(tt," ",1,3)
 ..;
 ..S ^CLSYN(n,term)=""
 ..quit
 quit
 
AGE(nor) ;
 new docid,order
 s xp1=$$ZP("nor.id")
 set docid=$o(^axin(xp1,nor,""))
 ; ^doc(1,0,9,8)
 set xp2=$$ZP("nor.birthdate")
 set h=$$DOC2^NORNU(docid,0,xp2)
 ;set h=^doc(docid,0,9,xp2)
 set age=$$AGE^NORNU(h)
 quit age
 
STT ;
 new docid
 set t=0
 set xpcode=$$ZP("obs.code.coding.code")
 set xpterm=$$ZP("obs.code.coding.display")
 set xpsystem=$$ZP("obs.code.coding.system")
 kill ^TERMS,^NOR
 set (nor,docid)=""
 f  s nor=$o(^asum("obs",nor)) q:nor=""  do
 .if nor'["-" quit
 .f  s docid=$o(^asum("obs",nor,docid)) q:docid=""  do
 ..;BREAK
 ..k ite
 ..do ITEDATA(docid,.ite,xpcode,xpterm,xpsystem)
 ..set ite=$p(ite(1),"~",1)
 ..set term=$p(ite(1),"~",2)
 ..; DON'T COUNT IF TERM ALREADY BEEN COUNTED FOR THIS PATIENT?
 ..i $d(^NOR(nor,term)) quit
 ..set system=$p(ite(1),"~",3)
 ..set age=$$AGE(nor)
 ..s ^TERMS(term)=$get(^TERMS(term))+1
 ..s ^TERMS(term,age)=$get(^TERMS(term,age))+1
 ..s ^TERMS(term,ite,system)=""
 ..S ^NOR(nor,term)=""
 ..s t=t+1
 ..i t#10000=0 w !,t
 quit
 
TOP ;
 kill ^TOP
 set term=""
 f  s term=$o(^TERMS(term)) q:term=""  do
 .s tot=^(term)
 .S ^TOP(tot,term)=""
 .quit
 quit
 
TOTPAGES() ;
 S tot=$order(^J(""),-1)
 s j="{""totalPages"": "_tot_"}"
 quit j
 
JSON(page) ;
 set row="",j="["
 f  s row=$o(^J(page,row)) q:row=""  do
 .s rec=^J(page,row)
 .s j=j_"{""row"":"""_rec_"""},"
 .quit
 S j=$e(j,1,$l(j)-1)_"]"
 quit j
 
BANDIT ;
 new bands
 F I=0:1:4 S bands(I)=1
 F I=5:1:16 S bands(I)=2
 F I=17:1:24 S bands(I)=3
 F I=25:1:34 S bands(I)=4
 F I=35:1:44 S bands(I)=5
 F I=45:1:54 S bands(I)=6
 F I=55:1:64 S bands(I)=7
 F I=65:1:74 S bands(I)=8
 F I=75:1:84 S bands(I)=9
 F I=85:1:89 S bands(I)=10
 F I=90:1:170 S bands(I)=11
 
 K ^J
 
 set (tot,term,c)="",page=1
 f  s tot=$o(^TOP(tot),-1) q:tot=""  do
 .f  s term=$o(^TOP(tot,term),-1) q:term=""  do
 ..w !,term
 ..s (age,csv)=""
 ..f  s age=$o(^TERMS(term,age)) q:age=""  do
 ...S total=$get(^(age))
 ...quit:total=""
 ...;w !,term," ",age," total: ",total r *y
 ...set pce=bands(age)
 ...set $p(csv,"~",pce)=$p(csv,"~",pce)+total
 ...quit
 ..s c=c+1
 ..i c#1000=0 set page=page+1
 ..S $piece(csv,"~",12)=tot
 ..S ^J(page,c)=$$ESC^VPRJSON($$STRIP^UPRNUI2(term))_"~"_csv
 ..;w !,csv r *y
 quit
 
FORTY8(docid,terms) ; get term
 new group,order
 k terms
 s (group,order,term)=""
 f  s group=$o(^doc(docid,group)) q:group=""  do
 .f  s order=$o(^doc(docid,group,order)) q:order=""  do
 ..s term=$get(^doc(docid,group,order,46))
 ..quit:term=""
 ..set terms(term)=group_"~"_order
 ..quit
 s term=""
 s a=""
 f  s a=$o(terms(a)) q:a=""  i $l(a)>$length(term) s term=a
 quit term
 
ITEDATA(docid,ite,xpcode,xpterm,xpsystem) ;
 ;kill ite
 new group
 set group=""
 for  set group=$o(^doc(docid,group)) q:group=""  do
 .s ite=$get(^doc(docid,group,1,xpcode))
 .i ite="" quit
 .;s term=^doc(docid,group,2,xpterm)
 .; should be a function
 .k terms
 .s term=$$FORTY8(docid,.terms)
 .;do FORTY8(docid)
 .;set term=$o(terms(""),-1)
 .set rec=terms(term)
 .set g=$p(rec,"~",1)
 .s system=^doc(docid,g,$$O(docid,g,xpsystem),xpsystem)
 .s ite=^doc(docid,g,$$O(docid,g,xpcode),xpcode)
 .set ite(group)=ite_"~"_term_"~"_system
 .quit
 quit
 
O(docid,g,xp1) ;
 s o="",qf=0
 f  s o=$o(^doc(docid,g,o)) q:o=""  do  q:qf
 .i $d(^doc(docid,g,o,xp1)) s qf=1
 .quit
 quit o
