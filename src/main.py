import os
   import random
   from gpiozero import RotaryEncoder, Button
   import pygame
   import dropbox

   # Dropbox configuration (you'll need to set this up)
   DROPBOX_ACCESS_TOKEN = 'YOUR_DROPBOX_ACCESS_TOKEN'

   # GPIO pin configuration
   LEFT_POT_CLK = 17
   LEFT_POT_DT = 18
   LEFT_POT_SW = 27
   RIGHT_POT_CLK = 22
   RIGHT_POT_DT = 23
   RIGHT_POT_SW = 24

   # Audio settings
   AUDIO_DIR = '/home/pi/radio_tracks'
   DECADES = ['1920s', '1930s', '1940s', '1950s', '1960s', '1970s', '1980s', '1990s', '2000s', '2010s', '2020s']

   class TimeTravelingRadio:
       def __init__(self):
           self.left_pot = RotaryEncoder(LEFT_POT_CLK, LEFT_POT_DT)
           self.left_switch = Button(LEFT_POT_SW)
           self.right_pot = RotaryEncoder(RIGHT_POT_CLK, RIGHT_POT_DT)
           self.right_switch = Button(RIGHT_POT_SW)
           
           self.current_decade_index = 0
           self.current_track_index = 0
           self.is_on = False
           self.volume = 0
           
           pygame.mixer.init()
           self.tracks = self.load_tracks()

       def load_tracks(self):
           tracks = {}
           for decade in DECADES:
               decade_dir = os.path.join(AUDIO_DIR, decade)
               tracks[decade] = [f for f in os.listdir(decade_dir) if f.endswith('.mp3')]
           return tracks

       def update_tracks_from_dropbox(self):
           dbx = dropbox.Dropbox(DROPBOX_ACCESS_TOKEN)
           for decade in DECADES:
               dropbox_path = f'/radio_tracks/{decade}'
               local_path = os.path.join(AUDIO_DIR, decade)
               
               # Download new files from Dropbox
               for entry in dbx.files_list_folder(dropbox_path).entries:
                   if isinstance(entry, dropbox.files.FileMetadata):
                       local_file_path = os.path.join(local_path, entry.name)
                       if not os.path.exists(local_file_path):
                           dbx.files_download_to_file(local_file_path, f'{dropbox_path}/{entry.name}')
           
           # Reload tracks after update
           self.tracks = self.load_tracks()

       def handle_left_pot(self):
           if self.left_pot.value > 0:
               self.volume = min(1.0, self.volume + 0.1)
           else:
               self.volume = max(0.0, self.volume - 0.1)
           pygame.mixer.music.set_volume(self.volume)

       def handle_right_pot(self):
           if self.right_pot.value > 0:
               self.current_track_index = (self.current_track_index + 1) % len(self.tracks[DECADES[self.current_decade_index]])
           else:
               self.current_track_index = (self.current_track_index - 1) % len(self.tracks[DECADES[self.current_decade_index]])
           self.play_current_track()

       def handle_left_switch(self):
           self.is_on = not self.is_on
           if self.is_on:
               self.play_current_track()
           else:
               pygame.mixer.music.stop()

       def handle_right_switch(self):
           if not self.is_on:
               self.current_decade_index = (self.current_decade_index + 1) % len(DECADES)
               self.current_track_index = 0

       def play_current_track(self):
           if self.is_on:
               decade = DECADES[self.current_decade_index]
               track = self.tracks[decade][self.current_track_index]
               pygame.mixer.music.load(os.path.join(AUDIO_DIR, decade, track))
               pygame.mixer.music.play()

       def run(self):
           self.left_pot.when_rotated = self.handle_left_pot
           self.right_pot.when_rotated = self.handle_right_pot
           self.left_switch.when_pressed = self.handle_left_switch
           self.right_switch.when_pressed = self.handle_right_switch
           
           while True:
               # Main loop
               pass

   if __name__ == "__main__":
       radio = TimeTravelingRadio()
       radio.run()