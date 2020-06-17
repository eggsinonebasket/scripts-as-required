import urllib.request
import json
import io
import sys
import json
import traceback
import getopt
import numbers
import codecs
import os
#import exceptions
import shutil
from xml.dom.minidom import parseString, Document, DOMImplementation

def json2xml(json_obj, line_padding=""):
    result_list = list()

    json_obj_type = type(json_obj)

    if json_obj_type is list:
        for sub_elem in json_obj:
            result_list.append(json2xml(sub_elem, line_padding))

        return "\n".join(result_list)

    if json_obj_type is dict:
        for tag_name in json_obj:
            sub_obj = json_obj[tag_name]
            result_list.append("%s<%s>" % (line_padding, tag_name))
            result_list.append(json2xml(sub_obj, "\t" + line_padding))
            result_list.append("%s</%s>" % (line_padding, tag_name))

        return "\n".join(result_list)

    return "%s%s" % (line_padding, json_obj)


def parse_element(doc, root, j):
  if j is None:
    return
  if isinstance(j, dict):
    for key in j.keys():

      value = j[key]
      if isinstance(value, list):
        for e in value:
          keyFormatted = key.replace(' ', '_')
          elem = doc.createElement(keyFormatted)
          parse_element(doc, elem, e)
          root.appendChild(elem)
      else:
        if key.isdigit():
          elem = doc.createElement('item')
          elem.setAttribute('value', key)
        else:
          keyFormatted = key.replace(' ', '_')
          elem = doc.createElement(keyFormatted)
        parse_element(doc, elem, value)
        root.appendChild(elem)
  elif isinstance(j, list):
    #print("isinstance list of len ", len(j))
    print(j)
    for e in j:
        parse_element(doc, root, e)
  elif isinstance(j, str):
    #print("isinstance str ", j)
    text = doc.createTextNode(j)
    #print("created text node ", text.data)
    root.appendChild(text)
  elif isinstance(j, str):
    #print("isinstance str", j)
    text = doc.createTextNode(j)
    root.appendChild(text)
  elif isinstance(j, numbers.Number):
    text = doc.createTextNode(str(j))
    root.appendChild(text)
  else:
    raise Exception("unhandled type %s for %s" % (type(j), j,))

def createOneFilePerRecord(outputDirectory, domain, elem, start, splitElement):

    # domImplementation = DOMImplementation()


    # Create one file per record, with domain name and increment
    resultsList = elem.getElementsByTagName(splitElement)

    if(len(resultsList) == 0):
        raise Exception('splitElement ' + splitElement + ' not found - add element on which to split on as command parameter')

    for i in range(1, len(resultsList)):
        results = resultsList[i]

        obj_xml_rootRecordDocument = Document()
        rootRecord = obj_xml_rootRecordDocument.createElement('record')
        obj_xml_rootRecordDocument.appendChild(rootRecord)

        rootRecord.appendChild(results)

        recordFilename = str.format(outputDirectory + '/' + domain + '_' + str(i + start[0]) + '.xml')
        recordFile = open(recordFilename, 'w+')

        #recordFile.write(rootRecord.toprettyxml(encoding='utf-8', indent=' '))
        recordFile.write(rootRecord.toprettyxml(indent=' '))
        recordFile.close()
        print("This page of output split per record, and written to %s" % recordFilename)

def getCount(elem):

    # For ckan api
    count = 0
    countElementList = elem.getElementsByTagName('count')

    print('len(countElementList): %d' % len(countElementList))

    # For MAGDA api
    if (len(countElementList) == 0):
        hitCountList = elem.getElementsByTagName('hitCount')
        for val in hitCountList:
            print(val.parentNode.tagName)
            if(val.parentNode.tagName == 'datasets'):
                countElementList.append(val)

    if (len(countElementList) == 1):
        assert (len(countElementList[0].childNodes[0].data) > 0)
        count = int(countElementList[0].childNodes[0].data)

    return count

def process(rows, start, dataSetUri, dataSetName, outputDirectory, domain, splitElement, usePostfix):

    obj_xml_rootDocument = Document()
    root = obj_xml_rootDocument.createElement('root')

    obj_xml_rootDocument.appendChild(root)


    if (usePostfix > 0):
        postfix = str.format("&rows=" + str(rows) + "&start=" + str(start[0]))

    try:
        obj_addinfourl = urllib.request.urlopen(dataSetUri + postfix, timeout=5)
    except KeyboardInterrupt:
        print("Interrupted - ", sys.exc_info()[0])
        raise
    except:
        print("Exception %s when opening %s" % (sys.exc_info()[0], dataSetUri + postfix))
        raise

    print("Retrieved content at " + dataSetUri + postfix)
    assert (obj_addinfourl is not None)
    obj_json_str = (obj_addinfourl.read())
    # print(obj_json_str)
    assert (obj_json_str is not None)
    obj_dict = json.loads(obj_json_str)

    elem = obj_xml_rootDocument.createElement("datasets")
    parse_element(obj_xml_rootDocument, elem, obj_dict)

    root.appendChild(elem)

    #print(elem.toprettyxml())

    count = getCount(elem)

    print("Retrieved count %d " % count)

    # obj_StreamReaderWriter.write(obj_xml_Document.toprettyxml(encoding='utf-8', indent=' ')

    if (splitElement != None):
        print("splitElement: " + splitElement)
        createOneFilePerRecord(outputDirectory, domain, elem, start, splitElement)

    else:
        recordFilename = str.format(outputDirectory + '/' + domain + '_' + str(dataSetName) + '_' + str(start[0]) + '.xml')
        recordFile = open(recordFilename, 'w+')

        recordFile.write(obj_xml_rootDocument.toprettyxml(indent=' '))
        recordFile.close()
        print("This page of output all written to %s" % recordFilename)

    # outputFile.write(obj_xml_rootDocument.toprettyxml(encoding='utf-8', indent=' '))
    # print("All output appended to %s" % outFileName)

    start[0] = start[0] + 100
    print("start inside: ", start[0])
    print("Continuing to paginate on this same dataseturl if count (%d) greater than start (%d)  " % (count, start[0]))

    return count


def writeXmlFromJson(dataSetUri, dataSetName, outputDirectory, splitElement=None, usePostfix=1):

    postfix=""
    rows=99
    start = [int]
    start[0] = 0
    count = 100

    domImplementation = DOMImplementation()

    domain = str(dataSetUri.split("//")[-1].split("/")[0].split('?')[0])

    try:

        while(count > (start[0])):

            count = process(rows, start, dataSetUri, dataSetName, outputDirectory, domain, splitElement, usePostfix)
            print("count returned: ", count)
            print("start returned: ", start[0])

    except KeyboardInterrupt:
        print("Interrupted - ", sys.exc_info()[0])
        raise
    except:
        print("Exception - ", sys.exc_info()[0])
        #traceback.print_exc(file=sys.stdout)
        raise



  

    

        

       


