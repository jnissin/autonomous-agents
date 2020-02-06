import ddf.minim.analysis.*;
import ddf.minim.*;
import java.util.HashMap;

class AudioManager
{
  float rmsSum;           // Used for smoothing
  float rmsSmoothFactor;  // Used for smoothing
  
  Minim minim;
  AudioPlayer sample;
  FFT fft;
  int numBins;
  float spectrumScale;
  float[] binMaximumAmplitudes;
  float maximumAmplitude;
  
  AudioManager(float rmsSmoothFactor)
  {
    this.minim = new Minim(applet);

    this.sample = null;
    this.rmsSmoothFactor = rmsSmoothFactor;
    this.rmsSum = 0.0;
    this.numBins = 32;
    this.spectrumScale = 1;
    this.binMaximumAmplitudes = new float[this.numBins];
    this.maximumAmplitude = 1.0;
  }
  
  void update()
  {
    // Perform a forward FFT on the samples in the mix buffer
    fft.forward(this.sample.mix);
  }
  
  void loadAudioFile(String filePath)
  {
    // Load and play a soundfile and loop it
    this.sample = this.minim.loadFile(filePath, 1024);
    this.sample.loop();
    
    // Create an FFT object that has a time-domain buffer the same size as the sample buffer
    // note: needs to be a power of two
    this.fft = new FFT(this.sample.bufferSize(), this.sample.sampleRate());
    
    // Calculate the averages by grouping frequency bands linearly
    this.fft.linAverages(this.numBins);
    
    // Initialize the overall maximum average
    this.maximumAmplitude = 1.0;
    
    // Initialize maximum aplitude values - 32 seems like a good guess
    this.binMaximumAmplitudes = new float[this.numBins];
    
    for (int i = 0; i < this.binMaximumAmplitudes.length; i++)
    {
      this.binMaximumAmplitudes[i] = 32.0 * this.spectrumScale;
    }
  }
  
  float getAmplitude()
  {
    float val =  this.fft.calcAvg(20.0, 20.0 * 1000);
    
    if (val > this.maximumAmplitude)
    {
      this.maximumAmplitude = val;
    }
    
    // Return a value between [0, 1]
    return map(val, 0, this.maximumAmplitude, 0, 1);
  }

  float getFrequency(int bin)
  {
    int binIdx = constrain(bin, 0, this.numBins - 1);
    float val = this.fft.getAvg(binIdx) * this.spectrumScale;
    
    if (val > this.binMaximumAmplitudes[binIdx])
    {
      this.binMaximumAmplitudes[binIdx] = val;
    }
    
    // Return a value between [0, 1]
    return map(val, 0, this.binMaximumAmplitudes[binIdx], 0, 1); 
  }
}
