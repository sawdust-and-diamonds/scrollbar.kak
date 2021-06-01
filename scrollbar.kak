###############################################################################
#                               Scrollbar.kak                                 #
###############################################################################

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

# Move scrollbar to the left when necessary, as a user-activated command.
define-command move-scrollbar-to-left -override -docstring %{
    Move the scrollbar to the leftmost position in the stack of highlighters.
    } %{
    rmhl window/scrollbar-kak
    addhl -override window/scrollbar-kak flag-lines Scrollbar scrollbar_flags
}

###############################################################################
#                              Setup Commands                                 #
###############################################################################

define-command scrollbar-enable -docstring %{
    Enable the scrollbar in the current window
} %{
    # Get notified when scrollbar data needs to be updated
    hook -group scrollbar-kak window RawKey .* update-scrollbar

    # Let other plugins notify us if they change the view without a keypress
    hook -group scrollbar-kak window User view-scrolled update-scrollbar

    # Update it right now
    update-scrollbar

    # Install the scrollbar highlighter
    addhl -override window/scrollbar-kak flag-lines Scrollbar scrollbar_flags
}

define-command scrollbar-disable -docstring %{
    Disable the scrollbar in the current window
} %{
    # Uninstall the scrollbar highlighter
    rmhl window/scrollbar-kak

    # Don't get notified when the scrollbar needs to be updated
    rmhooks window scrollbar-kak
}
