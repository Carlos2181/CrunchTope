!!! *** Copyright Notice ***
!!! �CrunchFlow�, Copyright (c) 2016, The Regents of the University of California, through Lawrence Berkeley National Laboratory 
!!! (subject to receipt of any required approvals from the U.S. Dept. of Energy).� All rights reserved.
!!!�
!!! If you have questions about your rights to use or distribute this software, please contact 
!!! Berkeley Lab's Innovation & Partnerships Office at��IPO@lbl.gov.
!!!�
!!! NOTICE.� This Software was developed under funding from the U.S. Department of Energy and the U.S. Government 
!!! consequently retains certain rights. As such, the U.S. Government has been granted for itself and others acting 
!!! on its behalf a paid-up, nonexclusive, irrevocable, worldwide license in the Software to reproduce, distribute copies to the public, 
!!! prepare derivative works, and perform publicly and display publicly, and to permit other to do so.
!!!
!!! *** License Agreement ***
!!! �CrunchFlow�, Copyright (c) 2016, The Regents of the University of California, through Lawrence Berkeley National Laboratory)
!!! subject to receipt of any required approvals from the U.S. Dept. of Energy).  All rights reserved."
!!! 
!!! Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
!!! 
!!! (1) Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
!!!
!!! (2) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
!!! in the documentation and/or other materials provided with the distribution.
!!!
!!! (3) Neither the name of the University of California, Lawrence Berkeley National Laboratory, U.S. Dept. of Energy nor the names of 
!!! its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
!!!
!!! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
!!! BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
!!! SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
!!! DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
!!! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
!!! LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
!!! THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!!!
!!! You are under no obligation whatsoever to provide any bug fixes, patches, or upgrades to the features, functionality or 
!!! performance of the source code ("Enhancements") to anyone; however, if you choose to make your
!!! Enhancements available either publicly, or directly to Lawrence Berkeley National Laboratory, without 
!!! imposing a separate written license agreement for such 
!!! Enhancements, then you hereby grant the following license: a  non-exclusive, royalty-free perpetual license to install, use, 
!!! modify, prepare derivative works, incorporate into other computer software, distribute, and sublicense such enhancements or 
!!! derivative works thereof, in binary and source code form.

!!!      ****************************************

SUBROUTINE jac_exchange_local(ncomp,nexchange,nexch_sec,nsurf,nsurf_sec,neqn,jx,jy,jz)
USE crunchtype
USE params
USE concentration
USE solver
USE transport
USE medium
USE temperature

IMPLICIT NONE
!fp! auto_par_loops = 0;

!  External variables and arrays

INTEGER(I4B), INTENT(IN)                                  :: ncomp
INTEGER(I4B), INTENT(IN)                                  :: nexchange
INTEGER(I4B), INTENT(IN)                                  :: nexch_sec
INTEGER(I4B), INTENT(IN)                                  :: nsurf
INTEGER(I4B), INTENT(IN)                                  :: nsurf_sec
INTEGER(I4B), INTENT(IN)                                  :: neqn
INTEGER(I4B), INTENT(IN)                                  :: jx
INTEGER(I4B), INTENT(IN)                                  :: jy
INTEGER(I4B), INTENT(IN)                                  :: jz

!  Internal variables and arrays

INTEGER(I4B)                                              :: ix
INTEGER(I4B)                                              :: i2
INTEGER(I4B)                                              :: nex
INTEGER(I4B)                                              :: ixcheck
INTEGER(I4B)                                              :: ns
INTEGER(I4B)                                              :: i
INTEGER(I4B)                                              :: is2

REAL(DP)                                                 :: mutemp
REAL(DP)                                                 :: spex_conc
REAL(DP)                                                 :: sum1
REAL(DP)                                                 :: sum2
REAL(DP)                                                 :: exchangetemp
 
fch_local = 0.0
fexch = 0.0

IF (iexc == 1 .OR. iexc == 3) THEN  ! Gapon or Gaines-Thomas (equivalent fractions)

  DO nex = 1,nexch_sec
    spex_conc = spex10(nex+nexchange,jx,jy,jz)

    DO ix = 1,nexchange
      IF (muexc(nex,ix+ncomp) /= 0.0) THEN
        exchangetemp = exchangesites(ix,jx,jy,jz)
        mutemp = muexc(nex,ix+ncomp)
        DO i2 = 1,ncomp+nexchange
          fexch(ix+ncomp,i2) = fexch(ix+ncomp,i2) + mutemp*muexc(nex,i2)*    &
            spex_conc/exchangetemp
       END DO
      END IF
    END DO

    DO i = 1,ncomp
      IF (muexc(nex,i) /= 0.0) THEN
        mutemp = muexc(nex,i) 
        DO i2 = 1,ncomp+nexchange
          fch_local(i,i2) = fch_local(i,i2) + mutemp*muexc(nex,i2)*spex_conc
        END DO
      END IF
    END DO

  END DO


!!        do ix = 1,nexchange
!!          do i2 = 1,ncomp+nexchange
!!            sum2 = 0.0
!!            do nex = 1,nexch_sec
!!              sum2 = sum2 + muexc(nex,ix+ncomp)*muexc(nex,i2)*spex10(nexchange+nex,jx,jy,jz)
!!            end do
!!            fexch(ix+ncomp,i2) = sum2
!!          end do
!!        end do

ELSE    !                  Vanselow convention
  
  fweight = 0.0
  DO nex = 1,nexch_sec
    spex_conc = aexch(nex)
    ixcheck = ixlink(nex)
    DO ix = 1,nexchange
      IF (muexc(nex,ix+ncomp) /= 0.0) THEN
        mutemp = muexc(nex,ix+ncomp)
        DO i2 = 1,ncomp+nexchange
          fweight(ix+ncomp,i2) = fweight(ix+ncomp,i2) +     &
              mutemp*muexc(nex,i2)*spex_conc
        END DO
      END IF
      IF (ixcheck == ix) THEN
        DO i2 = 1,ncomp+nexchange
          fexch(ix+ncomp,i2) = fexch(ix+ncomp,i2) +       & 
              muexc(nex,i2)*spex_conc
        END DO
      END IF
    END DO
  END DO
  
  DO nex = 1,nexch_sec
    spex_conc = aexch(nex)
    ix = ixlink(nex)
    DO i = 1,ncomp
      IF (muexc(nex,i) /= 0.0) THEN
        mutemp = muexc(nex,i)
        DO i2 = 1,ncomp+nexchange
          sum1 = mutemp*muexc(nex,i2)*spex_conc*tec(ix)
          sum2 = -exchangesites(ix,jx,jy,jz)*mutemp*spex_conc/  &
             (wt_aexch(ix)*wt_aexch(ix))*fweight(ix+ncomp,i2)
          fch_local(i,i2) = fch_local(i,i2) + sum1 + sum2
        END DO
      END IF
    END DO
  END DO
  
END IF

DO ns = 1,nsurf_sec
  spex_conc = spsurf10(ns+nsurf,jx,jy,jz)
  DO i = 1,ncomp
    IF (musurf(ns,i) /= 0.0) THEN
      mutemp = musurf(ns,i)
      DO i2 = 1,ncomp
        fch_local(i,i2) = fch_local(i,i2) + mutemp*musurf(ns,i2)*spex_conc
      END DO
      DO is2 = 1,nsurf
        fch_local(i,is2+ncomp+nexchange) = fch_local(i,is2+ncomp+nexchange)  &
         + mutemp*musurf(ns,is2+ncomp)*spex_conc
      END DO
    END IF
  END DO
END DO

RETURN
END SUBROUTINE jac_exchange_local
!***********************************************************
