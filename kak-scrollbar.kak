###############################################################################
#                             A rough outline                                 #
###############################################################################

hook window InsertKey .* update-scrollbar
hook window NormalKey .* update-scrollbar

define-command update-scrollbar -override %{
	try %{ check-if-pos-same } catch %{
	    save-scrollbar-pos
	    # save-selections-pos
	    calculate-scrollbar-flags
	    redraw-scrollbar
	}
}

# Set our "Scrollbar" face and character
face global Scrollbar rgb:606060
declare-option str scrollbar_char '▓'
# Unfortunately, I can't get our face information froma %sh expansion, so I've
# had to store this extra colour information with declare-option:
declare-option str scrollbar_sel_color1 "{rgb:ffb060}"
declare-option str scrollbar_sel_color2 "{rgb:ffb0b0}"
declare-option str scrollbar_sel_char '█'

# The line-specs option for our scrollbar
declare-option line-specs scrollbar_flags

# Store our current scrollbar position
declare-option str scrollbar_pos # "X,Y", where X & Y are line numbers

# Save our cursor information so we know when to redraw and when not to.
declare-option int scrollbar_last_cursor_line

# Check if cursor position is the same; if not, raise an error so we can "catch" it
define-command check-if-pos-same -override %{
	eval %sh{
		[ "$kak_opt_scrollbar_last_cursor_line" -ne "$kak_cursor_line" ] && echo "fail"
	}
}

# Save the top and bottom lines of the visible window
# (This I've called our "scrollbar-pos", because the scrollbar shows only the
# bounds of the current window.)
define-command save-scrollbar-pos -override %{
    eval %sh{
        set -- $kak_window_range
        y_start=$1
        y_end=$(( $1 + $3 - 1 ))
        echo "set-option buffer scrollbar_pos '$y_start,$y_end'"
    }
}

define-command calculate-scrollbar-flags -override %{
    eval %sh{
        set --  $kak_window_range
        set --  "$kak_opt_scrollbar_pos"\
				"$kak_opt_scrollbar_char" \
			    "$kak_selections_desc"\
				"{rgb:ffb060}$kak_opt_scrollbar_sel_char" \
				"$kak_buf_line_count"\
				"$kak_window_height"\
				"$1"
        echo "set-option buffer scrollbar_flags $kak_timestamp " $(calc-scrollbar "$@")
    }
}

define-command redraw-scrollbar -override -hidden %{
    addhl -override buffer/ flag-lines Scrollbar scrollbar_flags
}

define-command move-scrollbar-to-left -override %{
    exec ':rmhl buffer/flag-lines<tab><ret>'
    redraw-scrollbar
}
