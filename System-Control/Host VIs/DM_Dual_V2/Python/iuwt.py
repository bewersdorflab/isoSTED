#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Code with the Isotropic Undecimated Wavelet Transform
taken (Aug 24, 2015) from
https://github.com/ratt-ru/PyMORESANE/
Credits to J. S. Kenyon
"""

import numpy as np


def dec(in1, scale_count, scale_adjust=0, store_smoothed=True):
    """

    This function calls the a trous algorithm code to decompose the input into
    its wavelet coefficients. This is the isotropic undecimated wavelet
    transform implemented for a single CPU core.

    INPUTS:
    in1            (no default)
    scale_count    (no default):   Maximum scale to be considered.
    scale_adjust   (default=0):    Adjustment to scale
    store_smoothed (default=False):Smoothed image is stored or not.

    OUTPUTS:
    detail_coeffs                  Array containing the detail coefficients.
    C0             (optional):     Array containing the smoothest version
    """

    # Filter-bank for use in the a trous algorithm.
    wavelet_filter = (1./16)*np.array([1, 4, 6, 4, 1])

    # Initialises an empty array to store the coefficients.

    detail_coeffs = np.empty(
        [scale_count-scale_adjust, in1.shape[0], in1.shape[1]])

    C0 = in1    # Sets the initial value to be the input array.

    # The following loop, which iterates up to scale_adjust, applies the a
    # trous algorithm to the scales which are considered insignificant. This is
    # important as each set of wavelet coefficients depends on the last
    # smoothed version of the input.

    if scale_adjust > 0:
        for i in range(0, scale_adjust):
            C0 = ser_a_trous(C0, wavelet_filter, i)

    # The meat of the algorithm - two sequential applications fo the a trous
    # followed by determination and storing of the detail coefficients. C0 is
    # reassigned the value of C on each loop - C0 is always the smoothest
    # version of the input image.

    for i in range(scale_adjust, scale_count):
        C = ser_a_trous(C0, wavelet_filter, i)       # Approximation
        C1 = ser_a_trous(C, wavelet_filter, i)       # Approximation
        detail_coeffs[i - scale_adjust, :, :] = C0 - C1  # Detail
        C0 = C

    if store_smoothed:
        return detail_coeffs, C0
    else:
        return detail_coeffs


def rec(in1, smoothed_array, scale_adjust=0):
    """
    This function calls the a trous algorithm code to recompose the input into
    a single array. This is the implementation of the isotropic undecimated
    wavelet transform recomposition for a single CPU core.

    INPUTS:
    in1             (no default):
    scale_adjust    (no default):
    smoothed_array  (default=None):

    OUTPUTS:
    recomposition
    """

    # Filter-bank for use in the a trous algorithm.
    wavelet_filter = (1./16)*np.array([1, 4, 6, 4, 1])

    # Determines scale with adjustment and creates a zero array to store the
    # output, unless smoothed_array is given.

    max_scale = in1.shape[0] + scale_adjust

    if smoothed_array is None:
        recomposition = np.zeros([in1.shape[1], in1.shape[2]])
    else:
        recomposition = smoothed_array

    # The following loops call the a trous algorithm code to recompose the
    # input. The first loop assumes that there are non-zero wavelet
    # coefficients at scales above scale_adjust, while the second loop
    # completes the recomposition on the scales less than scale_adjust.

    for i in range(max_scale-1, scale_adjust-1, -1):
        recomposition = ser_a_trous(
            recomposition, wavelet_filter, i) + in1[i - scale_adjust, :, :]

    if scale_adjust > 0:
        for i in range(scale_adjust-1, -1, -1):
            recomposition = ser_a_trous(recomposition, wavelet_filter, i)

    return recomposition


def ser_a_trous(C0, filter, scale):
    """
    The following is a serial implementation of the a trous algorithm. Accepts
    the following parameters:

    INPUTS:
    filter (no default):
    C0     (no default):
    scale  (no default):

    OUTPUTS:
    C1
    """
    tmp = filter[2]*C0

    tmp[(2**(scale + 1)):, :] += filter[0]*C0[:-(2**(scale + 1)), :]
    tmp[:(2**(scale + 1)), :] += filter[0]*C0[(2**(scale + 1))-1::-1, :]

    tmp[(2**scale):, :] += filter[1]*C0[:-(2**scale), :]
    tmp[:(2**scale), :] += filter[1]*C0[(2**scale)-1::-1, :]

    tmp[:-(2**scale), :] += filter[3]*C0[(2**scale):, :]
    tmp[-(2**scale):, :] += filter[3]*C0[:-(2**scale)-1:-1, :]

    tmp[:-(2**(scale + 1)), :] += filter[4]*C0[(2**(scale + 1)):, :]
    tmp[-(2**(scale + 1)):, :] += filter[4]*C0[:-(2**(scale + 1))-1:-1, :]

    C1 = filter[2]*tmp

    C1[:, (2**(scale + 1)):] += filter[0]*tmp[:, :-(2**(scale + 1))]
    C1[:, :(2**(scale + 1))] += filter[0]*tmp[:, (2**(scale + 1))-1::-1]

    C1[:, (2**scale):] += filter[1]*tmp[:, :-(2**scale)]
    C1[:, :(2**scale)] += filter[1]*tmp[:, (2**scale)-1::-1]

    C1[:, :-(2**scale)] += filter[3]*tmp[:, (2**scale):]
    C1[:, -(2**scale):] += filter[3]*tmp[:, :-(2**scale)-1:-1]

    C1[:, :-(2**(scale + 1))] += filter[4]*tmp[:, (2**(scale + 1)):]
    C1[:, -(2**(scale + 1)):] += filter[4]*tmp[:, :-(2**(scale + 1))-1:-1]

    return C1
