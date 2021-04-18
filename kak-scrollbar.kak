###############################################################################
#                               hahaha! Todo                                  #
###############################################################################

# 1: Determine when best to redraw.
#       PROBABLY you should run a test to see if window moved, then redraw
#       AND then include it in all Insert and Normal keypresses
#       See if you can make try/catch into if/then logic
# 2: Make the scrollbar stop at end of file
#       You will have to change the logic quite a bit
#       Determine scrollbar length, then determine final row
# 2.5: Work on showing selections as well.
# 3: Make the scrollbar move left beyond all other highlights
# 4: Find a way to add a line of space,
# 5: And make the visuals configurable, then...
# 6: Upload v0.0.1!

###############################################################################
#                                 Debugging                                   #
###############################################################################

# TODO...

###############################################################################
#                             A rough outline                                 #
###############################################################################

hook window NormalIdle .* update-scrollbar
# hook window NormalIdle .* move-scrollbar-to-left
hook window NormalKey .* update-scrollbar

define-command update-scrollbar -override %{
	try %{ check-if-pos-same } catch %{
	    calculate-scrollbar-pos
	    calculate-selections-pos
	    set-scrollbar-flags
	    redraw-scrollbar
	}
}

# Set up our new face
# face global Scrollbar yellow+d
face global Scrollbar rgb:606060
face global ScrollbarSelection rgb:F0F060

# Set the line-specs option for our scrollbar
declare-option line-specs scrollbar_flags

# Format: "XX-YY", where XX & YY are line numbers
declare-option str scrollbar_pos
declare-option int scrollbar_last_cursor_line
# Format: "X1-Y1|X2-Y2|...XN|YN", where Xi & Yi are line numbers
declare-option str scrollbar_selections_pos

# Character for scrollbar
declare-option str scrollbar_char '▒'

# Check if cursor position is the same; if not, raise an error so we can "catch" it
define-command check-if-pos-same -override %{
	eval %sh{
		[ "$kak_opt_scrollbar_last_cursor_line" -ne "$kak_cursor_line" ] && echo "fail"
	}
}

define-command calculate-scrollbar-pos -override %{
    eval %sh{
        # Get our base values
        set -- $kak_window_range
        y_start=$1
        y_end=$(( $1 + $3 - 1 ))
        win_h=$3
        buf_h=$kak_buf_line_count
        # What is the maximum line we can draw flags to?
        max_line=$([ $win_h -gt $buf_h ] && echo $buf_h || echo $win_h)
        # Take the min of buffer length & last displayed line
        y_end=$([ $y_end -gt $buf_h ] && echo $buf_h || echo $y_end)
        # Calculate our position
        start_pct=$(( ( y_start * 100 ) / buf_h ))
        end_pct=$(( ( y_end * 100 ) / buf_h ))
        # Get scrollbar line start & end
        scrollbar_start=$(printf "%.0f" $(echo "scale=2;$1+$max_line*$start_pct/100" | bc))
        scrollbar_end=$(printf "%.0f" $(echo "scale=2;$1+$max_line*$end_pct/100" | bc))
        # Set the option
        echo "set-option buffer scrollbar_pos '$scrollbar_start $scrollbar_end'"
    }
}

define-command calculate-selections-pos -override %{
    eval %sh{
        set -- $kak_selections_desc
        get_line() {
            # Takes 1 argument, a 'selection_desc' (format: Y1.X1,Y2.X2)
			IFS=','; set -- $1
			IFS='.'; set -- $1 $2
			[ "$1" -le "$3" ] && line="$(seq $1 $3)" || line="$(seq $3 $1)"
			# line=$(echo $(eval echo "{$1..$3}") | tr ' ' '\n')
	    }
	    lines=""
		for desc in "$@"; do
			get_line $desc
			lines="$line\n$lines"
		done
		lines=$(echo "$lines" | uniq | tr '\n' ' ')
		echo "set-option buffer scrollbar_selections_pos '$lines'"
    }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        #EOF                                               vim: set ai sw=4 syn=boxes:)}]))]))]))))))))))))})})))
define-command set-scrollbar-flags -override -hidden %{
    eval %sh{
        flags="$kak_timestamp"
        char="$kak_opt_scrollbar_char"
        set -- $kak_opt_scrollbar_pos
        for i in $(seq "$1" "$2"); do
            flags="$flags $i|$char"
        done
        echo "set-option buffer scrollbar_flags $flags"
    }
}

define-command redraw-scrollbar -override -hidden %{
    addhl -override buffer/ flag-lines Scrollbar scrollbar_flags
}

define-command move-scrollbar-to-left -override %{
    exec ':rmhl buffer/flag-lines<tab><ret>'
    redraw-scrollbar
}
