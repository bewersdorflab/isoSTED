#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""json2dict - convert a LabView JSON into a Python dict and vice versa.

author: J. Antonello <jacopo.antonello@dpag.ox.ac.uk>
date: Tue Oct 18 09:30:05 BST 2016
"""

import copy
import json
import numpy as np

from collections import OrderedDict


def loads(jsonstr):
    outd = json.loads(jsonstr, object_pairs_hook=OrderedDict)
    for k, v in outd.items():
        if (
                isinstance(v, list) and
                len(v) > 0 and
                type(v[0]) in [int, float, bool, list]):
            outd[k] = np.array(v)
    return outd


def dumps(outd):
    outd = copy.copy(outd)
    for k, v in outd.items():
        if isinstance(v, np.ndarray):
            outd[k] = v.tolist()
    return json.dumps(outd).encode('utf-8')


def empty_like(outd):
    dempty = OrderedDict()
    for k, v in outd.items():
        if isinstance(v, bool):
            dempty[k] = False
        else:
            dempty[k] = 0*v
        # if isinstance(v, np.ndarray):
        #     # dempty[k] = (0*v).tolist
        #     sh = list(v.shape)
        #     sh[-1] = 0
        #     dempty[k] = np.zeros(shape=sh, dtype=v.dtype)
        # else:
        #     dempty[k] = 0*outd[k]
    return dempty
