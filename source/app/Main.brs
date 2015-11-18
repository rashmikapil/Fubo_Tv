function main()
    log("DEBUG", " Main Function")
    Config()
    setDateime()
    rokuAppBaseScreen()
 end function

function rokuAppBaseScreen()
    log("DEBUG", " rokuAppBaseScreen")

    m.mainAppScreen = CreateObject("roCodeRegistrationScreen")
    rokuLinkStatus = readLinkStatus("linked")

    if rokuLinkStatus = "true"
    else
        m.mainAppScreen.show()
    end if
    ' deleteLinkStatus("token")
    ' deleteLinkStatus("refresh")
    ' deleteLinkStatus("linked")
'
    appTimer = CreateObject("roTimespan")
    appTimer.mark()
    while  m.appExitStatus = false

        print "appTimer Total Duration is" appTimer.TotalSeconds()
        if appTimer.TotalSeconds() > m.refreshTokenExpiryTime then
            if m.linkStatus = true then
                retrieveRequest = getRefreshToken(m.port)
                appTimer.mark()
            end if
        end if

        rokuLinkStatus = readLinkStatus("linked")

        if rokuLinkStatus = "true"
            if m.exitListScreenFlag = true
                ShowMessage()
            else
                proStatus  = checkForProUserStatus()
                if proStatus = true then
                    log("INFO","linked true")
                    if m.appInitStatus = false
                        initializeApplication()
                    end if
                    m.mainAppScreen.show()
                    listingScreen()
                else
                    loginScreen()
                end if
            end if
        else
            if m.loginExit = true
                m.mainAppScreen.show()
                ShowMessage()
            else
                loginScreen()
            end if
        end if

    end while
 end function

