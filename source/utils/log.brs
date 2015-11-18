function log(level = "OFF" as String, text = "" as String) as Void
    logLevel = 5

    ' [OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE]
    levels = {
        OFF: 0
        FATAL: 1
        ERROR: 2
        WARN: 3
        INFO: 4
        DEBUG: 5
        TRACE: 6
    }

    separators = {
        OFF: ""
        FATAL: "//////////////////////////////////////////////////////////////////////////////////////////////////////////"
        ERROR: "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        WARN: ".........................................................................................................."
        INFO: ""
        DEBUG: ""
        TRACE: ""
    }


    if levels[level] <> levels.OFF and levels[level] <= logLevel then
        if separators[level] <> "" then print separators[level]
        print "[" + level + "] - "; text
        if separators[level] <> "" then print separators[level]
    end if
end function
