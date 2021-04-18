###############################################################################
#                               What's next?                                  #
###############################################################################

# This is pretty amazing, but we still have a long way to go.
# 
# 2: Make the scrollbar stop at end of file
#       You will have to change the logic quite a bit
#       Determine scrollbar length, then determine final row
# 4: Find a way to add a line of space,
# 5: And make the visuals configurable, then...
# 6: Upload v0.0.1!

###############################################################################
#                             A rough outline                                 #
###############################################################################

hook window NormalIdle .* update-scrollbar
hook window InsertIdle .* update-scrollbar
# hook window NormalIdle .* move-scrollbar-to-left
hook window NormalKey .* update-scrollbar

define-command update-scrollbar -override %{
	try %{ check-if-pos-same } catch %{
	    save-scrollbar-pos
	    save-selections-pos
	    calculate-scrollbar-flags
	    # set-scrollbar-flags
	    redraw-scrollbar
	}
}

# Set up our new face
# face global Scrollbar yellow+d
face global Scrollbar rgb:606060
face global ScrollbarSelection rgb:F0F060
declare-option str scrollbar_face "{rgb:ffb060}"

# Set the line-specs option for our scrollbar
declare-option line-specs scrollbar_flags

# Format: "XX-YY", where XX & YY are line numbers
declare-option str scrollbar_pos
declare-option int scrollbar_last_cursor_line
# Format: "X1-Y1|X2-Y2|...XN|YN", where Xi & Yi are line numbers
declare-option str scrollbar_selection_lines

# Character for scrollbar
declare-option str scrollbar_char '▒'
declare-option str scrollbar_sel_char '█'

# Check if cursor position is the same; if not, raise an error so we can "catch" it
define-command check-if-pos-same -override %{
	eval %sh{
		[ "$kak_opt_scrollbar_last_cursor_line" -ne "$kak_cursor_line" ] && echo "fail"
	}
}

define-command save-scrollbar-pos -override %{
    eval %sh{
        set -- $kak_window_range
        y_start=$1
        y_end=$(( $1 + $3 - 1 ))
        echo "set-option buffer scrollbar_pos '$y_start $y_end'"
    }
}

define-command calculate-scrollbar-flags -override %{
    eval %sh{
        # Get our base values
        set -- $kak_opt_scrollbar_pos
        y_start=$1
        y_end=$2
        win_h=$(( $2 - $1 + 1 ))
        buf_h=$kak_buf_line_count
        # What is the maximum line we can draw flags to?
        max_line=$([ $win_h -gt $buf_h ] && echo $buf_h || echo $win_h)
        # Take the min of buffer length & last displayed line
        y_end=$([ $y_end -gt $buf_h ] && echo $buf_h || echo $y_end)
        # Calculate our position
        get_flag_line() {
            pct=$(( $1 * 100 / buf_h ))
            printf "%.0f" $(echo "scale=2;$y_start+$max_line*$pct/100" | bc)
        }
        # Get scrollbar line start & end
        scrollbar_start=$(get_flag_line $y_start)
        scrollbar_end=$(get_flag_line $y_end)
        # echo "set-option buffer scrollbar_pos '$scrollbar_start $scrollbar_end'"
        # Get flag chars
        face="$kak_opt_scrollbar_face"
        char1="$kak_opt_scrollbar_char"
        char2="$kak_opt_scrollbar_sel_char"
        flags="$kak_timestamp"
        # Selection flags
        sel_lines=""
        for i in $kak_opt_scrollbar_selection_lines; do
            sel_lines="$(get_flag_line $i)\n$sel_lines"
        done
        sel_lines=$(echo "$sel_lines" | uniq | sort -n | tr '\n' ' ')
        for i in $sel_lines; do
            flags="$flags $i|$face$char2"
        done
        # Flags for main scrollbar
        for i in $(seq $scrollbar_start $scrollbar_end); do
            flags="$flags $i|$char1"
        done
        echo "set-option buffer scrollbar_flags $flags"
    }
}

define-command save-selections-pos -override %{
    eval %sh{
        set -- $kak_selections_desc
        get_line() {
            # Takes 1 argument, a 'selection_desc' (format: Y1.X1,Y2.X2)
			IFS=','; set -- $1
			IFS='.'; set -- $1 $2
			[ "$1" -le "$3" ] && line="$(seq $1 $3)" || line="$(seq $3 $1)"
            # line=$(echo $(eval echo "{$1..$3}") | tr ' ' '\n')
            IFS=' '
	    }
	    lines=""
		for desc in "$@"; do
			get_line $desc
			lines="$line\n$lines"
		done
		lines=$(echo "$lines" | uniq | tr '\n' ' ')
            echo "set-option buffer scrollbar_selection_lines '$lines'"
    }
}

define-command redraw-scrollbar -override -hidden %{
    addhl -override buffer/ flag-lines Scrollbar scrollbar_flags
}

define-command move-scrollbar-to-left -override %{
    exec ':rmhl buffer/flag-lines<tab><ret>'
    redraw-scrollbar
}
