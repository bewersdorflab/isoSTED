#!/usr/bin/env python3
# -*- coding: utf-8 -*-


"""sensorless - use numerical methods to maximise an image quality metric.

This script needs labviewhandler.py, xml2dict.py and json2dict.py.

author: J. Antonello <jacopo.antonello@dpag.ox.ac.uk>
date: Tue Apr 18 15:05:59 BST 2017
"""

import traceback
import argparse
import numpy as np
import msvst

from scipy.optimize import curve_fit
from labviewhandler import add_labviewhandler_parameters, run_algorithm2


def metric_msvst(
        initstack, pixelsize, confocal, fpr=5e-3, h5f=None, weighted=1.0):
    Jmax = int(np.floor(np.log2(initstack.shape[0]))) - 1
    assert(initstack.shape[1] == initstack.shape[0])

    allscales = np.array([pixelsize*(2**i) for i in range(Jmax)])
    selscales = allscales[allscales <= confocal]
    J = selscales.size
    assert(J > 0)

    print('metric_msvst J {}, weighted {}, scales {} [nm]'.format(
        J, weighted, str(selscales)))

    msvst.dec(initstack)  # initialise msvst
    sigma2s = msvst.sigma2s(J)

    if h5f:
        h5f['msvst/allscales'] = allscales
        h5f['msvst/selscales'] = selscales
        h5f['msvst/J'] = J
        h5f['msvst/sigma2s'] = sigma2s
        h5f['msvst/weighted'] = weighted

        h5f['msvst/counter'] = 0
        h5f.create_dataset(
            'msvst/metriclog', (0,), maxshape=(None,), dtype=np.float)

    def f(s):
        ajs, djs0 = msvst.msvst(s, J)
        djs1 = list()
        for j in range(J):
            djs1.append(msvst.H1(djs0[j], sigma2s[j], fpr))

        if weighted != 1.0:
            for j in range(J):
                djs0[j] /= weighted**j
                djs1[j] /= weighted**j

        suma = np.square(np.stack(djs0)).sum()
        sumt = np.square(np.stack(djs1)).sum()
        metricval = sumt/suma

        if h5f:
            counter = h5f['msvst/counter']
            metriclog = h5f['msvst/metriclog']

            np.append(metriclog, metricval)
            name = 'msvst/denoised/{:09d}'.format(counter.value)
            h5f[name] = msvst.imsvst([0*ajs[-1]], djs1)

            counter[()] = counter.value + 1

        return metricval

    return f


metric_funcs = [metric_msvst]
metric_names = [f.__name__ for f in metric_funcs]
algorithm_names = ['modal']


def modal3(
        f, xacc1, initial, npoints, maxcorr, bias, fitter_name='quad',
        h5f=None, counter=0, apply_correction=True, normalise=True):

    xacc = 0 + xacc1

    # scalar fit Gaussian
    func_exp_bounds = (
        (-maxcorr, 0.0, 0.0, 0.0),
        (maxcorr, np.inf, np.inf, np.inf))

    def func_exp(x, x0, a, b, c):
        return a*np.exp(-b*((x - x0)**2)) + c

    # scalar fit quadratic
    func_quad_bounds = (
        (-maxcorr, 0.0, 0.0),
        (maxcorr, np.inf, np.inf))

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
    if h5f:
        h5f['modal/fitter'] = fitter_name

    for imode in range(xacc1.size):
        fiterr = False
        xdata = np.linspace(-bias, bias, npoints)
        ydata = np.zeros_like(xdata)
        for i in range(xdata.size):
            delta = np.zeros_like(xacc)
            delta[imode] = xdata[i]
            ydata[i] = f(xacc + delta)

        # normalise ydata
        if normalise:
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
            h5f['modal/xdata/{:09d}'.format(counter)] = xdata
            h5f['modal/ydata/{:09d}'.format(counter)] = ydata
            h5f['modal/yhat/{:09d}'.format(counter)] = yhat
            h5f['modal/popt/{:09d}'.format(counter)] = popt
            counter += 1

        # apply best value for this mode
        delta *= 0
        delta[imode] = popt[0]
        if apply_correction:
            xacc += delta

        print('mode: {:02d}, fiterr: {:>5s}, centre: {:+f}'.format(
            imode, str(fiterr), popt[0]))

    return xacc


class ModalWrapper:

    counter = 0
    modal_func = [modal3]

    def dump(self, address, value):
        if self.control.isoSTED.h5f:
            self.control.isoSTED.h5f[address] = value

    def __init__(self, control, args):
        self.control = control
        self.args = args
        self.xacc = np.zeros((control.get_ndof(),))

        if args.metric == 'metric_msvst':
            imsize = control.isoSTED.imacq['Image Format']
            pixelsize = control.isoSTED.imacq['Pixel Size (nm)'][0]
            self.metric = metric_msvst(
                initstack=np.zeros((imsize, imsize)),
                pixelsize=pixelsize, confocal=args.confocal, fpr=args.fpr,
                h5f=control.isoSTED.h5f, weighted=args.ms_weighted)
        else:
            raise NotImplementedError()

        self.dump('modal/name', self.modal_func[0].__name__)

    def run(self):
        # # scalar fit Gaussian
        # func_exp_bounds = (
        #     (-args.modal_max_amplitude, 0.0, 0.0, 0.0),
        #     (args.modal_max_amplitude, np.inf, np.inf, np.inf))
        # def func_exp(x, x0, a, b, c):
        #     return a*np.exp(-b*((x - x0)**2)) + c

        log_x = self.control.isoSTED.h5f.create_dataset(
            'modal/log_x', (self.xacc.size, 0),
            maxshape=(self.xacc.size, None), dtype=np.float)
        log_y = self.control.isoSTED.h5f.create_dataset(
            'modal/log_y', (0,), maxshape=(None,), dtype=np.float)

        def f(x):
            self.control.write_settings(x)
            y = self.metric(self.control.isoSTED.read_stack()[0])

            # np.append(log_x, x.reshape(-1, 1), axis=1)
            # np.append(log_y, y.reshape(1, 1), axis=1)
            log_x.resize((self.xacc.size, log_x.shape[1] + 1))
            log_y.resize((log_y.size + 1,))
            log_x[:, -1] = x
            log_y[-1] = y

            return y

        # The first stack measurement is taken in the LabView handler and is
        # ignored here. The second stack measurement (initial), i.e., the first
        # measurement considered by the algorithm, corresponds to the DM
        # aberrated image/SLM aberrated image/specimen aberration
        initial = f(self.xacc)
        self.dump('modal/initial', initial)

        return self.modal_func[0](
                f=f, xacc1=self.xacc, initial=initial,
                npoints=self.args.modal_npoints,
                maxcorr=self.args.max_amplitude,
                bias=self.args.bias,
                fitter_name='quad',
                h5f=self.control.isoSTED.h5f,
                counter=0,
                apply_correction=not self.args.modal_no_correction)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Run sensorless optimisation algorithms.',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    add_labviewhandler_parameters(parser)

    # sensorless parameters
    parser.add_argument(
        '--metric', choices=metric_names, default=metric_names[0],
        help='Name of the metric function')
    parser.add_argument(
        '--bias', type=float, default=0.4, metavar='BIAS',
        help='Bias used in scanning each mode [calib rad]')
    parser.add_argument(
        '--max-amplitude', type=float, default=3.0, metavar='AMPL',
        help='Maximum amplitude allowed for the correction [calib rad]')
    parser.add_argument(
        '--modal-npoints', type=int, default=4, metavar='STEPS',
        help='Number of points for each one dimensional curve fit')
    parser.add_argument(
        '--ms-weighted', type=float, default=1.0, metavar='WGHT',
        help='Apply a scale-dependent weighting. 1.0 no weighting')
    parser.add_argument(
        '--modal-no-correction', action='store_true',
        help='''
Do not apply the aberration correction in the modal algorithm. Useful to
collect data only. This data can be used to evaluate different metrics.''')
    parser.add_argument(
        '--confocal', type=float, default=250.0, metavar='RES',
        help='Expected confocal resolution in nm, e.g. 250')
    parser.add_argument(
        '--fpr', type=float, default=5e-3, metavar='FPR',
        help='False positive rate for H1 using MS-VST based metric')
    parser.add_argument(
        '--algorithm', choices=algorithm_names,
        default=algorithm_names[0], help='Algorithm name')

    args = parser.parse_args()

    control, first_stack, close_fun, finally_fun = run_algorithm2(args)
    try:
        if args.algorithm == 'modal':
            modalWrapper = ModalWrapper(control, args)
            xopt = modalWrapper.run()

        close_fun(xopt)

    except Exception as e:
        traceback.print_exc()
        raise e
    finally:
        finally_fun()
