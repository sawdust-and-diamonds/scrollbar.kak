###############################################################################
#                               Scrollbar.kak                                 #
###############################################################################

# V0.0.1 makes no attempt to be computationally efficient!
# So, the scrollbar loop will be running all the time.
# I've had a lot of bugs with the solutions I've tried up until now, and it's
# a challenge to find a good one.
hook global InsertKey .* update-scrollbar
hook global NormalKey .* update-scrollbar
hook global InsertChar .* update-scrollbar
hook global NormalIdle .* update-scrollbar
hook global InsertIdle .* update-scrollbar

# Main scrollbar display loop
define-command update-scrollbar -hidden -override %{
    try %{
        check-hooks-enabled
        try %{
            check-scrollbar-option
            calculate-scrollbar-flags
            redraw-scrollbar
        } catch %{
            remove-scrollbar
        } 
    } catch %{
        nop
    }
}

# The line-specs option for our scrollbar
declare-option -hidden line-specs scrollbar_flags

# Set our "Scrollbar" face and character
face global Scrollbar rgb:808080
declare-option str scrollbar_char '▓'
# Unfortunately, I can't get our face information from a %sh expansion, so I've
# had to store this extra colour information with declare-option:
declare-option str scrollbar_sel_col1 "{rgb:9840d8}"
declare-option str scrollbar_sel_col2 "{rgb:ffb060}"
declare-option str scrollbar_sel_char '█'

# Gather arguments to send to our C script.
# The C program will process this information and return a string for our line-desc
# object. See the C file for more details.
define-command calculate-scrollbar-flags -hidden -override %{
    eval %sh{
        set --  $kak_window_range
        set --  "$1" \
                "$(( $1 + $3 ))" \
                "$kak_opt_scrollbar_char" \
                "$kak_selections_desc" \
                "$kak_opt_scrollbar_sel_col2$kak_opt_scrollbar_sel_char" \
                "$kak_opt_scrollbar_sel_col1$kak_opt_scrollbar_sel_char" \
                "$kak_buf_line_count" \
                "$kak_window_height"
        echo "set-option buffer scrollbar_flags $kak_timestamp " $(kak-calc-scrollbar "$@")
    }
}

# Graphically update the scrollbar
define-command redraw-scrollbar -hidden -override %{
    addhl -override window/ flag-lines Scrollbar scrollbar_flags
}

# Move scrollbar to the left when necessary - this is a user-activated command.
define-command move-scrollbar-to-left -override -docstring %{
    Move the scrollbar to the leftmost position in the stack of highlighters.
    } %{
    exec ':rmhl buffer/flag-lines<tab><ret>'
    redraw-scrollbar
}

###############################################################################
#                              Option Handling                                #
###############################################################################

# Option to turn scrollbar on and off
declare-option bool enable_scrollbar false
declare-option -hidden bool scrollbar_disable_hooks true

# Tell the hooks not to run while option is disabled
hook global WinSetOption enable_scrollbar=true %{
    set-option window scrollbar_disable_hooks false
}

# Remove the scrollbar for this window
define-command remove-scrollbar -hidden -override %{
    exec '<esc>:rmhl window/flag-lines<tab><ret>'
    set-option window scrollbar_disable_hooks true
}

# Check the scrollbar should be active
define-command check-scrollbar-option -hidden -override %{
    eval %sh{
        [ "$kak_opt_enable_scrollbar" = "false" ] && echo "fail"
    }
}

# Check whether we should be running the hooks
define-command check-hooks-enabled -hidden -override %{
    eval %sh{
        [ "$kak_opt_scrollbar_disable_hooks" = "true" ] && echo "fail"
    }
}
