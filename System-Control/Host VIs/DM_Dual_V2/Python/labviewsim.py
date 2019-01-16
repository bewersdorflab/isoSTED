#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""labviewsim

author: J. Antonello <jacopo.antonello@dpag.ox.ac.uk>
date:   Thu Dec  1 12:17:35 GMT 2016
"""

import socket
import argparse
import matplotlib.pyplot as plt
import numpy as np

from numpy.random import normal

import xml2dict
import json2dict

from numpy.linalg import norm
from scipy.io import loadmat

from dmcontrol import DMCalib
from dmcontrol import DM0_MATS, DM0_PARS, DM0_SIGN, DM0_FLIPX, DM0_FLIPY
from dmcontrol import DM0_ROTATION
from dmcontrol import DM1_MATS, DM1_PARS, DM1_SIGN, DM1_FLIPX, DM1_FLIPY
from dmcontrol import DM1_ROTATION
from labviewhandler import read_payload, write_payload

act_pos = np.array([
    [4,  8], [4, 12], [4, 16], [4, 20], [4, 24], [4, 28], [4, 32], [4, 36],
    [4, 40], [4, 44], [8,  4], [8,  8], [8, 12], [8, 16], [8, 20], [8, 24],
    [8, 28], [8, 32], [8, 36], [8, 40], [8, 44], [8, 48], [12,  4], [12,  8],
    [12, 12], [12, 16], [12, 20], [12, 24], [12, 28], [12, 32], [12, 36],
    [12, 40], [12, 44], [12, 48], [16,  4], [16,  8], [16, 12], [16, 16],
    [16, 20], [16, 24], [16, 28], [16, 32], [16, 36], [16, 40], [16, 44],
    [16, 48], [20,  4], [20,  8], [20, 12], [20, 16], [20, 20], [20, 24],
    [20, 28], [20, 32], [20, 36], [20, 40], [20, 44], [20, 48], [24,  4],
    [24,  8], [24, 12], [24, 16], [24, 20], [24, 24], [24, 28], [24, 32],
    [24, 36], [24, 40], [24, 44], [24, 48], [28,  4], [28,  8], [28, 12],
    [28, 16], [28, 20], [28, 24], [28, 28], [28, 32], [28, 36], [28, 40],
    [28, 44], [28, 48], [32,  4], [32,  8], [32, 12], [32, 16], [32, 20],
    [32, 24], [32, 28], [32, 32], [32, 36], [32, 40], [32, 44], [32, 48],
    [36,  4], [36,  8], [36, 12], [36, 16], [36, 20], [36, 24], [36, 28],
    [36, 32], [36, 36], [36, 40], [36, 44], [36, 48], [40,  4], [40,  8],
    [40, 12], [40, 16], [40, 20], [40, 24], [40, 28], [40, 32], [40, 36],
    [40, 40], [40, 44], [40, 48], [44,  4], [44,  8], [44, 12], [44, 16],
    [44, 20], [44, 24], [44, 28], [44, 32], [44, 36], [44, 40], [44, 44],
    [44, 48], [48,  8], [48, 12], [48, 16], [48, 20], [48, 24], [48, 28],
    [48, 32], [48, 36], [48, 40], [48, 44], ])

# state
dms = np.array([
    [-7.88734641e-02,   1.73346594e-01],
    [-2.51551994e-01,   2.04975795e-02],
    [-2.15597734e-01,   3.08442912e-02],
    [-2.09340068e-01,   5.39246048e-02],
    [-2.07424386e-01,   4.86647405e-02],
    [-2.04738545e-01,   3.37595608e-02],
    [-2.13737359e-01,   1.44459542e-02],
    [-2.32242168e-01,  -1.49814458e-02],
    [-2.84480509e-01,  -6.96460111e-02],
    [-1.05894221e-01,   2.26946379e-02],
    [-4.93534190e-02,   1.58512980e-01],
    [-5.46201092e-01,  -1.69904046e-01],
    [-4.58397451e-01,  -1.41462067e-01],
    [-4.38561718e-01,  -1.17203936e-01],
    [-4.44316976e-01,  -1.05811704e-01],
    [-4.40537129e-01,  -1.04495681e-01],
    [-4.42348224e-01,  -1.14260437e-01],
    [-4.52834682e-01,  -1.35489844e-01],
    [-4.55659341e-01,  -1.56102407e-01],
    [-4.76748356e-01,  -2.01212206e-01],
    [-5.47216618e-01,  -2.48290785e-01],
    [-1.19885307e-01,   2.38380417e-02],
    [-2.67809255e-01,   2.42339841e-02],
    [-4.90295014e-01,  -1.26005049e-01],
    [-3.66507250e-01,  -8.08502574e-02],
    [-3.83110307e-01,  -6.37660635e-02],
    [-4.08721070e-01,  -5.68545731e-02],
    [-3.42107746e-01,  -5.64745485e-02],
    [-3.75261911e-01,  -6.53218499e-02],
    [-3.76495471e-01,  -7.26627736e-02],
    [-3.91035285e-01,  -9.31048320e-02],
    [-3.96192593e-01,  -1.25395285e-01],
    [-5.00395895e-01,  -1.93031548e-01],
    [-3.07426784e-01,  -7.06521428e-02],
    [-2.34834129e-01,   4.91545108e-02],
    [-4.58635222e-01,  -1.15773680e-01],
    [-3.57346586e-01,  -5.32624000e-02],
    [-3.76623011e-01,  -4.60575754e-02],
    [-3.63375067e-01,  -3.33620598e-02],
    [-3.55575738e-01,  -2.56958955e-02],
    [-3.71596622e-01,  -3.12237201e-02],
    [-3.62773494e-01,  -3.04961465e-02],
    [-3.73601070e-01,  -5.52917602e-02],
    [-3.81332850e-01,  -7.99747630e-02],
    [-4.59031392e-01,  -1.50181222e-01],
    [-2.61438758e-01,  -1.31252279e-02],
    [-2.28842446e-01,   4.87983029e-02],
    [-4.56771288e-01,  -1.18551404e-01],
    [-3.57605530e-01,  -4.27001586e-02],
    [-3.61655535e-01,  -3.78448850e-02],
    [-3.58554549e-01,  -3.23359515e-02],
    [-3.50205213e-01,  -1.61029626e-02],
    [-3.49250056e-01,  -1.73531317e-02],
    [-3.50682529e-01,  -2.00662784e-02],
    [-3.72066034e-01,  -3.42167343e-02],
    [-3.52200098e-01,  -5.61366846e-02],
    [-4.66609814e-01,  -1.33993555e-01],
    [-2.39676401e-01,   1.97950197e-02],
    [-2.23871083e-01,   4.29739998e-02],
    [-4.55182446e-01,  -1.24866651e-01],
    [-3.50725912e-01,  -5.13155537e-02],
    [-3.48294199e-01,  -3.64797942e-02],
    [-3.48815662e-01,  -9.71041417e-03],
    [-3.52286763e-01,  -7.06962504e-03],
    [-3.39660004e-01,   2.78845712e-03],
    [-3.14487554e-01,  -5.17467357e-04],
    [-3.68562569e-01,  -1.44204478e-02],
    [-3.58597669e-01,  -2.56100690e-02],
    [-4.48244067e-01,  -9.73641826e-02],
    [-2.32902355e-01,   4.78190429e-02],
    [-2.10727491e-01,   2.02780036e-02],
    [-4.44357119e-01,  -1.38478542e-01],
    [-3.43155391e-01,  -6.31349708e-02],
    [-3.58727022e-01,  -4.11256701e-02],
    [-3.40009959e-01,  -2.24318327e-02],
    [-3.49423773e-01,  -8.75840373e-03],
    [-3.36813188e-01,  -3.64436197e-03],
    [-3.29911841e-01,   1.74389142e-03],
    [-3.44899615e-01,  -5.81293496e-03],
    [-3.44856038e-01,  -1.54560116e-02],
    [-4.43312945e-01,  -8.43064669e-02],
    [-2.34221878e-01,   7.44195686e-02],
    [-2.36575351e-01,   7.27756431e-03],
    [-4.69398754e-01,  -1.35287718e-01],
    [-3.69674476e-01,  -7.20346853e-02],
    [-3.78067557e-01,  -4.96634007e-02],
    [-3.47120146e-01,  -3.04105316e-02],
    [-3.44463776e-01,  -1.24340962e-02],
    [-3.36330815e-01,  -1.08349279e-02],
    [-3.43504421e-01,  -1.47342701e-03],
    [-3.53369584e-01,  -9.40755136e-03],
    [-3.56871719e-01,  -1.91192565e-02],
    [-4.47483777e-01,  -7.91405715e-02],
    [-2.26666477e-01,   6.92885678e-02],
    [-2.52948464e-01,  -1.79132944e-02],
    [-4.78422202e-01,  -1.69151281e-01],
    [-3.74197523e-01,  -1.03919618e-01],
    [-3.70529125e-01,  -6.76321152e-02],
    [-3.56958071e-01,  -4.14662096e-02],
    [-3.48815662e-01,  -2.05396179e-02],
    [-3.52633364e-01,  -2.70257226e-02],
    [-3.46772076e-01,  -4.51207461e-03],
    [-3.52590044e-01,  -1.19588029e-02],
    [-3.49467198e-01,  -3.83139116e-02],
    [-4.52356554e-01,  -9.58352782e-02],
    [-2.17360674e-01,   8.04212549e-02],
    [-2.91476070e-01,  -8.43064669e-02],
    [-4.81412875e-01,  -2.15832395e-01],
    [-3.93386039e-01,  -1.44199123e-01],
    [-3.89227164e-01,  -1.10861158e-01],
    [-3.86024877e-01,  -8.40568387e-02],
    [-3.77005553e-01,  -4.89003839e-02],
    [-3.70614558e-01,  -5.25008287e-02],
    [-3.75176794e-01,  -2.82260763e-02],
    [-3.73174859e-01,  -3.41312839e-02],
    [-3.60751855e-01,  -5.07649958e-02],
    [-4.68888648e-01,  -1.08974418e-01],
    [-2.59309141e-01,   7.06826244e-02],
    [-7.31309950e-02,  -1.90331409e-02],
    [-5.36790415e-01,  -2.63031654e-01],
    [-4.72962654e-01,  -2.19677589e-01],
    [-4.50481885e-01,  -1.67406725e-01],
    [-4.50801203e-01,  -1.40777121e-01],
    [-4.42870884e-01,  -1.27061470e-01],
    [-4.60812366e-01,  -9.60006275e-02],
    [-4.37794809e-01,  -8.51383153e-02],
    [-4.44918961e-01,  -9.13236909e-02],
    [-4.49962796e-01,  -1.04372255e-01],
    [-5.26283035e-01,  -1.43676200e-01],
    [-4.73583852e-02,   2.47327056e-01],
    [-9.42020816e-02,   2.63469695e-02],
    [-2.42208940e-01,  -8.68839670e-02],
    [-2.18407970e-01,  -2.77545971e-02],
    [-2.20880615e-01,   2.22989930e-02],
    [-1.55865429e-01,   3.56168751e-02],
    [-1.71714008e-01,   7.59973394e-02],
    [-1.84353006e-01,   7.84790319e-02],
    [-2.09531509e-01,   7.33383375e-02],
    [-2.53506688e-01,   6.76258822e-02],
    [-6.81501709e-02,   1.62775013e-01]])

image_size = 256
stack0 = np.resize(
    loadmat('./simstack.mat')['stack'],
    (image_size, image_size))
zcomp = 0.83882867660355576


dd = np.linspace(0, 50, 200)
xx, yy = np.meshgrid(dd, dd)
actsplot = np.zeros((xx.size, act_pos.shape[0]))

for i in range(140):
    actsplot[:, i] = np.exp(-np.sqrt(
        (xx - act_pos[i, 0])**2 + (yy - act_pos[i, 1])**2)/2).ravel()


dm0 = DMCalib(DM0_PARS, DM0_MATS)
dm0.rotate_pupil(DM0_ROTATION, DM0_SIGN)
dm0.flip_pupil(DM0_FLIPX, DM0_FLIPY)
dm1 = DMCalib(DM1_PARS, DM1_MATS)
dm1.rotate_pupil(DM1_ROTATION, DM1_SIGN)
dm1.flip_pupil(DM1_FLIPX, DM1_FLIPY)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Simulate isoSTED LabView VIs.',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('--host', type=str, default='localhost')
    parser.add_argument('--port', type=int, default=8900)
    parser.add_argument('--debug', action='store_true')
    parser.add_argument('--step', action='store_true')
    parser.add_argument('--plot', action='store_true')
    parser.add_argument('--no-flats', action='store_true')
    parser.add_argument('--no-auto-scale', action='store_true')
    parser.add_argument('--fill-scans', action='store_true')

    args = parser.parse_args()

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((args.host, args.port))

    def read_xml():
        return read_payload(
            sock, debug=args.debug, interpret=xml2dict.loads)

    def write_xml(dout):
        write_payload(
            sock, dout, debug=args.debug, interpret=xml2dict.dumps)

    def read_json():
        return read_payload(
            sock, debug=args.debug, interpret=json2dict.loads)

    def write_json(dout):
        write_payload(
            sock, dout, debug=args.debug, interpret=json2dict.dumps)

    imacq = {
        'Customized Image Format': 0,
        'Fast Axis Frequency (Hz)': 15780.0,
        'Frames Accumulations': 1,
        'Frames Per Capture': 1,
        'Image Dimension (um)': np.array([5.,  5.]),
        'Image Format': image_size,
        'Line Accumulations': 30,
        'Number of Z Steps': 1,
        'Pixel Size (nm)': np.array([14.6484375, 14.6484375]),
        'Scan Mode': 'XY',
        'Scan Type': 'Beam Scanning',
        'Z Steps Size (um)': 1.0
        }
    write_xml(imacq)
    read_json()

    detectors = {
        'Far Red (685/40 nm)': True,
        'Green (525/50 nm)': False,
        'Orange (624/40 nm)': False,
        'PMT': False,
        'Sum All': False
        }
    write_xml(detectors)
    read_json()

    lasers = {
        '485 nm': False,
        '590 nm': False,
        '650 nm': True,
        'Manual Control': False,
        'STED': True,
        'STED Power (V)': 3.0
        }
    write_xml(lasers)
    read_json()

    # initial condition
    write_json({'dms': dms, 'zcomp': zcomp})
    read_json()

    if args.plot:
        artist_updates = list()
        nn = 2
        mm = 2
        u = np.zeros((act_pos.shape[0], 1))

        fig = plt.figure(1)
        fig.show()

        ax = plt.subplot(nn, mm, 1)
        dm0img = ax.imshow(
            np.dot(actsplot, u).reshape(xx.shape),
            interpolation='none',
            vmin=-1, vmax=1)
        cb = plt.colorbar(dm0img, ax=ax)
        cb.formatter.set_powerlimits((0, 1))
        ax.axis('off')
        fig.canvas.draw()
        artist_updates.append((ax, [dm0img], None))

        ax = plt.subplot(nn, mm, 2)
        dm1img = ax.imshow(
            np.dot(actsplot, u).reshape(xx.shape),
            interpolation='none',
            vmin=-1, vmax=1)
        cb = plt.colorbar(dm1img, ax=ax)
        cb.formatter.set_powerlimits((0, 1))
        ax.axis('off')
        fig.canvas.draw()
        artist_updates.append((ax, [dm1img], None))

        ax = plt.subplot(nn, mm, 3)
        ax.set_xlim(1., 140.)
        ax.set_ylim(-1., 1.)
        ax.grid()
        fig.canvas.draw()
        bg = fig.canvas.copy_from_bbox(ax.bbox)
        dm0l, = ax.plot(np.zeros((140,)), color='b')
        artist_updates.append((ax, [dm0l], bg))

        ax = plt.subplot(nn, mm, 4)
        ax.set_xlim(1., 140.)
        ax.set_ylim(-1., 1.)
        ax.grid()
        fig.canvas.draw()
        bg = fig.canvas.copy_from_bbox(ax.bbox)
        dm1l, = ax.plot(np.zeros((140,)), color='b')
        artist_updates.append((ax, [dm1l], bg))

    def do_plot():
        if args.no_flats:
            mydm0 = dms[:, 0] - dm0.uflat
        else:
            mydm0 = dms[:, 0]

        if args.no_flats:
            mydm1 = dms[:, 1] - dm1.uflat
        else:
            mydm1 = dms[:, 1]

        dm0img.set_array(np.dot(actsplot, mydm0).reshape(xx.shape))
        if args.no_auto_scale:
            dm0img.set_clim(-1., 1.)
        else:
            dm0img.autoscale()

        dm1img.set_array(np.dot(actsplot, mydm1).reshape(xx.shape))
        if args.no_auto_scale:
            dm1img.set_clim(-1., 1.)
        else:
            dm1img.autoscale()

        dm0l.set_ydata(mydm0)
        dm1l.set_ydata(mydm1)

        for ax, arts, bg in artist_updates:
            if bg:
                ax.figure.canvas.restore_region(bg)
            for a in arts:
                ax.draw_artist(a)
        for ax, _, _ in artist_updates:
            ax.figure.canvas.blit(ax.bbox)

        plt.pause(0.05)

    # # test plot
    # for i in range(140):
    #     dms *= 0
    #     dms[i, 0] = (-1)**(i + 1)
    #     dms[-i, 1] = (-1)**(i)
    #     do_plot()

    aberration = None
    run = True
    scan_count = 0
    while run:
        write_json({'Command': 'Command'})
        cmd = read_json()['Command']
        if cmd == 'Scan':
            if args.plot:
                do_plot()
            if args.step:
                if input(
                    'Stepping: q quit, anything continue scan={} '.format(
                        scan_count)) == 'q':
                    run = False

            if aberration is not None and norm(aberration) != 0.0:
                enorm = norm((aberration - dms).ravel())
                expval = np.exp(-enorm)*stack0
                stack = expval*np.ones((image_size, image_size))
            else:
                stack = stack0*normal(size=(image_size, image_size))
            if args.fill_scans:
                fig10 = plt.figure(10, figsize=(1.28, 1.28), dpi=100)
                ax = fig10.gca()
                ax.axis('off')
                plt.text(
                    .5, .5, str(scan_count),
                    transform=ax.transAxes, ha='center')
                fig10.canvas.draw()
                data = np.fromstring(
                    fig10.canvas.tostring_rgb(), dtype=np.uint8, sep='')
                size = fig10.canvas.get_width_height()
                data = data.reshape(size + (3,))
                stack = data[:, :, 0]
                plt.close(fig10)

            # send scan
            write_json({
                'dm0': dms[:, 0],
                'dm1': dms[:, 1],
                'zcomp': zcomp,
                'stack': stack})
            # write hardware
            upd = read_json()
            dms[:, 0] = upd['dm0']
            dms[:, 1] = upd['dm1']
            zcomp = upd['zcomp']

            if aberration is None:
                flats = np.hstack((
                    dm0.uflat.reshape(-1, 1),
                    dm1.uflat.reshape(-1, 1)))
                norm1 = norm((dms - flats).ravel())
                print(norm1)
                if norm1 != 0.0:
                    aberration = dms.copy()
                    print('Detected DM aberration')
                else:
                    print('No DM aberration detected')
                    aberration = 0*dms.copy()

            scan_count += 1

        elif cmd == 'Image acquisition params':
            write_xml(imacq)
            imacq = read_xml()
        elif cmd == 'Detectors params':
            raise NotImplementedError
        elif cmd == 'Laser params':
            raise NotImplementedError
        elif cmd == 'Stop':
            run = False
