
Function displayDetailScreen(selection as Integer) 
    port = CreateObject("roMessagePort")
    detailscreen = CreateObject("roSpringboardScreen")
    detailscreen.SetMessagePort(port)
    detailscreen.SetPosterStyle("rounded-rect-16x9-generic")
    detailscreen.SetBreadcrumbText("", "Channel")
    detailscreen.SetBreadcrumbEnabled(true)
   
    VideoAssociativeArray = CreateObject ("roAssociativeArray")

    if m.channels.data.count() <> 0
        for i = 0 to m.channels.data.count()-1 step 1             
            retUrl= m.channels.data[selection].assets.thumbnail
            Url = m.channels.data[selection].hls_url
                if(retUrl<>Invalid)
                    st=tostr(retUrl)
                    newUrl=strReplace(st,"https","http")
                    image = AnyToString(newUrl)
                    description = AnyToString(m.channels.data[selection].description)
                    channelId = m.channels.data[selection].id
                end if
                if(Url<>Invalid)
                    streamUrl=tostr(Url)
                end if
        end for
    else
        showErrorMessageDialog(m.loadingDataErrorText)
    end if   

    VideoAssociativeArray = {
                                    StreamUrls :streamUrl
                                    StreamQualities : "HD"
                                    StreamFormat : "hls"
                                    Title : m.channels.data[selection].title
                                    HDPosterUrl : image
                                    StreamBitrates : 4400
                                    Description : description
                                    Actors :"Now Playing :"
                                    SwitchingStrategy: "full-adaptation" 
                                    } 
    
    
    detailscreen.SetDescriptionStyle("rounded-square-generic")   
    detailscreen.ClearButtons()
    detailscreen.AddButton(1,"Watch")
    detailscreen.AddButton(2,"Schedule")
    detailscreen.SetStaticRatingEnabled(false) 
    detailscreen.AllowUpdates(true)
    detailscreen.SetContent(VideoAssociativeArray)
    detailscreen.Show()
        
    while true
     msg = wait(0, detailscreen.GetMessagePort())
        if type(msg) = "roSpringboardScreenEvent"
            if msg.isScreenClosed()
                print "Screen closed"
                exit while                
            else if msg.isButtonPressed()
                    key = msg.GetIndex()
                    if key = 1                         
                        displayVideo(VideoAssociativeArray)
                        print"video excuted sucessfully+++++++++++++++++++++++++++++"
                    else if key = 2
                        m.timer.mark()
                        tdaySeconds = m.timer.asSeconds()
                        tomSeconds = tdaySeconds + 43200
                        fromMiliSeconds = toStr(tdaySeconds) + "000"
                        toMiliSeconds = toStr(tomSeconds) + "000"
                        schedule = showSchedule(channelId,fromMiliSeconds,toMiliSeconds)
                        showScheduleScreen(schedule)
                    end if
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            end if     
        else 
            print "wrong type.... type=";msg.GetType(); " msg: "; msg.GetMessage()    
        end if       
    end while
End Function

