Function detailScreen(metaData as object,screentype as object)
    log("DEBUG", " detailScreen")

    m.detailPort = CreateObject("roMessagePort")
    detailscreen = CreateObject("roSpringboardScreen")
    detailscreen.SetMessagePort(m.detailPort)

    log("INFO", "Analytics for Details Screen")
    m.analytics = Analytics(m.userId, m.segmentIOAPIKeyValue, m.detailPort)
    m.detailsScreenEventReq = Invalid
    m.detailsScreenEventReq = m.analytics.sendScreenEvent("Details Screen")

    detailscreen.SetPosterStyle("rounded-rect-16x9-generic")
    description = ""
    detailscreen.SetBreadcrumbText("",m.categoryList[screentype.row])
    detailscreen.SetBreadcrumbEnabled(true)
    detailscreen.SetDescriptionStyle("rounded-square-generic")
    detailscreen.ClearButtons()
    detailscreen.Show()
    match = false
    categoryexists = false

    for categoryIndex = 0 to m.category.count()-1
        category = m.category[categoryIndex]
            if m.categoryList[screentype.row] = category.name
                buttonArrayCount = category.buttonArray.count()-1
                if screentype.row = 0 then
                    if valid(m.matchChannel)
                        match = true
                        if m.matchChannel = metaData.channelID
                            buttonArrayCount = category.buttonArray.count()-1 'dvr match button present'
                        else
                            buttonArrayCount = category.buttonArray.count()-2 'No dvr match button when live match is there'
                        end if
                    else if match = false
                        buttonArrayCount = category.buttonArray.count()-2 'No dvr match button when there are no live matches'
                    end if
                end if
                for buttonIndex = 0 to buttonArrayCount
                     detailscreen.AddButton(buttonIndex+1,category.buttonArray[buttonIndex])
                    categoryexists = true
                end for
            exit for
            end if

    end for

    if categoryexists = false
        detailscreen.AddButton(1,"Watch")
    end if

        detailscreen.SetStaticRatingEnabled(false)
        detailscreen.AllowUpdates(true)
        detailscreen.SetContent(metaData)
        detailscreen.Show()
        if metaData.StreamUrl <> "invalid"

            while true
                msg = wait(0, m.detailPort)

                if type(msg) = "roSpringboardScreenEvent"
                    if msg.isScreenClosed()
                        log("INFO", " Details Screen Closed")
                        exit while
                    else if msg.isButtonPressed()
                        print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
                        ''log("DEBUG", "Button pressed:  " + msg.GetIndex() + " msg: " + msg.GetData() )

                        if msg.GetIndex() = 1
                            if m.categoryList[screentype.row] = "Channels" or m.categoryList[screentype.row] = "Live Matches" or m.categoryList[screentype.row] = "MY DVR"
                                if metaData.streamUrl <> invalid
                                    playVideo(metaData)
                                else
                                    showErrorMessageDialog("Video URL not available to play")
                                end if
                            else if m.categoryList[screentype.row] = "Upcoming Matches"
                                eventId =  m.UpcomingMatches.data.events[screentype.selection].id
                                dvrMatch(screentype.selection)
                            else
                                if metaData.streamUrl <> invalid
                                    playVideo(metaData)
                                else
                                    showErrorMessageDialog("Invalid Stream Url")
                                end if
                        end if

                        else if msg.GetIndex() = 2
                            if m.categoryList[screentype.row] = "Channels"
                                showSchedule(metaData.channelID,screentype.selection)
                            else if m.categoryList[screentype.row] = "Live Matches"
                                if eventId = oldId
                                    detailscreen.AddButton(2,"DVR Requested")
                                    detailscreen.show()
                                else
                                    addDvr(eventId,oldId)
                                end if
                            end if

                        else if msg.GetIndex() = 3
                            if m.categoryList[screentype.row] = "Channels"
                                scheduleInfo = showSchedule(metaData.channelID,screentype.selection)
                                dvrMatch(scheduleInfo)
                            end if

                        else if msg.GetIndex() = 0
                            print "BACK"
                        end if
                    else
                        log("DEBUG", "Unknown event in Details screen: " + msg.GetType().tostr() + " msg: " + msg.GetMessage() )
                    endif
                else if type(msg) = "roUrlEvent" then
                    if m.detailsScreenEventReq <> Invalid and msg.getSourceIdentity() = m.detailsScreenEventReq.getIdentity()  then
                        if msg.getResponseCode() = 200 then
                            result = msg.getString()
                            response = ParseJSON(result)
                            if response <> invalid AND NOT response.DoesExist("success")
                                log("DEBUG", " Error Submitting Analytics to Segment.IO  ")
                            end if
                        else
                            log("DEBUG", " Details Screen POST Call Unsuccessfull ")
                        end if
                        m.detailsScreenEventReq = Invalid
                    else
                        log("DEBUG", " Invalid  Details Screen Event  ")
                    end if
                else
                    log("DEBUG", "Unknown event in Details screen: " + msg.GetType().tostr() + " msg: " + msg.GetMessage() )
                end if
            end while
        else
            showErrorMessageDialog("No video to play, Try later")
        end if
End Function