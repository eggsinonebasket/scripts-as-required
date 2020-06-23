###############################################################################################################################
#
# usage: python Concat_Metadadata_CSW_FromDataSource.py --output_directory GA_Output --input http://www.ga.gov.au/geonetwork/srv/en/csw?request=GetRecords&service=CSW&version=2.0.2&namespace=xmlns%28csw=http://www.opengis.net/cat/csw%29&resultType=results&outputSchema=http://www.isotc211.org/2005/gmd&outputFormat=application/xml&maxRecords=10&typeNames=csw:Record&elementSetName=full&constraintLanguage=CQL_TEXT&constraint_language_version=1.1.0
#
# Process:
# Takes CSW data source original link e.g. http://www.ga.gov.au/geonetwork/srv/en/csw
# Loads provided uri with appended "&startPosition=1&maxRecords=100" http://www.ga.gov.au/geonetwork/srv/en/csw?
#   request=GetRecords
#   &service=CSW
#   &version=2.0.2
#   &namespace=xmlns%28csw=http://www.opengis.net/cat/csw%29
#   &resultType=results
#   &outputSchema=http://www.isotc211.org/2005/gmd
#   &outputFormat=application/xml&maxRecords=10
#   &typeNames=csw:Record
#   &elementSetName=full
#   &constraintLanguage=CQL_TEXT
#   &constraint_language_version=1.1.0
#   &startPosition=1&maxRecords=100
# Writes starting root node metadata to output file
# Loads next uri as same as first but with appended:  &startPosition=101&maxRecords=100
# Continues, loading all files until no more records to retrieve
# Writes closing root node registryObjects to output file
#
# Output:
# ConcatMetadataTree.xml - xml that represents all metadata nodes from at original data source link
# Output will only be as well-formed as the input (no validation or correction is made)
#
###############################################################################################################################

from optparse import OptionParser
from xml.dom.minidom import parseString, Document, Node
import codecs
import urllib3
import sys
import os
import string
import shutil

#import urllib3.contrib.pyopenssl
#urllib3.contrib.pyopenssl.inject_into_urllib3()

import urllib3


###############################################################################################################################
#
# Methods
#
###############################################################################################################################

def retrieveXML(count, filePath, uri):
    assert (uri is not None)

    try:
        http = urllib3.PoolManager()
        print("Opening uri %s" % uri)
        r = http.request('GET', uri, headers={"Accept" : "text/html", "User-Agent" : "ARDC Assist"})
        result = r.data
    except Exception as e:
        print("Unable to open uri %s - exception: %s" % (uri, e))
        sys.exit(-1)

    assert (result != 0)

    try:
        assert (result != 0)
        doc = parseString(result)
        assert (doc != 0)
    except Exception as e:
        print("Error: Unable to parse xml at uri %s - exception: %s" % (uri, e))
        print(result)
        return None

    assert (doc is not None)
    errors = doc.getElementsByTagName("error")
    for error in errors:
        assert (error is not None)
        print("Error: %s" % error.nodeValue)

    try:
        filePath = filePath + ('%d.xml' % count)
        print(filePath)
        outFile = codecs.open(filePath, 'w')
    except Exception as e:
        print("Unable to open file %s - exception: %s" % (filePath, e))
        sys.exit(-1)

    outFile.write(doc.toxml())
    outFile.close()

    searchResults = doc.getElementsByTagName('csw:SearchResults')
    assert (searchResults.length <= 1)
    print("Search Results length: %d" % searchResults.length)
    if (searchResults.length == 1):
        resultsDict = {}
        resultsDict['numberOfRecordsMatched'] = int(searchResults.item(0).getAttribute('numberOfRecordsMatched'))
        resultsDict['numberOfRecordsReturned'] = int(searchResults.item(0).getAttribute('numberOfRecordsReturned'))
        resultsDict['nextRecord'] = int(searchResults.item(0).getAttribute('nextRecord'))
        return resultsDict

    return None


# Copied from http://code.activestate.com/recipes/541096-prompt-the-user-for-confirmation/
def confirm(prompt=None, resp=False):
    """prompts for yes or no response from the user. Returns True for yes and
    False for no.

    'resp' should be set to the default value assumed by the caller when
    user simply types ENTER.

    >>> confirm(prompt='Create directory (remove and create if it exists)?', resp=True)
    Create Directory? [y]|n:
    True
    >>> confirm(prompt='Create directory (remove and create if it exists)?', resp=False)
    Create Directory? [n]|y:
    False
    >>> confirm(prompt='Create directory (remove and create if it exists)?', resp=False)
    Create Directory? [n]|y: y
    True

    """

    if prompt is None:
        prompt = 'Confirm'

    if resp:
        prompt = '%s [%s]|%s: ' % (prompt, 'y', 'n')
    else:
        prompt = '%s [%s]|%s: ' % (prompt, 'n', 'y')

    while True:
        ans = raw_input(prompt)
        if not ans:
            return resp
        if ans not in ['y', 'Y', 'n', 'N']:
            print('please enter y or n.')
            continue
        if ans == 'y' or ans == 'Y':
            return True
        if ans == 'n' or ans == 'N':
            return False


###############################################################################################################################
#
# Options
#
###############################################################################################################################

usage = "usage: %prog [options] arg1"
parser = OptionParser(usage=usage)
parser.add_option("--input", action="store", dest="data_source_uri",
                  help="uri of csw data source, e.g. http://catalogue.aodn.org.au/geonetwork/srv/eng/csw")
parser.add_option("--output_directory", action="store", dest="output_directory",
                  help="directory to write output to, e.g. 'AIMS'")

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


dataSourceURI = options.data_source_uri
outputDirectory = options.output_directory


###############################################################################################################################
#
# Processing
#
###############################################################################################################################

if os.path.exists(outputDirectory):
    shutil.copytree(outputDirectory, outputDirectory+'bak')
    shutil.rmtree(outputDirectory)
print("Constructing directory " + outputDirectory)
os.makedirs(outputDirectory)

outFileName = ('ConcatMetadataTree')
filePath = outputDirectory + '/' + outFileName

count = 1
nextRecord = 1

numberOfRecordsReturned = None
numberOfRecordsMatched = None

while (numberOfRecordsReturned != 0):
    resultsDict = retrieveXML(count, filePath, dataSourceURI + "&startPosition=" + str(nextRecord))

    if resultsDict != None:
        numberOfRecordsMatched = resultsDict['numberOfRecordsMatched']
        print("numberOfRecordsMatched: %s" % resultsDict['numberOfRecordsMatched'])

        numberOfRecordsReturned = resultsDict['numberOfRecordsReturned']
        print("numberOfRecordsReturned: %s" % resultsDict['numberOfRecordsReturned'])

        nextRecord = resultsDict['nextRecord']
        print("nextRecord: %s" % resultsDict['nextRecord'])

        count = count + 1
    else:
        numberOfRecordsReturned = 0

print("Output files written to directory %s" % outputDirectory)

