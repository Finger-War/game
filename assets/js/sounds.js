const SoundManager = {
  sounds: {
    start_match: '/sounds/start_match.wav',
    correct: '/sounds/correct.wav',
    incorrect: '/sounds/incorrect.wav',
    countdown: '/sounds/countdown.wav',
    victory: '/sounds/victory.wav',
    defeat: '/sounds/defeat.wav',
    typing: '/sounds/typing.mp3',
  },
  
  audioElements: {},
  
  initialize() {
    Object.keys(this.sounds).forEach(key => {
      const audio = new Audio(this.sounds[key]);
      audio.preload = 'auto';
      audio.volume = 0.25;
      this.audioElements[key] = audio;
      audio.load();
    });
    
    return this;
  },
  
  play(sound) {
    const audio = this.audioElements[sound];
    if (!audio) {
      return;
    }
    
    try {
      if (audio.readyState >= 2) {
        audio.currentTime = 0;
        const playPromise = audio.play();
        
        if (playPromise !== undefined) {
          playPromise.catch(() => {});
        }
      }
    } catch (e) {}
  }
};

export default SoundManager;
