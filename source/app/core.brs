function initializeApplication() as Void
    log("DEBUG", " initializeApplication")

    identityEventReq   = Invalid
    identityCompleteEventReq = Invalid
    trackRokuLaunchEventReq = Invalid

    m.analytics = Analytics(m.userId, m.segmentIOAPIKeyValue, m.port)
    traits = {
        email: m.emailId,
        industry: "Sports"
        }
    identityEventReq = m.analytics.sendIdentityEvent("Roku Launch",traits)

    setDateime()
    initAppTimer = CreateObject("roTimespan")
    initAppTimer.mark()

    while true
        msg = wait(0, m.port)
        if type(msg) = "roUrlEvent" then
            if identityEventReq <> Invalid and msg.getSourceIdentity() = identityEventReq.getIdentity()  then
                checkPostResponse(msg)
                identityEventReq = Invalid
                identityCompleteEventReq = m.analytics.sendCompleteIdentityEvent("Roku Launch",traits)
            else if identityCompleteEventReq <> Invalid and msg.getSourceIdentity() = identityCompleteEventReq.getIdentity()  then                '
                checkPostResponse(msg)
                identityCompleteEventReq = Invalid
                rokuProperties = {
                    event: "Roku Launch",
                    plan: m.planName
                }
                trackRokuLaunchEventReq = m.analytics.sendRokuLaunchTrackEvent("Roku Launch", rokuProperties )
            else if trackRokuLaunchEventReq <> Invalid and msg.getSourceIdentity() = trackRokuLaunchEventReq.getIdentity()  then
                checkPostResponse(msg)
                trackRokuLaunchEventReq = Invalid
                exit While
            end if
        end if
    end while

    m.channels = apiParse("channel")
    m.shows = apiParse("show")
    m.UpcomingMatches = UpcomingMatches()
    m.appInitStatus = true
end function
