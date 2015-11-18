function dvrMatch(schedule as object)

    log("DEBUG", " dvrMatch Function")

    if type(schedule) = "roArray" then
        if valid(schedule[0]) then
            eventId = schedule[0].eventId
        end if
    else
        matches = m.UpcomingMatchList
        dateTime = matches[schedule].start_time
        eventTime=mid(dateTime,0,16)
        airOn = strReplace(eventTime,"T"," at ")
        time = "This Match will air on : "+ airOn
        eventId = m.UpcomingMatches.data.events[schedule].id
    end if

    if m.myDvr.data.events.count() <> 0
        oldId = m.myDvr.data.events[0].event
    else
        oldId = "invalid"
    end if

        if valid(eventId) then
            port = CreateObject("roMessagePort")
            screen = CreateObject("roCodeRegistrationScreen")
            screen.SetMessagePort(port)
            if oldId <> "invalid" and m.myDvr.data.limit = 0
                screen.AddButton(1, "Yes, Overwrite my other DVR")
            else
                screen.AddButton(1, "DVR Match")
            end if
            screen.AddButton(2, "Cancel")
            if type(schedule) = "roArray" then
                title = mid(schedule[0].title,7)
            else
                title = matches[schedule].Title
            end if

            screen.AddFocalText(" ", "spacing-dense")
            if type(schedule) = "roArray" then
                screen.AddFocalText("This is playing now", "spacing-dense")
            else
                screen.AddFocalText(time, "spacing-dense")
            end if
            screen.AddFocalText(" ", "spacing-dense")
            screen.AddFocalText("Would you like to Schedule a DVR request for:", "spacing-dense")
            screen.AddFocalText(" ", "spacing-dense")
            screen.AddFocalText(title, "spacing-dense")
            screen.AddFocalText(" ", "spacing-dense")
            if m.myDvr.data.events.count() <> 0 and m.myDvr.data.limit = 0
                screen.AddFocalText("and Overwrite your existing DVR:", "spacing-dense")
                screen.AddFocalText(" ", "spacing-dense")
                screen.AddFocalText(m.myDvr.data.events[0].program.title, "spacing-dense")
                screen.AddFocalText(" ", "spacing-dense")
            end if

                screen.Show()

                while true
                    msg = wait(0, screen.GetMessagePort())
                    if type(msg) = "roCodeRegistrationScreenEvent"
                        if msg.isScreenClosed()
                            exit while
                        else if msg.isButtonPressed()
                            if (msg.GetIndex() = 1)
                                addDvr(eventId,oldId)
                                exit while
                            else if (msg.GetIndex() = 2)
                                exit while
                            endif
                        endif
                    endif
                end while
            screen.close()
    else
        showErrorMessageDialog("Error cannot perform action")
    end if
End Function