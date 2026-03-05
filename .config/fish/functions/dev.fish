function dev --description 'Launch VSCodium, Firefox:localhost:3000, start postgres + npm dev in new terminal (for Hyprland)'
    # fail early if hyprctl missing
    if not command -v hyprctl > /dev/null
        echo "Error: hyprctl not found in PATH. Install Hyprland's hyprctl or adjust the function."
        return 1
    end
    
    # find a VSCodium executable
    if command -v codium > /dev/null
        set vsc_cmd codium
    else if command -v vscodium > /dev/null
        set vsc_cmd vscodium
    else if command -v code > /dev/null
        set vsc_cmd code
    else
        echo "Warning: VSCodium/Code not found in PATH. Function will still try 'codium' but may fail."
        set vsc_cmd codium
    end
    
    # choose a terminal emulator (first available)
    set -l term_choice
    for t in alacritty kitty foot gnome-terminal xterm
        if command -v $t > /dev/null
            set term_choice $t
            break
        end
    end
    
    if test -z "$term_choice"
        echo "Error: No supported terminal found (looked for alacritty, kitty, foot, gnome-terminal, xterm)."
        return 1
    end
    
    # Workspace 1: launch VSCodium
    hyprctl dispatch workspace 1
    sleep 0.15
    # start in background and detach
    nohup $vsc_cmd > /dev/null 2>&1 & disown
    
    # Workspace 2: launch Firefox to localhost:3000 in new window
    hyprctl dispatch workspace 2
    sleep 0.15
    nohup firefox --new-window "http://localhost:3000" > /dev/null 2>&1 & disown
    
    # Workspace 3: create a small temporary script that will run inside a new terminal.
    set -l tmp_script (mktemp /tmp/devstart.XXXXXX)
    printf '%s\n' '#!/bin/sh' \
                'read -s -p "sudo password: " pw' \
                'echo' \
                'printf "%s\n" "$pw" | sudo -S systemctl start postgresql' \
                'cd "$HOME/Tatsu" || exit 1' \
                'npm run dev' \
                > $tmp_script
    chmod +x $tmp_script
    
    # switch to workspace 3 and spawn a terminal to run the temp script (the new terminal will prompt for sudo password)
    hyprctl dispatch workspace 3
    sleep 0.15
    
    switch $term_choice
        case alacritty
            # alacritty: -e <command...>
            alacritty -e sh -c "$tmp_script" >/dev/null 2>&1 & disown
        case kitty
            kitty sh -c "$tmp_script" >/dev/null 2>&1 & disown
        case foot
            foot sh -c "$tmp_script" >/dev/null 2>&1 & disown
        case gnome-terminal
            # gnome-terminal prefers: -- bash -c "..."
            gnome-terminal -- bash -c "$tmp_script; exec bash" >/dev/null 2>&1 & disown
        case xterm
            xterm -e sh -c "$tmp_script" >/dev/null 2>&1 & disown
    end
    
    # small pause to ensure new terminal picked up the script file
    sleep 0.2
    
    # finally, exit the shell that called this function (this closes the terminal that invoked devstart)
    exit
end
