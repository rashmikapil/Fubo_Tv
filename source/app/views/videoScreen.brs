function playVideo(videoArray as Object)
    log("DEBUG", " playVideo Function")

    hdntl = Invalid
    request = CreateObject("roUrlTransfer")
    request.SetPort(CreateObject("roMessagePort"))
    edgeAuth = getEdgeAuth("edgeauth")
    streamToken = edgeAuth.data.token
    StreamUrl = AnyToString(videoArray.StreamUrl)
    StreamUrl = StreamUrl + "?hdnts=" + streamToken
    request.SetUrl(StreamUrl)
    request.EnableCookies()
    request.EnableFreshConnection(true)
    if (request.AsyncGetToString())
        event = wait(30000, request.GetPort())
        if type(event) = "roUrlEvent"
            if (event.GetResponseCode() <> 200)
                log("DEBUG", " No Video, Please check back later")
		            showErrorMessageDialog("No Video, Please check back later")
                return 0
            endif
            headers = event.GetResponseHeadersArray()
        else if event = invalid
            log("DEBUG", " AsyncGetToString timeout")
            request.AsyncCancel()
            return 0
        else
            log("DEBUG", " AsyncGetToString unknown event")
            return 0
        endif
    endif
    for each header in headers
        val = header.LookupCI("Set-Cookie")
            if (val <> invalid)
                if (val.Left(5) = "hdntl")
                    hdntl = val.Left(Instr(1,val,";")-1)
                endif
            endif
    end for

    screen = CreateObject("roVideoScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.SetPositionNotificationPeriod(1)
    edgeAuth = getEdgeAuth("edgeauth")
    streamToken = edgeAuth.data.token
    videoUrl = AnyToString(videoArray.StreamUrl)
    videoUrl = videoUrl + "?hdnts=" + streamToken
    screen.setCertificatesFile("common:/certs/ca-bundle.crt")
    screen.initClientCertificates()
    screen.EnableCookies()

    if hdntl<>Invalid
      screen.AddHeader("Cookie",hdntl)
    end if

    if m.device.GetDisplaySize().h = 720
        quality = "HD"
    else
        quality = "SD"
    end if

    stream = {
       HDBranded: true
       IsHD: true
       Title:videoArray.Title
       Description:videoArray.Description
       StreamBitrates: [0]
       StreamUrls: [videoUrl]
       StreamQualities: quality
       StreamFormat: videoArray.StreamFormat
       SwitchingStrategy:"full-adaptation"
    }

    if hdntl <> Invalid
        screen.SetContent(stream)
        screen.show()

        log("INFO", "Segment IO Analytics for Video Screen")
        m.analytics = Analytics(m.userId, m.segmentIOAPIKeyValue, port)
        videoScreenEventReq = Invalid
        videoScreenEventReq = m.analytics.sendScreenEvent("Video Screen")
        videoTrackViewEventReq = Invalid
        identityEventReq = Invalid

        log("INFO", " YOubora Initialization")
        if m.youboraInstance = invalid then
            m.youboraInstance = Youbora()
            m.youboraInstance.init("fubotvdev") 'perform the initialization'
            m.pingTime = m.youboraInstance.getDataInfo() 'perform the /data call and return the pingtime in seconds. This call blocks until the data is retrieved'
            m.pingTime = m.pingTime * 1000 'since here we are using ms, x1000'
        end if

        log("INFO", " Video Variables")
        joinTime=0 'time going from the play up to the first frame is displaying'
        date = CreateObject("roDateTime") 'object to track time'
        cur = date.asSeconds() 'track now'
        isBuffering = true 'flag to indicate if the video is buffering or not'
        curVideoPosition = 0 'current video position in seconds'

        bitrate = 0 'helper variable to store the bitrate of video'
        lastBuffer = 0 'helper variable to store last buffer starting time'
        silence = false 'variable to enable/disable log of the video events'
        timestart= 0 'helper variable to store the time of the start event'

        log("INFO", " YOubora Variables")
        modelObject = m.device.GetModelDetails()
        firmwareVersion = m.device.GetVersion()

        log("INFO", " Plugin Variables For Youbora")

        user = m.emailID
        url = videoArray.StreamUrl
        videoTitle = videoArray.Title

        if videoArray.Live=Invalid
            live = false
        else if videoArray.Live="VOD"
            live = false
        else if videoArray.Live="Live"
            live = True
        else
            live = false
        end if

        id = videoArray.ChannelID
        if videoArray.VideoLength <> invalid then
            if type(duration) <> "roInteger" then
                duration = FIX(videoArray.VideoLength)
            else
                duration =  videoArray.VideoLength
            end if
        else
            duration = 3600   ''Default Duration if the Length of the Video is Unknown
        end if

        properties = "{"+Chr(34)+"filename"+Chr(34)+": "+Chr(34)+"PlayVideo"+Chr(34)+","+Chr(34)+"content_id"+Chr(34)+": "+Chr(34)+id+Chr(34)+","+Chr(34)+"content_metadata"+Chr(34)+":{"+Chr(34)+"title"+Chr(34)+": "+chr(34)+videoTitle+chr(34)+","+Chr(34)+"genre"+Chr(34)+": "+Chr(34)+"sport"+Chr(34)+","+Chr(34)+"language"+Chr(34)+": "+Chr(34)+"spanish"+Chr(34)+","+Chr(34)+"year"+Chr(34)+": "+Chr(34)+"2015"+Chr(34)+","+Chr(34)+"duration"+Chr(34)+": "+Chr(34)+duration.toStr()+Chr(34)+","+Chr(34)+"parental"+Chr(34)+": "+Chr(34)+"All"+Chr(34)+"},"+Chr(34)+"transaction_type"+Chr(34)+": "+Chr(34)+"Subscription"+Chr(34)+","+Chr(34)+"quality"+Chr(34)+": "+Chr(34)+"HD"+Chr(34)+","+Chr(34)+"device"+Chr(34)+":{"+Chr(34)+"manufacturer"+Chr(34)+": "+Chr(34)+"Roku"+Chr(34)+","+Chr(34)+"type"+Chr(34)+": "+Chr(34)+modelObject.ModelNumber+Chr(34)+","+Chr(34)+"firmware"+Chr(34)+": "+Chr(34)+firmwareVersion+Chr(34)+"} }" 'optional properties. Chr(34) means ", BrightScript cannot escape " '
        extraparams = {} 'array of extraparameters, the name of the elements of the associative array is fixed and mandatory'
        extraparams["param1"] = "param1"
        extraparams["param2"] = "param2"
        extraparams["param3"] = "param3"
        extraparams["param4"] = "param4"

        hashtitles= false 'enable or disable hashtitles'
        cdn = "Akamai" '

          while true
              msg = wait(m.pingTime, port)
              date.mark()
              now = date.asSeconds()

              ' If the timeout expires, or the difference is geq than ping time, send PING'
              if (now - cur  >= (m.pingTime / 1000) )
                  log("DEBUG", " PING Called from Youbora Analytics")
                  m.youboraInstance.ping(curVideoPosition,bitrate)
                  cur = now
              end if

              if type(msg) = "roVideoScreenEvent"
                  if msg.isScreenClosed() then 'Screen is closed'
                        ' m.youboraInstance.stop()
                      exit while
                  else if msg.isFullResult() then 'The video has been completed'

                  else if msg.isPaused() then 'The video has been paused'
                      m.youboraInstance.pause()

                  else if msg.isResumed() then 'The video has been resumed'
                      m.youboraInstance.resume()

                  else if msg.isStatusMessage() then 'Status message. This seems is not implemented'

                  else if msg.isPartialResult() then 'The video is stopped but it is not completed'
                      log("DEBUG", " Partial result Event Raised in Play Video Function")
                      ' m.pingTime = 0
                      exit While
                  else if msg.isPlaybackPosition() then 'Inform playback position'
                      nowpos = msg.GetIndex()
                        'if the video is running and last position was 0, it is the first time that it runs, so send JOIN TIME'
                      if(curvideoposition=0 and nowpos > 0)
                          jointime = (now - timestart)*1000
                          m.youboraInstance.joinTime(nowpos,jointime)
                      endif

                        'If the video is buffering and the position is greater than the past, it means it has recover from buffering, so inform BUFFER UNDERRUN'
                      if isBuffering and nowpos >= curvideoposition then
                          isbuffering=false
                          duration = (now - lastBuffer)*1000
                          m.youboraInstance.bufferUnderrun(curVideoPosition,duration)
                      end if
                      curvideoposition = nowpos
                  else if msg.isStreamStarted() then 'Stream has started'
                      info = msg.GetInfo()

                      isBuffering= info["IsUnderrun"]
                      bitrate = (info.MeasuredBitrate)*1000

                      if(isBuffering=true) 'The stream has started after a buffering event'
                          lastBuffer = now
                      endif

                      'If the stream is not buffering and there is not informed position. It means it is starting from the beging of the video, so send START'
                      if isBuffering = False and curvideoposition=0
                          m.youboraInstance.start(info.Url,live,properties,user,extraparams,duration,hashtitles,cdn,isp,ip)
                          timestart=now
                      endif
                  else if msg.isRequestFailed() 'Something failed'
                      log("DEBUG", "play failed: " + msg.GetMessage() )
                      errorcode = msg.GetIndex()
                      m.youboraInstance.error(errorcode,url,transactionCode,live,properties,user,extraparams,duration,hashtitles,cdn,isp,ip)
                      screen.close()
                  else 'Unkwown event'
                      if(silence=false)
                          log("DEBUG", "Unknown event: " + msg.GetType().tostr() + " msg: " + msg.GetMessage() )
                      end if
                      if (msg.GetType() = 15)
                          screen.close()
                      end if
                  endif
              else if type(msg) = "roUrlEvent" then
                  if videoScreenEventReq <> Invalid and msg.getSourceIdentity() = videoScreenEventReq.getIdentity()  then
                      checkPostResponse(msg)
                      videoScreenEventReq = Invalid
                      log("INFO", "Segment IO Analytics for Video View")
                      traits = {
                          event: "Video View",
                          email: m.emailId,
                          userId: m.userId,
                          live: live,
                          Title: videoArray.Title
                      }
                      m.analytics.sendVideoTrackViewEvent("VideoView", traits )
                  else if videoTrackViewEventReq <> Invalid and msg.getSourceIdentity() = videoTrackViewEventReq.getIdentity()  then
                      checkPostResponse(msg)
                      videoTrackViewEventReq = Invalid
                  else
                      log("DEBUG", " Invalid roUrlEvent Video Screen Event  ")
                  end if
              else
                  log("INFO", "Unknown Event Type Posted other then roVideoScreen and roUrlEvent")
              end if
          end while

          m.youboraInstance.stop()
          m.youboraInstance = invalid
          m.pingTime = 0
          screen.close()
          log("DEBUG", " video closed in playVideo")
    else
        showErrorMessageDialog("Invalid Stream Url")
    end if
end function
