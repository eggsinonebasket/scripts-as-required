import urllib3

import sys
import re
from xml.dom.minidom import parseString, Document, Node
import codecs
import os


#working
noConstraints = '''
    <csw:GetRecords 
        service="CSW"
        version="2.0.2"
        maxRecords="200"
        startPosition="1"
        resultType="results"
        outputFormat="application/xml"
        outputSchema="http://www.isotc211.org/2005/gmd"
        xmlns="http://www.opengis.net/cat/csw/2.0.2"
        xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
        xmlns:ogc="http://www.opengis.net/ogc"
        xmlns:ows="http://www.opengis.net/ows"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:dct="http://purl.org/dc/terms/"
        xmlns:gml="http://www.opengis.net/gml"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.opengis.net/cat/csw/2.0.2">
        <csw:Query typeNames="csw:Record">
            <ElementSetName typeNames="csw:Record">full</ElementSetName>
        </csw:Query>
    </csw:GetRecords>
    '''

queryTemplate = '''
    <csw:GetRecords 
        service="CSW"
        version="2.0.2"
        maxRecords="200"
        startPosition="{0}"
        resultType="results"
        outputFormat="application/xml"
        outputSchema="http://www.isotc211.org/2005/gmd"
        xmlns="http://www.opengis.net/cat/csw/2.0.2"
        xmlns:gmd="http://www.isotc211.org/2005/gmd" 
        xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
        xmlns:ogc="http://www.opengis.net/ogc"
        xmlns:ows="http://www.opengis.net/ows"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:dct="http://purl.org/dc/terms/"
        xmlns:gml="http://www.opengis.net/gml"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.opengis.net/cat/csw/2.0.2">
        <csw:Query typeNames="csw:Record">
            <ElementSetName typeNames="csw:Record">full</ElementSetName>
            <Constraint version="1.1.0">
                <ogc:Filter xmlns="http://http://www.opengis.net/ogc" xmlns:gmd="http://www.isotc211.org/2005/gmd">{1}</ogc:Filter>
            </Constraint>
        </csw:Query>
    </csw:GetRecords>
    '''

queryPropertyTemplate = '''
    <ogc:PropertyIsLike wildCard="*" singleChar="_" escapeChar="\">
    <ogc:PropertyName>{0}</ogc:PropertyName>
    <ogc:Literal>{1}</ogc:Literal>
    </ogc:PropertyIsLike>
    '''


def constructQuery(conditionDict):

    query = ""

    for key, paramList in conditionDict.items():
        if(len(conditionDict) > 1):
            query += str.format('<ogc:{0}>', key)
        for paramDict in paramList:
            print(type(paramDict))
            for param in paramDict.items():
                print(type(param))
                print(param)
            print(paramDict["name"])
            query += str.format(queryPropertyTemplate, paramDict["name"], paramDict["value"])

        if (len(conditionDict) > 1):
            query += str.format('</ogc:{0}>', key)

    return query


def dictFormatted(conditionDict):

    formatted = ""

    for key, paramList in conditionDict.items():
        formatted += str.format('{0}_', key)
        for params in paramList:
            formatted += str.format('{0}_{1}_', params["name"], params["value"])

    return formatted


def callCSW(cswUrl, conditionDict):

    startPosition = '1'
    fullQuery = None
    fileName = ""

    if (conditionDict != None):

        query = constructQuery(conditionDict)
        if(query == None):
            print("Unable to construct query")
            return

        fullQuery = queryTemplate.format(startPosition, query)
        print(fullQuery)
        conditionsOkForFileName = re.sub('[/:]', '_', dictFormatted(conditionDict))
        urlOkForFileName = re.sub('[/:]', '_', cswUrl)
        fileName = str.format('{0}{1}{2}', urlOkForFileName, conditionsOkForFileName, 'records.xml')

    else:
        fullQuery = noConstraints.format(startPosition)
        fileName = "all_records.xml"

    try:
        http = urllib3.PoolManager()
        print("Opening uri %s" % cswUrl)
        print("Query \n %s" % fullQuery)
        r = http.request('POST', cswUrl, body = fullQuery, headers = {'Content-Type': 'applicationa /xml'})
        result = r.data
    except Exception as e:
        print("Unable to open url %s - exception: %s" % (cswUrl, e))
        sys.exit(-1)

    assert (result != 0)


    try:
        assert (result != 0)
        doc = parseString(result)
        assert (doc != 0)
    except Exception as e:
        print("Error: Unable to parse xml at uri %s - exception: %s" % (cswUrl, e))
        return None

    assert (doc is not None)
    errors = doc.getElementsByTagName("error")
    for error in errors:
        assert (error is not None)
        print("Error: %s" % error.nodeValue)

    try:
        print(fileName)
        outFile = codecs.open(fileName, 'w')

    except Exception as e:
        print("Unable to open file %s - exception: %s" % (fileName, e))
        sys.exit(-1)

    #outFile.write(doc.toxml(encoding='utf-8'))
    outFile.write(doc.toxml())
    outFile.close()

    searchResults = doc.getElementsByTagName('csw:SearchResults')
    assert (searchResults.length <= 1)
    print("Search Results length: %d" % searchResults.length)
    if (searchResults.length == 1):
        print("numberOfRecordsMatched: %d" % int(searchResults.item(0).getAttribute('numberOfRecordsMatched')))

    print('Results written to ' + os.getcwd() + '/' + str(fileName))



def main():

    print(sys.argv[0])
    print(sys.argv[1])

    assert (len(sys.argv) == 2)
    assert (sys.argv[1] != None)

    url = sys.argv[1]

    callCSW(url, None)


if __name__ == "__main__":
    main()




