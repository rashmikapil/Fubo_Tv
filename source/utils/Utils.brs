
'******************************************************
'REM Constucts a URL Transfer object
'******************************************************

Function CreateApiURLTransferObject(url as String) as Object
    obj = CreateObject("roUrlTransfer")
    obj.SetPort(CreateObject("roMessagePort"))
    obj.SetUrl(url)
    obj.addHeader("Content-Type", "application/json; charset=utf-8")
    obj.setCertificatesFile("common:/certs/ca-bundle.crt")
    obj.initClientCertificates()
    obj.enableEncodings(true)
    obj.RetainBodyOnError(true)
    return obj
End Function

'******************************************************
'Convert anything to a string
'
'Always returns a string
'******************************************************

Function tostr(any)
    ret = AnyToString(any)
    if ret = invalid ret = type(any)
    if ret = invalid ret = "unknown" 'failsafe
    return ret
End Function


'******************************************************
'Replace substrings in a string. Return new string
'******************************************************

Function strReplace(basestr As String, oldsub As String, newsub As String) As String
    newstr = ""

    i = 1
    while i <= Len(basestr)
        x = Instr(i, basestr, oldsub)
        if x = 0 then
            newstr = newstr + Mid(basestr, i)
            exit while
        endif

        if x > i then
            newstr = newstr + Mid(basestr, i, x-i)
            i = x
        endif

        newstr = newstr + newsub
        i = i + Len(oldsub)
    end while

    return newstr
End Function

'******************************************************
'Walk an AA and print it
'******************************************************
Sub PrintAA(aa as Object)
    print "---- AA ----"
    if aa = invalid
        print "invalid"
        return
    else
        cnt = 0
        for each e in aa
            x = aa[e]
            PrintAny(0, e + ": ", aa[e])
            cnt = cnt + 1
        next
        if cnt = 0
            PrintAny(0, "Nothing from for each. Looks like :", aa)
        endif
    endif
    print "------------"
End Sub

'******************************************************
'Print an associativearray
'******************************************************
Sub PrintAnyAA(depth As Integer, aa as Object)
    for each e in aa
        x = aa[e]
        PrintAny(depth, e + ": ", aa[e])
    next
End Sub

'*************************************************************
'try to convert an object to a string. return invalid if can't
'*************************************************************
Function AnyToString(any As Dynamic) As dynamic
    if any = invalid return "invalid"
    if isstr(any) return any
    if isint(any) return itostr(any)
    if isbool(any)
        if any = true return "true"
        return "false"
    endif
    if isfloat(any) return Str(any)
    if type(any) = "roTimespan" return itostr(any.TotalMilliseconds()) + "ms"
    return invalid
End Function

'******************************************************
'isstr
'
'Determine if the given object supports the ifString interface
'******************************************************
Function isstr(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifString") = invalid return false
    return true
End Function

'******************************************************
'isbool
'
'Determine if the given object supports the ifBoolean interface
'******************************************************
Function isbool(obj as dynamic) As Boolean
    if valid(obj) = false return false
    if GetInterface(obj, "ifBoolean") = invalid return false
    return true
End Function


'******************************************************
'itostr
'
'Convert int to string. This is necessary because
'the builtin Stri(x) prepends whitespace
'******************************************************
Function itostr(i As Integer) As String
    str = Stri(i)
    return strTrim(str)
End Function


'******************************************************
'islist
'
'Determine if the given object supports the ifList interface
'******************************************************
Function islist(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifArray") = invalid return false
    return true
End Function


'******************************************************
'isint
'
'Determine if the given object supports the ifInt interface
'******************************************************
Function isint(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifInt") = invalid return false
    return true
End Function

'******************************************************
' validstr
'
' always return a valid string. if the argument is
' invalid or not a string, return an empty string
'******************************************************
Function validstr(obj As Dynamic) As String
    if isnonemptystr(obj) return obj
    return ""
End Function


'******************************************************
'Trim a string
'******************************************************
Function strTrim(str As String) As String
    st=CreateObject("roString")
    st.SetString(str)
    return st.Trim()
End Function

function isFloat(item) as Boolean
    return type(item) = "Float" or type(item) = "roFloat"
end function

'******************************************************
'Tokenize a string. Return roList of strings
'******************************************************
Function strTokenize(str As String, delim As String) As Object
    st=CreateObject("roString")
    st.SetString(str)
    return st.Tokenize(delim)
End Function

function storeLinkStatus(key as String, value as String)
    registry = createObject("roRegistrySection", "SHOWREG")
    registry.write(key, value)
    registry.flush()
end function


function readLinkStatus(key as String) as Dynamic
    registry= createObject("roRegistrySection", "SHOWREG")
    if registry.exists(key)
        return registry.read(key)
    end if
    return invalid
end function

' Deletes a value from local storage
function deleteLinkStatus(key as String)
    registry = createObject("roRegistrySection", "SHOWREG")
    if registry.exists(key)
        registry.delete(key)
        registry.flush()
    end if
end function

function storePersistentValue(key as String, value as String)
    registry = createObject("roRegistrySection", "SHOWREG")
    registry.write(key, value)
    registry.flush()
end function


function readPersistentValue(key as String) as Dynamic
    registry= createObject("roRegistrySection", "SHOWREG")
    if registry.exists(key)
        return registry.read(key)
    end if
    return invalid
end function

function deletePersistentValue(key as String)
    registry = createObject("roRegistrySection", "SHOWREG")
    if registry.exists(key)
        registry.delete(key)
        registry.flush()
    end if
end function

'******************************************************
'Get our device version
'******************************************************

Function GetDeviceVersion()
    return CreateObject("roDeviceInfo").GetVersion()
End Function

'******************************************************
'Get our serial number
'******************************************************

Function GetDeviceESN()
    return CreateObject("roDeviceInfo").GetDeviceUniqueId()
End Function




