Function Analytics(userId as String, apiKey as string, port as Object) as Object
	log("DEBUG", " Analytics Function")

		appInfo = CreateObject("roAppInfo")
		this = {
			type: "Analytics"
			version: "1.0.3"

			apiKey: apiKey

			Init: init_analytics
			Submit: submit_analytics
			AddSessionDetails: AddSessionDetails
			AddScreenSessionDetails: AddScreenSessionDetails
			AddIdentifySessionDetails: AddIdentifySessionDetails
			GetGeoData: getGeoData_analytics

            sendScreenEvent: sendScreenEvent
			sendIdentityEvent: sendIdentityEvent
            sendCompleteIdentityEvent: sendCompleteIdentityEvent
            sendRokuLaunchTrackEvent: sendRokuLaunchTrackEvent
            sendRokuLinkedTrackEvent: sendRokuLinkedTrackEvent
            sendVideoTrackViewEvent: sendVideoTrackViewEvent

			UserAgent: appInfo.GetTitle() + " - " + appInfo.GetVersion()
			AppVersion: appInfo.GetVersion()
			AppName: appInfo.GetTitle()

			userId: userId
			port: port

			useGeoData: true

			queue: invalid
			timer: invalid

			lastRequest: invalid
		}
		this.init()
	return this

End Function

Function init_analytics() as void
	log("DEBUG", "init_analytics Called")

	if m.useGeoData = true and m.geoData = Invalid then
		m.GetGeoData()
	end if

	m.SetModeCaseSensitive()
	m.queue = CreateObject("roArray", 0, true)
	m.analyticsTimer = CreateObject("roTimeSpan")
	m.analyticsTimer.mark()

End Function

Function sendScreenEvent(screenName as String)as Object
    log("DEBUG", "sendScreenEvent Called")
    event = CreateObject("roAssociativeArray")
    event.action = "screen"
    event.name = screenName
    m.AddScreenSessionDetails(event)
    m.queue.push(event)
    request = m.submit()
    return request
End Function

Function AddSessionDetails(event as Object)
	log("DEBUG", "AddSessionDetails Called")

	event.timestamp = AnalyticsDateTime()
	event.userId = m.userId
	event.context = CreateObject("roAssociativeArray")

	if NOT event.DoesExist("options")
		options = CreateObject("roAssociativeArray")
		event.options = options
	end if

	library = CreateObject("roAssociativeArray")
	library.name = "SegmentIO-Brightscript"
	library.version = m.version

	event.options.library = library

	device = CreateObject("roDeviceInfo")

	deviceInfo = CreateObject("roAssociativeArray")
	deviceInfo.model = device.GetModel()
	deviceInfo.version = device.GetVersion()
	deviceInfo.manufacturer = "Roku"
	deviceInfo.name = device.GetModelDisplayName()
	deviceInfo.id = device.GetDeviceUniqueId()
	event.context.device = deviceInfo

	event.context.app = CreateObject("roAssociativeArray")
	event.context.app.name = m.AppName
	event.context.app.version = m.AppVersion
	event.context.useragent = m.useragent

	event.context.os = CreateObject("roAssociativeArray")
	event.context.os.version = device.GetVersion()
	event.context.os.name = "Roku"

	if m.geoData <> invalid
		location = CreateObject("roAssociativeArray")
		if m.geoData.DoesExist("country_code") then location.country = m.geoData.country_code
		if m.geoData.DoesExist("city") then location.city = m.geoData.city
		if m.geoData.DoesExist("longitude") then location.longitude = m.geoData.longitude
		if m.geoData.DoesExist("latitude") then location.latitude = m.geoData.latitude
		event.context.location = location

		if m.geoData.DoesExist("ip") then event.context.ip = m.geoData.ip
	end if

	ipAddress = device.GetIPAddrs()
	if ipAddress <> invalid
		event.context.ip = ipAddress.eth1
	end if
	event.context.os = device.GetVersion()

	locale = strReplace(device.GetCurrentLocale(), "_", "-")
	event.context.locale = locale

	screen = CreateObject("roAssociativeArray")
	screen.width = device.GetDisplaySize().w
	screen.height = device.getDisplaySize().h
	screen.type = device.GetDisplayType()
	screen.mode = device.GetDisplayMode()
	screen.ratio = device.GetDisplayAspectRatio()
	event.context.screen = screen

End Function

Function AddScreenSessionDetails(event as Object)
    log("DEBUG", "AddScreenSessionDetails Called")

	event.timestamp = AnalyticsDateTime()
	event.userId = m.userId

End Function


Function AddIdentifySessionDetails(event as Object)
    log("DEBUG", "AddIdentifySessionDetails Called")

	event.timestamp = AnalyticsDateTime()
	event.userId = m.userId

End Function

Function submit_analytics() as object

	request = CreateObject("roUrlTransfer")
	if m.queue.count() > 0 THEN
		log("DEBUG", "Submitting Analytics...")

		batch = CreateObject("roAssociativeArray")
		batch.SetModeCaseSensitive()
		batch.batch = m.queue

		batch.context = CreateObject("roAssociativeArray")
		batch.context.SetModeCaseSensitive()

		library = CreateObject("roAssociativeArray")
		library.name = "SegmentIO-Brightscript"
		library.version = m.version
		batch.context.library = library

		json = strReplace(FormatJson(batch), "userid", "userId") 'Because of the wonky way roAssociativeArrays keys don't care about case :\

		m.queue.clear()

		transfer = CreateObject("roUrlTransfer")

		'Authentication
		Auth = CreateObject("roByteArray")
		Auth.FromAsciiString(m.apiKey + ":")

		transfer.AddHeader("Authorization", "Basic " + Auth.ToBase64String())
		transfer.AddHeader("Accept", "application/json")
		transfer.AddHeader("Content-type", "application/json")
		transfer.SetUrl("https://api.segment.io/v1/import" )
		if m.port <> invalid then transfer.SetPort(m.port)

		transfer.EnablePeerVerification(false)
		transfer.EnableHostVerification(false)
		transfer.RetainBodyOnError(true)

		transfer.AsyncPostFromString(json)
		request = transfer
	end if
	m.analyticsTimer.mark()
	return request

End Function

function sendIdentityEvent(eventName as string, traits = invalid as Object)as Object
    log("DEBUG", "sendIdentityEvent Called")

    event = CreateObject("roAssociativeArray")
    event.SetModeCaseSensitive()
    event.action = "identify"
    event.name = eventName
    event.traits = traits
    m.AddIdentifySessionDetails(event)
    m.queue.push(event)
    request = m.submit()
    return request
end Function

function sendCompleteIdentityEvent(eventName as string, traits = invalid as Object)as Object
    log("DEBUG", "sendCompleteIdentityEvent Called")

    event = CreateObject("roAssociativeArray")
    event.SetModeCaseSensitive()
    event.action = "identify"
    event.name = eventName
    event.traits = traits
    m.AddSessionDetails(event)
    m.queue.push(event)
    request = m.submit()
    return request
end Function

function sendRokuLaunchTrackEvent(eventName as string, properties = invalid as Object)as Object
    log("DEBUG", "sendRokuLaunchTrackEvent Called")

    event = CreateObject("roAssociativeArray")
    event.action = "track"
    event.event = eventName
    event.properties = properties
    m.AddSessionDetails(event)
    m.queue.push(event)
    request = m.submit()
    return request
end Function

function sendRokuLinkedTrackEvent(eventName as string, traits = invalid as Object)as Object
    log("DEBUG", "sendRokuLinkedTrackEvent Called")
    event = CreateObject("roAssociativeArray")
    event.action = "track"
    event.event = eventName
    event.traits = traits
    m.AddSessionDetails(event)
    m.queue.push(event)
    request = m.submit()
    return request
end function

function sendVideoTrackViewEvent(eventName as string, traits = invalid as Object) as Object
    log("DEBUG", "sendVideoTrackViewEvent Called")

    event = CreateObject("roAssociativeArray")
    event.action = "track"
    event.event = eventName
    event.traits = traits
    m.AddSessionDetails(event)
    m.queue.push(event)
    request = m.submit()
    return request
end function

Function AnalyticsDateTime() as String
    log("DEBUG", "AnalyticsDateTime Called")

	date = CreateObject("roDateTime")
	date.mark()
	return DateToISO8601String(date, true)
End Function

'This queries the telize open GeoIP service Telize to get Geo and public IP data
Function getGeoData_analytics()

    if m.geoData = Invalid then
        log("DEBUG", "getGeoData_analytics Called")
        url = "http://www.telize.com/geoip"
        transfer = CreateObject("roUrlTransfer")
        transfer.SetUrl(url)
        data = transfer.GetToString()
        object = ParseJSON(data)
        m.geoData = object
    end if

End Function

Function DateToISO8601String(date As Object, includeZ = True As Boolean) As String
   iso8601 = PadLeft(date.GetYear().ToStr(), "0", 4)
   iso8601 = iso8601 + "-"
   iso8601 = iso8601 + PadLeft(date.GetMonth().ToStr(), "0", 2)
   iso8601 = iso8601 + "-"
   iso8601 = iso8601 + PadLeft(date.GetDayOfMonth().ToStr(), "0", 2)
   iso8601 = iso8601 + "T"
   iso8601 = iso8601 + PadLeft(date.GetHours().ToStr(), "0", 2)
   iso8601 = iso8601 + ":"
   iso8601 = iso8601 + PadLeft(date.GetMinutes().ToStr(), "0", 2)
   iso8601 = iso8601 + ":"
   iso8601 = iso8601 + PadLeft(date.GetSeconds().ToStr(), "0", 2)
   If includeZ Then
      iso8601 = iso8601 + "Z"
   End If
   Return iso8601
End Function

Function PadLeft(value As String, padChar As String, totalLength As Integer) As String
   While value.Len() < totalLength
      value = padChar + value
   End While
   Return value
End Function
