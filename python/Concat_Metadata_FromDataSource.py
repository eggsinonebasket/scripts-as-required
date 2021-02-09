###############################################################################################################################
#
# usage: python Concat_RIF-CS_FromDataSource.py --input http://portal.auscope.org/geonetwork/srv/env/oaipmh --metadataPrefix
#
# Process:
# Takes OAI-PMH data source original link e.g. http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh
# Loads as http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh?verb=ListRecords&metadataPrefix={metadataPrefix}
# Writes starting root node metadata to output file
# Reads resumption token value at end of file 
# Loads next uri as http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh?verb=ListRecords&resumptionToken={resumptionTokenValue}
# Continues, loading all files until no more resumption token
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

###############################################################################################################################
#
# Methods
# 
###############################################################################################################################

def retrieveXML(count, filePath, uri):
  assert(uri is not None)

  
  print (count)
  try:
    print(uri)
    http = urllib3.PoolManager()
    print("Opening uri %s" % uri.encode())
    r = http.request('GET', uri)
    result = r.data
  except Exception as e:
      print("Unable to open uri %s - exception: %s" % (uri.encode(), e))
      sys.exit(-1)
    
  assert(result != 0)

  try:
    assert (result != 0)
    doc = parseString(result)
    assert (doc != 0)

  except Exception as e:
    print("Error: Unable to parse xml at uri %s - exception: %s" % (uri, e))
    return None
    
  assert(doc is not None)
  errors = doc.getElementsByTagName("error")
  for error in errors:
    assert(error is not None)
    print("Error: %s" % error.nodeValue)

  try:
    filePath=filePath+('%d.xml' % count)
    print(filePath)
    outFile = codecs.open(filePath, 'w')
  except Exception as e:
      print("Unable to open file %s - exception: %s" % (filePath, e))
      sys.exit(-1)
  
  #outFile.write(doc.toprettyxml(indent="  ", encoding="utf-8"))
  outFile.write(doc.toprettyxml(indent="  "))
  outFile.close()
  
  resumptionTokenList = doc.getElementsByTagName('resumptionToken')
  assert(resumptionTokenList.length <= 1)
  if(resumptionTokenList.length == 1):
    if(resumptionTokenList.item(0).firstChild != None):
      if(resumptionTokenList.item(0).firstChild.nodeType == Node.TEXT_NODE):
        print("Resumption token data: %s" % resumptionTokenList.item(0).firstChild.data)
        return resumptionTokenList.item(0).firstChild.data

  print("No resumption token provided - end of records")
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
            print ('please enter y or n.')
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
parser.add_option("--input", action="store", dest="data_source_uri", help="uri of OAI-PMH data source, e.g. http://spatial-dev.ala.org.au/geonetwork/srv/en/oaipmh")
parser.add_option("--operation", action="store", dest="operation", help="operation - if not provided, ListRecords will be used")
parser.add_option("--metadata_prefix", action="store", dest="metadata_prefix", help="metadata prefix, e.g. 'rif' or 'oai_dc' or 'iso19139.anzlic' or 'iso19139.mcp' ")
parser.add_option("--set", action="store", dest="set", help="set to narrow down what is to be retrieved' ")
parser.add_option("--output_directory", action="store", dest="output_directory", help="directory to write output to, e.g. 'AIMS'")

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

if ((options.operation == 'ListRecords') or ((options.operation == None) or (len(options.operation) < 1))) and ((options.metadata_prefix == None) or (len(options.metadata_prefix) < 1)):
    parser.error("Requires metadata_prefix because ListRecords will be called - override ListRecords with --operation.  Try --help for usage")
    sys.exit(-1)

if not options.output_directory:
    parser.error("Requires output directory.  Try --help for usage")
    sys.exit(-1)

if len(options.output_directory) < 1:
    parser.error("Requires output directory.  Try --help for usage")
    sys.exit(-1)

if ((options.operation == None) or (len(options.operation) < 1)):
    operation = 'ListRecords'
else:
    operation = options.operation

metadataPrefix = options.metadata_prefix
dataSourceURI = options.data_source_uri
outputDirectory = options.output_directory
subset = options.set

def requestURI(dataSourceURI, subset, metadataPrefix):
  path = ""
  if len(dataSourceURI) > 0:
    path = dataSourceURI+"?verb="+operation

  if (subset is not None) and (len(subset) > 0):
    path = path+"&set="+subset

  if ((metadataPrefix != None) and (len(metadataPrefix) > 0)):
    path = path+"&metadataPrefix="+metadataPrefix
    
  return path

###############################################################################################################################
#
# Processing
# 
###############################################################################################################################

#if os.path.exists(outputDirectory):
  #    if(confirm("Remove and recreate directory "+outputDirectory+" and all of its contents")):
  #    shutil.rmtree(outputDirectory)
  #else:
#    sys.exit(-1)

if os.path.exists(outputDirectory):
    print("Removing existing directory " + outputDirectory)
    shutil.rmtree(outputDirectory)

print("Constructing directory "+outputDirectory)
os.makedirs(outputDirectory)


outFileName = ('ConcatMetadataTree')
filePath = outputDirectory + '/' + outFileName

count=0

requestURI = requestURI(dataSourceURI, subset, metadataPrefix)

resumptionToken = retrieveXML(count, filePath, requestURI)




while resumptionToken is not None:
  assert(len(resumptionToken) > 1)
  count=count+1
  resumptionToken = retrieveXML(count, filePath, dataSourceURI+"?verb="+operation+"&resumptionToken="+resumptionToken)

print("Output files written to directory %s" % outputDirectory)

