LIB ;Library Extrinsic Functions and parameter passed subrtns [ 03/07/2019  3:50 PM ] ; 4/21/25 2:03pm
 ;**ESCL 5078466941B PLEASE DO NOT REMOVE.**
 ; (c) copyright 1997. Egton Medical Information Systems Ltd.
 ; All rights reserved.
 ;downloaded 5.1 beta by OT 1:15 pm  5.12.2001
 ;downloaded beta by DS 4:21 pm  15.2.2000
 ;downloaded beta by DS 9:58 am  31.10.99
 ;downloaded beta by DS 2:12 pm  24.9.99
 ;downloaded beta by PS 9:31 am  12.2.99
 ;downloaded beta by SS 10:32 am  20.11.98
 ;downloaded beta by AB 8:48 am  20.8.98
 ;downloaded beta by SS 11:43 am  18.2.98
 ;downloaded beta by SS 11:40 am  18.2.98
 ;downloaded beta by SS 11:38 am  18.2.98
 ;downloaded distrib by KGM 4:27 pm  19.12.96
%version ;;4.3; - Changed by development only
UC(ZX) ;Upper Case Conversion
 S ZX=$TR(ZX,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 Q ZX
 ;
LC(ZX) ;Lower Case Conversion
 S ZX=$TR(ZX,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
 Q ZX
 ;
LT(ZX) ;Leading and trailing spaces
 F  Q:$E(ZX)'=" "  S ZX=$E(ZX,2,25500)
 F  Q:$E(ZX,$L(ZX))'=" "  S ZX=$E(ZX,1,$L(ZX)-1)
 Q ZX
 ;
IN(ZX) ;Initial Capitals
 N ZY
 ;S ZX=$$LT(ZX)
 S ZX=$TR(ZX,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
 F ZY=1:1:$L(ZX) I $A(ZX,ZY)>96&($A(ZX,ZY)<123) DO
 . I $E(ZX,ZY-1)="'" Q
 . S $E(ZX,ZY)=$C($A(ZX,ZY)-32) F  S ZY=ZY+1 I $A(ZX,ZY)<97!($A(ZX,ZY)>122) S ZY=ZY-1 Q
 Q ZX
 ;
DA(ZX,PAD) ;Returns a date from ascii date format
 N ZD,ZM,ZY
 I $E(ZX,1,5)="3'!""#" S ZX=" Not known " Q ZX
 I $E(ZX,1,5)="@%!,>" S ZX=" Not known " Q ZX
 S ZD=$A(ZX,5)-33,ZM=$A(ZX,4)-33
 S ZY=$A(ZX,1)-33_($A(ZX,2)-33)_($A(ZX,3)-33)
 I ZY>2500 S ZY=5000-ZY S ZM=12-ZM S ZD=$S(ZY#4!(ZY=1900):$P("31 28 31 30 31 30 31 31 30 31 30 31"," ",ZM)-ZD,1:$P("31 29 31 30 31 30 31 31 30 31 30 31"," ",ZM)-ZD)
 I ZM=0 S ZX=ZY Q ZX
 I ZD=0 S ZX=ZM_"."_ZY Q ZX
 I ZY'=1900 I $E(ZY,1,2)=19 S ZY=$E(ZY,3,4)
 I ZD<1 S ZX=" Not Known " Q ZX
 S ZX=ZD_"."_ZM_"."_ZY
 S:ZY?2N ZY=19_ZY S ZX=ZD_"."_ZM_"."_ZY
 Q ZX
 ;
AD(ZX,REV,dobeep) ;Sets an ascii date from standard date format [ 11/10/91  10:56 AM ]
 ;Returns nul and Bel if date incorrect
 ;ZX is date
 ;REV is REV indicator
 ;dobeep if set to 0 will not beep when invalid date, defaults to on
 
 
 N ZZ,ZY,ZM,ZD,beep
 
 ;OT added for API calls, so that beep can be switched off for invalid
 ;dates
 s dobeep=$g(dobeep,1)
 s beep=$s(dobeep:$c(7),1:"")
 
 S ZX=$TR(ZX,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
 ;Tests for correct formats
 I ZX="nk" S ZX="2.1.1860"
 I ZX["not" S ZX="2.1.1860"
 I ZX?2N S ZX=0_"/"_0_"/"_ZX
 I ZX?4N S ZX=0_"/"_0_"/"_ZX
 I ZX?3L2N S ZX="/"_$F("jan feb mar apr may jun jul aug sep oct nov dec"," "_$E(ZX,1,3))/4_"/"_$E(ZX,4,5)
 F ZZ=1:1:$L(ZX) I $E(ZX,ZZ)?1P S ZZ=$E(ZX,ZZ) Q 
 I " ./,"'[ZZ S ZX="" Q ZX
 I ZX?1N.N1P1N.N S ZX=0_ZZ_ZX
 I ZX'?1N.N1P1N.N1P1N.N W beep S ZX="" Q ZX
 I ZZ?1N W beep S ZX="" Q ZX
 S ZD=$P(ZX,ZZ,1)
 S ZM=$P(ZX,ZZ,2)
 S ZY=$P(ZX,ZZ,3) I ZY?2N S ZY=20_ZY
 I (ZY<1860)!(ZY>2099)!(ZM<0)!(ZM>12)!(ZD<0)!(ZD>31) W beep S ZX="" Q ZX
 ;Is it a Leap year
 I (ZY#4)!(ZY=1900) DO  I ZX=""  Q ZX
 .  I ZD>$P("31 28 31 30 31 30 31 31 30 31 30 31"," ",ZM) W beep S ZX="" Q
 I '(ZY#4)&(ZY'=1900) I ZD>$P("31 29 31 30 31 30 31 31 30 31 30 31"," ",ZM) W beep S ZX="" Q ZX
 S ZX=$C($E(ZY,1,2)+33)_$C(($E(ZY,3)+33))_$C($E(ZY,4)+33)_$C(ZM+33)_$C(ZD+33)
 I $G(REV) S ZX=$$RV(ZX)
 Q ZX
 ;
RV(ZX) ;Reverses ascii date for storage purposes [ 11/10/91  11:28 AM ]
 N ZD,ZM,ZY
 ;format correct ?
 I ZX="" W *7 Q ZX
 I $A(ZX)>54 Q ZX
 S ZD=$A($E(ZX,5))-33,ZM=$A($E(ZX,4))-33,ZY=$A($E(ZX,1))-33_($A($E(ZX,2))-33)_($A($E(ZX,3))-33)
 ;Leap year ? reverse the day
 I (ZY#4)!(ZY=1900) DO
 .   S ZD=$P("31 28 31 30 31 30 31 31 30 31 30 31"," ",ZM)-ZD
 E  S ZD=$P("31 29 31 30 31 30 31 31 30 31 30 31"," ",ZM)-ZD
 ;reverse the year
 S ZY=5000-ZY
 ;reverse the month
 S ZM=12-ZM
 ;rebuild
 S ZX=$C($E(ZY,1,2)+33)_$C($E(ZY,3,3)+33)_$C($E(ZY,4,4)+33)_$C(ZM+33)_$C(ZD+33)
 Q ZX
 ;
NL(ZX) ;Strips out ascii 0 from any string
 S ZX=$TR(ZX,$C(0),"")
 Q ZX
 ;
LP(ZX,ZY,ZZ)     ;Returns the last piece of a string
 ;ZX-Returns the last piece in the calling variable
 ;ZY is the delimiter 
 ;ZZ Returns the last piece number in ZZ
 F ZZ=0:1 I $P(ZX,ZY,ZZ+1,ZZ+100)="" S ZX=$P(ZX,ZY,ZZ) Q
 Q ZX
 ;
CS(ZX,ZY,ZZ,ZU) ;Clears the screen from a specified row from column to row
 N R,C
 S ZY=$G(ZY,1)
 S ZZ=$G(ZZ,24)
 F R=ZX:1:ZZ S C=ZY W @%("POS"),%("CEL")
 Q
 I $G(%)'="" DO
 . I '$D(ZY) F R=ZX:1:24 K %S(%,R)
 . I '$D(ZY) Q
 . S ZZ=$G(ZZ,24)
 . F R=ZX:1:ZZ S C=ZY-1 FOR  S C=$O(%S(%,R,C)) Q:C=""  K %S(%,R,C)
 ;;AW fix for screen corruption in LV (missing top bar)
 ;;I '$D(ZY),ZX=3,%("TERM")="WINTERM",($G(%("LVVER"))'<2) D BLOCK^ET(0,42-20,9*80,54,95) S R=ZX+1,C=1 W @%("POS"),%("CTE") Q
 I '$D(ZY),ZX=3,%("TERM")="WINTERM" D BLOCK^ET(0,42,9*80,54,95) S R=ZX+1,C=1 W @%("POS"),%("CTE") Q
 I '$D(ZY) S R=ZX,C=1 W @%("POS"),%("CTE") Q
 S ZZ=$G(ZZ,24)
 I $D(ZU) DO  Q
 . F R=ZX:1:ZZ S C=ZY W @%("POS"),$J("",ZU-ZY+1)
 F R=ZX:1:ZZ S C=ZY W @%("POS"),%("CEL")
 Q
 
 ;
DF(Z1,Z2,ZZ)       ;Calculates the difference in days between two days [ 11/11/91  10:21 AM ]
 ;Z1,Z2 are the dates in 5 char ascii .Z is returned
 ;
 N ZD1,ZM1,ZY1,ZD2,ZM2,ZY2,ETN,NTE,NQ
 I Z1=Z2 S Z=0 Q Z
 I $A(Z1)>60,Z2]Z1 S Z=Z2,Z2=Z1,Z1=Z
 ELSE  I $A(Z1)<60,Z1]Z2 S Z=Z2,Z2=Z1,Z1=Z
 S Z1=$$DA(Z1),ZD1=$P(Z1,".",1),ZM1=$P(Z1,".",2),ZY1=$P(Z1,".",3)
 S Z2=$$DA(Z2),ZD2=$P(Z2,".",1),ZM2=$P(Z2,".",2),ZY2=$P(Z2,".",3)
NEW ;
 S ETN=$S(ZY2#4:$P(%("NY")," ",ZM2)+ZD2,1:$P(%("NL")," ",ZM2)+ZD2)
 S NTE=$S(ZY1#4:$P(%("YN")," ",ZM1)-ZD1,1:$P(%("LN")," ",ZM1)-ZD1)
 I ZY1=ZY2 S NQ=$S(ZY1#4:365,1:366) S ZZ=ETN-(NQ-NTE) Q ZZ
 I ZY2>ZY1 S ZZ=ETN+NTE+(365*(ZY2-ZY1)-365) Q ZZ
 S ZZ=ETN+NTE+(365*(ZY1-ZY2)-365) Q ZZ
 ;
WR(ZX,ZY) ;Extrinsic function to wrap a string
 ;Resturns tha array in ZX with wrap lenght in ZY
 N ZZ,ZU
 S ZU=ZX K ZX S ZX=ZU
 S ZU=1
 I $L(ZX)'>ZY S ZX(1)=ZX Q ZX
 F ZZ=ZY:-1:0 I "., "[$E(ZX,ZZ) S ZZ=$S(ZZ=0:ZY,1:ZZ) S ZX(ZU)=$E(ZX,1,ZZ),ZX=$E(ZX,ZZ+1,$L(ZX)) S ZU=ZU+1,ZZ=ZY Q:ZX=""
 Q ZX
 ;
MS(ROW,COL,MESAGE,CLEAR,REV,JUST)    ;Parameter driven routine to display a message
 ;ROW,COL are row and column
 ;MESAGE is the message
 ;CLEAR is an optional flag to clear the line
 ;REV is optional reverse flag
 ;JUST optional justification
 N R,C,att,len
 s att=1
 S JUST=$G(JUST)
 I $G(%("TERM"))="WINTERM",$G(COL)=1,ROW=2 D TITLE^STDMENU(MESAGE) Q
 I ROW=2,$G(COL)=1,$G(REV)=1 S MESAGE=$$EMAIL^STDLIB(MESAGE)
 S MESAGE=$J(MESAGE,JUST)
 S len=$l(MESAGE)
 I COL="C" S COL=40-(len\2)
 I $G(REV) W %("CRV") I $G(%)'="" S att=2
 S R=ROW,C=COL W @%("POS"),MESAGE I $G(CLEAR) W $S($G(REV):$J("",80-len),1:%("CEL"))
 I $G(%)'="" S %S(%,R,C)=att_MESAGE DO
 . FOR  S C=$O(%S(%,R,C)) Q:C=""  I COL+len>(C-1)!($G(CLEAR)) K %S(%,R,C)
 I $G(REV) W %("CNO")
 Q
 ;
ER(ZX,ZY,HANG,CLEAR,R,C)          ;Error display
 ;ZX is the error number held in ^H("ERROR")
 ;ZY is the optional varaible to display the error
 ;HANG is opional time out
 ;CLEAR is flag to clear error if required
 ; optional row and colunm
 ;^TERR($J) is a flag set to indicate an error
 I $G(R)="" S R=24,C=1
 W *7
 W @%("POS"),"[ ",$G(^H("ERROR",ZX))
 W:$G(ZY)'="" " '",ZY,"'"
 W " ]"
 S ^TERR($J)=R_"~"_C
 I $G(HANG) H HANG
 I $G(CLEAR) D CS^LIB(24)
 Q
TM(ZX,ZY,ZZ) ;Calculates a time from a variable equivalent to $H part 2
 ;ZX is a variable of $H type
 ;if ZX is not defined it is derived from $H
 I '$D(ZX) S ZX=$P($H,",",2)
 S ZY=ZX\60
 S ZZ=$S(ZY<720:" am",1:" pm")
 S ZX=($S(ZY\60>12:ZY\60-12,1:ZY\60))_":"_($S(ZY#60>9:ZY#60,1:"0"_(ZY#60)))_ZZ
 Q ZX
YN(ROW,COLUMN,PROMPT,CLEAR,REV,JUST,LINE,FUN,LAST)          ;Yes or no input
 ;ROW,COLUMN is row and column of input
 ;PROMPT is prompt
 ;CLEAR is flag to clear line
 ;REVERSE is flag to reverse video input
 ;JUST justifies the prompt
 ;LINE flag to clear the line after question
 ;FUN =string of FK in /17/18/ format
 ;Returns $T
 N R,C,K
 I $G(LAST)="" S LAST=" "
 S R=ROW,C=COLUMN I PROMPT'="" W @%("POS"),$J(PROMPT_" : ",$G(JUST))
 I PROMPT="" W @%("POS")
 I $G(CLEAR) W %("CEL")
 I $G(REV),($G(LAST)'="") W %("CRV"),LAST,%("CNO"),@%("CL")
 I LAST=" " K LAST
 FOR  W %("OC") D OFF^ECHO R *K S FK=$ZB\256 D ON^ECHO DO  Q:$D(K)
 . I K=13,$G(LAST)'="" S K=$A(LAST)
 . I $G(FUN)'="",FK=XIT S K="" Q
 . I FK'=0 I $G(FUN)[("/"_FK_"/") S K="" Q
 .  S K=$C(K),K=$TR(K,"yn","YN")
 .  I K'="Y"&(K'="N") W *7 KILL K
 ;set $T if ans="Y"
 I FK=HLP S K="Y"
 W K
 I $G(LINE) W @%("POS"),%("CEL")
 IF K="Y"
 Q
KE(K,TIME,CHAR) ;Reads a key and returns ascii value of K and $ZB\256 in FK
 ;TIME is time out for read
 S FK=0
KET I $G(TIME) D OFF^ECHO R *K:TIME Q:'$T
 I '$G(TIME) D OFF^ECHO R *K
 S FK=$ZB\256
 I K<2,FK=0 R *K:1 S FK=$S(K=73:25,K=81:26,K=82:22,K=79:24,K=71:21,K=116:52,K=115:53,K=84:52,K=83:53,K=15:10,1:0) S K=0 D ON^ECHO I 1 Q
 D ON^ECHO
 I $D(CHAR) I K=13 S K="" I 1 Q
 I $D(CHAR) S K=$C(K)
 I 1
 Q:FK>0
 Q
 
TR(ZX,ZY,ZZ) ;Extrinsix function to translate a string [ 01/19/92  5:03 PM ]
 ;ZX is the variable
 ;ZY is the string to translate
 ;ZZis the string to tranlsate to
 N ZW
 S ZW=0
 FOR  S ZW=$F(ZX,ZY,ZW) Q:ZW=0  S ZW=ZW-$L(ZY)-1 S ZX=$E(ZX,0,ZW)_ZZ_$E(ZX,ZW+$L(ZY)+1,50000),ZW=ZW+$L(ZZ)+1
 Q ZX
AK(ROW,COL,CLR) ;Any key
 N K
 D MS^LIB(ROW,COL,"Press any key to continue : ") D KE(.K)
 I $G(CLR) S $Y=CLR D CS(CLR)
 Q
