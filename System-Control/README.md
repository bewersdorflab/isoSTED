# isoSTED Control

INTRODUCTION
-------------------------------------------------------------
Each DM needs to be characterized offline using an external Michelson interferometer setup before it is inserted into the beam path. By tilting the flat mirror in the reference arm of the interferometer setup, the phase induced by the DM can be obtained using Fourier fringe analysis3 and phase unwrapping4. The characterization of the DM consists of computing the influence matrix H that maps a vector u containing the voltage of each actuator of the DM to the corresponding vector z that contains the coefficients of the Zernike analysis of the phase. The matrix H is computed by collecting a set of input-output vector pairs u and z, and by solving a least-squares problem5. After it is installed, the DM can be operated in open-loop and controlled using the vector of Zernike coefficients z as the independent variable, i.e., given a vector of desired Zernike coefficients z, the voltage vector u to be applied to the DM is found by minimizing the norm squared of z-H∙u.

This program is to generate the Matrix H, namely, the control matrix.

The code was programmed in LabVIEW 2014. The code also passed the tests in LabVIEW 2015 and LabVIEW 2018. 

Contributor: XH, EA, and JA Last update: Jan. 13, 2018

INSTALLATION
No installation is required.

HOW TO USE
Run the files with the name "Step 1" to "Step 5" sequentially.

DEMO
Some example data are available in the folder "./DM/DM resources/". The output from this example data set can be found in the folder "./DM/Zernike Decomposition/"

HARDWARE SUPPORT
Currently, this code is only compatible with DM model multiDM-5.5 produced by Boston Micromachines.
