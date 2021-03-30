# DM

INTRODUCTION
-----------------------------------------------------------
Each DM needs to be characterized offline using an external Michelson interferometer setup before it is inserted into the beam path. By tilting the flat mirror in the reference arm of the interferometer setup, the phase induced by the DM can be obtained using Fourier fringe analysis3 and phase unwrapping4. The characterization of the DM consists of computing the influence matrix H that maps a vector u containing the voltage of each actuator of the DM to the corresponding vector z that contains the coefficients of the Zernike analysis of the phase. The matrix H is computed by collecting a set of input-output vector pairs u and z, and by solving a least-squares problem5. After it is installed, the DM can be operated in open-loop and controlled using the vector of Zernike coefficients z as the independent variable, i.e., given a vector of desired Zernike coefficients z, the voltage vector u to be applied to the DM is found by minimizing the norm squared of z-H∙u.

This program is to generate the Matrix H, namely, the control matrix.

The code was programmed and tested in Matlab 2017b.

Contributor: XH, JA, and JZ Last update: Jan. 12, 2018

INSTALLATION
-----------------------------------------------------------
No installation is required.

HOW TO USE
-----------------------------------------------------------
Run the files with the name "Step 1" to "Step 5" sequentially.

DEMO
-----------------------------------------------------------
Some example data are available in the folder "./DM/DM resources/". The output from this example data set can be found in the folder "./DM/Zernike Decomposition/"

HARDWARE SUPPORT
-----------------------------------------------------------
Currently, this code is only compatible with DM model multiDM-5.5 produced by Boston Micromachines.


***********************************************************************************

Copyright (C) 2021 Bewersdorf Lab, Yale University
Copyright (C) 2021 Xiang Hao
Copyright (C) 2021 Edward Allgeyer
Copyright (C) 2021 Jacopo Antonello
Copyright (C) 2021 Jiaxi Zhao

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

***********************************************************************************
