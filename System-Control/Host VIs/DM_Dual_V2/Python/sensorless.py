#!/usr/bin/env python3
# -*- coding: utf-8 -*-


"""sensorless - use numerical methods to maximise an image quality metric.

This script needs labviewhandler.py, xml2dict.py and json2dict.py.

author: J. Antonello <jacopo.antonello@dpag.ox.ac.uk>
date: Tue Oct 18 09:30:05 BST 2016
"""

import argparse
import numpy as np
import iuwt

from numpy.fft import fft2, fftshift
from numpy.linalg import norm, lstsq
from scipy.signal import tukey
from scipy.optimize import minimize, curve_fit
from labviewhandler import add_labviewhandler_parameters, run_algorithm


def apply_threshold(abs_thresh, rel_thresh, img, isoSTED, log_x, log_y):
    if abs_thresh > 0.0:
        img[img < abs_thresh] = 0.0
    elif rel_thresh > 0.0:
        img[img < rel_thresh*isoSTED.log_din[0]['stack'].max()] = 0.0
    if isoSTED.h5f:
        isoSTED.h5f['metric/stack/{:09d}'.format(len(log_x))] = img
    return img


def metric_iuwt1(args, isoSTED, log_x, log_y, img):
    # Thu Mar 23 13:15:23 GMT 2017
    P = isoSTED.imacq['Pixel Size (nm)'][0]
    N = img.shape[0]
    levels = int(np.floor(np.log2(N)))
    scales = np.array([P*(2**i) for i in range(levels)])
    sel = (scales > args.resolution_high_nm)*(scales < args.resolution_low_nm)
    assert(np.any(sel))
    if len(log_y) == 0:
        print('metric_iuwt1 all scales: ' + str(scales))
        print('metric_iuwt1 sel scales: ' + str(scales[sel]))

    D, A = iuwt.dec(img, levels)
    D[np.invert(sel), :, :] = 0
    for i in np.where(sel)[0]:
        scale = D[i, :, :]
        ascale = np.abs(scale)
        mass = ascale.ravel()
        scale[(ascale - mass.mean()) < 3*mass.std()] = 0
        D[i, :, :] = scale
    sharp = np.abs(D).sum()

    if isoSTED.h5f:
        isoSTED.h5f['metric/FM/{:09d}'.format(len(log_x))] = fftshift(
            iuwt.rec(D, 0*A))

    return -sharp


def metric_low_spatial_freq(args, isoSTED, log_x, log_y, img):
    img = apply_threshold(
        args.abs_thresh, args.rel_thresh, img, isoSTED, log_x, log_y)

    P = isoSTED.imacq['Pixel Size (nm)'][0]
    N = img.shape[0]
    dd = np.arange(-N/2, N/2)/(N*P)
    xx, yy = np.meshgrid(dd, dd)
    rr = np.sqrt(xx**2 + yy**2)
    mask = (rr > 1/args.resolution_low_nm)*(rr < 1/args.resolution_high_nm)
    mask.astype(np.float)
    w = tukey(N, .25, True)
    w = w.reshape(1, -1)*w.reshape(-1, 1)

    f = fftshift(img*w)
    F = fft2(f)
    M = fftshift(mask)
    FM = np.abs(F*M)

    if isoSTED.h5f:
        isoSTED.h5f['metric/FM/{:09d}'.format(len(log_x))] = FM

    return -FM.sum()


def metric_ring(args, isoSTED, log_x, log_y, img):
    img = apply_threshold(
        args.abs_thresh, args.rel_thresh, img, isoSTED, log_x, log_y)

    def ring_model(x0, y0, r0, a, A):
        dd = np.linspace(-1, 1, img.shape[0])
        xx, yy = np.meshgrid(dd, dd)
        rr = np.sqrt((xx - x0)**2 + (yy - y0)**2)
        hat = A*np.exp(-a*(rr - r0)**2)
        return hat

    def error(x):
        hat = ring_model(x[0], x[1], x[2], x[3], x[4])
        return norm(hat.ravel() - img.ravel())

    optres = minimize(
        error, np.array([0., 0., .1, 100, 1.]),
        bounds=((-1., 1.), (-1., 1.), (0.01, 0.2), (1, 50), (1e-5, 1e5)))

    if isoSTED.h5f:
        x = optres.x
        isoSTED.h5f['metric/ring/{:09d}'.format(len(log_x))] = ring_model(
            x[0], x[1], x[2], x[3], x[4])
        isoSTED.h5f['metric/x/{:09d}'.format(len(log_x))] = x

    return optres.fun


def metric_total_intensity(args, isoSTED, log_x, log_y, img):

    img = apply_threshold(
        args.abs_thresh, args.rel_thresh, img, isoSTED, log_x, log_y)

    return -img.sum()


def metric_sum_square(args, isoSTED, log_x, log_y, img):

    img = apply_threshold(
        args.abs_thresh, args.rel_thresh, img, isoSTED, log_x, log_y)

    return -np.square(img).sum()


def plot_debug(args, log_din, log_dout, log_x, log_y):
    # TODO FIXME
    pass


metric_funcs = [
    metric_iuwt1,
    metric_low_spatial_freq,
    metric_total_intensity,
    metric_ring,
    metric_sum_square]

metric_names = [f.__name__ for f in metric_funcs]


if __name__ == '__main__':
    algorithm_names = ['modal2', 'nelder-mead', 'modal']
    parser = argparse.ArgumentParser(
        description='''
Run sensorless optimisation algorithms. Use `modal2` for the scan mode
algorithm or `nelder-mead`, see the help for ALGORITHM.''',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument(
        '--algorithm', choices=algorithm_names,
        default=algorithm_names[0], help='Algorithm name')
    add_labviewhandler_parameters(parser)

    # parser.add_argument('--no-hold', action='store_true')
    parser.add_argument(
        '--nm-disp', action='store_true',
        help='Show progress for nelder-mead method')
    parser.add_argument(
        '--nm-maxiter', type=int, default=None, metavar='ITERATIONS',
        help='Maximum iterations for nelder-mead method')
    parser.add_argument(
        '--nm-maxfev', type=int, default=None, metavar='FEVAL',
        help='Maximum measurements of nelder-mead method / stop condition')
    parser.add_argument(
        '--abs-thresh', type=float, default=-1.0, metavar='THRESH',
        help='Absolute threshold for background removal')
    parser.add_argument(
        '--rel-thresh', type=float, default=-1.0, metavar='THRESH',
        help='Relative threshold for background removal')
    parser.add_argument(
        '--metric', choices=metric_names, default=metric_names[0],
        help='Name of the metric function')
    parser.add_argument(
        '--bias-rms', type=float, default=1.0, metavar='BIAS',
        help='Magnitude of the bias for scanning aberration modes [calib rad]')
    parser.add_argument(
        '--modal-max-amplitude', type=float, default=3.0, metavar='AMPL',
        help='''
Maximum amplitude allowed for the aberration correction [calib rad]
(modal algorithm)''')
    parser.add_argument(
        '--modal-steps', type=int, default=4, metavar='STEPS',
        help='Number of steps for each iteration of the modal algorithm')
    parser.add_argument(
        '--modal-no-correction', action='store_true',
        help='''
Do not apply the aberration correction in the modal algorithm. Useful to
collect data only. This data can be used to evaluate different metrics.''')
    parser.add_argument(
        '--resolution-low-nm', type=float, default=250, metavar='L',
        help='Expected lower resolution in nm, e.g. 250 for confocal')
    parser.add_argument(
        '--resolution-high-nm', type=float, default=40, metavar='H',
        help='Expected higher resolution in nm, e.g. 40 for STED')

    args = parser.parse_args()

    def scipy_minimise(
        f, x0, h5f=None, method=args.algorithm, options={
            'maxiter': args.nm_maxiter,
            'maxfev': args.nm_maxfev,
            'disp': args.nm_disp}):
        if options['maxfev'] is None:
            options['maxfev'] = 5*x0.size
        optres = minimize(fun=f, x0=x0, method=method, options=options)
        return optres.x, optres.message

    modal_count = 0

    # added on Wed Nov 30 17:18:38 GMT 2016
    def modal2(
            f, xacc1, h5f=None, npoints=args.modal_steps,
            nmax=args.bias_rms, fitter_name='quad'):
        global modal_count
        xacc = 0 + xacc1

        # scalar fit Gaussian
        func_exp_bounds = (
            (-args.modal_max_amplitude, 0.0, 0.0, 0.0),
            (args.modal_max_amplitude, np.inf, np.inf, np.inf))

        def func_exp(x, x0, a, b, c):
            return a*np.exp(-b*((x - x0)**2)) + c

        # scalar fit quadratic
        func_quad_bounds = (
            (-args.modal_max_amplitude, 0.0, 0.0),
            (args.modal_max_amplitude, np.inf, np.inf))

        def func_quad(x, x0, ymax, c):
            return ymax - c*np.square(x - x0)

        if fitter_name == 'exp':
            func = func_exp
            bounds = func_exp_bounds
        elif fitter_name == 'quad':
            func = func_quad
            bounds = func_quad_bounds
        else:
            raise ValueError('Unknown fitter name {}'.format(fitter_name))

        # first stack meas is taken in the labview handler for simplicity
        # and is ignored here. the second stack measurement (initial), i.e.,
        # the first measurement considered in this file, corresponds to the
        # DM aberrated image/SLM aberrated image/specimen aberration
        initial = -f(0*xacc)
        if h5f:
            h5f['modal/name'] = 'modal2'
            h5f['modal/func'] = func.__name__
            h5f['modal/fitter'] = fitter_name
            h5f['modal/initial'] = initial

        for imode in range(xacc1.size):
            fiterr = False
            xdata = np.linspace(-nmax, nmax, npoints)
            ydata = np.zeros_like(xdata)
            for i in range(xdata.size):
                delta = np.zeros_like(xacc)
                delta[imode] = xdata[i]
                ydata[i] = -f(xacc + delta)

            # normalise ydata
            ydata /= abs(initial)

            try:
                popt, _ = curve_fit(
                    func, xdata, ydata, p0=None, bounds=bounds)
                yhat = func(xdata, *popt)
                fiterr = False
            except:
                popt = np.inf*np.ones((len(bounds[0]),))
                yhat = np.inf*np.ones_like(ydata)
                fiterr = True

            if h5f:
                h5f['modal/xdata/{:09d}'.format(modal_count)] = xdata
                h5f['modal/ydata/{:09d}'.format(modal_count)] = ydata
                h5f['modal/yhat/{:09d}'.format(modal_count)] = yhat
                h5f['modal/popt/{:09d}'.format(modal_count)] = popt
                modal_count += 1

            # apply best value for this mode
            delta *= 0
            delta[imode] = popt[0]
            if not args.modal_no_correction:
                xacc += delta

            print('mode: {:02d}, fiterr: {:>5s}, centre: {:+f}'.format(
                imode, str(fiterr), popt[0]))

        return xacc, 'modal2 finished'

    # old modal code
    func_exp_bounds = (
        (-2.0, 0.0, 0.0, -np.inf),
        (2.0, np.inf, np.inf, np.inf))

    def func_exp(x, x0, a, b, c):
        return a*np.exp(-b*((x - x0)**2)) + c

    def modal(
            f, xacc1, h5f=None, npoints=args.modal_steps, nmax=args.bias_rms,
            func=func_exp, bounds=func_exp_bounds):
        global modal_count
        xacc = 0 + xacc1

        # second stack measurement corresponds to the DM aberrated image or
        # the flat value set by Python
        f(0*xacc)

        # f(0*xacc) was added at 3.39 11/11/16

        for imode in range(xacc1.size):
            fiterr = False
            xdata = np.linspace(-nmax, nmax, npoints)
            ydata = np.zeros_like(xdata)
            for i in range(xdata.size):
                delta = np.zeros_like(xacc)
                delta[imode] = xdata[i]
                ydata[i] = -f(xacc + delta)
            # print(xdata, ydata)
            d1 = np.diff(ydata)
            d2ind = np.abs(d1).argmin()
            d2 = np.diff(d1)
            try:
                d2 = d2[min(d2ind, d2.size - 1)]
            except:
                print('ERROR', d2ind, d2)
            p0 = [0.0, ydata.max(), -d2/(2*ydata.max()), ydata.min()]
            try:
                popt, pcov = curve_fit(
                    func, xdata, ydata, p0=p0, bounds=bounds)
                fiterr = False
            except:
                popt = [0.0, 0.0, 0.0, 0.0]
                fiterr = True
                # print('Failed to fit mode ', imode)
            yhat = func(xdata, *popt)
            if h5f:
                if modal_count == 0:
                    h5f['modal/name'] = 'modal'
                    h5f['modal/func'] = func.__name__
                h5f['modal/xdata/{:09d}'.format(modal_count)] = xdata
                h5f['modal/ydata/{:09d}'.format(modal_count)] = ydata
                h5f['modal/yhat/{:09d}'.format(modal_count)] = yhat
                h5f['modal/popt/{:09d}'.format(modal_count)] = popt
                modal_count += 1
            delta *= 0
            delta[imode] = popt[0]
            xacc += delta
            print('mode', imode, 'err', fiterr, 'centre', popt[0])
            # print(imode, xdata, ydata, yhat, popt)
        return xacc, 'modal finished'

    def modal_simple(f, xacc1, h5f, npoints=5, nmax=1):
        global modal_count
        xacc = 0 + xacc1

        # second stack measurement corresponds to the DM aberrated image or
        # the flat value set by Python
        f(0*xacc)

        for imode in range(xacc1.size):
            ydata = list()
            xdata = np.linspace(-nmax, nmax, npoints)
            for x in xdata:
                delta = np.zeros_like(xacc)
                delta[imode] = x
                ydata.append(-f(xacc + delta))
            A = np.zeros((xdata.size, 3))
            for i in range(xdata.size):
                A[i, 0] = xdata[i]**2
                A[i, 1] = xdata[i]
                A[i, 2] = 1
            # print(xdata, ydata)
            # if bounds is not None:
            #     popt, pcov = curve_fit(func, xdata, ydata, bounds=bounds)
            # else:
            #     popt, pcov = curve_fit(func, xdata, ydata)
            abc = lstsq(A, ydata)[0]
            centre = -abc[1]/(2*abc[0])
            yhat = [abc[0]*x**2 + abc[1]*x + abc[2] for x in xdata]
            print('centre', centre)
            if h5f:
                if modal_count == 0:
                    h5f['modal/func'] = 'modal_simple'
                h5f['modal/xdata/{:09d}'.format(modal_count)] = xdata
                h5f['modal/ydata/{:09d}'.format(modal_count)] = ydata
                h5f['modal/yhat/{:09d}'.format(modal_count)] = np.array(yhat)
                h5f['modal/popt/{:09d}'.format(modal_count)] = np.array(abc)
                modal_count += 1
            delta *= 0
            delta[imode] = centre
            xacc += delta
            # print(imode, xdata, ydata, yhat, abc)
        return xacc, 'modal finished'

    if args.algorithm == 'modal':
        payload_func = modal
    elif args.algorithm == 'modal2':
        payload_func = modal2
    else:
        payload_func = scipy_minimise

    log_din, log_dout, log_y, log_x = run_algorithm(
        args, metric_funcs[metric_names.index(args.metric)],
        payload_func, plot_debug)
