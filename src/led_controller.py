from rpi_ws281x import PixelStrip, Color
   import time

   # LED strip configuration:
   LED_COUNT = 16      # Number of LED pixels.
   LED_PIN = 18        # GPIO pin connected to the pixels (18 uses PWM!).
   LED_FREQ_HZ = 800000  # LED signal frequency in hertz (usually 800khz)
   LED_DMA = 10        # DMA channel to use for generating signal (try 10)
   LED_BRIGHTNESS = 255  # Set to 0 for darkest and 255 for brightest
   LED_INVERT = False  # True to invert the signal (when using NPN transistor level shift)
   LED_CHANNEL = 0     # set to '1' for GPIOs 13, 19, 41, 45 or 53

   strip = PixelStrip(LED_COUNT, LED_PIN, LED_FREQ_HZ, LED_DMA, LED_INVERT, LED_BRIGHTNESS, LED_CHANNEL)
   strip.begin()

   def time_travel_effect():
       # Time travel effect
       for i in range(strip.numPixels()):
           strip.setPixelColor(i, Color(0, 0, 255))  # Blue color
           strip.show()
           time.sleep(0.05)
       
       # Flash effect
       for _ in range(3):
           for i in range(strip.numPixels()):
               strip.setPixelColor(i, Color(255, 255, 255))  # White color
           strip.show()
           time.sleep(0.1)
           for i in range(strip.numPixels()):
               strip.setPixelColor(i, Color(0, 0, 0))  # Off
           strip.show()
           time.sleep(0.1)
   
   # Call this function when changing decades
   # time_travel_effect()