Function listingScreen()
    log("DEBUG", " listingScreen Function")

    m.gridscreen = CreateObject("roGridScreen")
    m.gridPort = CreateObject("roMessagePort")
    m.gridscreen.SetMessagePort(m.gridPort)

    m.gridscreen.Show()
    timerRefresh = CreateObject("roTimeSpan")
    timerLive = CreateObject("roTimeSpan")
    timer = CreateObject("roTimeSpan")
    log("DEBUG", "Analytics for Home Screen")
    m.analytics = Analytics(m.userId, m.segmentIOAPIKeyValue, m.gridPort)
    retrieveRequest = Invalid
    m.homeScreenEventReq = Invalid
    m.identitySignInEventReq = Invalid
    m.trackSignInEventReq  = Invalid
    m.homeScreenEventReq = m.analytics.sendScreenEvent("Home Screen")

    m.gridscreen.SetDisplayMode("scale-to-fill")
    m.gridscreen.setGridStyle("four-column-flat-landscape")
    m.gridscreen.setCertificatesFile("common:/certs/ca-bundle.crt")
    m.gridscreen.initClientCertificates()
    timeout = 60
    timerRefresh.mark()
    timerLive.mark()
    m.gridscreen.Show()
    setUpGrid()
    liveStatus = false
    screenType = {}
    while true

        if timerRefresh.TotalSeconds() > m.refreshTokenExpiryTime then 'check whether token has expired'
            retrieveRequest = getRefreshToken(m.gridPort)
    		timerRefresh.mark()
        end if
        log("TRACE", "to display now playing")
        if timerLive.TotalSeconds() > timeout
            m.gridscreen.SetContentList(0,getChannels())
            if liveStatus = true
                liveMatches = getUpcomingMatches("Live Matches")
                upcomingMatches = getUpcomingMatches()
                m.gridscreen.SetContentList(1,liveMatches)
                m.gridscreen.SetContentList(2,upcomingMatches)
                m.gridscreen.SetListVisible(1,true)
                for categoryCount = 0 to m.categoryList.count()-1
                    if m.categoryList[categoryCount] = "MY DVR"
                         m.gridscreen.setContentList(categoryCount,m.myDvrList)
                    end if
                    exit for
                end for
            end if
            ' setUpGrid()
            m.gridscreen.show()
            timerLive.mark()
        end if

        msg = wait(1000, m.gridPort)

        if type(msg) = "roGridScreenEvent" then
            if msg.isScreenClosed() then
                log("INFO", "closing grid screen")
                m.exitListScreenFlag = true
                m.screen = invalid
                exit while
            else if msg.isListItemFocused() then
               m.gridscreen.show()
            else if msg.isListItemSelected() then
                screenType.AddReplace("row",msg.GetIndex())
                screenType.AddReplace("selection" ,msg.getData())
                print "screenType =  " screenType
                metaData = getDetails(screenType)
                detailScreen(metaData, screentype)
            end if
        else if type(msg) = "roUrlEvent" then
            if m.homeScreenEventReq <> Invalid and msg.getSourceIdentity() = m.homeScreenEventReq.getIdentity()  then
                checkPostResponse(msg)
                homeScreenEventReq = Invalid
                properties = {
                    email: m.emailId,
                    userId: m.userId
                }
                m.identitySignInEventReq = m.analytics.sendIdentityEvent("Signed In",properties)
            else if m.identitySignInEventReq <> Invalid and msg.getSourceIdentity() = m.identitySignInEventReq.getIdentity()  then
                checkPostResponse(msg)
                m.identitySignInEventReq = Invalid
                traits = {
                    email: m.emailId,
                    userId: m.userId
                }
                m.trackSignInEventReq = m.analytics.sendRokuLinkedTrackEvent("Signed In", traits )
            else if m.trackSignInEventReq <> Invalid and msg.getSourceIdentity() = m.trackSignInEventReq.getIdentity()  then
                checkPostResponse(msg)
                m.trackSignInEventReq = Invalid
            else
                log("DEBUG", " Invalid  listingScreen Event  ")
            end if
        end if
    end while
    m.gridscreen.close()
End Function

function setUpGrid()
    shows = []

    m.categoryList = []
    if valid(m.channels)
        m.categoryList.push("Channels")
    end if

    m.liveMatches = getUpcomingMatches("Live Matches")
    'if m.LiveList.count() <> 0
    m.categoryList.push("Live Matches")
    'end if

    if valid(m.UpcomingMatches)
        m.categoryList.push("Upcoming Matches")
    end if

    m.myDvr = getMyDvr()
    if valid(m.myDvr.data)
        if m.myDvr.data.events.count() <> 0
            m.categoryList.push("MY DVR")
        end if
    end if

    if valid(m.shows)
        getshows()
    end if

    showCategory = false
    m.gridscreen.setupLists(m.categoryList.count())
    m.gridscreen.SetListNames(m.categoryList)
    m.channelList = getChannels()
    m.UpcomingMatchList = getUpcomingMatches()
    m.myDvrList = getDvr()
    for categoryCount = 0 to m.categoryList.count()-1
        if m.categoryList[categoryCount] = "Channels"
            m.gridscreen.setContentList(categoryCount,m.channelList)
        else if m.categoryList[categoryCount] = "Live Matches"
            m.gridscreen.setContentList(categoryCount,m.liveMatches)
        else if m.categoryList[categoryCount] = "Upcoming Matches"
            m.gridscreen.setContentList(categoryCount,m.UpcomingMatchList)
        else if m.categoryList[categoryCount] = "MY DVR"
            m.gridscreen.setContentList(categoryCount,m.myDvrList)
        else
            showCategory = true
            m.showCategoryCount = categoryCount
            exit for
        end if
    end for
    if showCategory = true
        m.showList = {}
        m.showList.list = []
        for index = categoryCount to m.categoryList.count()-1 step 1
            shows = getShowDetails(m.categoryList[index])
            m.gridscreen.setContentList(index,shows)
            m.showList.list.push(shows)
        end for
    end if
    if m.LiveList.count() = 0
        m.gridscreen.SetListVisible(1, False)
    end if
end function

function getChannels() as object
    playlist = []
    for channelValue = 0 to m.channels.data.count()-1
        channelID = m.channels.data[channelValue].id
        fromSeconds = m.timer.asSeconds()
        toSeconds = fromSeconds + 43200
        fromMiliSeconds = toStr(fromSeconds) + "000"
        toMiliSeconds = toStr(toSeconds) + "000"
        description = "Now Playing : " + chr(10)

        now = getEvents(channelId)

        for eventsId = 0 to now.data.events.count()-1
            time = now.data.events[eventsId].start
            hour = mid(time,12,2)
            if m.hours = hour
                    for each item in now.data.programs
                        if now.data.events[eventsId].program = now.data.programs.[item].id
                            description = description + now.data.programs.[item].title + chr(10)
                            if valid(now.data.programs.[item].description)
                                description = description + now.data.programs.[item].description
                            end if
                        end if
                    end for
                else
                    item = now.data.events[0].program
                    description = description + now.data.programs.[item].title + chr(10)
                    if valid(now.data.programs.[item].description)
                        description = description + now.data.programs.[item].description
                    end if
                end if
            exit for
            end for

            channel = {}
            retUrl= m.channels.data[channelValue].assets.thumbnail
            if(retUrl<>Invalid)
                st=tostr(retUrl)
                newUrl=strReplace(st,"https","http")
                channel.AddReplace("HDPosterUrl",newUrl)
                channel.AddReplace("SDPosterUrl",newUrl)
                channel.AddReplace("Title",m.channels.data[channelValue].title)
                channel.AddReplace("Description",description)
                channel.AddReplace("channelID",m.channels.data[channelValue].id)
                channel.AddReplace("streamUrl",m.channels.data[channelValue].hls_url)
                if now.data.events.count() <> 0 then
                    if now.data.events[0].contentType = "" or now.data.events[0].contentType = "Repeat"
                        channel.AddReplace("Live","VOD")
                    else if now.data.events[0].contentType = "New" or  now.data.events[0].contentType = "Live"
                        channel.AddReplace("Live","Live")
                    else
                        channel.AddReplace("Live","VOD")
                    end if
                    channel.AddReplace("VideoLength",now.data.events[0].duration)
                end if
                    playlist.push(channel)
            end if

    end for
    return playlist
end function

function getshows() as object
    shows = ""
    for showId = 0 to m.shows.data.count()-1
        if m.shows.data[showId].video.count() <> 0 then
           shows = m.shows.data[showId].title
           m.categoryList.push(m.shows.data[showId].title)
        end if
    end for
end function


function getShowDetails(showName as string) as object
    playList = []
    if valid(m.shows)
       for showValue = 0 to m.shows.data.count()-1
            if m.shows.data[showValue].video.count() <> 0 then
                if m.shows.data[showValue].title = showName then
                    for videoId = 0 to  m.shows.data[showValue].video.count()-1
                        shows = {}
                        retUrl= m.shows.data[showValue].video[videoId].thumb_image.big
                        if(retUrl<>Invalid)
                            st = tostr(retUrl)
                            newUrl = strReplace(st,"https","http")
                            shows.AddReplace("HDPosterUrl",newUrl)
                            shows.AddReplace("SDPosterUrl",newUrl)
                            shows.AddReplace("Title",m.shows.data[showValue].video[videoId].title)
                            shows.AddReplace("slug",m.shows.data[showValue].video[videoId].slug)
                            shows.AddReplace("Description",m.shows.data[showValue].description)
                            shows.AddReplace("Length",m.shows.data[showValue].video[videoId].duration)
                            shows.AddReplace("ShowID",m.shows.data[showValue].video[videoId].id)
                            playlist.push(shows)
                        end if
                    end for
                 end if
            end if
        end for
    end if
    return playlist
end function

function getUpcomingMatches(flag ="Upcoming Matches")

    playList = []
    live = false

    if valid(m.UpcomingMatches)
        for eventsId = 0 to m.UpcomingMatches.data.events.count()-1
             eventMatch = m.UpcomingMatches.data.events[eventsId].match
             startTime = m.UpcomingMatches.data.events[eventsId].start
             endTime = m.UpcomingMatches.data.events[eventsId].end
             eventDate = mid(startTime,0,10)
             liveDate = mid(m.currentDateTime,0,10)
             live = matchIsLive()

            for each item in m.UpcomingMatches.data.programs
                if m.UpcomingMatches.data.events[eventsId].program = m.UpcomingMatches.data.programs.[item].id
                    matches = {}
                    image = m.UpcomingMatches.data.programs.[item].thumbnail
                    newUrl = strReplace(image,"https","http")
                    matches.AddReplace("HDPosterUrl",newUrl)
                    matches.AddReplace("SDPosterUrl",newUrl)
                    matches.AddReplace("Title",m.UpcomingMatches.data.programs.[item].title)
                    matches.AddReplace("Description",m.UpcomingMatches.data.programs.[item].description)
                    matches.AddReplace("eventchannelID",m.UpcomingMatches.data.events[eventsId].channel)
                    matches.AddReplace("eventMatch",eventMatch)
                    matches.AddReplace("start_time",startTime)
                    matches.AddReplace("channelslug",m.UpcomingMatches.data.channels.slug)
                    if m.UpcomingMatches.data.events[eventsId].ContentType = "" or m.UpcomingMatches.data.events[eventsId].ContentType = "Repeat"
                        matches.AddReplace("Live","VOD")
                    else if m.UpcomingMatches.data.events[eventsId].ContentType = "New" or  m.UpcomingMatches.data.events[eventsId].ContentType = "Live"
                        matches.AddReplace("Live","Live")
                    else
                        matches.AddReplace("Live","VOD")
                    end if
                    matches.AddReplace("Length",m.UpcomingMatches.data.events[eventsId].duration)
                    if liveDate = eventDate and live = true
                        m.LiveList.push(matches)
                        m.matchChannel = matches.eventchannelID
                    else
                        playlist.push(matches)
                    end if
                end if
            end for
        end for
    else
        playlist = []
        matches = {}
        matches.AddReplace("HDPosterUrl","pkg:/assets/images/empty.png")
        matches.AddReplace("SDPosterUrl","pkg:/assets/images/empty.png")
        matches.AddReplace("Title","No upcoming Matches")
        playlist.push(matches)
    end if

    if(flag="Live Matches")
       return m.LiveList
    else
      return playlist
    end if

end function

function getDvr()
        playlist = []
        print "==== " m.myDvr.data.events.count()
        for eventsId = 0 to m.myDvr.data.events.count()-1
            dvr = {}
            if valid(m.myDvr.data.events[eventsId].program.thumbnails[0].url)
                imageUrl = m.myDvr.data.events[eventsId].program.thumbnails[0].url
                image = strReplace(imageUrl,"https","http")
                dvr.AddReplace("HDPosterUrl",image)
                dvr.AddReplace("SDPosterUrl",image)
            else
                dvr.AddReplace("HDPosterUrl",m.emptyImage)
                dvr.AddReplace("SDPosterUrl",m.emptyImage)
            end if
            if valid(m.myDvr.data.events[eventsId].program)
                dvr.AddReplace("Title",m.myDvr.data.events[eventsId].program.title)
                dvr.AddReplace("Description",m.myDvr.data.events[eventsId].program.description)
            else
                dvr.AddReplace("Title","Title")
                dvr.AddReplace("Description","Description")
            end if
            dvr.AddReplace("video",m.myDvr.data.events[eventsId].video)
            dvr.AddReplace("date",m.myDvr.data.events[eventsId].createdAt)

            dvr.AddReplace("length",m.myDvr.data.events[eventsId].duration)
            dvr.AddReplace("ContentID",m.myDvr.data.events[eventsId].id)

            playlist.push(dvr)
        end for
        return playlist
end function

