LV ; ; 5/14/25 4:10pm
 quit
 
FIX ;
 k ^x
 set (a,b,c,d)=""
 f  s a=$o(^axin(5,a)) q:a=""  do
 .f  s b=$o(^axin(5,a,b)) q:b=""  do
 ..f  s c=$o(^axin(5,a,b,c)) q:c=""  do
 ...f  s d=$o(^axin(5,a,b,c,d)) q:d=""  do
 ....w !,a," ",b," ",c," ",d
 ....set a=$$TR^LIB(a," ","")
 ....W !,a
 ....S ^x(a,b,c,d)=""
 merge ^axin(5)=^x
 quit
 
ZP(xpath) ;
 q $get(^idxpath(xpath))
 
EXIST(index,str) ;
 if $data(^axin(index,str)) q 1
 ;if $order(^axin(xpath,str))'="" q 1
 set next=index_""","""_str
 set a="^axin("_""""_next_""""_")"
 S next=$Q(@a) i next="" quit 0
 set value=$P(next,",",2)
 set zv=$e(value,1,$l(value)-1)
 set zv=$e(zv,2,999)
 if zv'[str quit 0
 quit 1
 
GO(str) ;
 k done
 K ^TDOC($job),^TXR($j)
 set str=$$LC^LIB(str)
 
 f chunk=1:1:$l(str,",") s x=$piece(str,",",chunk) do
 .i x="" quit
 .set x=$$LT^LIB(x)
 .i $data(done(x)) quit
 .set done(x)=""
 .D FIND(x)
 .quit
 
 kill ^TC($job)
 set docid="",zc=0
 f  s docid=$o(^TXR($j,docid)) q:docid=""  do
 .set tot=^(docid)
 .S ^TC($J,tot,docid)=""
 .s zc=zc+1
 .quit
 
 S (tot,totcount)=""
 set j="{""patients"": [], ""total"": 0}"
 s:$data(^TC($job)) j="{""searchType"": ""multi-search"",",j=j_"""patients"": ["
 S zc=0
 f  s tot=$o(^TC($J,tot),-1) q:tot=""!(zc>499)  do
 .f  s docid=$order(^TC($j,tot,docid),-1) q:docid=""!(zc>499)  do
 ..s zc=zc+1
 ..s j=j_$$J^NORNU(docid,.totcount)
 i $data(^TC($j)) g OUT
 quit j
 
FIND(str) ;
 ; dob
 ; names
 ; post code
 ; address
 ;
 ; nor.address.city
 ; nor.address.district
 ; nor.address.line
 ; nor.address.postalcode
 ; nor.address.text
 ; nor.birthdate
 ;
 
 new c
 set zc=1
 kill xpath
 
 ; check if its a date
 set d=$$DH^STDDATE(str)
 if d'="" do
 .s index=$$ZP("nor.birthdate")
 .quit:'$data(^axin(index,d))
 .set xpath(zc)=^xpath(index)_"~"_index_"~"_d
 .set zc=zc+1
 .quit
 
 ; names
 for n="nor.name.family","nor.name.given" do
 .s index=$$ZP(n)
 .quit:'$$EXIST(index,str)
 .set xpath(zc)=^xpath(index)_"~"_index_"~"_str
 .set zc=zc+1
 .quit
 
 ; postal code
 set pcode=$$TR^LIB(str," ","")
 if $$validp^NORNU(pcode) do
 .s xp=$$ZP("nor.address.postalcode")
 .i '$data(^axin(xp,pcode)) quit
 .set xpath(zc)=^xpath(xp)_"~"_xp_"~"_pcode
 .set zc=zc+1
 .quit
 
 ; addresses
 for n="nor.address.city","nor.address.district","nor.address.line" do
 .s index=$$ZP(n)
 .quit:'$$EXIST(index,str)
 .set xpath(zc)=^xpath(index)_"~"_index_"~"_str
 .set zc=zc+1
 .quit
 
 set zc=""
 f zc=1:1:$o(xpath(""),-1) do
 .s index=$p(xpath(zc),"~",2)
 .s str=$p(xpath(zc),"~",3)
 .do SRCH(index,str)
 .quit
 quit
 
SRCH(index,str) ;
 set totcount=0,j=""
 set str=$$LC^LIB(str)
 set next=index_""","""_str
 set a="^axin("_""""_next_""""_")"
 
 S next=$Q(@a) i next="" quit
 set docid=$piece(next,",",3)
 i docid'?1n.n s docid=$p(next,",",4)
 
 set ^TDOC($J,docid)=""
 set ^TDOC($J,docid,str)=""
 set ^TXR($J,docid)=$get(^TXR($J,docid))+1
 
NEXT S next=$Q(@next) quit:next=""!(totcount>499)
 set value=$P(next,",",2),zv=value
 ;
 I $e(value,1,$l(value))="""" do
 .set zv=$e(value,1,$l(value)-1)
 .set zv=$e(zv,2,999)
 .quit
 
 set docid=$piece(next,",",3)
 i docid'?1n.n s docid=$p(next,",",4)
 
 if zv'[str quit
 
 set ^TDOC($j,docid)=""
 set ^TDOC($j,docid,str)=""
 set ^TXR($J,docid)=$get(^TXR($J,docid))+1

 goto NEXT
 
OUT ;
 set j=$e(j,1,$l(j)-1)
 s j=j_"],"
 s j=j_"""totalCount"":"_totcount_"}"
 quit j
 
NAMES(str) ;
 set str=$$LC^LIB(str)
 S lchar=$extract(str,$l(str))
 ;S lchar=$c($a(lchar)-1)
 ;W !,lchar
 ;set:$l(str)>1 lchar=$e(str,1,$l(str)-1)_$c($a(lchar)-1)
 set:$l(str)>1 lchar=$e(str,1,$l(str)-1)
 w !,lchar
 f  s lchar=$order(^axin(21,lchar)) q:lchar=""  do
 .w !,lchar R *Y
 .quit
 quit
