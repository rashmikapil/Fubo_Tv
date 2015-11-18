function getDetails(screentype as object) as object
    log("DEBUG", " getDetails Function")

	if m.categoryList[screenType.row] = "Channels"
        return getChannelInfo(screenType.selection)

    else if m.categoryList[screenType.row] = "Live Matches"
        return getLiveMatchesInfo(screentype.selection)

    else if m.categoryList[screenType.row] = "Upcoming Matches"
        return getUpcomingMatchesInfo(screentype.selection)

    else if m.categoryList[screenType.row] = "MY DVR"
        return getMydvrInfo(screentype.selection)
    else
        return getShowInfo(screentype)
    end if

end function

function getChannelInfo(selection as integer) as object
    log("DEBUG", " getChannelInfo Function")

	metaData = {}
	channelList = []
    channelList = m.channelList
    actor      = "NOW PLAYING :"
    format     = "hls"

    channelID   = channelList[selection].channelID
    Description = AnyToString(channelList[selection].Description)
    description = strReplace(Description,"Now Playing : "+chr(10),"")
    image       = AnyToString(channelList[selection].HDPosterUrl)
    title       = AnyToString(channelList[selection].Title)
    streamUrl   = channelList[selection].streamUrl
    VideoLength = channelList[selection].VideoLength
    live        = channelList[selection].Live

    metaData.AddReplace("Actor",actor)
    metaData.AddReplace("StreamFormat",format)
    metaData.AddReplace("channelID",channelID)
    metaData.AddReplace("Description",description)
    metaData.AddReplace("HDPosterUrl",image)
    metaData.AddReplace("SDPosterUrl",image)
    metaData.AddReplace("Title",title)
    metaData.AddReplace("StreamUrl",streamUrl)
    metaData.AddReplace("VideoLength",VideoLength)
    metaData.AddReplace("Live",live)

    return metaData

end function

function getLiveMatchesInfo(selection as integer)
    log("DEBUG", " getLiveMatchesInfo Function")

	metaData = {}
	matchesList = []
    matchesList = m.liveMatches
    actor      = "LIVE : "
    format     = "hls"
        for each item in m.UpcomingMatches.data.channels
            if(m.UpcomingMatches.data.channels.[item].id = matchesList[selection].eventChannelID)
                slug        = m.UpcomingMatches.data.channels.[item].slug
                slugUrl     = getChannelSlug(slug)
                print "--- " slugUrl.data.id

                Url         = slugUrl.data.hls_url
                image       = AnyToString(matchesList[selection].HDPosterUrl)
                title       = AnyToString(matchesList[selection].Title)
                description = title+chr(10)+AnyToString(matchesList[selection].Description)
                eventId     = matchesList[selection].eventChannelID

                Length      = AnyToString(matchesList[selection].Length)
                Live        = AnyToString(matchesList[selection].Live)

                if(Url<>Invalid)
                    streamUrl=tostr(Url)
                end if
            end if
        end for

    metaData.AddReplace("Actor",actor)
    metaData.AddReplace("StreamFormat",format)
    metaData.AddReplace("Description",description)
    metaData.AddReplace("HDPosterUrl",image)
    metaData.AddReplace("SDPosterUrl",image)
    metaData.AddReplace("Title",title)
    metaData.AddReplace("StreamUrl",streamUrl)

    metaData.AddReplace("VideoLength",Length)
    metaData.AddReplace("Live",Live)
    metaData.AddReplace("channelID",eventId)

    return metaData
end function

function getUpcomingMatchesInfo(selection as integer)
    log("DEBUG", " getUpcomingMatchesInfo Function")

	metaData = {}
	upMatchesList = []
    upMatchesList = getUpcomingMatches()
    actor      = "Upcoming :"

    event_time = upMatchesList[selection].start_time
    eventTime  = mid(event_time,0,16)
    time       = strReplace(eventTime,"T"," at ")
    title      = AnyToString(upMatchesList[selection].Title)
    image      = AnyToString(upMatchesList[selection].HDPosterUrl)
    description = time+chr(10)+title+chr(10)+AnyToString(upMatchesList[selection].Description)

    metaData.AddReplace("Actor",actor)
    metaData.AddReplace("Description",description)
    metaData.AddReplace("HDPosterUrl",image)
    metaData.AddReplace("SDPosterUrl",image)
    metaData.AddReplace("Title",title)

    return metaData
end function

function getMydvrInfo(selection as integer)
    log("DEBUG", " getMydvrInfo Function")

	metaData = {}
	dvrList = []
    dvrList =  m.myDvrList
    format     = "hls"

    if valid(dvrList[selection].video) then
        print "111"
        streamUrl = AnyToString(dvrList[selection].video.Link)
    else
        print "222"
        streamUrl = "invalid"
    end if
    image      = dvrList[selection].HDPosterUrl
    title       = dvrList[selection].Title
    description = dvrList[selection].Description
    date        = dvrList[selection].date
    eventTime   = mid(date,0,16)
    time        = strReplace(eventTime,"T"," at ")
    actor       = "Aired On : " + time
    length      = dvrList[selection].Length
    channelID   = dvrList[selection].ContentID

    metaData.AddReplace("Actor",actor)
    metaData.AddReplace("StreamFormat",format)
    metaData.AddReplace("Description",description)
    metaData.AddReplace("HDPosterUrl",image)
    metaData.AddReplace("SDPosterUrl",image)
    metaData.AddReplace("Title",title)
    metaData.AddReplace("StreamUrl",streamUrl)

    metaData.AddReplace("VideoLength",length)
    metaData.AddReplace("Live","VOD")
    metaData.AddReplace("channelID",channelID)

    return metaData
end function

function getShowInfo(screentype as object)
    log("DEBUG", " getShowInfo Function")
    showIndex = screentype.row - m.showCategoryCount
	metaData = {}
    episodeDetails = m.showList.list[showIndex]

    if type(episodeDetails[screentype.selection].slug) <> "roInteger"
        showEpisode    = getEpisode(episodeDetails[screentype.selection].slug)
    else
        slug = episodeDetails[screentype.selection].slug.toStr()
        showEpisode    = getEpisode(slug)
    end if

    if valid(showEpisode)
        if valid(showEpisode.data[0])
            description    =  AnyToString(showEpisode.data[0].description)
            streamUrl  = AnyToString(showEpisode.data[0].link)

            if Right(streamUrl,4)  = "m3u8"
                format = "hls"
            else if Right(streamUrl,3) = "mp4"
                format = "mp4"
            else
               format = "hls"
            end if
       '' else
           'streamUrl = "invalid"
        end if
    else
        streamUrl = invalid
    end if

        title          = m.categoryList[screentype.row]
        image          = AnyToString(episodeDetails[screentype.selection].HDPosterUrl)

        duration       = episodeDetails[screentype.selection].Length
        id             = episodeDetails[screentype.selection].showID
        if(screentype.selection > 8)
            actor ="Episode  " + tostr (screentype.selection+1)
        else
            actor ="Episode  0" + tostr(screentype.selection+1)
        end if

        if valid(streamUrl)

        else
            streamUrl = "invalid"
        end if

    metaData.AddReplace("Actor",actor)
    metaData.AddReplace("StreamFormat",format)
    metaData.AddReplace("Description",description)
    metaData.AddReplace("HDPosterUrl",image)
    metaData.AddReplace("SDPosterUrl",image)
    metaData.AddReplace("Title",title)
    metaData.AddReplace("StreamUrl",streamUrl)

    metaData.AddReplace("VideoLength",duration)
    metaData.AddReplace("Live","VOD")
    metaData.AddReplace("channelID",id)

    return metaData
end function