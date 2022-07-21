/* REXX */
/* GIVEN CLASS AND PROFILE, SPIT USERS & CYCLE THROUGH GROUPS TO SPIT */
/* USERID AND USER NAMES                                              */
/* 21/07/2022 - GCO VERSION 1.0                                       */
SAY "FULL CLASS NAME?"
PARSE UPPER PULL CLASS
SAY "PROFILE?"
PARSE UPPER PULL PROFILE
SAY "USERID?"
PARSE UPPER PULL USERACC
MYRC=IRRXUTIL("EXTRACT",CLASS,PROFILE,"RACF","","FALSE")
/* ERROR HANDLING */
IF (WORD(MYRC,1)<>0) THEN DO
   SAY "MYRC="MYRC
   SAY "AN ERROR OCCURRED - PROBABLY NO PROFILE"
   EXIT 1
END
/* OUTPUT */
SAY "CLASS: "RACF.CLASS
SAY "PROFILE: "RACF.PROFILE
SAY "OWNER: "RACF.BASE.OWNER.1
SAY "UACC: "RACF.BASE.UACC.1
SAY "ACL:"
DO A=1 TO RACF.BASE.ACLCNT.REPEATCOUNT
IF RACF.BASE.ACLID.A = LEFT(USERACC,8) THEN
   SAY "---->" USERACC "HAS ACCESS TO PROFILE:" PROFILE "<----"
SAY " "!!RACF.BASE.ACLID.A!!":"!!RACF.BASE.ACLACS.A
MYRC=IRRXUTIL("EXTRACT","GROUP",RACF.BASE.ACLID.A,"GRP")
IF (WORD(MYRC,1)<>0) THEN DO
   IF MYRC = "12 12 4 4 4" THEN
/* SAY "GROUP " RACF.BASE.ACLID.A " DOES NOT EXIST" */
   ITERATE
END
/*-------------------------------------------------------------------*/
/* FIND IF THERE'S NO CONNECTED USERS FOR GROUP                     */
/*-------------------------------------------------------------------*/
IF GRP.BASE.CONNECTS.REPEATCOUNT = '' THEN DO
  /* X = WL2("GROUP" PROFILE "HAS NO USERS CONNECTED") */
   SAY "GROUP " RACF.BASE.ACLID.A " HAS NO USERS CONNECTED"
   ITERATE
END
/*-------------------------------------------------------------------*/
/* FOR EACH CONNECTED USER, EXTRACT THE USER'S DETAILS               */
/*-------------------------------------------------------------------*/
UCNT = GRP.BASE.CONNECTS.REPEATCOUNT
DO I = 1 TO UCNT
  ACUSERID = GRP.BASE.GUSERID.I
  ACLVL = GRP.BASE.GAUTH.I
  /* -------------------------------------------------------------- */
  /* CALL IRRXUTIL TO GET THE USER'S NAME                           */
  /*                                                                */
  /* -------------------------------------------------------------- */
  MYRC=IRRXUTIL("EXTRACT","USER",ACUSERID,"TEST")
  IF (WORD(MYRC,1)=0) THEN
    ACNAME = TEST.BASE.NAME.1
 SAY LEFT(RACF.BASE.ACLID.A,8) LEFT(ACUSERID,10) LEFT(ACNAME,21)
  IF ACUSERID = LEFT(USERACC,8) THEN
     SAY "---->" USERACC "HAS ACCESS TO PROFILE:" PROFILE "<----"
  END
END
