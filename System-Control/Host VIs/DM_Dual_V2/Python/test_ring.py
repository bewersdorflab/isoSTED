#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt
from numpy.random import normal
from numpy.linalg import norm
from scipy.optimize import minimize

img = normal(size=(64, 64))
count = 0


def ring_model(x0, y0, r0, a):
    dd = np.linspace(-1, 1, img.shape[0])
    xx, yy = np.meshgrid(dd, dd)
    rr = np.sqrt((xx - x0)**2 + (yy - y0)**2)
    hat = np.exp(-a*(rr - r0)**2)
    return hat


plt.imshow(ring_model(0., 0., .20, 100))
plt.show()


def error(x):
    global count
    count += 1
    hat = ring_model(x[0], x[1], x[2], x[3])
    return norm(hat.ravel() - img.ravel())


optres = minimize(
    error, np.array([0., 0., .1, 100]),
    bounds=((-1., 1.), (-1., 1.), (1e-5, 1.), (1e-5, 1e4)))

print(count)
