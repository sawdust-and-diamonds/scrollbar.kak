###############################################################################
#                               Scrollbar.kak                                 #
###############################################################################

# Turn on the main scrollbar-drawing hook(s)
define-command turn-on-scrollbar-hooks -hidden -override %{
    hook -group scrollbar-kak -always window RawKey .* update-scrollbar
}

# The line-specs option for our scrollbar
declare-option -hidden line-specs scrollbar_flags

# Try to store the plugin in the plugin folder if we can
declare-option -hidden str scrollbar_plugin_path %sh{ dirname "$kak_source" }

# I've chosen some default colours and scrollbar character styles which work
# well for my colour schemes; please customize them at your leisure.
face global Scrollbar +d@Default             # Set our Scrollbar face and character
face global ScrollbarSel +r@PrimarySelection # Show selections within the scrollbar
face global ScrollbarHL +r@SecondaryCursor   # For selections outside of the scrollbar
declare-option str scrollbar_char '▓'
declare-option str scrollbar_sel_char '█'

# Gather arguments to send to our C script.
# The C program will process this information and return a string for our line-desc
# object. See the C file for more details.
define-command update-scrollbar -hidden -override %{
    eval %sh{
        set -- $kak_window_range
        # 1st argument = window start, 2nd = window line count
        set -- "$1" \
               "$(( $1 + $3 ))" \
               "$kak_selections_desc" \
               "$kak_opt_scrollbar_char" \
               "$kak_opt_scrollbar_sel_char" \
               "$kak_buf_line_count" \
               "$kak_window_height"
        echo "set-option buffer scrollbar_flags $kak_timestamp " $("$kak_opt_scrollbar_plugin_path"/kak-calc-scrollbar  "$@")
    }
}   

# Launch / update the scrollbar highlighter
define-command draw-scrollbar -hidden -override %{
    addhl -override window/scrollbar-kak flag-lines Scrollbar scrollbar_flags
}

# Remove the scrollbar for this window
define-command remove-scrollbar -hidden -override %{
    rmhl window/scrollbar-kak
    rmhooks window scrollbar-kak
}

# Move scrollbar to the left when necessary, as a user-activated command.
define-command move-scrollbar-to-left -override -docstring %{
    Move the scrollbar to the leftmost position in the stack of highlighters.
    } %{
    rmhl window/scrollbar-kak
    redraw-scrollbar
}

###############################################################################
#                              Option Handling                                #
###############################################################################

# Option to turn scrollbar on and off
declare-option bool enable_scrollbar false

# Apply hooks when option is turned on
hook global WinSetOption enable_scrollbar=true %{
    turn-on-scrollbar-hooks
    update-scrollbar
    draw-scrollbar
}

# Remove hooks when option is turned off
hook global WinSetOption enable_scrollbar=false %{
    remove-scrollbar
}
