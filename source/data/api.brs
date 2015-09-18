
'function to call api'
function apiParse(param as string) as object
	url = ""
	print "inside apiParse " type(param)
	url 	    = m.apiBaseURL + param
	urlObject   = CreateApiURLTransferObject(url)
	stringvalue = urlObject.getToString()
	json 	    = ParseJson(stringvalue)
	return json
end function


function getLiveMatches(param as string)
    print "inside get live matches"
    url = ""
    url         = m.apiBaseURL + "daylist?days=" + param
    urlObject   = CreateApiURLTransferObject(url)
    stringvalue = urlObject.getToString()
    json        = ParseJson(stringvalue)
    return json
end function

function getEvents(channelId as string,startTime as string,endTime as string)
    print "getting events"
    print "inside get live matches"
    url = ""
    url         = m.apiBaseURL + "event/" + channelId + "?start=" + startTime + "&end=" + endTime
    print "url = " url
    urlObject   = CreateApiURLTransferObject(url)
    stringvalue = urlObject.getToString()
    json        = ParseJson(stringvalue)
    return json
end function

function getEpisode(slug as string)
print "inside getEpisode"
url = ""
url = m.apiBaseURL + "Video/" + slug
urlObject = CreateApiURLTransferObject(url)
stringvalue = urlObject.getToString()
json = ParseJson(stringvalue)
return json
end function