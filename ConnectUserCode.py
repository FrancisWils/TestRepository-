import json,httplibs 
import random
import numpy 

with open('Votes.csv', 'r') as file:

    data = file.read()
    votearray = data.splitlines()

file.close

for votes in votearray:
    
    connection = httplib.HTTPSConnection('api.parse.com', 443)
    connection.connect()

    post = 'POST'
    classname = '/1/classes/Votes'
    
    vote_value = votes.split(",")
    
    messageID = vote_value[0]
    userID = vote_value[1] 
    voteType = vote_value[2]
    
    Post = {"__type": "Pointer", "className":"Post", "objectId": messageID}
    User = {"__type": "Pointer", "className":"_User", "objectId": userID}

    connection.request(post, \
    classname, \
    json.dumps({"PostId" : messageID, "UserId" : userID, "Vote" : voteType, "Post" : Post, "User" : User}), \
    {"X-Parse-Application-Id": "SZHjevT3j3m0UHan9OurbdjNFrVlSkWuARZUFieI", \
    "X-Parse-REST-API-Key": "BdJsu7iVYyOEykyiLBvM7nOjoBODrqvxCDprftMY", \
    "Content-Type": "application/json"})
    
    results = json.loads(connection.getresponse().read()) 
    print results
