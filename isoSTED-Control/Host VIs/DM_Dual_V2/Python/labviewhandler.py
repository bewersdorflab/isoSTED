#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""labviewhandler - TCP pipe between LabView and Python using XML and JSON.

TODO

author: J. Antonello <jacopo.antonello@dpag.ox.ac.uk>
date: Tue Apr 18 15:04:55 BST 2017
"""

import sys
import traceback
import socket
import struct
import copy
import h5py
import json
# import argparse
# import time

import numpy as np
# import re

from h5py import version as h5version
from datetime import datetime
from dateutil.tz import tzlocal
from datetime import timezone

import xml2dict
import json2dict

from dmcontrol import add_control_parameters, apply_control


# max signed integer 2**31 - 1 = 2147483647
# unsigned int 4 bytes 2**(8*4)=4294967296
HEADER_SIZE_BYTES = 4
PAYLOAD_MAX_SIZE_BYTES = 2**31 - 1
DEFAULT_ENCODING = 'utf-8'


def sread(conn, size):
    data = b''
    while len(data) < size:
        tmp = conn.recv(size - len(data))
        data += tmp
        if len(tmp) == 0:
            raise RuntimeError('broken connection')
    return data


def read_payload(conn, debug=False, dump=None, interpret=json2dict.loads):
    size = struct.unpack('>I', sread(conn, size=HEADER_SIZE_BYTES))[0]
    payload = sread(conn, size=size).decode(DEFAULT_ENCODING)
    if dump:
        dump.write(payload.encode(DEFAULT_ENCODING))
    parsed = interpret(payload)
    if debug:
        print('read_payload() size:{} {}'.format(size, str(parsed)))
    return parsed


def write_payload(
        conn, payload, debug=False, dump=None, interpret=json2dict.dumps):
    parsed = interpret(payload)
    size = struct.pack('>I', len(parsed))
    if debug:
        print('write_payload() size:{} {}'.format(len(parsed), str(payload)))
    if dump:
        dump.write(parsed)
    conn.sendall(size)
    conn.sendall(parsed)


class LabViewStopException(Exception):
        pass


class IsoSTED:

    log_din = list()
    log_dout = list()

    input_counter = 0
    output_counter = 0

    def __init__(self, args, h5log=True):
        if h5log:
            libver = 'latest'
            date = datetime.now()
            h5fn = date.strftime('%Y_%m_%d_%H_%M_%S.h5')
            self.h5f = h5py.File(h5fn, 'w', libver=libver)
            self.h5f['version/libver'] = libver
            self.h5f['version/api_version'] = h5version.api_version
            self.h5f['version/version'] = h5version.version
            self.h5f['version/hdf5_version'] = h5version.hdf5_version
            self.h5f['version/info'] = h5version.info
            self.h5f['date_local'] = date.isoformat()
            self.h5f['date_utc'] = date.replace(
                tzinfo=tzlocal()).astimezone(timezone.utc).isoformat()
            self.h5f['args'] = json.dumps(vars(args))
        else:
            self.h5f = None

    def dump_dict(self, prefix, d):
        for k, v in d.items():
            if isinstance(v, dict):
                a = prefix + '/' + k
                b = v['Choice'][v['Val']]
                # print(a, b)
                self.h5f[a] = b
            else:
                a = prefix + '/' + k
                # print(a, v)
                self.h5f[a] = v

    def initialise(self):
        # read LabView configuration
        self.imacq = self.read_xml()
        self.dump_dict('imacq', self.imacq)
        self.write_json({'a': 'a'})

        self.detectors = self.read_xml()
        self.dump_dict('detectors', self.detectors)
        self.write_json({'a': 'a'})

        self.lasers = self.read_xml()
        self.dump_dict('lasers', self.lasers)
        self.write_json({'a': 'a'})

        self.initial = self.read_json()
        self.dump_dict('initial', self.initial)
        self.write_json({'a': 'a'})

        # input dimensions
        self.parse_image_format()

        # output dimensions
        self.dmnact = max(self.initial['dms'].shape)

        self.dm0 = self.initial['dms'][:, 0]
        self.dm1 = self.initial['dms'][:, 1]
        self.zcomp = self.initial['zcomp']

    def parse_image_format(self):
        sel = self.imacq['Image Format']
        if sel == 0:
            x1 = self.imacq['Customized Image Format'][0]
            x2 = self.imacq['Customized Image Format'][1]
        else:
            x1 = sel
            x2 = sel
        x3 = self.imacq['Number of Z Steps']
        dims = (x1, x2, x3)
        if x3 == 1 or x3 == 0:
            shape = (x1, x2)
        else:
            shape = dims

        # return dims, shape
        self.stack_dims = dims
        self.stack_shape = shape

    def issue_command(self, cmd):
        cmdin = self.read_json()
        if 'Command' in cmdin.keys() and cmdin['Command'] == 'Stop':
            self.write_json({'Command': 'Stop'})
            raise LabViewStopException()
        self.write_json({'Command': cmd})
        return cmdin

    def read_stack(self):
        self.issue_command('Scan')
        din = self.read_json()

        self.stack = din['stack']
        self.zcomp = din['zcomp']
        assert(din['dm0'].size == self.dmnact)
        assert(din['dm1'].size == self.dmnact)
        assert(isinstance(din['zcomp'], float))

        if self.h5f:
            self.h5f['input/stack/{:09d}'.format(
                self.input_counter)] = din['stack']
            self.h5f['input/zcomp/{:09d}'.format(
                self.input_counter)] = din['zcomp']

        self.log_din.append(din)
        self.input_counter += 1

        return self.stack, self.zcomp

    def write_settings(self, dm0, dm1, zcomp):
        self.dm0 = copy.copy(dm0)
        self.dm1 = copy.copy(dm1)
        self.zcomp = zcomp

        assert(dm0.size == self.dmnact)
        assert(dm1.size == self.dmnact)
        assert(isinstance(zcomp, float))

        dout = json2dict.empty_like(self.log_din[-1])
        dout['dm0'] = self.dm0
        dout['dm1'] = self.dm1
        dout['zcomp'] = self.zcomp
        dout['stack'] = np.zeros(self.stack_shape)

        if self.h5f:
            self.h5f['output/dm0/{:09d}'.format(
                self.output_counter)] = self.dm0
            self.h5f['output/dm1/{:09d}'.format(
                self.output_counter)] = self.dm1
            self.h5f['output/zcomp/{:09d}'.format(
                self.output_counter)] = self.zcomp

        self.log_dout.append(dout)
        self.write_json(dout)

        self.log_dout.append(dout)
        self.output_counter += 1

    def get_dm0_dof(self):
        return self.dmnact

    def get_dm1_dof(self):
        return self.dmnact

    def get_zcomp_dof(self):
        return 1

    def close_logging(self):
        if self.h5f:
            self.h5f.flush()
            self.h5f.close()
            self.h5f = None

    def issue_stop(self):
        self.issue_command('Stop')


def run_algorithm(
        args, compute_metric, num_min,
        plot_debug):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    if sys.platform == 'linux':
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.bind((args.host, args.port))
    except socket.error as err:
        print(
            'bind failed: {} {}'.format(str(err.args[0]), err.args[1]),
            file=sys.stderr)
        sys.exit(1)

    sock.listen(1)
    print('listening {}:{}'.format(args.host, args.port))

    if args.dump_files:
        dump_input = open('input.log', 'wb')
        dump_output = open('output.log', 'wb')
    else:
        dump_input = None
        dump_output = None

    isoSTED = IsoSTED(args)

    log_y = list()
    log_x = list()

    stop = False
    try:
        while not stop:
            conn, addr = sock.accept()
            print('accepted {}:{}'.format(addr[0], addr[1]))

            # use conventional pid controller sequence read() then write()
            # TODO add Control-C and detect end from LabView

            def read_xml():
                return read_payload(
                    conn, debug=args.debug, dump=dump_input,
                    interpret=xml2dict.loads)

            def write_xml(dout):
                write_payload(
                    conn, dout, debug=args.debug, dump=dump_output,
                    interpret=xml2dict.dumps)

            def read_json():
                return read_payload(
                    conn, debug=args.debug, dump=dump_input,
                    interpret=json2dict.loads)

            def write_json(dout):
                write_payload(
                    conn, dout, debug=args.debug, dump=dump_output,
                    interpret=json2dict.dumps)

            isoSTED.read_xml = read_xml
            isoSTED.write_xml = write_xml
            isoSTED.read_json = read_json
            isoSTED.write_json = write_json

            isoSTED.initialise()
            control = apply_control(args.control, isoSTED, args)
            ndof = control.get_ndof()

            # first read is not used as fmin operates on write first
            # in the first stack measurements, the DM value is set by the
            # LabView VI
            isoSTED.read_stack()

            # nelder-mead first asks for f(0) (check this), so the second
            # recorded stack should correspond to the aberrated image or the
            # flat value set by Python
            def fun(x):
                control.write_settings(x)
                if args.printx:
                    print(x)

                stack = isoSTED.read_stack()[0]
                metric_val = compute_metric(args, isoSTED, log_x, log_y, stack)

                log_x.append(x.reshape((x.size, 1)))
                log_y.append(metric_val)

                plot_debug(
                    args,
                    isoSTED.log_din, isoSTED.log_dout,
                    log_x, log_y)

                return metric_val

            try:
                xopt = np.zeros((ndof,))
                for _ in range(args.repeat):
                    optres = num_min(
                        lambda x: fun(xopt + x), 0*xopt, isoSTED.h5f)
                    xopt += optres[0]
                    print(optres[1])

                stop = True

                # loop ends with read so must write back
                control.write_settings(xopt)

                # final read/write to apply the best value
                stack = isoSTED.read_stack()[0]
                metric_val = compute_metric(args, isoSTED, log_x, log_y, stack)
                log_x.append(xopt.reshape((xopt.size, 1)))
                log_y.append(metric_val)
                control.write_settings(xopt)

                # tell LabView to quit
                isoSTED.issue_stop()

            except LabViewStopException:
                print('Detected LabView Stop')
                stop = True
    except Exception as e:
        traceback.print_exc()
        raise e
    finally:
        # sock.shutdown(socket.SHUT_RDWR)
        if isoSTED.h5f:
            if len(log_x) > 0:
                isoSTED.h5f['log_x'] = np.hstack(log_x)
                isoSTED.h5f['log_y'] = np.array(log_y)
            isoSTED.close_logging()
        sock.close()

    return isoSTED.log_din, isoSTED.log_dout, log_y, log_x


def run_algorithm2(args):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    if sys.platform == 'linux':
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        sock.bind((args.host, args.port))
    except socket.error as err:
        print(
            'bind failed: {} {}'.format(str(err.args[0]), err.args[1]),
            file=sys.stderr)
        sys.exit(1)

    sock.listen(1)
    print('listening {}:{}'.format(args.host, args.port))

    if args.dump_files:
        dump_input = open('input.log', 'wb')
        dump_output = open('output.log', 'wb')
    else:
        dump_input = None
        dump_output = None

    isoSTED = IsoSTED(args)

    conn, addr = sock.accept()
    print('accepted {}:{}'.format(addr[0], addr[1]))

    # The LabView code implements the convetional (?) PID controller command
    # sequence. It starts with a read() command where a stack is acquired. That
    # is followed by a write() command where the DM and other hardware settings
    # can be updated. EVERY read command must be followed by a write.

    def read_xml():
        return read_payload(
            conn, debug=args.debug, dump=dump_input,
            interpret=xml2dict.loads)

    def write_xml(dout):
        write_payload(
            conn, dout, debug=args.debug, dump=dump_output,
            interpret=xml2dict.dumps)

    def read_json():
        return read_payload(
            conn, debug=args.debug, dump=dump_input,
            interpret=json2dict.loads)

    def write_json(dout):
        write_payload(
            conn, dout, debug=args.debug, dump=dump_output,
            interpret=json2dict.dumps)

    isoSTED.read_xml = read_xml
    isoSTED.write_xml = write_xml
    isoSTED.read_json = read_json
    isoSTED.write_json = write_json

    isoSTED.initialise()
    control = apply_control(args.control, isoSTED, args)

    # The first read is not used at all by any algorithm. It records a stack
    # with the state before Python gets in control. It was necessary since fmin
    # functions require a sequence of write then read commands.
    first_stack = isoSTED.read_stack()

    # At this point the algorithm must continue alternating write, read, write,
    # read and so forth. It ends with a read command, followed by a call to
    # close_fun() and a finally_fun() in the finally block.

    def close_fun(xopt):
        # the algorithm ends with a read so issue a write to LabView
        control.write_settings(xopt)

        # final read/write to apply and record the result when using xopt
        isoSTED.read_stack()
        control.write_settings(xopt)

        # tell LabView to quit
        isoSTED.issue_stop()

    def finally_fun():
        if isoSTED.h5f:
            isoSTED.close_logging()
        sock.close()

    return control, first_stack, close_fun, finally_fun


def add_labviewhandler_parameters(parser):
    parser.add_argument(
        '--host', type=str, default='localhost',
        help='Host name')
    parser.add_argument(
        '--port', type=int, default=8900,
        help='Port number')
    parser.add_argument(
        '--debug', action='store_true',
        help='Debug LabView-Python communication')
    parser.add_argument(
        '--dump-files', action='store_true',
        help='Save LabView-Python communication to disk')
    parser.add_argument(
        '--repeat', type=int, default=1, metavar='TIMES',
        help='Run the correction algorithm more than once (BROKEN)')
    parser.add_argument(
        '--printx', action='store_true',
        help='Print the variable under optimisation.')
    add_control_parameters(parser)
