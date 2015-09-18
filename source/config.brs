
 Function initApi()
    m.apiBaseURL = "http://fubo-dev2.herokuapp.com/"   
    
    m.channels = apiParse("channel")
    m.liveMatches = apiParse("match")
    m.shows = apiParse("show")
    m.liveMatches = getLivematches("1")
  
    m.noScheduleText = "No schedule for this channel" 
    m.loadingDataErrorText = "No data"
    return m
 End Function

Function InitTheme() as void
    app = CreateObject("roAppManager")
    m.timer = CreateObject("roDateTime")
    
    backgroundColor             = "#F0F0F0"

    theme = {
        BackgroundColor: backgroundColor
        GridScreenMessageColor:   "#5B9BD5"
        GridScreenRetrievingColor: "#000000"
        GridScreenBackgroundColor: "#303030"
        GridScreenListNameColor: "#5B9BD5"
        SearchScreenBackgroundColor: "#111111"

    ' Color values work here
        GridScreenDescriptionTitleColor: "#5B9BD5"
        GridScreenDescriptionDateColor: "#000000"
        GridScreenDescriptionRuntimeColor: "#000000" '"#5B005B"
        GridScreenDescriptionSynopsisColor: "#000000"
    
    'used in the Grid Screen
        CounterTextLeft: "#5B9BD5"
        CounterSeparator: "#000000 "
        CounterTextRight: "#000000 "
    
        GridScreenOverhangSliceHD: "pkg:/assets/images/TopBarHD.png"
        GridScreenOverhangHeightHD: "100"
        GridScreenLogoOffsetHD_X: "0"
        GridScreenLogoOffsetHD_Y: "0"
        GridScreenBorderOffsetHD_X:"-20"
        GridScreenBorderOffsetHD_y:"-20"
        'GridScreenFocusBorderHD:"pkg:/images/border.png"

    
        GridScreenOverhangSliceSD: "pkg:/assets/images/TopBarSD.png"
        GridScreenOverhangHeightSD: "100"
        GridScreenLogoOffsetSD_X: "0"
        GridScreenLogoOffsetSD_Y: "0"

        OverhangSliceHD: "pkg:/assets/images/TopBarHD.png"
        OverhangHeightHD: "100"

        OverhangSliceSD: "pkg:/assets/images/TopBarSD.png"
        OverhangHeightHD: "100"

        ParagraphScreenBackgroundColor: "#F0F0F0"
        ParagraphBodyText: "#202020"
        ParagraphHeaderText: "#5B9BD5"

        SpringboardTitleText: "#5B9BD5"
        SpringboardGenreColor: "#000000"
        SpringboardRuntimeColor: "#000000"
        SpringboardSynopsisColor: "#000000"

    }
    app.SetTheme( theme )
End Function

function showErrorMessageDialog(title as String)    
    dialog = CreateObject("roOneLineDialog")
    dialog.SetTitle(title)
    dialog.Show()
    sleep(2000)
    dialog.Close()
    dialog = invalid
End function