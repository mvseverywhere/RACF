 /* REXX */                                                              
 /* 21/07/2022 - GCO VERSION 1.0                                       */
 /* ASKS CLASS AND PROFILE-RETURNS USER & CYCLE THROUGH GROUPS TO FIND */
 /* USERID AND USER NAMES                                              */
 SAY "CLASS:"                                                            
 PARSE UPPER PULL CLASS                                                  
 /*--------------------------------------------------------------------*/
 /* ---> CHANGE:  ADD VERIFICATION IF EMPTY                            */
 /* ---> CHANGE:  ADD VERIFICATION IF EXISTS                           */
 /*--------------------------------------------------------------------*/
 SAY "PROFILE:"                                                          
 PARSE UPPER PULL PROFILE                                                
 /*--------------------------------------------------------------------*/
 /* ---> CHANGE:  ADD VERIFICATION IF EMPTY                            */
 /* ---> CHANGE:  ADD VERIFICATION IF EXISTS                           */
 /*--------------------------------------------------------------------*/
 SAY "USERID:"                                                           
 PARSE UPPER PULL USERACC                                                
 _RC=IRRXUTIL("EXTRACT",CLASS,PROFILE,"RACF","","FALSE")                 
 /* BASIC ERROR HANDLER */                                               
 IF (WORD(_RC,1)<>0) THEN DO                                             
    SAY "_RC="_RC                                                        
    SAY "ERROR: VERIFY CLASS AND PROFILE NAME"                           
 /*--------------------------------------------------------------------*/
 /*    IF _RC=12 12 4 4 4  --> PROFILE DO NOT EXISTS                   */
 /*    IF _RC=12 12 4 4 12 --> CLASS DO NOT EXISTS                     */
 /*    IF _RC=8 2 1 0 0 --> CLASS EMPTY                                */
 /*    IF _RC=8 3 1 0 0 --> PROFILE EMPTY                              */
 /*--------------------------------------------------------------------*/
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
** LEVEL 1: ADD ACCESS TYPE TAKEN FROM RACF.BASE.ACLACS.A             */
SAY " "!!RACF.BASE.ACLID.A!!":"!!RACF.BASE.ACLACS.A                     
_RC=IRRXUTIL("EXTRACT","GROUP",RACF.BASE.ACLID.A,"GRP")                 
IF (WORD(_RC,1)<>0) THEN DO                                             
   IF _RC = "12 12 4 4 4" THEN                                          
/* SAY "GROUP " RACF.BASE.ACLID.A " DOES NOT EXIST" */                  
   ITERATE                                                              
END                                                                     
/*-------------------------------------------------------------------*/ 
/* IS THE GROUP EMPTY?                                               */ 
/*-------------------------------------------------------------------*/ 
IF GRP.BASE.CONNECTS.REPEATCOUNT = '' THEN DO                           
  /* X = WL2("GROUP" PROFILE "HAS NO USERS CONNECTED") */               
   SAY "GROUP " RACF.BASE.ACLID.A " HAS NO USERS CONNECTED"             
   ITERATE                                                              
END                                                                     
/*-------------------------------------------------------------------*/ 
/* CYCLE GROUP CONNECTED USERS AND EXTRACT INFORMATION               */ 
/*-------------------------------------------------------------------*/ 
UCNT = GRP.BASE.CONNECTS.REPEATCOUNT                                    
DO I = 1 TO UCNT                                                        
  ACUSERID = GRP.BASE.GUSERID.I                                         
  ACLVL = GRP.BASE.GAUTH.I                                              
  /* -------------------------------------------------------------- */  
  /* CALL IRRXUTIL TO GET THE USER'S NAME                           */  
  /*                                                                */  
  /* -------------------------------------------------------------- */ 
    _RC=IRRXUTIL("EXTRACT","USER",ACUSERID,"TEST")                       
  IF (WORD(_RC,1)=0) THEN                                              
    ACNAME = TEST.BASE.NAME.1                                          
 SAY "    "LEFT(RACF.BASE.ACLID.A,8) LEFT(ACUSERID,10) LEFT(ACNAME,21) 
  IF ACUSERID = LEFT(USERACC,8) THEN                                   
     SAY "---->" USERACC "HAS ACCESS TO PROFILE:" PROFILE "<----"      
  END                                                                  
END                                                                    
