import pygame
import time
import os

def play_audio():
    pygame.mixer.init()
    audio_file = "/app/audio/test_audio.mp3"
    
    if not os.path.exists(audio_file):
        print(f"Error: Audio file not found at {audio_file}")
        return

    print(f"Playing audio file: test_audio.mp3")

    pygame.mixer.music.load(audio_file)
    pygame.mixer.music.play()
   
    # Keep the script running while the audio plays
    while pygame.mixer.music.get_busy():
        time.sleep(1)

if __name__ == "__main__":
    print("Starting audio playback...")
    play_audio()
    print("Audio playback finished.")