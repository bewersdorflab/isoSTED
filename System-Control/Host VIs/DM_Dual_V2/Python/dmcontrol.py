#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np

from numpy.random import normal
from numpy.linalg import norm, matrix_rank
from scipy.io import loadmat

from czernike import RZern

# LabView convertion u to voltage:
# d = dmax*(u + 1)/2
# V = (-b + sqrt(b**2 + 4*a*D))/(2*a)

# MATLAB calibration
# d_f = f1(v_f)
# d_t = d_f + d
# u_t = 2*d_t/f1(300) - 1
# v_t = f2(d_t)

# SIGNAL VS VOL. DATABASE (Voltage vs Signal_Data Engine_V1)
# 1: 13RW018#054 Upper DM in isoSTED
# 0: 13RW023#017 Lower DM in isoSTED
# 0: 247.8239, 0.060365, -0.83694, 3500
# 1: 294.658, 0.03945, 0.2539, 3500
# Vmax, a, b, dmax

DM1_PARS = './calibrations/13RW018p054/13RW018p054_params.mat'
DM1_MATS = './calibrations/13RW018p054/13RW018p054_ds1-351-88-matrices.mat'
DM1_ROTATION = 0.0
DM1_SIGN = 1
DM1_FLIPX = False
DM1_FLIPY = False

DM0_PARS = './calibrations/13RW023p017/13RW023p017_params.mat'
DM0_MATS = './calibrations/13RW023p017/13RW023p017_ds1-351-88-matrices.mat'
DM0_ROTATION = 0.0
DM0_SIGN = -1
DM0_FLIPX = False
DM0_FLIPY = True


ZCOMP_MIN_UM = 0.0
ZCOMP_MAX_UM = 15.0


class DMCalib:

    flatOn = 1.

    def __init__(self, fparams, fmatrices):
        self.params = loadmat(fparams)
        self.uflat = self.params['uflat'].ravel()

        # get exact matlab parameters
        self.a = self.params['a'][0, 0]
        self.b = self.params['b'][0, 0]
        self.C = self.params['C'][0, 0]
        self.D = self.params['D'][0, 0]
        self.E = self.params['E'][0, 0]
        self.F = self.params['F'][0, 0]
        self.calibration_lambda = self.params['calibration_lambda'][0, 0]
        self.rad_to_nm = (self.calibration_lambda/1e-9)/(2*np.pi)

        self.matrices = loadmat(fmatrices)
        self.Hf = np.ascontiguousarray(self.matrices['Hf'])
        self.Cf = np.ascontiguousarray(self.matrices['Cf'])
        self.H1 = np.ascontiguousarray(self.matrices['H1'])
        self.C1 = np.ascontiguousarray(self.matrices['C1'])

        self.noll_indices = set(range(1, self.Hf.shape[0] + 1))

    def rad_to_nm(self, rad):
        return rad*self.rad_to_nm

    def add_flat_to_u(self, u):
        u = self.flatOn*self.uflat + u
        return u

    def set_zernike_indices(self, noll_indices):
        # stored in Noll - 1
        if not isinstance(noll_indices, np.ndarray):
            noll_indices = np.array(noll_indices, dtype=np.int)
        self.zernike_indices = noll_indices - 1

    def zernike_to_u(self, x):
        assert(self.zernike_indices.size == x.size)
        xf = np.zeros((self.Cf.shape[1],))
        xf[self.zernike_indices] = x
        return np.dot(self.Cf, xf)

    def rotate_pupil(self, rad, sign):
        if rad != 0.:
            T = self.make_rot_matrix(self.Hf.shape[0], rad)
            self.Hf = sign*np.dot(T, self.Hf)
            self.Cf = sign*np.dot(self.Cf, T.T)

    def flip_pupil(self, xflip, yflip):
        if xflip:
            T = self.make_xflip_matrix(self.Hf.shape[0])
            self.Hf = np.dot(T, self.Hf)
            self.Cf = np.dot(self.Cf, T)
        if yflip:
            T = self.make_yflip_matrix(self.Hf.shape[0])
            self.Hf = np.dot(T, self.Hf)
            self.Cf = np.dot(self.Cf, T)

    def make_rot_matrix(self, nz, alpha):
        # nz = (n + 1)*(n + 2)/2 = 1/2*n**2 + 3/2*n + 1
        n = int(-(3/2) + np.sqrt((3/2)**2 - 4/2*(1 - nz)))
        cz = RZern(n)
        nml = list(zip(cz.ntab.tolist(), cz.mtab.tolist()))
        R = np.zeros((cz.nk, cz.nk))
        for i, nm in enumerate(nml):
            n, m = nm[0], nm[1]
            if m == 0:
                R[i, i] = 1.0
            elif m > 0:
                R[i, i] = np.cos(m*alpha)
                R[i, nml.index((n, -m))] = np.sin(m*alpha)
            else:
                R[i, nml.index((n, -m))] = -np.sin(abs(m)*alpha)
                R[i, i] = np.cos(abs(m)*alpha)

        # checks
        assert(matrix_rank(R) == R.shape[0])
        assert(norm((np.dot(R, R.T) - np.eye(cz.nk)).ravel()) < 1e-11)
        assert(norm((np.dot(R.T, R) - np.eye(cz.nk)).ravel()) < 1e-11)
        return R

    def make_yflip_matrix(self, nz):
        n = int(-(3/2) + np.sqrt((3/2)**2 - 4/2*(1 - nz)))
        cz = RZern(n)
        nml = list(zip(cz.ntab.tolist(), cz.mtab.tolist()))
        R = np.zeros((cz.nk, cz.nk))
        for i, nm in enumerate(nml):
            m = nm[1]
            if m < 0:
                R[i, i] = -1.0
            else:
                R[i, i] = 1.0

        # checks
        assert(matrix_rank(R) == R.shape[0])
        assert(norm((np.dot(R, R.T) - np.eye(cz.nk)).ravel()) < 1e-11)
        assert(norm((np.dot(R.T, R) - np.eye(cz.nk)).ravel()) < 1e-11)
        return R

    def make_xflip_matrix(self, nz):
        n = int(-(3/2) + np.sqrt((3/2)**2 - 4/2*(1 - nz)))
        cz = RZern(n)
        nml = list(zip(cz.ntab.tolist(), cz.mtab.tolist()))
        R = np.zeros((cz.nk, cz.nk))
        for i, nm in enumerate(nml):
            m = nm[1]
            if abs(m) % 2 == 0 and m < 0:
                R[i, i] = -1.0
            elif abs(m) % 2 == 1 and m > 0:
                R[i, i] = -1.0
            else:
                R[i, i] = 1.0
        # checks
        assert(matrix_rank(R) == R.shape[0])
        assert(norm((np.dot(R, R.T) - np.eye(cz.nk)).ravel()) < 1e-11)
        assert(norm((np.dot(R.T, R) - np.eye(cz.nk)).ravel()) < 1e-11)
        return R


class DualDMVoltage:

    def __init__(self, isoSTED, args):
        self.isoSTED = isoSTED
        self.dm0 = DMCalib(DM0_PARS, DM0_MATS)
        self.dm0.rotate_pupil(DM0_ROTATION, DM0_SIGN)
        self.dm1 = DMCalib(DM1_PARS, DM1_MATS)
        self.dm1.rotate_pupil(DM1_ROTATION, DM1_SIGN)

        if args.cnt_no_dm0:
            self.flag_dm0 = 0.0
            self.ndof0 = 0
        else:
            self.flag_dm0 = 1.0
            self.ndof0 = self.isoSTED.get_dm0_dof()

        if args.cnt_no_dm1:
            self.flag_dm1 = 0.0
            self.ndof1 = 0
        else:
            self.flag_dm1 = 1.0
            self.ndof1 = self.isoSTED.get_dm1_dof()

        if args.cnt_no_zcomp:
            self.flag_zcomp = 0.0
            self.ndof2 = 0
        else:
            self.flag_zcomp = 1.0
            self.ndof2 = self.isoSTED.get_zcomp_dof()

        self.ndof = self.ndof0 + self.ndof1 + self.ndof2

    def get_ndof(self):
        return self.ndof

    def write_settings(self, x):

        x = x.copy()

        off = 0

        if self.ndof0 > 0:
            dm0 = x[off:off + self.ndof0]
            off += self.ndof0
        else:
            dm0 = np.zeros(self.isoSTED.get_dm0_dof())

        if self.ndof1 > 0:
            dm1 = x[off:off + self.ndof1]
            off += self.ndof1
        else:
            dm1 = np.zeros(self.isoSTED.get_dm1_dof())

        if self.ndof2 > 0:
            zcomp = x[off:off + self.ndof2]
            off += self.ndof2
        else:
            zcomp = np.zeros(self.isoSTED.get_zcomp_dof())

        assert(off == x.size)

        self.isoSTED.write_settings(
            self.dm0.add_flat_to_u(dm0),
            self.dm1.add_flat_to_u(dm1),
            zcomp)


class DualDMZernike:

    def __init__(self, isoSTED, args):
        self.isoSTED = isoSTED
        self.dm0 = DMCalib(DM0_PARS, DM0_MATS)
        self.dm0.rotate_pupil(DM0_ROTATION, DM0_SIGN)
        self.dm0.flip_pupil(DM0_FLIPX, DM0_FLIPY)
        self.dm1 = DMCalib(DM1_PARS, DM1_MATS)
        self.dm1.rotate_pupil(DM1_ROTATION, DM1_SIGN)
        self.dm1.flip_pupil(DM1_FLIPX, DM1_FLIPY)

        if args.use_labview_initial:
            self.dm0.uflat = isoSTED.dm0.copy()
            self.dm1.uflat = isoSTED.dm1.copy()

        zernike_indices, exclude_4pi = get_zernike_indeces_from_args(args)

        if isoSTED.h5f:
            isoSTED.h5f['dmcontrol/zernike_indices'] = zernike_indices
            isoSTED.h5f['dmcontrol/exclude_4pi'] = exclude_4pi
            isoSTED.h5f['dmcontrol/rad_to_nm'] = self.dm0.rad_to_nm

        # for convention the rad of the DM calibration wavelength are used in
        # the control. this unit can be converted to um afterwards
        assert(self.dm0.rad_to_nm == self.dm1.rad_to_nm)

        # setup zcomp scaling
        # LabView accepts zcomp between [ZCOMP_MIN_UM, ZCOMP_MAX_UM]
        assert(ZCOMP_MIN_UM == 0)
        self.zcomp_calib_rad_to_um = (
            self.dm0.calibration_lambda/1e-6)/(2*np.pi)
        if isoSTED.h5f:
            isoSTED.h5f['dmcontrol/zcomp_calib_rad_to_um'] = (
                self.zcomp_calib_rad_to_um)

        print('dmcontrol: lambda = {} nm'.format(
            self.dm0.params['calibration_lambda'][0, 0]/1e-9))
        print('dmcontrol: rad_to_nm = {}'.format(self.dm0.rad_to_nm))
        print('dmcontrol: zcomp_calib_rad_to_um = {}'.format(
            self.zcomp_calib_rad_to_um))

        # setup DM0 dofs
        if args.cnt_no_dm0:
            self.flag_dm0 = 0.0
            self.ndof0 = 0
        else:
            self.flag_dm0 = 1.0
            self.dm0.set_zernike_indices(zernike_indices)
            self.ndof0 = self.dm0.zernike_indices.size

        # setup DM1 dofs
        if args.cnt_no_dm1:
            self.flag_dm1 = 0.0
            self.ndof1 = 0
        else:
            self.flag_dm1 = 1.0
            self.dm1.set_zernike_indices(zernike_indices)
            self.ndof1 = self.dm1.zernike_indices.size

        # setup zcomp dof
        if args.cnt_no_zcomp:
            self.flag_zcomp = 0.0
            self.ndof2 = 0
        else:
            self.flag_zcomp = 1.0
            self.ndof2 = self.isoSTED.get_zcomp_dof()

        # but 4pi modes may be removed later
        self.ndof = self.ndof0 + self.ndof1 + self.ndof2

        if args.z_4pi_modes:
            # 4pi modes control
            zind0 = self.dm0.zernike_indices
            zind1 = self.dm1.zernike_indices
            assert(zind0.size == zernike_indices.size)
            assert(zind1.size == zernike_indices.size)
            assert(norm(zind0 - (zernike_indices - 1)) == 0)
            assert(norm(zind1 - (zernike_indices - 1)) == 0)
            if zind0.size != zind1.size or np.any(zind0 != zind1):
                raise ValueError('Zernike modes must match for DM0 and DM1')

            # build all 4Pi modes combinations
            all_4pi = list()
            T1 = np.zeros((2*self.ndof0, 2*self.ndof0))
            count = 0
            for i, noll in enumerate(zernike_indices):
                for s in [1, -1]:
                    all_4pi.append(s*noll)
                    T1[i, count] = 1.
                    T1[self.ndof0 + i, count] = s
                    count += 1
            assert(matrix_rank(T1) == 2*self.ndof0)

            # remove 4Pi covariant/contravariant modes
            if exclude_4pi.size > 0:
                if isoSTED.h5f:
                    isoSTED.h5f['dmcontrol/T1_full'] = T1

                remove = np.intersect1d(all_4pi, exclude_4pi)
                inds_remove = list()
                for r in remove:
                    inds = (all_4pi == r).nonzero()[0]
                    assert(inds.size == 1)
                    inds_remove.append(inds[0])
                all_indices = np.arange(T1.shape[1])
                rem_indices = np.setdiff1d(all_indices, inds_remove)
                if len(inds_remove) > 0:
                    T1 = T1[:, rem_indices]

                print('4pi_modes: all_4pi NOLL')
                print(all_4pi)
                print('4pi_modes: all_indices')
                print(all_indices)
                print('4pi_modes: remaining_indices')
                print(rem_indices)
                print('4pi_modes: {} modes removed'.format(
                    all_indices.size - rem_indices.size))

                if isoSTED.h5f:
                    isoSTED.h5f['dmcontrol/all_4pi'] = all_4pi
                    isoSTED.h5f['dmcontrol/all_indices'] = all_indices
                    isoSTED.h5f['dmcontrol/rem_indices'] = rem_indices

            # zcomp
            if self.ndof2 > 0:
                # append zcomp dof
                T = np.eye(self.ndof)
                T[:(self.ndof - self.ndof2), :(self.ndof - self.ndof2)] = T1
            else:
                T = T1
        else:
            # direct control
            T = np.eye(self.ndof)

        if isoSTED.h5f:
            isoSTED.h5f['dmcontrol/T'] = T

        self.T = T
        # effective ndof
        self.ndof = T.shape[1]

        # initial DM aberration
        if args.dm_ab_calib_rad != 0.0 and args.dm_ab_um != 0.0:
            print('WARN: cannot specify DM aberration both in rad and um')
        if args.dm_ab_um != 0.0:
            self.set_random_dm_ab_um(args.dm_ab_um)
        elif args.dm_ab_calib_rad != 0.0:
            self.set_random_dm_ab_calib_rad(args.dm_ab_calib_rad)
        else:
            self.set_random_dm_ab_calib_rad(0.0)

        if isoSTED.h5f:
            isoSTED.h5f['dmcontrol/dm_ab_calib_rad'] = self.dm_ab_calib_rad

        self.log_write_count = 0

    def zcomp_calib_rad_to_labview(self, rad):
        return rad*self.zcomp_calib_rad_to_um + ZCOMP_MAX_UM/2

    def zcomp_labview_to_calib_rad(self, um):
        return (um - ZCOMP_MAX_UM/2)/self.zcomp_calib_rad_to_um

    def get_ndof(self):
        return self.ndof

    def get_dm0_ndof(self):
        return self.ndof0

    def get_dm1_ndof(self):
        return self.ndof1

    def set_random_dm_ab_calib_rad(self, rms=0.5):
        ab = normal(size=(self.T.shape[1],))
        ab = (rms/norm(ab))*ab
        self.dm_ab_calib_rad = ab

    def set_random_dm_ab_um(self, rms=0.5):
        self.set_random_dm_ab_calib_rad(rms=rms/self.dm0.rad_to_nm)

    def write_settings(self, x):
        x = x.copy()

        if self.isoSTED.h5f:
            self.isoSTED.h5f['dmcontrol/write/{:09d}'.format(
                self.log_write_count)] = x
            self.log_write_count += 1

        if self.dm_ab_calib_rad is not None:
            x += self.dm_ab_calib_rad

        x = np.dot(self.T, x)

        off = 0

        if self.ndof0 > 0:
            dm0 = self.dm0.zernike_to_u(x[off:off + self.ndof0])
            off += self.ndof0
        else:
            dm0 = np.zeros(self.isoSTED.get_dm0_dof())

        if self.ndof1 > 0:
            dm1 = self.dm1.zernike_to_u(x[off:off + self.ndof1])
            off += self.ndof1
        else:
            dm1 = np.zeros(self.isoSTED.get_dm1_dof())

        if self.ndof2 > 0:
            zcomp = x[off:off + self.ndof2]
            # normalise zcomp
            zcomp = self.zcomp_calib_rad_to_labview(zcomp)
            off += self.ndof2
        else:
            assert(self.isoSTED.get_zcomp_dof() == 1)
            zcomp = 0.0

        assert(off == x.size)

        self.isoSTED.write_settings(
            self.dm0.add_flat_to_u(dm0),
            self.dm1.add_flat_to_u(dm1),
            zcomp)


control_classes = [DualDMZernike, DualDMVoltage]
control_names = [c.__name__ for c in control_classes]


def apply_control(name, isoSTED, args):
    if name not in control_names:
        raise ValueError(
            'Control name must be any of {}'.format(str(control_names)))
    return control_classes[control_names.index(name)](isoSTED, args)


def get_zernike_indeces_from_args(args):
    if args.cnt_no_dm0 or args.cnt_no_dm1:
        if args.z_4pi_modes:
            print('You cannot use 4Pi modes if one of the DMs is disabled.')
            print('Disabling 4Pi modes automatically.')
            args.z_4pi_modes = False

    if args.z_min > 0 and args.z_max > 0:
        mrange = np.arange(args.z_min, args.z_max + 1)
    else:
        mrange = np.array([], dtype=np.int)

    if args.z_noll_include is not None:
        minclude = np.fromstring(args.z_noll_include, dtype=np.int, sep=',')
        minclude = minclude[minclude > 0]
    else:
        minclude = np.array([], dtype=np.int)

    if args.z_noll_exclude is not None:
        mexclude = np.fromstring(args.z_noll_exclude, dtype=np.int, sep=',')
        mexclude = mexclude[mexclude > 0]
    else:
        mexclude = np.array([], dtype=np.int)

    zernike_indices = np.setdiff1d(
        np.union1d(np.unique(mrange), np.unique(minclude)),
        np.unique(mexclude))

    print('Selected Noll indices for the Zernike modes are:')
    print(zernike_indices)

    if args.z_4pi_modes and args.z_exclude_4pi_modes:
        exclude_4pi = np.fromstring(
            args.z_exclude_4pi_modes, dtype=np.int, sep=',')
        # intersect = np.intersect1d(zernike_indices, np.abs(exclude_4pi))
        # if intersect.size != exclude_4pi.size:
        #     print('WARN: the following 4pi modes exclusions were not used:')
        #     print(np.setdiff1d(exclude_4pi, intersect))
    else:
        exclude_4pi = np.array([], dtype=np.int)

    if args.z_4pi_modes and exclude_4pi.size > 0:
        print('Excluded 4Pi modes are:')
        print(exclude_4pi)

    zernike_indices.sort()
    exclude_4pi.sort()

    return zernike_indices, exclude_4pi


def add_control_parameters(parser):
    parser.add_argument(
        '--dm-ab-calib-rad', type=float, default=0.0, metavar='RMS',
        help='Add random DM aberration of RMS [rad] (calibration lambda)')
    parser.add_argument(
        '--dm-ab-um', type=float, default=0.0, metavar='RMS',
        help='Add random DM aberration of RMS [um]')
    parser.add_argument(
        '--control', metavar='NAME',
        choices=control_names, default=control_names[0],
        help='Select a DM control')
    parser.add_argument(
        '--cnt-no-dm0', action='store_true', help='Disable DM0')
    parser.add_argument(
        '--cnt-no-dm1', action='store_true', help='Disable DM1')
    parser.add_argument(
        '--cnt-no-zcomp', action='store_true', default=True,
        help='Disable piston compensation stage')
    parser.add_argument(
        '--z-noll-include', type=str, default=None, metavar='INDICES',
        help='''
Comma separated list of Noll indices to include, e.g.,
1,2,3,4,5,6.
NB: DO NOT USE SPACES in the list!''')
    parser.add_argument(
        '--z-noll-exclude', type=str, default=None, metavar='INDICES',
        help='''
Comma separated list of Noll indices to exclude, e.g.,
1,5,6 to exclude piston and astigmatism.
NB: DO NOT USE SPACES in the list!''')
    parser.add_argument(
        '--z-min', type=int, default=5, metavar='MIN',
        help='Minimum Noll index to consider, use -1 to ignore')
    parser.add_argument(
        '--z-max', type=int, default=10, metavar='MAX',
        help='Maximum Noll index to consider, use -1 to ignore')
    parser.add_argument(
        '--z-4pi-modes', type=bool, default=True, help='Use 4Pi modes')
    parser.add_argument(
        '--z-exclude-4pi-modes', type=str, default='-1,2,3,4',
        metavar='INDICES',
        help='''
Comma separated list of 4pi modes to ignore, e.g.,
-1,2,3,4 to ignore contravariant piston and covariant tip/tilt/defocus.
The sign denotes co/contra variant. The absolute value denotes a Noll index.
NB: DO NOT USE SPACES in the list!''')
    parser.add_argument(
        '--use-labview-initial', action='store_true',
        help='Use LabView provided initial state and flat')
