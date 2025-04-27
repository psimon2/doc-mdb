CONSUMER ;  ; 4/25/25 3:28pm
 quit
 
RESET ;
 k ^d,^axin,^asum,^gin,^idxpath,^doc,^last,^xpath
 quit
 
IDXPATH2(f,resource) ;
 close f
 open f:(readonly)
 set id=$i(^idxpath)
 f  u f r str q:$zeof!(str="")  do
 .use 0 w !,str
 .i str["Document" quit
 .set xpath=$$LC^LIB($p($e(str,3,999),":"))
 .set node=resource_"."_$$NODE(xpath)
 .if $d(^idxpath(node)) quit
 .set ^idxpath(node)=id
 .set ^xpath(id)=node
 .set id=$i(^idxpath)
 .quit
 close f
 quit
 
GROUPER ;
 k groups
 ; patient fhir resources
 set groups("nor","address[0]")=1
 set groups("nor","address[0]/line[0]")=1
 set groups("nor","address[0]/line[1]")=1
 set groups("nor","address[0]/line[2]")=1
 set groups("nor","careProvider[0]")=2
 set groups("nor","careProvider[1]")=3
 set groups("nor","identifier[0]")=4
 set groups("nor","identifier[1]")=5
 set groups("nor","name[0]/family[0]")=6
 set groups("nor","name[0]/given[0]")=6
 set groups("nor","name[0]/prefix[0]")=6
 set groups("nor","name[0]")=6
 set groups("nor","extension[0]/valueCodeableConcept/coding[0]")=17
 set groups("nor","telecom[0]")=7
 set groups("nor","telecom[1]")=8
 set groups("nor","telecom[2]")=9
 set groups("nor","telecom[3]")=10
 set groups("nor","telecom[4]")=11
 set groups("nor","telecom[5]")=12
 set groups("nor","telecom[6]")=13
 set groups("nor","telecom[7]")=14
 set groups("nor","telecom[8]")=15
 set groups("nor","telecom[9]")=16
 
 set groups("eoc","extension[0]")=1
 quit
 
NODE(xpath) ;
 set node=xpath
 for i=0:1:20 set node=$$TR^LIB(node,"["_i_"]","")
 set node=$$TR^LIB(node,"/",".")
 quit node
 
G(xpath,resource) ; return xpath group index.
 if xpath'["]" quit 0
 set qf=0
 for i=$l(xpath):-1:1 do  q:qf
 .i $e(xpath,i)="]" s qf=1
 .quit
 s ret=$e(xpath,1,i)
 set groupid=$get(groups(resource,ret))
 quit groupid
 
GETNOR(resource,str) ;
 set test=$$LC^LIB(str)
 set nor=""
 if test["patient/" s nor=$p($e($p(str,":",2),2,99),"/",2)
 if resource="nor",$p($e(str,3,999),":")="id" s nor=$extract($p(str,":",2),2,999)
 quit nor
 
GETID() ;
 L ^doc:10
 I '$T Q 0
 S ID=$I(^doc)
 L -^doc
 quit ID
 
STT(resource,f) ;
 do GROUPER
 set resource=$$LC^LIB(resource)
 close f
 open f:(readonly)
 set t=0
 for  use f r str q:$zeof  do
 .set nor=$$GETNOR(resource,str)
 .set t=t+1
 .if str["Document" s docid=$$GETID() set order=1 u 0 w !,docid quit
 .if docid#10000=0,'$data(^d(docid)) use 0 w !,docid S ^d(docid)=""
 .set xpath=$p($e(str,3,999),":")
 .set value=$$LC^LIB($p(str,": ",2))
 .if value="" quit
 .if value["http://" quit
 .set node=$$NODE(xpath)
 .set node=$$LC^LIB(resource_"."_node)
 .set groupid=$$G(xpath,resource)
 .set idxid=^idxpath(node)
 .if $piece(value,"t",1)?4N1"-"2N1"-"2N set v=$p(value,"t"),value=$$DH^STDDATE($p(v,"-",3)_"."_$p(v,"-",2)_"."_$piece(v,"-"))
 .i nor'="" set ^asum(resource,nor,docid)=""
 .set ^axin(idxid,value,docid,groupid,order)=""
 .set ^doc(docid,groupid,order,idxid)=value
 .set order=order+1
 .quit
 close f
 quit
