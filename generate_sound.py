
import math
import os
import struct
import wave

os.makedirs("assets/sounds", exist_ok=True)

sample_rate = 44100
duration = 0.12
frequency = 850

with wave.open("assets/sounds/tap.wav", "w") as audio:
    audio.setnchannels(1)
    audio.setsampwidth(2)
    audio.setframerate(sample_rate)

    for i in range(int(sample_rate * duration)):
        t = i / sample_rate
        envelope = (1 - t / duration) ** 2
        sample = int(
            12000 * envelope *
            math.sin(2 * math.pi * frequency * t)
        )
        audio.writeframes(struct.pack("<h", sample))

print("Tap sound created successfully!")
