'function to get details for list screen'
function showSchedule(channelId as string,startTime as string,endTime as string) as object
    events = getEvents(channelId,startTime,endTime)
    print "events = " events.data.programs.count()
    programId = []
    schedule = []
    time = ""
    title = ""
       
    for i = 0 to events.data.events.count()-1 
      	for each item in events.data.programs
      		if events.data.events[i].program = events.data.programs.[item].id 
       			assocArray = {}
       			time = events.data.events[i].start
  	      		strt = mid(time,12,5)
       			title = events.data.programs.[item].title
       			titleString = "[" + strt + "] " + title
       			assocArray.AddReplace("title",titleString)
       			assocArray.AddReplace("HDPosterUrl",events.data.programs.[item].thumbnail)
       			assocArray.AddReplace("Description",events.data.programs.[item].description)
       			programId.push(assocArray)
      	   	end if
      	end for
     	 	 schedule.push(programId[i])	
    end for
    return schedule
end function


'display list screeen'
function showScheduleScreen(schedule as object)
print "inside list screen  " schedule 
if schedule.count() <> 0 then
	screen = CreateObject("rolistscreen")
	screen.setMessagePort(m.port)
	screen.SetBreadcrumbText("Schedule ", "")
	screen.setcontent(schedule)
	screen.show()
	while true
		msg = wait(0,m.port)
		if type(msg) = "rolistscreenevent"
			key = msg.GetIndex()
		else if msg.isscreenclosed()
			exit while
		end if
	end while
    screen.close()
else
    showErrorMessageDialog(m.noScheduleText)
end if
end function