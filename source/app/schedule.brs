function showSchedule(channelId as string, selection as integer)
    log("DEBUG", " showSchedule Function")

    events = getEvents(channelId)
    programId = []
    scheduleInfo = []
    time = ""
    title = ""

    for eventId = 0 to events.data.events.count()-1
      	for each item in events.data.programs
      		if events.data.events[eventId].program = events.data.programs.[item].id
       			scheduleDetails = {}
       			time = events.data.events[eventId].start
  	      	strt = mid(time,12,5)
       			title = events.data.programs.[item].title
            if eventId = 0
              titleString = "[NOW] " + title
            else
     			    titleString = "[" + strt + "] " + title
            end if
       			scheduleDetails.AddReplace("title",titleString)
       			scheduleDetails.AddReplace("HDPosterUrl",m.channels.data[selection].assets.thumbnail)
       			scheduleDetails.AddReplace("Description",events.data.programs.[item].description)
            scheduleDetails.AddReplace("eventId",events.data.events[eventId].id)
            scheduleDetails.AddReplace("content",events.data.events[eventId].contentType)
            scheduleDetails.AddReplace("datetime",events.data.events[eventId].start)
       			programId.push(scheduleDetails)
      	   	end if
      	end for
     	 	 scheduleInfo.push(programId[eventId])
    end for
    if scheduleInfo.count() <> 0 then

        screen = CreateObject("rolistscreen")
        port = CreateObject("roMessagePort")
        screen.setMessagePort(port)

        log("INFO", "Analytics for Schedule Screen")
        m.analytics = Analytics(m.userId, m.segmentIOAPIKeyValue, port)
        m.scheduleScreenEventReq = Invalid
        m.scheduleScreenEventReq = m.analytics.sendScreenEvent("Schedule Screen")

        screen.SetBreadcrumbText("Schedule ", "")
        screen.setcontent(scheduleInfo)
        screen.show()
        while true
            msg = wait(0,port)
            if type(msg) = "rolistscreenevent" then
                key = msg.GetIndex()
                if msg.isscreenclosed() then
                    exit while
                end if
            else if type(msg) = "roUrlEvent" then
                if  m.scheduleScreenEventReq <> Invalid and msg.getSourceIdentity() =  m.scheduleScreenEventReq.getIdentity()  then
                    checkPostResponse(msg)
                    m.scheduleScreenEventReq = Invalid
                end if
            else if msg.isscreenclosed() then
                exit while
            end if
        end while
        screen.close()
        log("DEBUG", " Show Schedule Screen Closed")
    else
        showErrorMessageDialog(m.noScheduleText)
    end if
    return scheduleInfo
end function

