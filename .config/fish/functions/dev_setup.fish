function dev_setup
    # Launch VSCodium on workspace 1
    hyprctl dispatch workspace 1
    vscodium &
    sleep 1
    
    # Launch Firefox with localhost:3000 on workspace 2
    hyprctl dispatch workspace 2
    firefox http://localhost:3000 &
    sleep 1
    
    # Launch terminal on workspace 3, start PostgreSQL, and run npm dev
    hyprctl dispatch workspace 3
    kitty fish -c '
        echo "Starting PostgreSQL..."
        sudo systemctl start postgresql
        and begin
            echo ""
            echo "Navigating to Tatsu directory and starting dev server..."
            cd ~/Tatsu
            npm run dev
        end
    ' &
    
    # Return to workspace 1
    sleep 1
    hyprctl dispatch workspace 1
end
