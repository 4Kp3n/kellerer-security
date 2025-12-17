document.addEventListener("DOMContentLoaded", (event) => {
    gsap.registerPlugin(ScrollTrigger)
    console.log("GSAP verfügbar?", typeof gsap !== 'undefined');
    console.log("DOM geladen");
    console.log("GSAP verfügbar?", typeof gsap);
    console.log("ScrollTrigger verfügbar?", typeof ScrollTrigger);
    console.log("Boxen gefunden?", document.querySelectorAll('.box').length);
    
    if (typeof gsap === 'undefined') {
        console.error("GSAP ist nicht geladen!");
        return;
    }
    
    gsap.registerPlugin(ScrollTrigger);
    
    // Animation 1: Green Box
    gsap.to(".green", {
        rotation: 720,
        x: 500,
        duration: 2,
        ease: "power2.inOut"
    });
    
    // Animation 2: Purple Box
    gsap.from(".purple", {
        rotation: -360,
        x: -100,
        duration: 2,
        ease: "power2.inOut"
    });
    
    // Animation 3: Blue Box
    gsap.fromTo(".blue", 
        { x: 100 },
        { 
            rotation: 360, 
            x: -100, 
            duration: 2,
            ease: "power2.inOut"
        }
    );
});
 
