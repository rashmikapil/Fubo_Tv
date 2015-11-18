function loginScreen() As Void
    log("DEBUG", " loginScreen")

    m.Screen = CreateObject("roscreen",true,1280,720)
    m.loginPort = CreateObject("roMessagePort")
    m.Screen.setMessagePort(m.loginPort)
    m.Screen.Finish()

    m.loginScreenEventReq = Invalid
    log("DEBUG", "Analytics for Login Screen")
    uniqueDeviceID = createObject("roDeviceInfo").GetDeviceUniqueId()
    m.analytics = Analytics(uniqueDeviceID, m.segmentIOAPIKeyValue, m.loginPort)
    m.loginScreenEventReq = m.analytics.sendScreenEvent("Login Screen")

    m.focusButtonOne = true
    m.focusButtonTwo = false

    m.Screen.clear(&h0f0f0fff)
    m.Screen.SetAlphaEnable(true)
    m.logoHD         = CreateObject("roBitmap", "pkg:/assets/images/login_HD.png")
    m.logoSD         = CreateObject("roBitmap", "pkg:/assets/images/login_SD.png")
    m.activeButton   = CreateObject("roBitmap", "pkg:/assets/images/HighlightedOption310x46.png")
    m.inactiveButton = CreateObject("roBitmap", "pkg:/assets/images/Unhighlightedoption310x46.png")


    font_registry_Bold       = CreateObject("roFontRegistry")
    font_registry_Bold.Register("pkg:/fonts/Source_Sans_Pro/SourceSansPro-Bold.ttf")
    m.fontButtons         = font_registry_Bold.GetDefaultFont(20,true,false)

    m.Screen.DrawObject(0,0,m.logoHD)
    m.Screen.DrawObject(300,600,m.activeButton)
    m.Screen.DrawObject(650,600,m.inactiveButton)
    m.Screen.DrawText("START FREE TRIAL", 360, 613, &hffffffff, m.fontButtons)
    m.Screen.DrawText("LOGIN",770,613, &hA4A4A4ff, m.fontButtons)


    m.Screen.SwapBuffers()
    m.Screen.finish()
    eventloop()
end function

function eventloop()
    log("DEBUG", " Eventloop of Login Screen")
    response = {}
    loginEvent = true
    login = false
    while loginEvent
        msg = wait(0, m.Screen.GetMessagePort())
        if type(msg) = "roUniversalControlEvent" then
            key = msg.GetInt()
            if key = 5
                print "key presssed " key
                m.Screen.DrawObject(0,0,m.logoHD)
                m.Screen.DrawObject(300,600,m.inactiveButton)
                m.Screen.DrawObject(650,600,m.activeButton)
                m.Screen.DrawText("START FREE TRIAL", 360, 613, &hA4A4A4ff, m.fontButtons)
                m.Screen.DrawText("LOGIN",770,613, &hffffffff, m.fontButtons)
                m.Screen.SwapBuffers()
                m.Screen.finish()

            else if key = 4
                print "key presssed " key
                m.Screen.DrawObject(0,0,m.logoHD)
                m.Screen.DrawObject(300,600,m.activeButton)
                m.Screen.DrawObject(650,600,m.inactiveButton)
                m.Screen.DrawText("START FREE TRIAL", 360, 613, &hffffffff, m.fontButtons)
                m.Screen.DrawText("LOGIN",770,613, &hA4A4A4ff, m.fontButtons)
                m.Screen.SwapBuffers()
                m.Screen.finish()

            else if key = 0
                print "key presssed " key
                m.exitListScreenFlag = true
                m.loginExit = true
                m.rokuPollFlag = false
                m.linkStatus = false
                m.regScreenFlag = false
                m.screen = invalid
                exit while
            else if key = 6
                print "key presssed " key
                m.regScreenFlag = true
                exit while
            end if
        else if type(msg) = "roUrlEvent" then
            if m.loginScreenEventReq <> Invalid and msg.getSourceIdentity() = m.loginScreenEventReq.getIdentity()  then
                if msg.getResponseCode() = 200 then
                    result = msg.getString()
                    response = ParseJSON(result)
                    if response <> invalid AND NOT response.DoesExist("success")
                        log("DEBUG", " Error Submitting Analytics to Segment.IO  ")
                    end if
                else
                    log("DEBUG", " LoginScreen POST Call Unsuccessfull ")
                end if
                m.loginScreenEventReq = Invalid
            else
                log("DEBUG", " Invalid LoginScreen Event  ")
            end if
        end if
    end while
    if m.regScreenFlag = true
        doRegistration()
    end if
end function





