// Mobile Menu Toggle
const hamburger = document.querySelector('.hamburger');
const navMenu = document.querySelector('.nav-menu');

hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('active');
    navMenu.classList.toggle('active');
});

// Close mobile menu when clicking on a link
document.querySelectorAll('.nav-menu a').forEach(link => {
    link.addEventListener('click', () => {
        hamburger.classList.remove('active');
        navMenu.classList.remove('active');
    });
});

// Smooth Scrolling
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Navbar Scroll Effect
window.addEventListener('scroll', () => {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        navbar.style.boxShadow = '0 5px 20px rgba(0, 0, 0, 0.15)';
    } else {
        navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
    }
});

// Pipeline Tabs
const tabBtns = document.querySelectorAll('.tab-btn');
const tabContents = document.querySelectorAll('.tab-content');

tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        // Remove active class from all buttons and contents
        tabBtns.forEach(b => b.classList.remove('active'));
        tabContents.forEach(c => c.classList.remove('active'));

        // Add active class to clicked button
        btn.classList.add('active');

        // Show corresponding content
        const tabId = btn.getAttribute('data-tab');
        document.getElementById(tabId).classList.add('active');
    });
});

// Intersection Observer for Animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all sections
document.querySelectorAll('.section').forEach(section => {
    section.style.opacity = '0';
    section.style.transform = 'translateY(50px)';
    section.style.transition = 'all 0.6s ease';
    observer.observe(section);
});

// Counter Animation for Stats
const animateCounter = (element, target, duration = 2000) => {
    let current = 0;
    const increment = target / (duration / 16);
    
    const updateCounter = () => {
        current += increment;
        if (current < target) {
            element.textContent = Math.floor(current);
            requestAnimationFrame(updateCounter);
        } else {
            element.textContent = target;
        }
    };
    
    updateCounter();
};

// Trigger counter animation when stats section is visible
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const statNumbers = entry.target.querySelectorAll('.stat-card h3');
            statNumbers.forEach(num => {
                const target = parseInt(num.textContent);
                animateCounter(num, target);
            });
            statsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

const heroStats = document.querySelector('.hero-stats');
if (heroStats) {
    statsObserver.observe(heroStats);
}

// Form Submission
const contactForm = document.querySelector('.contact-form form');
if (contactForm) {
    contactForm.addEventListener('submit', (e) => {
        e.preventDefault();
        alert('Thank you for your message! We will get back to you soon.');
        contactForm.reset();
    });
}

// Dynamic Architecture Diagram (SVG)
const createArchitectureDiagram = () => {
    const diagram = document.getElementById('arch-diagram');
    if (!diagram) return;

    // Create SVG dynamically
    const svg = `
        <svg viewBox="0 0 800 600" xmlns="http://www.w3.org/2000/svg">
            <!-- Background -->
            <defs>
                <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
                    <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
                </linearGradient>
            </defs>
            
            <!-- Internet Cloud -->
            <ellipse cx="400" cy="50" rx="80" ry="40" fill="#60a5fa" opacity="0.7"/>
            <text x="400" y="55" text-anchor="middle" fill="white" font-weight="bold">Internet</text>
            
            <!-- ALB -->
            <rect x="350" y="120" width="100" height="60" rx="10" fill="url(#grad1)"/>
            <text x="400" y="155" text-anchor="middle" fill="white" font-weight="bold">AWS ALB</text>
            
            <!-- NGINX -->
            <rect x="350" y="220" width="100" height="60" rx="10" fill="#10b981"/>
            <text x="400" y="255" text-anchor="middle" fill="white" font-weight="bold">NGINX</text>
            
            <!-- Services Layer -->
            <rect x="100" y="320" width="120" height="60" rx="10" fill="#f59e0b"/>
            <text x="160" y="355" text-anchor="middle" fill="white" font-size="14" font-weight="bold">ArgoCD</text>
            
            <rect x="250" y="320" width="120" height="60" rx="10" fill="#8b5cf6"/>
            <text x="310" y="355" text-anchor="middle" fill="white" font-size="14" font-weight="bold">Vault</text>
            
            <rect x="400" y="320" width="120" height="60" rx="10" fill="#06b6d4"/>
            <text x="460" y="355" text-anchor="middle" fill="white" font-size="14" font-weight="bold">Nexus</text>
            
            <rect x="550" y="320" width="120" height="60" rx="10" fill="#ef4444"/>
            <text x="610" y="355" text-anchor="middle" fill="white" font-size="14" font-weight="bold">SonarQube</text>
            
            <!-- Database -->
            <ellipse cx="400" cy="500" rx="100" ry="50" fill="#10b981"/>
            <text x="400" y="505" text-anchor="middle" fill="white" font-weight="bold">MongoDB</text>
            <text x="400" y="525" text-anchor="middle" fill="white" font-size="12">Atlas</text>
            
            <!-- Connections -->
            <line x1="400" y1="90" x2="400" y2="120" stroke="#334155" stroke-width="2"/>
            <line x1="400" y1="180" x2="400" y2="220" stroke="#334155" stroke-width="2"/>
            <line x1="400" y1="280" x2="160" y2="320" stroke="#334155" stroke-width="2"/>
            <line x1="400" y1="280" x2="310" y2="320" stroke="#334155" stroke-width="2"/>
            <line x1="400" y1="280" x2="460" y2="320" stroke="#334155" stroke-width="2"/>
            <line x1="400" y1="280" x2="610" y2="320" stroke="#334155" stroke-width="2"/>
            <line x1="310" y1="380" x2="400" y2="450" stroke="#334155" stroke-width="2"/>
        </svg>
    `;
    
    diagram.innerHTML = svg;
};

// Initialize diagram when page loads
window.addEventListener('load', createArchitectureDiagram);

// Add active class to current section in nav
window.addEventListener('scroll', () => {
    const sections = document.querySelectorAll('.section[id]');
    const navLinks = document.querySelectorAll('.nav-menu a');
    
    let current = '';
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (scrollY >= (sectionTop - 200)) {
            current = section.getAttribute('id');
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${current}`) {
            link.classList.add('active');
        }
    });
});

console.log('🚀 DevOps Platform Website Loaded Successfully!');
