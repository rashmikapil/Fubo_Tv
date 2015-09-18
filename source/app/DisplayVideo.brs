Function displayVideo( rovideodetails  as object) 
    print "Displaying video: "
	
    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(p)
    video.ShowSubtitle(true) 
    video.ShowSubtitleOnReplay(true)     
	video.SetContent(rovideodetails)
    video.SetPositionNotificationPeriod(1)
    video.show()

    lastSavedPos   = 0
    statusInterval = 10 

    while true
        msg = wait(0, video.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then 'ScreenClosed event
                print "Closing video screen"
                exit while
            else if msg.isPlaybackPosition() then
                nowpos = msg.GetIndex()
                print "playback position is "nowpos
                if nowpos > 10000
                    
                end if
                if nowpos > 0
                    if abs(nowpos - lastSavedPos) > statusInterval
                        lastSavedPos = nowpos
                    end if
                end if
            else if msg.isRequestFailed()
                print "play failed: "; msg.GetMessage()
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
                 m.fromVideo =  msg.GetType() 
                 if (msg.GetType() = 15)
                    video.close()
                end if
            endif
        end if
    end while
    video.close()
    print "video closed in display video screen......................................................"
End Function



   