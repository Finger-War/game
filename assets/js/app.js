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
import SoundManager from "./sounds"

// Initialize the sound manager once
const soundManager = SoundManager.initialize();

// Define hooks for LiveView
let Hooks = {}

// Enhanced countdown hook with immediate redirect
Hooks.Countdown = {
  mounted() {
    // Set up event handler
    this.handleEvent("countdown-redirect", ({count, target}) => {
      // Find countdown element
      let countElement = document.getElementById("countdown");
      let currentCount = count || 3;
      
      // Add immediate redirect capability
      if (count === 0) {
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
    
    // Play typing sound when user types
    this.el.addEventListener('keydown', (e) => {
      if (e.key.length === 1 || e.key === 'Backspace') {
        soundManager.play('typing');
      }
    });
    
    // Handle match start sound
    this.handleEvent("match_started", () => {
      soundManager.play('start_match');
    });
    
    // Handle form submission feedback
    this.handleEvent("word_result", ({ result }) => {
      if (result === "correct") {
        this.showFeedback("correct");
        soundManager.play('correct');
      } else {
        this.showFeedback("incorrect");
        soundManager.play('incorrect');
      }
    });
    
    // Handle match end sounds
    this.handleEvent("match_ended", ({ status }) => {
      if (status === "victory") {
        soundManager.play('victory');
      } else if (status === "defeat") {
        soundManager.play('defeat');
      }
    });
    
    // Handle countdown sound
    this.handleEvent("time_warning", () => {
      soundManager.play('countdown');
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
