# Respect .profile things
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
fi

. "$HOME/.cargo/env"
