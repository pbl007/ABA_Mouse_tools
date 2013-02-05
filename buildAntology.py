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
    brainStructure["id"] = structureObject["id"]
    brainStructure["ontology_id"] = structureObject["ontology_id"]
    brainStructure["acronym"] = structureObject["acronym"]
    brainStructure["name"] = structureObject["name"]
    brainStructure["color_hex_triplet"] = structureObject["color_hex_triplet"]
    brainStructure["graph_order"] = structureObject["graph_order"]
    brainStructure["st_level"] = structureObject["st_level"]
    brainStructure["hemisphere_id"] = structureObject["hemisphere_id"]
     
    brainStructure["parent_structure_id"] = structureObject["parent_structure_id"]
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
#     "id": 997,
#     "atlas_id": -1,
#     "ontology_id": 1,
#     "acronym": "root",
#     "name": "root",
#     "color_hex_triplet": "FFFFFF",
#     "graph_order": 0,
#     "st_level": null,
#     "hemisphere_id": 3,
#     "parent_structure_id": null,
        
