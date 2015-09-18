
Function EpisodeDetailScreen(row as Integer,selection as Integer) 
    port = CreateObject("roMessagePort")
    detailscreen = CreateObject("roSpringboardScreen")
    detailscreen.SetMessagePort(port)
    detailscreen.SetPosterStyle("rounded-rect-16x9-generic")
    detailscreen.SetBreadcrumbText("", "Ajax TV")
    detailscreen.SetBreadcrumbEnabled(true)
    
    displayVideoAssociativeArray = CreateObject ("roAssociativeArray")
    episodeDetails = getShowDetails(m.categoryList[row])
    showEpisode    =getEpisode(episodeDetails[selection].slug)

    streamUrl   =AnyToString(showEpisode.data[0].link)
    description =AnyToString(showEpisode.data[0].description) 
    title       =AnyToString(episodeDetails[selection].Title) 
    image       =AnyToString(episodeDetails[selection].HDPosterUrl)
    print"****************"showEpisode.data[0].link

    episodeNumber ="Episode "+tostr(selection)
   
       
        VideoAssociativeArray = {
                                    StreamUrls :streamUrl + ".mp4"
                                    StreamQualities : "HD"
                                    StreamFormat : "mp4"
                                    Title :title 
                                    HDPosterUrl : image
                                    StreamBitrates : 4400
                                    Description : description
                                    Actors :episodeNumber
                                    SwitchingStrategy: "full-adaptation" 
                                    } 
    
    
     detailscreen.SetDescriptionStyle("rounded-square-generic")   
     detailscreen.ClearButtons()
     detailscreen.AddButton(1,"Watch")
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
                    print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
                    if msg.GetIndex() = 1                         
                        displayVideo(VideoAssociativeArray)
                        print"video excuted sucessfully+++++++++++++++++++++++++++++"
                    endif
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif     
        else 
            print "wrong type.... type=";msg.GetType(); " msg: "; msg.GetMessage()    
        end if       
    end while

End Function

