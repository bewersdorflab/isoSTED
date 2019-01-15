#!/usr/bin/env python3

import scipy
import os
import argparse
import numpy as np
from skimage.restoration import unwrap_phase
from scipy import io


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='''Unwrap phase using M. A. Herráez, D. R. Burton, M. J.
        Lalor, and M. A. Gdeisat, "Fast two-dimensional phase-unwrapping
        algorithm based on sorting by reliability following a noncontinuous
        path," Appl. Opt. 41, 7437-7444 (2002).
        ''',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        'file',
        type=argparse.FileType('rb'),
        help='Wrapped phase, either in a MATLAB or an ASCII file.')
    parser.add_argument(
        '--debug', action='store_true', help='Plot phases.')
    parser.add_argument(
        '--quiet', action='store_true', help='No console output.')

    args = parser.parse_args()

    dout = dict()
    matfile = io.loadmat(args.file)

    phiw = matfile['phiw']
    apmask = matfile['apmask'].astype(np.bool)
    masked = np.ma.masked_array(phiw, np.invert(apmask))
    phiu = np.array(unwrap_phase(masked, wrap_around=False, seed=10))
    splits = os.path.splitext(args.file.name)
    scipy.io.savemat(splits[0] + '_unwrapped' + splits[1], {'phiu': phiu})
