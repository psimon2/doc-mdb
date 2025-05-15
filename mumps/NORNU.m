NORNU ; ; 5/14/25 12:29pm
 quit
 
ISNULL(var) ;
 new q
 set q=0
 if $A(var)=-1 s q=1
 quit q
 
DH(date) ;
 quit $$DH^STDDATE(date)
 
HD(h) ;
 q $$HD^STDDATE(h)
 
ORDER(docid,idx) ;
 new order
 set (order,qf)=""
 f  s order=$o(^doc(docid,0,order)) q:order=""  do  q:qf
 . i $d(^doc(docid,0,order,idx)) set qf=1 quit
 quit order
 
AGEAT(eventdate,dob) ;
 use 0
 S eventdate=$P(eventdate,"-",3)_"."_$P(eventdate,"-",2)_"."_$P(eventdate,"-")
 S TDAY=$$DA^STDDATE(eventdate)
 S TDOB=$P(dob,"-",3)_"."_$P(dob,"-",2)_"."_$P(dob,"-")
 S JN=$$DA^STDDATE(TDOB)
 S DA2=$A($E(TDAY,5)),MO2=$A($E(TDAY,4)),YEC2=($A($E(TDAY,1))-33)_($A($E(TDAY,2))-33)_($A($E(TDAY,3))-33)
 S DA1=$A($E(JN,5)),MO1=$A($E(JN,4)),YEC1=($A($E(JN,1))-33)_($A($E(JN,2))-33)_($A($E(JN,3))-33)
 S YEARS=YEC2-YEC1
 I MO2>MO1 Q YEARS
 I MO2<MO1 S YEARS=YEARS-1 Q YEARS
 I DA2>DA1 Q YEARS
 I DA2<DA1 S YEARS=YEARS-1 Q YEARS
 quit YEARS
 
AGEV(docid) ;
 s idx=^idxpath("nor.birthdate")
 s order=$$ORDER(docid,idx)
 s dob=^doc(docid,0,order,idx)
 s d=$$HD^STDDATE(dob)
 s d=$p(d,".",3)_"-"_$p(d,".",2)_"-"_$p(d,".",1)
 s today=$$HD^STDDATE(+$H)
 s today=$p(today,".",3)_"-"_$p(today,".",2)_"-"_$p(today,".",1)
 s age=$$AGEAT(today,d)
 quit age
 
SUMV(jobid,count) ;
 set ^TSUMV(jobid)=$get(^TSUMV(jobid))+count
 quit +$get(^TSUMV(jobid))
 
KILLG(glob,node) ;
 ; only allowed to kill ^T globals
 if $e(glob,1,2)'="^T" q 0
 if $get(glob)="" kill @glob quit
 k @glob@(node)
 quit 1
 
ASUM(type,id,xpathid) ;
 new doc,data,q
 if id["/" s id=$p(id,"/",2)
 set doc=$o(^asum(type,id,""))
 set data="",q=0
 if doc'="",$get(xpathid)'="" do
 . s data=$$GRPORD(doc,xpathid) ; get from doc.;
 . s q=1
 quit $s(q=1:data,1:doc)
 
GRPORD(zdocid,zxpath) ;
 ; return the value from the first group_id
 set (zgroup,zorder,zvalue)=""
 f  set zgroup=$order(^doc(zdocid,zgroup)) q:zgroup=""  do  q:zvalue'=""
 .f  set zorder=$o(^doc(zdocid,zgroup,zorder)) q:zorder=""  do  q:zvalue'=""
 ..set zvalue=$get(^doc(zdocid,zgroup,zorder,zxpath))
 ..quit
 .quit
 quit zvalue
 
RandomDate(StartDate) ;
 SET Today=$H
 SET DaysDiff=Today-StartDate
 IF DaysDiff<1 QUIT ""  ; Ensure the range is valid
 SET RandomOffset=$R(DaysDiff)+1  ; Generate random offset (1 to DaysDiff)
 SET RandomDate=StartDate+RandomOffset
 quit RandomDate
 
ENDEOC ;
 
 ; ^xpath(37)="eoc.managingorganization.reference"
 ; ^xpath(38)="eoc.patient.reference"
 ; ^xpath(42)="nor.dateofdeath"
 
 set sql="select docid, DOC(docid,0,37) AS org, DOC(docid,0,38) as nor, ASUM('nor',DOC(docid,0,38),42) as dateofdeath from xasum WHERE type = 'eoc';"
 S *X=$$execute^%ydbguiOcto(sql,360000)
 set row=1
 k ^T($job)
 f  s row=$o(X("data",row)) q:row=""  do
 . set rec=X("data",row)
 . i $e(rec)="(" quit
 . set org=$p($p(rec,"|",2),"/",2)
 . set docid=$p(rec,"|",1)
 . s ^T($j,org)=$get(^T($j,org))+1
 . s ^T($j,org,docid)=""
 . quit
 ;	
 K ^TZ($J)
 ; end 10% of the episode of care records for each organisation
 set (org,docid)=""
 f  s org=$o(^T($J,org)) q:org=""  do
 . s tot=^T($J,org)
 . s p=$justify(tot*0.10,0,0)
 . w !,tot," ",p
 . set ^TZ($job,org)=p
 . quit
 ;	
 if '$data(^idxpath("eoc.period.end")) do
 . set z=^idxpath
 . set ^idxpath("eoc.period.end")=z
 . set ^xpath(z)="eoc.period.end"
 . set z=z+1,^idxpath=z
 . quit
 ;	
 set row=1
 kill org
 set path1=^idxpath("eoc.period.start")
 set path2=^idxpath("eoc.patient.reference")
 set xpath=^idxpath("eoc.period.end")
 set dobxpath=^idxpath("nor.birthdate")
 ;	
 kill doc
 f  s row=$o(X("data",row)) q:row=""  do
 . s rec=X("data",row)
 . i $e(rec)="(" quit
 . set docid=$p(rec,"|",1)
 . set org=$p($p(rec,"|",2),"/",2)
 . ; avoid dead patients.;
 . set dod=$p(rec,"|",4)
 . if dod'="" quit
 . set nor=$piece($$DOC2(docid,0,path2),"/",2)
 . set tot=^TZ($job,org)
 . set org(org)=$get(org(org))+1
 . i org(org)>tot quit
 . ;set lastobs=$o(^asumx(nor,""),-1)
 . set lastobs=$$DOC^NORNU(docid,dobxpath) ; patient's d.o.b
 . set horo=$$RandomDate(lastobs)
 . ;set doc(org,docid)=lastobs_"~"_$$RandomDate^OCTOTST(lastobs)_"~"_nor
 . set order=$o(^doc(docid,0,""),-1)+1
 . set ^axin(xpath,horo,docid,0,order)=""
 . set ^doc(docid,0,order,xpath)=horo
 . quit
 quit
 
DOC2(docid,groupid,xpath) ;
 set (orderid,value)=""
 f  s orderid=$o(^doc(docid,groupid,orderid)) q:orderid=""  do  q:value'=""
 . if $data(^doc(docid,groupid,orderid,xpath)) s value=^(xpath)
 .quit
 quit value
 
MAKEDEAD ;
 S sql="SELECT TEMPKILL('^TSUMV','test-123');"
 S *X=$$execute^%ydbguiOcto(sql,360000)
 ;write !
 ;zwr X
 set sql="SELECT AGEV(CAST(docid AS VARCHAR)) AS age, COUNT(*) AS record_count, SUMV2('test-123', COUNT(*)) AS total FROM xasum WHERE type = 'nor' GROUP BY age;"
 S *X=$$execute^%ydbguiOcto(sql,360000)
 ;w !
 ;zwr X
 kill ^T($job)
 S row=1 ; avoid headers
 f  s row=$o(X("data",row)) q:row=""  do
 . set r=X("data",row)
 . I $E(r)="(" quit
 . set age=$p(r,"|",1)
 . set deadstat=^DEADSTAT(age)
 . S tot=$p(r,"|",2)
 . write !,age," ",tot," ",deadstat," ",$j(tot*deadstat,0,0)
 . ; how many to make dead
 . I $j(tot*deadstat,0,0)=0 quit
 . set ^T($job,age)=$j(tot*deadstat,0,0)
 . quit
 ;	
 ; get a list of all the patients ordered by age.;
 set sql="select docid, cast(AGEV(cast(docid as varchar)) as integer) as age, id from xasum where type = 'nor' order by age;"
 S *X=$$execute^%ydbguiOcto(sql,360000)
 ;w !
 ;zwr X
 S r="",t=1,oage=""
 kill ^deaded
 set dobxpath=^idxpath("nor.birthdate")
 f  s r=$o(X("data",r)) q:r=""  do
 . s rec=X("data",r)
 . s docid=$p(rec,"|",1)
 . s age=$p(rec,"|",2)
 . i age'=oage s t=1
 . if age=""!(age<0) quit
 . set nor=$p(rec,"|",3)
 . ;set lastobs=$o(^asumx(nor,""),-1)
 . set lastobs=$$DOC^NORNU(docid,dobxpath) ; patient's d.o.b
 . if t>$get(^T($j,age)) quit
 . ;I age=91 w !,age," ",^T($J,91)," ",$$HD^STDDATE(lastobs)," dead date: ",$$HD^STDDATE($$RandomDate(lastobs)) s t=t+1
 . set ^deaded(age,nor)=$$RandomDate(lastobs)_"~"_lastobs
 . s oage=age
 . set t=t+1
 . quit
 w !,t
 ;	
 ; set up a new xpath for datefdeath
 if '$data(^idxpath("nor.dateofdeath")) do
 . set z=^idxpath
 . set ^idxpath("nor.dateofdeath")=z
 . set ^xpath(z)="nor.dateofdeath"
 . set z=z+1,^idxpath=z
 . quit
 ;	
 set xpath=^idxpath("nor.dateofdeath")
 s (age,nor)=""
 f  s age=$o(^deaded(age)) q:age=""  do
 . f  s nor=$o(^deaded(age,nor)) q:nor=""  do
 . . s rec=^deaded(age,nor)
 . . s dodhoro=$p(rec,"~",1)
 . . set docid=$o(^asum("nor",nor,""))
 . . i docid="" quit
 . . set order=$o(^doc(docid,0,""),-1)+1
 . . set ^axin(xpath,dodhoro,docid,0,order)=""
 . . set ^doc(docid,0,order,xpath)=dodhoro
 . . quit
 quit
 ;	
DEADSTAT ; 
 K ^DEADSTAT
 s f="/tmp/%dead.txt"
 close f
 o f:(readonly)
 f  u f r str q:$zeof  do
 . ;use 0 w !,str
 . s age=$p(str," ")
 . s percent=$p(str," ",2)
 . USE 0 w !,age," > ",percent
 . S per=$p(percent,"%")
 . s per=per/100
 . w !,per
 . s ^DEADSTAT(age)=per
 . quit
 close f
 quit
 ; 
DOCDUM(docid,groupid,xpathid) ;
 set (orderid,value)=""
 f  s orderid=$o(^doc(docid,groupid,orderid)) q:orderid=""  do  q:value'=""
 .if $data(^doc(docid,groupid,orderid,xpathid)) s value=^(xpathid)
 .quit
 quit value
 
AGE(dob) ; dob = horolog date (+$H)
 set today=$$HD^STDDATE(+$H)
 set curryr=$p(today,".",3)
 set currmo=$p(today,".",2)
 set currday=$p(today,".",1)
 
 set dob=$$HD^STDDATE(dob)
 
 I dob="Unknown" q -1
 
 set birthyr=$p(dob,".",3)
 set birthmo=$p(dob,".",2)
 set birthday=$p(dob,".",1)
 
 set age=curryr-birthyr
 if (currmo<birthmo)!((currmo=birthmo)&(currday<birthday)) s age=age-1
 quit age
 
ZP(xpath) ;
  quit $get(^idxpath(xpath))
 
EXIST(xpath,str) ;
 if $data(^axin(xpath,str)) q 1
 if $order(^axin(xpath,str))'="" q 1
 quit 0
 
validp(post) ;
 s post=$$LC^LIB(post)
 i post?2l1n1l1n2l q 1
 i post?1l1n1l1n2l q 1
 i post?1l2n2l q 1
 i post?1l3n2l q 1
 i post?2l2n2l q 1
 i post?2l3n2l q 1
 quit 0
 
STT(norstr) ;
 new j
 
 S ^nor=norstr
 I $data(^ICONFIG("NATIVE")) s j=$$GO^LV(norstr) quit j
 
 set norstr=$$LC^LIB(norstr)
 
 ;s j="{""searchType"":  ""name"","
 ;s j=j_"""patients"": [{"
 ;s j=j_"""id"": ""12345"","
 ;S j=j_"""dob"":""1.1.1991"","
 ;s j=j_"""postcode"":""LS17 5EH"","
 ;s j=j_"""phone"":""0113 2666248"","
 ;s j=j_"""fullName"": ""John Smith""}"
 ;s j=j_"],"
 ;s j=j_"""totalCount"":1}"
 
 set j="{""patients"": [], ""total"": 0}"
 
 set sql="",searchtype=""
 
 ; dob
 if norstr'[",",$$DH^STDDATE(norstr)'="" do
 .S searchtype="date of birth"
 .s xpath=$$ZP("nor.birthdate")
 .s date=$$DH^STDDATE(norstr)
 .s sql="select docid from zaxin where value = cast("_date_" as varchar) and xpath="_xpath
 .s searchtype="dob"
 .quit
 
 ; names
 if sql="",norstr'["," do
 .set searchtype="names"
 .set xpath=$$ZP("nor.name.family")
 .if $$EXIST(xpath,norstr) do  quit
 ..set x=$$ZP("nor.id")
 ..set sql="select docid from zaxin where value like '"_norstr_"%' and xpath="_xpath
 ..quit
 .; otherwise, go for given name
 .set xpath=$$ZP("nor.name.given")
 .if $$EXIST(xpath,norstr) do  quit
 ..set sql="select docid from zaxin where value like '"_norstr_"%' and xpath="_xpath
 ..quit
 .quit
 
 ; post code
 set pcode=$$TR^LIB(norstr," ","")
 if $$validp(pcode) do
 .set searchtype="post code"
 .s xpath=$$ZP("nor.address.postalcode")
 .set sql="select docid from zaxin where value ='"_norstr_"' and xpath="_xpath
 .quit
 
 ; address
 if sql="" do
 .;s xpath=$$ZP("nor.address.line"),in="("
 .;f i=1:1:$l(norstr,",") do
 .;.set bit=$p(norstr,",",i)
 .;.if bit="" quit
 .;.if $$EXIST(xpath,bit) set in=in_"value like '"_bit_"%' OR "
 .;.quit
 .;set in=$e(in,1,$l(in)-3)_")"
 .;
 .;set sql="select docid from zaxin where "_in_" and xpath = "_xpath
 .set searchtype="address"
 .set xpath=$$ZP("nor.address.text")
 .if $$EXIST(xpath,norstr) s sql="select docid from zaxin where value like '"_norstr_"%' and xpath="_xpath
 .quit
 
 kill X
 
 set ^sql=sql
 if sql'="" S sql=sql_" limit 500",*X=$$execute^%ydbguiOcto(sql,360000)
 
 ;m ^X=X
 
 if $data(X("data",3)) s j="{""searchType"": """_searchtype_""",",j=j_"""patients"": ["
 
 if '$data(X("data",3)) q j
 
 s row=1,totcount=0,b=$o(X("data",""),-1)
 f  s row=$o(X("data",row)) q:row=""!(row=b)  do
 .; docid is always the 1st item in the result sets row
 .set rec=X("data",row)
 .;if rec["rows)" quit
 .set docid=$p(rec,"|",1)
 .s j=j_$$J(docid,.totcount)
 .quit
 
 if $data(X("data",3)) do
 .set j=$e(j,1,$l(j)-1)
 .s j=j_"],"
 .s j=j_"""totalCount"":"_totcount_"}"
 .quit
 quit j
 
 ; docid,"nor.telecom.use","nor.telecom.system","nor.telecom.value"
DOCSYS(docid,xpuse,xpsys,xpvalue) ;
 new array,count
 kill array
 s xpuse=$$ZP(xpuse)
 s xpsys=$$ZP(xpsys)
 s xpvalue=$$ZP(xpvalue)
 s (group,order)=""
 f  s group=$o(^doc(docid,group)) q:group=""  do
 .f  s order=$o(^doc(docid,group,order)) q:order=""  do
 ..f i=xpuse,xpsys,xpvalue if $get(^doc(docid,group,order,i))'="" set array(group,i)=^(i)
 ..quit
 set (group,i,value)=""
 f  s group=$order(array(group)) q:group=""  do  q:value'=""
 .f  s i=$o(array(group,i)) q:i=""  do  q:value'=""
 ..;w !,array(group,xpuse)
 ..if array(group,i)="phone",array(group,xpuse)'="old" set value=array(group,xpvalue)
 quit value
 
DOC(docid,xpath) ;
 set (order,group,value)=""
 f  s group=$o(^doc(docid,group)) q:group=""  do  q:value'=""
 .f  s order=$o(^doc(docid,group,order)) q:order=""  do  q:value'=""
 ..;W !,value
 ..if $get(^doc(docid,group,order,xpath))'="" s value=^(xpath)
 quit value
 
J(docid,totcount) ;
 s xpath=$$ZP("nor.id")
 set id=$$DOC(docid,xpath)
 
 s xpath=$$ZP("nor.birthdate") 
 set dob=$$DOC(docid,xpath)
 
 s xpath=$$ZP("nor.address.postalcode")
 set postcode=$$DOC(docid,xpath)
 
 set xpath=$$ZP("nor.name.text")
 set fullname=$$DOC(docid,xpath)
 
 set xpath=$$ZP("nor.address.text")
 set address=$$DOC(docid,xpath)
 
 ;set phone="0113 2666248"
 
 s xj=""
 set xj=xj_"{""id"":"""_docid_""","
 set xj=xj_"""dob"":"""_$$HD^STDDATE(dob)_""","
 set xj=xj_"""postcode"":"""_postcode_""","
 set xj=xj_"""address"":"""_address_""","
 set xj=xj_"""phone"":"""_$$DOCSYS^NORNU(docid,"nor.telecom.use","nor.telecom.system","nor.telecom.value")_""","
 set xj=xj_"""fullName"":"""_fullname_"""},"
 
 set totcount=totcount+1
 quit xj
