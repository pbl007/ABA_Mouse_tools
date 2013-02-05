'''
Created on Feb 5, 2013

@author: lior
'''
import urllib
import simplejson
import csv


def getValues(structureObject):
    multiStructure = []
    brainStructure = {}
    
    for dictObj in structureObject:
        if dictObj != 'children':
            brainStructure[dictObj] = structureObject[dictObj]
            
    multiStructure.append(brainStructure)
    for children in structureObject["children"]:
        multiStructure = multiStructure + getValues(children) 
        
    return multiStructure


if __name__ == '__main__':
    
    antologyUrl = 'http://api.brain-map.org/api/v2/structure_graph_download/1.json'
    #you can also use the ontlogyTree.json file
    jsonData = urllib.urlopen(antologyUrl)
    response = simplejson.load(jsonData)
    
    if response['success'] == True:
        ontology = response['msg']
        
        multiStructure = getValues(ontology[0])
                

        with open('ontology.csv','wb') as f: #Remember `newline=""` in Python 3.x
            w = csv.DictWriter(f, multiStructure[0].keys())
            w.writeheader()
            w.writerows(multiStructure)
