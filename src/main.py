import RPi.GPIO as GPIO
import time
import os
import pygame
from gpiozero import RotaryEncoder, Button

# Initialize pygame mixer
pygame.mixer.init()

# GPIO setup
GPIO.setmode(GPIO.BCM)

# Potentiometer pins
LEFT_CLK = 17
LEFT_DT = 18
LEFT_SW = 27
RIGHT_CLK = 22
RIGHT_DT = 23
RIGHT_SW = 24

# Set up rotary encoders and buttons
left_pot = RotaryEncoder(LEFT_CLK, LEFT_DT)
left_button = Button(LEFT_SW)
right_pot = RotaryEncoder(RIGHT_CLK, RIGHT_DT)
right_button = Button(RIGHT_SW)

# Global variables
power_on = False
current_decade = 1950
current_track = 0
volume = 50
decades = [1950, 1960, 1970, 1980, 1990, 2000, 2010, 2020]

def load_tracks(decade):
    """Load tracks for the given decade."""
    tracks = os.listdir(f"/app/audio/{decade}")
    return [f"/app/audio/{decade}/{track}" for track in tracks if track.endswith('.mp3')]

def play_track(track_path):
    """Play the given track."""
    pygame.mixer.music.load(track_path)
    pygame.mixer.music.play()

def stop_track():
    """Stop the currently playing track."""
    pygame.mixer.music.stop()

def change_volume(direction):
    """Change the volume up or down."""
    global volume
    volume = max(0, min(100, volume + direction * 5))
    pygame.mixer.music.set_volume(volume / 100)

def time_travel_effect():
    """Play a time travel sound effect."""
    effect = pygame.mixer.Sound("/app/audio/time_travel_effect.wav")
    effect.play()
    time.sleep(2)  # Wait for the effect to finish

def handle_left_pot():
    """Handle left potentiometer events."""
    global power_on
    if left_button.is_pressed:
        power_on = not power_on
        if power_on:
            play_track(current_tracks[current_track])
        else:
            stop_track()
    else:
        change_volume(left_pot.value)

def handle_right_pot():
    """Handle right potentiometer events."""
    global current_decade, current_track, current_tracks
    if right_button.is_pressed:
        # Change decade
        decade_index = (decades.index(current_decade) + 1) % len(decades)
        current_decade = decades[decade_index]
        current_tracks = load_tracks(current_decade)
        current_track = 0
        if power_on:
            time_travel_effect()
            play_track(current_tracks[current_track])
    else:
        # Change track
        direction = 1 if right_pot.value > 0 else -1
        current_track = (current_track + direction) % len(current_tracks)
        if power_on:
            play_track(current_tracks[current_track])

def main():
    global current_tracks
    current_tracks = load_tracks(current_decade)

    try:
        while True:
            handle_left_pot()
            handle_right_pot()
            time.sleep(0.1)  # Small delay to prevent excessive CPU usage
    except KeyboardInterrupt:
        GPIO.cleanup()

if __name__ == "__main__":
    main()