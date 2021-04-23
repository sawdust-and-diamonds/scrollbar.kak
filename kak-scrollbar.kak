###############################################################################
#                             A rough outline                                 #
###############################################################################

hook window InsertKey .* update-scrollbar
hook window NormalKey .* update-scrollbar
hook window InsertChar .* update-scrollbar-with-check
hook window NormalIdle .* update-scrollbar
hook window InsertIdle .* update-scrollbar

define-command update-scrollbar -override %{
    calculate-scrollbar-flags
    redraw-scrollbar
	save-cursor-state
}

define-command update-scrollbar-with-check -override %{
	try %{ check-if-pos-same } catch %{
	    calculate-scrollbar-flags
	    redraw-scrollbar
    	save-cursor-state
	}
}

# The line-specs option for our scrollbar
declare-option line-specs scrollbar_flags

# Set our "Scrollbar" face and character
face global Scrollbar rgb:606060
declare-option str scrollbar_char '▓'
# Unfortunately, I can't get our face information from a %sh expansion, so I've
# had to store this extra colour information with declare-option:
declare-option str scrollbar_sel_color1 "{rgb:ffb060}"
declare-option str scrollbar_sel_color2 "{rgb:ffb0b0}"
declare-option str scrollbar_sel_char '█'

# Save our cursor information so we know when to redraw and when not to.
declare-option int scrollbar_last_cursor_line
declare-option str scrollbar_last_window_range
declare-option int scrollbar_last_buf_line_count

# Check if window situation is the same; if not, raise an error so we can "catch" it
define-command check-if-pos-same -override %{
	eval %sh{
		[ "$kak_opt_scrollbar_last_cursor_line" -ne "$kak_cursor_line" ] ||\
		[ "$kak_opt_scrollbar_last_buf_line_count" -ne "$kak_buf_line_count" ] ||\
		[ "$kak_opt_scrollbar_last_window_range" != "$kak_window_range" ] && echo "fail"
	}
}

# Save current window situation for later checks.
define-command save-cursor-state -override -hidden %{
    set-option buffer scrollbar_last_cursor_line %val{cursor_line}
    set-option buffer scrollbar_last_buf_line_count %val{buf_line_count}
    set-option buffer scrollbar_last_window_range %val{window_range}
}

# Gather arguments to send to our C script.
# The C program will process this information and return a string for our line-desc
# object. See the C file for more details
define-command calculate-scrollbar-flags -override %{
    eval %sh{
        set --  $kak_window_range
        set --  "$1" \
                "$(( $1 + $3 - 1 ))" \
				"$kak_opt_scrollbar_char" \
			    "$kak_selections_desc" \
				"$kak_opt_scrollbar_sel_color1$kak_opt_scrollbar_sel_char" \
				"$kak_buf_line_count" \
				"$kak_window_height"
        echo "set-option buffer scrollbar_flags $kak_timestamp " $(calc-scrollbar "$@")
    }
}

# Graphically update the scrollbar
define-command redraw-scrollbar -override -hidden %{
    addhl -override buffer/ flag-lines Scrollbar scrollbar_flags
}

define-command move-scrollbar-to-left -override %{
    exec ':rmhl buffer/flag-lines<tab><ret>'
    redraw-scrollbar
}
