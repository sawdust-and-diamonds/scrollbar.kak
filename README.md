# Scrollbar.kak

This is a scrollbar for [*kakoune*](https://github.com/mawww/kakoune), the educated programmer's terminal editor of choice.

It uses the line-flagging feature and a compiled script to provide a real-time, smooth-as-silk scrollbar display. A limitation of this is that the scrollbar isn't a clickable UI element—you'll still have to roll your sleeves up and apply finger to keyboard to navigate around that document. This is kak, so you oughtta either be or get used to it!

This is **version 0.0.4**. The whole feature is—and will remain—somewhat experimental, and won't promise anything like a perfect experience, because it's not easy to implement as a plugin.

![Scrollbar image](https://i.ibb.co/kSsjsVj/scrollbar.png)

## See selections outside your current view

The scrollbar will show the locations of your selections as you make them, allowing you to see selections outside of your current view.

## Installation

Just put the `scrollbar.kak` into either your plugins or your autoload folder in kak's configuration directory. I highly recommend [plug.kak](https://github.com/andreyorst/plug.kak) to handle this for you.

## Using the scrollbar

Once you have scrollbar.kak and calc-scrollbar-kak installed, there is not much to do. Use the `scrollbar-enable` command to make it appear in the current window. You can set it for all windows in your `kakrc` like so:

```
hook global WinCreate .* %{ scrollbar-enable }
```

## Features & limitations

* The scrollbar can't display past the last line of the buffer, meaning that it will start to disappear as your view scrolls past the end of your document.

* In a window where one source line is soft-wrapped across two or more display lines, the scroll thumb size may be inaccurate, since it's not possible to put different flags on different display lines.

* The scrollbar is composed of simple terminal characters. Currently, it doesn't make use of any fancy tricks to make the display less granular than the height of a single character. 

* Some built-in kak commands mess with the flags list (scrollbar.kak's `line-spec` value), and there'll be a brief graphical glitch as one character-height of scrollbar is deleted and re-inserted. I haven't figured out a way to make the re-application apply more instantly.

### A built-in scrollbar for kakoune?

My next project is to write an update for kak's core that will allow you to build your own custom version of kak with 'baked-in' scrollbar functionality, and which won't have these limitations.

Hopefully it'll be possible to host this feature on the wonderful [hakoune](https://github.com/Delapouite/hakoune) project, a fork of kak with optional power features—for the most power-hungry of power users.

### Get in touch with more ideas

In the meantime, if you have any ideas as to how I can make `scrollbar-kak` more efficient in its execution, and thereby help it display even more smoothly, please let me know.

## Customization

There are a number of *face* options you can edit to customize your scrollbar's look:

`Scrollbar`: This sets the main face for your scrollbar column, i.e. its background colour and the main scrollbar colour.

`ScrollbarSel`: Sets the colour for in-view selections.

`ScrollbarHL`: Sets the colour for out-of-view selections, i.e. the scrollbar's display of selections that are outside your current view. I find it helpful to set this to a more... alarming colour, so that you notice when you are editing text outside your current view.

Here are a few examples of how you can change the scrollbar colours. Please enter `:doc faces` into kak for more information:

`set-face global Scrollbar rgb:7080a0,rgb:281090`

`set-face global ScrollbarSel green`

`set-face global ScrollbarHL @Information`

You can change which characters are used for displaying the scrollbar with the following options:

`scrollbar_char` : Sets the character used for the scrollbar.

`scrollbar_sel_char` : Sets the character used for selections.

Scrollbar.kak will try to store the compiled tool in the its own plugin folder, but there is the `scrollbar_plugin_path` option if you need to change where the tool is stored.

If you've set up the scrollbar and played about with adding new highlighters, you might want to push it back to its left-most position on the highlighter stack. To do so, use the `move-scrollbar-to-left` command.

## Integrating with Other Plugins

Most of the time, when the view changes it's because the user pressed a key, so we use Kakoune's `RawKey` hook to trigger redrawing the scrollbar. However, there are ways for the view to move without a keypress, like using `execute-keys` or the `:select` command. If you are the author of a plugin that uses such a technique, and you want the scrollbar to update automatically afterward without having to press a key, you can trigger the `ScrollEnd` user hook:

    trigger-user-hook ScrollEnd

## License

Oi! 'Ave you got a license for that scrollbar?

Actually, yes you have, because I'm releasing this under the MIT license. Though, to be honest, if you have grand ideas and want to use this elsewhere without the disclaimer or indeed under another license, just let me know and we can arrange it.
