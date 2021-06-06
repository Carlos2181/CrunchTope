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

SUBROUTINE keqcalc2_init(ncomp,nrct,nspec,ngas,nsurf_sec,tempc)
USE crunchtype
USE params
USE concentration
USE mineral
USE temperature

IMPLICIT NONE

!  External variables

INTEGER(I4B), INTENT(IN)                             :: ncomp
INTEGER(I4B), INTENT(IN)                             :: nrct
INTEGER(I4B), INTENT(IN)                             :: nspec
INTEGER(I4B), INTENT(IN)                             :: ngas
INTEGER(I4B), INTENT(IN)                             :: nsurf_sec

REAL(DP), INTENT(IN)                                 :: tempc

!  Internal variables

REAL(DP)                                             :: temp
REAL(DP)                                             :: temp2
REAL(DP)                                             :: x1
REAL(DP)                                             :: x2
REAL(DP)                                             :: x3
REAL(DP)                                             :: x4
REAL(DP)                                             :: x5

INTEGER(I4B)                                         :: ksp
INTEGER(I4B)                                         :: kg
INTEGER(I4B)                                         :: k
INTEGER(I4B)                                         :: msub
INTEGER(I4B)                                         :: ns
INTEGER(I4B)                                         :: np

temp = tempc + 273.15
temp2 = temp*temp

DO ksp = 1,nspec
  IF (ntemp == 1 .OR. RunIsothermal) THEN
    keqaq_tmp(ksp) = -clg*eqhom(ksp)
  ELSE
    x1 = as1(ksp,1)
    x2 = as1(ksp,2)
    x3 = as1(ksp,3)
    x4 = as1(ksp,4)
    x5 = as1(ksp,5)
    keqaq_tmp(ksp) = -clg*(x1*DLOG(temp) + x2 +  &
        x3*temp + x4/temp + x5/(temp2))
  END IF
END DO

DO kg = 1,ngas
  ksp = kg + nspec
  IF (ntemp == 1 .OR. RunIsothermal) THEN
    keqgas_tmp(kg) = -clg*eqgas(kg)
  ELSE
    x1 = as1(ksp,1)
    x2 = as1(ksp,2)
    x3 = as1(ksp,3)
    x4 = as1(ksp,4)
    x5 = as1(ksp,5)
    keqgas_tmp(kg) = -clg*(x1*DLOG(temp) + x2 +  &
        x3*temp + x4/temp + x5/(temp2))
  END IF
END DO

msub = 0
DO k = 1,nrct
  DO np = 1,nreactmin(k)
    msub = msub + 1
    ksp = msub + ngas + nspec
    IF (ntemp == 1 .OR. RunIsothermal) THEN
      keqmin_tmp(np,k) = clg*alnk(msub)
    ELSE
      x1 = as1(ksp,1)
      x2 = as1(ksp,2)
      x3 = as1(ksp,3)
      x4 = as1(ksp,4)
      x5 = as1(ksp,5)
      keqmin_tmp(np,k) = clg*(x1*DLOG(temp) + x2 +  &
          x3*temp + x4/temp + x5/(temp2))
    END IF
  END DO
END DO

DO ns = 1,nsurf_sec
  ksp = msub + ngas + nspec + ns
  IF (ntemp == 1 .OR. RunIsothermal) THEN
    keqsurf_tmp(ns) = -clg*eqsurf(ns)
  ELSE
    x1 = as1(ksp,1)
    x2 = as1(ksp,2)
    x3 = as1(ksp,3)
    x4 = as1(ksp,4)
    x5 = as1(ksp,5)
    keqsurf_tmp(ns) = -clg*(x1*DLOG(temp) + x2 +  &
        x3*temp + x4/temp + x5/(temp2))
  END IF
END DO


RETURN
END SUBROUTINE keqcalc2_init
!*********************************************************************