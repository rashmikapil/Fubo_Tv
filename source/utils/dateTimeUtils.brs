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

function getLiveInCountDown(livein as Object)

	videoStartDateTime = CreateObject("roDateTime")
	videoStartDateTime.FromISO8601String(livein)
	videoStartDateTime.ToLocalTime()
	eventStartUnixTimeStamp = videoStartDateTime.AsSeconds()

	currentDateTime = CreateObject("roDateTime")
	currentDateTime.Mark()
	currentDateTime.ToLocalTime()
	seconds = eventStartUnixTimeStamp - currentDateTime.AsSeconds()

	return seconds
end function

Function getCountdownString(seconds As Integer) As String

	if seconds <> invalid
		hours = Int(seconds / 3600) 
	end if
	
	if hours <> invalid AND seconds <> invalid
		if hours < 1
			minutes = Int(seconds / 60)
			seconds = seconds MOD 60
			days = 0
		else if hours > 23
			days = Int(hours/24)
			if days <> invalid
				hours = hours - (days*24)
			end if
			minutes = Int(seconds / 60)

			if hours <> invalid AND minutes <> invalid AND days <> invalid
				minutes = minutes - (hours*60) - (days*1440)
				seconds = seconds - (hours*3600) - (minutes*60) - (days*86400)
			end if 
		else 
			minutes = Int(seconds / 60)
			if minutes <> invalid 
				minutes = minutes - (hours*60)
		    	seconds = seconds - (hours*3600) - (minutes*60)
			end if 
			days = 0
		end if
	end if

	if days <> invalid 
		strOfDays = days.toStr()
	else 
		strOfDays = ""
	end if
	
	if hours <> invalid 
		strOfHours = hours.toStr()
	else 
		strOfMins = ""
	end if
	
	if hours <> invalid
		strOfMins = minutes.toStr()
	else 
		strOfMins = ""
	end if

	if seconds <> invalid
		strOfSeconds = seconds.toStr()
	else 
		strOfSeconds = ""
	end if
	
	timeLeft =  "Live in " + strOfDays + "d " + strOfHours + "h " + strOfMins + "m " + strOfSeconds + "s" 
	if seconds = 0 and minutes = 0 and hours = 0 and days = 0
	   timeLeft = "Live Now"
	else	
	   timeLeft =  "Live in " + strOfDays + "d " + strOfHours + "h " + strOfMins + "m " + strOfSeconds + "s"  
	end if

	return timeLeft
End Function


function valid(item) as Boolean
    return type(item) <> "Invalid" and type(item) <> "roInvalid" and type(item) <> "<uninitialized>"
end function

function isFloat(item) as Boolean
    return type(item) = "Float" or type(item) = "roFloat"
end function