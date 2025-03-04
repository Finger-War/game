// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"

// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Define hooks for LiveView
let Hooks = {}

// Enhanced countdown hook with immediate redirect
Hooks.Countdown = {
  mounted() {
    console.log("Countdown hook mounted - with immediate redirect capability");
    
    // Set up event handler
    this.handleEvent("countdown-redirect", ({count, target}) => {
      console.log("Starting countdown", count, target);
      
      // Find countdown element
      let countElement = document.getElementById("countdown");
      let currentCount = count || 3;
      
      // Add immediate redirect capability
      if (count === 0) {
        console.log("Immediate redirect requested");
        window.location.href = target || "/";
        return;
      }
      
      // Start countdown interval
      const countInterval = setInterval(() => {
        currentCount--;
        
        // Update display
        if (countElement) {
          countElement.textContent = currentCount;
        }
        
        // When done, navigate
        if (currentCount <= 0) {
          clearInterval(countInterval);
          console.log("Countdown finished, redirecting to", target || "/");
          window.location.href = target || "/";
        }
      }, 1000);
    });
  }
};

// Game specific hooks
Hooks.GameInput = {
  mounted() {
    this.el.focus();
    this.feedback = document.getElementById('input-feedback');
    
    // Initialize audio elements if they don't exist
    if (!window.gameAudio.initialized) {
      window.gameAudio = {
        initialized: true,
        correct: new Audio('/sounds/correct.mp3'),
        incorrect: new Audio('/sounds/incorrect.mp3'),
        countdown: new Audio('/sounds/countdown.mp3'),
        victory: new Audio('/sounds/victory.mp3'),
        defeat: new Audio('/sounds/defeat.mp3'),
        typing: new Audio('/sounds/typing.mp3')
      };
      
      // Preload all audio
      Object.values(window.gameAudio).forEach(audio => {
        if (audio instanceof Audio) {
          audio.load();
          audio.volume = 0.5;
        }
      });
    }
    
    // Play typing sound when user types
    this.el.addEventListener('keydown', (e) => {
      if (e.key.length === 1 || e.key === 'Backspace') {
        if (window.gameAudio.typing) {
          // Reset and play typing sound
          window.gameAudio.typing.currentTime = 0;
          window.gameAudio.typing.play().catch(e => console.log("Audio play prevented:", e));
        }
      }
    });
    
    // Handle form submission feedback
    this.handleEvent("word_result", ({ result }) => {
      if (result === "correct") {
        this.showFeedback("correct");
        if (window.gameAudio.correct) {
          window.gameAudio.correct.play().catch(e => console.log("Audio play prevented:", e));
        }
      } else {
        this.showFeedback("incorrect");
        if (window.gameAudio.incorrect) {
          window.gameAudio.incorrect.play().catch(e => console.log("Audio play prevented:", e));
        }
      }
    });
    
    // Handle match end sounds
    this.handleEvent("match_ended", ({ status }) => {
      if (status === "victory" && window.gameAudio.victory) {
        window.gameAudio.victory.play().catch(e => console.log("Audio play prevented:", e));
      } else if (status === "defeat" && window.gameAudio.defeat) {
        window.gameAudio.defeat.play().catch(e => console.log("Audio play prevented:", e));
      }
    });
    
    // Handle countdown sound
    this.handleEvent("time_warning", () => {
      if (window.gameAudio.countdown) {
        window.gameAudio.countdown.play().catch(e => console.log("Audio play prevented:", e));
      }
    });
  },
  
  showFeedback(type) {
    this.feedback.className = "absolute top-0 left-0 w-full h-full rounded-lg";
    
    if (type === "correct") {
      this.feedback.classList.add("bg-green-500", "bg-opacity-20");
    } else {
      this.feedback.classList.add("bg-red-500", "bg-opacity-20");
    }
    
    this.feedback.classList.remove("hidden");
    
    // Hide feedback after animation
    setTimeout(() => {
      this.feedback.classList.add("hidden");
    }, 300);
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
