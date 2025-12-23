// Enhanced JavaScript for EFEWALICOMMS OY website
(function() {
    'use strict';

    // Performance optimization: Use requestAnimationFrame for smooth animations
    const raf = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || function(callback) { setTimeout(callback, 16); };

    // Utility functions
    const utils = {
        // Debounce function for performance
        debounce: function(func, wait) {
            let timeout;
            return function executedFunction(...args) {
                const later = () => {
                    clearTimeout(timeout);
                    func(...args);
                };
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
            };
        },

        // Throttle function for scroll events
        throttle: function(func, limit) {
            let inThrottle;
            return function() {
                const args = arguments;
                const context = this;
                if (!inThrottle) {
                    func.apply(context, args);
                    inThrottle = true;
                    setTimeout(() => inThrottle = false, limit);
                }
            };
        },

        // Check if element is in viewport
        isInViewport: function(element) {
            const rect = element.getBoundingClientRect();
            return (
                rect.top >= 0 &&
                rect.left >= 0 &&
                rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
                rect.right <= (window.innerWidth || document.documentElement.clientWidth)
            );
        },

        // Smooth scroll to element
        smoothScrollTo: function(element, offset = 0) {
            const targetPosition = element.offsetTop - offset;
            const startPosition = window.pageYOffset;
            const distance = targetPosition - startPosition;
            const duration = 1000;
            let start = null;

            function animation(currentTime) {
                if (start === null) start = currentTime;
                const timeElapsed = currentTime - start;
                const run = ease(timeElapsed, startPosition, distance, duration);
                window.scrollTo(0, run);
                if (timeElapsed < duration) requestAnimationFrame(animation);
            }

            function ease(t, b, c, d) {
                t /= d / 2;
                if (t < 1) return c / 2 * t * t + b;
                t--;
                return -c / 2 * (t * (t - 2) - 1) + b;
            }

            requestAnimationFrame(animation);
        }
    };

    // Enhanced Mobile Menu Management
    class MobileMenu {
        constructor() {
            this.button = document.getElementById('mobile-menu-button');
            this.overlay = document.getElementById('mobile-menu-overlay');
            this.hamburgerIcon = document.getElementById('hamburger-icon');
            this.closeIcon = document.getElementById('close-icon');
            this.isOpen = false;

            this.init();
        }

        init() {
            if (!this.button || !this.overlay) {
                console.warn('Mobile menu elements not found');
                return;
            }

            this.button.addEventListener('click', this.toggle.bind(this));
            this.overlay.addEventListener('click', this.handleOverlayClick.bind(this));
            
            // Close menu on escape key
            document.addEventListener('keydown', (e) => {
                if (e.key === 'Escape' && this.isOpen) {
                    this.close();
                }
            });

            // Close menu when clicking on links
            this.overlay.querySelectorAll('a').forEach(link => {
                link.addEventListener('click', () => this.close());
            });

            console.log('Mobile menu initialized');
        }

        toggle() {
            if (this.isOpen) {
                this.close();
            } else {
                this.open();
            }
        }

        open() {
            this.isOpen = true;
            this.overlay.classList.remove('hidden');
            this.overlay.classList.add('open');
            this.hamburgerIcon.classList.add('hidden');
            this.closeIcon.classList.remove('hidden');
            this.button.setAttribute('aria-expanded', 'true');
            document.body.classList.add('overflow-hidden');
            
            // Focus management
            this.overlay.focus();
            console.log('Mobile menu opened');
        }

        close() {
            this.isOpen = false;
            this.overlay.classList.add('hidden');
            this.overlay.classList.remove('open');
            this.hamburgerIcon.classList.remove('hidden');
            this.closeIcon.classList.add('hidden');
            this.button.setAttribute('aria-expanded', 'false');
            document.body.classList.remove('overflow-hidden');
            
            // Return focus to menu button
            this.button.focus();
            console.log('Mobile menu closed');
        }

        handleOverlayClick(e) {
            if (e.target === this.overlay) {
                this.close();
            }
        }
    }

    // Enhanced Mobile Dropdown Management
    class MobileDropdown {
        constructor() {
            this.toggles = document.querySelectorAll('.mobile-dropdown-toggle');
            this.init();
        }

        init() {
            this.toggles.forEach(toggle => {
                toggle.addEventListener('click', this.handleToggle.bind(this));
            });
            console.log('Mobile dropdowns initialized');
        }

        handleToggle(e) {
            e.preventDefault();
            const toggle = e.currentTarget;
            const content = toggle.nextElementSibling;
            const icon = toggle.querySelector('svg');

            // Close other dropdowns
            this.toggles.forEach(otherToggle => {
                if (otherToggle !== toggle) {
                    otherToggle.classList.remove('active');
                    otherToggle.setAttribute('aria-expanded', 'false');
                    const otherContent = otherToggle.nextElementSibling;
                    otherContent.classList.remove('expanded');
                }
            });

            // Toggle current dropdown
            toggle.classList.toggle('active');
            content.classList.toggle('expanded');
            const isExpanded = toggle.classList.contains('active');
            toggle.setAttribute('aria-expanded', isExpanded.toString());

            if (icon) {
                icon.style.transform = isExpanded ? 'rotate(180deg)' : 'rotate(0deg)';
            }
        }
    }

    // Enhanced Read More Functionality
    class ReadMoreToggle {
        constructor() {
            this.toggles = document.querySelectorAll('.read-more-toggle');
            this.init();
        }

        init() {
            this.toggles.forEach(toggle => {
                toggle.addEventListener('click', this.handleToggle.bind(this));
            });
            console.log('Read more toggles initialized');
        }

        handleToggle(e) {
            e.preventDefault();
            const toggle = e.currentTarget;
            const description = toggle.previousElementSibling;
            const isExpanded = toggle.dataset.expanded === 'true';

            if (isExpanded) {
                description.textContent = description.dataset.shorttext;
                toggle.textContent = 'More information →';
                toggle.dataset.expanded = 'false';
                toggle.setAttribute('aria-expanded', 'false');
            } else {
                description.textContent = description.dataset.fulltext;
                toggle.textContent = 'Less information ←';
                toggle.dataset.expanded = 'true';
                toggle.setAttribute('aria-expanded', 'true');
            }
        }
    }

    // Enhanced FAQ Accordion
    class FAQAccordion {
        constructor() {
            this.toggles = document.querySelectorAll('.faq-toggle');
            this.init();
        }

        init() {
            this.toggles.forEach(toggle => {
                toggle.addEventListener('click', this.handleToggle.bind(this));
            });
            console.log('FAQ accordion initialized');
        }

        handleToggle(e) {
            e.preventDefault();
            const toggle = e.currentTarget;
            const content = toggle.nextElementSibling;
            const icon = toggle.querySelector('svg');

            // Close other FAQ items
            this.toggles.forEach(otherToggle => {
                if (otherToggle !== toggle) {
                    const otherContent = otherToggle.nextElementSibling;
                    otherContent.classList.add('hidden');
                    const otherIcon = otherToggle.querySelector('svg');
                    if (otherIcon) otherIcon.classList.remove('rotate-180');
                }
            });

            // Toggle current FAQ item
            content.classList.toggle('hidden');
            if (icon) {
                icon.classList.toggle('rotate-180');
            }
        }
    }

    // Enhanced Scroll to Top Button
    class ScrollToTop {
        constructor() {
            this.button = document.getElementById('scrollToTopBtn');
            this.init();
        }

        init() {
            if (!this.button) {
                console.warn('Scroll to top button not found');
                return;
            }

            // Throttled scroll listener for better performance
            const handleScroll = utils.throttle(() => {
                if (window.scrollY > 300) {
                    this.button.classList.remove('hidden');
                    this.button.classList.add('flex');
                } else {
                    this.button.classList.add('hidden');
                    this.button.classList.remove('flex');
                }
            }, 100);

            window.addEventListener('scroll', handleScroll);
            this.button.addEventListener('click', this.scrollToTop.bind(this));
            console.log('Scroll to top button initialized');
        }

        scrollToTop(e) {
            e.preventDefault();
            utils.smoothScrollTo(document.body);
        }
    }

    // Enhanced Loading Indicator
    class LoadingIndicator {
        constructor() {
            this.indicator = document.getElementById('loading-indicator');
            this.init();
        }

        init() {
            if (!this.indicator) {
                console.warn('Loading indicator not found');
                return;
            }

            // Hide loading indicator when page is loaded
            window.addEventListener('load', () => {
                setTimeout(() => {
                    this.indicator.classList.add('hidden');
                }, 500);
            });

            // Hide immediately if page is already loaded
            if (document.readyState === 'complete') {
                this.indicator.classList.add('hidden');
            }
        }
    }

    // Enhanced Current Year Updater
    class CurrentYearUpdater {
        constructor() {
            this.elements = document.querySelectorAll('[id*="current-year"]');
            this.init();
        }

        init() {
            this.elements.forEach(element => {
                element.textContent = new Date().getFullYear();
            });
            console.log('Current year updated');
        }
    }

    // Enhanced Service Description Initializer
    class ServiceDescriptionInitializer {
        constructor() {
            this.descriptions = document.querySelectorAll('.service-description');
            this.init();
        }

        init() {
            this.descriptions.forEach(desc => {
                if (desc.dataset.shorttext) {
                    desc.textContent = desc.dataset.shorttext;
                }
            });
            console.log('Service descriptions initialized');
        }
    }

    // Enhanced Intersection Observer for animations
    class AnimationObserver {
        constructor() {
            this.observer = new IntersectionObserver(
                (entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            entry.target.classList.add('text-animate');
                        }
                    });
                },
                {
                    threshold: 0.1,
                    rootMargin: '0px 0px -50px 0px'
                }
            );

            this.init();
        }

        init() {
            const animatedElements = document.querySelectorAll('h1, h2, h3, p');
            animatedElements.forEach(el => {
                this.observer.observe(el);
            });
            console.log('Animation observer initialized');
        }
    }

    // Enhanced Error Handling
    class ErrorHandler {
        static handleError(error, context) {
            console.error(`Error in ${context}:`, error);
            // In production, you might want to send this to an error tracking service
        }
    }

    // Initialize everything when DOM is ready
    document.addEventListener('DOMContentLoaded', () => {
        try {
            console.log('Initializing EFEWALICOMMS OY website...');
            
            // Initialize all components
            new MobileMenu();
            new MobileDropdown();
            new ReadMoreToggle();
            new FAQAccordion();
            new ScrollToTop();
            new LoadingIndicator();
            new CurrentYearUpdater();
            new ServiceDescriptionInitializer();
            new AnimationObserver();

            console.log('Website initialization complete');
        } catch (error) {
            ErrorHandler.handleError(error, 'DOMContentLoaded');
        }
    });

    // Performance monitoring
    window.addEventListener('load', () => {
        if ('performance' in window) {
            const perfData = performance.getEntriesByType('navigation')[0];
            console.log('Page load time:', perfData.loadEventEnd - perfData.loadEventStart, 'ms');
        }
    });

    // Service Worker registration (for future PWA features)
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
            navigator.serviceWorker.register('/sw.js')
                .then(registration => {
                    console.log('SW registered: ', registration);
                })
                .catch(registrationError => {
                    console.log('SW registration failed: ', registrationError);
                });
        });
    }

})();

// Logout function - exposed globally for onclick handler
function logout() {
    // Clear auth_token cookie
    document.cookie = 'auth_token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    document.cookie = 'auth_token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/; domain=' + window.location.hostname;
    
    // Redirect to main app with logout flag (main app will clear its localStorage)
    window.location.href = window.location.origin.replace(':8000', ':8080') + '?logout=true';
}

// Make logout available globally
window.logout = logout;
