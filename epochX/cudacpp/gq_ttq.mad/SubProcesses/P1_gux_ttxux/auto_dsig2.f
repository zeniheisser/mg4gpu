      DOUBLE PRECISION FUNCTION DSIG2(PP,WGT,IMODE)
C     ****************************************************
C     
C     Generated by MadGraph5_aMC@NLO v. 3.5.0_lo_vect, 2023-01-26
C     By the MadGraph5_aMC@NLO Development Team
C     Visit launchpad.net/madgraph5 and amcatnlo.web.cern.ch
C     
C     Process: g u~ > t t~ u~ WEIGHTED<=3 @1
C     Process: g c~ > t t~ c~ WEIGHTED<=3 @1
C     Process: g d~ > t t~ d~ WEIGHTED<=3 @1
C     Process: g s~ > t t~ s~ WEIGHTED<=3 @1
C     
C     RETURNS DIFFERENTIAL CROSS SECTION
C     Input:
C     pp    4 momentum of external particles
C     wgt   weight from Monte Carlo
C     imode 0 run, 1 init, 2 reweight, 
C     3 finalize, 4 only PDFs,
C     5 squared amplitude only (never
C     generate events)
C     Output:
C     Amplitude squared and summed
C     ****************************************************
      IMPLICIT NONE
C     
C     CONSTANTS
C     
      INCLUDE 'genps.inc'
      INCLUDE 'nexternal.inc'
      INCLUDE 'maxconfigs.inc'
      INCLUDE 'maxamps.inc'
      DOUBLE PRECISION       CONV
      PARAMETER (CONV=389379.66*1000)  !CONV TO PICOBARNS
      REAL*8     PI
      PARAMETER (PI=3.1415926D0)
C     
C     ARGUMENTS 
C     
      DOUBLE PRECISION PP(0:3,NEXTERNAL), WGT
      INTEGER IMODE
C     
C     LOCAL VARIABLES 
C     
      INTEGER I,ITYPE,LP,IPROC
      DOUBLE PRECISION G1
      DOUBLE PRECISION CX2,SX2,UX2,DX2
      DOUBLE PRECISION XPQ(-7:7),PD(0:MAXPROC)
      DOUBLE PRECISION DSIGUU,R,RCONF

      INTEGER LUN,ICONF,IFACT,NFACT
      DATA NFACT/1/
      SAVE NFACT
C     
C     STUFF FOR DRESSED EE COLLISIONS
C     
      INCLUDE '../../Source/PDF/eepdf.inc'
      DOUBLE PRECISION EE_COMP_PROD

      INTEGER I_EE
C     
C     STUFF FOR UPC
C     
      DOUBLE PRECISION PHOTONPDFSQUARE
C     
C     EXTERNAL FUNCTIONS
C     
      LOGICAL PASSCUTS
      DOUBLE PRECISION ALPHAS2,REWGT,PDG2PDF,CUSTOM_BIAS
      INTEGER NEXTUNOPEN
C     
C     GLOBAL VARIABLES
C     
      INTEGER          IPSEL
      COMMON /SUBPROC/ IPSEL
C     MINCFIG has this config number
      INTEGER           MINCFIG, MAXCFIG
      COMMON/TO_CONFIGS/MINCFIG, MAXCFIG
      INTEGER MAPCONFIG(0:LMAXCONFIGS), ICONFIG
      COMMON/TO_MCONFIGS/MAPCONFIG, ICONFIG
C     Keep track of whether cuts already calculated for this event
      LOGICAL CUTSDONE,CUTSPASSED
      COMMON/TO_CUTSDONE/CUTSDONE,CUTSPASSED

      INTEGER SUBDIAG(MAXSPROC),IB(2)
      COMMON/TO_SUB_DIAG/SUBDIAG,IB
      INCLUDE '../../Source/vector.inc'  ! needed to define VECSIZE_MEMMAX
      INCLUDE 'run.inc'
C     Common blocks
      CHARACTER*7         PDLABEL,EPA_LABEL
      INTEGER       LHAID
      COMMON/TO_PDF/LHAID,PDLABEL,EPA_LABEL
      DOUBLE PRECISION RHEL, RCOL
      INTEGER SELECTED_HEL(VECSIZE_MEMMAX)
      INTEGER SELECTED_COL(VECSIZE_MEMMAX)
C     
C     local
C     
      DOUBLE PRECISION P1(0:3, NEXTERNAL)
      INTEGER CHANNEL
C     
C     DATA
C     
      DATA G1/1*1D0/
      DATA CX2,SX2,UX2,DX2/4*1D0/
C     ----------
C     BEGIN CODE
C     ----------
      DSIG2=0D0

      IF(IMODE.EQ.1)THEN
C       Set up process information from file symfact
        LUN=NEXTUNOPEN()
        NFACT=1
        OPEN(UNIT=LUN,FILE='../symfact.dat',STATUS='OLD',ERR=20)
        DO WHILE(.TRUE.)
          READ(LUN,*,ERR=10,END=10) RCONF, IFACT
          ICONF=INT(RCONF)
          IF(ICONF.EQ.MAPCONFIG(MINCFIG))THEN
            NFACT=IFACT
          ENDIF
        ENDDO
        DSIG2 = NFACT
 10     CLOSE(LUN)
        RETURN
 20     WRITE(*,*)'Error opening symfact.dat. No symmetry factor used.'
        RETURN
      ENDIF
C     Continue only if IMODE is 0, 4 or 5
      IF(IMODE.NE.0.AND.IMODE.NE.4.AND.IMODE.NE.5) RETURN


      IF (ABS(LPP(IB(1))).GE.1) THEN
          !LP=SIGN(1,LPP(IB(1)))
        G1=PDG2PDF(LPP(IB(1)),0, IB(1),XBK(IB(1)),DSQRT(Q2FACT(IB(1))))
      ENDIF
      IF (ABS(LPP(IB(2))).GE.1) THEN
          !LP=SIGN(1,LPP(IB(2)))
        CX2=PDG2PDF(LPP(IB(2)),-4, IB(2),XBK(IB(2)),DSQRT(Q2FACT(IB(2))
     $   ))
        SX2=PDG2PDF(LPP(IB(2)),-3, IB(2),XBK(IB(2)),DSQRT(Q2FACT(IB(2))
     $   ))
        UX2=PDG2PDF(LPP(IB(2)),-2, IB(2),XBK(IB(2)),DSQRT(Q2FACT(IB(2))
     $   ))
        DX2=PDG2PDF(LPP(IB(2)),-1, IB(2),XBK(IB(2)),DSQRT(Q2FACT(IB(2))
     $   ))
      ENDIF
      PD(0) = 0D0
      IPROC = 0
      IPROC=IPROC+1  ! g u~ > t t~ u~
      PD(IPROC)=G1*UX2
      PD(0)=PD(0)+DABS(PD(IPROC))
      IPROC=IPROC+1  ! g c~ > t t~ c~
      PD(IPROC)=G1*CX2
      PD(0)=PD(0)+DABS(PD(IPROC))
      IPROC=IPROC+1  ! g d~ > t t~ d~
      PD(IPROC)=G1*DX2
      PD(0)=PD(0)+DABS(PD(IPROC))
      IPROC=IPROC+1  ! g s~ > t t~ s~
      PD(IPROC)=G1*SX2
      PD(0)=PD(0)+DABS(PD(IPROC))
      IF (IMODE.EQ.4)THEN
        DSIG2 = PD(0)
        RETURN
      ENDIF
      IF(FRAME_ID.NE.6)THEN
        CALL BOOST_TO_FRAME(PP, FRAME_ID, P1)
      ELSE
        P1 = PP
      ENDIF

      CHANNEL = SUBDIAG(2)
      CALL RANMAR(RHEL)
      CALL RANMAR(RCOL)
      CALL SMATRIX2(P1,RHEL, RCOL,CHANNEL,1, DSIGUU, SELECTED_HEL(1),
     $  SELECTED_COL(1))


      IF (IMODE.EQ.5) THEN
        IF (DSIGUU.LT.1D199) THEN
          DSIG2 = DSIGUU*CONV
        ELSE
          DSIG2 = 0.0D0
        ENDIF
        RETURN
      ENDIF
C     Select a flavor combination (need to do here for right sign)
      CALL RANMAR(R)
      IPSEL=0
      DO WHILE (R.GE.0D0 .AND. IPSEL.LT.IPROC)
        IPSEL=IPSEL+1
        R=R-DABS(PD(IPSEL))/PD(0)
      ENDDO

      DSIGUU=DSIGUU*REWGT(PP)

C     Apply the bias weight specified in the run card (default is 1.0)
      DSIGUU=DSIGUU*CUSTOM_BIAS(PP,DSIGUU,2,1)

      DSIGUU=DSIGUU*NFACT

      IF (DSIGUU.LT.1D199) THEN
C       Set sign of dsig based on sign of PDF and matrix element
        DSIG2=DSIGN(CONV*PD(0)*DSIGUU,DSIGUU*PD(IPSEL))
      ELSE
        WRITE(*,*) 'Error in matrix element'
        DSIGUU=0D0
        DSIG2=0D0
      ENDIF
C     Generate events only if IMODE is 0.
      IF(IMODE.EQ.0.AND.DABS(DSIG2).GT.0D0)THEN
C       Call UNWGT to unweight and store events
        CALL UNWGT(PP,DSIG2*WGT,2,SELECTED_HEL(1), SELECTED_COL(1), 1)
      ENDIF

      END
C     
C     Functionality to handling grid
C     



      DOUBLE PRECISION FUNCTION DSIG2_VEC(ALL_PP, ALL_XBK, ALL_Q2FACT,
     $  ALL_CM_RAP, ALL_WGT, IMODE, ALL_OUT, VECSIZE_USED)
C     ****************************************************
C     
C     Generated by MadGraph5_aMC@NLO v. 3.5.0_lo_vect, 2023-01-26
C     By the MadGraph5_aMC@NLO Development Team
C     Visit launchpad.net/madgraph5 and amcatnlo.web.cern.ch
C     
C     Process: g u~ > t t~ u~ WEIGHTED<=3 @1
C     Process: g c~ > t t~ c~ WEIGHTED<=3 @1
C     Process: g d~ > t t~ d~ WEIGHTED<=3 @1
C     Process: g s~ > t t~ s~ WEIGHTED<=3 @1
C     
C     RETURNS DIFFERENTIAL CROSS SECTION
C     Input:
C     pp    4 momentum of external particles
C     wgt   weight from Monte Carlo
C     imode 0 run, 1 init, 2 reweight, 
C     3 finalize, 4 only PDFs,
C     5 squared amplitude only (never
C     generate events)
C     Output:
C     Amplitude squared and summed
C     ****************************************************
      IMPLICIT NONE
C     
C     CONSTANTS
C     
      INCLUDE '../../Source/vector.inc'  ! needed to define VECSIZE_MEMMAX
      INCLUDE 'genps.inc'
      INCLUDE 'nexternal.inc'
      INCLUDE 'maxconfigs.inc'
      INCLUDE 'maxamps.inc'
      DOUBLE PRECISION       CONV
      PARAMETER (CONV=389379.66*1000)  !CONV TO PICOBARNS
      REAL*8     PI
      PARAMETER (PI=3.1415926D0)
C     
C     ARGUMENTS 
C     
      DOUBLE PRECISION ALL_PP(0:3,NEXTERNAL,VECSIZE_MEMMAX)
      DOUBLE PRECISION ALL_WGT(VECSIZE_MEMMAX)
      DOUBLE PRECISION ALL_XBK(2,VECSIZE_MEMMAX)
      DOUBLE PRECISION ALL_Q2FACT(2,VECSIZE_MEMMAX)
      DOUBLE PRECISION ALL_CM_RAP(VECSIZE_MEMMAX)
      INTEGER IMODE
      DOUBLE PRECISION ALL_OUT(VECSIZE_MEMMAX)
      INTEGER VECSIZE_USED
C     ----------
C     BEGIN CODE
C     ----------
C     
C     LOCAL VARIABLES 
C     
      INTEGER I,ITYPE,LP,IPROC
      DOUBLE PRECISION G1(VECSIZE_MEMMAX)
      DOUBLE PRECISION CX2(VECSIZE_MEMMAX),SX2(VECSIZE_MEMMAX)
     $ ,UX2(VECSIZE_MEMMAX),DX2(VECSIZE_MEMMAX)
      DOUBLE PRECISION XPQ(-7:7),PD(0:MAXPROC)
      DOUBLE PRECISION ALL_PD(0:MAXPROC, VECSIZE_MEMMAX)
      DOUBLE PRECISION DSIGUU,R,RCONF
      INTEGER LUN,ICONF,IFACT,NFACT
      DATA NFACT/1/
      SAVE NFACT
      DOUBLE PRECISION RHEL  ! random number
      INTEGER CHANNEL
C     
C     STUFF FOR DRESSED EE COLLISIONS --even if not supported for now--
C     
      INCLUDE '../../Source/PDF/eepdf.inc'
      DOUBLE PRECISION EE_COMP_PROD

      INTEGER I_EE
C     
C     EXTERNAL FUNCTIONS
C     
      LOGICAL PASSCUTS
      DOUBLE PRECISION ALPHAS2,REWGT,PDG2PDF,CUSTOM_BIAS
      INTEGER NEXTUNOPEN
      DOUBLE PRECISION DSIG2
C     
C     GLOBAL VARIABLES
C     
      INTEGER          IPSEL
      COMMON /SUBPROC/ IPSEL
C     MINCFIG has this config number
      INTEGER           MINCFIG, MAXCFIG
      COMMON/TO_CONFIGS/MINCFIG, MAXCFIG
      INTEGER MAPCONFIG(0:LMAXCONFIGS), ICONFIG
      COMMON/TO_MCONFIGS/MAPCONFIG, ICONFIG
C     Keep track of whether cuts already calculated for this event
      LOGICAL CUTSDONE,CUTSPASSED
      COMMON/TO_CUTSDONE/CUTSDONE,CUTSPASSED

      INTEGER SUBDIAG(MAXSPROC),IB(2)
      COMMON/TO_SUB_DIAG/SUBDIAG,IB
      INCLUDE 'run.inc'

      DOUBLE PRECISION P_MULTI(0:3, NEXTERNAL, VECSIZE_MEMMAX)
      DOUBLE PRECISION HEL_RAND(VECSIZE_MEMMAX)
      DOUBLE PRECISION COL_RAND(VECSIZE_MEMMAX)
      INTEGER SELECTED_HEL(VECSIZE_MEMMAX)
      INTEGER SELECTED_COL(VECSIZE_MEMMAX)

C     Common blocks
      CHARACTER*7         PDLABEL,EPA_LABEL
      INTEGER       LHAID
      COMMON/TO_PDF/LHAID,PDLABEL,EPA_LABEL

C     
C     local
C     
      DOUBLE PRECISION P1(0:3, NEXTERNAL)
      INTEGER IVEC

C     
C     DATA
C     
      DATA G1/VECSIZE_MEMMAX*1D0/
      DATA CX2,SX2,UX2,DX2/VECSIZE_MEMMAX*1D0,VECSIZE_MEMMAX*1D0
     $ ,VECSIZE_MEMMAX*1D0,VECSIZE_MEMMAX*1D0/
C     ----------
C     BEGIN CODE
C     ----------

      IF(IMODE.EQ.1)THEN
        NFACT = DSIG2(ALL_PP(0,1,1), ALL_WGT(1), IMODE)
        RETURN
      ENDIF

C     Continue only if IMODE is 0, 4 or 5
      IF(IMODE.NE.0.AND.IMODE.NE.4.AND.IMODE.NE.5) RETURN


      DO IVEC=1,VECSIZE_USED
        IF (ABS(LPP(IB(1))).GE.1) THEN
            !LP=SIGN(1,LPP(IB(1)))
          G1(IVEC)=PDG2PDF(LPP(IB(1)),0, IB(1),ALL_XBK(IB(1),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(1), IVEC)))
        ENDIF
        IF (ABS(LPP(IB(2))).GE.1) THEN
            !LP=SIGN(1,LPP(IB(2)))
          CX2(IVEC)=PDG2PDF(LPP(IB(2)),-4, IB(2),ALL_XBK(IB(2),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(2), IVEC)))
          SX2(IVEC)=PDG2PDF(LPP(IB(2)),-3, IB(2),ALL_XBK(IB(2),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(2), IVEC)))
          UX2(IVEC)=PDG2PDF(LPP(IB(2)),-2, IB(2),ALL_XBK(IB(2),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(2), IVEC)))
          DX2(IVEC)=PDG2PDF(LPP(IB(2)),-1, IB(2),ALL_XBK(IB(2),IVEC)
     $     ,DSQRT(ALL_Q2FACT(IB(2), IVEC)))
        ENDIF
      ENDDO
      ALL_PD(0,:) = 0D0
      IPROC = 0
      IPROC=IPROC+1  ! g u~ > t t~ u~
      DO IVEC=1, VECSIZE_USED
        ALL_PD(IPROC,IVEC)=G1(IVEC)*UX2(IVEC)
        ALL_PD(0,IVEC)=ALL_PD(0,IVEC)+DABS(ALL_PD(IPROC,IVEC))

      ENDDO
      IPROC=IPROC+1  ! g c~ > t t~ c~
      DO IVEC=1, VECSIZE_USED
        ALL_PD(IPROC,IVEC)=G1(IVEC)*CX2(IVEC)
        ALL_PD(0,IVEC)=ALL_PD(0,IVEC)+DABS(ALL_PD(IPROC,IVEC))

      ENDDO
      IPROC=IPROC+1  ! g d~ > t t~ d~
      DO IVEC=1, VECSIZE_USED
        ALL_PD(IPROC,IVEC)=G1(IVEC)*DX2(IVEC)
        ALL_PD(0,IVEC)=ALL_PD(0,IVEC)+DABS(ALL_PD(IPROC,IVEC))

      ENDDO
      IPROC=IPROC+1  ! g s~ > t t~ s~
      DO IVEC=1, VECSIZE_USED
        ALL_PD(IPROC,IVEC)=G1(IVEC)*SX2(IVEC)
        ALL_PD(0,IVEC)=ALL_PD(0,IVEC)+DABS(ALL_PD(IPROC,IVEC))

      ENDDO


      IF (IMODE.EQ.4)THEN
        ALL_OUT(:) = ALL_PD(0,:)
        RETURN
      ENDIF

      DO IVEC=1,VECSIZE_USED
C       Do not need those three here do I?	 
        XBK(:) = ALL_XBK(:,IVEC)
C       CM_RAP = ALL_CM_RAP(IVEC)
        Q2FACT(:) = ALL_Q2FACT(:, IVEC)

C       Select a flavor combination (need to do here for right sign)
        CALL RANMAR(R)
        IPSEL=0
        DO WHILE (R.GE.0D0 .AND. IPSEL.LT.IPROC)
          IPSEL=IPSEL+1
          R=R-DABS(ALL_PD(IPSEL,IVEC))/ALL_PD(0,IVEC)
        ENDDO

        IF(FRAME_ID.NE.6)THEN
          CALL BOOST_TO_FRAME(ALL_PP(0,1,IVEC), FRAME_ID, P_MULTI(0,1
     $     ,IVEC))
        ELSE
          P_MULTI(:,:,IVEC) = ALL_PP(:,:,IVEC)
        ENDIF
        CALL RANMAR(HEL_RAND(IVEC))
        CALL RANMAR(COL_RAND(IVEC))
      ENDDO
      CHANNEL = SUBDIAG(2)

      CALL SMATRIX2_MULTI(P_MULTI, HEL_RAND, COL_RAND, CHANNEL,
     $  ALL_OUT , SELECTED_HEL, SELECTED_COL, VECSIZE_USED)


      DO IVEC=1,VECSIZE_USED
        DSIGUU = ALL_OUT(IVEC)
        IF (IMODE.EQ.5) THEN
          IF (DSIGUU.LT.1D199) THEN
            ALL_OUT(IVEC) = DSIGUU*CONV
          ELSE
            ALL_OUT(IVEC) = 0.0D0
          ENDIF
          RETURN
        ENDIF

        XBK(:) = ALL_XBK(:,IVEC)
C       CM_RAP = ALL_CM_RAP(IVEC)
        Q2FACT(:) = ALL_Q2FACT(:, IVEC)

        IF(FRAME_ID.NE.6)THEN
          CALL BOOST_TO_FRAME(ALL_PP(0,1,IVEC), FRAME_ID, P1)
        ELSE
          P1 = ALL_PP(:,:,IVEC)
        ENDIF
C       call restore_cl_val_to(ivec)
        DSIGUU=DSIGUU*REWGT(P1)

C       Apply the bias weight specified in the run card (default is
C        1.0)
        DSIGUU=DSIGUU*CUSTOM_BIAS(P1,DSIGUU,2, IVEC)

        DSIGUU=DSIGUU*NFACT

        IF (DSIGUU.LT.1D199) THEN
C         Set sign of dsig based on sign of PDF and matrix element
          ALL_OUT(IVEC)=DSIGN(CONV*ALL_PD(0,IVEC)*DSIGUU,DSIGUU
     $     *ALL_PD(IPSEL,IVEC))
        ELSE
          WRITE(*,*) 'Error in matrix element'
          DSIGUU=0D0
          ALL_OUT(IVEC)=0D0
        ENDIF
C       Generate events only if IMODE is 0.
        IF(IMODE.EQ.0.AND.DABS(ALL_OUT(IVEC)).GT.0D0)THEN
C         Call UNWGT to unweight and store events
          CALL UNWGT(ALL_PP(0,1,IVEC), ALL_OUT(IVEC)*ALL_WGT(IVEC),2,
     $      SELECTED_HEL(IVEC), SELECTED_COL(IVEC), IVEC)
        ENDIF
      ENDDO

      END
C     
C     Functionality to handling grid
C     






      SUBROUTINE PRINT_ZERO_AMP2()

      RETURN
      END


      SUBROUTINE SMATRIX2_MULTI(P_MULTI, HEL_RAND, COL_RAND, CHANNEL,
     $  OUT, SELECTED_HEL, SELECTED_COL, VECSIZE_USED)
      USE OMP_LIB
      IMPLICIT NONE

      INCLUDE 'nexternal.inc'
      INCLUDE '../../Source/vector.inc'  ! needed to define VECSIZE_MEMMAX
      INCLUDE 'maxamps.inc'
      INTEGER                 NCOMB
      PARAMETER (             NCOMB=32)
      DOUBLE PRECISION P_MULTI(0:3, NEXTERNAL, VECSIZE_MEMMAX)
      DOUBLE PRECISION HEL_RAND(VECSIZE_MEMMAX)
      DOUBLE PRECISION COL_RAND(VECSIZE_MEMMAX)
      INTEGER CHANNEL
      DOUBLE PRECISION OUT(VECSIZE_MEMMAX)
      INTEGER SELECTED_HEL(VECSIZE_MEMMAX)
      INTEGER SELECTED_COL(VECSIZE_MEMMAX)
      INTEGER VECSIZE_USED

      INTEGER IVEC


!$OMP PARALLEL
!$OMP DO
      DO IVEC=1, VECSIZE_USED
        CALL SMATRIX2(P_MULTI(0,1,IVEC),
     &	                         hel_rand(IVEC),
     &                           col_rand(IVEC),
     &				 channel,
     &                           IVEC,
     &				 out(IVEC),
     &				 selected_hel(IVEC),
     &				 selected_col(IVEC)
     &				 )
      ENDDO
!$OMP END DO
!$OMP END PARALLEL
      RETURN
      END

      INTEGER FUNCTION GET_NHEL2(HEL, IPART)
C     if hel>0 return the helicity of particule ipart for the selected
C      helicity configuration
C     if hel=0 return the number of helicity state possible for that
C      particle 
      IMPLICIT NONE
      INTEGER HEL,I, IPART
      INCLUDE 'nexternal.inc'
      INTEGER ONE_NHEL(NEXTERNAL)
      INTEGER                 NCOMB
      PARAMETER (             NCOMB=32)
      INTEGER NHEL(NEXTERNAL,0:NCOMB)
      DATA (NHEL(I,0),I=1,5) / 2, 2, 2, 2, 2/
      DATA (NHEL(I,   1),I=1,5) /-1,-1,-1, 1, 1/
      DATA (NHEL(I,   2),I=1,5) /-1,-1,-1, 1,-1/
      DATA (NHEL(I,   3),I=1,5) /-1,-1,-1,-1, 1/
      DATA (NHEL(I,   4),I=1,5) /-1,-1,-1,-1,-1/
      DATA (NHEL(I,   5),I=1,5) /-1,-1, 1, 1, 1/
      DATA (NHEL(I,   6),I=1,5) /-1,-1, 1, 1,-1/
      DATA (NHEL(I,   7),I=1,5) /-1,-1, 1,-1, 1/
      DATA (NHEL(I,   8),I=1,5) /-1,-1, 1,-1,-1/
      DATA (NHEL(I,   9),I=1,5) /-1, 1,-1, 1, 1/
      DATA (NHEL(I,  10),I=1,5) /-1, 1,-1, 1,-1/
      DATA (NHEL(I,  11),I=1,5) /-1, 1,-1,-1, 1/
      DATA (NHEL(I,  12),I=1,5) /-1, 1,-1,-1,-1/
      DATA (NHEL(I,  13),I=1,5) /-1, 1, 1, 1, 1/
      DATA (NHEL(I,  14),I=1,5) /-1, 1, 1, 1,-1/
      DATA (NHEL(I,  15),I=1,5) /-1, 1, 1,-1, 1/
      DATA (NHEL(I,  16),I=1,5) /-1, 1, 1,-1,-1/
      DATA (NHEL(I,  17),I=1,5) / 1,-1,-1, 1, 1/
      DATA (NHEL(I,  18),I=1,5) / 1,-1,-1, 1,-1/
      DATA (NHEL(I,  19),I=1,5) / 1,-1,-1,-1, 1/
      DATA (NHEL(I,  20),I=1,5) / 1,-1,-1,-1,-1/
      DATA (NHEL(I,  21),I=1,5) / 1,-1, 1, 1, 1/
      DATA (NHEL(I,  22),I=1,5) / 1,-1, 1, 1,-1/
      DATA (NHEL(I,  23),I=1,5) / 1,-1, 1,-1, 1/
      DATA (NHEL(I,  24),I=1,5) / 1,-1, 1,-1,-1/
      DATA (NHEL(I,  25),I=1,5) / 1, 1,-1, 1, 1/
      DATA (NHEL(I,  26),I=1,5) / 1, 1,-1, 1,-1/
      DATA (NHEL(I,  27),I=1,5) / 1, 1,-1,-1, 1/
      DATA (NHEL(I,  28),I=1,5) / 1, 1,-1,-1,-1/
      DATA (NHEL(I,  29),I=1,5) / 1, 1, 1, 1, 1/
      DATA (NHEL(I,  30),I=1,5) / 1, 1, 1, 1,-1/
      DATA (NHEL(I,  31),I=1,5) / 1, 1, 1,-1, 1/
      DATA (NHEL(I,  32),I=1,5) / 1, 1, 1,-1,-1/

      GET_NHEL2 = NHEL(IPART, IABS(HEL))
      RETURN
      END


