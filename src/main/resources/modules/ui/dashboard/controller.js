$(function() {
	$(".column").sortable({
		// cancel: ".portlet-content",
		opacity: 0.6,
		revert: true,
		cursor: "move",
		handle: ".portlet-header",
		connectWith : ".column"
	});
	
	// add the move cursor as a visual hint
	$(".portlet-header").addClass("move");

	/* NOT REQUIRED RIGHT NOW:
	$(".portlet").addClass(
			"ui-widget ui-widget-content ui-helper-clearfix ui-corner-all")
			.find(".portlet-header").addClass("ui-widget-header ui-corner-all")
			.prepend("<span class='ui-icon ui-icon-minusthick'></span>").end()
			.find(".portlet-content");

	$(".portlet-header .ui-icon").click(
			function() {
				$(this).toggleClass("ui-icon-minusthick").toggleClass(
						"ui-icon-plusthick");
				$(this).parents(".portlet:first").find(".portlet-content")
						.toggle();
			}); */

	/* $(".column").disableSelection(); */
});