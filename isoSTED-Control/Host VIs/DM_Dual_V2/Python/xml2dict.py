#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""xml2dict - convert a LabView XML into a Python dict and vice versa.

author: J. Antonello <jacopo.antonello@dpag.ox.ac.uk>
date: Tue Oct 18 09:30:05 BST 2016
"""

import xml.etree.ElementTree as ET
import numpy as np

from collections import OrderedDict
# from numpy import prod

from xml.dom.minidom import parseString


def loads(xmlstr):
    root = ET.fromstring(xmlstr)
    children = root.getchildren()

    numel = int(root.find('NumElts').text)
    children.remove(root.find('Name'))
    children.remove(root.find('NumElts'))
    assert(len(children) == numel)

    outd = OrderedDict()
    for child in children:
        if child.tag == 'Array':
            name = child.find('Name').text
            dims = [int(c.text) for c in child.findall('Dimsize')]

            chs = child.getchildren()
            chs.remove(child.find('Name'))
            for d in child.findall('Dimsize'):
                chs.remove(d)
            # if len(chs) != prod(dims):
            #     print(name)
            #     print(dims)
            #     print(chs)
            #     assert(False)

            tag = chs[0].tag
            payloads = [c.find('Val').text for c in chs]
            if len(payloads) == 1 and payloads[0] is None:
                payloads = []
            # if len(chs) > 0:
            #     payloads = [c.find('Val').text for c in chs]
            # else:
            #     newval = [None]

            if tag == 'U8':
                newval = np.fromstring(
                    ' '.join(payloads), sep=' ', dtype=np.uint8)
            elif tag == 'U16':
                newval = np.fromstring(
                    ' '.join(payloads), sep=' ', dtype=np.uint16)
            elif tag == 'U32':
                newval = np.fromstring(
                    ' '.join(payloads), sep=' ', dtype=np.uint32)
            elif tag == 'I8':
                newval = np.fromstring(
                    ' '.join(payloads), sep=' ', dtype=np.int8)
            elif tag == 'I16':
                newval = np.fromstring(
                    ' '.join(payloads), sep=' ', dtype=np.int16)
            elif tag == 'I32':
                newval = np.fromstring(
                    ' '.join(payloads), sep=' ', dtype=np.int32)
            elif tag == 'DBL':
                newval = np.fromstring(
                    ' '.join(payloads), sep=' ', dtype=np.float)
                # print(payloads)
                # newval = np.array([float(f) for f in payloads])
            elif tag == 'String':
                newval = payloads
            else:
                raise ValueError('No match for tag ' + tag + ' in Array')

            if isinstance(newval, np.ndarray):
                newval.shape = dims
            outd[name] = newval

        elif child.tag == 'String':
            outd[child.find('Name').text] = child.find('Val').text
        elif child.tag in ['I8', 'I16', 'I32', 'U8', 'U16', 'U32']:
            outd[child.find('Name').text] = int(child.find('Val').text)
        elif child.tag in ['DBL']:
            outd[child.find('Name').text] = float(child.find('Val').text)
        elif child.tag == 'Boolean':
            outd[child.find('Name').text] = bool(int(child.find('Val').text))
        elif child.tag == 'EW':
            name = child.find('Name').text
            val = int(child.find('Val').text)
            choices = [
                t.text for t in child.getchildren() if t.tag == 'Choice']
            outd[name] = {'Val': val, 'Choice': choices}
        else:
            raise ValueError('No match for tag ' + child.tag)

    return outd


def python2labview_type(a):
    if type(a) == str:
        return 'String'
    elif type(a) == bool:
        return 'Boolean'
    elif type(a) == int:
        return 'U32'
    elif type(a) == float:
        return 'DBL'
    elif isinstance(a, np.ndarray):
        if a.dtype == np.uint8:
            return 'U8'
        elif a.dtype == np.uint16:
            return 'U16'
        elif a.dtype == np.uint32:
            return 'U32'
        elif a.dtype == np.int8:
            return 'I8'
        elif a.dtype == np.int16:
            return 'I16'
        elif a.dtype == np.int32:
            return 'I32'
        elif a.dtype == np.float:
            return 'DBL'
        else:
            raise ValueError('No numpy match for type ' + str(type(a)))
    else:
        raise ValueError('No match for type ' + str(type(a)))


def dumps(outd):
    root = ET.Element('Cluster')
    ET.SubElement(root, 'Name').text = 'written cluster'
    ET.SubElement(root, 'NumElts').text = str(len(outd))

    for k, v in outd.items():
        if isinstance(v, dict):
            a = ET.SubElement(root, 'EW')
            ET.SubElement(a, 'Name').text = k
            ET.SubElement(a, 'Val').text = str(v['Val'])
            for sv in v:
                e = ET.SubElement(a, python2labview_type(sv))
        if isinstance(v, list):
            a = ET.SubElement(root, 'Array')
            ET.SubElement(a, 'Name').text = k
            ET.SubElement(a, 'Dimsize').text = str(len(v))
            for sv in v:
                e = ET.SubElement(a, python2labview_type(sv))
                ET.SubElement(e, 'Name').text = ''
                ET.SubElement(e, 'Val').text = str(sv)
        elif isinstance(v, np.ndarray):
            a = ET.SubElement(root, 'Array')
            ET.SubElement(a, 'Name').text = k
            for dim in v.shape:
                ET.SubElement(a, 'Dimsize').text = str(dim)
            for sv in v.ravel():
                e = ET.SubElement(a, python2labview_type(v))
                ET.SubElement(e, 'Name').text = 'number: 0 to 1'
                ET.SubElement(e, 'Val').text = str(sv)
        else:
            a = ET.SubElement(root, python2labview_type(v))
            ET.SubElement(a, 'Name').text = k
            if type(v) == bool:
                ET.SubElement(a, 'Val').text = str(int(v))
            else:
                ET.SubElement(a, 'Val').text = str(v)

    # thank you LabView!
    str1 = parseString(ET.tostring(root)).toprettyxml()
    str1 = str1.replace('\n', '\r\n').replace('<?xml version="1.0" ?>\r\n', '')
    str1 = str1.replace('\t', '')
    return str1.encode('utf-8')


def empty_like(outd):
    dempty = OrderedDict()
    for k, v in outd.items():
        if isinstance(v, np.ndarray):
            dempty[k] = np.zeros(shape=outd[k].shape, dtype=outd[k].dtype)
        elif isinstance(v, bool):
            dempty[k] = outd[k]
        else:
            dempty[k] = 0*outd[k]
    return dempty


if __name__ == '__main__':
    with open('dumpxml.xml', 'r') as f:
        xmlstr = f.read()
    outd = loads(xmlstr)
    print(outd)
    xmlstr2 = dumps(outd).decode('utf-8')
    with open('dumpxml2.xml', 'w') as f:
        f.write(xmlstr2)
