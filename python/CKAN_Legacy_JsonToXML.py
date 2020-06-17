import urllib3
import json
import codecs
import sys
import json
import traceback
import getopt
import numbers
import JsonToXML
import os
import shutil

from optparse import OptionParser
from xml.dom.minidom import Document

# Get data source link from input
usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--uri", action="store", dest="URI", help="uri of all metadata in JSON, e.g. https://www.opengov.nsw.gov.au/publication.json")
parser.add_option("--outputDirectory", action="store", dest="outputDirectory", help="file name for output")
parser.add_option("--splitElement", action="store", dest="splitElement", help="repeating element within paginated search, on which to split, e.g. results")

(options, args) = parser.parse_args()

# Validate data source uri
if not(options.URI):
    parser.error("Requires URI.  Try --help for usage")
    sys.exit(-1)

if len(options.URI) < 1:
    parser.error("Requires URI.  Try --help for usage")
    sys.exit(-1)

if not(options.outputDirectory):
    parser.error("Requires directory name for output.  Try --help for usage")
    sys.exit(-1)

if len(options.outputDirectory) < 1:
    parser.error("Requires directory for output.  Try --help for usage")
    sys.exit(-1)

if (options.splitElement):
   splitElement = options.splitElement
else:
    splitElement = None


dataSetUri = options.URI
outputDirectory = options.outputDirectory

print("OutputDirectory directory requested: " + outputDirectory)

fullDirectoryPath = outputDirectory + '/' + 'Records'
if os.path.exists(fullDirectoryPath):
    shutil.rmtree(fullDirectoryPath)
os.makedirs(fullDirectoryPath)

print("Created full directory path %s? %s " % (fullDirectoryPath, os.path.exists(fullDirectoryPath)))


print("Out directory: %s" % outputDirectory)
#JsonToXML.writeXmlFromJson(dataSetUri, outputFile, 'results') #split xml output on element 'results' so that we get a file per record within page retrieved)
JsonToXML.writeXmlFromJson(dataSetUri, 'search', fullDirectoryPath, splitElement) #split xml output on element 'results' so that we get a file per record within page retrieved)
