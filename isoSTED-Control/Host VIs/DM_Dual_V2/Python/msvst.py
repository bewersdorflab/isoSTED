#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
[1] J.L. Starck,
http://www.multiresolutions.com/sparsesignalrecipes/software.html
[2] Michael Broxton, https://github.com/broxtronix/pymultiscale/
[3] B. Zhang, J. M. Fadili and J. L. Starck, "Wavelets, Ridgelets, and
Curvelets for Poisson Noise Removal," in IEEE Transactions on Image Processing,
vol. 17, no. 7, pp. 1093-1108, July 2008.  doi: 10.1109/TIP.2008.924386 URL:
http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=4531116&isnumber=4539841
[4] Starck, Jean-Luc, Fionn Murtagh, and Mario Bertero. "Starlet transform in
astronomical data processing." Handbook of Mathematical Methods in Imaging.
Springer New York, 2011. 1489-1531. doi: 10.1007/978-0-387-92920-0_34

author: J. Antonello <jacopo.antonello@dpag.ox.ac.uk>
date: Tue Apr 18 09:30:13 BST 2017
"""

import numpy as np

from scipy.stats import norm
from scipy.ndimage.filters import convolve


kernels = []
hjs = []


def make_kernels(levels):
    global kernels

    hB3 = np.array([1., 4., 6., 4., 1.])/16

    kernels2 = list()
    hjtmp = hB3
    for j in range(2, levels + 1):
        hjtmp = np.kron(hjtmp, np.array([1., 0.]))
        kernels2.append(hjtmp)
    for j in range(len(kernels2)):
        kernels2[j] = kernels2[j][:-(2**(j + 1) - 1)]

    kernels = [hB3] + kernels2


def dec1(img, J=None):
    if J is None:
        J = int(np.floor(np.log2(min(img.shape))) - 1)

    if len(kernels) < J:
        make_kernels(J)
        assert(len(kernels) == J)

    # a_0 = a_J + sum_{j=1}^{J} d_j

    ajm1 = img
    djs = list()
    ajs = list()
    for j in range(J):
        k = kernels[j]
        aj = convolve(ajm1, k.reshape((1, -1)), mode='constant')
        aj = convolve(aj, k.reshape((-1, 1)), mode='constant')
        ajs.append(aj)
        djs.append(ajm1 - aj)

        ajm1 = aj

    assert(len(ajs) == J)
    assert(len(djs) == J)

    return ajs, djs


def make_hjs(size):
    global hjs

    delta = np.zeros((size,))
    delta[size//2] = 1.

    for j in range(len(kernels)):
        k = kernels[j]
        hj = convolve(delta, k, mode='constant')
        hjs.append(hj)

        delta = hj


def dec(img, J=None):
    if J is None:
        J = int(np.floor(np.log2(min(img.shape))) - 1)

    if len(kernels) < J:
        make_kernels(J)
        assert(len(kernels) == J)
    if len(hjs) < J or hjs[0].shape[0] != img.shape[0]:
        make_hjs(img.shape[0])
        assert(len(hjs) == J)

    # a_0 = a_J + sum_{j=1}^{J} d_j

    ajm1 = img
    djs = list()
    ajs = list()
    for j in range(J):
        tmp = convolve(img, hjs[j].reshape((1, -1)), mode='constant')
        tmp = convolve(tmp, hjs[j].reshape((-1, 1)), mode='constant')
        ajs.append(tmp)
        djs.append(ajm1 - tmp)
        ajm1 = tmp

    assert(len(ajs) == J)
    assert(len(djs) == J)

    return ajs, djs


def T(j, a):
    h = np.kron(hjs[j].reshape(-1, 1), hjs[j].reshape(1, -1))
    tau1 = h.sum()
    tau2 = np.power(h, 2).sum()
    tau3 = np.power(h, 3).sum()

    c = 7*tau2/(8*tau1) - tau3/(2*tau2)
    b = np.sign(tau1)/np.sqrt(np.abs(tau1))

    return b*np.sign(a + c)*np.sqrt(np.abs(a + c))


def msvst(img, J=None):

    if J is None:
        J = int(np.floor(np.log2(min(img.shape))) - 1)

    ajs, _ = dec(img, J=J)
    djs = list()

    Tjm1 = np.sign(img + 3/8)*np.sqrt(np.abs(img + 3/8))
    for j in range(len(ajs)):
        Tj = T(j, ajs[j])
        djs.append(Tjm1 - Tj)
        Tjm1 = Tj

    assert(len(ajs) == J)
    assert(len(djs) == J)

    return ajs, djs


def sigma2s(J):

    sigma2s = list()

    tau2jm1 = 1.
    tau1jm1 = 1.
    hjm1 = np.zeros_like(hjs[0])
    hjm1[hjm1.size//2] = 1.0
    hjm1 = np.kron(hjm1.reshape(-1, 1), hjm1.reshape(1, -1))
    for j in range(J):
        h = np.kron(hjs[j].reshape(-1, 1), hjs[j].reshape(1, -1))
        tau2 = np.power(h, 2).sum()
        tau1 = h.sum()
        ip = np.dot(hjm1.ravel(), h.ravel())
        sigma2s.append(
            tau2jm1/(4*tau1jm1**2) + tau2/(4*tau1**2) - ip/(2*tau1jm1*tau1))

        tau2jm1 = tau2
        tau1jm1 = tau1
        hjm1 = h

    return sigma2s


def H1(d, sigma2, fpr):
    d2 = d.copy()
    p = 2*(1 - norm.cdf(np.abs(d)/np.sqrt(sigma2)))
    pmap = p > fpr
    d2[pmap] = 0

    return d2


def imsvst(ajs, djs):
    tmp = T(len(ajs) - 1, ajs[-1]) + np.stack(djs, axis=0).sum(axis=0)
    neg = tmp < 0.0
    tmp = np.square(tmp)
    tmp[neg] *= -1
    return tmp
