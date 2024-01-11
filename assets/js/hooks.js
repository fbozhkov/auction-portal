let Hooks = {}

Hooks.Swiper = {
    mounted() {
        var swiper = new Swiper(".mySwiper", {
            // spaceBetween: 10,
            slidesPerView: 4,
            freeMode: true,
            watchSlidesProgress: true,
        });
        var swiper2 = new Swiper(".mySwiper2", {
            // spaceBetween: 10,
            navigation: {
                nextEl: ".swiper-button-next",
                prevEl: ".swiper-button-prev",
            },
            thumbs: {
                swiper: swiper,
            },
        });
    }
}

Hooks.HamburgerToggle = {
    toggleDropdown() {
        let dropdown = document.getElementById("hamburger-dropdown");
        if (dropdown.style.display === "block") {
            dropdown.style.display = "none";
        } else {
            dropdown.style.display = "block";
        }
    }
}

export default Hooks;