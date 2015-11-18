
Function doRegistration() As object
    log("DEBUG", " doRegistration")

    m.isLinked = false
    retryInterval = 0
    retryDuration = 0
    m.RegToken = getPreregistration()
    regscreen = displayRegistrationScreen()
    m.regCode = m.RegToken.code
    m.linkStatus = true
    exitRegistration = true
    login = false
    rokuLink = false

    if valid(m.regCode)
        regscreen.SetRegistrationCode(m.regCode)
    end if

    while exitRegistration
        if valid(m.retry)
            retryInterval = m.interval
            retryDuration = m.retry
        end if
        duration = 0
        sn = GetDeviceESN()
        if m.regCode = "" then return 2

        while m.linkStatus
	        m.rokuPollFlag = true
            response = Invalid
            if valid(m.regCode)
                response = getlink(sn,m.regCode)
            end if
            if valid(response)
            print "link response " response.token
                if response.status = "success"
                    sn = GetDeviceESN()
                    storeLinkStatus("linked", "true")
                    storeLinkStatus("token",response.token.access_token)
                    storeLinkStatus("refresh",response.token.refresh_token)
		            m.islinked = true
                    exitRegistration = false
                    m.userDetailsRequest = getUserDetails(m.regPort)

                    ' regscreen.close()
                    ' log("DEBUG", " Code Registration Screen Closed")
                    ' exit While
                end if
            end if

            getNewCode = false

            if m.clock.TotalSeconds() > retryDuration
                m.RegToken = getPreregistration()
                m.regCode = m.RegToken.code
                if valid(m.regCode)
                    regscreen.SetRegistrationCode(m.regCode)
                end if
                if valid(m.retry)
                    retryDuration = retryDuration + m.retry
                end if
            end if

            while true
                back = false
                msg = wait(retryInterval * 1000, m.regPort)
                duration = duration + retryInterval
                if msg = invalid exit while

                if type(msg) = "roCodeRegistrationScreenEvent" then
                    response = invalid
                    if msg.isScreenClosed()
                        log("INFO", " isScreenClosed Event of Code Registration Screen Invoked")
                        m.regScreenFlag = false
                        m.linkStatus = false
                        exitRegistration = false
                        m.rokuPollFlag = false
                        regscreen.close()
                        ' exit while
                    else if msg.isButtonPressed()
                        print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
                        if msg.GetIndex() = 0
                            regscreen.SetRegistrationCode("retrieving code...")
                            getNewCode = true
                            exit while
                        endif
                        if msg.GetIndex() = 1 'return response
                            m.linkStatus = false
                            exitRegistration = false
                            m.islinked = false
                            regscreen.close()
                        end if
                    endif
                else if type(msg) = "roUrlEvent" then
                    if m.codeRegScreenEventReq <> Invalid and msg.getSourceIdentity() = m.codeRegScreenEventReq.getIdentity()  then
                        if msg.getResponseCode() = 200 then
                            result = msg.getString()
                            response = ParseJSON(result)
                            if response <> invalid AND NOT response.DoesExist("success")
                                log("DEBUG", " Error Submitting Analytics to Segment.IO  ")
                            end if
                        else
                            log("DEBUG", " Code Registration POST Call Unsuccessfull ")
                        end if
                        m.codeRegScreenEventReq = Invalid
                    else if  m.userDetailsRequest <> Invalid and msg.getSourceIdentity() = m.userDetailsRequest.getIdentity()  then
                        log("DEBUG", " User Details POST Call Loop Check ")
                        if msg.getResponseCode() = 200 then
                                result = msg.getString()
                                print msg.getResponseCode()
                                userDetails = ParseJson(result)
                                userStatus = populateUserDetails(userDetails)
                                if userStatus = False then
                                    m.islinked = false
                                    m.linkStatus = false
                                    exitRegistration = false
                                    storeLinkStatus("linked", "false")
                                    regscreen.close()
                                    showErrorMessageDialog("Please register as a Pro user")
                                end if
                        else
                            log("DEBUG", " RETRIEVE USER DETAILS POST UNSUCCESSFULL ")
                        end if
                        m.userDetailsRequest = Invalid
                        traits = {
                            email: m.emailId,
                            userId: m.userId
                        }
                        log("INFO", "Analytics for Roku Linked Track Event")
                        m.analytics = Analytics(m.userId, m.segmentIOAPIKeyValue, m.regPort)
                        m.rokuLinkedEventReq = m.analytics.sendRokuLinkedTrackEvent("Roku Linked", traits)
                    else if m.rokuLinkedEventReq <> Invalid and msg.getSourceIdentity() = m.rokuLinkedEventReq.getIdentity()  then
                        checkPostResponse(msg)
                        m.rokuLinkedEventReq = Invalid
                        log("DEBUG", " Code Registration Screen Closed")
                        regscreen.close()
                    else
                        log("DEBUG", " Invalid POST Event Request Event  ")
                    end if
                end if

            end while

            if duration > retryDuration  exit while
                if getNewCode
                    m.RegToken = getPreregistration()
                    m.regCode = m.RegToken.code
                    if valid(m.regCode)
                        regscreen.SetRegistrationCode(m.regCode)
                    end if
                end if
            log("INFO", " poll prelink again...")
        end while
    end while
    if m.islinked = true
        ' m.screen = invalid
        showErrorMessageDialog("Congratulations! You have successfully linked your Roku device")
    end if

End Function

Function displayRegistrationScreen() As Object
    log("DEBUG", " displayRegistrationScreen")

    regscreen = CreateObject("roCodeRegistrationScreen")
    m.regPort = CreateObject("roMessagePort")
    regscreen.SetMessagePort(m.regPort)

    regscreen.SetTitle("")
    regscreen.AddFocalText("Go to www.fubo.tv/roku and enter the code below","spacing-dense")
    regscreen.AddFocalText(" ", "spacing-dense")
    regscreen.AddFocalText("This screen should update automatically once you link", "spacing-dense")
    regscreen.AddFocalText(" ", "spacing-dense")
    regscreen.AddFocalText("your device.", "spacing-dense")
    regscreen.AddFocalText(" ", "spacing-dense")
    regscreen.SetRegistrationCode("retreiving code...")
    regscreen.AddButton(0, "Get a new code")
    regscreen.AddButton(1, "Back")
    regscreen.Show()

    m.userDetailsRequest = Invalid
    m.rokuLinkedEventReq = Invalid
    m.userDetailsRequest = Invalid


    log("INFO", "Analytics for Code Registration Screen")
    uniqueDeviceID = createObject("roDeviceInfo").GetDeviceUniqueId()
    m.analytics = Analytics(uniqueDeviceID, m.segmentIOAPIKeyValue, m.regPort)
    m.codeRegScreenEventReq = Invalid
    m.codeRegScreenEventReq = m.analytics.sendScreenEvent("Roku Registration Screen")

    return regscreen

End Function


