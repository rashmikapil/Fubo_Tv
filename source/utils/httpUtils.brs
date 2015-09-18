
'**********************************************************
'**  Video Player Example Application - URL Utilities 
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'**********************************************************
' The MIT License (MIT)
' 
' Copyright (c) 2009 Roku Inc.
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.

REM ******************************************************
REM Constucts a URL Transfer object
REM ******************************************************

Function CreateURLTransferObject(url As String, headerList as Object) as Object
    obj = CreateObject("roUrlTransfer")
    obj.SetPort(CreateObject("roMessagePort"))
    obj.SetUrl(url)
    obj.setHeaders({ Accept : "*/*" })
    'for https request
    if (headerList["Content-Type"]) = invalid then
        obj.addHeader("Content-Type", "text/plain; charset=utf-8")
    end if
    obj.setCertificatesFile("common:/certs/ca-bundle.crt")
    obj.addHeader("X-Roku-Reserved-Dev-Id", "")    
    
    for each header in headerList
        if isString(headerList[header]) then
            print "Header: " + header + ": " + headerList[header]
            obj.addHeader(header, headerList[header])
        else
            print "Invalid header"
            print header
        end if
    end for
    
    obj.initClientCertificates()
    obj.enableEncodings(true)
    return obj
End Function

Function CreateApiURLTransferObject(url as String) as Object
    obj = CreateObject("roUrlTransfer")
    obj.SetPort(CreateObject("roMessagePort"))
    obj.SetUrl(url)
    obj.AddHeader("Accept", "application/vnd.herotalkies-v1+json")
    obj.addHeader("Content-Type", "application/json; charset=utf-8")
    obj.setCertificatesFile("common:/certs/ca-bundle.crt")
    obj.initClientCertificates()
    obj.enableEncodings(true)
    obj.RetainBodyOnError(true)
    return obj
End Function


REM ******************************************************
REM Url Query builder
REM so this is a quick and dirty name/value encoder/accumulator
REM ******************************************************

Function HttpUtils(url As String, headerList = {}) as Object
    print ""
    print "-----"
    print "URL: "; url
    obj = CreateObject("roAssociativeArray")
    obj.Http                        = CreateURLTransferObject(url, headerList)
    obj.FirstParam                  = true
    obj.statusCode                  = -1
    obj.AddParam                    = http_add_param
    obj.AddRawQuery                 = http_add_raw_query
    obj.GetToStringWithRetry        = http_get_to_string_with_retry
    obj.PutToStringWithRetry        = http_put_to_string_with_retry
    obj.DeleteToStringWithRetry     = http_delete_to_string_with_retry
    obj.GetToFileWithRetry          = http_get_to_file_with_retry
    obj.GetToFileWithoutRetry       = http_get_to_file_without_retry
    obj.PrepareUrlForQuery          = http_prepare_url_for_query
    obj.GetToStringWithTimeout      = http_get_to_string_with_timeout
    obj.PostFromStringWithTimeout   = http_post_from_string_with_timeout
    obj.PostFromStringWithRetry     = http_post_from_string_with_retry
    obj.setUrl                      = http_set_url
    obj.getUrl                      = http_get_url
    obj.setPort                     = http_set_port
    obj.AddExtraParam               = http_add_extra_param
    obj.CancelAsync                 = http_cancel_async_request
    obj.getStatusCode               = http_get_status_code
    obj.setStatusCode               = http_set_status_code
    obj.headerList                  = headerList

    if Instr(1, url, "?") > 0 then obj.FirstParam = false

    return obj
End Function


REM ******************************************************
REM Constucts a URL Transfer object 2
REM ******************************************************

Function CreateURLTransferObject2(url As String, contentHeader As String) as Object
    obj = CreateObject("roUrlTransfer")
    obj.SetPort(CreateObject("roMessagePort"))
    obj.SetUrl(url)
    obj.AddHeader("Content-Type", contentHeader)
    obj.setCertificatesFile("common:/certs/ca-bundle.crt")
    obj.EnableEncodings(true)
    return obj
End Function

REM ******************************************************
REM Url Query builder 2
REM so this is a quick and dirty name/value encoder/accumulator
REM ******************************************************

Function HttpUtilsWithHeader(url As String, contentHeader As String) as Object
    obj = CreateObject("roAssociativeArray")
    obj.Http                        = CreateURLTransferObject2(url, contentHeader)
    obj.FirstParam                  = true
    obj.AddParam                    = http_add_param
    obj.AddRawQuery                 = http_add_raw_query
    obj.GetToStringWithRetry        = http_get_to_string_with_retry
    obj.GetToFileWithRetry          = http_get_to_file_with_retry
    obj.PrepareUrlForQuery          = http_prepare_url_for_query
    obj.GetToStringWithTimeout      = http_get_to_string_with_timeout
    obj.PostFromStringWithTimeout   = http_post_from_string_with_timeout
    obj.setUrl                      = http_set_url
    obj.getUrl                      = http_get_url
    obj.setPort                     = http_set_port
    obj.AddExtraParam               = http_add_extra_param
    obj.CancelAsync                 = http_cancel_async_request
    obj.getStatusCode               = http_get_status_code
    obj.setStatusCode               = http_set_status_code

    if Instr(1, url, "?") > 0 then obj.FirstParam = false

    return obj
End Function


REM ******************************************************
REM HttpEncode - just encode a string
REM ******************************************************

Function HttpEncode(str As String) As String
    o = CreateObject("roUrlTransfer")
    return o.Escape(str)
End Function

REM ******************************************************
REM Prepare the current url for adding query parameters
REM Automatically add a '?' or '&' as necessary
REM ******************************************************

Function http_prepare_url_for_query() As String
    url = m.Http.GetUrl()
    if m.FirstParam then
        url = url + "?"
        m.FirstParam = false
    else
        url = url + "&"
    endif
    m.Http.SetUrl(url)
    return url
End Function

REM ******************************************************
REM Percent encode a name/value parameter pair and add the
REM the query portion of the current url
REM Automatically add a '?' or '&' as necessary
REM Prevent duplicate parameters
REM ******************************************************

Function http_add_param(name As String, val As String) as Void
    q = m.Http.Escape(name)
    q = q + "="
    url = m.Http.GetUrl()
    if Instr(1, url, q) > 0 return    'Parameter already present
    q = q + m.Http.Escape(val)
    m.AddRawQuery(q)
End Function

REM ******************************************************
REM Tack a raw query string onto the end of the current url
REM Automatically add a '?' or '&' as necessary
REM ******************************************************

Function http_add_raw_query(query As String) as Void
    url = m.PrepareUrlForQuery()
    url = url + query
    m.Http.SetUrl(url)
End Function

REM ******************************************************
REM Performs Http.AsyncGetToString() in a retry loop
REM with exponential backoff. To the outside
REM world this appears as a synchronous API.
REM ******************************************************

Function http_get_to_string_with_retry(timeout=30000) as Object
    timeout%         = timeout
    num_retries%     = 3
    urlEvent = invalid

    str = ""
    errMsg = ""
    while num_retries% > 0
        if (m.Http.AsyncGetToString())
            event = wait(timeout%, m.Http.GetPort())
            if type(event) = "roUrlEvent"
                urlEvent = event
                m.setStatusCode(event.getResponseCode())
                str = event.GetString()
                exit while        
            elseif event = invalid
                m.Http.AsyncCancel()
                REM reset the connection on timeouts
                m.Http = CreateURLTransferObject(m.Http.GetUrl(), m.headerList)
                'timeout% = 2 * timeout%
            else
                print "roUrlTransfer::AsyncGetToString(): unknown event"
            endif
        endif

        num_retries% = num_retries% - 1
    end while

    if str = "" then
        errMsg = m.Http.GetFailureReason()
    end if

    return {
        errorMessage: errMsg
        responseString: str
        urlEvent: urlEvent
    }
End Function

Function http_put_to_string_with_retry(timeout=30000) as Object
    timeout%         = timeout
    num_retries%     = 3
    urlEvent = invalid

    str = ""
    m.Http.setRequest("PUT")
    while num_retries% > 0
        if (m.Http.AsyncGetToString())
            event = wait(timeout%, m.Http.GetPort())
            if type(event) = "roUrlEvent"
                urlEvent = event
                m.setStatusCode(event.getResponseCode())
                str = event.GetString()
                exit while        
            elseif event = invalid
                m.Http.AsyncCancel()
                REM reset the connection on timeouts
                m.Http = CreateURLTransferObject(m.Http.GetUrl(), m.headerList)
                'timeout% = 2 * timeout%
            else
                print "roUrlTransfer::AsyncGetToString(): unknown event"
            endif
        endif

        num_retries% = num_retries% - 1
    end while
    return {
        responseString: str
        urlEvent: urlEvent
    }
End Function

Function http_delete_to_string_with_retry(timeout=30000) as Object
    timeout%         = timeout
    num_retries%     = 3
    urlEvent = invalid

    str = ""
    m.Http.setRequest("DELETE")
    while num_retries% > 0
        if (m.Http.AsyncGetToString())
            event = wait(timeout%, m.Http.GetPort())
            if type(event) = "roUrlEvent"
                urlEvent = event
                m.setStatusCode(event.getResponseCode())
                str = event.GetString()
                exit while        
            elseif event = invalid
                m.Http.AsyncCancel()
                REM reset the connection on timeouts
                m.Http = CreateURLTransferObject(m.Http.GetUrl(), m.headerList)
                'timeout% = 2 * timeout%
            else
                print "roUrlTransfer::AsyncGetToString(): unknown event"
            endif
        endif

        num_retries% = num_retries% - 1
    end while
    return {
        responseString: str
        urlEvent: urlEvent
    }
End Function

REM ******************************************************
REM Performs Http.AsyncGetToFile() in a retry loop
REM with exponential backoff. To the outside
REM world this appears as a synchronous API.
REM return the tmp file name if the file is successfully downloaded
REM ******************************************************

Function http_get_to_file_with_retry(preferredTmpName="temp", preferredExt="m4a", timeout=60000) as String
    timeout%         = timeout
    num_retries%     = 3

    str = ""
    tmpFile = "tmp:/"+preferredTmpName+"."+preferredExt
    while num_retries% > 0
        if (m.Http.AsyncGetToFile(tmpFile))
            event = wait(timeout%, m.Http.GetPort())
            if type(event) = "roUrlEvent"
                m.setStatusCode(event.getResponseCode())
                str = tmpFile
                exit while        
            elseif event = invalid
                m.Http.AsyncCancel()
                REM reset the connection on timeouts
                m.Http = CreateURLTransferObject(m.Http.GetUrl(), m.Http.headerList)
                'timeout% = 2 * timeout%
            else
                print "roUrlTransfer::AsyncGetToString(): unknown event"
            endif
        endif

        num_retries% = num_retries% - 1
    end while
    
    return str
End Function

REM ******************************************************
REM Performs Http.AsyncGetToFile()
REM with exponential backoff. To the outside
REM world this appears as a synchronous API.
REM return the tmp file name if the file is successfully downloaded
REM ******************************************************

Function http_get_to_file_without_retry(preferredTmpName="temp", preferredExt="m4a", timeout=60000) as String

    str = ""
    tmpFile = "tmp:/"+preferredTmpName+"."+preferredExt
    while true
        if (m.Http.AsyncGetToFile(tmpFile))
            event = wait(timeout, m.Http.GetPort())
            if type(event) = "roUrlEvent"
                m.setStatusCode(event.getResponseCode())
                str = tmpFile
                exit while
            elseif event = invalid
                m.Http.AsyncCancel()
                exit while
            else
                print "roUrlTransfer::AsyncGetToString(): unknown event"
            endif
        endif
    end while
    print "str: " + str
    return str
End Function

REM ******************************************************
REM Performs Http.AsyncGetToString() with a single timeout in seconds
REM To the outside world this appears as a synchronous API.
REM ******************************************************

Function http_get_to_string_with_timeout(seconds as Integer) as Object
    timeout% = 1000 * seconds

    str = ""
    event = invalid
    
    m.Http.EnableFreshConnection(true) 'Don't reuse existing connections
    'm.Http.AsyncCancel()
    if (m.Http.AsyncGetToString())
        event = wait(timeout%, m.Http.GetPort())
        if type(event) = "roUrlEvent"
            m.setStatusCode(event.getResponseCode())
            str = event.GetString()
        else if event = invalid
            ' Dbg("AsyncGetToString timeout")
            m.Http.AsyncCancel()
        else
            ' Dbg("AsyncGetToString unknown event", event)
        endif
    endif
    return {
        responseString: str
        urlEvent: event
    }
End Function

REM ******************************************************
REM Performs Http.AsyncPostFromString() with a single timeout in seconds
REM To the outside world this appears as a synchronous API.
REM ******************************************************

Function http_post_from_string_with_timeout(val As String, seconds as Integer) as String
    timeout% = 1000 * seconds

    ' print "POST "; val

    str = ""
'    m.Http.EnableFreshConnection(true) 'Don't reuse existing connections
    if (m.Http.AsyncPostFromString(val))
        event = wait(timeout%, m.Http.GetPort())
        if type(event) = "roUrlEvent"
			'print "AsyncPostFromString: event: "; event
            m.setStatusCode(event.getResponseCode())
			'print "statuscode: "; event.getResponseCode()
            str = event.GetString()
        elseif event = invalid  
            'print "AsyncPostFromString timeout"
            m.Http.AsyncCancel()
        else
            print "AsyncGetToString unknown event"; event
        endif
    endif

    ' print "Response:"
    ' print str
    ' print ""

    return str
End Function

Function http_post_from_string_with_retry(val As String, timeout=5000) as String
    timeout%         = timeout
    num_retries%     = 3

    print "POST "; val

    str = ""
    while num_retries% > 0
        if (m.Http.AsyncPostFromString(val))
            event = wait(timeout%, m.Http.GetPort())
            if type(event) = "roUrlEvent"
                print "event.getResponseCode() "; event.getResponseCode()
                m.setStatusCode(event.getResponseCode())
                str = event.GetString()
                exit while        
            else if event = invalid
                m.Http.AsyncCancel()
                REM reset the connection on timeouts
                m.Http = CreateURLTransferObject(m.Http.GetUrl(), m.headerList)
            else
                print "roUrlTransfer::AsyncGetToString(): unknown event"
            endif
        endif

        num_retries% = num_retries% - 1
    end while

    print "Response:"
    print str
    print ""

    return str
End Function


REM ******************************************************
REM Set the url of http request
REM ******************************************************
Function http_set_url(url As String) as Void
    m.Http.SetUrl(url)
End Function

REM ******************************************************
REM Get the url of http request
REM ******************************************************
Function http_get_url() as String
    return m.Http.getUrl()
End Function

REM ******************************************************
REM Set message port
REM ******************************************************
Function http_set_port(port) as Void
    m.Http.setPort(port)
End Function

REM ******************************************************
REM Add extra parameter for the url link
REM ******************************************************
Function http_add_extra_param(name as String, value as String, symbol as String) as Boolean
    url = m.Http.getUrl()
    if url = invalid or url = ""
        return false
    end if
    
    url = url+symbol+name+"="+value
    m.Http.SetUrl(url)
    return true
End Function

REM ******************************************************
REM Cancel Async HTTP request
REM ******************************************************
function http_cancel_async_request() as Void
    m.http.AsyncCancel()
end function

function http_get_status_code() as Integer
    return m.statusCode
end function

function http_set_status_code(code as Integer) as Void
    m.statusCode = code
end function 

