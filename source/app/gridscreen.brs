Function showGridScreen() 

    print "enter showGridScreen"
    screen = CreateObject("roGridScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.SetDisplayMode("scale-to-fill")
    screen.setGridStyle("four-column-flat-landscape")
    m.categoryList = ["Channels", "Live Matches","DVR"]
    getshows()
    screen.setupLists(m.categoryList.count())
    screen.SetListNames(m.categoryList)
    screen.SetContentList(0,getChannels())
    screen.SetContentList(1,liveMatches())
    
    for i = 3 to m.categoryList.count()-1
        screen.SetContentList(i,getShowDetails(m.categoryList[i]))
    end for
    screen.Show()
    while true
        msg = wait(0, port)
        if type(msg) = "roGridScreenEvent" then
            if msg.isListItemFocused() then
                screen.show()
            else if msg.isListItemSelected() then
                print"list item focused | current show = "; msg.GetIndex()
                row = msg.GetIndex()    
                m.selection = msg.getData() 
                if row = 0  'for channels'
                    DisplayDetailScreen(m.selection)  
                else if row = 1  'for live matches'
                    liveMatchesDetailScreen(m.selection)
                  else if row > 2 and row < m.categoryList.count()
                        EpisodeDetailScreen(row,m.selection)
                end if
            else if msg.isScreenClosed() then 
                exit while
            end if  
        end if
    end while
    screen.close()
End Function

function getChannels() as object

    playList = []

         if(m.channels.data.count() <> 0)
            for i = 0 to m.channels.data.count()-1 step 1
                assocArray = {}              
                retUrl= m.channels.data[i].assets.thumbnail
               if(retUrl<>Invalid)
                    st=tostr(retUrl)
                    newUrl=strReplace(st,"https","http")
                    assocArray.AddReplace("HDPosterUrl",newUrl)
                    assocArray.AddReplace("Title",m.channels.data[i].title)
                    assocArray.AddReplace("Description",m.channels.data[i].description)
                    playlist.push(assocArray)
                end if
            end for
            else
                assocArray = {}
                assocArray.AddReplace("Description","Empty Playlist")
                playlist.push(assocArray)
        end if
     return playlist
end function

function getshows() as object
    shows = ""
    for i = 0 to m.shows.data.count()-1
       shows = m.shows.data[i].title
       m.categoryList.push(m.shows.data[i].title)
    end for
end function
      

function getShowDetails(showName as string) as object
    print "inside show details  " showName
    playList = []
    if m.shows.data.count() <> 0 then
        for i = 0 to m.shows.data.count()-1
            if m.shows.data[i].video.count() <> 0 then
                if m.shows.data[i].title = showName then
                    for j = 0 to  m.shows.data[i].video.count()-1
                        assocArray = {}   
                        retUrl= m.shows.data[i].video[j].thumb_image.big
                       if(retUrl<>Invalid)
                            st=tostr(retUrl)
                            newUrl=strReplace(st,"https","http")  
                            assocArray.AddReplace("HDPosterUrl",newUrl)
                            assocArray.AddReplace("Title",m.shows.data[i].video[j].title)
                            assocArray.AddReplace("slug",m.shows.data[i].video[j].slug)
                            playlist.push(assocArray)
                        end if
                    end for
                end if
            end if
        end for
        return playlist
    else
        showErrorMessageDialog(m.loadingDataErrorText)
    end if
end function

function liveMatches()
    print "live matches details "
    playList = []
    if m.liveMatches.data.count() <> 0 then
        for i = 0 to m.liveMatches.data.count()-1
            for j = 0 to m.liveMatches.data[i].matches.count()-1
                assocArray = {}              
                retUrl= m.liveMatches.data[i].matches[j].program.thumbnail
                if(retUrl<>Invalid)
                    st=tostr(retUrl)
                    newUrl=strReplace(st,"https","http")
                    assocArray.AddReplace("HDPosterUrl",newUrl)
                    assocArray.AddReplace("Title",m.liveMatches.data[i].matches[j].program.title)
                    assocArray.AddReplace("Description",m.liveMatches.data[i].matches[j].program.description)
                    assocArray.AddReplace("ID",m.liveMatches.data[i].matches[j].channel.id)
                    playlist.push(assocArray)
                end if
            end for
        end for
        return playlist
    else 
        showErrorMessageDialog(m.loadingDataErrorText)
    end if
end function