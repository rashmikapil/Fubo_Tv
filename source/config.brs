
Function Config()

    m.apiBaseURL =  "https://api.fubo.tv/"
    m.LiveList = []
    m.noScheduleText = "No schedule for this channel"
    m.loadingDataErrorText = "No data"
    m.category = []
    m.emptyImage = "pkg:/assets/images/empty.png"
    m.deviceId = GetDeviceESN()

    'Segment IO Variables
    m.segmentIOAPIKeyValue = "jh2q6sqatv"
    m.geoData = Invalid

    'Flag Variables
    m.appExitStatus = false      ' App Exit Status Flag
    m.exitListScreenFlag = false ' List Screen Exit Flag
    m.regScreenFlag = false      ' Code Registration Screen Flag
    m.rokuPollFlag = false
    m.loginExit = false
    m.isLinked = false
    m.appInitStatus = false      'InitializeApplication Flag

    refreshTokenExpiryTime = readPersistentValue("expireduration")
    if valid (m.refreshTokenExpiryTime) then
        m.refreshTokenExpiryTime = int(refreshTokenExpiryTime)
    else
        m.refreshTokenExpiryTime = 60
    end if

    'Code Registration Variables
    m.linkStatus = true


    'Main Port'
    m.port   = CreateObject("roMessagePort")
    m.mainAppScreen = Invalid

    'Youbora Variables
    m.youboraInstance = invalid
    m.pingTime = invalid

    'Segment

    m.category = [
            {
            name    : "Channels"
            buttonArray : ["Watch", "Schedule", "DVR Match"]
            },

            {
             name    : "Live Matches"
             buttonArray : ["Watch", "DVR Match"]
            },

            {
             name     : "Upcoming Matches"
             buttonArray  : ["DVR Match"]
            },

            {
             name     : "MY DVR"
             buttonArray  :["Watch Your DVR"]
            },
    ]

    m.device = CreateObject("rodeviceinfo")
    m.timer = CreateObject("roDateTime")
    m.clock = CreateObject("roTimespan")

    InitTheme()

End Function

Function InitTheme()

    app = CreateObject("roAppManager")
    theme = {
        BackgroundColor: "#363636"
        GridScreenMessageColor:   "#5B9BD5"
        GridScreenRetrievingColor: "#DFE2EB"
        GridScreenBackgroundColor: "#363636"
        GridScreenListNameColor: "#FFFFFF"

        OverhangPrimaryLogoSD : "pkg:/assets/images/logo_SD.png"
        OverhangPrimaryLogoOffsetSD_X : "33"
        OverhangPrimaryLogoOffsetSD_Y : "20"
        OverhangPrimaryLogoHD : "pkg:/assets/images/logo_HD.png"
        OverhangPrimaryLogoOffsetHD_X : "50"
        OverhangPrimaryLogoOffsetHD_Y : "25"

    ' Color values work here
        GridScreenDescriptionTitleColor: "#F57C00"
        GridScreenDescriptionSynopsisColor: "#000000"
        GridScreenBorderOffsetHD : "(-5,-3)"
        GridScreenBorderOffsetSD : "(-3,-1)"
        GridScreenFocusBorderHD :"pkg:/assets/images/border.png"
        GridScreenFocusBorderSD :"pkg:/assets/images/border1.png"
        GridScreenLogoHD : "pkg:/assets/images/logo_HD.png"
        GridScreenLogoSD : "pkg:/assets/images/logo_SD.png"

    'used in the Grid Screen
        CounterTextLeft: "#F57C00"
        CounterSeparator: "#DFE2EB"
        CounterTextRight: "#F57C00"

        GridScreenOverhangSliceHD: "pkg:/assets/images/top_HD.png"
        GridScreenOverhangHeightHD: "100"
        GridScreenLogoOffsetHD_X: "50"
        GridScreenLogoOffsetHD_Y: "25"
        GridScreenBorderOffsetHD_X:"-20"
        GridScreenBorderOffsetHD_y:"-20"

        GridScreenOverhangSliceSD: "pkg:/assets/images/top_SD.png"
        GridScreenOverhangHeightSD: "55"
        GridScreenLogoOffsetSD_X: "33"
        GridScreenLogoOffsetSD_Y: "20"

        OverhangSliceHD: "pkg:/assets/images/top_HD.png"
        OverhangHeightHD: "100"

        OverhangSliceSD: "pkg:/assets/images/top_SD.png"
        OverhangHeightSD: "77"

        SpringboardTitleText: "#FFFFFF"
        'SpringboardGenreColor: "#FFFFFF"
        SpringboardActorsColor: "#DFE2EB"

        'SpringboardBackgroundColor : "#22262E"
        SpringboardButtonHighlightColor : "#DFE2EB"
        SpringboardButtonNormalColor : "#DFE2EB"
        SpringboardRuntimeColor: "#DFE2EB"
        SpringboardSynopsisColor: "#DFE2EB"
        SpringboardBreadcrumbTextrighst : "#DFE2EB"
        SpringboardBreadcrumbTextleft : "#DFE2EB"
    }
    app.SetTheme(theme)
End Function

