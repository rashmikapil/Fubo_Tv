
function apiParse(param as string) as object
	url = ""
	url 	    = m.apiBaseURL + param
	urlObject   = CreateApiURLTransferObject(url)
	stringvalue = urlObject.getToString()
	json 	    = ParseJson(stringvalue)
	return json
end function

function getEdgeAuth(param as string)
    url = ""
    url         = m.apiBaseURL + param
    urlObject   = CreateApiURLTransferObject(url)
    stringvalue = urlObject.getToString()
    json        = ParseJson(stringvalue)
    return json
end function

function UpcomingMatches()
    url = ""
    offset ="match/days/7"
    url         = m.apiBaseURL + offset
    urlObject   = CreateApiURLTransferObject(url)
    stringvalue = urlObject.getToString()
    json        = ParseJson(stringvalue)
    return json
end function

function getEvents(channelId as string)
    m.timer.mark()
    fromSeconds = m.timer.asSeconds()
    toSeconds = fromSeconds + 43200
    fromMiliSeconds = toStr(fromSeconds) + "000"
    toMiliSeconds = toStr(toSeconds) + "000"
    url = ""
    url         = m.apiBaseURL + "event/" + channelId + "?start=" + fromMiliSeconds + "&end=" + toMiliSeconds
    urlObject   = CreateApiURLTransferObject(url)
    stringvalue = urlObject.getToString()
    json        = ParseJson(stringvalue)
    return json
end function

function getEpisode(slug as string)
    url = ""
    url = m.apiBaseURL + "video/" + slug
    url = strReplace(url,"|","%7C")
    print "url = " url
    urlObject = CreateApiURLTransferObject(url)
    stringvalue = urlObject.getToString()
    json = ParseJson(stringvalue)
    return json
end function

function getChannelSlug(slug as string)
    url = ""
    url = m.apiBaseURL + "channel/" + slug
    urlObject = CreateApiURLTransferObject(url)
    stringvalue = urlObject.getToString()
    json = ParseJson(stringvalue)
    return json
end function

function requestData(messagePort as Object, url as String, method = "GET" as String, headers = [] as Object, postBody = "", fileName = "" ) as Object
    request = createObject("roUrlTransfer")
    request.setPort(messagePort)
    request.setUrl(url)
    request.setRequest(method)

    ' Add a default cert to enable HTTPS requests
    request.setCertificatesFile("common:/certs/ca-bundle.crt")
    request.initClientCertificates()
    request.enableCookies()
    request.enableFreshConnection(true)
    request.retainBodyOnError(true)

    if headers.count() <> 0 then
        if headers[0]  = "Refresh"
            refreshToken = readLinkStatus("refresh")
            value = ""
            value = "Bearer " + refreshToken
            request.addHeader("Authorization",value)

        else if headers[0]  = "DVR" or headers[0] = "ADD_DVR"
            token = readLinkStatus("token")
            value = ""
            value = "Bearer " + token
            request.addHeader("Authorization",value)
        else if headers[0]  = "USER" or headers[0] = "USER"
            token = readPersistentValue("token")
            value = ""
            value = "Bearer " + token
            request.addHeader("Authorization",value)
        end if
    end if

    if method = "GET" then
        if fileName <> "" then
            request.asyncGetToFile(fileName)
        else
            request.asyncGetToString()
        end if

    else if method = "POST" or method = "PUT" then
       log("DEBUG", " debug, post body :")
       print
       request.asyncPostFromString(postBody)
    end if
    return request
end function

function getRefreshToken(port as Object) as object
    log("DEBUG", " getRefreshToken")
    offset="refresh"
    signinRequest = requestData(port,  m.apiBaseURL+offset, "POST",["Refresh"])
    while true
        msg = wait(500,port)
            if type(msg) = "roUrlEvent" then
                if msg.getInt() = 1 then
                    if signinRequest <> Invalid and msg.getSourceIdentity() = signinRequest.getIdentity()  then
                        result = msg.getString()
                        print msg.getResponseCode()
                        value = ParseJson(result)
                        storePersistentValue("token",value.data.access_token)
                        storePersistentValue("refresh",value.data.refresh_token)
                        storePersistentValue("expireduration",value.data.expires_in.tostr())
                    exit while
                    end if
                end if
            end if
    end while
end function

function getMyDvr()
    log("DEBUG", " getMyDvr")
    offset="dvr"
    signinRequest = requestData(m.gridPort, m.apiBaseURL+offset, "GET",["DVR"])
        while true
            msg = wait(500,m.gridPort)
                if type(msg) = "roUrlEvent" then
                    if msg.getInt() = 1 then
                        if signinRequest <> Invalid and msg.getSourceIdentity() = signinRequest.getIdentity()  then
                            result = msg.getString()
                            print msg.getResponseCode()
                            value = ParseJson(result)
                        exit while
                    end if
                end if
            end if
        end while
        return value
  end function

function addDvr(eventId as string, oldId as string)
    log("DEBUG", " addDvr")

    offset="dvr?id="+eventId+"&force=true"
    offsetDvr ="dvr?id="+eventId+"&force=true&oldId="+oldId

    if oldId = "invalid" then
        signinRequest = requestData(m.detailPort, m.apiBaseURL+offset,"POST",["ADD_DVR"])
    else
        signinRequest = requestData(m.detailPort, m.apiBaseURL+offsetDvr,"POST",["ADD_DVR"])
    end if
    dvrFound = false

        while true
            msg = wait(500,m.detailPort)
                if type(msg) = "roUrlEvent" then
                    if msg.getInt() = 1 then
                        if signinRequest <> Invalid and msg.getSourceIdentity() = signinRequest.getIdentity()  then
                            result = msg.getString()
                            print msg.getResponseCode()
                            value = ParseJson(result)
                            if valid(value.data)
                                showErrorMessageDialog("DVR added to My DVR list")
                                setUpGrid()
                            else
                                message = ""
                                message = value.error.message
                                showErrorMessageDialog(message)
                            end if
                        exit while
                    end if
                end if
            end if
        end while
end function


function getPreregistration()
    log("DEBUG", " getPreregistration")

    offset="device/register"
    postbody = "deviceId="+m.deviceId
    signinRequest = requestData(m.loginPort, m.apiBaseURL+offset, "POST",[],postbody )
        while true
            msg = wait(500,m.loginPort)
                if type(msg) = "roUrlEvent" then
                    if msg.getInt() = 1 then
                        if signinRequest <> Invalid and msg.getSourceIdentity() = signinRequest.getIdentity()  then
                            result = msg.getString()
                            print msg.getResponseCode()
                            value = ParseJson(result)
                            m.code = value.code
                            m.retry = value.retryDuration
                            m.interval = value.retryInterval
                        exit while
                    end if
                end if
            end if
        end while
        return value
  end function


function getlink(deviceId as string, code as string)
    log("DEBUG", " getlink")

    offset="device/link"
    postbody = "code=" + code + "&deviceId="+deviceId
    signinRequest = requestData(m.regPort, m.apiBaseURL+offset,"POST",[],postbody)
        while m.rokuPollFlag
            msg = wait(500,m.regPort)
                if type(msg) = "roUrlEvent" then
                    if msg.getInt() = 1 then
                        if signinRequest <> Invalid and msg.getSourceIdentity() = signinRequest.getIdentity()  then
                            result = msg.getString()
                            if result <> ""
                                value = ParseJson(result)
                                if valid(value)
                                    if value.status = "success"
                                    end if
                                end if
                            end if
                        exit while
                    end if
                end if
            end if
        end while
        return value
  end function

function getUserDetails(port as object) as object
    log("DEBUG", " getUserDetails")
    offset="user"
    return requestData(port, m.apiBaseURL+offset, "GET",["USER"])
end function