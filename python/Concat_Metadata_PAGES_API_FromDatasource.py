###############################################################################################################################
#
# usage: python Concat_Metadadata_API_FromDataSource.py
# --input api url
# --output_directory path to directory
# --identifier_prefix PREFIX_FOR_ID
# --params required before start position, e.g. 'pagesize=1&page='
#
from optparse import OptionParser
from xml.dom.minidom import parse, Document, Node
import codecs
import sys
import os
import shutil
import urllib.request

###############################################################################################################################
#
# Methods
#
###############################################################################################################################

def retrieveXML(count, filePath, uri):
    assert (uri is not None)

    try:
        # proxy_handler = urllib.ProxyHandler({})
        # opener = urllib.build_opener(proxy_handler)
        # print("Opening uri: %s" % uri)
        # req = urllib.Request(uri)
        # req.add_header('Accept-Language', 'en-gb')
        # req.add_header('Accept', 'application/xml')
        # result = urllib.urlopen(req)
        print("Opening uri: %s" % uri)
        result = urllib.request.urlopen(uri, timeout=30)
    except Exception as e:
        print("Unable to open uri %s - exception: %s" % (uri, e))
        sys.exit(-1)

    assert (result != 0)

    try:
        doc = parse(result)
    except Exception as e:
        print("Error: Unable to parse xml at uri %s - exception: %s" % (uri, e))
        return None

    assert (doc is not None)
    errors = doc.getElementsByTagName("error")
    for error in errors:
        assert (error is not None)
        print("Error: %s" % error.nodeValue)

    try:
        filePath = filePath + ('_%d.xml' % count)
        outFile = codecs.open(filePath, 'w')
        print('Constructed file: ' + filePath)
    except Exception as e:
        print("Unable to open file %s - exception: %s" % (filePath, e))
        sys.exit(-1)

    outFile.write(doc.toprettyxml(indent="  "))
    outFile.close()

    print("Results written to %s" % filePath)

    searchResults = doc.getElementsByTagNameNS('*', 'count')
    assert (searchResults.length <= 1)
    if (searchResults.length == 1):
        print(searchResults.item(0).__class__.__name__)
        assert ((Node.ELEMENT_NODE == searchResults.item(0).nodeType))
        if (Node.ELEMENT_NODE == searchResults.item(0).nodeType):
            assert(searchResults.item(0).firstChild.nodeValue != None)
            print("count: %s" % searchResults.item(0).firstChild.nodeValue)
            return int(searchResults.item(0).firstChild.nodeValue)

    return None

###############################################################################################################################
#
# Options
#
###############################################################################################################################

usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--input", action="store", dest="data_source_uri",
                  help="uri of csw data source, e.g. http://catalogue.source.org.au/api")
parser.add_option("--output_directory", action="store", dest="output_directory",
                  help="directory to write output to, e.g. 'OUTPUT'")
parser.add_option("--identifier_prefix", action="store", dest="identifier_prefix",
                  help="oai identifier prefix (will be appended with incremented count)")
parser.add_option("--api_key", action="store", dest="api_key",
                  help="api key (will be applied to all calls)")
parser.add_option("--params", action="store", dest="params",
                  help="params to add before start position")


(options, args) = parser.parse_args()

###############################################################################################################################
#
# Validation
#
###############################################################################################################################

if not options.data_source_uri:
    parser.error("Requires data_source_uri.  Try --help for usage")
    sys.exit(-1)

if len(options.data_source_uri) < 1:
    parser.error("Requires data_source_uri.  Try --help for usage")
    sys.exit(-1)

if not options.output_directory:
    parser.error("Requires output directory.  Try --help for usage")
    sys.exit(-1)

if not options.params:
    parser.error("Requires params.  Try --help for usage")
    sys.exit(-1)

dataSourceURI = options.data_source_uri
outputDirectory = options.output_directory
identifierPrefix = options.identifier_prefix if options.identifier_prefix != None else 'ID'
params = options.params




###############################################################################################################################
#
# Processing
#
###############################################################################################################################

if os.path.exists(outputDirectory):
    print("Backup existing directory if it contains files (that's the only check - not comparing with possible existing back up directory or anything) " + outputDirectory)
    if os.listdir(outputDirectory): #contains files
        if os.path.exists(outputDirectory+'_BAK'):
            shutil.rmtree(outputDirectory+'_BAK') #remove BAK directory if exists
        shutil.copytree(outputDirectory, outputDirectory+'_BAK') #copy to BAK directory
        print("Back up created in " + outputDirectory+'_BAK')
    print("Removing existing directory " + outputDirectory)
    shutil.rmtree(outputDirectory)

print("Constructing directory " + outputDirectory)
os.makedirs(outputDirectory)

filePath = outputDirectory + '/' + identifierPrefix

count = 0

startPosition = 1
maxRecords = 1

while startPosition <= maxRecords:
    count = count + 1

    if not options.api_key:
        maxRecords = retrieveXML(count, filePath, dataSourceURI + "?" + str(params)  + str(startPosition))
    else:
        maxRecords = retrieveXML(count, filePath, dataSourceURI + "?apiKey=" + str(options.api_key) + "&" + str(params) + str(startPosition))


    startPosition = startPosition + 1


print("Output files written to directory %s" % outputDirectory)

