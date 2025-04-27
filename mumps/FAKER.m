FAKER ; ; 4/27/25 11:19am
 quit
 
 ; replace the addresses in fhir.nor.txt with the
 ; faker addresses.
REPLACE ;
 S f="/tmp/fhir.nor.txt"
 S file="/tmp/fhir.nor.faker.txt"
 close f,file
 o f:(readonly)
 O file:(newversion:stream:nowrap:chset="M")
 f  u f r str q:$zeof  do
 .;use 0 w !,str r *y
 .kill b
 .D DECODE^VPRJSON($name(str),$name(b),$name(err))
 .;w !
 .;zwr b
 .;r *y
 .set faker=$$RANDOM()
 .;use 0 w !,faker
 .k b("address")
 .S b("address",1,"city")=$P(faker,",",4)
 .s b("address",1,"district")=""
 .s b("address",1,"line",1)=$p(faker,",",1)
 .s b("address",1,"line",2)=$p(faker,",",2)
 .s b("address",1,"line",3)=$p(faker,",",3)
 .s b("address",1,"postalCode")=$p(faker,",",5)
 .s b("address",1,"text")=faker
 .s b("address",1,"use")="home"
 .S json=""
 .kill j
 .D ENCODE^VPRJSON($NA(b),$na(j),$NA(e))
 .f i=1:1:$o(j(""),-1) s json=json_j(i)
 .;w !,json
 .use file w json,$c(10)
 .quit
 close f,file
 quit
 
RANDOM() ;
C set c=$random(50000-1)
 ;i c=0 goto C
 set adr=^FAKER(c)
 quit adr
 
STT ; line1,line2,line3,city,postcode
 k ^FAKER
 set c=0
 S f="/home/fred/uk_addresses.csv"
 close f
 o f:(readonly)
 u f r str
 f  u f r str q:$zeof  do
 .set str=$$TR^LIB(str,$c(13),"")
 .use 0 w !,str
 .set ^FAKER(c)=str
 .s c=c+1
 .quit
 close f
 quit
