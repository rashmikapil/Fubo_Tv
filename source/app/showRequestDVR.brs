Function showRequestDVR(selection as Integer) 
   port = CreateObject("roMessagePort")
    detailscreen = CreateObject("roSpringboardScreen")
    detailscreen.SetMessagePort(port)
    detailscreen.SetPosterStyle("rounded-rect-16x9-generic")
    detailscreen.SetBreadcrumbText("", "Upcoming Match")
    detailscreen.SetBreadcrumbEnabled(true)
   
    displayVideoAssociativeArray = CreateObject ("roAssociativeArray")
    assocArray = {}  
    assocArray =liveMatches()
    printAA(assocArray[selection]) 
    print" (assocArray[0])========= "assocArray[selection].id

    for i = 0 to m.channels.data.count()-1 step 1    
        if(m.channels.data[i].id =assocArray[selection].id)
            Url =m.channels.data[i].hls_url
            image = AnyToString(assocArray[selection].HDPosterUrl)
            description = AnyToString(assocArray[selection].Description) 
            title=AnyToString(assocArray[selection].Title) 
            if(Url<>Invalid)
                streamUrl=tostr(Url)
            end if
        end if
    end for


        VideoAssociativeArray = {
                                    StreamUrls :streamUrl
                                    StreamQualities : "HD"
                                    StreamFormat : "hls"
                                    Title :title 
                                    HDPosterUrl : image
                                    StreamBitrates : 4400
                                    Description : description
                                    Actors :"Upcoming Match :"
                                    SwitchingStrategy: "full-adaptation" 
                                    } 
    
    
     detailscreen.SetDescriptionStyle("rounded-square-generic")   
     detailscreen.ClearButtons()
     detailscreen.AddButton(1,"RequestDVR")
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