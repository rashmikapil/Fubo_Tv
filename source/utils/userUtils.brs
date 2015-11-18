Function populateUserDetails(userInfoDetails as Object)as Boolean
    log("INFO", " populateUserDetails")

    if userInfoDetails <> Invalid then
        proStatus  = True
        if valid (userInfoDetails) then
            if userInfoDetails.data.recurly.subscription.isPro = True then
                if valid (userInfoDetails.data.id )  then
                    m.userId = userInfoDetails.data.id
                else
                    m.userId  = "Anonymous User ID"
                end if

                if valid (userInfoDetails.data.email) then
                    m.emailId = userInfoDetails.data.email
                else
                    m.emailId  = "email@fubo.tv"
                end if

                if valid (userInfoDetails.data.givenName) then
                    m.firstName = userInfoDetails.data.givenName
                else
                    m.firstName ="FUBO"
                end if

                if valid (userInfoDetails.data.familyName) then
                    m.familyName = userInfoDetails.data.familyName
                else
                    m.familyName = "TV"
                end if

                if valid (userInfoDetails.data.recurly.subscription.plan.name) then
                    m.planName = userInfoDetails.data.recurly.subscription.plan.name
                else
                    m.planName = "fuboTV $66 Annual Plan"
                end if
            else
                proStatus  = False
            end if
        end if
        return proStatus
    else
        log("ERROR", " userInfoDetails Object is Invalid in populateUserDetails Function ")
    end if
End Function

Function checkForProUserStatus() as Boolean
    proStatus = True
    retrieveRequest    = getRefreshToken(m.port)
    userDetailsRequest = getUserDetails(m.port)

    while true
        msg = wait(0, m.port)
        if userDetailsRequest <> Invalid and msg.getSourceIdentity() = userDetailsRequest.getIdentity()  then
            if msg.getResponseCode() = 200 then
                result = msg.getString()
                userDetails = ParseJson(result)
                if userDetails.data.recurly.subscription.isPro = True then
                    proStatus = True
                    populateUserDetails(userDetails)
                else
                    proStatus = False
                end if
                exit While
            else
                log("DEBUG", " RETRIEVE PRO STATUS POST UNSUCCESSFULL ")
            end if
        end if
    end While

    if proStatus = false then
        m.mainAppScreen.show()
        showErrorMessageDialog("Please register as a Pro user")
    end if

    return proStatus

End Function

Function checkPostResponse(msg as Object)
    log("INFO", " checkPostResponse Function")

    if msg <> Invalid then
        if msg.getResponseCode() = 200 then
            result = msg.getString()
            response = ParseJSON(result)
            if response <> invalid AND NOT response.DoesExist("success")
                log("DEBUG", " Response of POST Call Unsuccessfull ")
            end if
        else
            log("ERROR", "  POST Call Unsuccessfull in Check Post Response ")
        end if
    else
        log("ERROR", " msg Object is Invalid in checkPostResponse Function ")
    end if

End function

Function ShowMessage() As Void
    log("INFO", " ShowMessage Function")

    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)
    dialog.EnableOverlay(false)
    dialog.SetTitle("QUIT FUBO TV")
    dialog.SetText("Do You Want to quit the application?")
    dialog.AddButton(1, "YES")
    dialog.AddButton(2, "NO")
    dialog.EnableBackButton(true)
    dialog.Show()
    appExit = false
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 1
                    m.appExitStatus = true
                    exit while
                else if dlgMsg.GetIndex() = 2
                    m.appExitStatus = false
                    m.loginExit = false
                    m.exitListScreenFlag = false
                    exit while
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while
    dialog.Close()
End Function

Function showErrorMessageDialog(title as String)
    log("DEBUG", " showErrorMessageDialog Function")

    if title <> Invalid then
        dialog = CreateObject("roOneLineDialog")
        dialog.EnableOverlay(true)
        dialog.SetTitle(title)
        dialog.Show()
        sleep(2000)
        dialog.Close()
    else
        log("ERROR", " Title Invalid in showErrorMessageDialog Function")
    end if
End function



