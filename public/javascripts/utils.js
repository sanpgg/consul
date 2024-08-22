/*general settings*/
var Functions = {
	init: function(){
		Functions.loadSidr()
				 .loadCarousel();
	}, 
	loadCarousel: function(){
		$('.owl-carousel').owlCarousel({
		    loop:true,
		    margin:10,
		    nav: true,
		    navText: ["<i class='fas fa-angle-left'></i>", "<i class='fas fa-angle-right'></i>"],
		    responsiveClass:true,
		    responsive:{
		        0:{
		            items:1,
		            nav: true
		        },
		        768:{
		            items:2,
		            nav: true
		        },
		        1200:{
		            items:3,
		            nav:true,
		            loop:false
		        }
		    }
		});
		return this;
	},
	loadSidr: function(){
        $('#btn-nav-menu').sidr({
            name: 'content-nav-menu',
            side: 'right',
            renaming: false,
            onOpen: function() {
                $('.overlay-web-full').css({ "-webkit-transition" : "opacity 1s ease-out", "height" : "100%", "opacity" : "0.8" });
            },
            onClose: function() {
                $('.overlay-web-full').css({ " -webkit-transition": "opacity 1s ease-in", "height" : "0", "opacity" : "0" });
            }
        });
        $(document).on('touchstart click', '.close-sidr', function(){
            $.sidr('close', 'sidebar-wrapper');
        });
        return this;
    },
    close_menu_resize: function(){
		$.sidr('close', 'content-nav-menu');
	} 
};
$(document).on('touchstart click', '.close-nav', Functions.close_menu_resize);
$(document).ready(Functions.init);
$(window).on('resize', Functions.loadSidr);
$(window).on('resize', Functions.close_menu_resize);
