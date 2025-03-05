/**
 * TypingAnimation - A clean implementation of a typing animation
 * that follows best practices for memory management and performance.
 */
export default {
  // Store active animations to clean them up if needed
  _activeAnimations: new Map(),
  
  // Initialize the animation when the DOM is ready
  initialize() {
    document.addEventListener("DOMContentLoaded", () => {
      const typedElement = document.getElementById('typed-subtitle');
      
      if (typedElement) {
        // Start animation with the subtitle and store reference for cleanup
        const animationId = this.startAnimation(
          typedElement, 
          "The distributed typing battle", 
          { 
            typingSpeed: 100,
            pauseDuration: 3000,
            backspaceSpeed: 50,
            restartDelay: 500
          }
        );
        
        // Cleanup animation when page is unloaded
        window.addEventListener("beforeunload", () => {
          this.stopAnimation(animationId);
        });
      }
    });
  },
  
  // Start an animation with options and return a unique ID
  startAnimation(element, text, options = {}) {
    if (!element) return null;
    
    // Generate unique ID for this animation
    const animationId = Math.random().toString(36).substr(2, 9);
    
    // Default options
    const config = {
      typingSpeed: options.typingSpeed || 100,
      pauseDuration: options.pauseDuration || 3000,
      backspaceSpeed: options.backspaceSpeed || 50,
      restartDelay: options.restartDelay || 500,
      loop: options.loop !== undefined ? options.loop : true
    };
    
    // Store animation metadata
    this._activeAnimations.set(animationId, {
      element,
      timeouts: [],
      intervals: [],
      isActive: true
    });
    
    // Start the typing process
    this._typeText(animationId, element, text, 0, config);
    
    return animationId;
  },
  
  // Clean up an animation
  stopAnimation(animationId) {
    if (!animationId || !this._activeAnimations.has(animationId)) return;
    
    const animation = this._activeAnimations.get(animationId);
    
    // Clear all timeouts
    animation.timeouts.forEach(timeout => clearTimeout(timeout));
    
    // Clear all intervals
    animation.intervals.forEach(interval => clearInterval(interval));
    
    // Mark as inactive
    animation.isActive = false;
    
    // Remove from map
    this._activeAnimations.delete(animationId);
  },
  
  // Private method to handle typing text
  _typeText(animationId, element, text, index, config) {
    // Get animation record
    const animation = this._activeAnimations.get(animationId);
    if (!animation || !animation.isActive) return;
    
    // If element no longer exists in DOM, clean up
    if (!document.body.contains(element)) {
      this.stopAnimation(animationId);
      return;
    }
    
    // Type next character
    if (index < text.length) {
      element.textContent += text.charAt(index);
      
      // Schedule next character
      const timeout = setTimeout(() => {
        this._typeText(animationId, element, text, index + 1, config);
      }, config.typingSpeed);
      
      animation.timeouts.push(timeout);
    } else {
      // Typing complete, pause then erase
      const timeout = setTimeout(() => {
        this._eraseText(animationId, element, config);
      }, config.pauseDuration);
      
      animation.timeouts.push(timeout);
    }
  },
  
  // Private method to handle erasing text
  _eraseText(animationId, element, config) {
    // Get animation record
    const animation = this._activeAnimations.get(animationId);
    if (!animation || !animation.isActive) return;
    
    // If element no longer exists in DOM, clean up
    if (!document.body.contains(element)) {
      this.stopAnimation(animationId);
      return;
    }
    
    const interval = setInterval(() => {
      if (element.textContent.length > 0) {
        element.textContent = element.textContent.slice(0, -1);
      } else {
        // Text fully erased
        clearInterval(interval);
        
        // Start again after delay if looping
        if (config.loop) {
          const timeout = setTimeout(() => {
            this._typeText(animationId, element, config.text || "The distributed typing battle", 0, config);
          }, config.restartDelay);
          
          animation.timeouts.push(timeout);
        }
      }
    }, config.backspaceSpeed);
    
    animation.intervals.push(interval);
  }
};
