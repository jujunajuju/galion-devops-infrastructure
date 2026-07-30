document.addEventListener("DOMContentLoaded", function () {

    console.log("🚀 Galion DevOps Dashboard loaded");

    const steps = document.querySelectorAll(".step");

    steps.forEach((step, index) => {

        step.style.animationDelay = `${index * 0.2}s`;

    });


});
