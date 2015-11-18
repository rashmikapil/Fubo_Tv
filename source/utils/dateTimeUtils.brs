function getDateTime(liveIn) as String
	
	getSystemYear = ""
	getShowYear = ""
	getSystemMonth = ""
	getShowMonth = ""
	getSystemDate = 0
	getShowdate = 0

	videoStartDateTime = CreateObject("roDateTime")
	videoStartDateTime.FromISO8601String(livein)
	videoStartDateTime.toLocalTime()
	eventStartUnixTimeStamp = videoStartDateTime.AsSeconds()
	
	
	currentDateTime = CreateObject("roDateTime")
	currentDateTime.Mark()
	currentDateTime.toLocalTime()
	currentDateStr = currentDateTime.AsDateString("short-month-no-weekday")
	currentDateStrArr = currentDateStr.Tokenize(",")
	currentdateArr = currentDateStrArr[0].Tokenize(" ")
	getSystemMonth = currentdateArr[0]
	getSystemDate = currentdateArr[1]
	getIntSystemDate = getSystemDate.ToInt()

	getSystemYear = currentDateStrArr[1].trim()
	
	seconds = eventStartUnixTimeStamp - currentDateTime.AsSeconds()
		

	eventDateTime = CreateObject("roDateTime")
	eventDateTime.fromSeconds(eventStartUnixTimeStamp)
	eventDateStr = eventDateTime.AsDateString("short-month-no-weekday")
	eventDateStrArr = eventDateStr.Tokenize(",")
	getRostrShowYear = eventDateStrArr[1]
	getShowYear = getRostrShowYear.trim()
	dateArr = eventDateStrArr[0].Tokenize(" ")
	getShowMonth = dateArr[0]
	getStrShowdate = dateArr[1]
	getShowdate = getStrShowdate.ToInt()
	finalDateStr = dateArr[1] + " " + dateArr[0]


	eventHour = 0
	eventMin = 0
	eventMinStr = ""
	eventHourStr = ""
	eventTimeStr = ""
	eventMer = ""


	eventHour = eventDateTime.GetHours()
	eventMin = eventDateTime.GetMinutes()
	if eventMin <> invalid  
		if eventMin < 10
			eventMinStr = "0" + Str(eventMin).trim()
		else 
			eventMinStr = str(eventMin).trim()
		end if
	end if 

	if eventHour <> invalid
		if eventHour > 11 then
	        if eventHour > 12 then
	            eventHour = eventHour - 12
	        end if
	        eventHourStr = str(eventHour)
	        eventMer = "PM"
	    else
	        if eventHour = 0 then
	             eventHour = 12
	        end if
	        eventHourStr = str(eventHour)
	        eventMer = "AM"
	    end if
	end if
   
	if getSystemYear <> invalid AND getShowYear <> invalid AND getShowdate <> invalid AND getIntSystemDate <> invalid AND getShowMonth <> invalid and getsystemMonth <> invalid then
		if getSystemYear = getShowYear 
				if getShowdate = getIntSystemDate AND getsystemMonth = getShowMonth
					return "Today" + "  @" + eventHourStr + ":" + eventMinStr + " " + eventMer
				else if getShowdate = getIntSystemDate + 1 AND getsystemMonth = getShowMonth
				     return "Tomorrow"  + "  @" + eventHourStr + ":" + eventMinStr + " " + eventMer
			    else 
			   		 eventTimeStr = finalDateStr + " @ " + eventHourStr + ":" + eventMinStr + " " + eventMer
					 return eventTimeStr
			    end if 
		end if 
	end if
end function

function valid(item) as Boolean
    return type(item) <> "Invalid" and type(item) <> "roInvalid" and type(item) <> "<uninitialized>"
end function


function setDateime()
    
 m.currentDateTime = ""
   yr =  m.timer.GetYear()
   year = toStr(yr)
   if yr < 10
      year = "0" + year
   end if

   mnth = m.timer.GetMonth()
   month = toStr(mnth)
    if mnth < 10
      month = "0" + month
    end if

   dy = m.timer.GetDayOfMonth()
   day = toStr(dy)
    if dy < 10
      day = "0" + day
    end if

   m.hr = m.timer.GetHours()
    m.hours = toStr(m.hr)
    if m.hr < 10
        m.hours = "0" + m.hours
    end if

   m.mn = m.timer.GetMinutes()
   m.minutes = toStr(m.mn)
   if m.mn < 10
        m.minutes = "0" + m.minutes
   end if

   se = m.timer.GetSeconds()
   seconds = toStr(se)
 
   m.currentDateTime = year + "-" + month + "-" + day + "T" + m.hours + ":" + m.minutes 
end function


function matchIsLive() as boolean

  if valid(m.UpcomingMatches) 
    for eventsId = 0 to m.UpcomingMatches.data.events.count()-1
        startTime = m.UpcomingMatches.data.events[eventsId].start
        endTime = m.UpcomingMatches.data.events[eventsId].end
        startTime = left(startTime,23)
        endTime = left(endTime,23)     
        if isCurrent(startTime, endTime)
          return true 
        end if
    end for
    return false
  else
    return false
  end if  
end function 

function isCurrent(startTime as string, endTime as string) as boolean
  
  startDateTime = CreateObject("roDateTime")
  startDateTime.FromISO8601String(startTime)
  utsStart = startDateTime.AsSeconds()

  endDateTime = CreateObject("roDateTime")
  endDateTime.FromISO8601String(endTime)
  utsEnd = endDateTime.AsSeconds()
 
  currentDateTime = CreateObject("roDateTime")
  utsNow = currentDateTime.AsSeconds()

  if utsStart <= utsNow AND utsNow <=utsEnd then
    return true
  else
    return false
  end if

end function 


